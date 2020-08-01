--[[
    author:{laofu}
    time:2020-6-19 16:14:05
    function:{活动日常任务}
]]
local DailyTask = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/TaskDailyCom", DailyTask)

local DailyTaskModel = import("Model/DailyTaskModel")
DailyTask.dailyPopup = import("UI/Task/TaskDailyPopup")

function DailyTask:ctor()
    self._scoreTitle = self:GetChild("textIntegral")
    self._scoreText = self:GetChild("integralNumber")
    self._refreshTimer = self:GetChild("textRefresh")

    self._banner = self:GetChild("bannerDaily")
    self._topBox = self:GetChild("liebiaoTop")
    self._taskList = self:GetChild("liebiaoDaily")

    self._scoreTitle.text = StringUtil.GetI18n(I18nType.Commmon, "UI_INTEGRAL_NOW") .. ":"
    self._banner.icon = UITool.GetIcon(GlobalBanner.WelfareDailyTask)

    self.isVisible = true
    self._taskList:SetVirtual()
    self:SetRedPoint()

    self:InitEvent()
end

function DailyTask:InitEvent()
    self._taskList.itemRenderer = function(index, item)
        item:SetData(self.taskListData[index + 1])
    end

    --列表item的响应事件，打开弹窗
    self:AddListener(
        self._taskList.onClickItem,
        function(content)
            self:DailyListClick(content)
        end
    )

    --日常任务刷新
    self:AddEvent(
        EventDefines.DailyTaskRefreshAction,
        function(refreshAt)
            if refreshAt ~= nil then
                Event.Broadcast(EventDefines.DailyRedPointRefresh, false)
                self._topBox:TaskDailyRewardClear()
            end
            --这里防止不在当前页面的时候刷新数据
            if self.isVisible then
                self:OnOpen()
            end
            --刷新日常任务红点显示
            self:SetRedPoint()
        end
    )

    --任务界面（非福利中心）红点刷新
    self:AddEvent(
        EventDefines.RefreshDailyRed,
        function()
            self:SetRedPoint()
        end
    )
end

--刷新积分显示和设置计时器
function DailyTask:ResreshText(score, refreshAt)
    self._scoreText.text = score
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
    local function get_time()
        return refreshAt - Tool.Time()
    end
    self.cd_func = function()
        local refreshTime = get_time()
        local timeStr = refreshTime >= 0 and Tool.FormatTime(refreshTime) or "24:00:00"
        self._refreshTimer.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TIME_RENEW", {time = timeStr})
    end
    self:Schedule(self.cd_func, 1)
end

--刷新日常任务红点
function DailyTask:SetRedPoint()
    DailyTaskModel.GetDailyRedData(
        function(amount)
            local isRed
            if amount > 0 then
                isRed = true
            else
                isRed = false
            end
            Event.Broadcast(EventDefines.DailyRedPointRefresh, isRed)
            Event.Broadcast(EventDefines.UITaskRefreshRed)
        end
    )
end

--task列表item点击事件
function DailyTask:DailyListClick(content)
    local item = content.data
    local config = item:GetData()

    if config.StateType == 2 or config.StateType == 3 then
        if config.StateType == 3 then --锁住
            local unlockId = config.unlock[1].value
            local levelstr = DailyTaskModel.GetUnlockLevel(unlockId)
            local values = {
                building_name = StringUtil.GetI18n(I18nType.Building, "400000_NAME"),
                building_level = tostring(levelstr)
            }
            local lockName = StringUtil.GetI18n(I18nType.Commmon, "Building_Lock_Level", values)
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                info = lockName
            }
            UIMgr:Open("ConfirmPopupTextCentered", data)
        end
        return
    end
    DailyTask.dailyPopup.selectItem = item
    UIMgr:Open("TaskDailyPopup")
end

-- 设置列表信息
function DailyTask:SetList(unlockList, accompList, accompAward)
    DailyTaskModel:DailyTaskInit()
    self.taskListData, self.boxListData = DailyTaskModel:GetConfTaskByRsp(unlockList, accompList, accompAward)
    self._taskList.numItems = #self.taskListData
    self._topBox:SetDailyData(self.boxListData, self.score, self.baseLevel, self)
    AnimationLayer.UIDownToTopBoxAnim(self._taskList, 100, self)
end

--玩家所有日常任务的信息
function DailyTask:GetDailyTaskData()
    self._taskList.numItems = 0
    Net.DailyTask.GetDailyTaskInfo(
        function(rsp)
            self.score = rsp.Score --分数
            self.refreshTime = rsp.RefreshAt --刷新时间
            self.unLockedList = rsp.Unlocked --已经解锁的数据
            self.accomplished = rsp.Accomplished --完成的每日任务
            self.accomplishedAward = rsp.AccomplishedAward --完成的宝箱任务
            self.baseLevel = rsp.BaseLevel --当前主堡等级
            self:ResreshText(self.score, self.refreshTime)
            self:SetList(self.unLockedList, self.accomplished, self.accomplishedAward)
        end
    )
end

function DailyTask:OnOpen()
    self.isVisible = true
    self:GetDailyTaskData()
    self._taskList.scrollPane:ScrollTop()
    Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.OpenUI, 12900, 0)
end

function DailyTask:OnClose()
    self.isVisible = false
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
end

return DailyTask
