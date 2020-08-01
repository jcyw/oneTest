--[[
    function:通用底板
    author:{tiantian}
    time:2020-07-28 11:06:24
]]
local UIBackground = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/UIBackground", UIBackground)

function UIBackground:ctor()
end

function UIBackground:SetIcon(icon)
    _G.UITool.GetIcon(icon,self._icon)
end

return UIBackground