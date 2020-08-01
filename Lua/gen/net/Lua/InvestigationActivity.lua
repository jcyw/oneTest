Net.InvestigationActivity = {}

-- 请求-获取第二周侦查活动信息
function Net.InvestigationActivity.GetInvestigationActivityInfo(...)
    Network.RequestDynamic("GetInvestigationActivityInfoParams", {}, ...)
end

-- 请求-获取侦查活动完成任务的奖励
function Net.InvestigationActivity.GetInvestigationTaskAward(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetInvestigationTaskAwardParams", fields, ...)
end

return Net.InvestigationActivity