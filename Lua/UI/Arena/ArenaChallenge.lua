--author: 	Amu
--time:		2020-06-19 14:48:26

local ArenaModel = import("Model/ArenaModel")

local callback

local ArenaChallenge = fgui.extension_class(GComponent)
fgui.register_extension("ui://Arena/ArenaChallenge", ArenaChallenge)


function ArenaChallenge:ctor()
    self._btnHelp = self:GetChild("btnHelp")

    self._rankText = self:GetChild("text1")
    self._rankDec = self:GetChild("text2")
    self._freeChallengeTimes = self:GetChild("text3")
    self._freeReadTimes = self:GetChild("text4")

    self._rankNum = self:GetChild("textNum1")
    self._freeChallengeNum = self:GetChild("textNum2")
    self._freeReadNum = self:GetChild("textNum3")

    self._textTime = self:GetChild("textTime")
    self._btnLuckDraw = self:GetChild("btnLuckDraw")

    self._btnFree = self:GetChild("btnFree")
    self._btnRefresh = self:GetChild("n40")

    self._btnFreeText = self._btnFree:GetChild("title")
    self._btnRefreshText = self._btnRefresh:GetChild("title")
    self._btnRefreshNum = self._btnRefresh:GetChild("text")

    self._btnFreeText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS8")
    self._btnRefreshText.text = StringUtil.GetI18n(I18nType.Commmon, "Button_Translate")

    self._listView = self:GetChild("liebiao")

    self._ctrView = self:GetController("c1")
    self._ctrView2 = self:GetController("c2")

    self:InitEvent()
end

function ArenaChallenge:InitEvent(  )
    self:AddListener(self._btnFree.onClick,function()
        if ArenaModel._RefreshFreeTimes > 0 then
            ArenaModel.RefreshBattleCandidate(function()
                self:RefreshListView()
                self:RefreshPanel()
            end)
        end
    end)

    self:AddListener(self._btnRefresh.onClick,function()
        local data = {
            content = StringUtil.GetI18n("configI18nCommons", "UI_ARENA_BATTLE_TIPS28", {num = self._btnRefreshNum.text}),
            gold = tonumber(self._btnRefreshNum.text),
            sureCallback = function()
                ArenaModel.RefreshBattleCandidate(function()
                    self:RefreshListView()
                    self:RefreshPanel()
                end)
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end

        item:SetData(ArenaModel._Candidates[index+1])
    end

    callback = function()
        if not ArenaModel._endTime then
            return
        end
        local time = ArenaModel._endTime - Tool.Time()
        if time < 0 then
            self:UnSchedule(callback)
            -- self._ctrView2.selectedIndex = 1
            self._scheduler = false
            if math.abs(ArenaModel._endTime - ArenaModel._BattleEndAt) > 100 then
                ArenaModel.GetArenaBattlePageInfo(function()
                    self:InitData()
                end)
            end
            UIMgr:Close("ArenaViewPlayerGame")
            UIMgr:Close("ArenaDispatchTroops")
            return
        end
        self._textTime.text = TimeUtil.SecondToDHMS(time)
    end

    self:AddEvent(ARENA_CHALLENGE_EVNET.WinRefresh, function()
        ArenaModel.GetArenaBattlePageInfo(function()
            self:InitData()
        end)
    end)

    self:AddEvent(ARENA_CHALLENGE_EVNET.RefreshTimes, function()
        self:RefreshPanel()
    end)
end

function ArenaChallenge:InitData()
    self:RefreshListView()
    self:RefreshPanel()
    self:StartCountDown()
end

function ArenaChallenge:RefreshPanel()
    self._rankText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS1")
    self._rankDec.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS3")
    self._freeChallengeTimes.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS2")
    self._freeReadTimes.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS4")

    local a = self._rankText.displayObject.width
    self._rankNum.x = self._rankText.x + self._rankText.displayObject.width

    self._rankNum.text = ArenaModel._rank
    self._freeChallengeNum.text = ArenaModel._DayBattleiFreeTimes
    self._freeReadNum.text = ArenaModel._WeekPriedFreeTimes
    
    if ArenaModel._RefreshFreeTimes > 0 then
        self._ctrView.selectedIndex = 0
    else
        local len = #Global.Arena_refresh
        self._ctrView.selectedIndex = 1
        if ArenaModel._RefreshBoughtTimes+1 >= len then
            self._btnRefreshNum.text = Global.Arena_refresh[len]
        else
            self._btnRefreshNum.text = Global.Arena_refresh[ArenaModel._RefreshBoughtTimes+1]
        end
    end
    
end

function ArenaChallenge:StartCountDown( )
    if not self._scheduler then
        -- if ArenaModel._endTime - Tool.Time() > 0 then
        --     self._ctrView2.selectedIndex = 0
        -- else
        --     self._ctrView2.selectedIndex = 1
        -- end
        callback()
        self:Schedule(callback, 1)
        self._scheduler = true
    end
end

function ArenaChallenge:EndCountDown( )
    self:UnSchedule(callback)
    self._scheduler = false
end

function ArenaChallenge:RefreshListView()
    self._listView.numItems = #ArenaModel._Candidates
    AnimationLayer.PlayListLeftToRightAnim(AnimationType.UILeftToRight, self._listView, 0.2, self)
end

function ArenaChallenge:OnClsoe()
    self:EndCountDown()
end

return ArenaChallenge