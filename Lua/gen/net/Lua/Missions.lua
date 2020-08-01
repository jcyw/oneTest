Net.Missions = {}

-- 请求-行军
function Net.Missions.March(...)
    local fields = {
        "X", -- int32
        "Y", -- int32
        "Category", -- int32
        "BattleId", -- string
        "Armies", -- array-Army
        "Param", -- string
        "BeastId", -- int32
    }
    Network.RequestDynamic("MissionMarchParams", fields, ...)
end

-- 请求-行军采集野矿
function Net.Missions.Mining(...)
    local fields = {
        "X", -- int32
        "Y", -- int32
        "HeroId", -- string
        "Armies", -- array-Army
        "BeastId", -- int32
    }
    Network.RequestDynamic("MissionMiningParams", fields, ...)
end

-- 请求-行军攻击NPC
function Net.Missions.Pve(...)
    local fields = {
        "X", -- int32
        "Y", -- int32
        "HeroId", -- string
        "Armies", -- array-Army
        "BeastId", -- int32
    }
    Network.RequestDynamic("MissionPVEParams", fields, ...)
end

-- 请求-行军攻击玩家
function Net.Missions.Attack(...)
    local fields = {
        "X", -- int32
        "Y", -- int32
        "HeroId", -- string
        "Armies", -- array-Army
        "BeastId", -- int32
    }
    Network.RequestDynamic("MissionAttackParams", fields, ...)
end

-- 请求-行军抵达
function Net.Missions.Arrive(...)
    local fields = {
        "EventId", -- string
    }
    Network.RequestDynamic("MissionArriveParams", fields, ...)
end

-- 请求-行军完成
function Net.Missions.Return(...)
    local fields = {
        "EventId", -- string
    }
    Network.RequestDynamic("MissionReturnParams", fields, ...)
end

-- 请求-取消采集野矿
function Net.Missions.CancelMining(...)
    local fields = {
        "EventId", -- string
    }
    Network.RequestDynamic("MissionCancelMiningParams", fields, ...)
end

-- 请求-侦查
function Net.Missions.Spy(...)
    local fields = {
        "X", -- int32
        "Y", -- int32
    }
    Network.RequestDynamic("MissionSpyParams", fields, ...)
end

-- 请求-忽略预警
function Net.Missions.IgnoreWarning(...)
    local fields = {
        "WarningId", -- string
    }
    Network.RequestDynamic("MissionIgnoreParams", fields, ...)
end

-- 请求-忽略所有预警
function Net.Missions.IgnoreAllWarning(...)
    local fields = {
        "Ok", -- bool
    }
    Network.RequestDynamic("MissionIgnoreAllParams", fields, ...)
end

-- 请求-AI行军抵达
function Net.Missions.AIArrive(...)
    local fields = {
        "EventId", -- string
        "GM", -- bool
    }
    Network.RequestDynamic("AIMissionArriveParams", fields, ...)
end

-- 请求-取消扎营
function Net.Missions.CancelCamp(...)
    local fields = {
        "EventId", -- string
    }
    Network.RequestDynamic("MissionCancelCampParams", fields, ...)
end

-- 请求-召回部队
function Net.Missions.Cancel(...)
    local fields = {
        "EventId", -- string
    }
    Network.RequestDynamic("MissionCancelParams", fields, ...)
end

-- 请求-获取集结队长行军
function Net.Missions.GetRallyCaptainMission(...)
    local fields = {
        "EventId", -- string
    }
    Network.RequestDynamic("GetRallyCaptainMissionParams", fields, ...)
end

return Net.Missions