--author: 	Amu
--time:		2019-09-09 14:34:54

local BtnMailAddChat = fgui.extension_class(GButton)
fgui.register_extension("ui://Mail/btnMailAddChat", BtnMailAddChat)

function BtnMailAddChat:ctor()
    self:InitEvent()
end

function BtnMailAddChat:InitEvent()
end

function BtnMailAddChat:SetData(index)
    self.index = index
end

function BtnMailAddChat:GetIndex()
    return self.index
end

return BtnMailAddChat