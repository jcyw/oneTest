local GD = _G.GD
local GuidePanelModel = import("Model/GuideControllerModel")
local UIType = _G.GD.GameEnum.UIType
local WorldCityModel = import("Model/WorldCityModel")
local MissionEventModel = import("Model/MissionEventModel")
local MarchLineModel = import("Model/MarchLineModel")
local MarchAnimModel = import("Model/MarchAnimModel")
local MapModel = import("Model/MapModel")
local WorldMap = import("UI/WorldMap/WorldMap")
local FavoriteModel = import("Model/FavoriteModel")
local WorldBuildType = import("Enum/WorldBuildType")
local NoviceModel = import("Model/NoviceModel")
local WorldCity = UIMgr:NewUI("WorldCity")
local view
local showMaxCount = 5
local nowPos = 0
local CVector3 = CS.UnityEngine.Vector3
local CVector4 = CS.UnityEngine.Vector4
local GlobalVars = GlobalVars
local MarchReturnList = {}
local TriggerIsStart = false --浮标引导是否开始

function WorldCity:OnInit()
    view = self.Controller.contentPane
    self.showPos = {
        x = Model.GetPlayer().X,
        y = Model.GetPlayer().Y
    }
    WorldMap.InitMap(self.showPos, view:GetChild("transparentMask"))

    self._btnContent = view:GetChild("icon_quan")
    self._myTownTip = view:GetChild("MyTownTip")
    self._myTownTip.visible = true
    self._distanceText = self._myTownTip:GetChild("titel")
    self._arrowTip = self._myTownTip:GetChild("bg")
    
    --self._arrowTip = self._myTownTip:GetChild("bg")
    self.chunkInfo = nil
    GuidePanelModel:SetParentUI(view, UIType.WorldMapPoint)
    self:OnRegister()
    -- self:AddEvent(
    --     EventDefines.BuildingMoveing,
    --     function(touchX, touchY)
    --         if Stage.inst.touchCount == 2 then
    --             Log.Info("双指操作暂时屏蔽")
    --             return
    --         end
    --         -- self:DragMove(touchX, touchY)
    --     end
    -- )
    --关闭地图详情通知
    self:AddEvent(
        EventDefines.UICloseMapDetail,
        function()
            self.isShowBtn = false
        end
    )
    self:AddEvent(
        EventDefines.BeginBuildingMove,
        function(data)
            self.BuildType = data.BuildType
            if self.BuildType == WorldBuildType.MainCity then
                --迁移主城

                local item = GD.ItemAgent.GetItemModelById(Global.FlyCityItemID)
                local config = ConfigMgr.GetItem("configItems", Global.FlyCityItemID)
            elseif self.BuildType == WorldBuildType.UnionFortress then
                -- self._plot.icon = UIPackage.GetItemURL(unionBuild.build_image[1], unionBuild.build_image[2])
                --修建联盟堡垒
                self.ConfId = data.ConfId
                local unionBuild = ConfigMgr.GetItem("configAllianceFortresss", data.ConfId)
            elseif self.BuildType == WorldBuildType.UnionGoLeader then
                local item = GD.ItemAgent.GetItemModelById(Global.AllianceFlyCityItemID)
                local config = ConfigMgr.GetItem("configItems", Global.AllianceFlyCityItemID)
            end
            -- self._plotTypeController.selectedIndex = 1
            local screenPosX, screenPosY
            if data.posNum then
                self.posX, self.posY = MathUtil.GetCoordinate(data.posNum)
                screenPosX, screenPosY = MathUtil.ScreenRatio(WorldMap.Instance():LogicToScreenPos(self.posX, self.posY))
            else
                screenPosX, screenPosY = 375, 667
                local posX, posY = WorldMap.Instance():ScreenToLogicPos(screenPosY, screenPosY)
                self.posX = math.floor(posX)
                self.posY = math.floor(posY)
            end

            Event.Broadcast(EventDefines.RefreshBuildBtnInfo, data)
        end
    )

    self:AddEvent(
        EventDefines.TriggerGuideJudge,
        function(type, para1, para2)
            if not GlobalVars.IsOpenTriggerGuide then
                return
            end
            local triggerId = GD.TriggerGuideAgent.GetTriggerId(type, para1, para2)
            if #triggerId ~= 0 then
                for i = #triggerId, 1, -1 do
                    --判断是否已经触发过了，如果已经出发了就不再出发
                    local bActive = function()
                        for j = 1, #Model.Player.TriggerGuides do
                            if triggerId[i].Id == Model.Player.TriggerGuides[j].Id then
                                table.remove(triggerId, i)
                                return true
                            end
                        end
                        return false
                    end
                    if bActive() == false then
                        Net.Logins.SetTriggerGuideStep({Step = triggerId[i].Step, Id = triggerId[i].Id, Finish = false})
                        table.insert(Model.Player.TriggerGuides, {Step = triggerId[i].Step, Id = triggerId[i].Id, Finish = false})
                    end
                end
                for i = #Model.Player.TriggerGuides, 1, -1 do
                    local triggerInfo = GD.TriggerGuideAgent.GetTriggerGuideByConfId(Model.Player.TriggerGuides[i].Id)
                    if not triggerInfo then
                        table.remove(Model.Player.TriggerGuides, i)
                    end
                end
                table.sort(
                    Model.Player.TriggerGuides,
                    function(a, b)
                        local triggerInfoa = GD.TriggerGuideAgent.GetTriggerGuideByConfId(a.Id)
                        local triggerInfob = GD.TriggerGuideAgent.GetTriggerGuideByConfId(b.Id)
                        return triggerInfoa.isCloseWindow < triggerInfob.isCloseWindow
                    end
                )
                if GlobalVars.IsInCityTrigger == false and GlobalVars.IsTriggerStatus == false and #triggerId ~= 0 then
                    Event.Broadcast(EventDefines.TriggerAllPanelClose)
                end
            end
        end
    )

    self:AddEvent(
        EventDefines.TriggerGuideDo,
        function(id, step)
            if GlobalVars.IsInCityTrigger == false then
                self:DoTriggerGuide(id, step)
            end
        end
    )
    self:AddEvent(
        EventDefines.TriggerGuideNextStep,
        function(id, step)
            if GlobalVars.IsInCityTrigger == false then
                local net_func = function()
                    Event.Broadcast(EventDefines.TriggerGuideDo, id, step)
                end
                step = step + 1
                local isKey = NoviceModel.GetNoviceGuideByConfId(id + step).isKey
                if isKey == 1 then
                    Net.Logins.SetTriggerGuideStep({Step = step, Id = id, Finish = false}, net_func)
                elseif isKey == 2 then
                    Net.Logins.SetTriggerGuideStep({Step = step, Id = id, Finish = true}, net_func)
                else
                    Event.Broadcast(EventDefines.TriggerGuideDo, id, step)
                end
            end
        end
    )

    self:AddEvent(
        EventDefines.TriggerAllPanelClose,
        function()
            if GlobalVars.IsInCityTrigger == false and not GlobalVars.IsSidebarOpen then
                Event.Broadcast(EventDefines.GuideMask, true)
                self:RemainTriggerGuideJudge()
            end
        end
    )
end
--直接打开
function WorldCity:OnOpen(posX, posY)
    if WorldMap.mapObj then
        ObjectUtil.SetActive(WorldMap.mapObj, true)
    end
    if posX and posY then
        self.showPos = {
            x = posX,
            y = posY
        }
    else
        self.showPos = {
            x = Model.GetPlayer().X,
            y = Model.GetPlayer().Y
        }
    end
    -- Event.Broadcast(EventDefines.UIMapLoadingFinish)
    WorldMap.AddEventBeforeMap(
        function()
            WorldMap.Instance():GotoPoint(self.showPos.x, self.showPos.y)
        end
    )

    Event.Broadcast(EventDefines.WorldMapCameraPosReturn)
end

function WorldCity:MoveTo(posX, posY, isFromCity)
    if WorldMap.mapObj then
        ObjectUtil.SetActive(WorldMap.mapObj, true)
    end
    WorldMap.AddEventBeforeMap(
        function()
            WorldMap.Instance():MoveToPoint(posX, posY, isFromCity)
        end
    )
end

function WorldCity:OnClose()
    -- WorldMap.Instance():GotoPoint(MapModel.GetMyTownPos())
    Net.MapInfos.LeaveMap(
        function()
            -- 回程时，地块中心返回为玩家主基地所在位置
            WorldMap.Instance():ReturnToMyBase()
        end
    )
    ObjectUtil.SetActive(WorldMap.mapObj, false)
    UIMgr:Close("WorldCity")
end

--判断有没有没有完成的触发式引导
function WorldCity:RemainTriggerGuideJudge()
    -- triggerGuide
    if #Model.Player.TriggerGuides == 0 or GlobalVars.NowTriggerId ~= 0 or GD.TriggerGuideAgent.WorldHaveStashTriggerJudge() == false then
        Event.Broadcast(EventDefines.GuideMask, false)
        return
    end
    for k, v in pairs(Model.Player.TriggerGuides) do
        local triggerInfo = GD.TriggerGuideAgent.GetTriggerGuideByConfId(v.Id)
        -- print("triggerInfo--------------------", table.inspect(triggerInfo))
        if triggerInfo and v.Finish == false and v.Id ~= GlobalVars.NowTriggerId and (triggerInfo.inCity == 0 or triggerInfo.inCity == 2) and GlobalVars.IsInCityTrigger == false then
            if triggerInfo.isCloseWindow == 1 then
                -- end
                -- 如果没有其他弹出窗口
                -- if UIMgr:GetWindowCount() == 0 and UIMgr:GetShowPopPanelCount() == 0 then
                GlobalVars.NowTriggerId = v.Id
                UIMgr:ClosePopAndTopPanel()
                Event.Broadcast(EventDefines.TriggerGuideDo, v.Id, v.Step)
                break
            else
                GlobalVars.NowTriggerId = v.Id
                Event.Broadcast(EventDefines.TriggerGuideDo, v.Id, v.Step)
                break
            end
        end
    end
end

function WorldCity.errorDealTriggerFunc()
    Event.Broadcast(EventDefines.ClearTrigger)
end

function WorldCity:DoTriggerGuide(id, step)
    local noviceInfo = NoviceModel.GetNoviceGuideByConfId(id + step)
    local triggerInfo = GD.TriggerGuideAgent.GetTriggerGuideByConfId(id)
    if not noviceInfo or not triggerInfo then
        return
    end
    if ABTest.GuideSkipAB_Logic() == 5002 then
        if WorldCity.errorDealTriggerFunc then
            -- Log.Error("---------------------------------")
            self:UnScheduleFast(WorldCity.errorDealTriggerFunc)
            self:ScheduleOnceFast(WorldCity.errorDealTriggerFunc, 10)
        else
            self:ScheduleOnceFast(WorldCity.errorDealTriggerFunc, 10)
        end
    end
    if noviceInfo.type ~= _G.GD.GameEnum.NoviceType.TriggerEnd then
        local noviceVisible = UIMgr:GetUIOpen("Novice")
        local uiNovice = UIMgr:GetUI("Novice")
        if GlobalVars.NowTriggerId == 14200 then
            if noviceVisible == true then
                uiNovice:TriggerGuideShowMessage(id, step, self.chunkInfo)
            else
                UIMgr:Open("Novice", id, step, self.chunkInfo)
            end
        else
            if triggerInfo.inCity == 0 or triggerInfo.inCity == 2 and GlobalVars.IsInCityTrigger == false then
                GlobalVars.IsTriggerStatus = true
                GlobalVars.IsAllowPopWindow = false
                if noviceInfo.type == _G.GD.GameEnum.NoviceType.TriggerStart then
                    Event.Broadcast(EventDefines.TriggerGuideNextStep, id, step)
                else
                    if noviceInfo.turnId ~= nil and noviceInfo.type == _G.GD.GameEnum.NoviceType.TriggerDialog and noviceInfo.turnId.type == 2 then
                        TriggerGuide:TriggerGuideStart(id + step)
                    end
                    if noviceVisible == true then
                        uiNovice:TriggerGuideShowMessage(id, step, self.chunkInfo)
                    else
                        UIMgr:Open("Novice", id, step, self.chunkInfo)
                    end
                end
            end
        end
    else
        --如果是送兵引导，结束后结束屏幕泛红
        if GlobalVars.NowTriggerId == 14200 then
        --Event.Broadcast(EventDefines.TwelveHourTrigger, false)
        end
        if WorldCity.errorDealTriggerFunc then
            self:UnScheduleFast(WorldCity.errorDealTriggerFunc)
        end
        GlobalVars.IsTriggerStatus = false
        GlobalVars.IsAllowPopWindow = true
        -- UIMgr:Close("Novice")
        NoviceModel.CloseUI()
        GlobalVars.NowTriggerId = 0
        for i = 1, #Model.Player.TriggerGuides do
            if Model.Player.TriggerGuides[i].Finish == false then
                if Model.Player.TriggerGuides[i].Id == id then
                    Model.Player.TriggerGuides[i].Finish = true
                    break
                end
            end
        end
        GD.TriggerGuideAgent.WorldHaveStashTriggerJudge()
    end
    SdkModel.ReportEvent("trigger_guide", id + step)
end

--显示点击选择
function WorldCity:OnShowBtn(posNum, screenPos, isGuide)
    if self.isShowBtn then
        self.isShowBtn = false
        self.itemDetail:OffAnim()
        return
    end

    local showXPos, showYPos = MathUtil.GetCoordinate(posNum)
    WorldCityModel.SetCurrentPos(showXPos, showYPos)
    --  self.itemDetail = WorldMap.Instance():GetItemDetail()
    self.itemDetail:WorldCityInit(posNum, screenPos, nil, isGuide)
    self.isShowBtn = true
end

--外城注册事件
function WorldCity:OnRegister()
    self.isShowAll = false
    self:AddListener(
        self._myTownTip.onClick,
        function()
            Event.Broadcast(EventDefines.UICloseMapDetail)
            WorldMap.Instance():GotoPoint(MapModel.GetMyTownPos())
        end
    )
    --监听 点击外城地图事件
    self:AddEvent(
        EventDefines.UIClickWorldMap,
        function(map, isGuide, isFromMoveToPoint)
            if GlobalVars.IsInCity then
                return
            end

            local posNum = map["posNum"]
            local screenPos = map["screenPos"]
            local chunkInfo = MapModel.GetArea(posNum) -- MapInfo[posNum]
            self.chunkInfo = chunkInfo
            nowPos = posNum
            -- if chunkInfo and (chunkInfo.Category == Global.MapTypeThrone or chunkInfo.Category == Global.MapTypeFort) then
            --     TipUtil.TipById(50301)
            --     return
            -- end

            if isGuide then
                self:OnShowBtn(posNum, screenPos, isGuide)
            else
                self:OnShowBtn(posNum, screenPos)
            end
            --特殊处理
            local isMyFalcon = MapModel.CheckIsMyFalcon(posNum)
            if isMyFalcon then
                return
            end

            if chunkInfo and not isFromMoveToPoint then
                if chunkInfo.Category == Global.MapTypeTown then
                    local status = MapModel.CheckOwnerType(chunkInfo)
                    if status >= 10 then
                        status = math.floor(status / 10)
                    end
                    if status ~= 1 and status ~= 2 then
                        Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.ClickWorld, 12400, chunkInfo)
                    end
                elseif chunkInfo.Category == Global.MapTypeMine then
                    if self.itemDetail:JudgeCondition(chunkInfo.ConfId) ~= nil then
                        return
                    end
                    -- --如果在引导状态则退出
                    if ConfigMgr.GetItem("configMines", chunkInfo.ConfId).category == 1 then
                        Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.ClickWorld, 12300, chunkInfo)
                    elseif ConfigMgr.GetItem("configMines", chunkInfo.ConfId).category == 2 then
                        Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.ClickWorld, 13300, chunkInfo)
                    elseif ConfigMgr.GetItem("configMines", chunkInfo.ConfId).category == 3 then
                        Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.ClickWorld, 13400, chunkInfo)
                    elseif ConfigMgr.GetItem("configMines", chunkInfo.ConfId).category == 4 then
                        Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.ClickWorld, 13500, chunkInfo)
                    elseif ConfigMgr.GetItem("configMines", chunkInfo.ConfId).category == 5 then
                        Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.ClickWorld, 13600, chunkInfo)
                    end
                elseif chunkInfo.Category == Global.MapTypeMonster then
                    local monster = ConfigMgr.GetItem("configMonsters", chunkInfo.ConfId)
                    --dump(chunkInfo)
                    --if monster.level % 10 == 0 then
                    --    AudioModel.PlaySpeech(string.lower("t10enemy"))
                    --else
                    --    AudioModel.PlaySpeech(string.lower("t"..(monster.level%10).."enemy")) 
                    --end
                    --如果野怪为活动野怪，不弹出提示提示引导
                    if monster.type > 10 then
                        return
                    end
                    Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.ClickWorld, 12200, chunkInfo)
                end
            end
        end
    )
    --获取当前屏幕中心的地块坐标
    self:AddEvent(
        EventDefines.UIOnWorldMapChange,
        function(posX, posY)
            self.nowPosX = posX
            self.nowPosY = posY
 
            local isShow, angle = MapModel.GetTownTipPos()
            self._myTownTip.visible = isShow
            if self._myTownTip.visible and not TriggerIsStart then
                TriggerIsStart = true
                --指引回城浮标
                --Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.OtherType, 16000, 1)
            end
            if isShow then
                self._arrowTip.rotation = 135 - angle
                self._distanceText.text = MapModel.GetTownDistance(posX, posY) .. "km"
            end
        end
    )
    --监听 点击行军特效
    self:AddEvent(
        EventDefines.UIClickMarchUnit,
        function(params)
            self.isShowBtn = true
            self.itemDetail:MarchUnitInit(params)
        end
    )

    self:AddEvent(
        EventDefines.UIOnWorldMapMove,
        function()
            if (self.isShowBtn) then
                self.isShowBtn = false
                self.itemDetail:OffAnim()
            end
        end
    )
    self:AddEvent(
        EventDefines.UIOffAnim,
        function()
            if (self.isShowBtn) then
                self.isShowBtn = false
                self.itemDetail:OffAnim()
            end
        end
    )
    --地图初始化
    self:AddEvent(
        EventDefines.UIWorldMapInitFinish,
        function()
            MissionEventModel.Init()
        end
    )

    self.itemDetail = UIMgr:CreateObject("WorldCity", "BuildComplete")
    self.Controller.contentPane:AddChild(self.itemDetail)
end

--刷新地图UI按钮组
function WorldCity:OnRefreshBtns(funcs, posNum)
    local count = #funcs
    local index = 1
    for i = 1, 6 do
        if (self:CalBtnShowStaus(count, i)) then
            self._worldBtnList[i].visible = true
            self._worldBtnList[i]:init(funcs[index], posNum)
            index = index + 1
        else
            self._worldBtnList[i].visible = false
        end
    end
end

function WorldCity:CalBtnShowStaus(count, index)
    -- local isShow = false
    if (count == 1) then
        return (index == 3)
    elseif (count == 2) then
        return ((index == 1) or (index == 5))
    elseif (count == 3) then
        return index % 2 > 0
    elseif (count == 4) then
        return not (index == 3)
    else
        return true
    end
    -- return false
end

----------------------------迁城相关-------------------------
local delayTime = 0
function WorldCity:DragMove(touchX, touchY)
    local posX, posY = WorldMap.Instance():ScreenToLogicPos(MathUtil.FairyToScreeen(touchX, touchY))
    if posX < 1 or posY < 1 or posX > 1200 or posY > 1200 then
        -- posX = 1
        return
    end
    delayTime = 0

    -- if posY < 0 then
    --     posY = 0
    -- end
    ----只移动一块地的情况
    local delayX = 0
    local delayY = 0
    local param = 0.1

    local top = Screen.height * 0.3
    local bottom = Screen.height * 0.8
    local left = Screen.width * 0.2
    local right = Screen.width * 0.8

    if (touchX < left) then
        delayX = delayX + param
        delayY = delayY - param
    elseif touchX > right then
        delayX = delayX - param
        delayY = delayY + param
    end

    if touchY < top then
        delayX = delayX - param
        delayY = delayY - param
    elseif touchY > bottom then
        delayY = delayY + param
        delayX = delayX + param
    end
    if delayX ~= 0 or delayY ~= 0 then
    end

    if posX ~= self.posX or posY ~= self.posY then
    end
end

return WorldCity
