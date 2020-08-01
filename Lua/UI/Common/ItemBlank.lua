--[[
    Author: songzeming
    Function: 空白节点
]]
local ItemBlank = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/blankNode", ItemBlank)

function ItemBlank:ctor()
end

function ItemBlank:GetContext()
    return self
end

return ItemBlank
