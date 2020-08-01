-- author:{Amu}
-- time:2019-06-19 16:23:04
local Emojies = import("Utils/Emojies")

local MailEditorialNewsPopup = UIMgr:NewUI("MailEditorialNewsPopup")

function MailEditorialNewsPopup:OnInit()
    self._view = self.Controller.contentPane

    self._textInputName = self._view:GetChild("textInput")
    self._textExplain = self._view:GetChild("textExplain")

    self._box = self._view:GetChild("group")

    self:InitEvent()
end

function MailEditorialNewsPopup:OnOpen()

end


function MailEditorialNewsPopup:InitEvent(  )
    -- self:AddListener(self._view:GetChild("btnReturn").onClick,function() 
    --     UIMgr:Close("MailEditorialNewsPopup")
    -- end)

    self:AddListener(self._view.onTouchBegin,function(context)
        if context.inputEvent.y < self._box.y or context.inputEvent.y > (self._box.y+self._box.height) then
            UIMgr:Close("MailEditorialNewsPopup")
        end
    end)

    self:AddListener(self._view:GetChild("btnGold").onClick,function()
        local name = self._textInputName.text
        if name == "" then
            --TODO
            return
        end
        local msg = self._textExplain.text
        if msg == "" then
            --TODO
            return
        end
        Net.Mails.Send(MAIL_SUBTYPE.subPersonalMsg, name, msg, function(rsp)
            self._textExplain.text = ""
        end)
    end)


end

function MailEditorialNewsPopup:Close()
    UIMgr:Close("MailEditorialNewsPopup")
end

return MailEditorialNewsPopup