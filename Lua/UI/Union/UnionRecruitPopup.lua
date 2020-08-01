--author: 	Amu
--time:		2019-07-11 16:29:19

local UnionRecruitPopup = UIMgr:NewUI("UnionRecruitPopup")

function UnionRecruitPopup:OnInit()
    -- body
    self._view = self.Controller.contentPane

    self._bgMask = self._view:GetChild("bgMask")

    self._textInput = self._view:GetChild("textInput")

    self._limitText = self._view:GetChild("text")

    self._btnEdit = self._view:GetChild("btnEdit")
    self._btnSave = self._view:GetChild("btnSave")
    self._btnGo = self._view:GetChild("btnGo")
    self._textIconNum = self._btnGo:GetChild("text")

    self:InitEvent()
end

function UnionRecruitPopup:InitEvent( )
    self:AddListener(self._btnClose.onClick,function()--返回
        self:Close()
    end)

    self:AddListener(self._bgMask.onClick,function()--返回
        self:Close()
    end)

    self:AddListener(self._btnEdit.onClick,function()--编辑
        if self._textInput.enabled then
            self._textInput.enabled = false
            self._btnSave.enabled = false
        else
            self._textInput.enabled = true
            self._btnSave.enabled = true
        end
    end)

    self:AddListener(self._btnSave.onClick,function()--保存
        PlayerDataModel:SetData(PlayerDataEnum.UnionInviteMsg, self._textInput.text)
        self:RefreshText()
        TipUtil.TipById(50245)
    end)

    self:AddListener(self._btnGo.onClick,function()--发布
        Net.Alliances.Wanted(Model.Player.AllianceId, function()
            local params = {
                AllianceId = Model.Player.AllianceId,
                AllianceName = Model.Player.AllianceName,
                str = self._textInput.text
            }
            Net.Chat.SendChat("World", Model.Account.accountId, "", WORLD_CHAT_TYEP.Invite, JSON.encode(params), function()
                TipUtil.TipById(50246)
                self:Close()
            end)
        end)
    end)
end

function UnionRecruitPopup:OnOpen()
    Net.Alliances.GetWantedTimes(Model.Player.AllianceId, function(msg)
        self.times = msg.Count
        self:RefreshGold(msg.Count)
    end)
    self._textInput.enabled = false
    self._btnSave.enabled = false

    self:RefreshText()
end

function UnionRecruitPopup:RefreshText()
    local msg = PlayerDataModel:GetData(PlayerDataEnum.UnionInviteMsg)

    if msg and msg ~= "" then
        self._textInput.text = msg
    else
        local str = {}
        str["alliance_name"] = Model.Player.AllianceName
        self._textInput.text = StringUtil.GetI18n(I18nType.Commmon, "world_chat_"..WORLD_CHAT_TYEP.Invite, str)
    end
end

function UnionRecruitPopup:RefreshGold(times)
    local goldList = ConfigMgr.GetVar("AllianceRecprice")
    if (times+1) >= #goldList then
        self._textIconNum.text = goldList[#goldList]
    else
        self._textIconNum.text = goldList[times+1]
    end
end

function UnionRecruitPopup:Close( )
    UIMgr:Close("UnionRecruitPopup")
end

return UnionRecruitPopup