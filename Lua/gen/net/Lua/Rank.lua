Net.Rank = {}

-- 请求-排行榜数据
function Net.Rank.RankInfo(...)
    local fields = {
        "Category", -- int32
        "Offset", -- int32
        "Limit", -- int32
    }
    Network.RequestDynamic("RankParam", fields, ...)
end

return Net.Rank