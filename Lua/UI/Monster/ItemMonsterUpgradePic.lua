--[[
    function:兵种进阶半身像展示
    author:{tiantian}
    time:2020-07-29 19:32:55
]]
local ItemMonsterUpgradePic = fgui.extension_class(GComponent)
fgui.register_extension("ui://Monster/itemMonsterUpgradePic", ItemMonsterUpgradePic)

function ItemMonsterUpgradePic:ctor()
    self.bgtype = self:GetController("bgtype")
end

function ItemMonsterUpgradePic:SetData(level,name,icon,next)
    self.bgtype.selectedIndex = next and 1 or 0
    self._level.text = level
    self._name.text = name
    self._icon.icon = _G.UITool.GetIcon(icon)
end

return ItemMonsterUpgradePic