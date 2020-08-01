--author: 	Amu
--time:		2020-02-10 19:08:39

local MailfailureReason = UIMgr:NewUI("MailfailureReason")

function MailfailureReason:OnInit()
    self._view = self.Controller.contentPane
    
    self._btnReturn = self._view:GetChild("btnReturn")
    self._listView = self._view:GetChild("liebiao")

    self:InitEvent()
end

function MailfailureReason:InitEvent()
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)
    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end

        item:SetData(index + 1, self)
    end
end

function MailfailureReason:OnOpen()
    self:RefreshView()
end

function MailfailureReason:RefreshView()
    self._listView.numItems = 4
end

function MailfailureReason:Close()
    UIMgr:Close("MailfailureReason")
end

return MailfailureReason