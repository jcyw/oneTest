--author: 	Amu
--time:		2020-01-02 16:05:48

local SetupSwitchingLinePopup = UIMgr:NewUI("SetupSwitchingLinePopup")

function SetupSwitchingLinePopup:OnInit()
    self._view = self.Controller.contentPane

    self._bgMask = self._view:GetChild("bgMask")
    self._textLine = self._view:GetChild("textLine")

    self._btnList = {
        self._view:GetChild("btnLine1"),
        self._view:GetChild("btnLine2"),
        self._view:GetChild("btnLine3"),
        self._view:GetChild("btnLine4")
    }
    local line = PlayerDataModel:GetData(PlayerDataEnum.LoginLine)
    self.line = line and line or 1
    self._textLine.text = StringUtil.GetI18n("configI18nCommons", "System_SwitchLine_Text2", {line = math.ceil(tonumber(self.line))})

    self:InitEvent()
end

function SetupSwitchingLinePopup:InitEvent(  )
    self:AddListener(self._bgMask.onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnClose.onClick,function()
        self:Close()
    end)

    for k,btn in ipairs(self._btnList)do
        local _line = k
        if k >= tonumber(self.line) then
            _line = k+1
        end
        btn.text = StringUtil.GetI18n("configI18nCommons", "System_SwitchLine_Button1", {line = _line})
        self:AddListener(btn.onClick,function()
            PlayerDataModel:SetData(PlayerDataEnum.LoginLine, _line)
            Network.Relogin()
        end)
    end
end

function SetupSwitchingLinePopup:OnOpen()

end


function SetupSwitchingLinePopup:Close()
    UIMgr:Close("SetupSwitchingLinePopup")
end

return SetupSwitchingLinePopup