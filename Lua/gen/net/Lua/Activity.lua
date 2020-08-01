Net.Activity = {}

-- 请求-获取疯狂兑换的信息
function Net.Activity.GetCrazyExchangeInfo(...)
    Network.RequestDynamic("GetCrazyExchangeInfoParams", {}, ...)
end

-- 请求-兑换疯狂兑换的奖品
function Net.Activity.GetCrazyExchangeAward(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("GetCrazyExchangeAwardParams", fields, ...)
end

-- 请求-请求系统活动信息列表
function Net.Activity.GetSysActivitiesInfo(...)
    Network.RequestDynamic("GetSysActivitiesInfoParams", {}, ...)
end

-- 请求-请求指定系统活动信息
function Net.Activity.GetSysActivitiyInfo(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetSysActivityInfoParams", fields, ...)
end

-- 请求-请求指定活动建筑信息
function Net.Activity.GetActivitiyBuildingInfo(...)
    local fields = {
        "X", -- int32
        "Y", -- int32
    }
    Network.RequestDynamic("GetActivityBuildingInfoParams", fields, ...)
end

-- 请求-指定兑换的信息
function Net.Activity.ActivityExchangeInfo(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetActivityExchangeInfoParams", fields, ...)
end

-- 请求-活动兑换奖励
function Net.Activity.ExchangeReward(...)
    local fields = {
        "ActivityId", -- int32
        "ExchangeId", -- int32
        "Num", -- int32
    }
    Network.RequestDynamic("ActivityExchangeRewardParams", fields, ...)
end

-- 请求-个人设置活动信息
function Net.Activity.SetPlayerActivityInfo(...)
    local fields = {
        "ActivityInfo", -- ActivityRpcInfo
    }
    Network.RequestDynamic("SetPlayerActivityInfoParams", fields, ...)
end

-- 请求-更新阶段
function Net.Activity.RpcUpdateActivityStage(...)
    local fields = {
        "ActivityId", -- int32
        "Stage", -- int32
        "Trigger", -- int32
        "StageEndAt", -- int64
        "ReadyTill", -- int64
    }
    Network.RequestDynamic("PlayerUpdateActivityStageParams", fields, ...)
end

return Net.Activity