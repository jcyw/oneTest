--[[
    Author: songzeming
    Function: 玩家形象item
]]
local ItemPlayerCharacterList = fgui.extension_class(GComponent)
fgui.register_extension("ui://PlayerDetail/itemPlayerBust", ItemPlayerCharacterList)

local SpineCharacter = import("Model/Animation/SpineCharacter")

function ItemPlayerCharacterList:ctor()
end

function ItemPlayerCharacterList:Init(bust)
    SpineCharacter.ShowBust(self._bust, bust)
end

return ItemPlayerCharacterList
