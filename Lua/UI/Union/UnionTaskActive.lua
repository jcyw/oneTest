--author: 	Amu
--time:		2019-07-02 10:22:47

local TASKTYPE = {
    DayTask = 1,        --日常任务
    PresidentTask = 2   --会长任务
}

local UnionModel = import("Model/UnionModel")

local UnionTaskActive = UIMgr:NewUI("UnionTaskActive")
UnionTaskActive.selectItem = nil

function UnionTaskActive:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._btnReturn = self._view:GetChild("btnReturn")

    self._textDescribe = self._view:GetChild("textDescribe")

    self._group1 = self._view:GetChild("groupBtn")
    self._group2 = self._view:GetChild("groupOrdinary")
    self._group3 = self._view:GetChild("groupPresident")

    self._dayListView = self._view:GetChild("liebiao")
    self._preListView = self._view:GetChild("liebiaoPresident")

    self._btnOrdinary = self._view:GetChild("btnOrdinary")
    self._btnPresident = self._view:GetChild("btnPresident")
    -- self._btnPresident.enabled = false --todo临时屏蔽
    self._btnGetAll = self._view:GetChild("btnGetAll")

    self._bgDownTag = self._view:GetChild("bgDownTag")

    self._ctrView = self._view:GetController("c1")

    self._h = self._group1.height
    self._dayListViewH = self._dayListView.height
    self._group2Y = self._group2.y
    self._bgDownTagY = self._bgDownTag.y
    self._btnGetAllY = self._btnGetAll.y

    self._imageY = self._banner.y
    self._imageTopY = self._group1.y

    self._dayTaskInfo = {}

    self._textDescribe.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_AllianceTask_Tips")

    local dayTaskInfo = ConfigMgr.GetList("configAllianceDailyTasks")
    for _,v in ipairs(dayTaskInfo) do
        if not self._dayTaskInfo[v.task_type] then
            self._dayTaskInfo[v.task_type] = {}
        end
        table.insert(self._dayTaskInfo[v.task_type], v)
    end
    for _,v in ipairs(self._dayTaskInfo) do
        table.sort(v, function(a, b)
            return a.target < b.target
        end)
    end
    self._bossTaskInfo = ConfigMgr.GetList("configAllianceBossTasks")
    if not UnionModel.bossTasks then
        Net.AllianceDaily.AlliancePresientTaskInfo(function(msg)
            UnionModel.bossTasks = msg.Tasks
            for _,v in ipairs(self._bossTaskInfo)do
                for _,task in ipairs(UnionModel.bossTasks)do
                    if v.id == task.ConfId then
                        v.Status = task.Status
                        break
                    end
                end
            end
        end)
    else
        for _,v in ipairs(self._bossTaskInfo)do
            for _,task in ipairs(UnionModel.bossTasks)do
                if v.id == task.ConfId then
                    v.Status = task.Status
                    break
                end
            end
        end
    end
    self:InitEvent()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.UnionTask)
end

function UnionTaskActive:OnOpen(taskInfo)
    self.taskInfo = taskInfo
    self.type = TASKTYPE.DayTask
    self:ChangePage()
    if UnionModel:CheckUnionOwner() then
        self._group1.visible = true
        self._banner.y = self._imageY
        -- self._group2.y = self._group2Y + self._h
        self._bgDownTag.y = self._bgDownTagY + GRoot.inst.height-1334
        self._btnGetAll.y = self._btnGetAllY + GRoot.inst.height-1334
        self._dayListView:SetSize(self._dayListView.width, self._dayListViewH - self._h)
    else
        self._group1.visible = false
        self._banner.y = self._imageTopY
        -- self._group2.y = self._group2Y
        self._bgDownTag.y = self._bgDownTagY + GRoot.inst.height-1334
        self._btnGetAll.y = self._btnGetAllY + GRoot.inst.height-1334
        self._dayListView:SetSize(self._dayListView.width, self._dayListViewH)
    end
    self:CheckCuePoint()
    self:RefreshBtnState()
    self:RefreshListView()

    --打开界面刷新联盟任务提示点
    Event.Broadcast(EventDefines.UIAllianceTaskPonit)
end

function UnionTaskActive:CheckCuePoint()
    local sub = CuePointModel.SubType.Union.UnionTask
    CuePointModel:SetSingle(sub.Type, sub.NumberTask, self._btnOrdinary, CuePointModel.Pos.RightUp2515)
    CuePointModel:SetSingle(sub.Type, sub.NumberOwner, self._btnPresident, CuePointModel.Pos.RightUp2515)
end

function UnionTaskActive:Close()
    UIMgr:Close("UnionTaskActive")
end

function UnionTaskActive:InitEvent( )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnOrdinary.onClick,function()
        if self.type == TASKTYPE.DayTask then
            return
        end
        self.type = TASKTYPE.DayTask
        self:ChangePage()
    end)

    self:AddListener(self._btnPresident.onClick,function()
        if self.type == TASKTYPE.PresidentTask then
            return
        end
        self.type = TASKTYPE.PresidentTask
        self:ChangePage()
    end)

    self:AddListener(self._btnGetAll.onClick,function()
        local state
        local index = 0
        for _,v in pairs(self._dayTaskInfo[1])do
            if v.target > self.taskInfo.ActiveCount then
                state = RECEIVE_STATE.CantReceive
            else
                state = RECEIVE_STATE.CanReceive
            end
            for _,id in pairs(self.taskInfo.ClaimedActive)do
                if v.id == id then
                    state = RECEIVE_STATE.HavaReceive
                end
            end
            if state == RECEIVE_STATE.CanReceive then
                -- self:Claim(v.id)
                index = index + 1
            end
        end

        for _,v in pairs(self._dayTaskInfo[2])do --
            if v.target > self.taskInfo.ContributionCount then
                state = RECEIVE_STATE.CantReceive
            else
                state = RECEIVE_STATE.CanReceive
            end
            for _,id in pairs(self.taskInfo.ClaimedContribution)do
                if v.id == id then
                    state = RECEIVE_STATE.HavaReceive
                end
            end
            if state == RECEIVE_STATE.CanReceive then
                -- self:Claim(v.id)
                index = index + 1
            end
        end
        if index == 0 then
            TipUtil.TipById(50260)
        else
            Net.AllianceDaily.ClaimAll(function(msg)
                --播放领奖动画
                UITool.ShowReward(msg.Rewards)
    
                self.taskInfo.ClaimedActive = msg.ClaimedActive
                self.taskInfo.ClaimedContribution = msg.ClaimedContribution
                -- self._dayListView.numItems = #self._dayTaskInfo
                self:RefreshListView()
                self:RefreshBtnState()
                TipUtil.TipById(50273)
                UnionModel:RefreshUnionTaskNotRead()
                Event.Broadcast(EventDefines.UIAllianceTaskPonit)
            end)
        end
    end)

    self._dayListView.itemRenderer = function(index, item)
        if not index and self.taskInfo then 
            return
        end
        if index == 0 then
            item:SetData(self._dayTaskInfo[index+1], self.taskInfo.ActiveCount, self.taskInfo.ClaimedActive)
        else
            item:SetData(self._dayTaskInfo[index+1], self.taskInfo.ContributionCount, self.taskInfo.ClaimedContribution)
        end
    end

    self._preListView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self._bossTaskInfo[index+1])
    end
    self._preListView:SetVirtual()

    self:AddEvent(TASKACTIVETYPE.Claim, function(taskConfId)
        self:Claim(taskConfId)
    end)

    self:AddEvent(EventDefines.UIAllianceBossTaskPonit, function()
        for _,v in ipairs(self._bossTaskInfo)do
            for _,task in ipairs(UnionModel.bossTasks)do
                if v.id == task.ConfId then
                    v.Status = task.Status
                    break
                end
            end
        end
        self:RefreshListView()
    end)
    self:AddEvent(EventDefines.UIUnionTask, function()
        self:CheckCuePoint()
    end)
end

function UnionTaskActive:RefreshBtnState()
    self._btnGetAll.enabled = false
    local state
    for _,v in pairs(self._dayTaskInfo[1])do --
        if v.target > self.taskInfo.ActiveCount then
            state = RECEIVE_STATE.CantReceive
        else
            state = RECEIVE_STATE.CanReceive
        end
        for _,id in pairs(self.taskInfo.ClaimedActive)do
            if v.id == id then
                state = RECEIVE_STATE.HavaReceive
            end
        end
        if state == RECEIVE_STATE.CanReceive then
            self._btnGetAll.enabled = true
            return
        end
    end

    for _,v in pairs(self._dayTaskInfo[2])do --
        if v.target > self.taskInfo.ContributionCount then
            state = RECEIVE_STATE.CantReceive
        else
            state = RECEIVE_STATE.CanReceive
        end
        for _,id in pairs(self.taskInfo.ClaimedContribution)do
            if v.id == id then
                state = RECEIVE_STATE.HavaReceive
            end
        end
        if state == RECEIVE_STATE.CanReceive then
            self._btnGetAll.enabled = true
            return
        end
    end
end


function UnionTaskActive:RefreshListView()
    if self.type == TASKTYPE.DayTask then
        self._dayListView.numItems = #self._dayTaskInfo
    elseif self.type == TASKTYPE.PresidentTask then
        self._preListView.numItems = #self._bossTaskInfo
    end
end

function UnionTaskActive:ChangePage(type)
    if self.type == TASKTYPE.DayTask then
        self._group2.visible = true
        self._group3.visible = false
        self._ctrView.selectedIndex = 0
    elseif self.type == TASKTYPE.PresidentTask then
        self._group2.visible = false
        self._group3.visible = true
        self._ctrView.selectedIndex = 1
    end
    self:RefreshListView()
end

function UnionTaskActive:Claim(taskConfId)
    Net.AllianceDaily.Claim(taskConfId, function(msg)
        --播放领奖动画
        UITool.ShowReward(msg.Rewards)

        self.taskInfo.ClaimedActive = msg.ClaimedActive
        self.taskInfo.ClaimedContribution = msg.ClaimedContribution
        -- self._dayListView.numItems = #self._dayTaskInfo
        self:RefreshListView()
        self:RefreshBtnState()
        TipUtil.TipById(50273)
        UnionModel:RefreshUnionTaskNotRead()
        Event.Broadcast(EventDefines.UIAllianceTaskPonit)
    end)
end

return UnionTaskActive