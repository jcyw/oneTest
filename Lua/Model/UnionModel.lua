if UnionModel then
    return UnionModel
end
local BuildModel = import("Model/BuildModel")
local UnionInfoModel = import("Model/Union/UnionInfoModel")
local UnionMemberModel = import("Model/Union/UnionMemberModel")
local GuidedModel = import("Model/GuideControllerModel")
local GlobalVars = GlobalVars
UnionModel = {}

UnionModel.notReadAmount = 0
UnionModel.notReadHelpAmount = 0
UnionModel.notReadUnionTask = 0
UnionModel.notReadUnionBossTask = 0
UnionModel.bossTasks = nil
UnionModel.unionAttackPointList = {}
UnionModel.unionDefendPointList = {}
UnionModel.notVoteList = {}
UnionModel.techModels = {}
UnionModel.notReadUnionAttackList = {}

function UnionModel:Init()
    self.newMsgId = Model.AllMessageIndex
    self:InitEvent()
end

function UnionModel:InitEvent()
    Event.AddListener(
        EventDefines.AllianceMessage,
        function(msg)
            if msg.AllianceId == Model.Player.AllianceId then
                self.newMsgId = msg.MessageId
                Model.UnreadAllianceMessages = Model.UnreadAllianceMessages + 1
            end
        end
    )

    Event.AddListener(
        EventDefines.UIAllianceJoin,
        function()
            UnionModel:RefreshUnionTaskNotRead()
        end
    )
end

function UnionModel:GetNotReadAmount() --联盟未读
    local amount = 0
    local flag = nil

    if not (Model.Player.AllianceId == "") then
        amount = amount + self:GetNotReadMsgAmount()
        amount = amount + self:GetNotVoteAmount()
        amount = amount + self:GetNotReadHelpMsgAmount()
        amount = amount + self:GetWarfarePointAmount()
        amount = amount + self:GetNotReadUnionTask()
        amount = amount + self:GetNotReadUnionBossTask()
        flag = self:GetNotReadTechAmount()
    --TODO
    end

    -- if amount <= 0 and flag then
    --     return flag
    -- end
    return math.ceil(amount), flag
end

function UnionModel:GetNotReadManagerAmount() --联盟管理未读
    local amount = 0

    amount = amount + self:GetNotReadMsgAmount()
    amount = amount + self:GetNotVoteAmount()
    --TODO

    return math.ceil(amount)
end

function UnionModel:GetNotReadMsgAmount() --联盟留言未读
    -- local oldMsgId = PlayerDataModel:GetData(PlayerDataEnum.UnionMsgId)
    -- if not oldMsgId then
    --     oldMsgId = 0
    -- end
    -- return math.ceil(self.newMsgId - oldMsgId)
    return math.ceil(Model.UnreadAllianceMessages)
end

function UnionModel:GetNotVoteAmount() --联盟投票  未投
    return #self.notVoteList
end

function UnionModel:GetNotReadHelpMsgAmount() --联盟帮助信息未读
    return self.notReadHelpAmount
end

function UnionModel:GetWarfarePointAmount()
    return #self.unionAttackPointList + #self.unionDefendPointList
end

function UnionModel:GetNotReadAttackAmount()
    return #self.notReadUnionAttackList
end

function UnionModel:RefreshUnionTaskNotRead()
    if Model.Player.AllianceId == "" then
        return
    end
    Net.AllianceDaily.Info(
        Model.Player.AllianceId,
        function(msg)
            self.taskInfo = msg
            self._dayTaskInfo = {}
            self.notReadUnionTask = 0
            local dayTaskInfo = ConfigMgr.GetList("configAllianceDailyTasks")
            for _, v in ipairs(dayTaskInfo) do
                if not self._dayTaskInfo[v.task_type] then
                    self._dayTaskInfo[v.task_type] = {}
                end
                table.insert(self._dayTaskInfo[v.task_type], v)
            end
            for _, v in pairs(self._dayTaskInfo[1]) do --
                if v.target <= self.taskInfo.ActiveCount then
                    self.notReadUnionTask = self.notReadUnionTask + 1
                end
                for _, id in pairs(self.taskInfo.ClaimedActive) do
                    if v.id == id then
                        self.notReadUnionTask = self.notReadUnionTask - 1
                        break
                    end
                end
            end

            for _, v in pairs(self._dayTaskInfo[2]) do --
                if v.target <= self.taskInfo.ContributionCount then
                    self.notReadUnionTask = self.notReadUnionTask + 1
                end
                for _, id in pairs(self.taskInfo.ClaimedContribution) do
                    if v.id == id then
                        self.notReadUnionTask = self.notReadUnionTask - 1
                        break
                    end
                end
            end
            Event.Broadcast(EventDefines.UIAllianceTaskPonit)
        end
    )
end

--联盟任务未读
function UnionModel:GetNotReadUnionTask()
    return self.notReadUnionTask
end

function UnionModel:RefreshUnionBossTaskNotRead()
    if Model.Player.AllianceId == "" then
        return
    end
    self.notReadUnionBossTask = 0
    if not self.bossTasks then
        Net.AllianceDaily.AlliancePresientTaskInfo(
            function(msg)
                local a = 1
                self.bossTasks = msg.Tasks
                for _, v in ipairs(self.bossTasks) do
                    if v.Status == UNION_BOSS_TASK.APTStatusFinished then
                        self.notReadUnionBossTask = self.notReadUnionBossTask + 1
                    end
                end
                Event.Broadcast(EventDefines.UIAllianceBossTaskPonit)
            end
        )
    else
        for _, v in ipairs(self.bossTasks) do
            if v.Status == UNION_BOSS_TASK.APTStatusFinished then
                self.notReadUnionBossTask = self.notReadUnionBossTask + 1
            end
        end
        Event.Broadcast(EventDefines.UIAllianceBossTaskPonit)
    end
end

--联盟会长任务未读
function UnionModel:GetNotReadUnionBossTask()
    return self.notReadUnionBossTask
end

--联盟科技未读 （是   ！）
function UnionModel:GetNotReadTechAmount()
    return Model.Player.AllianceTechCanContri and "!" or nil
end

--登录初始化联盟战争红点信息
function UnionModel.InitUnionWarfarePoint()
    UnionModel.RequestAllianceBattle(
        Model.Player.AllianceId,
        function(rsp)
            local attackData = {}
            local defendData = {}
            local notReadUnionAttackData = {}

            for _, v in pairs(rsp.Battles) do
                if v.UserId ~= Model.Account.accountId
                and v.MemberLimit>1 then
                    table.insert(attackData, v.Uuid)
                end
            end

            for _, v in pairs(rsp.Defences) do
                table.insert(defendData, v.Uuid)
            end

            UnionModel.unionAttackPointList = attackData
            UnionModel.unionDefendPointList = defendData

            -- 找出未读的联盟集结进攻信息
            local list = PlayerDataModel:GetData(PlayerDataEnum.ReadUnionAttackIds)
            list = type(list) == "table" and list or {}
            for _,v in pairs(attackData) do
                local isNotRead = true
                for _,v1 in pairs(list) do
                    if v == v1 then
                        isNotRead = false
                        break
                    end
                end

                if isNotRead then
                    table.insert(notReadUnionAttackData, v)
                end
            end
            UnionModel.notReadUnionAttackList = notReadUnionAttackData

            -- 删除已读缓存中结束的集结进攻信息
            for k,v in pairs(list) do
                local notExist = true
                for _,v1 in pairs(attackData) do
                    if v == v1 then
                        notExist = false
                        break
                    end
                end

                if notExist then
                    table.remove(list, k)
                end
            end
            PlayerDataModel:SetData(PlayerDataEnum.ReadUnionAttackIds, list)
        end
    )
end

--请求集结信息
function UnionModel.RequestAllianceBattle(id, cb)
    if Model.Player.AllianceId == "" then
        return
    end
    Net.AllianceBattle.Infos(id, cb)
end

--添加联盟进攻红点信息
function UnionModel.AddOneUnionAttackPoint(data)
    local uuid = data
    local userId = 0
    local single = false --集结
    local allianceId = Model.Player.AllianceId
    if type(data) == "table" then
        uuid = data.Uuid
        single = data.Single
        allianceId =  data.AllianceId
        userId =  data.UserId or 0
    end

    if Model.Player.AllianceId
    and Model.Player.AllianceId == allianceId
    and userId ~= Model.Account.accountId
    and not single
    then
        table.insert(UnionModel.unionAttackPointList, uuid)
        table.insert(UnionModel.notReadUnionAttackList, uuid)
        local buildModel = BuildModel.FindByConfId(Global.BuildingJointCommand)
        if buildModel then
            local build = BuildModel.GetObject(buildModel.Id)
            if build then
                build:UnionWarfareAnim(true)
            end
        end
    end

    
    --设置集结指挥部气泡
    --[[if Model.Player.AllianceId then
        UnionModel.RequestAllianceBattle(Model.Player.AllianceId, function(rsp)
            local list = rsp.Battles
            local isShow = true
            for _, v in pairs(list) do
                -- 自己建的联盟进攻不显示气泡
                if v.UserId == Model.Account.accountId then
                    local list = PlayerDataModel:GetData(PlayerDataEnum.ReadUnionAttackIds)
                    list = type(list) == "table" and list or {}
                    table.insert(list, v.Uuid)
                    PlayerDataModel:SetData(PlayerDataEnum.ReadUnionAttackIds, list)
                    isShow = false
                    break;
                end
            end
            
            if isShow then
                table.insert(UnionModel.notReadUnionAttackList, uuid)

                local buildModel = BuildModel.FindByConfId(Global.BuildingJointCommand)
                if buildModel then
                    local build = BuildModel.GetObject(buildModel.Id)
                    if build then
                        build:UnionWarfareAnim(true)
                    end
                end
            end
        end)
    end]]--
end

--添加联盟防御红点信息
function UnionModel.AddOneUnionDefendPoint(uuid)
    table.insert(UnionModel.unionDefendPointList, uuid)
end

--去掉联盟进攻红点信息
function UnionModel.RemoveUnionAttackPoint(uuid)
    for k, v in pairs(UnionModel.unionAttackPointList) do
        if v == uuid then
            table.remove(UnionModel.unionAttackPointList, k)
            break;
        end
    end

    for k, v in pairs(UnionModel.notReadUnionAttackList) do
        if v == uuid then
            table.remove(UnionModel.notReadUnionAttackList, k)
            break;
        end
    end

    local list = PlayerDataModel:GetData(PlayerDataEnum.ReadUnionAttackIds)
    list = type(list) == "table" and list or {}
    for k, v in pairs(list) do
        if v == uuid then
            table.remove(list, k)
            break;
        end
    end
    PlayerDataModel:SetData(PlayerDataEnum.ReadUnionAttackIds, list)
end

--去掉联盟防御红点信息
function UnionModel.RemoveUnionDefendPoint(uuid)
    for k, v in pairs(UnionModel.unionDefendPointList) do
        if v == uuid then
            table.remove(UnionModel.unionDefendPointList, k)
            break;
        end
    end
end

--重置联盟进攻红点信息
function UnionModel.ResetUnionAttackPoint()
    UnionModel.unionAttackPointList = {}
end

--重置联盟防御红点信息
function UnionModel.ResetUnionDefendPoint()
    UnionModel.unionDefendPointList = {}
end

--清空联盟进攻未读信息
function UnionModel.ResetNotReadUnionAttackList()
    local list = PlayerDataModel:GetData(PlayerDataEnum.ReadUnionAttackIds)
    list = type(list) == "table" and list or {}
    for _,v in pairs(UnionModel.notReadUnionAttackList) do
        table.insert(list, v)
    end
    PlayerDataModel:SetData(PlayerDataEnum.ReadUnionAttackIds, list)

    UnionModel.notReadUnionAttackList = {}

    --去掉集结指挥部气泡
    local buildModel = BuildModel.FindByConfId(Global.BuildingJointCommand)
    if buildModel then
        local build = BuildModel.GetObject(buildModel.Id)
        if build then
            build:UnionWarfareAnim(false)
        end
    end
end

-------------------------------------------------获取联盟相关信息
--[[
   获取联盟信息 [可能会延迟,请在回调中处理]
   cb 回调 [必传] 获取联盟信息每次都要请求服务器,防止数据刷新不及时
   unionId 联盟ID [可不传] 传-获取指定联盟信息 不传-获取自己联盟信息
]]
function UnionModel.GetUnionInfo(cb, unionId)
    if not UnionModel.CheckJoinUnion() and not unionId then
        cb()
        return
    end
    unionId = unionId and unionId or Model.Player.AllianceId
    Net.Alliances.Info(
        unionId,
        function(rsp)
            cb(rsp.Alliance)
        end
    )
end
--请求自己联盟信息
function UnionModel.RequestUnionInfo(cb)
    Net.Alliances.Info(
        Model.Player.AllianceId,
        function(rsp)
            UnionInfoModel.SetInfo(rsp.Alliance)
            UnionInfoModel.SetPermissions(rsp.DisabledPermissions)
            UnionMemberModel.SetMembers(rsp.Members)
            UnionMemberModel.SetApplyOfficers(rsp.ApplyOfficers)
            cb()
        end
    )
end
--获取自己联盟信息 异步
function UnionModel.GetMineUnionInfo(cb)
    local info = UnionInfoModel.GetInfo()
    if not info or next(info) == nil then
        UnionModel.RequestUnionInfo(cb)
    else
        cb()
    end
end

function UnionModel.GetUnionNotice()
    local notice = UnionInfoModel.GetInfo().Announcement
    if notice == "" then
        notice = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceDynamic_Default")
    end
    return notice
end

function UnionModel.SetUnionNotice(notice)
    local info = UnionInfoModel.GetInfo()
    info.Announcement = notice
end

--检测是否满足联盟权限 (必须提前进入联盟界面才生效)
function UnionModel.CheckUnionPermissions(id)
    local conf = ConfigMgr.GetItem("configAlliancePermissions", id)
    for _, v in pairs(conf.members) do
        if v == Model.Player.AlliancePos then
            return not UnionInfoModel.CheckPermissions(id, v)
        end
    end
    return false
end
--获取联盟徽章
function UnionModel.GetUnionBadgeIcon(id)
    if not id then
        local info = UnionInfoModel.GetInfo()
        id = info.Emblem
    end
    local conf = ConfigMgr.GetItem("configAllianceLogos", id)
    if not conf then
        return
    end
    return UITool.GetIcon(conf.image),id
end
--获取联盟称谓
function UnionModel.GetAppellation(index, alliances)
    if not alliances then
        alliances = UnionInfoModel.GetInfo()
    end
    local title = alliances["NameR" .. index]
    if not title or title == "" then
        return ConfigMgr.GetI18n("configI18nCommons", "Ui_R" .. index .. "_Name")
    end
    return title
end
--根据联盟成员信息对成员权限等级权限分类
function UnionModel.MemberSort(members)
    local obj = {}
    for i = 0, 5 do
        obj[i] = {}
    end
    for _, v in pairs(members) do
        table.insert(obj[v.Position], v)
    end
    return obj
end
--通过配置表获取联盟权限配置表
function UnionModel.GetPermissionsByConf(conf)
    local arr = {}
    for k, v in pairs(conf) do
        for _, pos in pairs(v.Member) do
            if not arr[pos] then
                arr[pos] = {}
            end
            table.insert(arr[pos], k)
        end
    end
    return arr
end

function UnionModel:GetUnionCredit()
    local info = UnionInfoModel.GetInfo()
    if next(info) == nil then
        return 0
    else
        return info.Honor
    end
end

--格式化menber信息
--members
--        Position  --权限
--                  member
--                  .....
--        Position  --权限
--                  member
function UnionModel:FormatMember(member)
    local members = {}
    for _, v in ipairs(member) do
        if not members[v.Position] then
            members[v.Position] = {}
        end
        table.insert(members[v.Position], v)
    end
    return members
end

-- 检查是否有权限
function UnionModel.CheckPermission(permission)
    local permissionConfig = ConfigMgr.GetItem("configAlliancePermissions", permission)
    for _, v in pairs(permissionConfig.members) do
        if Model.Player.AlliancePos == v then
            return true
        end
    end

    return false
end

-- 检查是否有联盟
function UnionModel:CheckHadUnion()
    return not (Model.Player.AllianceId == "")
end

function UnionModel.CheckOpenCondition(index)
    local conf = ConfigMgr.GetItem("configAllianceMains", index)
    local unlockType = conf.open_conditions[1]
    if unlockType == 0 then
        return trye
    end
    local unlockLv = conf.open_conditions[2]
    local values = {
        lv = unlockLv
    }
    if unlockType == 1 then
        if BuildModel.GetCenterLevel() >= unlockLv then
            return true
        end
        TipUtil.TipById(50062, values)
        return false
    end
    if unlockType == 2 then
        if Model.Player.Level >= unlockLv then
            return true
        end
        TipUtil.TipById(50063, values)
        return false
    end
    return true
end

-------------------------------------------------联盟科技部分

-- 请求联盟科技
function UnionModel.GetTechs(cb)
    Net.AllianceTech.TechList(Model.Player.AllianceId, cb)
end

-- 请求联盟科技详细信息
function UnionModel.GetTechDetail(techId, cb)
    Net.AllianceTech.GetTech(Model.Player.AllianceId, tostring(techId), cb)
end

-- 设置联盟科技推荐
function UnionModel.SetTechRecommend(techId, cb)
    Net.AllianceTech.Recommend(Model.Player.AllianceId, tostring(techId), cb)
end

-- 取消联盟科技推荐
function UnionModel.SetTechUnrecommend(techId, cb)
    Net.AllianceTech.Unrecommend(Model.Player.AllianceId, tostring(techId), cb)
end

-- 研究联盟科技
function UnionModel.ResearchTech(techId, cb)
    Net.AllianceTech.Research(Model.Player.AllianceId, techId, cb)
end

-- 联盟科技捐献
function UnionModel.TechNormalDonate(techId, cost, cd)
    Net.AllianceTech.Contribute(
        Model.Player.AllianceId,
        techId,
        tostring(cost),
        function(rsp)
            if rsp.IsCooling then
                Model.Player.AllianceTechCanContri = not rsp.IsCooling
                Event.Broadcast(EventDefines.UIUnionScience)
            end

            if cd then
                cd(rsp)
            end
        end
    )
end

-- 是否有正在升级的联盟科技
function UnionModel.CheckUpgradeTech()
    for _, v in pairs(UnionModel.techModels) do
        if v.IsUp then
            return true
        end
    end

    return false
end

-- 检查推荐数是否达到上限
function UnionModel.CheckRecommondMax()
    local num = 0
    for _, v in pairs(UnionModel.techModels) do
        if v.IsRecommended then
            num = num + 1
        end
    end

    if num >= 2 then
        return true
    else
        return false
    end
end
-------------------------------------------------联盟相关检查
--检查是否加入联盟
function UnionModel.CheckJoinUnion()
    return Model.Player.AllianceId and Model.Player.AllianceId ~= ""
end
--检查是否为盟主
function UnionModel.CheckUnionOwner()
    local info = UnionInfoModel.GetInfo()
    if next(info) == nil then
        return false
    end
    return info.PresidentId == Model.Account.accountId
end
--是否满足查看入盟申请的权限
function UnionModel.CheckViewApply()
    if Model.Player.AlliancePos == 0 then
        return
    end
    return Model.Player.AlliancePos >= Global.ReviewApplyPosition
end

-------------------------------------------------协作任务部分------------------------------------

function UnionModel.InitHelpTask(data)
    Model.Init(ModelType.AllianceTasks, "Id", data.Tasks)
    UnionModel.AllianceTaskInfo = data.AllianceTaskTimes
    UnionModel.NextFreeAt = data.NextFreeAt
    UnionModel.NextRefreshTime = data.NextRefreshTime
end

function UnionModel.RefreshFreeAt(data)
    UnionModel.NextFreeAt = data.NextFreeAt
end

--检测可领取任务数量
function UnionModel.CheckFinishTaskCount()
    local list = Model.GetMap(ModelType.AllianceTasks)
    local count = 0
    for k, v in pairs(list) do
        if v.Status == 3 then
            count = count + 1
        end
    end
    return count
end
--是否有可接受任务
function UnionModel.IsCanGetTask()
    local list = Model.GetMap(ModelType.AllianceTasks)
    local count = 0
    for k, v in pairs(list) do
        if v.Status == 1 then
            count = count + 1
        end
    end
    return count
end

--接受一次任务
function UnionModel.AcceptTaskOnce()
    UnionModel.AllianceTaskInfo.RemainAcceptTimes = math.max(0, UnionModel.AllianceTaskInfo.RemainAcceptTimes - 1)
end
--帮助别人一次
function UnionModel.HelpOtherOnce()
    UnionModel.AllianceTaskInfo.RemainHelpTimes = math.max(0, UnionModel.AllianceTaskInfo.RemainHelpTimes - 1)
end
--获取可帮助次数
function UnionModel.GetRemainHelpTimes()
    return UnionModel.AllianceTaskInfo.RemainHelpTimes
end
--获取可接受次数
function UnionModel.GetRemainAcceptTimes()
    return UnionModel.AllianceTaskInfo.RemainAcceptTimes
end

--删除任务
function UnionModel.DelTask(id)
    local list = Model.GetMap(ModelType.AllianceTasks)
    if list[id] then
        list[id] = nil
    end
    Event.Broadcast(EventDefines.UIAllianceRefeshHelpTask)
end

function UnionModel.RefreshTask(task)
    local taskList = Model.GetMap(ModelType.AllianceTasks)
    taskList[task.Id] = task
end

function UnionModel.UpdateTask(newTask, oldTaskID) --联盟帮助任务，帮助成功后，返回task为新ID，索引旧ID进行替换
    local taskList = Model.GetMap(ModelType.AllianceTasks)
    taskList[newTask.Id] = newTask
    taskList[oldTaskID] = nil
end

--获取自己当前拥有任务
function UnionModel.GetOwnTaskCount()
    local taskList = Model.GetMap(ModelType.AllianceTasks)
    local count = 0
    for k, v in pairs(taskList) do
        if (v.Status == Global.ATStatusRunning and v.UserId == Model.Account.accountId) then
            count = count + 1
        end
    end
    return count
end

--获取联盟协作任务
function UnionModel.GetCoordinationTask()
    local taskList = Model.GetMap(ModelType.AllianceTasks)
    local list = {}
    for k, v in pairs(taskList) do
        if (v.Status == 1) then
            table.insert(list, v)
        end
    end
    table.sort(list, UnionModel.SortTask)
    return list
end
--获取联盟协作我的任务
function UnionModel.GetMyTask()
    local taskList = Model.GetMap(ModelType.AllianceTasks)
    local list = {}
    for k, v in pairs(taskList) do
        if v.Status > 1 and v.UserId == Model.Account.accountId then
            table.insert(list, v)
        end
    end
    table.sort(list, UnionModel.SortTask)
    return list
end
--获取联盟协作我的任务的奖励数量
function UnionModel.GetTeamTaskRewardCount()
    local countMint = 0
    local countOther = 0
    for k, v in pairs(Model.GetMap(ModelType.AllianceTasks)) do
        if v.Status == 3 then
            if v.UserId == Model.Account.accountId then
                countMint = countMint + 1
            else
                countOther = countOther + 1
            end
        end
    end
    return countMint, countOther
end

--获得帮助任务
function UnionModel.GetMyHelpOtherTask()
    local list = {}
    local taskList = Model.GetMap(ModelType.AllianceTasks)
    for k, v in pairs(taskList) do
        if v.UserId ~= Model.Account.accountId then
            table.insert(list, v)
        end
    end
    table.sort(list, UnionModel.SortTask)
    return list
end
--接受任务价格
function UnionModel.GetTaskPrice()
    local num = UnionModel.GetOwnTaskCount()
    local list = Global.ATStartFee
    if (num + 1 > #list) then
        return list[#list]
    end
    return list[num + 1]
end

--是否能够帮助别人
function UnionModel.IsOtherCanHelp()
    local taskList = Model.GetMap(ModelType.AllianceTasks)
    for k, v in pairs(taskList) do
        if v.HelperId == Model.Account.accountId and v.Status == Global.ATStatusRunning then
            return false
        end
    end
    return true
end

function UnionModel.IsExistFreeTask()
    local getTimes = UnionModel.AllianceTaskInfo.RefreshTimes - Global.ATFreeRefreshTimes

    return getTimes < 0 and UnionModel.NextFreeAt < Tool.Time() and UnionModel.GetOwnTaskCount() == 0
end

-- --我的任务已经请求
-- function UnionModel.ChangeMyTaskHelpStatus(taskId)
--     local taskList = Model.GetMap(ModelType.AllianceTasks)
--     for k, v in pairs(taskList) do
--         if v.Id == taskId and v.Status == 2 then
--             v.AskedHelp = true
--         end
--     end

--完成协作任务
function UnionModel.FinishUnionTask(taskType, taskId)
    local taskList = Model.GetMap(ModelType.AllianceTasks)
    taskList[taskId] = nil
end

--联盟协作任务排序
function UnionModel.SortTask(a, b)
    local info1 = ConfigMgr.GetItem("configAllianceTasks", a.ConfId)
    local info2 = ConfigMgr.GetItem("configAllianceTasks", b.ConfId)
    --可领取的
    if a.Status == 3 and b.Status < 3 then
        return true
    end
    if a.Status < 3 and b.Status == 3 then
        return false
    end
    if a.HelperId ~= "" and b.HelperId == "" then
        return true
    end
    if a.HelperId == "" and b.HelperId ~= "" then
        return false
    end
    if info1.grade == info2.grade then
        return a.ConfId < b.ConfId
    else
        return info1.grade > info2.grade
    end

    -- ConfId
    -- return a.
end

--检测是否未到加入联盟冷却时间
function UnionModel.CheckIsNotOverJoinTime()
    local time = Tool.Time()
    local joinTime = Model.GetMap(ModelType.UserAllianceInfo).AllianceJoinedAt
    local isOk = (Model.GetMap(ModelType.UserAllianceInfo).AllianceJoinedAt + Global.ATJoinAllianceCooldown) > Tool.Time()
    return isOk
end

--检查是否加入帮会推送弹窗
function UnionModel.CheckJoinPush(confId, level, isOnlineReward, isNetCache)
    --如果有其它引导则不出现弹窗
    local isGuiding = GuidedModel:IsGuideState()
    local isCondtion = isGuiding or GlobalVars.IsTriggerStatus or GlobalVars.IsNoviceGuideStatus
    if not isCondtion then
        return
    end
    --已有联盟不推送
    if UnionModel.CheckJoinUnion() then
        return
    end
    --指挥中心等级低于限定等级不推送
    if Model.Player.Level < GlobalMisc.JoinUnionCenterLimit then
        return
    end

    --天选之人弹窗
    local function god_like_func()
        PopupWindowQueue:Push("UnionView/UnionPushCreateGodLike")
    end
    --推送判断
    local function push_func()
        if Model.Player.IsGodLike then
            god_like_func()
        else
            --加入联盟弹窗
            Net.Alliances.Recommend(
                function(rsp)
                    if rsp.Have and not GlobalVars.IsTriggerStatus and not GuidedModel.isBeginGuide then
                        --获取到加入联盟信息
                        PopupWindowQueue:Push("UnionView/UnionPushJoin", rsp)
                    else
                        if rsp.IsGodLike then
                            god_like_func()
                        end
                    end
                end
            )
        end
    end

    if isOnlineReward then
        --在线奖励
        push_func()
    elseif isNetCache then
        --服务器缓存推送
        push_func()
        Model.Player.AllianceJoinRecommend = false
        Net.UserInfo.CleanJoinUnionRecommend()
    else
        --建筑建造升级
        for _, v in pairs(GlobalMisc.JoinUnionCondition) do
            if v.confId == confId then
                if v.level == level then
                    push_func()
                end
                break
            end
        end
    end
end

return UnionModel
