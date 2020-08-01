-- author:{Amu}
-- time:2019-06-15 10:23:29


local MailPersonalNews_AddFriends = UIMgr:NewUI("MailPersonalNews_AddFriends")

function MailPersonalNews_AddFriends:OnInit()
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnReturn")

    self._textName = self._view:GetChild("textName")
    self._btnEdit = self._view:GetChild("btnEdit")
    self._btnRed = self._view:GetChild("btnRed")

    self._listView = self._view:GetChild("liebiao")

    self:InitEvent()
end

function MailPersonalNews_AddFriends:InitEvent(  )
    self:AddListener(self._btnReturn.onClick,function() 
       self:Close()
    end)

    self:AddListener(self._btnRed.onClick,function()
        local data = {
            content = StringUtil.GetI18n("configI18nCommons", "BUTTON_DELETE_CONFIRM"),
            sureCallback = function()
                if self.groupInfo.sessionId then
                    Net.Mails.DelAndQuitSession(self.groupInfo.sessionId, function(msg)
                        MailModel:DeleteSessionInfo(MAIL_TYPE.Msg, self.groupInfo.sessionId)
                        Event.Broadcast(MAILEVENTTYPE.MailGroupDel)
                        UIMgr:Close("Mail_PersonalNews")
                        self:Close()
                    end)
                else
                    self:Close()
                end
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end)

    self:AddListener(self._btnEdit.onClick,function() 
        UIMgr:Open("MailManyPeopleChatRename", self.groupInfo)
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self.members, self.groupInfo, self)
    end

    self:AddEvent(MAILEVENTTYPE.MailGroupChange, function(info)
        if self.groupInfo.sessionId and self.groupInfo.sessionId == info.Uuid then
            self.members = info.Members
            self.groupInfo.receiver = info.Title
            self:SetMsgGroupTitle(info.Title, #info.Members)
            self:RefreshList()
        end
    end)
end

function MailPersonalNews_AddFriends:OnOpen(info, members)
    self.members = members
    self.groupInfo = info
    self:SetMsgGroupTitle(info.receiver, #members)
    if self.groupInfo.subCategory == MAIL_SUBTYPE.subPersonalMsg then
        self._btnEdit.visible = false
    else
        self._btnEdit.visible = true
    end
    self:RefreshList()
end

function MailPersonalNews_AddFriends:RefreshList()
    self._listView.numItems  = 1
end

function MailPersonalNews_AddFriends:SetMsgGroupTitle(title, num)
    if not title or title == "" then
        self._textName.text = string.format( "群聊(%d)", num)
    else
        self._textName.text = title
    end
end

function MailPersonalNews_AddFriends:Close()
    UIMgr:Close("MailPersonalNews_AddFriends")
end

return MailPersonalNews_AddFriends