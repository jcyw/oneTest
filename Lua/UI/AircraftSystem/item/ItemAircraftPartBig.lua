--[[
    author:{laofu}
    time:2020-07-15 17:37:58
    function:{零件格子}
]]
local GD = _G.GD
local ItemAircraftPartBig = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://AircraftSystem/itemAircraftPartBig", ItemAircraftPartBig)
local PlaneModel = _G.PlaneModel
local TipUtil = _G.TipUtil
local ConfigMgr = _G.ConfigMgr
local RESBOND = ConfigMgr.GetVar("ResBond")
function ItemAircraftPartBig:ctor()
    self._lockCtr = self:GetController("c1")
    self._bgCtr = self:GetController("c3")
    self._item = self:GetChild("item")
    self._planeName = self:GetChild("title")
    self._tipsText = self:GetChild("tipsText")
    self._price = self:GetChild("price")
    self._btnLock = self:GetChild("lock")

    self:AddListener(
        self._btnLock.onClick,
        function()
            local data = {
                title = "Ui_Buy",
                name = self.partConfig.name,
                image = self.partConfig.image,
                color = self.partConfig.color,
                buy_price = self.partConfig.buy_price,
                sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CONFIRM"),
                callback = function(cb)
                    if GD.ResAgent.Amount(RESBOND, false) >= self.partConfig.buy_price then
                        PlaneModel.BuyPlanePart(
                            self.partConfig.id,
                            function()
                                TipUtil.TipById(50199)
                                --刷新飞机机库页面和详细页面
                                Event.Broadcast(EventDefines.RefreshHangarContent)
                                Event.Broadcast(EventDefines.RefreshAirDetailsContent)
                                if cb then
                                    cb()
                                end
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
            UIMgr:Open(
                "AircraftStorePopup",
                data,
                function()
                    if self.triggerFunc then
                        self.triggerFunc()
                        self.triggerFunc = nil
                    end
                end
            )
        end
    )
end

function ItemAircraftPartBig:SetData(partId, haveBg, needUnlock)
    self.partConfig = PlaneModel.GetPartConfByID(partId)
    --背景设置
    self._bgCtr.selectedIndex = haveBg
    self._planeName.text = StringUtil.GetI18n(I18nType.Commmon, self.partConfig.name)
    --item设置
    self._item:SetShowData(self.partConfig.image, self.partConfig.color)
    --状态设置
    self._price:SetCost(self.partConfig.buy_price)
    if needUnlock then
        self._lockCtr.selectedIndex = 1
        self._tipsText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_COMPONETS_UNLOAD_TEXT")
    else
        self._lockCtr.selectedIndex = PlaneModel.GetPartInfoByPartId(partId) and 1 or 0
        self._tipsText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_COMPONETS_OWNED_TEXT")
    end
end

function ItemAircraftPartBig:TriggerOnclick(callback)
    self.triggerFunc = callback
end

return ItemAircraftPartBig
