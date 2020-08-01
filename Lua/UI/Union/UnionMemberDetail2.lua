--author: 	Amu
--time:		2019-08-23 15:37:31

local CommonModel = import('Model/CommonModel')

local UnionMemberDetail2 = UIMgr:NewUI("UnionMemberDetail2")

function UnionMemberDetail2:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._iconHero = self._view:GetChild("iconHero")

    self:InitEvent()
end

function UnionMemberDetail2:InitEvent( )
    self:AddListener(self._btnMask.onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnPlayInfo.onClick,function()
        TurnModel.PlayerDetails(self.info.UserId)
        self:Close()
    end)

    self:AddListener(self._btnInvite.onClick,function()
        if Model.Player.AlliancePos >= ALLIANCEPOS.R4 then
            UnionModel.GetUnionInfo(function(data)
                if data.Member >= data.MemberLimit then
                    TipUtil.TipById(50316)
                else
                    Net.Alliances.InvitePlayer(self.info.UserId, function()
                        TipUtil.TipById(50215)
                        self._panel:DelPlayerInfo(self.info.UserId)
                    end)
                end
            end)
            self:Close()
        else
            local data = {
                content = StringUtil.GetI18n("configI18nCommons", "Ui_AllianceClass_Tips"),
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    end)

    self:AddListener(self._btnSendMsg.onClick,function()
        local info = {}
        info.subject = self.info.UserId
        info.subCategory = MAIL_SUBTYPE.subPersonalMsg
        info.Receiver = self.info.Name
        UIMgr:Open("Mail_PersonalNews", nil, nil, nil, nil, MAIL_CHATHOME_TYPE.TempChat, info)
        self:Close()
    end)
end

function UnionMemberDetail2:OnOpen(info, panel)
    self.info = info
    self._panel = panel
    self._name.text = info.Name
    local avatarConf = ConfigMgr.GetList("configAvatars")[info.Bust]
    self._iconHero.icon = UITool.GetIcon(avatarConf.bust)
    -- CommonModel.SetUserAvatar(self._icon, info.Avatar, info.UserId)
    self._icon:SetAvatar(info, nil, info.UserId)
end

function UnionMemberDetail2:Close( )
    UIMgr:Close("UnionMemberDetail2")
end

return UnionMemberDetail2