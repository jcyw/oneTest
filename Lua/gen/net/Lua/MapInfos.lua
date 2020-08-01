Net.MapInfos = {}

-- 请求-搜索野矿
function Net.MapInfos.SearchMine(...)
    local fields = {
        "Category", -- int32
        "Level", -- int32
    }
    Network.RequestDynamic("MapSearchMineParams", fields, ...)
end

-- 请求-搜索野怪
function Net.MapInfos.SearchMonster(...)
    local fields = {
        "TaskSearch", -- bool
        "Level", -- int32
    }
    Network.RequestDynamic("MapSearchMonsterParams", fields, ...)
end

-- 请求-地块信息
function Net.MapInfos.MatrixInfo(...)
    local fields = {
        "ServerId", -- string
        "UserId", -- string
        "CenterX", -- int32
        "CenterY", -- int32
        "WidthRadius", -- int32
        "HeightRadius", -- int32
        "ForceRefresh", -- bool
    }
    Network.RequestDynamic("MapMatrixInfoParams", fields, ...)
end

-- 请求-联盟矿信息
function Net.MapInfos.AllianceMineInfo(...)
    local fields = {
        "MineId", -- int32
    }
    Network.RequestDynamic("MapAllianceMineInfoParams", fields, ...)
end

-- 请求-单个地块信息
function Net.MapInfos.PointInfo(...)
    local fields = {
        "ServerId", -- string
        "X", -- int32
        "Y", -- int32
    }
    Network.RequestDynamic("MapPointInfoParams", fields, ...)
end

-- 请求-搜索秘密基地
function Net.MapInfos.SearchSecretBase(...)
    Network.RequestDynamic("MapSearchSecretBaseParams", {}, ...)
end

-- 请求-离开地图
function Net.MapInfos.LeaveMap(...)
    Network.RequestDynamic("MapInfosLeaveParams", {}, ...)
end

return Net.MapInfos