--[[
    Author:maxiaolong
    Function:主线任务
]]
local TaskMain = UIMgr:NewUI("TaskMain")
local TaskModel = import("Model/TaskModel")
local DailyTaskModel = import("Model/DailyTaskModel")
local JumpMap = import("Model/JumpMap")
local GlobalVars = GlobalVars

local TAKSTYPE = {
    ["MAINTASK"] = 0,
    ["DAILYTASK"] = 1
}

function TaskMain:OnInit()
    local view = self.Controller.contentPane
    self._view = view

    -------------------公共元件-------------------
    self._title = view:GetChild("textName")
    self._sortingOrder = view.sortingOrder
    self._controller = view:GetController("c0")
    self._btnReturn = view:GetChild("btnReturn")
    self._btnMission = view:GetChild("btnMission")
    self._btnDaily = view:GetChild("btnDaily")
    self._redPoint = view:GetChild("redPoint")
    self._redPoint2 = view:GetChild("redPoint2")

    -------------------主线任务界面组件-------------------
    self._btnTaskBox = view:GetChild("btnTaskBox")
    self._btnTaskBoxCT = self._btnTaskBox:GetController("button")
    self._textBoxFinish = view:GetChild("TextBoxFinish")

    self._progressBarBox = view:GetChild("progressBarBox")
    self._textProgressBar = view:GetChild("textProgressBar")

    self._recTaskTitle = view:GetChild("textPlotReward")
    self._btnRecBg = view:GetChild("btnBgBox2")
    self._btnRecIcon = view:GetChild("icon")
    self._textRecDesc = view:GetChild("textIconName")
    self._textRecProgress = view:GetChild("textIconNameNum")
    self._progressBar = view:GetChild("ProgressBarYellow")
    self._iconRecRewards = view:GetChild("iconRewards")
    self._textRecRewardsNum = view:GetChild("textRewardsNum")
    self._btnRecGet = view:GetChild("btnGet")
    self._aniRecGetBtn = self._btnRecGet:GetChild("iconSign"):GetTransition("Anim")
    self._c1RecGetBtn = self._btnRecGet:GetController("c1")
    self._textRecTaskFinish = view:GetChild("TextMainTaskFinish")

    self._textOrdTitle = view:GetChild("textOrdinary")
    self._aniMove = view:GetTransition("Move")
    self._listOrd = view:GetChild("liebiaoMission")
    self._textOrdTaskFinish = view:GetChild("TextTaskCommonFinish")

    -------------------日常任务界面-------------------
    self._dailyTask = view:GetChild("TaskDaily")

    -------------------默认设置-------------------
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Hero")
    self._recTaskTitle.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RECOMMEND_TASK")
    self._textOrdTitle.text = StringUtil.GetI18n(I18nType.Commmon, "UI_COMMON_TASK")
    self._btnMission.title = StringUtil.GetI18n(I18nType.Commmon, "UI_MAIN_QUEST")
    self._btnDaily.title = StringUtil.GetI18n(I18nType.Commmon, "UI_DAILY_QUEST")
    self._bannerMain.icon = UITool.GetIcon(GlobalBanner.TaskMain)
    self._btnTaskBoxCT.selectedIndex = 0
    self._redPoint.visible = false
    self._redPoint2.visible = false
    self._textBoxFinish.visible = false
    self._textRecTaskFinish.visible = false
    self._textOrdTaskFinish.visible = false

    -------------------按钮显示隐藏列表-------------------
    self.TaskViewList = {
        ["MainTask"] = {
            self._btnRecIcon,
            self._textRecDesc,
            self._progressBar,
            self._iconRecRewards,
            self._textRecProgress,
            self._textRecRewardsNum,
            self._btnRecGet
        },
        ["CoomonTask"] = {
            self._listOrd
        },
        ["BoxTask"] = {
            self._btnTaskBox,
            self._progressBarBox,
            self._textProgressBar
        }
    }

    self:InitEvent()
end

--事件注册
function TaskMain:InitEvent()
    --日常任务Tag按钮
    self:AddListener(
        self._btnDaily.onChanged,
        function()
            if GlobalVars.IsTriggerStatus then
                return
            end
            self:OpenDailyTask()
        end
    )
    --退出界面按钮
    self:AddListener(
        self._btnReturn.onClick,
        function()
            UIMgr:Close("TaskMain",
            function ()
                if self.triggerCallBack then
                    self.triggerCallBack()
                end
            end
        )
        end
    )
    --中间宝箱按钮
    self:AddListener(
        self._btnTaskBox.onClick,
        function()
            --点击宝箱显示奖励框
            if GlobalVars.IsTriggerStatus then
                return
            end
            UIMgr:Open("TaskMissionBoxRewardPopup", self.listBoxTask[1])
        end
    )
    --推荐任务领取事件
    self:AddListener(
        self._btnRecGet.onClick,
        function()
            self:GetRecTaskOnclick()
        end
    )
    --推荐任务icon按钮事件
    self:AddListener(
        self._btnRecIcon.onClick,
        function()
            self:RecTaskOnlick()
        end
    )
    --推荐任务按钮
    self:AddListener(
        self._btnRecBg.onClick,
        function()
            self:RecTaskOnlick()
        end
    )
    --GM刷新数据
    self:AddEvent(
        EventDefines.CloseUiTaskMain,
        function()
            UIMgr:Close("TaskMain")
        end
    )
    --界面刷新
    self:AddEvent(
        EventDefines.UITaskMainRefresh,
        function()
            --刷新红点
            Event.Broadcast(EventDefines.UITaskRefreshRed)
            if UIMgr:GetUIOpen("TaskMain") then
                self:RefreshTaskContent()
                self:RefreshRedPoint()
            end
        end
    )
    --日常任务红点刷新
    self:AddEvent(
        EventDefines.DailyRedPointRefresh,
        function(show)
            --刷新红点
            self:RefreshDailyRedPoint(show)
        end
    )
end

function TaskMain:OnOpen(isOpenDaily, callback)
    local taskAmount = TaskModel:GetNoticeReadAmount() --未领取任务数量
    local dailyTaskAmount = DailyTaskModel:GetRedAmount() --日常任务红点数量

    self._listOrd.scrollPane:ScrollTop()
    self._sortingOrder = 3

    if not GlobalVars.IsNoviceGuideStatus and not GlobalVars.IsTriggerStatus then
        if isOpenDaily then
            self:SwitchPage(TAKSTYPE.DAILYTASK)
            self:OpenDailyTask()
            if callback then
                callback()
            end
        else
            if dailyTaskAmount > 0 and taskAmount == 0 then
                self:SwitchPage(TAKSTYPE.DAILYTASK)
                self:OpenDailyTask()
            else
                self:SwitchPage(TAKSTYPE.MAINTASK)
            end
        end
    else
        self:SwitchPage(TAKSTYPE.MAINTASK)
    end

    --隐藏按钮红点
    self._btnMission:GetChild("iconRedPoint").visible = false
    self._btnDaily:GetChild("iconRedPoint").visible = false
    --刷新页面内容
    self:RefreshTaskContent()
    --设置红点
    self:RefreshRedPoint()
    self._dailyTask:SetRedPoint()
    --强引导事件
    Event.Broadcast(EventDefines.NextNoviceStep, 1002)
end

--切换主线任务和日常任务页面
function TaskMain:SwitchPage(index)
    self._controller.selectedIndex = index
end

--打开日常任务页面
function TaskMain:OpenDailyTask()
    self._dailyTask:OnOpen()
end

--设置推荐任务按钮状态
function TaskMain:SetRecBtnState(index)
    self._c1RecGetBtn.selectedIndex = index
    local str = ""
    if index == 0 then
        str = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
    elseif index == 1 then
        str = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
    elseif index == 2 then
        str = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_39")
    elseif index == 3 then
        str = ""
    end
    self._btnRecGet.title = str
end

--*****************************************************************推荐任务点击和领取事件*****************************************************************
--推荐任务点击事件
function TaskMain:RecTaskOnlick()
    if GlobalVars.IsTriggerStatus then
        return
    end
    --点击显示推荐任务奖励框
    if not self.recTask or self._aniMove.playing == true then
        return
    end
    UIMgr:Open(
        "TaskMissionPopup",
        1,
        self.recTask,
        function()
            self._c1RecGetBtn.selectedIndex = 3
            self._aniMove:Play()
            self._aniMove:SetHook(
                "left",
                function()
                    --获得宝箱任务，推荐任务和普通任务数据
                    self.listBoxTask, self.recTask, self.listOrdTask = TaskModel:GetTaskByType()
                    if not self.recTask then
                        Event.Broadcast(EventDefines.MesTaskMainTipEvent, nil)
                    else
                        Event.Broadcast(EventDefines.MesTaskMainTipEvent, self.recTask)
                    end
                    self:RecTaskSetting()
                    self:RefreshRedPoint()
                end
            )
        end
    )
end

--推荐任务按钮事件
function TaskMain:GetRecTaskOnclick()
    if GlobalVars.IsTriggerStatus then
        return
    end
    if not self.recTask or self._aniMove.playing == true then
        return
    end
    local btnIndex = self._c1RecGetBtn.selectedIndex
    --前往
    if btnIndex == 0 then
        --领取
        UIMgr:Close("TaskMain")
        --跳转处理
        if self.recTask.jump.jump == 810500 then
            --如果该地块已解锁则向下查找有没有未解锁的地块
            local pieceId = self.recTask.jump.para
            local unlockNode = CityMapModel.GetLockBtn(pieceId)
            if unlockNode:GetVisible() then
                for i = pieceId, 1, -1 do
                    local lockNode = CityMapModel.GetLockBtn(i)
                    if not lockNode:GetVisible() then
                        pieceId = i
                        break
                    end
                end
            end
            TurnModel.MapLockPiece(pieceId)
        else
            JumpMap:JumpTo(self.recTask.jump, self.recTask.finish)
        end
    elseif btnIndex == 1 then
        --容错处理
        if not self.recTask or not self.recTask.award then
            return
        end
        --缓存
        local rewardData = self.recTask.award
        Net.MainTask.GetMainTaskAward(
            self.recTask.id,
            function(rsp)
                UITool.GiftReward(rewardData)
                TaskModel:GetRemoveTaskInfo(rsp) --接收通知去掉已领取任务信息
                self.recTask = TaskModel.GetRecommendTask()
                --完成主线任务隐藏主界面推荐按钮
                if not self.recTask then
                    Event.Broadcast(EventDefines.MesTaskMainTipEvent, nil)
                else
                    Event.Broadcast(EventDefines.MesTaskMainTipEvent, self.recTask)
                end
                --播放领奖动画
                self._c1RecGetBtn.selectedIndex = 3
                self._aniMove:Play()
                self._aniMove:SetHook(
                    "left",
                    function()
                        self:SetRecBtnState(1)
                        self:RecTaskSetting()
                        self:RefreshRedPoint()
                        if self.recTask.AwardTaken == false then
                            self:SetRecBtnState(1)
                        else
                            self:SetRecBtnState(0)
                        end
                    end
                )
                if GlobalVars.IsNoviceGuideStatus == true then
                    Event.Broadcast(EventDefines.NextNoviceStep, 1003)
                    UIMgr:Close("TaskMain")
                end
            end
        )
    end
end

--***********************************************************************任务列表设置*********************************************************************
--刷新页面内容
function TaskMain:RefreshTaskContent()
    self.listBoxTask, self.recTask, self.listOrdTask = TaskModel:GetTaskByType()
    self:BoxTaskSetting()
    self:RecTaskSetting()
    self:OrdTaskSetting()
end

--宝箱任务设置
function TaskMain:BoxTaskSetting()
    local boxIsReceive
    local boxCurValue = 0
    if not next(self.listBoxTask) then
        self._textBoxFinish.text = StringUtil.GetI18n(I18nType.Commmon, "UI_NO_GIFT_TASK")
        self._textBoxFinish.visible = true
        self:SetFinishTask(0, false)
        return
    else
        self._textBoxFinish.visible = false
        self:SetFinishTask(0, true)
    end
    if self.listBoxTask[1].AwardTaken == false then
        boxIsReceive = self.listBoxTask[1].AwardTaken
    end

    local boxMaxValue = self.listBoxTask[1].finish.para2
    if boxIsReceive == false then
        self._progressBarBox.value = 100
        for _, v in pairs(self.listBoxTask) do
            if v.AwardTaken == false then
                boxCurValue = boxCurValue + v.finish.para2
            elseif v.CurrentProcess > 0 then
                boxCurValue = boxCurValue + v.CurrentProcess
            end
        end
        self._textProgressBar.text = boxCurValue .. "/" .. boxMaxValue
        self._textProgressBar.color = Color(242 / 255, 241 / 255, 241 / 255)
        self._btnTaskBoxCT.selectedIndex = 1
        self.frontEffect, self.behindEffect = AnimationModel.GiftEffect(self._btnTaskBox, Vector3(1.5, 1.5, 1), nil, "TaskMainbtnTaskBox", self.frontEffect, self.behindEffect)
    else
        if not self.listBoxTask[1].CurrentProcess then
            boxCurValue = 0
        else
            boxCurValue = self.listBoxTask[1].CurrentProcess
        end
        self._progressBarBox.value = boxCurValue / boxMaxValue * 100
        self._textProgressBar.text = boxCurValue .. "/" .. boxMaxValue
        self._btnTaskBoxCT.selectedIndex = 0
        AnimationModel.DisPoseGiftEffect("TaskMainbtnTaskBox", self.frontEffect, self.behindEffect)
    end
end

--普通任务列表设置
function TaskMain:OrdTaskSetting()
    local testTable = {}
    for _, v in pairs(self.listOrdTask) do
        table.insert(testTable, v.id)
    end
    --普通任务
    local liebiaoCount
    if #self.listOrdTask == 0 then
        self._textOrdTaskFinish.text = StringUtil.GetI18n(I18nType.Commmon, "UI_NO_ORDINARY_TASK")
        self._textOrdTaskFinish.visible = true
        self._listOrd.numItems = 0
        self:SetFinishTask(2, false)
        return
    else
        self._textOrdTaskFinish.visible = false
        self:SetFinishTask(2, true)
    end

    liebiaoCount = #self.listOrdTask > 4 and 4 or #self.listOrdTask
    self._listOrd.numItems = liebiaoCount
    for i = 1, liebiaoCount do
        local item = self._listOrd:GetChildAt(i - 1)
        item:InitEvent(self.listOrdTask[i])
    end
end

--推荐任务设置
function TaskMain:RecTaskSetting()
    self.recTask = TaskModel:GetRecommendTask()
    --设置是否有推荐任务的元件显隐
    if not self.recTask then
        self._textRecTaskFinish.visible = true
        self._textRecTaskFinish.text = StringUtil.GetI18n(I18nType.Commmon, "UI_NO_RECOMMEND_TASK")
        self:SetFinishTask(1, false)
        return
    else
        self._textRecTaskFinish.visible = false
        self._textRecProgress.color = Color(242 / 255, 241 / 255, 241 / 255)
        self:SetFinishTask(1, true)
    end
    --图标和任务描述
    self._btnRecIcon.url = UITool.GetIcon(self.recTask.img)
    self._textRecDesc.text = TaskModel:GetTaskNameByType(self.recTask)
    --进度条
    local percent
    local isReceive
    if self.recTask.AwardTaken == false then
        isReceive = self.recTask.AwardTaken
    end
    if isReceive == false then
        self._textRecProgress.text = self.recTask.finish.para2 .. "/" .. self.recTask.finish.para2
        self._textRecProgress.color = Color(242 / 255, 241 / 255, 241 / 255)
        percent = 1
        self._progressBar.value = percent * 100
    else
        local curValue = self.recTask.CurrentProcess and self.recTask.CurrentProcess or 0
        local maxValue = self.recTask.finish.para2
        self._textRecProgress.text = curValue .. "/" .. maxValue
        percent = curValue / maxValue
        self._progressBar.value = percent * 100
    end
    --奖励类型和礼包
    local showType = self.recTask.special
    self._iconRecRewards.url = UITool.GetIcon(TaskModel:GetResConfById(showType))
    local awardType = self.recTask.award
    local res = TaskModel:GetGiftConfById(awardType)
    for _, v in pairs(res) do
        if showType == v.category then
            local amount = Tool.FormatNumberThousands(v.amount)
            self._textRecRewardsNum.text = "+" .. amount
        end
    end
    --设置按钮状态
    if percent < 1 then
        self:SetRecBtnState(0)
        if self.recTask.jump[1] == 0 then
            self._btnRecGet:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "FUND_VIEW_BUTTON")
        else
            self._btnRecGet:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
        end
    else
        self:SetRecBtnState(1)
    end
end
--*******************************************************************************************************************************************************

--0代表宝箱任务，--1代表推荐任务，--2代表普通任务
function TaskMain:SetFinishTask(pageIndex, isShow)
    local str = ""
    if pageIndex == 0 then
        str = "BoxTask"
    elseif pageIndex == 1 then
        str = "MainTask"
    elseif pageIndex == 2 then
        str = "CoomonTask"
    end

    local pageList = self.TaskViewList[str]
    for _, v in pairs(pageList) do
        v.visible = isShow
    end
end

--刷新主线任务红点提示显示
function TaskMain:RefreshRedPoint()
    local count = TaskModel:GetNoticeReadAmount()
    if count > 0 then
        self._redPoint.visible = true
    else
        self._redPoint.visible = false
    end
end

--刷新日常任务红点
function TaskMain:RefreshDailyRedPoint(show)
    self._redPoint2.visible = show
end

function TaskMain:DoOpenAnim(...)
    self:OnOpen(...)
    AnimationLayer.PanelAnim(AnimationType.PanelMoveUp, self)
end

function TaskMain:OnClose()
    Event.Broadcast(EventDefines.UITaskRefreshRed)
    UIMgr:Close("DailyTask")
    self._dailyTask:OnClose()
end

function TaskMain:TriggerOnclick(callback)
    self.triggerCallBack = callback
end

return TaskMain
