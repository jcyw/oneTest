Net.ActivityTask = {}

-- 请求-获取活动任务的信息
function Net.ActivityTask.GetActivityTaskInfos(...)
    Network.RequestDynamic("GetActivityTaskInfosParams", {}, ...)
end

-- 请求-获取活动任务的奖励
function Net.ActivityTask.GetActivityTaskAward(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetActivityTaskAwardParams", fields, ...)
end

-- 请求-获取猎狐活动任务信息
function Net.ActivityTask.GetHuntFoxInfos(...)
    Network.RequestDynamic("GetHuntFoxTaskInfosParams", {}, ...)
end

-- 请求-获取猎狐活动任务的奖励
function Net.ActivityTask.GetHuntFoxTaskAward(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetHuntFoxTaskAwardParams", fields, ...)
end

return Net.ActivityTask