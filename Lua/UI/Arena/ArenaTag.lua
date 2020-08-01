--author: 	Amu
--time:		2020-06-19 14:48:59

local ArenaModel = import("Model/ArenaModel")

local ArenaTag = UIMgr:NewUI("ArenaTag")

local PanelType = {}
PanelType.Challenge = 1
PanelType.Reward    = 2
PanelType.Rank      = 3

local callback

function ArenaTag:OnInit()
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnReturn")

    self._textName = self._view:GetChild("textName")

    self._ctrView = self._view:GetController("c1")

    self.pageInfo = {}
    self.pageInfo[PanelType.Challenge] = {
        viewId = 0,
        page = nil,
        pageUrl = {
            main = "Arena",
            sub  = "ArenaChallenge"
        }
    }
    self.pageInfo[PanelType.Reward] = {
        viewId = 1,
        page = nil,
        pageUrl = {
            main = "Arena",
            sub  = "ArenaReward"
        }
    }
    self.pageInfo[PanelType.Rank] = {
        viewId = 2,
        page = nil,
        pageUrl = {
            main = "Arena",
            sub  = "ArenaRank"
        }
    }

    self:InitEvent()
end

function ArenaTag:InitEvent( )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnTagChallenge.onClick,function()
        if ArenaModel._BattleEndAt - Tool.Time() <= 0  then
            TipUtil.TipById(50348)
            self._ctrView.selectedIndex = self.pageInfo[self.type].viewId
        else
            self:ChangePage(PanelType.Challenge)
        end
    end)

    self:AddListener(self._btnTagReward.onClick,function()
        if ArenaModel._BattleEndAt - Tool.Time() <= 0 and ArenaModel._rankNum < 0 then
            TipUtil.TipById(50349)
            self._ctrView.selectedIndex = self.pageInfo[self.type].viewId
        else
            self:ChangePage(PanelType.Reward)
        end
    end)

    self:AddListener(self._btnTagRank.onClick,function()
        self:ChangePage(PanelType.Rank)
    end)

    self:AddEvent(ARENA_CHALLENGE_EVNET.ArenaChallengeEnd, function()
        if ArenaModel._BattleEndAt - Tool.Time() > 0 then
            self:ChangePage(PanelType.Challenge)
        else
            UIMgr:Close("ArenaViewPlayerGame")
            UIMgr:Close("ArenaDispatchTroops")
            UIMgr:Close("ArenaBattle")
            UIMgr:Close("ConfirmPopupText")
            if ArenaModel._rankNum > 0 then
                self:ChangePage(PanelType.Reward)
            else
                self:ChangePage(PanelType.Rank)
            end
        end
    end)

    self:AddEvent(ARENA_CHALLENGE_EVNET.ArenaEnd, function()
        UIMgr:Close("ArenaViewPlayerGame")
        UIMgr:Close("ArenaDispatchTroops")
        UIMgr:Close("ArenaBattle")
        UIMgr:Close("ConfirmPopupText")
        self:Close()
    end)

    callback = function()
        if not ArenaModel._BattleEndAt then
            return
        end
        local time = ArenaModel._BattleEndAt - Tool.Time()
        if time < 0 then
            Event.Broadcast(ARENA_CHALLENGE_EVNET.ArenaChallengeEnd)
            self:UnSchedule(callback)
            self._scheduler = false
            return
        end
    end
end

function ArenaTag:OnOpen()
    ArenaModel.GetArenaBattlePageInfo(function()
        if ArenaModel._BattleEndAt - Tool.Time() > 0 then
            self:ChangePage(PanelType.Challenge)
        else
            if ArenaModel._rankNum > 0 then
                self:ChangePage(PanelType.Reward)
            else
                self:ChangePage(PanelType.Rank)
            end
        end
        self:StartCountDown()
    end)
end

function ArenaTag:ChangePage(type)
    if self.type == type then
        return
    end
    if self.type and self.pageInfo[self.type].page then
        self.pageInfo[self.type].page.visible = false
    end

    self.type = type
    self._ctrView.selectedIndex = self.pageInfo[self.type].viewId

    if not self.pageInfo[self.type].page then
        local page = UIMgr:CreateObject(self.pageInfo[self.type].pageUrl.main, self.pageInfo[self.type].pageUrl.sub)
        page:InitData()
        page:MakeFullScreen()
        self._view:AddChild(page)
        self.pageInfo[self.type].page = page
    else
        if self.pageInfo[self.type].page.RefreshData then
            self.pageInfo[self.type].page:RefreshData()
        end
    end

    self.pageInfo[self.type].page.visible = true
end

function ArenaTag:StartCountDown( )
    if not self._scheduler then
        callback()
        self:Schedule(callback, 1)
        self._scheduler = true
    end
end

function ArenaTag:EndCountDown( )
    self:UnSchedule(callback)
    self._scheduler = false
end

function ArenaTag:Close( )
    UIMgr:Close("ArenaTag")
end

function ArenaTag:OnClsoe()
    for _,v in ipairs(self.pageInfo)do
        if v.page and v.page.OnClsoe then
            v.page:OnClsoe()
        end
    end
    self:EndCountDown()
end

return ArenaTag