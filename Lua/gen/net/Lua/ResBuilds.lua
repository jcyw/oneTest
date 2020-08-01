Net.ResBuilds = {}

-- 请求-收集资源
function Net.ResBuilds.Collect(...)
    local fields = {
        "BuildingId", -- int32
    }
    Network.RequestDynamic("ResBuildCollectParams", fields, ...)
end

-- 请求-购买产量加速BUFF
function Net.ResBuilds.BuyBuff(...)
    local fields = {
        "BuildingId", -- int32
    }
    Network.RequestDynamic("ResBuildBuyBuffParams", fields, ...)
end

-- 请求-使用资源产量加速道具
function Net.ResBuilds.UseBuffItem(...)
    local fields = {
        "BuildingId", -- int32
        "Amount", -- int32
    }
    Network.RequestDynamic("ResBuildUseBuffItemParams", fields, ...)
end

-- 请求-收集单个建筑资源
function Net.ResBuilds.CollectSingle(...)
    local fields = {
        "BuildingId", -- int32
    }
    Network.RequestDynamic("ResBuildCollectSingleParams", fields, ...)
end

return Net.ResBuilds