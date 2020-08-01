Net.AllianceDaily = {}

-- 请求-联盟活跃任务信息
function Net.AllianceDaily.Info(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceDailyInfoParams", fields, ...)
end

-- 请求-领取联盟活跃任务奖励
function Net.AllianceDaily.Claim(...)
    local fields = {
        "TaskConfId", -- int32
    }
    Network.RequestDynamic("AllianceDailyClaimParams", fields, ...)
end

-- 请求-获取盟主任务信息
function Net.AllianceDaily.AlliancePresientTaskInfo(...)
    Network.RequestDynamic("AlliancePresientTaskInfoParams", {}, ...)
end

-- 请求-获取盟主任务奖励
function Net.AllianceDaily.AlliancePresientTaskClaim(...)
    local fields = {
        "ConfId", -- int32
    }
    Network.RequestDynamic("AlliancePresientTaskClaimParams", fields, ...)
end

-- 请求-标记引导改名
function Net.AllianceDaily.AlliancePresientTaskMarkRename(...)
    Network.RequestDynamic("AlliancePresientTaskMarkRenameParams", {}, ...)
end

-- 请求-领取联盟活跃任务奖励
function Net.AllianceDaily.ClaimAll(...)
    Network.RequestDynamic("AllianceDailyClaimAllParams", {}, ...)
end

return Net.AllianceDaily