--author: 	Amu
--time:		2020-06-16 22:56:51

local ItemTurntableBar = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemTurntableBar", ItemTurntableBar)

function ItemTurntableBar:ctor()

    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
    self:InitEvent()
end

function ItemTurntableBar:InitEvent(  )
    self:AddListener(self.onTouchBegin,function()
        if (self.title and self.decs and  self.detailPop and self.detailPop.OnShowUI) then
            self.detailPop:OnShowUI(self.title, self.decs, self, false)
        end
    end)

    self:AddListener(self.onTouchEnd, function()
        self.detailPop:OnHidePopup()
    end)

    self:AddListener(self.onRollOut,function()
        self.detailPop:OnHidePopup()
    end)
end

function ItemTurntableBar:SetData(info)
    if info.category then
        self.title = nil
        self.decs = nil
        local resConfig = ConfigMgr.GetItem("configResourcess", info.category)
        local mid = GD.ItemAgent.GetItemInnerContent(info.category)
        self._itemProp:SetShowData(resConfig.img,resConfig.color,nil,nil,mid)
        self._textName.text = ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_" .. info.category)
        self._textTagNumber.text = info.amount
    elseif info.confId then
        self.title = GD.ItemAgent.GetItemNameByConfId(info.confId)
        self.decs = GD.ItemAgent.GetItemDescByConfId(info.confId)
        local itemConfig = ConfigMgr.GetItem("configItems", info.confId)
        local mid = GD.ItemAgent.GetItemInnerContent(info.confId)
        self._itemProp:SetShowData(itemConfig.icon,itemConfig.color,nil,nil,mid)
        self._textName.text =  GD.ItemAgent.GetItemNameByConfId(info.confId)
        self._textTagNumber.text = string.format("x%d", info.amount)
    end
end

return ItemTurntableBar