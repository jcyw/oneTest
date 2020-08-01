--author: 	Amu
--time:		2020-03-12 14:48:35

local AmendmentNotice = UIMgr:NewUI("AmendmentNotice")

function AmendmentNotice:OnInit()
    self._view = self.Controller.contentPane

    self._limiteText = self._view:GetChild("text")

    self:InitEvent()
end

function AmendmentNotice:InitEvent( )
    self:AddListener(self._btnClose.onClick,function()--返回
        self:Close()
    end)

    self:AddListener(self._bgMask.onClick,function()--返回
        self:Close()
    end)
end

function AmendmentNotice:OnOpen()

end

function AmendmentNotice:RefreshText()

end

function AmendmentNotice:Close( )
    UIMgr:Close("AmendmentNotice")
end

return AmendmentNotice