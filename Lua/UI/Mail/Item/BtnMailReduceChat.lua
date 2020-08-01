--author: 	Amu
--time:		2019-09-09 14:35:06

local BtnMailReduceChat = fgui.extension_class(GButton)
fgui.register_extension("ui://Mail/btnMailReduceChat", BtnMailReduceChat)

function BtnMailReduceChat:ctor()
    self:InitEvent()
end

function BtnMailReduceChat:InitEvent()
end

function BtnMailReduceChat:SetData(index)
    self.index = index
end

function BtnMailReduceChat:GetIndex()
    return self.index
end

return BtnMailReduceChat