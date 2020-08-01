Net.LimitTimeMatch = {}

-- 请求-获取限时比赛信息
function Net.LimitTimeMatch.Info(...)
    Network.RequestDynamic("GetMatchInfoParams", {}, ...)
end

-- 请求-获取限时比赛排行榜
function Net.LimitTimeMatch.RankInfo(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("GetMatchRankParams", fields, ...)
end

return Net.LimitTimeMatch