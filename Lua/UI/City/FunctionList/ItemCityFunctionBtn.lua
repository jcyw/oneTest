--[[
    Author: songzeming
    Function: 建筑功能列表 图标按钮
]]
local ItemCityFunctionBtn = fgui.extension_class(GButton)
fgui.register_extension("ui://Build/buildComplete", ItemCityFunctionBtn)

local CTR = {
    Normal = "Normal",
    GoldIcon = "GoldIcon",
    GoldLabel = "GoldLabel",
    Item = "Item"
}
local CTR_DESC = {
    Single = "Single",
    Double = "Double"
}

function ItemCityFunctionBtn:ctor()
    self._ctr = self:GetController("Ctr")
    self._ctrDesc = self:GetController("CtrDesc")
    self:AddListener(self.onClick,
        function()
            self.callback()
            if self.triggerCallBack then
                self.triggerCallBack()
            end
        end
    )
end

function ItemCityFunctionBtn:Init(name, icon, callback)
    self.callback = callback
    self._title.text = name
    self._icon.icon = icon
    self._ctr.selectedPage = CTR.Normal
    self._ctrDesc.selectedPage = CTR_DESC.Single
    self:SetGrayed(false)
end

function ItemCityFunctionBtn:SetGoldNumberIcon(number)
    self._numGoldIcon.text = UITool.GetTextColor(GlobalColor.Yellow, number)
    self._ctr.selectedPage = CTR.GoldIcon
end

function ItemCityFunctionBtn:SetGoldNumberLabel(number)
    self._numGoldLabel.text = UITool.GetTextColor(GlobalColor.Yellow, number)
    self._ctr.selectedPage = CTR.GoldLabel
end

function ItemCityFunctionBtn:SetItemNumber(number)
    local values = {
        num = number
    }
    self._numItem.text = StringUtil.GetI18n(I18nType.Commmon, "UI_HAVE_NUM", values)
    self._ctr.selectedPage = CTR.Item
end

function ItemCityFunctionBtn:SetName(name, time)
    self._ctrDesc.selectedPage = CTR_DESC.Double
    self._title.text = name
    self._titleTime.text = time
end

function ItemCityFunctionBtn:SetGrayed(flag)
    self.grayed = flag
end

function ItemCityFunctionBtn:GetName()
    return self._title.text
end

function ItemCityFunctionBtn:TriggerOnclick(callback)
    self.triggerCallBack = callback
end

function ItemCityFunctionBtn:SetTouchMaskEnable(flag)
    self._touchMask.visible = flag
end

return ItemCityFunctionBtn
