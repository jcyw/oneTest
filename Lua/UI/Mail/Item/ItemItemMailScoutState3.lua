--author: 	Amu
--time:		2019-06-28 11:13:45

local ItemItemMailScoutState3 = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemItemMailScoutState3", ItemItemMailScoutState3)


function ItemItemMailScoutState3:ctor()
    self._icon = self:GetChild("icon")
    self._name = self:GetChild("textName")
    self._describe = self:GetChild("textDescribe")

    self:InitEvent()
end

function ItemItemMailScoutState3:InitEvent(  )
end

function ItemItemMailScoutState3:SetData(index, info, res)
end

return ItemItemMailScoutState3