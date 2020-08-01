--[[
    Author: songzeming
    Function: 资源收集动画item
]]
local ItemResCollectAnim = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/ResCollectAnim", ItemResCollectAnim)

function ItemResCollectAnim:ctor()
end

function ItemResCollectAnim:GetContext()
    return self
end

return ItemResCollectAnim
