--author: 	Amu
--time:		2020-03-09 11:35:19

local UnionModel = import("Model/UnionModel")

local AmendmentNotice = UIMgr:NewUI("AmendmentNotice")

function AmendmentNotice:OnInit()
    -- body
    self._view = self.Controller.contentPane

    self._bgMask = self._view:GetChild("bgMask")

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

    self:AddListener(self._textInput.onChanged,function()
        self:RefreshText()
    end)

    self:AddListener(self._btnSend.onClick,function()--编辑
        if self._textInput.text == UnionModel.GetUnionNotice() then
            TipUtil.TipById(50283)
            return
        end
        Net.Alliances.ChangeAnnouncement(self._textInput.text, function(msg)
            TipUtil.TipById(50282)
            self:Close()
        end)
    end)
end

function AmendmentNotice:OnOpen()
    self._textInput.text = UnionModel.GetUnionNotice()
    if Model.Player.AlliancePos >= Global.AlliancePosR4 then
        self._btnSend.enabled = true
    else
        self._btnSend.enabled = false
    end
    self:RefreshText()
end

function AmendmentNotice:RefreshText()
    self._textInput.text = string.gsub(self._textInput.text, "[\t\n\r[%]]+", "")
    local len = Util.GetGBLength(self._textInput.text)
    if len > 300 then
        self._textInput.text = self.lastText
        len = Util.GetGBLength(self._textInput.text)
        self._limiteText.text = string.format("(%d/300)", len)
    else
        self._limiteText.text = string.format("(%d/300)", len)
    end
    self.lastText = self._textInput.text
end

function AmendmentNotice:Close( )
    UIMgr:Close("AmendmentNotice")
end

return AmendmentNotice