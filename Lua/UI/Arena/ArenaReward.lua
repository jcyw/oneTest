--author: 	Amu
--time:		2020-06-19 14:48:50

local ArenaModel = import("Model/ArenaModel")

local ArenaReward = fgui.extension_class(GComponent)
fgui.register_extension("ui://Arena/ArenaReward", ArenaReward)

local callback


function ArenaReward:ctor()

    self._headHero = self:GetChild("n22")
    self._textName = self:GetChild("textName")
    self._textWinningNum = self:GetChild("textWinningNum")

    self._btnView = self:GetChild("btnView")
    self._btnReceive = self:GetChild("btnReceive")

    self._textView = self:GetChild("textView")
    self._textReceive = self:GetChild("textReceive")

    self._textRank = self:GetChild("textRank")

    self._worldInfoListView = self:GetChild("liebiao")
    self._selfInfoListView = self:GetChild("liebiao2")

    self:InitEvent()
end

function ArenaReward:InitEvent(  )
    self:AddListener(self._btnHelp.onClick,function()
        local data = {
            title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
            info = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS14")
        }
        UIMgr:Open("ConfirmPopupTextCentered", data)
    end)

    self:AddListener(self._btnView.onClick,function()
        ArenaModel.ArenaPryTroopInfo(-1, function(info)
            UIMgr:Open("ArenaViewPlayerGame", info)
        end)
    end)

    self:AddListener(self._btnReceive.onClick,function()
        if ArenaModel._AwardAt - Tool.Time() > 0 then
            TipUtil.TipById(50346)
        else
            ArenaModel.ArenaGetAwards(function(msg)
                UITool.ShowReward(msg.Rewards)
                self._textReceive.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_39")
            end)
        end
    end)

    -- Attacker:table: 00000002ACC808E0
    -- Defender:table: 00000002ACC804A0
    -- Times:14
    -- RecordType:3

    self._worldInfoListView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        local info = ArenaModel._WinStreakOrTerminateList[index+1]

        if info.RecordType == 1 or info.RecordType == 3 then  --连胜  (挑战成功  防守成功)
            local name = TextUtil.GetFormatPlayName(info.Attacker.AllianceName, info.Attacker.Name)
            item:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS15", 
                {player_name = name, num = info.Times})
        elseif info.RecordType == 2 then --终结  挑战失败
            local attackName = TextUtil.GetFormatPlayName(info.Attacker.AllianceName, info.Attacker.Name)
            local defendName = TextUtil.GetFormatPlayName(info.Defender.AllianceName, info.Defender.Name)

            item:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS16",
                {player_name = attackName, enemy_name = defendName, num = info.Times})
        elseif info.RecordType == 4 then  --终结 防守失败
            local attackName = TextUtil.GetFormatPlayName(info.Attacker.AllianceName, info.Attacker.Name)
            local defendName = TextUtil.GetFormatPlayName(info.Defender.AllianceName, info.Defender.Name)

            item:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS16",
                {enemy_name = attackName, player_name = defendName, num = info.Times})
        end
    end

    -- AttackerOrDefender:table: 00000002A25A0670
        -- AllianceId:""
        -- AllianceName:""
        -- AllianceShort:""
        -- Avatar:"1"
        -- Name:"arenarobot_name"
        -- PlayerId:"robot_247"
    -- CreateAt:1593433039
    -- IsWin:false
    -- RecordType:2
    -- ReportMailId:"brstnjroo3sjl8d7l0c0"
    self._selfInfoListView.itemRenderer = function(index, item)
        if not index then 
            return
        end

        item:SetData(ArenaModel._BattleResultList[index+1])
    end

    callback = function()
        if not ArenaModel._AwardAt then
            return
        end
        local time = ArenaModel._AwardAt - Tool.Time()
        if time <= 0 then
            self:UnSchedule(callback)
            self._scheduler = false
            if ArenaModel._GotAward then
                self._textReceive.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_39")
            else
                self._textReceive.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_NO_Get")
            end
            return
        end
        self._textReceive.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Time_Later_Recive", {time = TimeUtil.SecondToDHMS(time)})
    end
end

function ArenaReward:InitData()
    self:RefreshData()
end

function ArenaReward:RefreshData(  )
    ArenaModel.ArenaAwardPageInfo(function()
        -- CommonModel.SetUserAvatar(self._headHero, ArenaModel._PlayerRankInfo.Avatar)
        self._headHero:SetAvatar(ArenaModel._PlayerRankInfo)
        local str = ""
        if ArenaModel._PlayerRankInfo.AllianceName ~= "" then
            str = str .. string.format("\\[%s] ", ArenaModel._PlayerRankInfo.AllianceName)
        end
        self._textName.text = str .. ArenaModel._PlayerRankInfo.PlayerName

        self._textWinningNum.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS11", {num = ArenaModel._WinStreakTimes})
        self._textView.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS13", {num = ArenaModel._TroopInfoPriedTimes})
        self._textRank.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS1") .. ArenaModel._rank
        self:StartCountDown()
        self:RefreshListView()
    end)
end

function ArenaReward:RefreshListView(  )
    self._worldInfoListView.numItems = #ArenaModel._WinStreakOrTerminateList
    self._selfInfoListView.numItems = #ArenaModel._BattleResultList 
end

function ArenaReward:StartCountDown( )
    if not self._scheduler then
        callback()
        self:Schedule(callback, 1)
        self._scheduler = true
    end
end

function ArenaReward:EndCountDown( )
    self:UnSchedule(callback)
    self._scheduler = false
end

function ArenaReward:OnClsoe()
    self:EndCountDown()
end

return ArenaReward