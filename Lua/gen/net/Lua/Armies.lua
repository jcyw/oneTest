Net.Armies = {}

-- 请求-造兵
function Net.Armies.Train(...)
    local fields = {
        "ConfId", -- int32
        "Amount", -- int32
        "Instant", -- bool
    }
    Network.RequestDynamic("ArmyTrainParams", fields, ...)
end

-- 请求-收集士兵
function Net.Armies.Collect(...)
    local fields = {
        "EventId", -- string
    }
    Network.RequestDynamic("ArmyCollectParams", fields, ...)
end

-- 请求-治疗士兵
function Net.Armies.Cure(...)
    local fields = {
        "Armies", -- array-Army
        "Instant", -- bool
    }
    Network.RequestDynamic("ArmyCureParams", fields, ...)
end

-- 请求-解散士兵
function Net.Armies.Delete(...)
    local fields = {
        "Armies", -- array-Army
    }
    Network.RequestDynamic("ArmyDeleteParams", fields, ...)
end

-- 保存-编队
function Net.Armies.Formation(...)
    local fields = {
        "Armies", -- array-Formation
    }
    Network.RequestDynamic("ArmyFormationParams", fields, ...)
end

-- 请求-删除伤兵
function Net.Armies.DeleteInjured(...)
    local fields = {
        "Armies", -- array-Army
    }
    Network.RequestDynamic("ArmyDeleteInjuredParams", fields, ...)
end

-- 请求-修改军队编队名称
function Net.Armies.ModifyFormationName(...)
    local fields = {
        "FormId", -- int32
        "FormName", -- string
    }
    Network.RequestDynamic("ArmyFormationNameModifyParams", fields, ...)
end

-- 请求-升级军队
function Net.Armies.Upgrade(...)
    local fields = {
        "SourceConfId", -- int32
        "TargetConfId", -- int32
        "Amount", -- int32
        "Instant", -- bool
    }
    Network.RequestDynamic("ArmyUpgradeParams", fields, ...)
end

return Net.Armies