local CVector3 = _G.CVector3
local Vector3 = _G.Vector3
local ResMgr = _G.ResMgr
local Screen = _G.Screen

local floor = math.floor
local ceil = math.ceil
local sqrt = math.sqrt
local abs = math.abs

local Map = {
    behaviour = nil, -- csharp monobehaviour
    gameObject = nil, -- 地图预制对象
    camera = nil, -- 主相机
    transform = nil,
    MapLayers = {}
}

local BuildingManager = import("UI/WorldMap/BuildingManager")
-- ======================Local Vars============================
local prefabMapPath = "prefabs/worldmap"
local luaPath = "UI/WorldMap/CSWorldMap"
local WorldMapModel = import("Model/WorldMapModel")

-- 小正方形边长(float)
local UnitSideLen = 0
-- 扩充数量(int)
local extendAmount = 0

local MapRectOffset = 20

-- 回调代理
local Delegate

-- 地块预制(category -> prefab)
local prefabs = {}
local chunkCache = {}

-- 使用中：地块{pos -> {category -> Tile}}
local tiles = {}
-- 地块类型信息
local tileCategories = {}
local posIndexes = {}
-- 缓存：地块(类型 -> List)
local cacheTiles = {}
local oldTemp = {}

-- 联盟领地线
local allianceLineBlue = 600 -- 我方联盟领地线id
local allianceLineRed = 601 -- 地方联盟领地线id
local allianceLine = {[allianceLineBlue] = {}, [allianceLineRed] = {}} -- 正在使用联盟领地线
local cacheAllianceLine = {[allianceLineBlue] = {}, [allianceLineRed] = {}} -- 缓存联盟领地线

local lastcenterNum = -1000
local currentcenterNum = 0
local lastCheckLoadPos  -- Vector3
local plane  -- Plane
local ray  -- Ray
-- local mapArray
local mapTileArray
local mapTerrinArray
--不可覆盖地形
local mapBlockArray
local lastLogicPoints = {}

local _widthRadius
local _heightRadius
local _mapLength = 1201
local _screenVec3 = CVector3(Screen.width / 2, Screen.height / 2, 0)
local _borderVec3 = CVector3(0, 90, 0)

local minBorder = 0
local maxBorder = 0

local notRefreshAllTiles = true

-- ======================Static Methods========================
-- return map prefab instance
function Map.Create(tileLen, extendTiles, offset, delegate)
    UnitSideLen = tileLen
    extendAmount = extendTiles
    Delegate = delegate
    local ins = LuaBehaviour.Create(prefabMapPath, luaPath)

    return ins
end

-- ======================MonoBehaviour=========================
-- Behaviour creator
function Map.New(behaviour)
    local map = new(Map)
    map.behaviour = behaviour
    map.gameObject = behaviour.gameObject
    return map
end

function Map:Awake()
end

function Map:Start()
    -- 常用对象
    self.camera = GameObject.FindWithTag("MainCamera"):GetComponent("Camera")
    self.camera.orthographicSize = 4
    self.camera.enabled = true
    self.transform = self.gameObject.transform:Find("MapLayers")
    for i = 0, 4 do
        self.MapLayers[i] = self.transform:Find("" .. i).gameObject
    end
    plane = CS.UnityEngine.Plane(CVector3.up, CVector3.zero)
    -- 计算地图显示范围
    local unitDiagonalLen = UnitSideLen * sqrt(2)
    local topLeftPos = CVector3(0, Screen.height, 0)
    local topRightPos = CVector3(Screen.width, Screen.height, 0)
    local mapTopWidth = CVector3.Distance(self:ScreenPosToMap(topLeftPos), self:ScreenPosToMap(topRightPos))
    -- 左右半径
    _widthRadius = floor(ceil((mapTopWidth - unitDiagonalLen) / unitDiagonalLen / 2)) + extendAmount
    local mapHeight = CVector3.Distance(self:ScreenPosToMap(Vector3.zero), self:ScreenPosToMap(CVector3(0, Screen.height, 0)))
    -- 上下半径
    _heightRadius = floor(ceil((mapHeight - unitDiagonalLen) / unitDiagonalLen / 2)) + extendAmount + 2
    -- 加载地貌
    mapTileArray = ResMgr.Instance:LoadBytesFromBundle("terrian/map_tile")
    mapTerrinArray = ResMgr.Instance:LoadBytesFromBundle("terrian/map_terrain")
    mapBlockArray = ResMgr.Instance:LoadBytesFromBundle("terrian/map_blocktile")
    self:preloadMapResSync()
    minBorder = _G.mapOffset
    maxBorder = 1200 - minBorder
end

function Map:Update()
    Delegate:OnUpdate()
end

function Map:OnDestroy()
    Log.Info("CSWorldMap OnDestroy!")
end

-- ======================Instance Methods======================
function Map:AddChild(posNum, category)
    local anchorP = posNum
    local info = chunkCache[anchorP]
    if not info then
        info = {category = catetory}
        chunkCache[anchorP] = info
    else
        info.category = category
        chunkCache[anchorP] = info
    end
    return self:addTileToMap(anchorP, category, false)
end

function Map:DelChild(posNum, category)
    local categoryTiles = tiles[posNum]
    if categoryTiles then
        for key, _ in pairs(categoryTiles) do
            if key == 255 or key > 400 then
                self:delTileFromMap(posNum, key)
            end
        end
    end
end

function Map:GetChild(posNum, category)
    return self:getTileFromMap(posNum, category)
end

-- 按照坐标跳转
function Map:GotoPoint(currentX, currentY)
    local pos = self:logicToMapPos(currentX, currentY)
    pos = MathUtil.NegativeV3(pos)
    self.transform.position = pos
    --lastCheckLoadPos = pos
    lastcenterNum = self:ScreenToLogicPos(_screenVec3)
    self:mapRefresh()
end

function Map:MoveToPos(pos)
    self.transform.position = MathUtil.NegativeV3(pos)
    self:checkMapOffset()
end

function Map:ScreenToWorldPos(screenPos)
    local ray = self.camera:ScreenPointToRay(screenPos)
    local _, distance = plane:Raycast(ray)
    return ray:GetPoint(distance)
end

function Map:ScreenToLogicPos(screenPos)
    local worldPos = self:ScreenToWorldPos(screenPos)
    local pos = _G.MathUtil.V3Minus(worldPos, self.transform.position)
    return self:MapToLogicPos(pos)
end
--用于精确获取坐标
function Map:ScreenToLogicPoint(screenPos)
    local worldPos = self:ScreenToWorldPos(screenPos)
    local pos = _G.MathUtil.V3Minus(worldPos, self.transform.position)
    local x = (pos.x - UnitSideLen / 2) / UnitSideLen
    local y = (pos.z - UnitSideLen / 2) / UnitSideLen
    return x, y
end

function Map:LogicToMapPos(posNum)
    local x, y = self:DecodePosNum(posNum)
    return self:logicToMapPos(x, y)
end

function Map:MapToLogicPoint(pos)
    local x = ceil((pos.x - UnitSideLen / 2) / UnitSideLen)
    local y = ceil((pos.z - UnitSideLen / 2) / UnitSideLen)
    return x, y
end

function Map:MapToLogicPos(pos)
    local x = ceil((pos.x - UnitSideLen / 2) / UnitSideLen)
    local y = ceil((pos.z - UnitSideLen / 2) / UnitSideLen)
    return x * 10000 + y
end

-- 判断是否是地形
function Map:IsMapTerrain(posNum)
    -- local category = self:getBaseTerrainCategory(posNum) + 300
    -- local info = tileCategories[category]
    -- if not info then
    --     return
    -- end

    -- if info.layer == 2 then
    --     return true
    -- end
    -- return false
    local posX, posY = MathUtil.GetCoordinate(posNum)
    local value = string.byte(mapBlockArray, posX * 1201 + posY + 1)
    -- print("IsMapTerrain    ")
    -- print(value)

    return value == 1
end

function Map:GetMapPos()
    return self.transform.position
end

-- function Map:CSCoroutinePerfab(info, cb)
--     CSCoroutine.Start(function()
--         local info = ConfigMgr.GetItem("configMaptiles", info.category)
--         coroutine.yield(ResMgr.Instance:LoadPrefab(info.path))
--         local prefab = ResMgr.Instance:GetPrefab(info.path)
--         if not prefab then
--             return
--         end
--         local transform = self:GetMapLayer(info.layer).transform
--         local cloneObj = UObject.Instantiate(prefab, transform, true)
--         if info.scale then
--             local str = info.scale.Split(":")
--             cloneObj.transform.localScale = CVector3(tonumber(str[0]), tonumber(str[1]), tonumber(str[2]))
--         end
--         cb(cloneObj)
--     end)
-- end
-- ======================Private Methods=======================
function Map:addTileToMap(posNum, category, isBase)
    
    local info = tileCategories[category]
    -- local posX, posY = self:DecodePosNum(posNum)
    if not info then
        info = tileCategories[category - 1]
        if not info then
            return
        end
    end

    local indexes
    -- 高层有建筑的时候 第一层的不显示
    if info.layer == 1 then
        indexes = posIndexes[2]
        if indexes ~= nil and indexes[posNum] then
            --Log.Error("已经有建筑了")
            return
        else
            indexes = posIndexes[3]
            if indexes ~= nil and indexes[posNum] then
                --Log.Error("已经有建筑了")
                return
            end
        end
    end

    local anchorP = -1
    local posX, posY = self:DecodePosNum(posNum)
    if (info.width > 1 or info.height > 1) and info.radius == 1 and info.layer > 0 then
        -- 判断上下左右四个点，根据点判断物体的锚点
        local tmpX = posX + info.height - 1
        local tmpY = posY + info.width - 1
        if category == info.category then
            anchorP = posNum
        elseif tmpX < (maxBorder+1) and self:getMapArrayItem(tmpX * (maxBorder+1) + posY) == info.category then
            anchorP = tmpX * (maxBorder+1) + posY
        elseif tmpY < (maxBorder+1) and self:getMapArrayItem(posX * (maxBorder+1) + tmpY) == info.category then
            anchorP = posX * _mapLength + tmpY
        elseif tmpX < (maxBorder+1) and tmpY < (maxBorder+1) and self:getMapArrayItem(tmpX * (maxBorder+1) + tmpY) == info.category then
            anchorP = tmpX * (maxBorder+1) + tmpY
        end
    else
        anchorP = posNum
    end

    if anchorP == -1 then
        return
    end

    -- 清除格子上的原有建筑
    local categoryTiles = tiles[anchorP]
    if not categoryTiles then
        if not isBase then
            return
        end
        categoryTiles = {}
        tiles[anchorP] = categoryTiles
    end
    --判断是否已经有
    indexes = posIndexes[info.layer]
    if indexes ~= nil and indexes[posNum] then
        return categoryTiles[info.category]
    end

    --if info.layer == 1 then
    --    local tempTiles = tiles[posNum]
    --    for k, _ in pairs(tempTiles or {}) do
    --        local tempInfo = tileCategories[k]
    --        if tempInfo.layer > 1 then
    --            Log.Info("已经有建筑了")
    --            return
    --        end
    --    end
    --end

    local ins = self:getCacheTile(info.category)
    if not ins then
        ins = self:initMapObject(info, isBase)
    end
    local atlasReady = WorldMapModel.ResetSprite(ins,info.category)
    if atlasReady and notRefreshAllTiles then
        self:RecreshAllTilesSprites(tiles)
    end
    if categoryTiles[info.category] then
        self:delTileFromMap(anchorP, info.category)
    end

    -- 删除建筑覆盖区域的植被

    -- 判断占地格子，用于清除环境地皮
    if info.layer > 1 then
        local point = 0
        for i = 0, info.width - 1 do
            for j = 0, info.height - 1 do
                point = self:EncodePosNum(posX - i, posY - j)
                local resTiles = tiles[point]
                if resTiles then
                    for k, _ in pairs(resTiles) do
                        local tempInfo = tileCategories[k]
                        if tempInfo.layer == 1 then
                            self:delTileFromMap(point, k)
                        end
                    end
                end
            end
        end
    end

    if not ins then
        Log.Error("生成地图对象错误   " .. category)
    end
    self:setTileMapPos(ins, info.layer, anchorP, info.width, info.height, info.radius)
    categoryTiles[info.category] = ins
    -- self:RefreshMapBorder(posX, posY, posNum)
    self:AddMapBorder(posNum, posX, posY)
    return ins
end

function Map:RecreshAllTilesSprites(tiles)
    for _,tileList in pairs(tiles or {}) do
        for k,v in pairs(tileList or {}) do
            WorldMapModel.ResetSprite(v,k)
        end
    end
    notRefreshAllTiles = false
end

function Map:preloadMapResSync()
    local infos = Delegate:OnRegister(self)
    for _, info in ipairs(infos) do
        tileCategories[info.category] = info
        -- prefabs[info.category] = ResMgr.Instance:LoadPrefabSync(info.source)
    end
    self.MapBorderConfig = ConfigMgr.GetItem("configResourcePaths", PrefabType.WorldMap.Map_BorderLine)
    Delegate:OnMapInit()
end

function Map:mapRefresh()
    --local moved = self.transform.position - CVector3.zero
    local currentLogicPoints, currentX, currentY = self:getPoints(false)
    local addPoints = {}
    local delPoints = {}
    for pos, _ in pairs(currentLogicPoints) do
        if not lastLogicPoints[pos] then
            addPoints[pos] = true
        end
    end
    for pos, _ in pairs(lastLogicPoints) do
        if not currentLogicPoints[pos] then
            delPoints[pos] = true
        end
    end
    lastLogicPoints = currentLogicPoints
    local matrix = {
        centerX = currentX,
        centerY = currentY,
        widthRadius = _widthRadius,
        heightRadius = _heightRadius
    }
    self:OnMapRefresh(matrix, addPoints, delPoints)
end

function Map:CheckPointInView(posNum)
    return lastLogicPoints[posNum]
end

-- 回调Lua地块刷新
function Map:OnMapRefresh(matrix, addPoints, delPoints)
    -- 添加基础地貌
    self:addBaseTiles(addPoints)
    -- self:RefreshMapBorder(matrix, addPoints)

    -- 回收地块对象
    for posNum, _ in pairs(delPoints) do
        local categoryTiles = tiles[posNum]
        if categoryTiles then
            for category, tile in pairs(categoryTiles) do
                self:delTileMapPos(tile, posNum, category)
                self:addCacheTile(category, tile)
            end
        end
        self:RemoveMapBorder(posNum)
        tiles[posNum] = nil
    end

    -- 回调Lua
    Delegate:OnRefresh(matrix)
end
--is_G.mapOffset是否计算偏移量
function Map:getPoints(isMapOffset)
    local points = {}
    -- 屏幕中心坐标
    local centerNum = self:ScreenToLogicPos(_screenVec3)
    local centerX = floor(centerNum / 10000)
    local centerY = centerNum % 10000
    local startX = centerX + _heightRadius
    local startY = centerY + _heightRadius

    local height = _heightRadius * 2
    local maxLength = isMapOffset and maxBorder or _mapLength
    local minLength = isMapOffset and minBorder or 0

    local point
    for w = -_widthRadius, _widthRadius do
        local x = startX - w
        local y = startY + w

        for h = 0, height - 1 do
            local px = x - h
            local py = y - h
            if isMapOffset and (px < 0 or py < 0 or px > maxLength or py > maxLength) then
                break
            end
            point = self:EncodePosNum(px, py)
            points[point] = true
        end

        if w ~= _widthRadius then
            x = x - 1
            for h = 0, height - 2 do
                local px = x - h
                local py = y - h
                if isMapOffset and (px < 0 or py < 0 or px > maxLength or py > maxLength) then
                    break
                end
                point = self:EncodePosNum(px, py)
                points[point] = true
            end
        end
    end
    return points, centerX, centerY
end

local tileHidePos = CVector3(0, 1000, 0)
function Map:addCacheTile(category, ins)
    local info = ConfigMgr.GetItem("configMaptiles", category)
    if info.layer == 0 or info.layer == 1 then
        category = info.layer
    end
    local list = cacheTiles[category]
    if not list then
        list = {}
        cacheTiles[category] = list
    end
    list[#list + 1] = ins
    -- table.insert(list, ins)
end

function Map:getCacheTile(category)
    local info = ConfigMgr.GetItem("configMaptiles", category)
    if info.layer == 0 or info.layer == 1 then
        category = info.layer
    end
    local list = cacheTiles[category]
    if list and #list > 0 then
        return table.remove(list, #list)
    end
end

function Map:addBaseTiles(addPoints)
    local category = 0
    local chunkInfo
    local otherCategory = 0
    for posNum, _ in pairs(addPoints) do
        category = self:getBaseTileCategory(posNum)
        if not category then
            Log.Error(posNum)
            break
        end
        self:addTileToMap(posNum, category, true)
        otherCategory = self:getBaseTerrainCategory(posNum)
        if otherCategory >= 0 and otherCategory < 255 then
            self:addTileToMap(posNum, 300 + otherCategory, true)
        end
    end
end

function Map:RemoveNoUsePoints()
    local currentLogicPoints = self:getPoints(false)
    for pos, val in pairs(tiles) do
        if not currentLogicPoints[pos] then
            if val then
                for category, tile in pairs(val) do
                    self:delTileMapPos(tile, pos, category)
                    self:addCacheTile(category, tile)
                end
            end
            self:RemoveMapBorder(pos)
            tiles[pos] = nil
        end
    end
end

function Map:moveRemainPoints(remainPoints)
    for posNum, _ in pairs(remainPoints) do
        local category = self:getBaseTileCategory(posNum)
        local ins = self:getTileFromMap(posNum, category)
        local x, y = self:DecodePosNum(posNum)
        local pos = CVector3(x * UnitSideLen, 0, y * UnitSideLen)
        if tileCategories[category] then
            local info = tileCategories[category]
            if (info.width > 1 or info.height > 1) and info.radius == 1 then
                local diff = (-0.5 * (info.width - 1) * UnitSideLen)
                pos = _G.MathUtil.V3Plus(pos, CVector3(diff, 0, diff))
            end
        end
        if ins then
            ins.transform.localPosition = pos
        end
    end
end
--获取基础地貌
function Map:getBaseTileCategory(posNum)
    local tempX, tempY = self:DecodePosNum(posNum)
    if tempX > 1200 then
        tempX = tempX - 1200
    elseif tempX < 0 then
        tempX = 800 + tempX
    end
    if tempY > 1200 then
        tempY = tempY - 1200
    elseif tempY < 0 then
        tempY = 800 + tempY
    end
    local anchorP = tempX * _mapLength + tempY
    return self:getMapArrayItem(anchorP)
end
--获取地面地貌
function Map:getBaseTerrainCategory(posNum)
    local tempX, tempY = self:DecodePosNum(posNum)
    if tempX > 1200 then
        tempX = tempX - 1200
    elseif tempX < 0 then
        tempX = 800 + tempX
    end
    if tempY > 1200 then
        tempY = tempY - 1200
    elseif tempY < 0 then
        tempY = 800 + tempY
    end
    local anchorP = tempX * _mapLength + tempY
    return string.byte(mapTerrinArray, anchorP + 1)
end

function Map:getMapArrayItem(idx)
    local value = string.byte(mapTileArray, idx + 1)
    return value
end

function Map:getMapTerrainItem()
end

function Map:ClearAllianceLandLine()
    for _, v in pairs(allianceLine[allianceLineBlue]) do
        v.gameObject:SetActive(false)
        table.insert(cacheAllianceLine[allianceLineBlue], v)
    end
    for _, v in pairs(allianceLine[allianceLineRed]) do
        v.gameObject:SetActive(false)
        table.insert(cacheAllianceLine[allianceLineRed], v)
    end
    allianceLine[allianceLineBlue] = {}
    allianceLine[allianceLineRed] = {}
end

function Map:ShowAllianceLand(points, direction, isEnemy)
    for _, point in pairs(points) do
        local tempTiles = tiles[point]
        if tempTiles then
            for k, v in pairs(tempTiles) do
                if tileCategories[k].layer == 0 then
                    local pos = v.transform.localPosition
                    local line
                    if isEnemy then
                        local info = tileCategories[allianceLineRed]
                        if next(cacheAllianceLine[allianceLineRed]) then
                            line = table.remove(cacheAllianceLine[allianceLineRed], 1)
                            line.gameObject:SetActive(true)
                        else
                            line = self:initMapObject(info)
                        end
                        table.insert(allianceLine[allianceLineRed], line)
                    else
                        local info = tileCategories[allianceLineBlue]
                        if next(cacheAllianceLine[allianceLineBlue]) then
                            line = table.remove(cacheAllianceLine[allianceLineBlue], 1)
                            line.gameObject:SetActive(true)
                        else
                            line = self:initMapObject(info)
                        end
                        table.insert(allianceLine[allianceLineBlue], line)
                    end

                    if line then
                        line.transform.localPosition = pos
                        if direction == "D" then
                            line.transform.localEulerAngles = CVector3(90, 0, -90)
                        elseif direction == "L" then
                            line.transform.localEulerAngles = CVector3(-90, 0, 0)
                        elseif direction == "T" then
                            line.transform.localEulerAngles = CVector3(-90, 90, 0)
                        else
                            line.transform.localEulerAngles = CVector3(90, 0, 0)
                        end
                    end
                    break
                end
            end
        end
    end
end

function Map:getTileData(x,y)
    local usedPos = self:EncodePosNum(x, y)
    local categoryTiles = tiles[usedPos]
    if(categoryTiles)then
        return true
    else
        return false
    end
end

function Map:getTileFromMap(posNum, category)
    local categoryTiles = tiles[posNum]
    return categoryTiles and categoryTiles[category]
end

function Map:delTileFromMap(posNum, category)
    local categoryTiles = tiles[posNum]
    if not categoryTiles then
        return
    end

    local ins = categoryTiles[category]
    if ins then
        categoryTiles[category] = nil
        self:delTileMapPos(ins, posNum, category)
        self:addCacheTile(category, ins)
    end
end

function Map:initMapObject(info, isBase)
    -- local prefab = prefabs[info.category]
    local prefab = WorldMapModel.GetWorldMapPrefab(info.category)
    if not prefab then
        return
    end

    local transform = self:GetMapLayer(info.layer).transform
    local cloneObj = UObject.Instantiate(prefab, transform, true)
    cloneObj:SetActive(true)
    if info.scale then
        local str = info.scale.Split(":")
        cloneObj.transform.localScale = CVector3(tonumber(str[0]), tonumber(str[1]), tonumber(str[2]))
    end
    return cloneObj
end

function Map:GetMapLayer(layer)
    return self.MapLayers[layer]
end

function Map:CancelTileFlush()
    for i = 0, oldTemp.Count - 1 do
        oldTemp[i]:SetActive(false)
    end
end

function Map:checkMapOffset()
    --local moved = MathUtil.V3Minus(self.transform.position, lastCheckLoadPos)
    --if abs(moved.x) >= UnitSideLen / 10 * (extendAmount - 1) or abs(moved.z) >= UnitSideLen / 10 * (extendAmount - 1) then
        --lastCheckLoadPos = self.transform.position
        currentcenterNum = self:ScreenToLogicPos(_screenVec3)
        if (currentcenterNum ~= lastcenterNum) then
            lastcenterNum = currentcenterNum
            self:mapRefresh()
        end
    --end
end

function Map:setTileMapPos(ins, layer, posNum, width, height, whole)
    local pos = self:LogicToMapPos(posNum)
    if (width > 1 or height > 1) and whole == 1 then
        local diff = -0.5 * (width - 1) * UnitSideLen
        pos = _G.MathUtil.V3Plus(pos, CVector3(diff, 0, diff))

        local indexes = posIndexes[layer]
        if not indexes then
            indexes = {}
            posIndexes[layer] = indexes
        end
        local posX, posY = self:DecodePosNum(posNum)

        for x = 0, width - 1 do
            for y = 0, height - 1 do
                local usedPos = self:EncodePosNum(posX - x, posY - y)
                if not indexes[usedPos] then
                    indexes[usedPos] = posNum
                end
            end
        end
    end
    if not ins then
        Log.Error("未生成")
        return
    end
    ins.transform.localPosition = pos
end

function Map:delTileMapPos(ins, posNum, category)
    local info = tileCategories[category]
    if not info then
        return
    end
    ins.transform.localPosition = tileHidePos 
    --sly
    --GameObject.Destroy(ins)

    local posX, posY = self:DecodePosNum(posNum)
    if posX > 0 and posY > 0 then
        --清除当前建筑对象信息
        BuildingManager.ClearBuildInfo(ins, posNum)
        WorldMapModel.PoolDelMapUI(posNum)
    end
    if info.width > 1 or info.height > 1 then
        local indexes = posIndexes[info.layer]
        if not indexes then
            return
        end
        for x = 0, info.height - 1 do
            for y = 0, info.width - 1 do
                local usedPos = self:EncodePosNum((posX - x), posY - y)
                if indexes[usedPos] then
                    indexes[usedPos] = nil
                end
            end
        end
    end
end

function Map:ScreenPosToMap(screenPos)
    ray = self.camera:ScreenPointToRay(screenPos)
    local _, distance = plane:Raycast(ray)
    return ray:GetPoint(distance)
end

function Map:logicToMapPos(x, y)
    local pos = CVector3(x * UnitSideLen, 0, y * UnitSideLen)
    return pos
end

function Map:GetAllPoints()
    return self:getPoints(true)
end

-- public int[] GetAllPoints()
-- {
--     return getPoints(true).KToArray();
-- }

function Map:EncodePosNum(posX, posY)
    local point = abs(posX) * 10000 + abs(posY)
    if posX < 0 then
        point = point + 100000000
    end
    if posY < 0 then
        point = point + 200000000
    end

    return point
end

function Map:DecodePosNum(posNum)
    local symbol = floor(posNum / 100000000)
    local num = posNum % 100000000
    local posX = floor(num / 10000)
    local posY = num % 10000
    if symbol == 1 then
        posX = -1 * posX
    elseif symbol == 2 then
        posY = -1 * posY
    elseif symbol == 3 then
        posX = -1 * posX
        posY = -1 * posY
    end

    return posX, posY
end

local isBorderX = false
local isBorderY = false

function Map:AddMapBorder(posNum, posX, posY)
    if posX < minBorder or posX > maxBorder then
        return
    end
    if posY < minBorder or posY > maxBorder then
        return
    end

    isBorderX = (posX == minBorder or posX == maxBorder)
    isBorderY = (posY == minBorder or posY == maxBorder)
    if not isBorderX and not isBorderY then
        return
    end

    if not self.MapBorderListX then
        self.MapBorderListX = {}
    end
    if not self.MapBorderListY then
        self.MapBorderListY = {}
    end

    local delayX = 0
    local delayY = 0
    local isLoad = ObjectPoolManager.Instance:IsExistPool(self.MapBorderConfig.name)

    if isBorderX then
        if self.MapBorderListY[posY] then
            return
        end
        delayX = posX == minBorder and -0.5 or 0.5
        if isLoad then
            self:CreateMapBorder(posX + delayX, posY, true)
        else
            GameUtil.GetObjFromPool(
                PrefabType.WorldMap.Map_BorderLine,
                function()
                    self:CreateMapBorder(posX + delayX, posY, true)
                end
            )
        end
    end

    if isBorderY then
        if self.MapBorderListX[posX] then
            return
        end
        delayY = posY == minBorder and -0.5 or 0.5
        if isLoad then
            self:CreateMapBorder(posX, posY + delayY, false)
        else
            GameUtil.GetObjFromPool(
                PrefabType.WorldMap.Map_BorderLine,
                function()
                    self:CreateMapBorder(posX, posY + delayY, false)
                end
            )
        end
    end
end

function Map:CreateMapBorder(posX, posY, isLeft)
    if isLeft then
        if self.MapBorderListY[posY] then
            return
        end
    else
        if self.MapBorderListX[posX] then
            return
        end
    end
    local obj = ObjectPoolManager.Instance:Get(self.MapBorderConfig.name)
    obj.transform.parent = WorldMap.Instance().RouteLayer.transform
    obj.transform.localPosition = CVector3(posX, 0, posY)

    if isLeft then
        obj.transform.localEulerAngles = _borderVec3
        self.MapBorderListY[posY] = obj
    else
        obj.transform.localEulerAngles = CVector3.zero
        self.MapBorderListX[posX] = obj
    end
end

-- 如果有边界线就移除
function Map:RemoveMapBorder(posNum)
    --回收边界线
    local posX, posY = MathUtil.GetCoordinate(posNum)
    if posX == minBorder or posX == maxBorder then
        if self.MapBorderListX and self.MapBorderListX[posY] then
            _G.ObjectPoolManager.Instance:Release(self.MapBorderConfig.name, self.MapBorderListX[posY])
            --主动释放table
            self.MapBorderListX[posY] = nil
        end
    end
    if posY == minBorder or posY == maxBorder then
        if self.MapBorderListY and self.MapBorderListY[posX] then
            _G.ObjectPoolManager.Instance:Release(self.MapBorderConfig.name, self.MapBorderListY[posX])
            --主动释放table
            self.MapBorderListY[posX] = nil
        end
    end
end

return Map
