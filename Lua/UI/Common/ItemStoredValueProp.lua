--[[
    author:{maxiaolong}
    time:2019-10-19 15:08:33
    function:{活动道具奖励}
]]
local ItemStoredValueProp = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemStoredValueProp", ItemStoredValueProp)
-- local title = ""
-- local desc = ""
function ItemStoredValueProp:ctor()
    self._iconImage = self:GetChild("_icon")
    self._amountText = self:GetChild("_amount")
end

function ItemStoredValueProp:SetData(image, amount)
    self._amountText.text = tostring(amount)
    local icon = UITool.GetIcon(image)
    if not icon then
        icon = UITool.GetIcon(image)
    end
    self._iconImage.icon = icon
end

return ItemStoredValueProp
