Net.MainTask = {}

-- 请求-获取玩家所有主线任务相关信息
function Net.MainTask.GetMainTaskInfo(...)
    Network.RequestDynamic("GetMainTaskInfoParams", {}, ...)
end

-- 请求-获取完成主线任务后的奖励
function Net.MainTask.GetMainTaskAward(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetMainTaskAwardParams", fields, ...)
end

return Net.MainTask