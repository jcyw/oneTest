Net.AllianceStorehouse = {}

-- 请求-联盟仓库详细信息
function Net.AllianceStorehouse.StoreHouseInfo(...)
    local fields = {
        "ConfId", -- int32
        "X", -- int32
        "Y", -- int32
    }
    Network.RequestDynamic("AllianceStorehouseInfoParams", fields, ...)
end

-- 请求-联盟仓库界面初始信息
function Net.AllianceStorehouse.StoreInfo(...)
    local fields = {
        "ConfId", -- int32
    }
    Network.RequestDynamic("AllianceStorehouseInitParam", fields, ...)
end

-- 请求-存储
function Net.AllianceStorehouse.StoreRes(...)
    local fields = {
        "ConfId", -- int32
        "CostResource", -- array-ResAmount
    }
    Network.RequestDynamic("AllianceResStoreParam", fields, ...)
end

-- 请求-取回
function Net.AllianceStorehouse.FetchRes(...)
    local fields = {
        "ConfId", -- int32
        "Resource", -- array-ResAmount
    }
    Network.RequestDynamic("AllianceResFetchParam", fields, ...)
end

-- 请求-联盟仓库资源送回
function Net.AllianceStorehouse.RpcSendBack(...)
    local fields = {
        "ConfId", -- int32
        "Resource", -- array-ResAmount
        "Duration", -- int32
        "X", -- int32
        "Y", -- int32
    }
    Network.RequestDynamic("AllianceResRpcSendBackParams", fields, ...)
end

return Net.AllianceStorehouse