--[[
    author:{laofu}
    time:2020-07-17 10:58:33
    function:{战机详情界面}
]]
local GD = _G.GD
local AircraftDetails = UIMgr:NewUI("AircraftDetails")
local PlaneModel = import("Model/PlaneModel")
local RESBOND = ConfigMgr.GetVar("ResBond")

function AircraftDetails:OnInit()
    local view = self.Controller.contentPane
    self._bannerIcon = self._banner:GetChild("icon")
    self._bannerTitle = self._banner:GetChild("title")
    self._bannerBg = self._banner:GetChild("iconBg")
    self._oneKeyCtr = view:GetController("c1")
    self._lockCtr = view:GetController("c2")
    self._startCtr = view:GetController("c3")
    self._collectCtr = view:GetController("c4")
    self._bannerBg.icon = UITool.GetIcon(GlobalBanner.PlaneBanner)
    --文本设置
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_PLANE_TITLE")
    self._priceDesc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_BOND_CURRENT_POINT")
    self._btnOneKey.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_START_USE_ALL")
    self._btnLock.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceTech_UnLock")
    self._btnStart.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_START_USE")
    self._btnCancel.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CANCEL_USE")
    self._btnAddCollection.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_ADD_USUAL")
    self._btnCancelCollection.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_DELETE_USUAL")
    --分割线
    self:InitEvent()
end

function AircraftDetails:InitEvent()
    self:AddListener(
        self._btnClose.onClick,
        function()
            UIMgr:Close("AircraftDetails")
        end
    )

    self:AddListener(
        self._btnToShop.onClick,
        function()
            UIMgr:Open("AircraftAccessories")
            UIMgr:Close("AircraftDetails")
        end
    )

    self:AddListener(
        self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                info = StringUtil.GetI18n(I18nType.Commmon, "UI_PLANE_INFO")
            }
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )

    self:AddListener(
        self._btnStart.onClick,
        function()
            PlaneModel.NetLuanchPlane(
                self.aircraftId,
                function()
                    TipUtil.TipById(50362)
                    self._startCtr.selectedIndex = 1
                    --刷新机库页面
                    Event.Broadcast(EventDefines.RefreshHangarContent)
                    local planeInfo = PlaneModel.GetPlaneInfoById(self.aircraftId)
                    self:RefreshContent(planeInfo, self.isCollect)
                end
            )
            if self.triggerFunc then
                self.triggerFunc()
            end
        end
    )

    self:AddListener(
        self._btnCancel.onClick,
        function()
            PlaneModel.UnlaunchPlane(
                self.aircraftId,
                function()
                    TipUtil.TipById(50363)
                    self._startCtr.selectedIndex = 0
                    --刷新机库页面
                    Event.Broadcast(EventDefines.RefreshHangarContent)
                    local planeInfo = PlaneModel.GetPlaneInfoById(self.aircraftId)
                    self:RefreshContent(planeInfo, self.isCollect)
                end
            )
        end
    )

    self:AddListener(
        self._btnAddCollection.onClick,
        function()
            PlaneModel.AddCollectPlane(
                self.aircraftId,
                function()
                    TipUtil.TipById(50365)
                    self._collectCtr.selectedIndex = 1
                    --刷新机库页面
                    Event.Broadcast(EventDefines.RefreshHangarContent)
                end
            )
        end
    )

    self:AddListener(
        self._btnCancelCollection.onClick,
        function()
            PlaneModel.DelCollectPlane(
                self.aircraftId,
                function()
                    TipUtil.TipById(50361)
                    self._collectCtr.selectedIndex = 0
                    --刷新机库页面
                    Event.Broadcast(EventDefines.RefreshHangarContent)
                end
            )
        end
    )

    self:AddListener(
        self._btnOneKey.onClick,
        function()
            if not Model.Player.VipActivated then
                TipUtil.TipById(50366)
                return
            end
            if Model.Player.VipLevel < 9 then
                TipUtil.TipById(50367)
                return
            end
            PlaneModel.OneKeyLuanchPlane(
                self.aircraftId,
                function()
                    TipUtil.TipById(50362)
                    self._oneKeyCtr.selectedIndex = 0
                    --刷新机库页面
                    Event.Broadcast(EventDefines.RefreshHangarContent)
                    local planeInfo = PlaneModel.GetPlaneInfoById(self.aircraftId)
                    self:RefreshContent(planeInfo, self.isCollect)
                end
            )
        end
    )

    self:AddListener(
        self._btnLock.onClick,
        function()
            local data = {
                title = "Tips_TITLE",
                name = "ALERT_BUY_PLANE",
                buy_price = self.unlockTotalPrice,
                sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CONFIRM"),
                callback = function()
                    if GD.ResAgent.Amount(RESBOND, false) >= self.unlockTotalPrice then
                        PlaneModel.UnlockPlane(
                            self.aircraftId,
                            function()
                                TipUtil.TipById(50364)
                                self._lockCtr.selectedIndex = 0
                                --刷新机库页面
                                Event.Broadcast(EventDefines.RefreshHangarContent)
                                local planeInfo = PlaneModel.GetPlaneInfoById(self.aircraftId)
                                self:RefreshContent(planeInfo, self.isCollect)
                            end
                        )
                    else
                        local dataui = {
                            content = StringUtil.GetI18n(_G.I18nType.Commmon, "UI_PLANE_POINT_UNENOUGH"),
                            sureBtnText = StringUtil.GetI18n(_G.I18nType.Commmon, "UI_PLANE_GET"),
                            sureCallback = function()
                                PlaneModel.GetResBond()
                            end
                        }
                        UIMgr:Open("ConfirmPopupText", dataui)
                    end
                end
            }
            UIMgr:Open("AircraftStorePopup", data)
        end
    )

    self:AddListener(
        self._btnRight.onClick,
        function()
            if self.planeList[self.index + 1] then
                self:RefreshContent(self.planeList[self.index + 1], self.isCollect)
            end
        end
    )

    self:AddListener(
        self._btnLeft.onClick,
        function()
            if self.planeList[self.index - 1] then
                self:RefreshContent(self.planeList[self.index - 1], self.isCollect)
            end
        end
    )

    self._partList.itemRenderer = function(index, item)
        --item是否有背景图片，没有就是0
        item:SetData(self.partIdList[index + 1], 1, self.needUnlock)
    end

    self:AddEvent(
        EventDefines.RefreshAirDetailsContent,
        function()
            local planeInfo = PlaneModel.GetPlaneInfoById(self.aircraftId)
            self:RefreshContent(planeInfo, self.isCollect)
        end
    )

    self:AddEvent(
        EventDefines.UIResourcesAmount,
        function()
            self:RefreshPrice()
        end
    )
end

function AircraftDetails:OnOpen(planeInfo, isCollect)
    --内容刷新
    self:RefreshContent(planeInfo, isCollect)
end

function AircraftDetails:RefreshContent(planeInfo, isCollect)
    --左右按钮切换列表旋转
    self.isCollect = isCollect
    if isCollect then
        self.planeList = PlaneModel.GetCollectPlaneList()
    else
        self.planeList = PlaneModel.GteLevelPlaneList(planeInfo.config.level)
    end
    self.planeInfo = planeInfo
    self.aircraftId = planeInfo.Id
    self._bannerIcon.icon = UITool.GetIcon(self.planeInfo.config.image)
    self._bannerTitle.text = StringUtil.GetI18n(I18nType.Commmon, self.planeInfo.config.name)
    local num = GD.ResAgent.Amount(ConfigMgr.GetVar("ResBond"), false)
    self._price:SetCost(num)
    --左右按钮数据设置显示设置
    for key, value in pairs(self.planeList) do
        if value.Id == planeInfo.Id then
            self.index = key
            break
        end
    end
    self._btnRight.visible = self.planeList[self.index + 1] and true or false
    self._btnLeft.visible = self.planeList[self.index - 1] and true or false
    --零件列表
    self.partIdList = self.planeInfo.config.part_type
    self.needUnlock = false
    if self.planeInfo.config.unlock == 1 then
        self.needUnlock = true
    end
    self._partList.numItems = #self.partIdList
    --解锁状态设置
    self._lockCtr.selectedIndex = self.planeInfo.IsUnlock and 0 or 1
    --属性列表设置
    self._attributeBonus:SetList(self.aircraftId)
    --常用按钮设置
    self._collectCtr.selectedIndex = PlaneModel.GetCollectPlaneById(self.aircraftId) and 1 or 0
    self._startCtr.selectedIndex = PlaneModel.IsLuanchPlane(self.aircraftId) and 1 or 0
    --按钮状态设置
    if not self.planeInfo.IsUnlock then
        self._btnStart.enabled = false
        self._btnAddCollection.enabled = false
    else
        self._btnStart.enabled = true
        self._btnAddCollection.enabled = true
    end

    --一键启用状态设置
    self._oneKeyCtr.selectedIndex = self.needUnlock and 0 or 1
    self:StartUpStatus(planeInfo)
end

--启动状态设置
function AircraftDetails:StartUpStatus(planeInfo)
    --需要解锁的飞机
    if self.needUnlock and not self.planeInfo.IsUnlock then
        self._btnAddCollection.enabled = false
        local price = PlaneModel.UnlockPlanePrice(planeInfo)
        self.unlockTotalPrice = self.planeInfo.config.unlock_consume + price
        self._unlockPrice:SetCost(self.unlockTotalPrice)
    elseif not self.needUnlock then --不需要解锁的飞机
        local price = PlaneModel.PartTotalPrice(planeInfo)
        if price ~= 0 then
            self._isOneKeyPrice = price
            self._oneKeyPrice:SetCost(price)
            self._btnStart.enabled = false
            self._btnAddCollection.enabled = false
        end
        local isOneKey = (price ~= 0) and true or false
        self._oneKeyPrice.visible = isOneKey
        self._btnOneKey.enabled = isOneKey
        if isOneKey then
            self._btnOneKey.grayed = (Model.Player.VipLevel < 9) and true or false
        end
    end
end

function AircraftDetails:RefreshPrice()
    self._price:SetCost(GD.ResAgent.Amount(RESBOND, false))
end

function AircraftDetails:TriggerOnclick(callback)
    self.triggerFunc = callback
end

return AircraftDetails
