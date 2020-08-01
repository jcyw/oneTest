--[[
    author:{zhanzhang}
    time:2020-03-16 16:43:17
    function:{大地图建筑管理器}
]]
local BuildingManager = {}
local ItemMapTown = import("UI/WorldMap/ItemMapTown")
local ItemMapThrone = import("UI/WorldMap/ItemMapThrone")
local ItemMapFort = import("UI/WorldMap/ItemMapFort")

--主城缓存
local MapBuildList = {}
local PosTownMap = {}

function BuildingManager.RefreshMapTown(obj, posNum)
    local itemMap
    if not obj then
        itemMap = PosTownMap[posNum]
        if not itemMap then
            return
        end
    else
        local UUID = obj:GetInstanceID()
        itemMap = MapBuildList[UUID]
        if not itemMap then
            itemMap = new(ItemMapTown)
            itemMap:Init(obj)
            MapBuildList[UUID] = itemMap
            PosTownMap[posNum] = itemMap
        end
    end

    itemMap:RefreshCity(posNum)
    itemMap:RefreshComponent(posNum)
end
function BuildingManager.GetItemTown(obj)
    local UUID = obj:GetInstanceID()
    local itemMap = MapBuildList[UUID]
    if not itemMap then
        itemMap = new(ItemMapTown)
        itemMap:Init(obj)
        MapBuildList[UUID] = itemMap
    end
    return itemMap
end

function BuildingManager.ClearBuildInfo(obj, posNum)
    local UUID = obj:GetInstanceID()
    local itemMap = MapBuildList[UUID]
    if itemMap then
        itemMap:ClearBuildInfo()
    end
end
--王座和炮塔仅有5个，没有必要回收
function BuildingManager.RefreshMapThrone()
    local itemThrone
    if PosTownMap[6000600] then
        itemThrone = PosTownMap[6000600]
    else
        itemThrone = new(ItemMapThrone)
        PosTownMap[6000600] = itemThrone
    end
    itemThrone:Refresh()
end

function BuildingManager.RefreshMapFort(posNum)
    local itemFort
    if PosTownMap[posNum] then
        itemFort = PosTownMap[posNum]
    else
        itemFort = new(ItemMapFort)
        PosTownMap[posNum] = itemFort
    end
    itemFort:Refresh(posNum)
    return itemFort
end

return BuildingManager
