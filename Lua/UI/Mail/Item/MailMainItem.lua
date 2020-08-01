--author: 	Amu
--time:		2020-06-29 19:41:41

local MailMainItem = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/MailMainItem", MailMainItem)


function MailMainItem:ctor()
    self._iconRank = self:GetChild("iconRank")
    self._icon = self:GetChild("_icon")

    self:InitEvent()
end

function MailMainItem:InitEvent(  )
end



function MailMainItem:SetData(info)
end

return MailMainItem