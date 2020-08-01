--author: 	Amu
--time:		2019-09-10 09:48:54

local MailManyPeopleChatRename = UIMgr:NewUI("MailManyPeopleChatRename")

function MailManyPeopleChatRename:OnInit()
    self._view = self.Controller.contentPane

    self._bgMask = self._view:GetChild("bgMask")

    self._textInput = self._view:GetChild("textRename")
    self._btnOk = self._view:GetChild("btnOk")


    self:InitEvent()
end

function MailManyPeopleChatRename:InitEvent(  )
    self:AddListener(self._bgMask.onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnOk.onClick,function()
        if self._textInput.text == "" then
            TipUtil.TipById(50220)
            return
        end
        if self.groupInfo.sessionId then
            Net.Mails.ChangeGroupName(self.groupInfo.sessionId, self._textInput.text, function(msg)
                self:Close()
            end)
        end
    end)
end

function MailManyPeopleChatRename:OnOpen(groupInfo)
    self.groupInfo = groupInfo
    self._textInput.text = ""
end

function MailManyPeopleChatRename:Close()
    UIMgr:Close("MailManyPeopleChatRename")
end

return MailManyPeopleChatRename