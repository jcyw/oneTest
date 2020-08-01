--author: 	Amu
--time:		2020-06-19 14:47:33

local callback


local ArenaActivity = UIMgr:NewUI("ArenaActivity")

function ArenaActivity:OnInit()
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnReturn")

    self._textTime = self._view:GetChild("textTime")
    self._btnArena = self._view:GetChild("btnArena")

    self._listView = self._view:GetChild("liebiao")
    self._listView.numItems = 1

    self:InitEvent()
    self._banner.icon = UITool.GetIcon(GlobalBanner.ArenaBanner)
end

function ArenaActivity:InitEvent( )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnHelp.onClick,function()
        Sdk.AiHelpShowSingleFAQ(ConfigMgr.GetItem("configWindowhelps", 2095).article_id)
    end)

    self:AddListener(self._btnArena.onClick,function()
        if not self._isOpen then
            TipUtil.TipById(50317)
            return
        end
        if BuildModel.GetCenterLevel() >= 10 then
            UIMgr:Open("ArenaTag", self._info)
        else
            TipUtil.TipById(50339)
        end
    end)

    callback = function()
        if not self._endTime then
            return
        end
        local time = 0
        if self._isOpen then
            time = self._endTime - Tool.Time()
        else
            time = self._startAt - Tool.Time()
        end
        if time <= 0 then
            self:UnSchedule(callback)
            self._scheduler = false
            self:Close()
            Event.Broadcast(ARENA_CHALLENGE_EVNET.ArenaEnd)
            return
        end
        if not self._isOpen then
            self._textTime.text = StringUtil.GetI18n("configI18nCommons", "UNION_ARMY_BEGIN_TIME", {time = TimeUtil.SecondToDHMS(time)})
        else
            self._textTime.text = StringUtil.GetI18n("configI18nCommons", "Ui_Single_Timesup", {time = TimeUtil.SecondToDHMS(time)})
        end
    end
end

function ArenaActivity:OnOpen(info)
    self._info = info
    self._isOpen = info.Open
    self._endTime = info.EndAt
    self._startAt = info.StartAt

    self:StartCountDown()
end

function ArenaActivity:StartCountDown( )
    if not self._scheduler then
        callback()
        self:Schedule(callback, 1)
        self._scheduler = true
    end
end

function ArenaActivity:EndCountDown( )
    self:UnSchedule(callback)
    self._scheduler = false
end


function ArenaActivity:Close()
    UIMgr:Close("ArenaActivity")
end

function ArenaActivity:OnClose()
    self:EndCountDown()
end


return ArenaActivity