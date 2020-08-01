--[[
    联盟建筑查看详情
    author:{Temmie}
    time:2019-07-30
]]
local UnionFortressViewDetail = UIMgr:NewUI("UnionFortressViewDetail")

local UnionModel = import("Model/UnionModel")
local UnionInfoModel = import("Model/Union/UnionInfoModel")
local MonsterModel = import("Model/MonsterModel")
local ItemUnionAggregation = import("UI/Union/ItemUnionAggregation")
function UnionFortressViewDetail:OnInit()
    local view = self.Controller.contentPane
    self._control = view:GetController("showControl")
    self.c1 = view:GetController("c1")
    self.c2 = view:GetController("c2")
    self.c3 = view:GetController("c3")
    self._btnHelp = view:GetChild("btnHelp")
    self._titleText = view:GetChild("textName")
    self._list.itemRenderer = function(index, item)
        if index < #self.datas then
            local data = self.datas[index + 1]
            local itemClickFunc = function()
                if item:GetSelected() then
                    for k,v in pairs(self.curSelectedList) do
                        if v == data.UserId then
                            table.remove(self.curSelectedList, k)
                            break
                        end
                    end
                else
                    table.insert(self.curSelectedList, data.UserId)
                end
                self._list:RefreshVirtualList()
            end

            item:Init(ItemUnionAggregation.TypeEnum.Common, itemClickFunc)

            --选中项展开士兵列表
            for _,v in pairs(self.curSelectedList) do
                if v == data.UserId then
                    if (self.chunkInfo.OwnerId == Model.Account.accountId or self.unionInfo.PresidentId == Model.Account.accountId) and v ~= Model.Account.accountId then
                        item:OpenList(data.Armies, data.Beasts, function()
                            local x, y = MathUtil.GetCoordinate(self.chunkInfo.Id)
                            Net.AllianceBuildings.RemovalGarrison(x, y, data.UserId, function(rsp)
                                local id = data.UserId
                                for k,v in pairs(self.datas) do
                                    if v.UserId == id then
                                        table.remove(self.datas, k)
                                        break
                                    end
                                end
                                table.remove(self.curSelectedList, index + 1)
                                self._list.numItems = #self.datas + self.canAdd
                                
                                self.datas = {}
                                if self.config.building_type == Global.AllianceStore then
                                    self:InitStoreHouse()
                                else
                                    self:InitFortress()
                                end
                            end)
                        end)
                    else
                        item:OpenList(data.Armies, data.Beasts)
                    end
                    break
                end
            end

            local total = 0
            local power = 0
            for _,v in pairs(data.Armies) do
                total = total + v.Amount
                power = power + math.floor(ConfigMgr.GetItem("configArmys", v.ConfId).power * v.Amount)
            end
            for _,v in pairs(data.Beasts) do
                power = power + MonsterModel.GetMonsterRealPower(v.Id, v.Level, v.Health, v.MaxHealth)
            end
            item:SetContent(StringUtil.GetI18n(I18nType.Commmon, "Ui_Power"), Tool.FormatNumberThousands(math.floor(power)))
            item:SetSubContent(StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_ASsistance_Num"), total)
            item:SetPlayerInfo(data, data.Name, data.UserId)

            if self.info.State == 2 then
                item:SetStatusContent(StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Building"))
            elseif self.info.State == 4 then
                item:SetStatusContent(StringUtil.GetI18n(I18nType.Commmon, "QUEUE_IN_DESTROY"))
            else
                item:SetStatusContent(StringUtil.GetI18n(I18nType.Commmon, "QUEUE_IN_GARRISON"))
            end
        else
            -- 显示加入按钮
            item:Init(ItemUnionAggregation.TypeEnum.Add, function()
                local data = {
                    openType = ExpeditionType.UnionBuildingStation,
                    posNum = self.info.Pos
                }
                UIMgr:Open("Expedition", data)
            end)

            if self.info.State == 2 then
                if self.config.building_type == Global.AllianceStore then
                    item:SetAddBtnContent(StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouseBuliding_tips"))
                else
                    item:SetAddBtnContent(StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceBaseBuilding_Tips"))
                end
            else
                item:SetAddBtnContent(StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceBase_Tipsb"))
            end
        end
    end
    self._list:SetVirtual()

    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("UnionFortressViewDetail")
        end
    )

    self:AddListener(self._btnRecovery.onClick,    
        function()
            local recover_func = function()
                if self.config.building_type == Global.AllianceStore then
                    Net.AllianceBuildings.Destroy(
                        self.config.id,
                        function(rsp)
                            if rsp.Fail then
                                return
                            end

                            UIMgr:Close("UnionFortressViewDetail")
                        end
                    )
                    return
                end
                Net.AllianceBuildings.Recover(
                    self.config.id,
                    function(rsp)
                        if rsp.Fail then
                            return
                        end

                        UIMgr:Close("UnionFortressViewDetail")
                    end
                )
            end

            local comfirm_func = function()
                local data = {
                    content = self.config.id == 610006 and StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouseRecovery_Tips2")
                        or StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceBuildRecovery_Tips2", {build_name = self.name}),
                    buttonType = "double",
                    sureCallback = function()
                        recover_func()
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
            end
            
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceBuildRecovery_Tips1", {build_name = self.name}),
                buttonType = "double",
                sureCallback = function()
                    comfirm_func()
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    )

    self.timer_func = function()
        if self.buildAt > 0 then
            if self.info.State == 4 then
                self.curBuildValue = self.curBuildValue - self.info.OperationSpeedPerSec
            else
                self.curBuildValue = self.curBuildValue + self.info.OperationSpeedPerSec
            end
            self.buildAt = self.buildAt - 1
            self._txtTime.text = TimeUtil.SecondToDHMS(math.floor(self.buildAt))
            self._txtHp.text = math.floor(self.curBuildValue).."/"..self.config.build_hp
        else
            self:UnSchedule(self.timer_func)
        end
    end

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.UnionGift)
end

function UnionFortressViewDetail:OnOpen(chunkInfo)
    self.config = ConfigMgr.GetItem("configAllianceFortresss", chunkInfo.ConfId)
    self.chunkInfo = chunkInfo
    self.curSelectedList = {}
    self.datas = {}
    self._txtHp.text = ""
    --self._txtTime.text = ""
    self._txtMember.text = ""
    self.unionInfo = UnionInfoModel.GetInfo()
    if Model.Player.AllianceId ~= "" 
        and Model.Player.AllianceId == chunkInfo.AllianceId 
        and Model.Player.AlliancePos > 3 
        and (self.config.building_type == Global.AllianceDomain or self.config.building_type == Global.AllianceStore) then
        self._control.selectedPage = "show"
    else
        self._control.selectedPage = "hide"
    end
    if self.config.building_type == Global.AllianceStore then
        self:InitStoreHouse()
    else
        self:InitFortress()
    end
    if Model.Player.AllianceId ~= self.chunkInfo.AllianceId then
        self._list.visible = false
        self._list2.visible = false
    end
end

function UnionFortressViewDetail:InitStoreHouse()
    self._titleText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouse")
    local posX, posY = MathUtil.GetCoordinate(self.chunkInfo.Id)
    Net.AllianceStorehouse.StoreHouseInfo(
        self.chunkInfo.ConfId,
        posX,
        posY,
        function(rsp)
            -- rsp 结构为 AllianceBuilding
            if rsp.Fail then
                return
            end

            self:InitUI(rsp,posX,posY)
        end
    )
    self:SetListener(self._btnHelp.onClick,
        function()
            local data = {
                textTitle = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouse"),
                textContent = StringUtil.GetI18n(I18nType.Commmon, "UI_AllianceWarehourseStorage_Help_Text"),
                textBtnLeft = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES"),
                controlType = "single",
            }
            UIMgr:Open("ConfirmPopupDouble", data)
        end
    )
end

function UnionFortressViewDetail:InitFortress()
    self._titleText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceFortress")
    local func = function()
        local posX, posY = MathUtil.GetCoordinate(self.chunkInfo.Id)
        Net.AllianceBuildings.FortressInfo(
            posX,
            posY,
            function(rsp)
                -- rsp 结构为 AllianceBuilding
                if rsp.Fail then
                    return
                end
                self:InitUI(rsp,posX,posY)
            end
        )
    end
    if next(self.unionInfo) then
        func()
    elseif Model.Player.AllianceId ~= "" and Model.Player.AllianceId ~= self.chunkInfo.AllianceId then
        UnionModel.RequestUnionInfo(function()
            self.unionInfo = UnionInfoModel.GetInfo()
            func()
        end)
    else
        UnionModel.GetUnionInfo(function(rsp)
            self.unionInfo = rsp
            func()
        end,self.chunkInfo.AllianceId)
    end
    self:SetListener(self._btnHelp.onClick,
        function()
            Sdk.AiHelpShowFAQSection("29887")
        end
    )
end

function UnionFortressViewDetail:OnClose()
    self:UnSchedule(self.timer_func)
end

--[[ state:
	LOCKED    = 0 // 未解锁
	BUILDABLE = 1 // 可建造
	BUILDING  = 2 // 建造中
	COMPLETE  = 3 // 建造完成
	ATTACKED  = 4 // 被破坏
]]
function UnionFortressViewDetail:InitUI(rsp,posX,posY)
    self._posX.text = "X:"..posX
    self._posY.text = "Y:"..posY
    local info = rsp.Building
    local fortressConfig = ConfigMgr.GetItem("configAllianceFortresss", info.ConfId)
    self.name = info.Name == fortressConfig.building_name and StringUtil.GetI18n(I18nType.Commmon, fortressConfig.building_name) or info.Name
    self._txtName.text = "(" .. info.AllianceName .. ")" .. self.name
    self._icon.url = UITool.GetIcon(fortressConfig.build_image)--UnionModel.GetUnionBadgeIcon(info.AllianceAvatar)
    self.area = MapModel.GetArea(info.Pos)
    self.info = info
    self.c3.selectedIndex = 1
    if self.config.building_type == Global.AllianceStore and info.State == 3 then
        self.c2.selectedIndex = 0
        self:InitStoreList(rsp)
    else
        self.c2.selectedIndex = 1
        self:InitDefaultList(rsp)
    end
    self._txtTip.align = AlignType.Left
    if info.State == 2 then
        -- 建造时的面板显示
        self._txtHpTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Build_Hp")
        self.c1.selectedIndex = 0
        self._txtTimeTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceBuilding_Speed")
        self._txtTip.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceBase_Tipsc")
        self:BuildingValueTimer()
    elseif info.State == 4 then
        -- 破坏时的面板显示
        self._txtHpTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Build_Hp")
        self.c1.selectedIndex = 0
        self._txtTimeTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceDestroy_Time")
        self._txtTip.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceBase_Tips")
        self:BuildingValueTimer()
    elseif info.BuildFinish and info.ArchiValue < self.config.build_hp and info.OperationSpeedPerSec > 0 then
        -- 修复时的面板显示
        self._txtHpTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Build_Hp")
        self.c1.selectedIndex = 0
        self._txtTimeTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_FixSpeed")
        self._txtTip.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceBase_Tips")
        self:BuildingValueTimer()
    else
        self.c1.selectedIndex = 1
        if info.ConfId == 610006 then
            self.c3.selectedIndex = 0
            self._txtTip.align = AlignType.Center
            self._txtTip.text = ConfigMgr.GetI18n("configI18nBuildings", "610006_DESC")
        else
            self._txtTip.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceBase_Tips")
        end
    end
    local statusStr = MapModel.GetAllianceDomainStatus(MapModel.GetArea(self.info.Pos))
    if statusStr ~= "" then
        statusStr =  ConfigMgr.GetI18n(I18nType.Commmon, statusStr)
    end
    self._txtIconName.text = statusStr
    --联盟仓库自己储存中
    if self._list2.visible and self._selfStoring then
        self._txtIconName.text = ConfigMgr.GetI18n(I18nType.Commmon, "UI_ALLIANCE_SAVE")
    end
end

-- 联盟堡垒初始化
function UnionFortressViewDetail:InitDefaultList(rsp)
    self._txtHpTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Build_Hp")
    self._txtHp.text = rsp.Building.ArchiValue .. "/" .. self.config.build_hp
    self.canAdd = 0
    self._list2.visible = false
    self._list.visible = true
    -- 非本联盟人员只能看到据点名称、耐久值、自己部队和友方部队
    if Model.Player.AllianceId ~= self.chunkInfo.AllianceId then
        self._groupMyUnionInfo.visible = false

        local owner = MapModel.GetMapOwner(self.area.OwnerId)
        if self.area.OwnerId == Model.Player or (owner and owner.AllianceId == Model.Player.AllianceId) then
            self.datas = rsp.Building.Garrison
        end

        self._list.numItems = #self.datas
    else
        self._groupMyUnionInfo.visible = true
        self.datas = rsp.Building.Garrison
        local txtMemberTitle
        if self.info.State == 2 then
            txtMemberTitle = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceBunker_buildForces")
        else
            txtMemberTitle = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceBunker_DefensiveForces")
        end

        local amount = 0
        for _, v in pairs(rsp.Building.Garrison) do
            for _, v1 in pairs(v.Armies) do
                amount = amount + v1.Amount
            end
        end

        -- 我方堡垒没有被敌人占领
        local owner = MapModel.GetMapOwner(self.area.OwnerId)
        if self.area.OwnerId == "" or self.area.OwnerId == Model.Account.accountId or (owner and owner.AllianceId == Model.Player.AllianceId) then
            -- 进入出征界面
            self.canAdd = 1
        end

        self._list.numItems = #self.datas + self.canAdd
        self._txtMember.text = txtMemberTitle..amount .. "/" .. rsp.Building.GarrisonMax
    end
end

-- 联盟仓库初始化
function UnionFortressViewDetail:InitStoreList(rsp)
    self._txtHpTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Rec_Total")
    self._list.visible = false
    self._list2.visible = true
    self._txtMember.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Rec_People")..rsp.StoreMemberNum
    self.goods = rsp.Goods
    local amount = 0
    self._list2:RemoveChildrenToPool()
    self._selfStoring = false
    for _, v in pairs(rsp.Goods) do
        if v.UserId == PlayerDataModel.PlayId then
            self._selfStoring = true
        end
        local item = self._list2:AddItemFromPool()
        item:Init(FortressViewDetailItemType.SaveRes, v)
        for _, v1 in pairs(v.StoreGoods) do
            local config = ConfigMgr.GetItem("configResourcess", v1.Category)
            amount = amount + v1.Amount * config.ratio
        end
    end
    local item = self._list2:AddItemFromPool()
    item:Init(FortressViewDetailItemType.Add, {cb = function()
            local config = ConfigMgr.GetListBySearchKeyValue("configAllianceFortresss", "building_type", Global.AllianceStore)[1]
            Net.AllianceStorehouse.StoreInfo(
                config.id,
                function(rsp)
                    local posX, posY = MathUtil.GetCoordinate(self.chunkInfo.Id)
                    UIMgr:Open("UnionWarehouseAccessResources", 2, rsp,posX*10000+posY)
                end
            )
        end})
    self._txtHp.text = Tool.FormatNumberThousands(amount)
end

function UnionFortressViewDetail:BuildingValueTimer()
    if self.info.OperationSpeedPerSec > 0 then
        if self.info.State == 4 then
            self.curBuildValue = self.info.ArchiValue - (Tool.Time() - self.info.ChangeTime) * self.info.OperationSpeedPerSec
            self.buildAt = self.curBuildValue / self.info.OperationSpeedPerSec
        else
            self.curBuildValue = self.info.ArchiValue + (Tool.Time() - self.info.ChangeTime) * self.info.OperationSpeedPerSec
            self.buildAt = (self.config.build_hp - self.curBuildValue) / self.info.OperationSpeedPerSec
        end
        
        self:UnSchedule(self.timer_func)
        self:Schedule(self.timer_func, 1)
        self.timer_func()
    else
        self.c1.selectedIndex = 1
    end
end

return UnionFortressViewDetail
