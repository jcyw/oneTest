--[[
    author:{zhanzhang}
    time:2020-01-03 10:56:50
    function:{地图Model}
]]
local ItemMapTownUI = import("UI/WorldMap/ItemMapTownUI")
local ItemMineUI = import("UI/WorldMap/ItemMineUI")
local ItemMonsterUI = import("UI/WorldMap/ItemMonsterUI")
local ItemMapThroneUI = import("UI/WorldMap/ItemMapThroneUI")
local ActivityModel = import("Model/ActivityModel")
local ItemMapFortUI =  import("UI/WorldMap/ItemMapFortUI")

local CVector3 = _G.CVector3
local ResMgr = _G.ResMgr

local UIIndex = {}
local UIPool = {}
local WorldMapModel = {}

local BuildUIPool = {}
local BuildUI

local canBuildMat
local noBuildMat
local BuildCheckPointPos = {}
local worldPointNode

local AllArmyRota = CVector3(40, -135, 0)
local MarchAnimPool = {}

local BuildShieldList = {}
local WorldMapPrefab = {}
--大地图UI缓存
local MapUIList = {}

--动态地块图集
local tilemapAtlas
local tilemapAtlasWithAlpha
local atlasReady = false

------------------地图对象池-------------

function WorldMapModel.MapUIInit(key, pkgName, uiName)
    if UIIndex[key] then
        return
    end
    if not pkgName or not uiName then
        return
    end
    UIIndex[key] = {
        pkgName = pkgName,
        uiName = uiName
    }
end

function WorldMapModel.MapUIGet(key)
    if not UIIndex[key] then
        return
    end
    if not UIPool[key] then
        UIPool[key] = {}
    end
    if next(UIPool[key]) == nil then
        local obj = UIMgr:CreateObject(UIIndex[key].pkgName, UIIndex[key].uiName)
        if not obj then
            Log.Error("NodePool.Get Error 对象创建失败 key: ", key)
            return
        end
        return obj
    end

    local obj = UIPool[key][1]
    table.remove(UIPool[key], 1)
    return obj
end
function WorldMapModel.MapUIRelese(key, value)
    if not UIIndex[key] then
        return
    end
    if not UIPool[key] then
        return
    end
    value.x = 999999
    table.insert(UIPool[key], value)
end
----------------新版建筑UI对象池----------------
function WorldMapModel.MapBuildUIInit()
    _G.mapOffset = ConfigMgr.GetItem("ConfigMaps", Model.MapConfId).offset

    --获取王城战信息
    ActivityModel.ReqRoyalBattle()
    _G.RoyalModel.SetKingWarInfo()
end

-- function WorldMapModel.GetRoyalBattle

function WorldMapModel.MapBuildUIGet(category)
    if not BuildUIPool[category] then
        BuildUIPool[category] = {}
    end
    local buildUI
    if next(BuildUIPool[category]) == nil then
        local index = 0
        if category == Global.MapTypeTown or category == Global.MapTypeAllianceDomain or category == Global.MapTypeAllianceStore then
            index = 100001
            buildUI = new(ItemMapTownUI)
        elseif category == Global.MapTypeMine then
            index = 100002
            buildUI = new(ItemMineUI)
        elseif category == Global.MapTypeMonster then
            index = 100003
            buildUI = new(ItemMonsterUI)
        elseif category == Global.MapTypeThrone then
            index = 100004
            buildUI = new(ItemMapThroneUI)
        elseif category == Global.MapTypeFort then
            index = 100004
            buildUI = new(ItemMapFortUI)
        end
        if not buildUI then
            Log.Error("NodePool.Get Error 对象创建失败 key: {0}", category)
            return
        end

        buildUI:Init(index)
        return buildUI
    end
    buildUI = BuildUIPool[category][1]
    table.remove(BuildUIPool[category], 1)
    return buildUI
end
function WorldMapModel.MapBuildUIRelese(catetory, mapUI)
    if not BuildUIPool[catetory] then
        return
    end
    mapUI:OnClose()
    table.insert(BuildUIPool[catetory], mapUI)
end
-----------------------------------

function WorldBuildType.InitBuildMove()
    coroutine.yield(ResMgr.Instance:LoadPrefab("testure/materials"))
    prefab = ResMgr.Instance:GetPrefab("prefabs/plotchunk")
end

--1-4为下 右 左 上 5为其他地方
function WorldMapModel.GetPosByIndex(index)
    if not BuildCheckPointPos or #BuildCheckPointPos == 0 then
        BuildCheckPointPos = {}
        BuildCheckPointPos[1] = CVector3.zero
        BuildCheckPointPos[2] = CVector3(5, 0, -2.5)
        BuildCheckPointPos[3] = CVector3(-5, 0, -2.5)
        BuildCheckPointPos[4] = CVector3(0, 0, -5)
        BuildCheckPointPos[5] = CVector3(5000, 0, 0)
    end
    return BuildCheckPointPos[index]
end
-- --设置玩家国旗
-- function WorldMapModel.SetFlag(obj, ownerId)
--     local Owner = MapModel.GetMapOwner(ownerId)
--     local path = "texture/nationalflag/"
--     local texture = ResMgr.Instance:LoadTextureSync(path .. ConfigMgr.GetItem("configFlags", Owner.Flag).icon[2])
--     local flag = obj.transform:Find("Flag/Plane001")
--     local render = flag:GetComponent("SkinnedMeshRenderer")
--     local prop = MaterialPropertyBlock()
--     render:GetPropertyBlock(prop)
--     prop:SetTexture("_MainTex", texture)
--     render:SetPropertyBlock(prop)
-- end

function WorldMapModel.GetMarchConfig(marchType, num)
    local config = ConfigMgr.GetList("configArmyQueue")
    local num = 10000
    local nowConfig
    local isRally = 0
    if marchType == Global.MissionRally then
        isRally = 1
    else
        isRally = 0
    end
end

function WorldMapModel.ResetSprite(obj,catetory)
    local info = ConfigMgr.GetItem("configMaptiles", catetory)
    if info.layer == 0 and atlasReady then
        local spriteRenderer = obj:GetComponent("SpriteRenderer")
        local newSprite = tilemapAtlas:GetSprite(info.name)
        if newSprite then
            spriteRenderer.sprite = newSprite
        end
    elseif info.layer == 1 and atlasReady then
        local spriteRenderer = obj:GetComponent("SpriteRenderer")
        local newSprite = tilemapAtlasWithAlpha:GetSprite(info.name)
        if newSprite then
            spriteRenderer.sprite = newSprite
        end
    end
    return atlasReady
end

function WorldMapModel.GetWorldMapPrefab(catetory)
    local obj = WorldMapPrefab[catetory]
    if not obj then
        local info = ConfigMgr.GetItem("configMaptiles", catetory)
        WorldMapPrefab[catetory] = ResMgr.Instance:LoadPrefabSync(info.path)
        obj = WorldMapPrefab[catetory]
    end
    return obj
end

function WorldMapModel.GetRoyalBattleInfo()
    -- ActivityModel.G
end


function WorldMapModel.PreloadMapResSync()
    _G.CSCoroutine.Start(
        function()
            local infos = _G.ConfigMgr.GetList("configMaptiles")
            for i, info in ipairs(infos) do
                WorldMapPrefab[info.id] = ResMgr.Instance:LoadPrefabSync(info.path)
                if i % 20 == 0 then
                    coroutine.yield()
                end
            end
        end
    )
    DynamicRes.GetBundle("worldmap_atlas",
        function(ab)
            local atlas = ab:LoadAsset("tilemap")
            if atlas then
                tilemapAtlas = atlas
            end
            local atlasWithAlpha = ab:LoadAsset("tilemapwithalpha")
            if atlasWithAlpha then
                tilemapAtlasWithAlpha = atlasWithAlpha
            end
            atlasReady = true
        end
    )
end

--从池中获取对应UI
function WorldMapModel.PoolGetMapUI(posNum, category)
    local info
    if MapUIList[posNum] then
        info = MapUIList[posNum]
        if info.category == category then
            return info.mapUI
        else
            WorldMapModel.PoolDelMapUI(posNum)
        end
    end
    info = {}
    local newUI = WorldMapModel.MapBuildUIGet(category)
    info.category = category
    info.mapUI = newUI
    MapUIList[posNum] = info

    return newUI
end

--回收对应地块的UI
function WorldMapModel.PoolDelMapUI(posNum)
    local info = MapUIList[posNum]
    if info then
        if not info.mapUI then
            Log.Warning("回收值为空")
            return
        end
        WorldMapModel.MapBuildUIRelese(info.category, info.mapUI)
        info.mapUI = nil
        MapUIList[posNum] = nil
    end
end

return WorldMapModel
