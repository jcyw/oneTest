--[[
    author:{zhanzhang}
    time:2019-07-22 19:31:00
    function:{联盟领地管理Model}
]]
local UnionTrritoryModel = {}
local configList = {}
local typeCount = 0
local buildInfoList = {}
local pointPos = 0

function UnionTrritoryModel.Init(buildInfo)
    configList = {}
    local territorList
    if #configList == 0 then
        territorList = ConfigMgr.GetList("configAllianceFortresss")
        for i = 1, #territorList do
            if territorList[i].display == 1 then
                if not configList[territorList[i].building_type] then
                    configList[territorList[i].building_type] = {}
                end
                table.insert(configList[territorList[i].building_type], territorList[i])

                -- typeCount = territorList[i].building_type > typeCount and territorList[i].building_type or typeCount
            end
        end
    end
    for i = 1, #buildInfo.Fortresses do
        local config = ConfigMgr.GetItem("configAllianceFortresss", buildInfo.Fortresses[i].ConfId)
        if config.display == 1 then
            buildInfoList[buildInfo.Fortresses[i].ConfId] = buildInfo.Fortresses[i]
        end
    end
    local id
end

function UnionTrritoryModel.GetTerritorTypeList()
    return configList
end

function UnionTrritoryModel.GetTerritorTypeCount()
    local typeList = {}
    typeCount = 0
    for k,v in pairs(configList or {}) do
        typeCount = typeCount + 1
        typeList[#typeList + 1] = k
    end
    return typeCount,typeList
end

function UnionTrritoryModel.GetTerritorTypeListByIndex(index)
    return configList[index]
end

function UnionTrritoryModel.GetTerritorDetail(index)
    return buildInfoList[index]
end

-- 获取已有的联盟堡垒数量
function UnionTrritoryModel.GetAmountOfCompletedFortress()
    local amount = 0
    local fortressList = configList[1]
    for _, v in pairs(fortressList) do
        if buildInfoList[v.id].State > 2 then
            amount = amount + 1
        end
    end

    return amount
end
--获取联盟建筑修建状态
function UnionTrritoryModel.GetBuildingStatus(id)
    local info = UnionTrritoryModel.GetTerritorDetail(id)

    return 0
end

function UnionTrritoryModel.SetPointPos(posNum)
    pointPos = posNum
end
function UnionTrritoryModel.GetPointPos()
    return pointPos
end

return UnionTrritoryModel
