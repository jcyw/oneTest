Net.AllianceBuildings = {}

-- 请求-联盟领地页面
function Net.AllianceBuildings.BuildingsInfo(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceBuildingsInfoParams", fields, ...)
end

-- 请求-联盟建筑详细信息
function Net.AllianceBuildings.FortressInfo(...)
    local fields = {
        "PosX", -- int32
        "PosY", -- int32
    }
    Network.RequestDynamic("AllianceFortressInfoParams", fields, ...)
end

-- 请求-联盟建筑改名
function Net.AllianceBuildings.Rename(...)
    local fields = {
        "RenameList", -- array-RenameInfo
    }
    Network.RequestDynamic("AllianceBuildingRenameParams", fields, ...)
end

-- 请求-创建联盟建筑
function Net.AllianceBuildings.Create(...)
    local fields = {
        "ConfId", -- int32
        "PosX", -- int32
        "PosY", -- int32
    }
    Network.RequestDynamic("AllianceBuildingCreateParams", fields, ...)
end

-- 请求-拆除联盟建筑
function Net.AllianceBuildings.Destroy(...)
    local fields = {
        "ConfId", -- int32
    }
    Network.RequestDynamic("AllianceBuildingDestroyParams", fields, ...)
end

-- 请求-收回联盟堡垒
function Net.AllianceBuildings.Recover(...)
    local fields = {
        "ConfId", -- int32
    }
    Network.RequestDynamic("AllianceFortressRecoverParams", fields, ...)
end

-- 请求-联盟堡垒列表
function Net.AllianceBuildings.FortressList(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceFortressListParams", fields, ...)
end

-- 请求-获取基地附近建造地块
function Net.AllianceBuildings.GetNearbyBuildPlace(...)
    local fields = {
        "ConfId", -- int32
    }
    Network.RequestDynamic("GetNearbyBuildPlaceParams", fields, ...)
end

-- 请求-遣返驻军
function Net.AllianceBuildings.RemovalGarrison(...)
    local fields = {
        "X", -- int32
        "Y", -- int32
        "UserId", -- string
    }
    Network.RequestDynamic("RemovalGarrisonParams", fields, ...)
end

-- 请求-联盟建筑地图信息
function Net.AllianceBuildings.BuildingMapInfo(...)
    local fields = {
        "AllianceId", -- string
        "ConfId", -- int32
    }
    Network.RequestDynamic("AllianceBuildingMapInfoParams", fields, ...)
end

return Net.AllianceBuildings