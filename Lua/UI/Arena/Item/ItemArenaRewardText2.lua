--author: 	Amu
--time:		2020-06-30 22:35:51

local ItemArenaRewardText2 = fgui.extension_class(GComponent)
fgui.register_extension("ui://Arena/itemArenaRewardText2", ItemArenaRewardText2)


function ItemArenaRewardText2:ctor()
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")
    self._btnText = self:GetChild("titleView")

    self:InitEvent()
end

function ItemArenaRewardText2:InitEvent()
    self:AddListener(self._btnText.onClick,function()
        Net.Mails.RequestMailData(Auth.WorldData.accountId, self.reportId,function(mailmsg)
            UIMgr:Open("MailWarReport", MAIL_TYPE.MailSubTypeSports, 0, mailmsg.MailData, nil, MAIL_SHOWTYPE.Shere, Auth.WorldData.accountId)
        end)
    end)
end

function ItemArenaRewardText2:SetData(info)
    self.reportId = info.ReportMailId
    local name = TextUtil.GetFormatPlayName(info.AttackerOrDefender.AllianceName, info.AttackerOrDefender.Name)
    if info.RecordType == 1 then  --挑战成功
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS18", 
            {time = TimeUtil.SecondToDHMS(Tool.Time() - info.CreateAt), player_name = name})
    elseif info.RecordType == 2 then--挑战失败
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS17",
            {time = TimeUtil.SecondToDHMS(Tool.Time() - info.CreateAt), player_name = name})
    elseif info.RecordType == 3 then--防守成功
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS23",
            {time = TimeUtil.SecondToDHMS(Tool.Time() - info.CreateAt), player_name = name})
    elseif info.RecordType == 4 then--防守失败
        local numText = info.Rank > 0 and info.Rank or StringUtil.GetI18n(I18nType.Commmon, "Button_Commander_UnRank")

        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS22",
            {time = TimeUtil.SecondToDHMS(Tool.Time() - info.CreateAt), player_name = name, num = numText})
    end
end

return ItemArenaRewardText2