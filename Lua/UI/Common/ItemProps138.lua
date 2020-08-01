--[[
    author:{author}
    time:2019-09-29 15:33:53
    function:{desc}
]]
local ItemProps138 = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemProps138", ItemProps138)

function ItemProps138:ctor()
    self._bg = self:GetChild("bg")
    self._icon = self:GetChild("icon")
    self._num = self:GetChild("text")
end
function ItemProps138:SetData(amount, icon)
    self._num.text = "X" .. tostring(amount)
    self._icon.icon = UITool.GetIcon(icon)
end

return ItemProps138
