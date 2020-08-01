Net.AllianceTask = {}

-- 请求-更新联盟完成任务
function Net.AllianceTask.OnAllianceTaskUpdate(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("OnAllianceTaskUpdateParams", fields, ...)
end

return Net.AllianceTask