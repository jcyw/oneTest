--author: 	Amu
--time:		2019-12-03 11:56:19

local ItemActivityCenterCalendar3 = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemActivityCenterCalendar3", ItemActivityCenterCalendar3)

function ItemActivityCenterCalendar3:ctor()
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")
    self._timeText = self:GetChild("_amount")

    self._ctrView = self:GetController("c1")

    self:InitEvent()
end

function ItemActivityCenterCalendar3:InitEvent()
    self.callback = function()
        if not self._endTime then
            return
        end
        local time = self._endTime - Tool.Time()
        if time <= 0 then
            self:UnSchedule(self.callback)
            self._scheduler = false
            --[[if UIMgr:GetUIOpen("ActivityCenterCalendarPopup") then
                UIMgr:Close("ActivityCenterCalendarPopup")
                Event.Broadcast(EventDefines.RefreshActivityUI)
            end]]--
            return
        end
        self._timeText.text = TimeUtil.SecondToDHMS(time)
    end

    self.callback_waiting = function()
        if not self._startTime then
            return
        end
        local time = self._startTime - Tool.Time()
        if time <= 0 then
            self:UnSchedule(self.callback_waiting)
            self._schedule_waiting = false
            return
        end
        self._timeText.text = TimeUtil.SecondToDHMS(time)
    end

    self:AddEvent(
        ACTIVITY_DAY_COUNTDOWN_EVENT.Start,
        function()
            self:UpdateContent()
        end
    )

    self:AddEvent(
        ACTIVITY_DAY_COUNTDOWN_EVENT.End,
        function()
            self:UpdateContent()
        end
    )
end

function ItemActivityCenterCalendar3:UpdateContent()
    self._schedule = false
    self._schedule_waiting = false
    self:UnSchedule(self.callback)
    self:UnSchedule(self.callback_waiting)
    self._time = Tool.Time() + 24 * 60 * 60 * self.index
    if self._info.Open then --本格当天，活动开启中
        if self._time < self._info.EndAt then --本格日期小于结束时间
            if self.index == 0 then --本格时第一格，显示活动时间
                self._ctrView.selectedIndex = 0
                if self._info.Id == 1001001 then
                    self._endTime = Model.SingleActivity_EndAt
                else
                    self._endTime = self._info.EndAt
                end
                self._schedule = true --启动计时
                self:Schedule(self.callback, 1)
            else --本格不是第一格，显示活动开启中状态
                self._ctrView.selectedIndex = 1
            end
        else --本格日期大于结束时间 因活动开启中，所以不显示任何颜色
            self._ctrView.selectedIndex = 4
        end
    else --本格当天，活动未开启
        if self._time < self._info.StartAt then --本格日期小于活动下次开启时间
            if self.index == 0 then --本格是第一格
                self._ctrView.selectedIndex = 2 --显示待开启格子，并计时
                self._startTime = self._info.StartAt
                self._schedule_waiting = true
                self:Schedule(self.callback_waiting, 1)
            else
                self._ctrView.selectedIndex = 3
            end
        elseif self._time >= self._info.StartAt and self._time < self._info.EndAt then --即将开放的活动期间
            self._ctrView.selectedIndex = 1
        else
            self._ctrView.selectedIndex = 4
        end
    end
end

function ItemActivityCenterCalendar3:SetData(info, index)
    self._info = info
    self.index = index
    self:UpdateContent()
end

return ItemActivityCenterCalendar3
