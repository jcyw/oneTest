Net.DailyTask = {}

-- 请求-玩家所有日常任务的信息
function Net.DailyTask.GetDailyTaskInfo(...)
    Network.RequestDynamic("GetDailyTaskInfoParams", {}, ...)
end

-- 
function Net.DailyTask.GetDailyTaskAward(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetDailyTaskAwardParams", fields, ...)
end

return Net.DailyTask