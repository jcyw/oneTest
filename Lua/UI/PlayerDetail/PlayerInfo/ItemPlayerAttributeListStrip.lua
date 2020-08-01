--[[
    Author: songzeming
    Function: 玩家信息属性item 列表 条
]]
local ItemPlayerAttributeListStrip = fgui.extension_class(GComponent)
fgui.register_extension("ui://PlayerDetail/itemPlayerAttributeListStrip", ItemPlayerAttributeListStrip)

function ItemPlayerAttributeListStrip:ctor()
end

function ItemPlayerAttributeListStrip:Init(title, text)
    self._title.text = title
    self._text.text = text
end

return ItemPlayerAttributeListStrip
