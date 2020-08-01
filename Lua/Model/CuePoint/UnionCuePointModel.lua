--[[
    Author: songzeming
    Function: 公用模板 联盟提示红点
]]
local UnionCuePointModel = {}

local UnionModel = import("Model/UnionModel")
local UnionHelpModel = import("Model/Union/UnionHelpModel")

--联盟提示点初始化
function UnionCuePointModel:InitUnion()
    if self.init then
        return
    end
    self.init = true

    --跨天刷新通知
    Event.AddListener(
            TIME_REFRESH_EVENT.Refresh,
            function()
                self:CheckUnionPoint()
            end
    )
    -------------------------------------------------------------------- 联盟战争
    --联盟集结变化
    Event.AddListener(
            EventDefines.UIOnRefreshAggregation,
            function(rsp)
                self:CheckUnionWarfare()
            end
    )
    --联盟战争信息创建
    Event.AddListener(
            EventDefines.UIAllianceBattleCreate,
            function(rsp)
                self:CheckUnionWarfare()
            end
    )
    --接受到进攻预警
    Event.AddListener(
            ApiMap.protos.PT_MarchWarning,
            function(rsp)
                self:CheckUnionWarfare()
            end
    )
    --联盟战争取消
    Event.AddListener(
            EventDefines.UIAllianceBattleCancel,
            function(rsp)
                self:CheckUnionWarfare()
            end
    )
    --------------------------------------------------------------------联盟合作任务
    --联盟协作任务刷新
    Event.AddListener(
            EventDefines.UIAllianceRefeshHelpTask,
            function()
                self:CheckUnionTeamTask()
            end
    )
    --联盟协作任务领奖刷新
    Event.AddListener(
            EventDefines.UIOnFinishUnionTask,
            function()
                self:CheckUnionTeamTask()
            end
    )
    --刷新协作任务列表
    Event.AddListener(
            EventDefines.UIUnionCooperationRefreshTaskList,
            function()
                self:CheckUnionTeamTask()
            end
    )
    Event.AddListener(
            EventDefines.UIUnionTaskRefresh,
            function()
                self:CheckUnionTeamTask()
            end
    )
    -------------------------------------------------------------------- 联盟科技
    Event.AddListener(
            EventDefines.UIUnionScience,
            function()
                self:CheckUnionScience()
            end
    )
    -------------------------------------------------------------------- 联盟帮助
    Event.AddListener(
            EventDefines.UIUnionHelp,
            function()
                self:CheckUnionHelp()
            end
    )
    -------------------------------------------------------------------- 联盟任务
    Event.AddListener(
            EventDefines.UIAllianceTaskPonit,
            function()
                self:CheckUnionTask()
            end
    )
    Event.AddListener(
            EventDefines.UIAllianceBossTaskPonit,
            function()
                self:CheckUnionTask()
            end
    )
    -------------------------------------------------------------------- 联盟管理
    Event.AddListener(
            EventDefines.UIUnionManger,
            function()
                self:CheckUnionManager()
            end
    )
    -------------------------------------------------------------------- 退出联盟、加入联盟、创建联盟
    --退出联盟
    Event.AddListener(
            UNION_EVENT.Exit,
            function()
                self:CheckUnionPoint()
            end
    )
    --加入联盟
    Event.AddListener(
            EventDefines.UIAllianceJoin,
            function()
                self:CheckUnionPoint()
            end
    )
    --创建联盟
    Event.AddListener(
            EventDefines.UIAllianceCreate,
            function()
                self:CheckUnionPoint()
            end
    )

    self:CheckUnionPoint()
end

--检测是否加入联盟
local function CheckJoin()
    if UnionModel.CheckJoinUnion() then
        return true
    else
        CuePointModel:ResetUnion()
        return false
    end
end

--检测联盟提示点显示
function UnionCuePointModel:CheckUnionPoint()
    if not CheckJoin() then
        return
    end
    self:CheckUnionWarfare()
    self:CheckUnionTeamTask()
    self:CheckUnionScience()
    self:CheckUnionHelp()
    self:CheckUnionTask()
    self:CheckUnionMember()
    self:CheckUnionManager()
end

--联盟战争
function UnionCuePointModel:CheckUnionWarfare()
    -- Log.Info("提示点检测：联盟战争")
    if not CheckJoin() then
        return
    end
    UnionModel.RequestAllianceBattle(
        Model.Player.AllianceId,
        function(rsp)
            local sub = CuePointModel.SubType.Union.UnionWarfare
            sub.NumberBattles = #rsp.Battles
            sub.NumberDefences = #rsp.Defences
            sub.Number = sub.NumberBattles + sub.NumberDefences
            CuePointModel:CheckUnion()
            Event.Broadcast(EventDefines.UIUnionMainList, sub.Key)
            Event.Broadcast(EventDefines.UIUnionWarfare)
        end
    )
end

--联盟合作任务
function UnionCuePointModel:CheckUnionTeamTask()
    Log.Info("提示点检测：联盟合作任务")
    if not CheckJoin() then
        return
    end
    local numMine, numOther = UnionModel.GetTeamTaskRewardCount()
    local sub = CuePointModel.SubType.Union.UnionTeamTask
    sub.NumberWaring = UnionModel.CheckFinishTaskCount()
    sub.NumberMyTask = numMine
    sub.NumberHelpTask = numOther
    sub.Number = 0
    CuePointModel:CheckUnion()
    Event.Broadcast(EventDefines.UIUnionMainList, sub.Key)
    Event.Broadcast(EventDefines.UIUnionTeamTask)
end

--联盟科技捐献
function UnionCuePointModel:CheckUnionScience()
    -- Log.Info("提示点检测：联盟科技捐献")
    if not CheckJoin() then
        return
    end
    local sub = CuePointModel.SubType.Union.UnionScience
    sub.NumberWaring = Model.Player.AllianceTechCanContri and 1 or 0
    CuePointModel:CheckUnion()
    Event.Broadcast(EventDefines.UIUnionMainList, sub.Key)
end

--联盟帮助
function UnionCuePointModel:CheckUnionHelp()
    -- Log.Info("提示点检测：联盟帮助")
    if not CheckJoin() then
        return
    end
    local sub = CuePointModel.SubType.Union.UnionHelp
    sub.Number = UnionHelpModel.GetHelpNumber()
    CuePointModel:CheckUnion()
    Event.Broadcast(EventDefines.UIUnionMainList, sub.Key)
end

--联盟任务
function UnionCuePointModel:CheckUnionTask()
    -- Log.Info("提示点检测：联盟任务")
    if not CheckJoin() then
        return
    end
    local sub = CuePointModel.SubType.Union.UnionTask
    sub.NumberTask = UnionModel:GetNotReadUnionTask()
    sub.NumberOwner = Model.Player.AlliancePos == Global.AlliancePosR5 and UnionModel:GetNotReadUnionBossTask() or 0
    sub.Number = sub.NumberTask + sub.NumberOwner
    CuePointModel:CheckUnion()
    Event.Broadcast(EventDefines.UIUnionMainList, sub.Key)
    Event.Broadcast(EventDefines.UIUnionTask)
end

--联盟成员
function UnionCuePointModel:CheckUnionMember()
    -- Log.Info("提示点检测：联盟成员")
    if not CheckJoin() then
        return
    end
    local sub = CuePointModel.SubType.Union.UnionMember
    if UnionModel.CheckViewApply() then
        --有权限审批 获取入盟申请
        Net.Alliances.GetAllApplies(
            Model.Player.AllianceId,
            function(rsp)
                sub.NumberWaring = #rsp.AllianceApplies
                CuePointModel:CheckUnion()
                Event.Broadcast(EventDefines.UIUnionMainMember)
            end
        )
    else
        sub.NumberWaring = 0
        CuePointModel:CheckUnion()
        Event.Broadcast(EventDefines.UIUnionMainMember)
    end
end

--联盟管理
function UnionCuePointModel:CheckUnionManager()
    -- Log.Info("提示点检测：联盟管理")
    if not CheckJoin() then
        return
    end
    local sub = CuePointModel.SubType.Union.UnionManager
    sub.NumberVote = UnionModel:GetNotVoteAmount()
    sub.NumberMessage = UnionModel:GetNotReadMsgAmount()
    sub.NumberN = sub.NumberVote + sub.NumberMessage
    sub.Number = sub.NumberVote
    CuePointModel:CheckUnion()
    Event.Broadcast(EventDefines.UIUnionMainManger)
end

return UnionCuePointModel
