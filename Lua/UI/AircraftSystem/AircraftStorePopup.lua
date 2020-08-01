local GD = _G.GD
local UIMgr = _G.UIMgr
local UITool = _G.UITool
local AircraftStorePopup = UIMgr:NewUI("AircraftStorePopup")
local pageStatus = {
    icon = "icon", --带有图标时
    text = "text" -- 只有文本时
}
function AircraftStorePopup:OnInit()
    --获取部件
    local view = self.Controller.contentPane
    self._title = view:GetChild("_title")
    self._mask = view:GetChild("_mask")
    self._btnClose = view:GetChild("_btnClose")
    self._btnsure = view:GetChild("_btnsure")
    self._btnsure2 = view:GetChild("_btnsure2")
    self._textName = view:GetChild("_textName")
    self._textName2 = view:GetChild("_textName2")
    self._item= view:GetChild("item")
    self._price = view:GetChild("price")
    self._price2 = view:GetChild("price2")
    self._status = view:GetController("status")

    --获取属性列表组件
    self._textcost = {}
    for i = 1,3 do
        self._textcost[i] = view:GetChild(string.format("_textcost%d",i))
    end

    -- 回调
    self.callback = nil

    --事件
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("AircraftStorePopup")
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            UIMgr:Close("AircraftStorePopup")
        end
    )
    self:AddListener(self._btnsure.onClick,
        function()
            if self.callback then
                self.callback(
                    function ()
                        if self.triggerFunc then
                            self.triggerFunc()
                            self.triggerFunc=nil
                        end
                    end
                )
            end
            UIMgr:Close("AircraftStorePopup")
        end
    )
    self:AddListener(self._btnsure2.onClick,
        function()
            if self.callback then
                self.callback(
                    function ()
                        if self.triggerFunc then
                            self.triggerFunc()
                            self.triggerFunc=nil
                        end
                    end
                )
            end
            UIMgr:Close("AircraftStorePopup")
        end
    )
end
--[[
    data = {
        title 标题
        name 物品名字
        image 物品图标
        color 物品背景颜色
        buy_price 物品价格
        sureBtnText 确认按钮文本
        callback 确认后的回调
    }
]]
function AircraftStorePopup:OnOpen(data,triggerCb)
    if data.image then
        self._item:SetShowData(data.image, data.color)
        self._status.selectedPage = pageStatus.icon
    else
        self._status.selectedPage = pageStatus.text
    end
    self._title.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, data.title)
    self._textName.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, data.name)
    self._textName2.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, data.name)
    self._price:SetCost(data.buy_price)
    self._price2:SetCost(data.buy_price)
     --设置确定按钮文本
     if data.sureBtnText then
        self._btnsure.text = data.sureBtnText
        self._btnsure2.text = data.sureBtnText
    else
        self._btnsure.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
        self._btnsure2.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
    end
    self.callback = data.callback
    if triggerCb then
        triggerCb()
        triggerCb=nil
    end
end

function AircraftStorePopup:TriggerOnclick(callback)
    self.triggerFunc = callback
end

return AircraftStorePopup
