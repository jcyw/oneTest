--author: 	Amu
--time:		2020-06-24 24:02:57

local ItemAllianceInvitation = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemAllianceInvitation", ItemAllianceInvitation)

function ItemAllianceInvitation:ctor()
    self._btnRefuse = self:GetChild("btnRefuse")
    self._btnAccept = self:GetChild("btnAccept")
    self._btnSend = self:GetChild("btnSend")
    self._btnSee = self:GetChild("btnSee")

    self._iconHead = self:GetChild("iconHead")


    self._textTagName = self:GetChild("textTagName")
    self.playerName = self:GetChild("textPlayerName")
    self.allianceName_1 = self:GetChild("textAllianceName")
    self.allianceName_2 = self:GetChild("textAlliance")
    self.PresidentName = self:GetChild("textPositionName")
    self.powerLab = self:GetChild("textBattleNum")
    self.memberLab = self:GetChild("textMemberNum")
    self._iconFlag = self:GetChild("iconFlag")
    self.languageLab = self:GetChild("textLanguage")
    
    self._textContent = self:GetChild("textContent")

    self._bar = self:GetChild("itemDownBar")

    self._textTime = self:GetChild("textTime")

    self:InitEvent()
end

function ItemAllianceInvitation:InitEvent()
    self:AddListener(self._btnRefuse.onClick,function()--拒绝
        if self._info.Status == MAIL_INVITE_STATUS.Accept then
            TipUtil.TipById(50218)
            return
        elseif self._info.Status == MAIL_INVITE_STATUS.Refused then
            TipUtil.TipById(50219)
            return
        end
        Net.Alliances.RefuseInvitation(self.report.Id, function()
            --TODO
            self._info.Status = MAIL_INVITE_STATUS.Refused
            MailModel:UpdateStatus(MAIL_TYPE.Alliance , self._info.Number, MAIL_INVITE_STATUS.Refused)
            self._panel:RefreshData()
            Net.Mails.SetStatus(self._info.Uuid, MAIL_INVITE_STATUS.Refused, function()
                MailModel:UpdateDataByGid(self._info.Number, JSON.encode(self._info))
            end)
            self._btnAccept.enabled = false
            self._btnRefuse.enabled = false
        end)
    end)

    self:AddListener(self._btnAccept.onClick,function()--接受
        if self._info.Status == MAIL_INVITE_STATUS.Accept then
            TipUtil.TipById(50218)
            return
        elseif self._info.Status == MAIL_INVITE_STATUS.Refused then
            TipUtil.TipById(50219)
            return
        end
        Net.Alliances.AcceptInvitation(self.report.Id, function()
            --TODO
            self._info.Status = MAIL_INVITE_STATUS.Accept
            MailModel:UpdateStatus(MAIL_TYPE.Alliance , self._info.Number, MAIL_INVITE_STATUS.Accept)
            self._panel:RefreshData()
            Net.Mails.SetStatus(self._info.Uuid, MAIL_INVITE_STATUS.Accept, function()
                MailModel:UpdateDataByGid(self._info.Number, JSON.encode(self._info))
            end)
            self._btnAccept.enabled = false
            self._btnRefuse.enabled = false
        end)
    end)

    self:AddListener(self._btnSend.onClick,function()--发送信件
        local info = {
            subject = self.report.InvitorId,
            subCategory = MAIL_SUBTYPE.subPersonalMsg,
            Receiver =  self.report.President,
        }
        UIMgr:Open("Mail_PersonalNews", nil, nil, nil, nil, MAIL_CHATHOME_TYPE.TempChat, info)
    end)

    self:AddListener(self._btnSee.onClick,function()--查看帮会
        UIMgr:Open("UnionViewData", self.report.Id)
    end)
end

function ItemAllianceInvitation:SetData(info, panel)
    self._info = info
    self._panel = panel
    self.report = JSON.decode(info.Report)
    local name = "("..self.report.Name..")"..self.report.FullName
    self._iconHead:SetAvatar(self.report)
    self.playerName.text = info.Sender
    self.allianceName_1.text = name
    self.allianceName_2.text = name
    self.PresidentName.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Position_Boss")..":"..self.report.President
    self.powerLab.text = math.ceil(self.report.Power)
    self.memberLab.text = math.ceil(self.report.Member).."/".. math.ceil(self.report.MemberLimit)
    self._textTagName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_InvitationJoin", {alliance_name = self.report.FullName})
    self._textContent.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_NewInvitationJoin_Details", {alliance_name = self.report.FullName})
    
    self._textTime.text = TimeUtil:GetTimesAgo(info.CreatedAt)

    if Model.Player.AllianceId ~= "" then
        self._btnAccept.enabled = false
        self._btnRefuse.enabled = false
    else
        self._btnAccept.enabled = true
        self._btnRefuse.enabled = true
    end

    if self._info.Status == MAIL_INVITE_STATUS.Accept or self._info.Status == MAIL_INVITE_STATUS.Refused then
        self._btnAccept.enabled = false
        self._btnRefuse.enabled = false
    end

    local config = ConfigMgr.GetItem('configLanguages', self.report.Language)
    if config then
        self.languageLab.text = config.language
    end
    local config = ConfigMgr.GetItem('configFlags', math.ceil(self.report.Flag))
    if config then
        self._iconFlag.icon = UITool.GetIcon(config.icon)
    end
end

return ItemAllianceInvitation