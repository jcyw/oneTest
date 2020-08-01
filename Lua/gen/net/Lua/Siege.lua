Net.Siege = {}

-- 请求-参加攻城
function Net.Siege.Participate(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("ParticipateSiegeParams", fields, ...)
end

-- 请求-攻城信息
function Net.Siege.GetSiegeInfo(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("SiegeInfoParams", fields, ...)
end

-- 请求-攻城排行榜
function Net.Siege.GetRank(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("SiegeRankParams", fields, ...)
end

-- 请求-探索信息
function Net.Siege.GetExploreInfo(...)
    Network.RequestDynamic("GetExploreInfoParams", {}, ...)
end

-- 请求-探索阶段奖励
function Net.Siege.ExploreReward(...)
    Network.RequestDynamic("ExploreRewardParams", {}, ...)
end

-- 请求-攻城历史排行榜
function Net.Siege.GetHistoryRank(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("SiegeHistoryRankParams", fields, ...)
end

-- 请求-创建攻城行军
function Net.Siege.SiegeStartMarch(...)
    local fields = {
        "Round", -- int32
        "IsRally", -- bool
        "BaseX", -- int32
        "BaseY", -- int32
        "Missions", -- array-MissionTeam
        "Uuid", -- string
    }
    Network.RequestDynamic("SiegeRpcStartMarchParam", fields, ...)
end

return Net.Siege