--author: 	Amu
--time:		2019-09-25 15:08:03

local BtnChatExpression = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/btnChatExpression", BtnChatExpression)

BtnChatExpression.tempList = {}

function BtnChatExpression:ctor()
    self._icon = self:GetChild("icon")
    self:InitEvent()
end

function BtnChatExpression:InitEvent()
end

function BtnChatExpression:SetData(info)
    self.info = info
    local pkg = info[1] and info[1] or info.addr
    local url = info[2] and info[2] or info.id
    local a = UIPackage.GetItemURL(pkg, url)
    self._icon.icon = UIPackage.GetItemURL(pkg, url)
end

function BtnChatExpression:GetData()
    return self.info
end

return BtnChatExpression