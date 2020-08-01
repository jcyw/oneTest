--[[
    author:{zhanzhang}
    time:2019-06-28 13:44:25
    function:{联盟宝藏}
]]
local UnionTask = UIMgr:NewUI("UnionTask")
local UnionModel = import("Model/UnionModel")

function UnionTask:OnInit()
    local view = self.Controller.contentPane
    self._btnReturn = view:GetChild("btnReturn")
    --self._btnHelp = view:GetChild("btnHelp")
    self._btnTaskList = view:GetChild("btnTaskList")
    self._btnMyTask = view:GetChild("btnMyTask")
    self._btnHelpTask = view:GetChild("btnHelpTask")
    self._contentList = view:GetChild("liebiao")
    self._btnRefresh = view:GetChild("btnRefresh")
    self._btnRefreshGold = view:GetChild("btnRefreshGold")
    self._textRefreshPrice = self._btnRefreshGold:GetChild("text")
    self._groupRefresh = view:GetChild("gruopRefresh")
    self._textRefreshTime = view:GetChild("textRefreshTime")
    self._iconTime = view:GetChild("iconTime")

    self._noListText = view:GetChild("text")

    self._controller = view:GetController("c1")
    self._btnController = view:GetController("c2")
    self.nowTaskType = 0
    self.isCheckJointTime = false
    self:OnRegister()
end

function UnionTask:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            self:Close()
        end
    )
    -- self:AddListener(self._btnHelp.onClick,
    --     function()
    --         Sdk.AiHelpShowSingleFAQ(ConfigMgr.GetItem("configWindowhelps", 1010).article_id)
    --     end
    -- )
    self:AddListener(self._btnRefresh.onClick,
        function()
            self:RefreshTaskRequest()
        end
    )
    self:AddListener(self._btnRefreshGold.onClick,
        function()
            self:RefreshTaskRequest()
        end
    )
    self.calTimeFunc = function()
        self:RefreshTaskCountDown()
    end
    --任务列表
    self:AddListener(self._btnTaskList.onClick,
        function()
            --关闭刷新界面
            self:ShowTaskList()
        end
    )
    --我的任务
    self:AddListener(self._btnMyTask.onClick,
        --帮助任务
        function()
            self:ShowMyTask()
        end
    )
    self:AddListener(self._btnHelpTask.onClick,
        function()
            self:ShowHelpTask()
        end
    )
    self:AddListener(self._btnView.onClick,
        function()
            self:ShowTaskList()
        end
    )
    self:AddEvent(
        EventDefines.UIUnionCooperationRefreshTaskList,
        function(NextFreeAt)
            self.nextFreeAt = NextFreeAt
            self:RefreshTaskList(UnionModel.GetCoordinationTask())
        end
    )
    self:AddEvent(
        EventDefines.UIOnFinishUnionTask,
        function(taskType)
            if taskType == 2 then
                self:RefreshMyTask(UnionModel.GetMyTask())
            else
                local list = UnionModel.GetMyHelpOtherTask()
                self:RefreshHelpTask(list)
            end
        end
    )
    --联盟协作任务刷新
    self:AddEvent(
        EventDefines.UIAllianceRefeshHelpTask,
        function()
            if self.nowTaskType == 1 then
                self:ShowTaskList()
            elseif self.nowTaskType == 2 then
                self:ShowMyTask()
            else
                self:ShowHelpTask()
            end
        end
    )
    self:AddEvent(
        EventDefines.UIUnionTeamTask,
        function()
            self:CheckCuePoint()
        end
    )
    self:AddEvent(
        EventDefines.UIAllianceTaskPonit,
        function()
            self:CheckCuePoint()
        end
    )
end

function UnionTask:CheckCuePoint()
    local sub = CuePointModel.SubType.Union.UnionTeamTask
    --CuePointModel:SetSingle(sub.TypeWaring, sub.NumberWaring, self._btnTaskList, CuePointModel.Pos.RightUp2515)
    CuePointModel:SetSingle(sub.Type, sub.NumberMyTask, self._btnMyTask, CuePointModel.Pos.RightUp2515)
    CuePointModel:SetSingle(sub.Type, sub.NumberHelpTask, self._btnHelpTask, CuePointModel.Pos.RightUp2515)
end

function UnionTask:SetController(index)
    self._controller.selectedIndex = index
    --设置Banner
    if index == 0 then
        self._banner.icon = UITool.GetIcon(GlobalBanner.UnionTeamTask2)
    elseif index == 1 then
        self._banner.icon = UITool.GetIcon(GlobalBanner.UnionTeamTask3)
    elseif index == 2 or index == 4 then
        self._banner.icon = UITool.GetIcon(GlobalBanner.UnionTeamTask1)
    end
end

--- 点击页面3个按钮
function UnionTask:ShowTaskList()
    self.nowTaskType = 1
    self:SetController(0)
    local helpStr = {}
    helpStr["number"] = UnionModel.GetRemainAcceptTimes()
    self._textGet.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TaskListTips_a", helpStr)
    self:RefreshTaskList(UnionModel.GetCoordinationTask())
end

function UnionTask:ShowMyTask()
    local list = UnionModel.GetMyTask()
    self.nowTaskType = 2
    if not list or #list == 0 then
        -- self._contentList:RemoveChildrenToPool()
        self:SetController(3)
    else
        self:SetController(1)
        self:RefreshMyTask(list)
    end
end

function UnionTask:ShowHelpTask()
    self.nowTaskType = 3
    self:SetController(2)
    local list = UnionModel.GetMyHelpOtherTask()
    self:RefreshHelpTask(list)
    local helpStr = {}
    helpStr["number"] = UnionModel.GetRemainHelpTimes()
    self._textHelp.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TaskHelpTips", helpStr)
end

function UnionTask:OnOpen(index)
    self:UnSchedule(self.calTimeFunc)
    if not index then
        index = 1
    end
    self.isCheckJointTime = UnionModel.CheckIsNotOverJoinTime()
    self:SetController(index - 1)
    self.RefreshTimes = UnionModel.AllianceTaskInfo.RefreshTimes
    self.nextFreeAt = UnionModel.NextFreeAt
    self.nextRefreshTime = UnionModel.NextRefreshTime

    self.nowTaskType = index
    if index == 1 then
        self:ShowTaskList()
    elseif index == 2 then
        self:ShowMyTask()
    elseif index == 3 then
        self:ShowHelpTask()
    end
    if UnionModel.GetRemainAcceptTimes() ~= 0 then
        self:Schedule(self.calTimeFunc, 1, true)
    end
    self:CheckCuePoint()
end

function UnionTask:Close()
    UIMgr:Close("UnionTask")
end

--刷新下次免费时间
function UnionTask:RefreshTaskCountDown()
    --下次刷新时间
    if UnionModel.GetRemainAcceptTimes() == 0 then
        self._iconTime.visible = false
        return
    end
    local delayRefreshTime = UnionModel.NextRefreshTime - Tool.Time()
    if (delayRefreshTime > 0) then
        self._iconTime.visible = true
        self._textRefreshTime.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Cooperative_Time", {time = TimeUtil.SecondToHMS(delayRefreshTime)})
    else
        self._iconTime.visible = false
        self._textRefreshTime.text = ""
    end

    if self.nowTaskType ~= 1 then
        return
    end

    local delayFreeTime = self.nextFreeAt - Tool.Time()

    if (delayFreeTime > 0) then
        local helpStr = {}
        helpStr["number"] = UnionModel.GetRemainAcceptTimes()
        helpStr["time"] = TimeUtil.SecondToHMS(delayFreeTime)
        self._textGet.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TaskListTips_b", helpStr)
    else
    end

    --判断入帮时间进行刷新
    if self.isCheckJointTime then
        if not UnionModel.CheckIsNotOverJoinTime() and self.nowTaskType == 1 then
            self.isCheckJointTime = false
            self:ShowTaskList()
        end
    end
end

function UnionTask:OnClose()
    self._contentList:RemoveChildrenToPool()
    self:UnSchedule(self.calTimeFunc)
end
--刷新当前显示列表
function UnionTask:RefreshList(tasks, taskType)
    self._contentList:RemoveChildrenToPool()
    -- self._btnTaskView.visible = false
    if not tasks or #tasks == 0 then
        if taskType == 1 then
            self._noListText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TaskTipsNull")
        elseif taskType == 2 then
            -- self._btnTaskView.visible = true
            self._noListText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_MyTaskNo")
        else
            self._noListText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_NoTask")
        end
        return
    end
    for i = 1, #tasks do
        local item = self._contentList:AddItemFromPool()
        item:Init(tasks[i], taskType)
    end
end

--刷新任务列表
function UnionTask:RefreshTaskList(tasks)
    --判断当日是否还可以刷新和领取
    self._btnRefresh.enabled = UnionModel.GetRemainAcceptTimes() ~= 0
    self._btnRefreshGold.enabled = UnionModel.GetRemainAcceptTimes() ~= 0
    self.payRefreshTime = self.RefreshTimes - Global.ATFreeRefreshTimes
    self:RefreshList(tasks, 1)
    if (self.payRefreshTime < 0) then
        self._btnController.selectedIndex = 1
    else
        local list = ConfigMgr.GetVar("ATRefreshFee")
        local price = 0
        if self.payRefreshTime + 1 > #list then
            price = list[#list]
        else
            price = list[self.payRefreshTime + 1]
        end
        self._textRefreshPrice.text = price
        self._btnController.selectedIndex = 0
    end
    self:RefreshTaskCountDown()
end

function UnionTask:RefreshMyTask(tasks)
    self:RefreshList(tasks, 2)
end

function UnionTask:RefreshHelpTask(tasks)
    self:RefreshList(tasks, 3)
end
--点击刷新任务
function UnionTask:OnClickRefreshTask()
    local refreshFunc = function()
        UnionModel.GetUnionInfo(
            function(rsp)
                Net.AllianceTasks.Refresh(
                    rsp.Uuid,
                    function(data)
                        self.nextFreeAt = data.NextFreeAt
                        self.nextRefreshTime = data.NextRefreshTime
                        self.RefreshTimes = data.AllianceTaskTimes.RefreshTimes
                        UnionModel.InitHelpTask(data)
                        self:RefreshTaskList(UnionModel.GetCoordinationTask())
                        Event.Broadcast(EventDefines.UIUnionTaskRefresh)
                    end
                )
            end
        )
    end
    if (self.payRefreshTime >= 0) then
        local list = Global.ATRefreshFee
        local price = 0
        if self.payRefreshTime + 1 > #list then
            price = list[#list]
        else
            price = list[self.payRefreshTime + 1]
        end

        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TaskRefresh_Tips", {diamond_num = price}),
            gold = price,
            sureCallback = function()
                refreshFunc()
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        refreshFunc()
    end
end

function UnionTask:RefreshTaskRequest()
    --加入联盟未到冷却时间
    if UnionModel.CheckIsNotOverJoinTime() then
        TipUtil.TipById(50179)
        return
    end
    --刷新前检测是否有高品质任务
    local highTask = false
    local list = UnionModel.GetCoordinationTask()
    for i = 1, #list do
        local taskConfig = ConfigMgr.GetItem("configAllianceTasks", list[i].ConfId)
        if taskConfig.grade > 3 then
            highTask = true
        end
    end

    if highTask then
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TaskTranslate"),
            sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "Button_Translate"),
            cancelBtnText = StringUtil.GetI18n(I18nType.Commmon, "Button_Off"),
            btnGray = false,
            sureCallback = function()
                self:OnClickRefreshTask()
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        self:OnClickRefreshTask()
    end
end

return UnionTask
