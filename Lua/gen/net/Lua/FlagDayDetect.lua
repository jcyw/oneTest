Net.FlagDayDetect = {}

-- 请求-获取国旗日侦查活动信息
function Net.FlagDayDetect.GetInfo(...)
    Network.RequestDynamic("GetFlagDayDetectInfoParams", {}, ...)
end

-- 请求-获取国旗日侦查活动完成任务的奖励
function Net.FlagDayDetect.GetAward(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetFlagDayDetectTaskAwardParams", fields, ...)
end

return Net.FlagDayDetect