Net.EagleHunt = {}

-- 请求-活动信息
function Net.EagleHunt.Info(...)
    Network.RequestDynamic("EagleHuntInfoParams", {}, ...)
end

-- 请求-搜索
function Net.EagleHunt.Search(...)
    local fields = {
        "Guide", -- bool
    }
    Network.RequestDynamic("SearchEagleParams", fields, ...)
end

-- 请求-前往目标位置
function Net.EagleHunt.AimTarget(...)
    local fields = {
        "Index", -- int32
    }
    Network.RequestDynamic("EagleHuntAimTargetParams", fields, ...)
end

-- 请求-狩猎
function Net.EagleHunt.Hunt(...)
    local fields = {
        "X", -- int32
        "Y", -- int32
    }
    Network.RequestDynamic("HuntEagleParams", fields, ...)
end

-- 请求-近期记录
function Net.EagleHunt.RecentRecord(...)
    Network.RequestDynamic("RecentRecordParams", {}, ...)
end

-- 请求-记录汇总
function Net.EagleHunt.AllRecord(...)
    Network.RequestDynamic("AllRecordParams", {}, ...)
end

return Net.EagleHunt