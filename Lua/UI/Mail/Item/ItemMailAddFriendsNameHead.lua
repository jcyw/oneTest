--author: 	Amu
--time:		2019-09-09 14:34:43

local ItemMailAddFriendsNameHead = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailAddFriendsNameHead", ItemMailAddFriendsNameHead)

function ItemMailAddFriendsNameHead:ctor()
    self._head = self:GetChild("btnHead")
    self._name = self:GetChild("title")
    self:InitEvent()
end

function ItemMailAddFriendsNameHead:InitEvent()
end

function ItemMailAddFriendsNameHead:SetData(index, info)
    self.index = index
    self._name.text = info.Name
    self._head:SetAvatar(info)
end

function ItemMailAddFriendsNameHead:GetIndex()
    return self.index
end

return ItemMailAddFriendsNameHead