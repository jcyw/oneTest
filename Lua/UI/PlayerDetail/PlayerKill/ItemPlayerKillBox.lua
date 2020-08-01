--[[
    Author: songzeming
    Function: 玩家杀敌弹窗item
]]
local ItemPlayerKillBox = fgui.extension_class(GComponent)
fgui.register_extension('ui://PlayerDetail/itemPlayKillBox', ItemPlayerKillBox)

function ItemPlayerKillBox:ctor()
end

function ItemPlayerKillBox:Init(title, kill)
    self._title.text = title
    self._kill.text = kill
end

return ItemPlayerKillBox
