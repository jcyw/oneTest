Net.Arena = {}

-- 请求-刷新挑战候选人
function Net.Arena.RefreshBattleCandidate(...)
    Network.RequestDynamic("RefreshBattleCandidateParams", {}, ...)
end

-- 请求-获取挑战标签页信息
function Net.Arena.GetArenaBattlePageInfo(...)
    Network.RequestDynamic("GetArenaBattlePageInfoParam", {}, ...)
end

-- 请求-挑战
function Net.Arena.ArenaAttack(...)
    local fields = {
        "Armies", -- array-Army
        "BeastId", -- int32
        "BattleId", -- string
        "BattleRank", -- int32
    }
    Network.RequestDynamic("ArenaBattleParam", fields, ...)
end

-- 请求-查看队伍信息
function Net.Arena.ArenaPryTroopInfo(...)
    local fields = {
        "Rank", -- int32
    }
    Network.RequestDynamic("ArenaTroopInfoParam", fields, ...)
end

-- 请求-排行榜标签页信息
function Net.Arena.ArenaRankPageInfo(...)
    local fields = {
        "Count", -- int32
    }
    Network.RequestDynamic("ArenaRankPageInfoParam", fields, ...)
end

-- 请求-拉取排行榜玩家信息
function Net.Arena.ArenaRankPlayerInfo(...)
    local fields = {
        "Start", -- int32
        "Count", -- int32
    }
    Network.RequestDynamic("ArenaRankPlayerInfoParam", fields, ...)
end

-- 请求-拉取奖励标签页信息
function Net.Arena.ArenaAwardPageInfo(...)
    Network.RequestDynamic("ArenaAwardPageInfoParam", {}, ...)
end

-- 请求-领取奖励
function Net.Arena.ArenaGetAwards(...)
    Network.RequestDynamic("ArenaGetAwardsParam", {}, ...)
end

return Net.Arena