Net.Events = {}

-- 请求-使用钻石加速事件
function Net.Events.Speedup(...)
    local fields = {
        "Category", -- int32
        "EventId", -- string
    }
    Network.RequestDynamic("SpeedupParams", fields, ...)
end

-- 请求-使用道具加速事件
function Net.Events.SpeedupByItem(...)
    local fields = {
        "Category", -- int32
        "EventId", -- string
        "ItemAmounts", -- array-Item
    }
    Network.RequestDynamic("SpeedupByItemParams", fields, ...)
end

-- 请求-免费加速事件
function Net.Events.SpeedupByFree(...)
    local fields = {
        "Category", -- int32
        "EventId", -- string
    }
    Network.RequestDynamic("SpeedupByFreeParams", fields, ...)
end

-- 请求-取消事件
function Net.Events.Cancel(...)
    local fields = {
        "Category", -- int32
        "EventId", -- string
    }
    Network.RequestDynamic("CancelEventParams", fields, ...)
end

-- 请求-加速行军事件
function Net.Events.SpeedupMission(...)
    local fields = {
        "EventId", -- string
        "ConfId", -- int32
        "BuyAndUse", -- bool
        "RallyMission", -- bool
    }
    Network.RequestDynamic("SpeedupMissionParams", fields, ...)
end

-- 请求-召回行军事件
function Net.Events.RecallMission(...)
    local fields = {
        "EventId", -- string
        "BuyAndUse", -- bool
    }
    Network.RequestDynamic("RecallMissionParams", fields, ...)
end

-- 请求-事件面板信息
function Net.Events.EventPanelInfo(...)
    Network.RequestDynamic("EventPanelParams", {}, ...)
end

-- 请求-战斗关怀
function Net.Events.BattleCare(...)
    local fields = {
        "Dead", -- array-Army
        "Injured", -- array-Army
        "AttackerName", -- string
    }
    Network.RequestDynamic("BattleCareParams", fields, ...)
end

return Net.Events