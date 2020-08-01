Net.AllianceTasks = {}

-- 请求-开始联盟任务
function Net.AllianceTasks.Start(...)
    local fields = {
        "TaskId", -- string
    }
    Network.RequestDynamic("AllianceTasksStartParams", fields, ...)
end

-- 请求-请求帮助任务
function Net.AllianceTasks.AskHelp(...)
    local fields = {
        "TaskId", -- string
    }
    Network.RequestDynamic("AllianceTasksAskHelpParams", fields, ...)
end

-- 请求-协助联盟任务
function Net.AllianceTasks.Help(...)
    local fields = {
        "TaskOwnerId", -- string
        "TaskId", -- string
    }
    Network.RequestDynamic("AllianceTasksHelpParams", fields, ...)
end

-- 请求-刷新联盟任务
function Net.AllianceTasks.Refresh(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceTasksRefreshParams", fields, ...)
end

-- 请求-完成联盟任务
function Net.AllianceTasks.Finish(...)
    local fields = {
        "TaskId", -- string
    }
    Network.RequestDynamic("AllianceTasksFinishParams", fields, ...)
end

-- 请求-获取需要协助的联盟任务
function Net.AllianceTasks.Shared(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceTasksSharedParams", fields, ...)
end

-- 请求-领取协作任务奖励
function Net.AllianceTasks.Claim(...)
    local fields = {
        "TaskId", -- string
    }
    Network.RequestDynamic("AllianceTasksClaimParams", fields, ...)
end

-- 请求-加速联盟协作任务
function Net.AllianceTasks.Speedup(...)
    local fields = {
        "TaskId", -- string
    }
    Network.RequestDynamic("AllianceTasksSpeedupParams", fields, ...)
end

-- 请求-联盟任务被协助
function Net.AllianceTasks.OnHelp(...)
    local fields = {
        "TaskId", -- string
        "HelperId", -- string
        "HelperName", -- string
    }
    Network.RequestDynamic("AllianceTasksOnHelpParams", fields, ...)
end

return Net.AllianceTasks