--author: 	Amu,maxiaolong
--time:		2019-12-03 11:28:14

local ActivityCenterCalendarPopup = UIMgr:NewUI("ActivityCenterCalendarPopup")

function ActivityCenterCalendarPopup:OnInit()
    self._view = self.Controller.contentPane

    self._bgMask = self._view:GetChild("bgMask")
    self._btnClose = self._view:GetChild("btnClose")
    self._title = self._view:GetChild("title")
    self._dayList = self._view:GetChild("liebiao2")
    self._activityList = self._view:GetChild("liebiao1")
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_CALENDAR")
    self.index = 10000

    self:InitEvent()
end

function ActivityCenterCalendarPopup:InitEvent()
    self:AddListener(self._bgMask.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )

    self._dayList.itemRenderer = function(index, item)
        if not index then
            return
        end
        item:SetData(tonumber(self.week) + index, self.monthDays[index + 1])
    end

    self:AddListener(self._dayList.scrollPane.onScroll,
        function()
            Event.Broadcast(_G.ActivityModel.EVENT_DAY_SCROLL,  self._dayList.scrollPane.percX)
        end
    )

    self:AddEvent(
        _G.ActivityModel.EVENT_DAY_SCROLL,
        function(value)
            if value ~= self._dayList.scrollPane.percX then
                self._dayList.scrollPane.percX = value
            end
        end
    )

    self._activityList.itemRenderer = function(index, item)
        if not index then
            return
        end
        item:SetData(self.activityInfo[index + 1], index)
    end

    self:AddEvent(
        EventDefines.RefreshActivityUI,
        function()
            if not self.OnHide then
                self:RefereshUI()
            end
        end
    )
end

function ActivityCenterCalendarPopup:DoOpenAnim(...)
    self:OnOpen(...)
end

function ActivityCenterCalendarPopup:OnOpen()
    self:RefereshUI()
    Event.Broadcast(ACTIVITY_DAY_COUNTDOWN_EVENT.Start)
end

function ActivityCenterCalendarPopup:RefereshUI()
    self.activityInfo = _G.ActivityModel.GetActivityData(_G.ActivityModel.TypeModel.Calendar)
    self:RefreshData()
    self:RefreshListView()
end

function ActivityCenterCalendarPopup:RefreshListView()
    self._dayList.numItems = _G.ActivityModel._SHOWDAY
    self._activityList.numItems = #self.activityInfo
end

function ActivityCenterCalendarPopup:CheakActivityData(info, activityData)
    if info.Open then
        return true
    else
        return true
    end
end

function ActivityCenterCalendarPopup:RefreshData()
    self.week = os.date("%w", Tool.Time())
    local tempMonthDay = {}
    for i = 0, 9 do
        self.nowTime = os.date("*t", Tool.Time())
        self.nowTime.day = self.nowTime.day + i
        local nextDay = os.date("*t", os.time(self.nowTime))
        table.insert(tempMonthDay, {month = nextDay.month, day = nextDay.day})
    end
    self.monthDays = tempMonthDay
end

function ActivityCenterCalendarPopup:Close()
    UIMgr:Close("ActivityCenterCalendarPopup")
end

function ActivityCenterCalendarPopup:OnClose()
    Event.Broadcast(ACTIVITY_DAY_COUNTDOWN_EVENT.End)
end

return ActivityCenterCalendarPopup
