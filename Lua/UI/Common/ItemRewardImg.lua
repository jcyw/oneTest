--[[
    
]]
local ItemRewardImg = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/ItemRewardImg", ItemRewardImg)

function ItemRewardImg:ctor()
end

function ItemRewardImg:GetContext()
    return self
end

return ItemRewardImg