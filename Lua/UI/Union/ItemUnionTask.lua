--[[
    author:{zhanzhang}
    time:2019-06-28 14:36:14
    function:{联盟任务item}
]]
local ItemUnionTask = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionTask", ItemUnionTask)
local ShopModel = import("Model/ShopModel")

local UnionModel = import("Model/UnionModel")
local UnionHelpTaskType = import("Enum/UnionHelpTaskType")
local CommonModel = import("Model/CommonModel")

function ItemUnionTask:ctor()
    --拥有者姓名
    self._playerName = self:GetChild("textPlayerName")
    self._levelBg = self:GetChild("bgBlue")
    self._icon = self:GetChild("icon")
    self._btnHelp = self:GetChild("btnHelp")
    self._textBtnTip = self._btnHelp:GetChild("title")
    -- self._textCompletion = self:GetChild("textCompletion")
    self._textCompletionNum = self:GetChild("textCompletionNum")
    self._textCompletionTime = self:GetChild("textCompletionTime")
    self._groupCountDown = self:GetChild("groupHelpTask")
    self._progressBar = self:GetChild("progressBar")

    self._contentList = self:GetChild("liebiao")
    self._btnBuy = self:GetChild("btnGold")
    self._btnGray = self:GetChild("btnGray")
    self._textPrice = self._btnBuy:GetChild("text")
    --进度条控制器 --0 待领取 1进行中 2已完成
    self._controller = self:GetController("c1")
    --图片控制器 --0物品  --1 人
    self._headController = self:GetController("c2")
    --按钮控制器 --0免费  --1 购买 --2禁止
    self._btnController = self:GetController("btn")
    -- self._textCompletion.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TaskHelpTime")
    self._btnGray.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TaskRequest")
    self:AddListener(self._btnHelp.onClick,
        function()
            --处于帮助任务中
            if (self.taskType == 3) then
                self:HelpOtherClick()
            else
                self:MyTaskClick()
            end
            --刷新一遍联盟界面列表
            --Event.Broadcast(EventDefines.UIOnFinishUnionTask)
        end
    )
    self:AddListener(self._btnBuy.onClick,
        function()
            --处于帮助任务中
            if (self.taskType == 3) then
                self:HelpOtherClick()
            else
                self:MyTaskClick()
            end
        end
    )
    self.calTimeFunc = function()
        self:RefreshProgressBar()
    end
    --在帮助任务中点击帮助后其他帮助按钮置灰
    self:AddEvent(
        EventDefines.UIOnUnionHelpOtherTask,
        function(taskId)
            if (not self.data or self.taskType ~= 3) then
                return
            end
            if (self.data.Id ~= taskId) then
                self:RefreshStatus(UnionHelpTaskType.OtherWaitHelp)
            end
        end
    )
    -- _iconItem
    -- _textTaskName
    -- _iconPlayer
end

function ItemUnionTask:Init(data, taskType)
    self:UnSchedule(self.calTimeFunc)
    self.data = data
    self.taskType = taskType
    self.configTask = ConfigMgr.GetItem("configAllianceTasks", data.ConfId)
    self._textTaskName.text = ConfigMgr.GetI18n("configI18nCommons", self.configTask.name)
    self._textTaskName.color = GameUtil.Color(Global.TxtColour[self.configTask.grade + 1])
    self._bg.url = UITool.GetIcon(self.configTask.bg_grade)
    self._controller.selectedIndex = 0
    --判断自己是否是求助者，帮助者和求助者奖励不同
    if data.UserId == Model.Account.accountId then
        self:RefreshAward(data.Rewards)
    else
        self:RefreshAward(data.HelpRewards)
    end

    if (taskType == 1) then
        self._headController.selectedIndex = 0
        self._iconItem.icon = UITool.GetIcon(self.configTask.icon)
        self:RefreshStatus(UnionHelpTaskType.WaitReceive)
    elseif (taskType == 2) then
        self:RefreshMyTaskInfo()
    elseif (taskType == 3) then
        self:RefreshOtherTaskInfo()
    end
end

--刷新奖励箱子
function ItemUnionTask:RefreshAward(list)
    -- Scheduler
    self._contentList:RemoveChildrenToPool()
    for i = 1, #list do
        local itemAward = self._contentList:AddItemFromPool()
        itemAward:Init(list[i])
    end
end
--刷新进度条
function ItemUnionTask:RefreshProgressBar()
    -- if self.data.HelperId == "" then
    if self.data.Status == 1 then
        return
    end

    local delayTime = self.data.FinishAt - Tool.Time()
    if (delayTime < 0) then
        self:UnSchedule(self.calTimeFunc)
        self.data.Status = 3
        self:RefreshStatus(UnionHelpTaskType.CanGet)
        return
    end
    local totalTime = self.configTask.time
    self._progressBar.value = (totalTime - delayTime)
    if self.data.HelperId == "" then
        self._textHelperName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TeamMission_Time")
    end

    self._textCompletionTime.text = TimeUtil.SecondToHMS(delayTime)

    if self.taskStatus == UnionHelpTaskType.WaitSpeedUp then
        self.price = math.ceil((self.data.FinishAt - Tool.Time()) / 3600 * Global.ATSpeedupHourFee)
        self._textPrice.text = self.price
    end
end

function ItemUnionTask:OnClose()
    self:UnSchedule(self.calTimeFunc)
end

-------------------------------协作任务流程分支-----------------------------------------
--领取任务列表的任务
function ItemUnionTask:GetTask()
    local postFunc = function()
        Net.AllianceTasks.Start(
            self.data.Id,
            function(data)
                Event.Broadcast(EventDefines.UIUnionCooperationRefreshTaskList, data.NextFreeAt)
                Event.Broadcast(EventDefines.UIAllianceTaskPonit)
                UnionModel.RefreshFreeAt(data)
                UnionModel.AcceptTaskOnce()
            end
        )
    end
    if self.price > 0 then
        if self.price > Model.Player.Gem then
            ShopModel:GoldNotEnoughTipByType(RES_TYPE.Diamond)
            return
        end

        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TaskAccept_Tips", {diamond_num = self.price}),
            gold = self.price,
            sureCallback = function()
                postFunc()
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
        return
    end
    postFunc()
end
-------------------------------刷新任务Item分支-------------------------------------------

--进入刷新我的任务流程
function ItemUnionTask:RefreshMyTaskInfo()
    self._iconItem.icon = UITool.GetIcon(self.configTask.icon)
    self._headController.selectedIndex = 0
    if self.data.Status == Global.ATStatusRunning then
        --待执行的任务
        self._textCompletionNum.text = TimeUtil.SecondToHMS(self.configTask.time)
        if (self.data.HelperId == "") then
            self:RefreshStatus(UnionHelpTaskType.AskHelp)
        else
            --领取任务过后显示倒计时
            self:RefreshStatus(UnionHelpTaskType.WaitFinish)
        end
        self:Schedule(self.calTimeFunc, 1, true)
    else
        --已完成
        self:RefreshStatus(UnionHelpTaskType.CanGet)
    end
end

--刷新帮助任务

function ItemUnionTask:RefreshOtherTaskInfo()
    CommonModel.SetUserAvatar(self._iconPlayer, self.data.avatar, self.data.userId)
    self._headController.selectedIndex = 1
    if self.data.Status == Global.ATStatusRunning then
        --待执行的任务
        self._textCompletionNum.text = TimeUtil.SecondToHMS(self.configTask.time)
        self._controller.selectedIndex = 1
        if self.data.HelperId == "" then
            local isCanHelp = UnionModel.IsOtherCanHelp()
            if isCanHelp then
                self:RefreshStatus(UnionHelpTaskType.OtherCanHelp)
            else
                self:RefreshStatus(UnionHelpTaskType.OtherWaitHelp)
            end
        else
            self:RefreshStatus(UnionHelpTaskType.WaitSpeedUp)
            --领取任务过后显示倒计时
            self:Schedule(self.calTimeFunc, 1, true)
        end
    else
        --已完成
        self:RefreshStatus(UnionHelpTaskType.CanGet)
    end
end

-----------------------------------------------------------------------------------------
------------按钮事件分发------

--帮助任务
function ItemUnionTask:HelpOtherClick()
    if (self.data.Status == Global.ATStatusFinish) then
        --完成任务回调
        Net.AllianceTasks.Claim(
            self.data.Id,
            function(task)
                --播放领奖动画
                UITool.ShowReward(self.data.Rewards)
                UnionModel.FinishUnionTask(3, self.data.Id)
                Event.Broadcast(EventDefines.UIOnFinishUnionTask, 3)
            end
        )
        return
    end

    --2种状态--未帮助
    if (self.data.HelperId == "") then
        --加入联盟未到冷却时间不能帮助其他人任务
        if UnionModel.CheckIsNotOverJoinTime() then
            TipUtil.TipById(50136)
            return
        end
        Net.AllianceTasks.Help(
            self.data.UserId,
            self.data.Id,
            function(task)
                UnionModel.HelpOtherOnce()
                UnionModel.UpdateTask(task.Task, self.data.Id)
                self.data = task.Task
                Event.Broadcast(EventDefines.UIAllianceRefeshHelpTask)
            end
        )
    else
        if self.price > Model.Player.Gem then
            ShopModel:GoldNotEnoughTipByType(RES_TYPE.Diamond)
            return
        end
        --加速回调
        local postFunc = function()
            Net.AllianceTasks.Speedup(self.data.Id)
        end
        local temp = {}
        temp["diamond_num"] = self.price
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Task_SpeedUp", temp),
            gold = self.price,
            sureCallback = function()
                postFunc()
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end
end

function ItemUnionTask:MyTaskClick()
    --处于任务列表状态
    if (self.data.Status == 1) then
        --加入联盟未到冷却时间不能领取任务
        if UnionModel.CheckIsNotOverJoinTime() then
            TipUtil.TipById(50137)
            return
        end

        self:GetTask()
    elseif (self.data.Status == 2) then
        Net.AllianceTasks.AskHelp(
            self.data.Id,
            function(task)
                self._btnController.selectedIndex = 2
                self.data.AskedHelp = true
                -- UnionModel.ChangeMyTaskHelpStatus(self.data.Id)
            end
        )
    elseif (self.data.Status == Global.ATStatusFinish) then
        Net.AllianceTasks.Claim(
            self.data.Id,
            function(task)
                --播放领奖动画
                UITool.ShowReward(self.data.Rewards)
                UnionModel.FinishUnionTask(2, self.data.Id)
                Event.Broadcast(EventDefines.UIOnFinishUnionTask, 2)
            end
        )
    end
end

-----------切换状态------------------------------
function ItemUnionTask:RefreshStatus(taskStatus)
    self.taskStatus = taskStatus
    self._progressBar.max = self.configTask.time
    if taskStatus == UnionHelpTaskType.WaitReceive then
        -- end
        self._controller.selectedIndex = 0
        self.price = UnionModel.GetTaskPrice()
        self._playerName.text = ""
        self._textHelperName.text = ""
        self._textPrice.text = self.price
        if (self.price == 0) then
            self._btnHelp.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_Free")
            self._btnController.selectedIndex = 0
        else
            self._btnBuy.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Accept")
            self._btnController.selectedIndex = 1
        end
        self._textCompletionNum.text = TimeUtil.SecondToHMS(self.configTask.time)
    elseif taskStatus == UnionHelpTaskType.AskHelp then
        self._controller.selectedIndex = 1
        self._btnController.selectedIndex = self.data.AskedHelp and 2 or 0
        self._textHelperName.text = ""
        self._btnHelp.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TaskRequest")
        self._btnGray.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TaskRequest")
        self._playerName.text = self.data.UserName
        self._textCompletionNum.text = TimeUtil.SecondToHMS(self.configTask.time)
        self._progressBar.value = self.configTask.time
    elseif taskStatus == UnionHelpTaskType.OtherCanHelp then
        --可以帮助状态
        self._controller.selectedIndex = 0
        self._btnController.selectedIndex = 0
        self._btnHelp.title = StringUtil.GetI18n(I18nType.Commmon, "Button_Union_Help")
        self._textHelperName.text = ""
        self._playerName.text = self.data.UserName
        self._textCompletionNum.text = TimeUtil.SecondToHMS(self.configTask.time)
    elseif taskStatus == UnionHelpTaskType.OtherWaitHelp then
        --等待帮助不能点
        self._controller.selectedIndex = 0
        self._btnController.selectedIndex = 2
        self._btnHelp.title = StringUtil.GetI18n(I18nType.Commmon, "Button_Union_Help")
        self._btnGray.title = StringUtil.GetI18n(I18nType.Commmon, "Button_Union_Help")
        self._textHelperName.text = ""
        self._playerName.text = self.data.UserName
        self._textCompletionNum.text = TimeUtil.SecondToHMS(self.configTask.time)
    elseif taskStatus == UnionHelpTaskType.WaitSpeedUp then
        self._controller.selectedIndex = 1
        self._btnController.selectedIndex = 1
        self.price = math.ceil((self.data.FinishAt - Tool.Time()) / 3600 * Global.ATSpeedupHourFee)
        self._textPrice.text = self.price

        self._btnBuy.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_SPEED")
        self._playerName.text = self.data.UserName
        self._textHelperName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TaskHelpTxt")
    elseif taskStatus == UnionHelpTaskType.WaitFinish then
        self._controller.selectedIndex = 1
        self._btnController.selectedIndex = 2
        self._btnGray.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
        self._textHelperName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TeamMission_Player", {player_name = self.data.HelperName})
        self._playerName.text = self.data.UserName
    elseif taskStatus == UnionHelpTaskType.CanGet then
        self._controller.selectedIndex = 2
        self._btnController.selectedIndex = 0
        self._textHelperName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TeamMission_Player", {player_name = self.data.HelperName})
        self._playerName.text = self.data.UserName
        self._btnHelp.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
    end
end

return ItemUnionTask
