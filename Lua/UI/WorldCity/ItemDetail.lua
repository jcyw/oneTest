--[[
    author:{zhanzhang}
    time:2019-07-02 15:53:22
    function:{外城操作盘}
]]
local GD = _G.GD
local ItemDetail = fgui.extension_class(GButton)
fgui.register_extension("ui://WorldCity/BuildComplete", ItemDetail)

local BuildModel = import("Model/BuildModel")
local MapModel = import("Model/MapModel")
local FavoriteModel = import("Model/FavoriteModel")
local MissionEventModel = import("Model/MissionEventModel")
local UnionInfoModel = import("Model/Union/UnionInfoModel")
local GuidePanel = import("Model/GuideControllerModel")
local UIType = _G.GD.GameEnum.UIType
local WorldBuildType = import("Enum/WorldBuildType")
local ArmiesModel = import("Model/ArmiesModel")
local UnionTrritoryModel = import("Model/Union/UnionTrritoryModel")

local isInitSelectTip = false

function ItemDetail:ctor()
    self.sortingOrder = CityType.CITY_MAP_SORTINGORDER.FunctionList

    self._titleBox = self:GetChild("tagBox")
    self._animIn = self:GetTransition("In")
    self._animOut = self:GetTransition("Out")
    self._controller = self:GetController("Controller")

    for i = 1, 6 do
        self["_btnFunc" .. i] = self:GetChild("btn" .. i)
    end

    -- self:AddListener(self.onClick,
    --     function()
    --         if self.isItemClick then
    --             self.isItemClick = false
    --             return
    --         end

    --         Event.Broadcast(EventDefines.UICloseMapDetail)
    --     end
    -- )
    self:AddEvent(
        EventDefines.UIOnWorldMapMove,
        function()
            self:CloseSelectTip()
            self:OffAnim()
        end
    )
    self:AddEvent(
        EventDefines.UICloseMapDetail,
        function()
            self:CloseSelectTip()
            self:OffAnim()
            if self.typeMonster then
                self:UnScheduleFast(self.typeMonster)
            end
        end
    )
    self.refreshCallback = function()
        self:RefreshItemPos()
    end
    self:SetVisible()
    GuidePanel:SetParentUI(self, UIType.ItemDetailUI)

    self.typeMonster = function()
        local CollectionInstructionsVisible = UIMgr:GetUIOpen("CollectionInstructions")
        if CollectionInstructionsVisible then
            return
        end
        Event.Broadcast(EventDefines.UICloseMapDetail)
        self:UnScheduleFast(self.typeMonster)
        if not MapModel.GetArea(self.posNum) then
            return
        end
        UIMgr:Open("WildMonster", self.posNum, self.isGuide)
        --点击野怪音效
        local monster = ConfigMgr.GetItem("configMonsters", self.chunkInfo.ConfId)
        if not monster then
            return
        end
        AudioModel.Play(monster.line)

        if monster.type == 2 or monster.type == 3 then
            local list = PlayerDataModel:GetData(PlayerDataEnum.BREAKPOINT) or {}
            if list[20002] then
                return
            end
            --第一次点到剿灭行动活动怪
            SdkModel.TrackBreakPoint(20002, monster.activity_id) --打点
            list[20002] = true
            PlayerDataModel:SetData(PlayerDataEnum.BREAKPOINT, list)
        end
        -- self:UnScheduleFast(self.typeMonster)
    end
end

function ItemDetail:OnAnim()
    self._animIn:Play()
end

function ItemDetail:SetVisible()
    self._HandleGroup.visible = false
    self.visible = false
    self:CloseSelectTip()
    Event.Broadcast(EventDefines.UIOnCloseItemDetail)
end

function ItemDetail:OffAnim(cb)
    self.confId = nil
    if self.visible then
        self._animOut:Play(
            function()
                GameUpdate.Inst():DelFixedUpdate(self.refreshCallback)
                if cb then
                    cb()
                else
                    self:SetVisible()
                end
                self.isItemClick = false
            end
        )
    elseif cb then
        self._HandleGroup.visible = true
        cb()
    end

    if self._titleBox then
        self._titleBox:releaseSchedulerHandle()
    end
end

function ItemDetail:GetShow()
    return self.visible
end

function ItemDetail:RefreshItemPos()
    if WorldMap.Instance() then
        self.x, self.y = MathUtil.ScreenRatio(WorldMap.Instance():LogicToScreenPos(self.itemPosX, self.itemPosY))
    end
end

--新的选择框
--0.6
--0.75
--1.2
function ItemDetail:JudgeCondition(ConfId)
    local list = ConfigMgr.GetList("configMapSearchs")
    local id = MapModel.GetResByMineConfId(ConfId)
    --105002
    local config
    for i = 1, #list do
        if list[i].category == id then
            config = list[i]
        end
    end
    if config and config.condition > BuildModel.GetCenterLevel() then
        -- TipUtil.TipById(13020 + config.id, {level = config.condition})
        return {config.id, config.condition}
    end

    return nil
end
-------------------------------------------外城部分 -------------------------------------
function ItemDetail:WorldCityInit(posNum, screenPos, callback, isGuide)
    -- self:InitSelectTip()
    self.posNum = posNum
    GameUpdate.Inst():DelFixedUpdate(self.refreshCallback)
    if self.typeMonster then
        self:UnScheduleFast(self.typeMonster)
    end
    self.itemPosX, self.itemPosY = MathUtil.GetCoordinate(posNum)
    if MapModel.IsOutBorder(self.itemPosX, self.itemPosY) then
        Log.Info("点击区域越界")
        return
    end

    -- 判断王城站建筑无市长弹王城站广告界面
    local activityData = ActivityModel.GetRoyalBattleInfo()
    local chunkInfo, pointType = MapModel.GetArea(posNum)
    if not (activityData and activityData.Open) then
        if (chunkInfo and (chunkInfo.Category == 11 or chunkInfo.Category == 12)) then
            local hasUser = RoyalModel.warInfo and RoyalModel.warInfo.KingInfo
            if not hasUser or (not RoyalModel.warInfo.InWar and RoyalModel.warInfo.KingInfo.PlayerId == "") then
                --判断王城站建筑无市长弹王城站广告界面
                UIMgr:Open("RoyalTownOpoUpBox")
                return
            end
        end
    end

    if not chunkInfo then
        chunkInfo = {
            Catetory = Global.MapTypeBlank,
            Occupied = 0
        }
    end
    self.chunkInfo = chunkInfo

    --判断猎鹰活动是否解锁
    if chunkInfo.Category == Global.MapTypeMonster and not Model.isFalconOpen then
        local monsterInfo = ConfigMgr.GetItem("configMonsters", chunkInfo.ConfId)
        if monsterInfo.activity_id == 1900901 then
            if Model.Player.Level >= 4 then
                TipUtil.TipByContentWithWaring(StringUtil.GetI18n(I18nType.Commmon, "UI_Activity_FALCONType"))
            else
                TipUtil.TipById(50353)
                --TipUtil.TipByContent(nil, StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FALCONTIPS4"))
            end
            return
        end
    end

    local isMyFalcon, tempChunk = MapModel.CheckIsMyFalcon(posNum)
    if isMyFalcon then
        chunkInfo = tempChunk
        self.chunkInfo = tempChunk
    end
    self.x = screenPos.x
    self.y = screenPos.y
    self.isGuide = nil
    self.isGuide = isGuide
    if not isGuide and not GuidePanel:CheckGuiderPos() then
        Event.Broadcast(EventDefines.CloseGuide)
    end
    --修正建筑中心
    if chunkInfo and chunkInfo.Occupied ~= 0 then
        self.itemPosX, self.itemPosY = MathUtil.GetCoordinate(chunkInfo.Occupied)
        if chunkInfo.Category == Global.MapTypeThrone then
            self.ClickSize = 1.2
        else
            self.itemPosX = self.itemPosX - 0.5
            self.itemPosY = self.itemPosY - 0.5
            self.ClickSize = 0.75
        end
    else
        self.ClickSize = 0.6
    end
    self._selectTip.visible = false

    self:ShowSelectTip()
    if chunkInfo.Category == Global.MapTypeMonster then
        self._HandleGroup.visible = false
        self.visible = true
        -- if self.typeMonster then
        --     self:UnScheduleFast(self.typeMonster)
        -- end

        self:ScheduleFast(self.typeMonster, 0.5, 0.2)
        return
    elseif chunkInfo.Category == Global.MapTypeSecretBase then
        if chunkInfo.Occupied ~= 0 then
            local showXPos, showYPos = MathUtil.GetCoordinate(chunkInfo.Occupied)
            local isExplore, exploreInfo = MissionEventModel.CheckIsExploreing(showXPos, showYPos)
            if isExplore then
                -- self._selectTip.visible = true
                self._HandleGroup.visible = false
                self.visible = true

                local func = function()
                    if exploreInfo then
                        UIMgr:Open("PrisonExploration", exploreInfo)
                    else
                        local data = {
                            content = StringUtil.GetI18n(I18nType.Commmon, "Confirm_Explore_Last")
                        }
                        UIMgr:Open("ConfirmPopupText", data)
                    end

                    Event.Broadcast(EventDefines.UICloseMapDetail)
                end
                if isGuide then
                    self:ScheduleOnceFast(func, 0.5)
                else
                    func()
                end
                return
            end
        end
    end

    self.chunkCategory = chunkInfo.Category
    --点击外城地块音效
    if chunkInfo then
        if chunkInfo.Category == Global.MapTypeTown then -- 地块类型-玩家基地
            AudioModel.Play(80005)
        elseif chunkInfo.Category == Global.MapTypeMine then -- 地块类型-资源矿点
            AudioModel.Play(80007)
        elseif chunkInfo.Category == Global.MapTypeBlank then -- 地块类型-空地
            AudioModel.Play(80009)
        else
            --TODO  秘密基地  炮台等
        end
    end

    --判断矿是否解锁
    if chunkInfo and chunkInfo.Category == Global.MapTypeMine then
        local condition = self:JudgeCondition(chunkInfo.ConfId)
        if condition ~= nil then
            TipUtil.TipById(13020 + condition[1], {level = condition[2]})
            return
        end
    end

    local isBlackTrunk = MapModel.IsInBlackZone(self.itemPosX, self.itemPosY)

    self:OffAnim()
    self:OffAnim(
        function()
            self:ShowSelectTip()
            posNum = MapModel.GetTargetPos(posNum)
            self._titleBox:WorldInit(posNum)
            GameUpdate.Inst():AddFixedUpdate(self.refreshCallback)
            local funcs = MapModel.GetMapButtons(posNum)
            self.visible = true
            -- self._selectTip.visible = true
            self._HandleGroup.visible = true

            --检测是否满足条件
            for k, v in pairs(funcs) do
                if v == 3 then
                    --基地增益 指挥中心4级解锁
                    if not UnlockModel:UnlockCenter(UnlockModel.Center.Gain) then
                        table.remove(funcs, k)
                    end
                    break
                end
            end
            local count = #funcs

            self._controller.selectedPage = "Anim" .. count
            self.curentCount = count

            for i = 1, count do
                local _btnItem = self["_btnFunc" .. i]
                local funcData = ConfigMgr.GetItem("configMapButtons", funcs[i])
                local btnText = ConfigMgr.GetI18n("configI18nCommons", funcData.text)

                local isMapTerrain = WorldMap.Instance():IsMapTerrain(posNum) or isBlackTrunk

                if funcData.id == 12 and isMapTerrain then
                    _btnItem:SetGray()
                else
                    _btnItem:SetNormal()
                end

                _btnItem:Init(
                    btnText,
                    funcData.img,
                    function()
                        local a = PlayerDataModel.PlayId
                        if funcData.id == 1 then
                            --我的详情
                            TurnModel.PlayerDetails()
                        elseif funcData.id == 2 then
                            --领主详情
                            TurnModel.PlayerDetails(chunkInfo.OwnerId)
                        elseif funcData.id == 3 then
                            --3城市增益
                            UIMgr:Open("BaseGain", Global.PageBaseBuff)
                        elseif funcData.id == 4 then
                            --进入城市
                            Event.Broadcast(EventDefines.UIEnterMyCity)
                        elseif funcData.id == 5 then
                            -- end
                            -- MapModel.AttackCheck(
                            --     chunkInfo,
                            --     function()
                            --         fun()
                            --     end
                            -- )
                            --士兵援助
                            --local fun = function()
                            if chunkInfo.Category == Global.MapTypeTown then
                                -- 援助盟友
                                local pX, pY = MathUtil.GetCoordinate(posNum)
                                local confId = Global.BuildingUnionBuilding -- 联盟大厦
                                if BuildModel.CheckExist(confId) then
                                    Net.AllianceBattle.AssistLimit(
                                        chunkInfo.OwnerId,
                                        pX,
                                        pY,
                                        function(rsp)
                                            if rsp.Fail then
                                                return
                                            end

                                            if rsp.Max > 0 then
                                                UIMgr:Open("UnionSoldierAssistancePopup", posNum, rsp.Max, rsp.Used, ExpeditionType.JoinUnionDefense, chunkInfo.OwnerId)
                                            else
                                                TipUtil.TipById(50070)
                                            end
                                        end
                                    )
                                else
                                    TipUtil.TipById(50071)
                                end
                            else
                                -- 援助联盟堡垒
                                local pX, pY = MathUtil.GetCoordinate(posNum)
                                local confId = Global.BuildingUnionBuilding -- 联盟大厦
                                if BuildModel.CheckExist(confId) then
                                    Net.AllianceBattle.AssistLimit(
                                        chunkInfo.OwnerId,
                                        pX,
                                        pY,
                                        function(rsp)
                                            if rsp.Fail then
                                                return
                                            end

                                            if rsp.Max > 0 then
                                                UIMgr:Open("UnionSoldierAssistancePopup", posNum, rsp.Max, rsp.Used, ExpeditionType.UnionBuildingStation, chunkInfo.OwnerId)
                                            else
                                                TipUtil.TipById(50070)
                                            end
                                        end
                                    )
                                else
                                    TipUtil.TipById(50071)
                                end
                            end
                        elseif funcData.id == 6 then
                            --资源援助
                            local confId = Global.BuildingTransferStation -- 资源中转站
                            if BuildModel.CheckExist(confId) then
                                Net.AllianceAssist.AssistInfo(
                                    chunkInfo.OwnerId,
                                    function(rsp)
                                        if rsp.Fail then
                                            return
                                        end
                                        UIMgr:Open("UnionWarehouseAccessResources", 1, rsp)
                                    end
                                )
                            else
                                TipUtil.TipById(50202)
                            end
                        elseif funcData.id == 7 then
                            --7侦查
                            if ArmiesModel.CheckMissionLimit() then
                                return
                            end
                            MapModel.AttackCheck(
                                chunkInfo,
                                function()
                                    UIMgr:Open("Scout", posNum)
                                end
                            )
                        elseif funcData.id == 8 then
                            --集结进攻
                            local build = BuildModel.FindByConfId(Global.BuildingJointCommand)
                            if not build or build.Level <= 0 then
                                TipUtil.TipById(50291)
                                return
                            end
                            MapModel.AttackCheck(
                                chunkInfo,
                                function()
                                    UIMgr:Open("Aggregation", posNum)
                                end
                            )
                        elseif funcData.id == 9 then
                            --9攻击
                            MapModel.AttackCheck(
                                chunkInfo,
                                function()
                                    local data = {
                                        openType = pointType,
                                        posNum = posNum,
                                        mineAttach = (pointType == ExpeditionType.Mining)
                                    }
                                    UIMgr:Open("Expedition", data)
                                end
                            )
                        elseif funcData.id == 10 then
                            --矿点说明
                            if chunkInfo.Category == Global.MapTypeSecretBase then
                                UIMgr:Open("PrisonExplain")
                                return
                            end

                            --只有自己的矿能看部队详情
                            if (string.len(chunkInfo.OwnerId) > 0 and chunkInfo.OwnerId == Model.Account.accountId) then
                                UIMgr:Open("CollectDetails", chunkInfo)
                            else
                                UIMgr:Open("CollectionInstructions", chunkInfo)
                            end
                        elseif funcData.id == 11 then
                            --返回
                            local mission = MissionEventModel.GetMissionByPos(posNum)
                            -- if mission.Status == Global.MissionStatusMining then
                            --     MissionEventModel.CancelMining(mission.Uuid)
                            -- elseif mission.Status == Global.MissionStatusCamp then
                            --     MissionEventModel.CancelCamp(mission.Uuid)
                            -- end
                            Net.Missions.Cancel(mission.Uuid)
                        elseif funcData.id == 12 then
                            --特殊地形无法占领
                            if isMapTerrain then
                                if isBlackTrunk then
                                    TipUtil.TipById(50332)
                                else
                                    TipUtil.TipById(50068)
                                end
                                return
                            end

                            --占领
                            local data = {
                                openType = ExpeditionType.None,
                                posNum = posNum
                            }
                            UIMgr:Open("Expedition", data)
                        elseif funcData.id == 13 then
                            -- end
                            --迁城
                            -- local info = GD.ItemAgent.GetItemModelById(204002)
                            -- if info and info.Amount > 0 then
                            local data = {}
                            data.BuildType = WorldBuildType.MainCity
                            data.ConfId = 10
                            data.posNum = posNum
                            self:OffAnim()
                            Event.Broadcast(EventDefines.BeginBuildingMove, data)
                        elseif funcData.id == 14 then
                            -- end
                            --部队详情
                            if chunkInfo.Category == Global.MapTypeAllianceMine then
                                UIMgr:Open("UnionMineArea", chunkInfo)
                            elseif chunkInfo.Category == Global.MapTypeCamp then
                                Net.AllianceBattle.AllianceGarrisonsInfo(
                                    posNum,
                                    function(val)
                                        UIMgr:Open("ArmyDetails", val.Garrisons)
                                    end
                                )
                            elseif chunkInfo.Category == Global.MapTypeFort or chunkInfo.Category == Global.MapTypeThrone then
                                Net.AllianceBattle.AllianceGarrisonsInfo(
                                    posNum,
                                    function(val)
                                        UIMgr:Open("RoyalFortresViewDetail", val, chunkInfo)
                                    end
                                )
                            end
                        elseif funcData.id == 15 then
                            --标记
                            UIMgr:Open("UnionSignPopup", posNum)
                        elseif funcData.id == 16 then
                            --邀请入会
                            Net.Alliances.InvitePlayer(
                                chunkInfo.OwnerId,
                                function()
                                    TipUtil.TipById(50215)
                                end
                            )
                        elseif funcData.id == 17 then
                            --功能查看
                            if chunkInfo.Category == Global.MapTypeAllianceDomain then
                                UIMgr:Open("UnionFortressFunction")
                            elseif chunkInfo.Category == Global.MapTypeAllianceDefenceTower then
                                UIMgr:Open("UnionDefenseTowerFunction", chunkInfo)
                            elseif chunkInfo.Category == Global.MapTypeAllianceHospital then
                                UIMgr:Open("UnionHospital/UnionHospitalFunction")
                            elseif chunkInfo.Category == Global.MapTypeAllianceStore then
                                local data = {
                                    textTitle = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouse"),
                                    textContent = StringUtil.GetI18n(I18nType.Commmon, "UI_AillanceWarehouse_Tips_Text"),
                                    textBtnLeft = StringUtil.GetI18n(I18nType.Commmon, "Button_View"),
                                    controlType = "single",
                                    cbBtnLeft = function()
                                        UIMgr:Open("UnionViewData", chunkInfo.AllianceId)
                                    end
                                }
                                UIMgr:Open("ConfirmPopupDouble", data)
                            end
                        elseif funcData.id == 18 then
                            --查看详情
                            if chunkInfo.Category == Global.MapTypeAllianceDomain or chunkInfo.Category == Global.MapTypeAllianceStore then
                                UIMgr:Open("UnionFortressViewDetail", chunkInfo)
                            elseif chunkInfo.Category == Global.MapTypeAllianceMine then
                                UIMgr:Open("UnionMineArea", chunkInfo)
                            elseif chunkInfo.Category == Global.MapTypeAllianceDefenceTower then
                                UIMgr:Open("UnionDefenseTowerDetail", chunkInfo)
                            elseif chunkInfo.Category == Global.MapTypeAllianceHospital then
                                UIMgr:Open("UnionHospital/UnionHospital")
                            end
                        elseif funcData.id == 19 then
                            --贡献资源
                        elseif funcData.id == 20 then
                            --储存资源
                            local config = ConfigMgr.GetListBySearchKeyValue("configAllianceFortresss", "building_type", Global.AllianceStore)[1]
                            Net.AllianceStorehouse.StoreInfo(
                                config.id,
                                function(rsp)
                                    UIMgr:Open("UnionWarehouseAccessResources", 2, rsp,posNum)
                                end
                            )
                        elseif funcData.id == 21 then
                            -- 取出资源
                            local config = ConfigMgr.GetListBySearchKeyValue("configAllianceFortresss", "building_type", Global.AllianceStore)[1]
                            Net.AllianceStorehouse.StoreInfo(
                                config.id,
                                function(rsp)
                                    UIMgr:Open("UnionWarehouseAccessResources", 3, rsp,posNum)
                                end
                            )
                        elseif funcData.id == 22 then
                            -- （防御塔）升级
                        elseif funcData.id == 23 then
                            -- 伤员治疗
                            UIMgr:Open("CureRelated/CureArmy", BuildType.CUREARMY.Union)
                        elseif funcData.id == 24 then
                            -- 医院详情
                            UIMgr:Open("UnionHospital/UnionHospitalDetail")
                        elseif funcData.id == 25 then
                            -- 申请入会
                            self:OnUnionApply(chunkInfo)
                        elseif funcData.id == 26 then
                            -- 驻防
                            if chunkInfo.OwnerId ~= "" then
                                local pX, pY = MathUtil.GetCoordinate(posNum)
                                local confId = Global.BuildingUnionBuilding -- 联盟大厦
                                if BuildModel.CheckExist(confId) then
                                    Net.AllianceBattle.AssistLimit(
                                        chunkInfo.OwnerId,
                                        pX,
                                        pY,
                                        function(rsp)
                                            if rsp.Fail then
                                                return
                                            end

                                            if rsp.Max > 0 then
                                                UIMgr:Open("UnionSoldierAssistancePopup", posNum, rsp.Max, rsp.Used, ExpeditionType.UnionBuildingStation, chunkInfo.OwnerId)
                                            else
                                                TipUtil.TipById(50070)
                                            end
                                        end
                                    )
                                else
                                    TipUtil.TipById(50071)
                                end
                            else
                                local data = {
                                    openType = ExpeditionType.UnionBuildingStation,
                                    posNum = posNum
                                }
                                UIMgr:Open("Expedition", data)
                            end
                        elseif funcData.id == 27 then
                            -- 采集
                            local data = {
                                openType = ExpeditionType.Mining,
                                posNum = posNum,
                                assistLimit = 100000
                            }
                            UIMgr:Open("Expedition", data)
                        elseif funcData.id == 28 then
                            -- 状态
                            UIMgr:Open("UIRoyalCityStatus")
                        elseif funcData.id == 29 then
                            -- 公告板
                        elseif funcData.id == 30 then
                            -- 城市快报
                        elseif funcData.id == 31 then
                            -- 官职
                            print("打开官职界面")
                            UIMgr:Open("UIRoyalTownHall")
                        elseif funcData.id == 32 then
                            -- 城市大厅
                            UIMgr:Open("UIRoyalMain")
                        elseif funcData.id == 33 then
                            -- 搜索
                            UIMgr:Open("PrisonExplorationPopup", chunkInfo)
                        elseif funcData.id == 34 then
                            --     end
                            -- )
                            -- 警察来袭
                            Net.Activity.GetSysActivitiyInfo(
                                1000200,
                                function(data)
                                    UIMgr:Open("BlackKnight", data.Info)
                                end
                            )
                        elseif funcData.id == 35 then
                            -- 放置建筑
                            UnionTrritoryModel.SetPointPos(self.posNum)
                            UIMgr:Open("UnionTerritorialManagement")--("UnionTerritorialManagementSingle")
                        elseif funcData.id == 36 then
                            -- 修建
                            if chunkInfo.OwnerId ~= "" then
                                local pX, pY = MathUtil.GetCoordinate(posNum)
                                local confId = Global.BuildingUnionBuilding -- 联盟大厦
                                if BuildModel.CheckExist(confId) then
                                    Net.AllianceBattle.AssistLimit(
                                        chunkInfo.OwnerId,
                                        pX,
                                        pY,
                                        function(rsp)
                                            if rsp.Fail then
                                                return
                                            end

                                            if rsp.Max > 0 then
                                                UIMgr:Open("UnionSoldierAssistancePopup", posNum, rsp.Max, rsp.Used, ExpeditionType.UnionBuildingStation, chunkInfo.OwnerId)
                                            else
                                                TipUtil.TipById(50070)
                                            end
                                        end
                                    )
                                else
                                    TipUtil.TipById(50071)
                                end
                            else
                                local data = {
                                    openType = ExpeditionType.UnionBuildingStation,
                                    posNum = posNum
                                }
                                UIMgr:Open("Expedition", data)
                            end
                        elseif funcData.id == 37 then
                            --侦查（王座专用）
                            if ArmiesModel.CheckMissionLimit() then
                                return
                            end
                            MapModel.AttackCheck(
                                chunkInfo,
                                function()
                                    UIMgr:Open("Scout", posNum)
                                end
                            )
                        elseif funcData.id == 38 then
                            --集结进攻（王座专用）
                            local build = BuildModel.FindByConfId(Global.BuildingJointCommand)
                            if not build or build.Level <= 0 then
                                TipUtil.TipById(50291)
                                return
                            end
                            MapModel.AttackCheck(
                                chunkInfo,
                                function()
                                    UIMgr:Open("Aggregation", posNum)
                                end
                            )
                        elseif funcData.id == 39 then
                            --攻击（王座专用）
                            MapModel.AttackCheck(
                                chunkInfo,
                                function()
                                    local data = {
                                        openType = pointType,
                                        posNum = posNum,
                                        mineAttach = false
                                    }
                                    UIMgr:Open("Expedition", data)
                                end
                            )
                        elseif funcData.id == 40 then
                            --取消联盟标记
                            local signInfo = FavoriteModel.GetUnionSign(posNum)
                            if not signInfo then
                                return
                            end
                            Net.Bookmarks.DelAlliance(signInfo.Category)
                        elseif funcData.id == 43 then
                            -- 集结增援
                            local build = BuildModel.FindByConfId(Global.BuildingJointCommand)
                            if not build or build.Level <= 0 then
                                TipUtil.TipById(50291)
                                return
                            end

                            --王战集结援助判断是否上限
                            local throne = function()
                                if chunkInfo.OwnerId ~= "" then
                                    local pX, pY = MathUtil.GetCoordinate(posNum)
                                    local confId = Global.BuildingUnionBuilding -- 联盟大厦
                                    if BuildModel.CheckExist(confId) then
                                        Net.AllianceBattle.AssistLimit(
                                            chunkInfo.OwnerId,
                                            pX,
                                            pY,
                                            function(rsp)
                                                if rsp.Fail then
                                                    return
                                                end
    
                                                if rsp.Max > 0 then
                                                    UIMgr:Open("UnionSoldierAssistancePopup", posNum, rsp.Max, rsp.Used, ExpeditionType.UnionBuildingStation, chunkInfo.OwnerId,true)
                                                else
                                                    TipUtil.TipById(50070)
                                                end
                                            end
                                        )
                                    else
                                        TipUtil.TipById(50071)
                                    end
                                else
                                    local data = {
                                        openType = ExpeditionType.UnionBuildingStation,
                                        posNum = posNum
                                    }
                                    UIMgr:Open("Expedition", data)
                                end
                                -- local pX, pY = MathUtil.GetCoordinate(posNum)
                                -- Net.AllianceBattle.AssistLimit(
                                --     chunkInfo.OwnerId,
                                --     pX,
                                --     pY,
                                --     function(rsp)
                                --         if rsp.Fail then
                                --             return
                                --         end

                                --         if rsp.Max > 0 then
                                --             UIMgr:Open("UnionSoldierAssistancePopup", posNum, rsp.Max, rsp.Used, ExpeditionType.UnionBuildingStation, chunkInfo.OwnerId, true)
                                --         end
                                --     end
                                -- )
                            end

                            MapModel.AttackCheck(
                                chunkInfo,
                                function()
                                    if chunkInfo.Category == Global.MapTypeFort or chunkInfo.Category == Global.MapTypeThrone or chunkInfo.Category == Global.MapTypeAllianceDomain then
                                        throne()
                                    else
                                        UIMgr:Open("Aggregation", posNum)
                                    end
                                end
                            )
                        elseif funcData.id == 44 then
                            -- 部队详情
                            local mission = MissionEventModel.GetMissionByPos(posNum)
                            if mission then
                                UIMgr:Open("ArmyDetails", mission)
                            end
                        elseif funcData.id == 45 then
                            -- 修理
                            local data = {
                                openType = ExpeditionType.UnionBuildingStation,
                                posNum = posNum
                            }
                            UIMgr:Open("Expedition", data)
                        end

                        self:OffAnim()
                    end
                )
            end
        end
    )
    self._animOut:Stop()
    -- Event.Broadcast(EventDefines.CloseGuide)
    self:OnAnim()

    if chunkInfo == nil then
        return
    end
    if (chunkInfo.Category == Global.MapTypeMine or chunkInfo.Category == Global.MapTypeSecretBase) and isGuide then
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.ItemDetailUI)
    end
end

function ItemDetail:MarchUnitInit(info)
    local marchInfo = MissionEventModel.GetEvent(info.data.Uuid)
    if not marchInfo and info.data.OwnerId == Model.Account.accountId then
        Log.Info("战斗失败无法选择行军队列")
        return
    end
    local mission
    local isMyRallingEvent
    if marchInfo then
        mission = marchInfo
    else
        mission = info.data
        isMyRallingEvent ,mission.MissionTeams ,mission.marchType,mission.isRallyMarch = MissionEventModel.IsMyRallingEvent(info.data.AllianceBattleId) --如果是自己参与集结的部队，追加部队信息
        
    end

    GameUpdate.Inst():DelFixedUpdate(self.refreshCallback)
    self:CloseSelectTip()
    self._selectTip.visible = true
    self:OffAnim()
    self:SetScale(1, 1)
    local pos = self.parent:GlobalToLocal({x = Screen.width / 2, y = Screen.height / 2})
    self.x = pos.x
    self.y = pos.y
    self.itemPosX = pos.x
    self.itemPosY = pos.y
    self.visible = true
    self._HandleGroup.visible = true

    self._titleBox:MarchUnitInit(mission)
    local statusId
    if isMyRallingEvent then --是我参与集结的部队
        statusId = 300005
    else
        statusId = (not mission.OwnerId or mission.OwnerId == UserModel.AuthParams().AccountId) and (mission.IsReturn and 300002 or 300001) or (mission.IsReturn and 300004 or 300003)
    end
    local funcIds = GameUtil.Clone(ConfigMgr.GetItem("configMapStatuss", statusId).funcs or {})
    local noArmy = {
        [Global.MissionSpy] = true,
        [Global.MissionResAssist] = true,
        [Global.MissionVisit] = true,
        [Global.MissionHunt] = true,
        [Global.MissionResStore] = true,
    }

    --特殊处理当

    for i = 1, #funcIds do
        if funcIds[i] == 14 and noArmy[mission.Category] then
            table.remove(funcIds, i)
        elseif funcIds[i] == 41 and mission.Category == Global.MissionRally then
            --参加联盟集结的部队不能召回
            table.remove(funcIds, i)
        end
    end

    self._controller.selectedPage = "Anim" .. #funcIds
    for i, v in pairs(funcIds) do
        local funcData = ConfigMgr.GetItem("configMapButtons", v)
        self["_btnFunc" .. i]:Init(
            ConfigMgr.GetI18n("configI18nCommons", funcData.text),
            funcData.img,
            function()
                if funcData.id == 14 then
                    --部队详情
                    UIMgr:Open("ArmyDetails", mission)
                elseif funcData.id == 41 then
                    --打开召回界面
                    -- RecallMissionParams
                    UIMgr:Open("MarchRecall", mission)
                elseif funcData.id == 42 then
                    --打开加速界面
                    UIMgr:Open("MarchAcceleration", mission)
                end
            end
        )
        self["_btnFunc" .. i]:SetNormal()
    end
    self._animOut:Stop()
    self:OnAnim()
end

function ItemDetail:OnUnionApply(chunkInfo)
    if Model.Player.AllianceId ~= "" then
        TipUtil.TipById(50072)
        return
    end

    --获取玩家信息
    local player_info_func = function(playerRsp)
        if playerRsp.AllianceId == "" then
            TipUtil.TipById(50073)
            return
        end
        --获取玩家联盟信息
        local union_info_func = function(allianceRsp)
            local allianceInfo = allianceRsp.Alliance
            if allianceInfo.Member == allianceInfo.MemberLimit then
                --联盟人数已满 联系会长
                local info = {
                    subject = allianceInfo.PresidentId,
                    subCategory = MAIL_SUBTYPE.subPersonalMsg,
                    Receiver = allianceInfo.President
                }
                UIMgr:Open("Mail_PersonalNews", nil, nil, nil, nil, MAIL_CHATHOME_TYPE.TempChat, info)
            else
                local condLevel = playerRsp.Level >= allianceInfo.FreeJoinLevel
                local condPower = playerRsp.Power >= allianceInfo.FreeJoinPower
                if allianceInfo.FreeJoin and condLevel and condPower then
                    -- 满足直接加入联盟的条件
                    Net.Alliances.Join(
                        allianceInfo.Uuid,
                        function(joinRsp)
                            SdkModel.TrackBreakPoint(10047) --打点
                            Model.Player.AllianceId = joinRsp.Alliance.Uuid
                            Model.Player.AllianceName = joinRsp.Alliance.ShortName
                            Model.Player.AlliancePos = Global.AlliancePosR1
                            UnionInfoModel.SetInfo(joinRsp.Alliance)
                            Event.Broadcast(EventDefines.UIAllianceJoin)
                            TurnModel.UnionView()
                        end
                    )
                else
                    if not Model.Find(ModelType.AppliedAlliance, allianceInfo.Uuid) then
                        -- 申请入盟
                        local apply_suc_func = function()
                            --申请入会成功提示
                            TipUtil.TipById(50074)
                        end
                        UIMgr:Open("UnionApplyPopup", playerRsp.AllianceId, apply_suc_func)
                    else
                        -- 取消申请入盟
                        local data = {
                            content = StringUtil.GetI18n(I18nType.Commmon, "Alliance_Add_Cancel"),
                            sureCallback = function()
                                Net.Alliances.CancelApply(
                                    allianceInfo.Uuid,
                                    function()
                                        TipUtil.TipById(50140)
                                    end
                                )
                            end
                        }
                        UIMgr:Open("ConfirmPopupText", data)
                    end
                end
            end
        end
        Net.Alliances.Info(playerRsp.AllianceId, union_info_func)
    end
    Net.UserInfo.GetUserInfo(chunkInfo.OwnerId, player_info_func)
end

function ItemDetail:GuildShow()
    local count = self.curentCount
    local btn = nil
    for i = 1, count do
        local text = self["_btnFunc" .. i]:GetText()
        if self.chunkCategory and self.chunkCategory == Global.MapTypeMine then
            if text == StringUtil.GetI18n(I18nType.Commmon, "MAP_COLLECT_BUTTON") then
                btn = self["_btnFunc" .. i]
                break
            end
        elseif self.chunkCategory and self.chunkCategory == Global.MapTypeSecretBase then
            if text == StringUtil.GetI18n(I18nType.Commmon, "MAP_SEARCH_BUTTON") then
                btn = self["_btnFunc" .. i]
                break
            end
        end
    end
    return btn
end

function ItemDetail:ShowSelectTip()
    --点击闪烁
    -- if not self.clickShakeItem and not self.isLoading then
    --     --    local  ResMgr.Instance:LoadBundleSync()
    -- else
    if not self.isLoading then
        local url = "prefab_effect_worldmap/selectchunk"
        self.isLoading = true
        local obj = GameObject.Instantiate(ResMgr.Instance:LoadPrefabSync(url))
        self.clickShakeItem = obj:GetComponent("SpriteRenderer")
        self.clickShakeItem.enabled = false
        self.clickShakeItem.transform.parent = WorldMap.Instance().RouteLayer.transform
    end

    if self.clickTween then
        self.clickTween:Kill()
    end
    self.clickShakeItem.enabled = true
    self.clickShakeItem.color = CS.UnityEngine.Color(1, 1, 1, 1)
    self.clickShakeItem.transform.localScale = CVector3.one * self.ClickSize
    self.clickShakeItem.transform.localPosition = CVector3(self.itemPosX, 0, self.itemPosY)
    self.clickTween = self.clickShakeItem:DOFade(0.2, 0.5):SetLoops(-1, CS.DG.Tweening.LoopType.Yoyo)
    -- end
end
--关闭闪烁区域
function ItemDetail:CloseSelectTip()
    if not self.clickShakeItem then
        return
    end
    self.clickShakeItem.enabled = false
    if self.clickTween then
        self.clickTween:Kill()
    end
end

function ItemDetail:InitSelectTip()
    local url = "prefab_effect_worldmap/selectchunk"
    self.isLoading = false
    CSCoroutine.Start(
        function()
            self.isLoading = true
            coroutine.yield(ResMgr.Instance:LoadPrefab(url))
            local obj = GameObject.Instantiate(ResMgr.Instance:GetPrefab(url))
            self.clickShakeItem = obj:GetComponent("SpriteRenderer")

            -- self.clickShakeItem.transform.localScale = CVector3.one * self.ClickSize
            self.clickShakeItem.enabled = false
        end
    )
end
--检测猎鹰活动怪
-- function ItemDetail:CheckFalConActivity()
--     if self.chunkInfo.Category ~= Global.MapTypeBlank then
--         return
--     end

--     if not Model.MonsterVisitInfo or not Model.MonsterVisitInfo[1] then
--         return
--     end
--     local posX, posY = MathUtil.GetCoordinate(self.posNum)
--     for _, v in pairs(Model.MonsterVisitInfo[1].Avaliable or {}) do
--         if not v.Banned and v.X == posX and v.Y == posY then
--             self.chunkInfo = {
--                 AllianceId = "",
--                 Category = Global.MapTypeMonster,
--                 ConfId = v.ConfId,
--                 DeadTime = 0,
--                 FortressId = 0,
--                 FortressIdList = "",
--                 Id = v.Id,
--                 Occupied = 0,
--                 ServerId = Model.Player.Server
--             }
--         end
--     end
-- end

return ItemDetail
