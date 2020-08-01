Net.SevenDaysActivity = {}

-- 请求-七日活动信息
function Net.SevenDaysActivity.SevenDaysActivityInfo(...)
    Network.RequestDynamic("GetSevenDaysTaskInfosParams", {}, ...)
end

-- 请求-领取七日活动任务奖励
function Net.SevenDaysActivity.GetSevenDaysTaskReward(...)
    local fields = {
        "TaskId", -- int32
    }
    Network.RequestDynamic("GetSevenDaysTaskRewardParams", fields, ...)
end

-- 请求-领取七日活动积分奖励
function Net.SevenDaysActivity.GetSevenDaysTaskBonus(...)
    local fields = {
        "BonusId", -- int32
    }
    Network.RequestDynamic("GetSevenDaysTaskBonusParams", fields, ...)
end

return Net.SevenDaysActivity