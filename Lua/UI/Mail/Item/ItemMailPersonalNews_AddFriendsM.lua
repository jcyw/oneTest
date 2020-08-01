--author: 	Amu
--time:		2019-09-09 11:31:31


local ItemMailPersonalNews_AddFriendsM = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailPersonalNews_AddFriendsM", ItemMailPersonalNews_AddFriendsM)

function ItemMailPersonalNews_AddFriendsM:ctor()
    self._checkBox = self:GetChild("checkBox")

    self._listView = self:GetChild("liebiao")

    self._bgBox = self:GetChild("bgTop")
    self._bgBoxH = self._bgBox.height

    self._height = self.height

    self:InitEvent()
end

function ItemMailPersonalNews_AddFriendsM:InitEvent()

    self:AddListener(self._checkBox.onChanged,function()
        local _selectd = self._checkBox.asButton.selected
        Net.Mails.SetTop(self.groupInfo.sessionId, _selectd, function(msg)
            if _selectd then
                MailModel:SetMsgGroupTop(self.groupInfo.sessionId)
                TipUtil.TipById(50085)
            else
                MailModel:RemoveMsgGroupTop(self.groupInfo.sessionId)
                TipUtil.TipById(50086)
            end
            Event.Broadcast(MAILEVENTTYPE.MailRefresh)
        end)
    end)

    self._listView.itemProvider = function(index)
        if not index then 
            return
        end
        if index < #self.members then
            return "ui://Mail/itemMailAddFriendsNameHead"
        elseif index == #self.members then
            return "ui://Mail/btnMailAddChat"
        elseif index == #self.members+1 then
            return "ui://Mail/btnMailReduceChat"
        end
    end

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        if index+1 <= #self.members then
            item:SetData(index, self.members[index+1])
        else
            item:SetData(index)
        end
    end

    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        local index = item:GetIndex()

        if index+1 == #self.members+1 then
            UIMgr:Open("MailPersonalNews_AddFriends_SelectObject", self.members, self.groupInfo, self._panel)
        elseif index+1 == #self.members+2 then
            UIMgr:Open("MailPersonalNews_AddFriends_SelectObjectCen", self.members, self.groupInfo, self._panel)
        end
    end)

    self._listView:SetVirtual()
end

function ItemMailPersonalNews_AddFriendsM:SetData(members, groupInfo, panel)
    self.members = members
    self.groupInfo = groupInfo
    self._panel = panel
    self:RefreshViewH()
    self._checkBox.asButton.selected = MailModel:MsgGroupIsTop(groupInfo.sessionId)
    if members then
        if groupInfo.messageUserId == UserModel.data.accountId then
            self._listView.numItems  = #self.members + 2
        else
            self._listView.numItems  = #self.members + 1
        end
    end
end

function ItemMailPersonalNews_AddFriendsM:RefreshViewH()
    local _h =  math.ceil((#self.members+2)/5)
    self._bgBox.height = self._bgBoxH*_h
    self:SetSize(self.width, self._height + self._bgBoxH*(_h - 1))
end

return ItemMailPersonalNews_AddFriendsM