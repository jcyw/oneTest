--[[
    author:{laofu}
    time:2020-07-29 17:19:11
    function:{单人活动数据模块}
]]
local GD = _G.GD
local SingleActivityAgent = GD.LVar("SingleActivityAgent", {})
local AgentDefine = GD.AgentDefine

local GetSingleActivityInfo  --活动信息
local GetTasks  --获得领取到的任务
local GetRankAwards  --获得排名奖励列表
local GetScoreTaskBanner  --获得积分任务的名称和banner

local Net = _G.Net
local Model = _G.Model
local ConfigMgr = _G.ConfigMgr

--活动信息
function GetSingleActivityInfo(cb)
    Net.IndividualEvent.IndividualEventInfo(
        function(rsp)
            print("SingleModel======================================>>>>", table.inspect(rsp))
            Model.SingleActivity_Score = rsp.Score
            Model.SingleActivity_TaskId = rsp.Activity.Trigger
            Model.SingleActivity_TaskInfo = ConfigMgr.GetItem("configSingleEvents", rsp.Activity.Trigger)
            Model.SingleActivity_EndAt = rsp.StageEndAt
            Model.SingleActivity_Level = rsp.Level
            Model.SingleActivity_Stage = 0
            --得到自己这个等级阶段的积分和奖励礼包
            local stageAwardID = 0
            local configStageEvent = ConfigMgr.GetItem("configStageEvents", rsp.Activity.Trigger)
            for _, v in pairs(configStageEvent.score_award) do
                if v.lv == rsp.Level then
                    stageAwardID = v.score
                end
            end
            local stageAwards = ConfigMgr.GetItem("configStageAwards", stageAwardID)
            Model.SingleActivity_StageAward = {}
            for i = 1, 3, 1 do
                local data = {
                    score = stageAwards.score[i],
                    giftId = stageAwards.award[i]
                }
                table.insert(Model.SingleActivity_StageAward, data)
                if rsp.Score > stageAwards.score[i] then
                    --当前阶段
                    Model.SingleActivity_Stage = i
                end
            end

            if cb then
                cb()
            end
        end
    )
end

--获得领取到的任务
function GetTasks()
    local configSingleTypes = ConfigMgr.GetList("configSingleTypes")
    local tasks = {}
    for _, v in pairs(Model.SingleActivity_TaskInfo.task_event) do
        local typeTask = {}
        for _, task in pairs(configSingleTypes) do
            if task.sort == v then
                table.insert(typeTask, task)
            end
        end
        table.insert(tasks, typeTask)
    end
    return tasks
end

--获得排名奖励列表
function GetRankAwards()
    local configSingleRankAward = ConfigMgr.GetList("configSingleRankAwards")
    local rankAwards = {}
    for _, v in pairs(configSingleRankAward) do
        if v.task_event == Model.SingleActivity_TaskId then
            table.insert(rankAwards, v)
        end
    end
    return rankAwards
end

--获得积分任务的名称和banner
function GetScoreTaskBanner()
    local datas = {}
    for _, v in pairs(Model.SingleActivity_TaskInfo.task_event) do
        local id = "100" .. v
        local singleEvent = ConfigMgr.GetItem("configSingleEvents", tonumber(id))
        local data = {
            name = singleEvent.name,
            banner = singleEvent.single_banner
        }
        datas[v] = data
    end
    return datas
end

AgentDefine(SingleActivityAgent, "GetSingleActivityInfo", GetSingleActivityInfo)
AgentDefine(SingleActivityAgent, "GetTasks", GetTasks)
AgentDefine(SingleActivityAgent, "GetRankAwards", GetRankAwards)
AgentDefine(SingleActivityAgent, "GetScoreTaskBanner", GetScoreTaskBanner)

return SingleActivityAgent
