Net.AllianceBattle = {}

-- 请求-集结信息
function Net.AllianceBattle.Infos(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceBattleInfosParams", fields, ...)
end

-- 请求-创建集结
function Net.AllianceBattle.Create(...)
    local fields = {
        "Category", -- int32
        "DurationType", -- int32
        "TargetX", -- int32
        "TargetY", -- int32
        "Armies", -- array-Army
        "BeastId", -- int32
    }
    Network.RequestDynamic("AllianceBattleCreateParams", fields, ...)
end

-- 请求-解散
function Net.AllianceBattle.Disband(...)
    local fields = {
        "AllianceBattleId", -- string
    }
    Network.RequestDynamic("AllianceBattleDisbandParams", fields, ...)
end

-- 请求-遣返
function Net.AllianceBattle.Removal(...)
    local fields = {
        "AllianceBattleId", -- string
        "MissionId", -- string
    }
    Network.RequestDynamic("AllianceBattleRemovalParams", fields, ...)
end

-- 请求-加速
function Net.AllianceBattle.Speedup(...)
    local fields = {
        "AllianceBattleId", -- string
        "MissionId", -- string
        "ConfId", -- int32
    }
    Network.RequestDynamic("AllianceBattleSpeedupParams", fields, ...)
end

-- 请求-联盟战斗记录
function Net.AllianceBattle.Logs(...)
    local fields = {
        "Offset", -- int32
        "Limit", -- int32
    }
    Network.RequestDynamic("AllianceBattleLogsParams", fields, ...)
end

-- 请求-联盟战斗开始行军
function Net.AllianceBattle.March(...)
    local fields = {
        "AllianceBattleId", -- string
    }
    Network.RequestDynamic("AllianceBattleMarchParams", fields, ...)
end

-- 请求-联盟战斗加入集结
function Net.AllianceBattle.Join(...)
    local fields = {
        "HeroId", -- string
        "Armies", -- array-Army
        "AllianceBattleId", -- string
        "BeastId", -- int32
    }
    Network.RequestDynamic("AllianceBattleJoinParams", fields, ...)
end

-- 请求-援助士兵
function Net.AllianceBattle.Assist(...)
    local fields = {
        "X", -- int32
        "Y", -- int32
        "HeroId", -- string
        "Armies", -- array-Army
        "BeastId", -- int32
        "TargetId", -- string
    }
    Network.RequestDynamic("AllianceBattleAssistParams", fields, ...)
end

-- 请求-联盟援助限制
function Net.AllianceBattle.AssistLimit(...)
    local fields = {
        "ServerId", -- string
        "X", -- int32
        "Y", -- int32
    }
    Network.RequestDynamic("AllianceBattleAssistLimitParams", fields, ...)
end

-- 请求-获取驻军信息
function Net.AllianceBattle.AllianceGarrisonsInfo(...)
    local fields = {
        "PosNum", -- int32
    }
    Network.RequestDynamic("AllianceGarrisonsInfoParams", fields, ...)
end

-- 请求-请求士兵援助
function Net.AllianceBattle.AskArmyAssist(...)
    local fields = {
        "WarningId", -- string
    }
    Network.RequestDynamic("AllianceAskArmyAssistParams", fields, ...)
end

-- 请求-集结信息
function Net.AllianceBattle.BattleInfo(...)
    local fields = {
        "BattleId", -- string
    }
    Network.RequestDynamic("AllianceBattleInfoParams", fields, ...)
end

-- 请求-请求援助记录
function Net.AllianceBattle.AssistLogs(...)
    local fields = {
        "Start", -- int32
        "End", -- int32
    }
    Network.RequestDynamic("AllianceAssistLogsParams", fields, ...)
end

-- 请求-遣返援助
function Net.AllianceBattle.RemovalAssist(...)
    local fields = {
        "UserId", -- string
        "EventId", -- string
    }
    Network.RequestDynamic("RemovalAssistParams", fields, ...)
end

-- 请求-联盟战争被遣返
function Net.AllianceBattle.OnRemoval(...)
    local fields = {
        "BattleId", -- string
        "Mission", -- AllianceBattleMission
        "DefenderAllianceId", -- string
        "Immediate", -- bool
        "TargetId", -- int32
    }
    Network.RequestDynamic("AllianceBattleOnRemovalParams", fields, ...)
end

-- 请求-联盟战争完成战争开始返回
function Net.AllianceBattle.Return(...)
    local fields = {
        "BattleId", -- string
        "MissionTeam", -- MissionTeam
        "StopX", -- int32
        "StopY", -- int32
        "Rewards", -- array-Reward
        "ReturnEnergy", -- int32
        "FightFinish", -- bool
        "RewardImmidiately", -- bool
        "RewardsReason", -- int32
    }
    Network.RequestDynamic("AllianceBattleReturnParams", fields, ...)
end

-- 请求-强制解散集结
function Net.AllianceBattle.ForceDisband(...)
    local fields = {
        "BattleId", -- string
        "QuickReturnUserId", -- string
    }
    Network.RequestDynamic("AllianceBattleForceDisbandParams", fields, ...)
end

return Net.AllianceBattle