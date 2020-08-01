--[[
    author:{laofu}
    time:2020-07-15 16:32:12
    function:{战机机库item}
]]
local GD = _G.GD
local ItemAircraftIntroduction = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://AircraftSystem/itemAircraftIntroduction", ItemAircraftIntroduction)
local PlaneModel = import("Model/PlaneModel")

local StringUtil = _G.StringUtil
local UITool = _G.UITool
local I18nType = _G.I18nType
local UIMgr = _G.UIMgr
local ConfigMgr = _G.ConfigMgr
local RESBOND = ConfigMgr.GetVar("ResBond")

function ItemAircraftIntroduction:ctor()
    self._c1 = self:GetController("c1")
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")
    self._partList = self:GetChild("partList")
    self._btnLock = self:GetChild("_btnLock")
    self._price = self:GetChild("price")
    self._bannerBg = self:GetChild("iconBg")

    self._bannerBg.icon = UITool.GetIcon(GlobalBanner.PlaneBanner)
    self._btnLock.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceTech_UnLock")
    self:InitEvent()
end

function ItemAircraftIntroduction:InitEvent()
    self._partList.itemRenderer = function(index, item)
        --item是否有背景图片，没有就是0
        item:GetChild("item"):SetData(self._partIdList[index + 1], 0, self.needUnlock)
    end

    self:AddListener(
        self._icon.onClick,
        function()
            if self.triggerFunc then
                self.triggerFunc()
            end
            UIMgr:Open("AircraftDetails", self.planeInfo, self.isCollect)
        end
    )

    self:AddListener(
        self._btnLock.onClick,
        function()
            local data = {
                title = "Tips_TITLE",
                name = "ALERT_BUY_PLANE",
                buy_price = self.unlockPrice,
                sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CONFIRM"),
                callback = function()
                    if GD.ResAgent.Amount(RESBOND, false) >= self.unlockPrice then
                        PlaneModel.UnlockPlane(
                            self.planeInfo.Id,
                            function()
                                TipUtil.TipById(50364)
                                self._c1.selectedIndex = 0
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
end

function ItemAircraftIntroduction:SetData(planeInfo, isCollect)
    self.isCollect = isCollect
    self.planeInfo = planeInfo
    --设置解锁状态
    self._c1.selectedIndex = planeInfo.IsUnlock and 0 or 1
    if planeInfo.config.unlock == 1 then
        local price = PlaneModel.UnlockPlanePrice(planeInfo)
        self.unlockPrice = planeInfo.config.unlock_consume + price
        self._price:SetCost(self.unlockPrice)
    end
    --数据设置
    self._icon.icon = UITool.GetIcon(self.planeInfo.config.image)
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, self.planeInfo.config.name)
    --零件列表设置
    self._partIdList = self.planeInfo.config.part_type
    self.needUnlock = false
    if self.planeInfo.config.unlock == 1 then
        self.needUnlock = true
    end
    self._partList.numItems = #self._partIdList
end

function ItemAircraftIntroduction:TriggerOnclick(callback)
    self.triggerFunc = callback
end

return ItemAircraftIntroduction
