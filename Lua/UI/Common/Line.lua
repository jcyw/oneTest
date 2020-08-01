--[[
    author:Temmie
    time:2019-09-26 17:23:26
    function:科技树和技能树用的线
]]
local Line = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/line", Line)

function Line:ctor()
    self._colorControl = self:GetController("colorControl")
end

function Line:SetLight(value)
    self._colorControl.selectedPage = value and "blue" or "gray"
end

return Line
