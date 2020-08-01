--[[
    Author: songzeming
    Function: 队列弹窗 道具Item
]]
local ItemQueuePopupProp = fgui.extension_class(GComponent)
fgui.register_extension('ui://MainCity/itemQueuePopupProp', ItemQueuePopupProp)

function ItemQueuePopupProp:ctor()
end

function ItemQueuePopupProp:Init(icon,color,num,name)
    self._item:SetShowData(icon,color,num,name)
end

return ItemQueuePopupProp
