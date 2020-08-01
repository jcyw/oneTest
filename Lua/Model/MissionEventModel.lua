--行军消息Model
local MissionEventModel = {}
local MissionList = {}
local MissionRouteList = {}
local StopX = 0
local startX = 0
local startY = 0
local stopX = 0
local stopY = 0
function MissionEventModel.Init()
    local data = Model.GetMap("MissionEvents")
    for k, v in pairs(data) do
        MissionList[k] = v
    end
end

function MissionEventModel.OnRefresh(data)
    local list = Model.GetMap("MissionEvents")
    list[data.Uuid] = data
    -- Event.Broadcast(EventDefines.MissionEventRefresh)
end

function MissionEventModel.GetList()
    return Model.GetMap("MissionEvents")
end

function MissionEventModel.GetMissionAmount()
    local amount = 0
    for _, v in pairs(Model.GetMap(ModelType.MissionEvents)) do
        if v.Category ~= Global.MissionHunt then
            amount = amount + 1
        end
    end
    return amount
end

function MissionEventModel.GetEvent(index)
    local list = Model.GetMap("MissionEvents")
    return list[index]
end

function MissionEventModel.IsMyRallingEvent(allianceBattleId)
    for k,v in pairs(Model.GetMap("MissionEvents")) do
        if allianceBattleId == v.AllianceBattleId then
            return true , v.MissionTeams,v.marchType,v.isRallyMarch
        end
    end
    return false
end

--根据地块查找行军事件
function MissionEventModel.GetMissionByPos(posNum)
    local posX, posY = MathUtil.GetCoordinate(posNum)
    local list = Model.GetMap("MissionEvents")
    for k, v in pairs(list) do
        if v.StopX == posX and v.StopY == posY then
            return v
        end
    end
    return nil
end

--删除行军路线
function MissionEventModel.DelMission(key)
    local list = Model.GetMap("MissionEvents")
    if (list[key]) then
        list[key] = nil
    end
end

--取消挖矿即返回，建议后期整合
function MissionEventModel.CancelMining(missionId)
    Net.Missions.CancelMining(
        missionId,
        function(val)
            Log.Info("取消该路线")
        end
    )
end

--取消扎营
function MissionEventModel.CancelCamp(missionId)
    Net.Missions.CancelCamp(
        missionId,
        function(rsp)
            if rsp.Fail then
                return
            end
        end
    )
end

--撤回增援
function MissionEventModel.CancelAssist(missionId)
    Net.AllianceBattle.CancelAssist(
        missionId,
        nil,
        nil,
        function(rsp)
            if rsp.Fail then
                return
            end
        end
    )
end
--检测是否有队伍在探索秘密基地 1、在探索中 2、探索此处
function MissionEventModel.CheckIsExploreing(posX, posY)
    local isExplore = false
    local exploreInfo = nil
    local list = Model.GetMap("MissionEvents")
    for _, v in pairs(list) do
        if v.Category == Global.MissionExplore then
            isExplore = true
            if v.StopX == posX and v.StopY == posY and v.Status == 6 then
                exploreInfo = v
            end
        end
    end
    return isExplore, exploreInfo
end
--执行进攻动画流程
function MissionEventModel.SetAttackState(id)
    local info = MissionEventModel.GetEvent(id)
    info.isAttacking = true
end
function MissionEventModel.CheckIsAttackState(id)
    local info = MissionEventModel.GetEvent(id)
    return info.isAttacking == true
end

function MissionEventModel.InitMarchInfo(data)
    if not data.StartPointSize or not data.StopPointSize then
        Log.Error("出错了")
    end
    local startX, startY, stopX, stopY = MapModel.GetMarchPoint(data)
    local marchInfo = {}
    marchInfo.data = data
    marchInfo.showX = stopX
    marchInfo.showY = stopY
    return marchInfo
end

function MissionEventModel.GetReturnPoint(data)
    if not data.StartPointSize or not data.StopPointSize then
        Log.Error("出错了")
    end
    local startX, startY, stopX, stopY = MapModel.GetMarchPoint(data)
    local remainTime = data.FinishAt - Tool.Time()
    local duration = data.FinishAt - data.SpeedChangeAt
    startX = (startX * (100 - data.SpeedChangeDistance) + stopX * data.SpeedChangeDistance) / 100
    startY = (startY * (100 - data.SpeedChangeDistance) + stopY * data.SpeedChangeDistance) / 100

    local x = remainTime / duration * startX + (1 - remainTime / duration) * stopX
    local y = remainTime / duration * startY + (1 - remainTime / duration) * stopY
    return x, y
end
--是否当前正在集结中
function MissionEventModel.IsRallyNow()
    local list = Model.GetMap("MissionEvents")
    --检测是否在集结中 以及集结完毕出发进攻
    for k, v in pairs(list) do
        if (v.Category == Global.MissionRally or v.IsRally) then
            for a, b in pairs(v.MissionTeams) do
                if b.UserId == Model.Account.accountId then
                    return true
                end
            end
        end
    end
    return false
end

function MissionEventModel.GetFalconMissions()
    local falconTimeList = {}
    local list = Model.GetMap("MissionEvents")
    --检测是否在集结中 以及集结完毕出发进攻
    for k, v in pairs(list) do
        if (v.Category == Global.MissionHunt) then
            local delayTime = 0
            if v.IsReturn then
                delayTime = v.FinishAt
            else
                delayTime = v.FinishAt + v.Duration
            end
            falconTimeList[v.Uuid] = delayTime
        end
    end
    return falconTimeList
end
--当前是否有行军到点
function MissionEventModel.IsMarchToPoint(posNum)
    local posX, posY = MathUtil.GetCoordinate(posNum)
    local list = Model.GetMap("MissionEvents")
    --检测是否在集结中 以及集结完毕出发进攻
    for _, v in pairs(list) do
        if not v.IsReturn then
            if v.StopX == posX and v.StopY == posY then
                return true
            end
        end
    end
    return false
end

return MissionEventModel
