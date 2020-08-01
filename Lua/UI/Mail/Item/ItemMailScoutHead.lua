--author: 	Amu
--time:		2019-06-28 16:29:04

local ItemMailScoutHead = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailScoutHead", ItemMailScoutHead)

function ItemMailScoutHead:ctor()
    self._icon = self:GetChild("iconMy")
    self._name = self:GetChild("textName")
    self._lv = self:GetChild("textPlace")

    self:InitEvent()
end

function ItemMailScoutHead:InitEvent(  )
end

function ItemMailScoutHead:SetData(info)
    local str = ""
    if info.Alliance and info.Alliance ~= "" then
        str = str.."["..info.Alliance.."]"
    end
    str = str..info.Name
    self._name.text = str
    self._lv.text = string.format( "Lv.%d", info.Level)
    -- CommonModel.SetUserAvatar(self._icon, info.Avatar)
    self._icon:SetAvatar(info)
end

return ItemMailScoutHead