--[[
    author:{laofu}
    time:2020-06-01 11:09:26
    function:{单人活动}
]]
local GD = _G.GD
local SingleActivity = UIMgr:NewUI("SingleActivity")

function SingleActivity:OnInit()
    local view = self.Controller.contentPane

    self._btnRankAward = view:GetChild("btnRankAward")

    self._rewardListTitle = view:GetChild("rewardListTitle")
    self._rewardList = view:GetChild("rewardList")

    self._scoreListTitle = view:GetChild("scoreListTitle")
    self._scoreTaskList = view:GetChild("scoreTaskList")

    self._btnExit = view:GetChild("btnReturn")
    self._titleText = view:GetChild("activityTitle")
    self._btnHelp = view:GetChild("btnHelp")

    self._scoreBar = view:GetChild("progressBar")
    self._timeText = view:GetChild("timeText")
    self._barCurrentText = view:GetChild("currentText")
    self._barNextText = view:GetChild("nextScore")
    self._barText = view:GetChild("barText")

    --设置固定文本内容
    self._btnRankAward.title = StringUtil.GetI18n(I18nType.Commmon, "Button_Single_Viewrewards")
    self._rewardListTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Single_Award")
    self._scoreListTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Single_GetGrade")
    self._titleText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Single_Name")
    self._bgBanner.icon = _G.UITool.GetIcon({"banner_activity", "bg_banner_cooperation_02"})
    --事件注册
    self:InitEvent()
end

function SingleActivity:InitEvent()
    self:AddListener(
        self._btnRankAward.onClick,
        function()
            local rankAwards = GD.SingleActivityAgent.GetRankAwards()
            UIMgr:Open("SingleActivityRankAward", rankAwards)
        end
    )

    self:AddListener(
        self._btnHelp.onClick,
        function()
            local data = {
                info = StringUtil.GetI18n(I18nType.Commmon, "Ui_Single_Tips")
            }
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )

    self:AddListener(
        self._btnExit.onClick,
        function()
            UIMgr:Close("SingleActivity")
        end
    )

    --奖励列表
    self._rewardList.itemRenderer = function(index, item)
        local data = self.stageAward[index + 1]
        --item = ItemSingleActivityScoreReward
        item:InitData(data)
    end

    --积分任务列表
    self._scoreTaskList.itemRenderer = function(index, item)
        local task = self.scoreTasks[index + 1]
        --设置item内容
        local title = item:GetChild("title")
        local banner = item:GetChild("banner")
        local taskEvent = self.taksInfo.task_event[index + 1]
        local info = self.scoreViewInfo[taskEvent]
        title.text = StringUtil.GetI18n(I18nType.Commmon, info.name)
        banner.icon = UITool.GetIcon(info.banner)
        --按钮事件
        local btn = item:GetChild("btnGreen")
        btn.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_DETAIL")
        btn:RemoveEventListeners()
        self:AddListener(
            btn.onClick,
            function()
                UIMgr:Open("SingleActivityTask", task)
            end
        )
    end

    self:AddEvent(
        EventDefines.SingleActivityContentRefresh,
        function()
            UIMgr:Close("SingleActivity")
        end
    )
end

--设置进度条内容
function SingleActivity:SetProgerssBar()
    local diffNum = 0
    --设置bar的相关内容
    self._scoreBar.max = self.stageAward[#self.stageAward].score
    local offset = self._scoreBar.width / self._scoreBar.max
    for k, v in pairs(self.stageAward) do
        --设置下标位置
        local progressArrow = self.Controller.contentPane:GetChild("progressArrow" .. k)
        progressArrow:GetChild("title").text = v.score
        progressArrow.y = self._scoreBar.y + self._scoreBar.height
        progressArrow.x = self._scoreBar.x + (v.score * offset)
    end
    --计算积分差
    local nextStage = Model.SingleActivity_Stage + 1 >= 4 and 3 or Model.SingleActivity_Stage + 1
    local nextScore = self.stageAward[nextStage].score
    if self.score < nextScore then
        diffNum = nextScore - self.score
    end

    self._barCurrentText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Single_Grade_Now") .. self.score
    self._barNextText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Single_Grade_disparity") .. diffNum
    self._barText.text = self.score .. "/" .. self.stageAward[#self.stageAward].score

    self._scoreBar.value = self.score
end

--设置计时器
function SingleActivity:SetTimer(endAt)
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
    local function time_func()
        return endAt - Tool.Time()
    end
    if time_func() > 0 then
        local timeTextFunc = function(time)
            local times = Tool.FormatTime(time)
            self._timeText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Single_Timesup", {time = times})
        end
        self.cd_func = function()
            local ctime = time_func()
            if ctime >= 0 then
                timeTextFunc(ctime)
                return
            else -- 计时结束时
                self:UnSchedule(self.cd_func)
            end
        end
        self:Schedule(self.cd_func, 1)
    end
end

--刷新页面内容
function SingleActivity:RefreshContent()
    --玩家五级才开始活动
    GD.SingleActivityAgent.GetSingleActivityInfo(
        function()
            --分数
            self.score = Model.SingleActivity_Score
            --对应configSingleEvent表的ID
            self.taskID = Model.SingleActivity_TaskId
            --对应configSingleEvent表的单条内容
            self.taksInfo = Model.SingleActivity_TaskInfo
            --得到自己这个等级阶段的积分和奖励礼包，对应configStageAward表
            self.stageAward = Model.SingleActivity_StageAward
            --积分任务
            self.scoreTasks = GD.SingleActivityAgent.GetTasks()
            self.scoreViewInfo = GD.SingleActivityAgent.GetScoreTaskBanner()
            --计时器设置
            self:SetTimer(Model.SingleActivity_EndAt)
            --设置进度条内容
            self:SetProgerssBar()

            self._rewardList.numItems = #self.stageAward
            self._scoreTaskList.numItems = #self.taksInfo.task_event
            --列表大小
            self._scoreTaskList:ResizeToFit(self._scoreTaskList.numItems)
            self:ScheduleOnce(
                function()
                    --奖励列表长度适配
                    local view = self.Controller.contentPane
                    local bgTag2 = view:GetChild("bgTag2")
                    local bgDown = view:GetChild("bgDown")
                    local height = bgDown.y - (bgTag2.y + bgTag2.height)
                    self._rewardList.viewHeight = height
                end,
                0.3
            )
        end
    )
end

function SingleActivity:OnOpen()
    self:RefreshContent()
end

function SingleActivity:OnClose()
    self:UnSchedule(self.cd_func)
end

return SingleActivity
