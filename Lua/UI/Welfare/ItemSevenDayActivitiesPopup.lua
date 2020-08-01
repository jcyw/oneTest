local GD = _G.GD
local ItemSevenDayActivitiesPopup = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemSevenDayActivitiesPopup", ItemSevenDayActivitiesPopup)

function ItemSevenDayActivitiesPopup:ctor()
    self._icon = self:GetChild("icon")
    self._textTitle = self:GetChild("title")
    self._textNum = self:GetChild("textNum")
    self._iconArrow = self:GetChild("iconArrow")
    --self._groupMid = self._icon:GetChild("_groupMid")
    self._iconArrow.visible = false
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")

    local item = self._icon
    self:AddListener(item.onTouchBegin,
        function()
            local title = GD.ItemAgent.GetItemNameByConfId(self.data.confId)
            local des = nil
            if self.data.isRes then
                local key = ConfigMgr.GetItem("configResourcess", self.data.confId).key
                title = StringUtil.GetI18n(I18nType.Commmon, key)
                des = title .. "X" .. self.data.amount
            else
                des = GD.ItemAgent.GetItemDescByConfId(self.data.confId)
            end
            self.detailPop:OnShowUI(title, des, item._icon, false)
        end
    )
    self:AddListener(item.onTouchEnd,
        function()
            self.detailPop:OnHidePopup()
        end
    )
    self:AddListener(item.onRollOut,function()
        self.detailPop:OnHidePopup()
    end)
end

function ItemSevenDayActivitiesPopup:SetData(data)
    self.data = data
    self:RefreshInfo()
end

function ItemSevenDayActivitiesPopup:RefreshInfo()
    self._textNum.text = "x" .. self.data.amount
    --self._icon:SetIcon(UITool.GetIcon(self.data.image))
    local mid = GD.ItemAgent.GetItemInnerContent(self.data.confId)
    self._icon:SetShowData(self.data.image,self.data.color)
    self._icon:SetShowData(self.data.image,self.data.color,nil,nil,mid)
    --self._groupMid.visible = false
    local titleName = nil
    if self.data.isRes then
        local key = ConfigMgr.GetItem("configResourcess", self.data.confId).key
        titleName = StringUtil.GetI18n(I18nType.Commmon, key)
    else
        titleName = GD.ItemAgent.GetItemNameByConfId(self.data.confId)
    end
    self._textTitle.text = titleName
end

return ItemSevenDayActivitiesPopup
