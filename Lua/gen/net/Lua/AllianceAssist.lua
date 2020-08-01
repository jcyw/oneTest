Net.AllianceAssist = {}

-- 请求-援助界面初始信息
function Net.AllianceAssist.AssistInfo(...)
    local fields = {
        "AssistedPlayer", -- string
    }
    Network.RequestDynamic("AllianceResAssistInfoParam", fields, ...)
end

-- 请求-援助
function Net.AllianceAssist.Assist(...)
    local fields = {
        "AssistedPlayer", -- string
        "CostResource", -- array-ResAmount
    }
    Network.RequestDynamic("AllianceResAssistParam", fields, ...)
end

-- 请求-求援
function Net.AllianceAssist.AskForAssist(...)
    local fields = {
        "AllianceId", -- string
        "NeedResourceId", -- int32
    }
    Network.RequestDynamic("AllianceAskForResAssistParam", fields, ...)
end

-- 请求-求援冷却时间
function Net.AllianceAssist.GetAskForResAssistCoolDown(...)
    Network.RequestDynamic("AllianceResAssistCoolDownParam", {}, ...)
end

-- 请求-资源援助到达
function Net.AllianceAssist.ResArrived(...)
    local fields = {
        "Resource", -- array-ResAmount
        "ResReturn", -- bool
        "AssistingName", -- string
    }
    Network.RequestDynamic("AllianceRpcResAssistArrivedParam", fields, ...)
end

-- 请求-资源援助失败
function Net.AllianceAssist.ResAssistFailed(...)
    local fields = {
        "ReturnResource", -- array-ResAmount
    }
    Network.RequestDynamic("AllianceRpcResAssistFailedParam", fields, ...)
end

return Net.AllianceAssist