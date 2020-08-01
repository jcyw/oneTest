--[[
    Author:maxiaolong
    Function: 章节任务界面
]]
local GD = _G.GD
local TaskPlot = UIMgr:NewUI("TaskPlot")
local TaskPlotModel = import("Model/TaskPlotModel")
local TaskModel = import("Model/TaskModel")
local WelfareModel = import("Model/WelfareModel")
local plotConf = nil
local CTR = {
    Lockd = "Lockd", --锁定状态 变灰 不可点击
    UnLockd = "UnLockd" --解锁 可以领取全部奖励并跳转
}
local cutDialogIndex = 0
local GlobalVars = GlobalVars
local IsGotoGuide = false
local taskGoToPlotId = 0
local IsTouched = false
function TaskPlot:OnInit()
    local parentview = self.Controller.contentPane

    local view = parentview:GetChild("TaskPlotItem")
    self._taskPlotItem = view
    if MathUtil.HaveMatch() then
        view:SetScale(0.75, 0.75)
    end
    --文字显示:章节信息
    self._titleName = view:GetChild("titleName")
    self._textChapter = view:GetChild("textChapter")
    self._textDesc = view:GetChild("textDesc")
    --文字显示:获得奖励
    self._textTarget = view:GetChild("textTarget")
    --文字显示:剧情奖励
    self._textPlotReward = view:GetChild("textPlotReward")
    --文字显示:进程
    self._textAP = view:GetChild("textAP")
    --按钮相关
    self._btnReceive = view:GetChild("btnReceive")
    self._bthReceivetitle = self._btnReceive:GetChild("title")
    self._btnClose = view:GetChild("btnClose")
    self._bgMask = parentview:GetChild("bgMask")
    --页面控制
    self._receive = view:GetController("Receive")
    self._banner = view:GetChild("_banner")
    self._longPressLabel = view:GetChild("_longPressLabel")
    self._hero = view:GetChild("_hero")
    --任务列表
    self._list = view:GetChild("liebiaoPlot")
    self.guider = UIMgr:CreatePopup("Common", "Guide")
    --设置引导居中
    self.guider:SetPivot(0.5, 0.5)
    view:AddChild(self.guider)
    self.guider.visible = false
    self.guider:SetTopAnim(true)
    self._list.itemRenderer = function(index, item)
        self:ChapterMsg(index, item)
    end
    self:AddListener(
        parentview.onTouchEnd,
        function()
            IsTouched = true
        end
    )
    self:AddListener(
        parentview.onTouchBegin,
        function()
            IsTouched = true
        end
    )
    --章节奖励
    self._rewardlist = view:GetChild("liebiao")
    plotConf = ConfigMgr.GetList("configPlotNums")
    --点击X或者空白Mask时候 关闭页面
    self:AddListener(
        self._btnClose.onClick,
        function()
            self:Doclose()
        end
    )
    self:AddListener(
        self._bgMask.onClick,
        function()
            self:Doclose()
        end
    )

    self:AddListener(
        self._btnReceive.onClick,
        function()
            GlobalVars.IsTaskPlotAnim = true
            self:Doclose()
            Net.Chapter.GetChapterAward(
                function(msg)
                    --刷新
                    Event.Broadcast(EventDefines.RefreshTaskPlotGuide)
                    --存在做完章节任务的回复 需判断
                    if not next(msg) then
                        local finishNum = #plotConf
                        Model[ModelType.ChapterTasksInfo] = msg
                        UIMgr:Open("TaskPlotConfirm", self.Items, finishNum)
                        --如果章节完成则关闭MainUI中章节入口
                        Event.Broadcast(EventDefines.UICloseChapterShow)
                    else
                        Model[ModelType.ChapterTasksInfo] = msg
                        UIMgr:Open("TaskPlotConfirm", self.Items, msg.CurrentChapter - 1)
                        local alreadyTrigger = false
                        for j = 1, #Model.Player.TriggerGuides do
                            if Model.Player.TriggerGuides[j].Id == 15500 then
                                alreadyTrigger = true
                                break
                            end
                        end
                        if ABTest.Task_ABLogic() == 2001 then
                            if msg.CurrentChapter >= 5 then
                                Event.Broadcast(SYSTEM_SETTING_EVENT.HideTaskLable, true)
                            else
                                if alreadyTrigger == false then
                                    Event.Broadcast(SYSTEM_SETTING_EVENT.HideTaskLable, false)
                                else
                                    Event.Broadcast(SYSTEM_SETTING_EVENT.HideTaskLable, true)
                                end
                            end
                        end
                        Event.Broadcast(EventDefines.UIRefreshChapterShow)
                    end
                end
            )
        end
    )

    self:AddEvent(
        EventDefines.UIChapterSort,
        function()
            self.msg = Model.GetMap(ModelType.ChapterTasksInfo)
            self:RefreshChapters()
            self:RefreshChaptersShow()
        end
    )
    self:AddEvent(
        EventDefines.TaskPlotDialog,
        function(isStart, isInit)
            if isInit then
                cutDialogIndex = 0
            end
            self:PlayDialog(isStart)
        end
    )
    self:AddEvent(
        EventDefines.TaskPlotReview,
        function()
            self:OpenReview()
        end
    )
    --剧情任务功能完善
    self:AddEvent(
        EventDefines.TaskPlotCloseGuide,
        function()
            if IsGotoGuide then
                self:ScheduleOnceFast(
                    function()
                        self:SetNewNoviceGuide(taskGoToPlotId)
                    end,
                    0.2
                )
                return
            end
            TaskPlotModel.SetGuideStage(false)
            self.guider.visible = false
        end
    )
    --剧情任务前往引导
    self:AddEvent(
        EventDefines.TaskPlotGotoGuide,
        function(taskPlotId)
            taskGoToPlotId = taskPlotId
            IsGotoGuide = true
        end
    )
end

function TaskPlot:OnOpen(msg)
    --获取章节数据
    self.msg = msg
    self.plotconf = TaskModel:GetBasePlotTasks(msg.CurrentChapter)
    self.bannerPath = self.plotconf.banner
    self._banner.icon = UITool.GetIcon(self.bannerPath)
    self.heroPath = self.plotconf.role
    self._hero.icon = UITool.GetIcon(self.heroPath)
    self.include = self.plotconf.include
    self:RefreshChapters()

    --章节任务列表设置
    self._list.numItems = #self.include
    self._list:ResizeToFit(self._list.numChildren)
    self._list.scrollPane:SetPosY(0)
    self._list:EnsureBoundsCorrect()

    --章节奖励的礼物表
    local itemDatas, itemCount = WelfareModel.GetResOrItemByGiftId(self.plotconf.rewardid)
    -- local _, rewardItems = TaskModel:GetGiftConfById(self.plotconf.rewardid)
    -- for _, v in pairs(rewardItems) do
    --     v.Category = REWARD_TYPE.Item
    --     v.ConfId = v.confId
    -- end
    self.Items = itemDatas

    --固定文字国际化显示
    self._textTarget.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TRAGET_TASK")
    self._textPlotReward.text = StringUtil.GetI18n(I18nType.Commmon, "UI_PLOT_TASK_REWARD")
    self._bthReceivetitle.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_RECEIVE_AWARD_ALL")
    self:RefreshChapterMsg(itemDatas)
    self:ScheduleOnceFast(
        function()
            Event.Broadcast(EventDefines.NextNoviceStep, 1007)
        end,
        0.3
    )
    if GlobalVars.IsNoviceGuideStatus or GlobalVars.IsTriggerStatus then
        return
    end

    local isGuide = TaskPlotModel.GetGuideStage()
    
    if isGuide then
        self:SetTaskPlotGuide()
    else
        self.guider.visible = false
        local plotGuideData = TaskPlotModel.GetGuideData()
        local guideCount = 0
        local timeCount = plotGuideData.time
        self.refreshGuideFunc = function()
            if not self.guider.visible and not IsTouched then
                timeCount = timeCount - 1
            elseif IsTouched then
                IsTouched = false
                timeCount = plotGuideData.time
                self.guider.visible = false
            end
            if timeCount <= 0 and guideCount < plotGuideData.number then
                guideCount = guideCount + 1
                timeCount = plotGuideData.time
                self:SetTaskPlotGuide()
            end
            if guideCount == plotGuideData.number then
                self:UnScheduleFast(self.refreshGuideFunc)
                self.guider.visible = false
            end
        end
        self:ScheduleFast(self.refreshGuideFunc, 0.1)
    end
end

--章节任务排序 可领取>未完成>已领取
function TaskPlot:RefreshChapters()
    local Tasks = Model.GetMap(ModelType.ChapterTasksInfo)
    local AccTasks = Tasks.AccomplishedPlotTasks
    local UnlockedTasks = Tasks.UnlockedPlotTasks
    self.include = {}
    for _, v in ipairs(AccTasks) do
        if not v.AwardTaken then
            table.insert(self.include, v.Id)
        end
    end
    for _, v in ipairs(UnlockedTasks) do
        table.insert(self.include, v.Id)
    end
    for _, v in ipairs(AccTasks) do
        if v.AwardTaken then
            table.insert(self.include, v.Id)
        end
    end

    table.sort(
        self.include,
        function(a, b)
            return a < b
        end
    )
end

--刷新章节任务排序
function TaskPlot:RefreshChaptersShow()
    for i = 1, #self.include do
        local item = self._list:GetChildAt(i - 1)
        self:ChapterMsg(i - 1, item)
    end
end

--单个任务的内容
function TaskPlot:ChapterMsg(num, item)
    local plottaskId = self.include[num + 1]
    local finish = false
    local plottask = {}
    for _, v in pairs(self.msg.AccomplishedPlotTasks) do
        if plottaskId == v.Id then
            plottask = v
            finish = true
        end
    end
    if not next(plottask) then
        for _, v in pairs(self.msg.UnlockedPlotTasks) do
            if plottaskId == v.Id then
                plottask = v
            end
        end
    end
    item:Init(
        num,
        plottask,
        finish,
        function()
            self:Doclose()
        end
    )
end

--刷新章节任务显示
function TaskPlot:RefreshChapterMsg(rewardItems)
    dump(rewardItems)
    local icon, desc, title, titlekey, progress, finishNum, sumNum = TaskModel:GetPlotTaskMsg(self.msg)
    self._titleName.text = titlekey
    self._textChapter.text = title
    self._textDesc.text = desc
    self._textAP.text = StringUtil.GetI18n(I18nType.Commmon, "UI_PLOT_TASK_SCHEDULE", {num1 = finishNum, num2 = sumNum})
    --根据完成任务进度 判定是否可以领取
    if finishNum == sumNum then
        self._receive.selectedPage = CTR.UnLockd
    else
        self._receive.selectedPage = CTR.Lockd
    end
    --显示章节奖励
    self._longPressLabel.visible = false
    -- 长按提示框显示
    for i = 1, self._rewardlist.numItems do
        local item = self._rewardlist:GetChildAt(i - 1)
        if i > #rewardItems then
            item.visible = false
        else
            item.visible = true
            --item:SetAmount(rewardItems[i].amount)
            if rewardItems[i].isRes then
                rewardItems[i].Category = REWARD_TYPE.Res
            else
                rewardItems[i].Category = REWARD_TYPE.Item
            end
            rewardItems[i].ConfId = rewardItems[i].confId
            --item:SetData(rewardItems[i])
            --item:SetControl(2)
            --item:SetAmountMid(rewardItems[i].confId)
            
            local mid = GD.ItemAgent.GetItemInnerContent(rewardItems[i].confId)
            local icon,color = GD.ItemAgent.GetShowRewardInfo(rewardItems[i])
            item:SetShowData(icon,color,rewardItems[i].amount,nil,mid)

            self:AddListener(
                item.onTouchBegin,
                function()
                    local prop_name = rewardItems[i].title
                    local prop_desc = rewardItems[i].desc
                    self._longPressLabel:InitLabel(prop_name, prop_desc)
                    self._longPressLabel:SetArrowController(true)
                    self._longPressLabel:SetPos(40 + (item.size.x + 22) * (i - 1))
                    self._longPressLabel.visible = true
                end
            )
            self:AddListener(
                item.onTouchEnd,
                function()
                    self._longPressLabel.visible = false
                end
            )
        end
    end
end

--关闭界面
function TaskPlot:Doclose()
    UIMgr:Close("TaskPlot")
end

function TaskPlot:OnClose()
    if self.refreshGuideFunc then
        self:UnScheduleFast(self.refreshGuideFunc)
    end
    IsGotoGuide = false
    TaskPlotModel.SetGuideStage(false)
    self.guider:SetGuideScale(1)
    self.guider:SetPointerScale(1)
    self.guider.visible = false
end

local cutChargetIndex = 0

--对话栏,isStart是开始对话，false为结束的对话,isNext是否为下个对话
function TaskPlot:PlayDialog(isStart)
    if not next(Model[ModelType.ChapterTasksInfo]) then
        self.cutReviewConf = TaskModel.TaskPlotReview(#plotConf)
        self.cutReviewConf.start_dialog = nil
    else
        local chargeIndex = Model[ModelType.ChapterTasksInfo].CurrentChapter
        if isStart then
            self.cutReviewConf = TaskModel.TaskPlotReview(chargeIndex)
            cutChargetIndex = chargeIndex
        else
            self.cutReviewConf = TaskModel.TaskPlotReview(chargeIndex - 1)
            cutChargetIndex = chargeIndex - 1
        end
    end

    local dialogConf = nil
    if isStart then
        dialogConf = self.cutReviewConf.start_dialog
    else
        dialogConf = self.cutReviewConf.finish_dialog
    end

    --为空则直接退出
    if not dialogConf and isStart then
        GlobalVars.IsTaskPlotAnim = false
        return
    elseif not dialogConf and not isStart then --没有完成剧情
        self:OpenReview()
        return
    end
    local isEnd = false
    -- print("cutDialogIndex---------:", cutDialogIndex)
    local dialogContent = TaskModel.GetNextDialogConf(isStart, self.cutReviewConf.id, cutDialogIndex)
    cutDialogIndex = dialogContent and cutDialogIndex + 1 or cutDialogIndex
    local dialog = dialogContent
    if not dialog then
        print("dialog is nil:" .. table.inspect(dialog))
        return
    end
    local startDia, roleId = dialog.startDia, dialog.roleId
    -- print("roleId:" .. table.inspect(dialog.roleId))
    local roleConf = TaskModel.GetRoleConf(roleId)
    -- print("roleConf:" .. table.inspect(roleConf))
    local roleRes = {roleConf.roleRes[1], roleConf.roleRes[2]}
    local spokesmain = roleConf.spokesman
    local dialogText = startDia
    print("cutDialogIndex:", cutDialogIndex)
    print("length:", #dialogConf)
    isEnd = cutDialogIndex >= #dialogConf and true or false
    print("isEnd:", isEnd)
    -- print("cutDialogIndex:", cutDialogIndex)
    -- print("length:", #dialogConf)
    isEnd = cutDialogIndex >= #dialogConf and true or false
    -- print("isEnd:", isEnd)
    local diaLogInfo = {
        spokesMain = spokesmain,
        dialogText = dialogText,
        roleRes = roleRes,
        isStart = isStart,
        isEnd = isEnd
    }
    UIMgr:Open("Novice", nil, nil, diaLogInfo, true)
end

--打开剧情页面
function TaskPlot:OpenReview()
    local function dialogFunc()
        --剧情任务开始
        self:PlayDialog(true)
    end
    local chargeIndex = Model[ModelType.ChapterTasksInfo].CurrentChapter
    --结束后自动退出
    if not Model[ModelType.ChapterTasksInfo].CurrentChapter then
        return
    end
    UIMgr:Open("TaskPlotReview", chargeIndex, dialogFunc)
end

function TaskPlot:SetTaskPlotGuide()
    self.guider:SetGuideScale(1)
    self.guider:SetArrowSize(1)
    self.guider.visible = true
    local item = self:GetGuideItem()
    local posX, posY = 0
    local itemBtn = nil
    if item:GetChild("btnReceive") then
        local btn = item:GetChild("btnReceive")
        posX, posY = self._list.x + item.x + btn.x, self._list.y + item.y + btn.y
        itemBtn = btn
    else
        posX, posY = item.x, item.y
        itemBtn = item
    end
    -- btn:AddChild(self.guider)
    self._taskPlotItem:AddChild(self.guider)

    self.guider:SetGuideScale(0.6)
    self.guider:SetPointerScale(0.8)
    self.guider:SetTopAnim(false)
    self.guider:SetTrans(posX - self.guider.width / 2 + itemBtn.width / 2, posY - self.guider.height / 2 + itemBtn.height / 2)
    -- self.guider:SetTrans(577, 322)
end

function TaskPlot:GetGuideItem()
    --可领取状态
    if self._receive.selectedIndex == 0 then
        return self._btnReceive
    else
        local receiveItems = {}
        local jumpItems = {}
        for i = 1, self._list.numChildren do
            local item = self._list:GetChildAt(i - 1)
            if item._statectr.selectedIndex == 0 then
                table.insert(jumpItems, item)
            elseif item._statectr.selectedIndex == 1 and item.plottask.AwardTaken == false then
                table.insert(receiveItems, item)
            end
        end
        local sortByIdFunc = function(tempList)
            table.sort(
                tempList,
                function(a, b)
                    return a.plottask.Id < a.plottask.Id
                end
            )
        end

        if next(receiveItems) then
            sortByIdFunc(receiveItems)
            return receiveItems[1]
        else
            sortByIdFunc(jumpItems)
            return jumpItems[1]
        end
    end
end
function TaskPlot:SetNewNoviceGuide(taskPlotId)
    self.guider.visible = true
    self._taskPlotItem:AddChild(self.guider)
    self.guider:SetGuideScale(0.6)
    self.guider:SetPointerScale(0.8)
    self.guider:SetTopAnim(false)
    local item = nil
    local btn = nil
    for i = 1, self._list.numChildren do
        local itemEntity = self._list:GetChildAt(i - 1)
        if taskPlotId == itemEntity.plottask.Id and itemEntity._statectr.selectedIndex == 0 then
            item = itemEntity
            break
        end
    end
    if not item then
        return
    end
    btn = item:GetChild("btnReceive")
    local posX, posY = self._list.x + item.x + btn.x, self._list.y + item.y + btn.y
    self.guider:SetTrans(posX - self.guider.width / 2 + btn.width / 2, posY - self.guider.height / 2 + btn.height / 2)
end
return TaskPlot
