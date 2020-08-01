--[[
    Author: songzeming
    Function: 其他玩家信息
]]
local PlayerInfoOther = UIMgr:NewUI("PlayerInfo/PlayerInfoOther")

local UnionModel = import("Model/UnionModel")
import("UI/PlayerDetail/PlayerInfo/ItemPlayerAttributeList")

function PlayerInfoOther:OnInit()
    self:AddListener(self._btnUnion.onClick,
        function()
            self:OnBtnUnionClick()
        end
    )
    self:AddListener(self._btnSendLetter.onClick,
        function()
            self:OnBtnSendLetterClick()
        end
    )
    self:AddListener(self._btnComplaint.onClick,
        function()
            self:OnBtnComplaintClick()
        end
    )
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("PlayerInfo/PlayerInfoOther")
        end
    )
    self._btnHeadReplace.visible = false

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.PlayerInfo)
end

function PlayerInfoOther:OnOpen(playerId, info)
    self:ShowPlayerInfo(playerId, info)
    self:ShowAttributeInfo()
end

--显示玩家信息
function PlayerInfoOther:ShowPlayerInfo(playerId, info)
    self.playerId = playerId
    self.info = info
    -- CommonModel.SetUserAvatar(self._icon, info.Avatar, playerId)
    self._icon:SetAvatar(info, nil, self.playerId)
    if info.AllianceName and info.AllianceName ~= "" then
        --玩家有联盟 可查看对方联盟
        self._name.text = "(" .. info.AllianceName .. ")" .. info.Name
        self._btnUnion.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance")
        self._btnUnion.enabled = true
    else
        --玩家没有联盟
        self._name.text = info.Name
        if UnionModel.CheckJoinUnion() then
            --邀请玩家入盟
            self._btnUnion.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Invitation_Join")
            self._btnUnion.enabled = UnionModel.CheckPermission(GlobalAlliance.APInviteJoin)
        else
            self._btnUnion.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance")
            self._btnUnion.enabled = false
        end
    end
    TextUtil.TextWidthAutoSize(self._name,334,1,3)
    self._flag.icon = UITool.GetIcon(ConfigMgr.GetItem("configFlags", info.Flag).icon)
    if info.Declaration == "" then
        self._textSpeak.text = StringUtil.GetI18n(I18nType.Commmon, "Button_CommanderTips_Default")
    else
        self._textSpeak.text = info.Declaration
    end
    self._textSpeak.autoSize = 1
    TextUtil.TextWidthAutoSize(self._textSpeak,490,1,2)
    if self._textSpeak.height >= 83 then
        TextUtil.TextHightAutoSize(self._textSpeak,83,2,3)
    end
    self._city.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Commander_Server") .. ": " .. info.Server
    --self._city.text = "暂无数据" --TODO
    self._level.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Level") .. ": " .. UITool.GetTextColor(GlobalColor.White, info.HeroLevel)
    self._power.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Power") .. ": " .. UITool.GetTextColor(GlobalColor.White, Tool.FormatNumberThousands(info.Power))
    self._kill.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Destroy_Number") .. ": " .. UITool.GetTextColor(GlobalColor.White, info.Kills)
end

--点击邀请入盟/查看联盟
function PlayerInfoOther:OnBtnUnionClick()
    if self.info.AllianceId and self.info.AllianceId ~= "" then
        UIMgr:Open("UnionViewData", self.info.AllianceId)
    else
        Net.Alliances.InvitePlayer(
            self.playerId,
            function()
                TipUtil.TipById(50215)
            end
        )
    end
end

--点击发送信件
function PlayerInfoOther:OnBtnSendLetterClick()
    local info = {}
    info.subject = self.playerId
    info.subCategory = MAIL_SUBTYPE.subPersonalMsg
    info.Receiver = self.info.Name
    UIMgr:Open("Mail_PersonalNews", nil, nil, nil, nil, MAIL_CHATHOME_TYPE.TempChat, info)
end

--点击举报玩家
function PlayerInfoOther:OnBtnComplaintClick()
    UIMgr:Open("PlayerInfo/PlayerComplaintBox", self.playerId, self.info.Name)
end

--显示属性信息
function PlayerInfoOther:ShowAttributeInfo()
    self._listAtt:RemoveChildrenToPool()
    Net.UserInfo.GetUserDetailedBattleInfo(
        self.playerId,
        function(rsp)
            local title = StringUtil.GetI18n(I18nType.Commmon, "Ui_PlayerAttrnuteType_102")
            local item = self._listAtt:AddItemFromPool()
            item:InitOther(title, rsp)

            self._listAtt:EnsureBoundsCorrect()
            self._listAtt.scrollPane.touchEffect = self._listAtt.scrollPane.contentHeight > self._listAtt.height
        end
    )
end

return PlayerInfoOther
