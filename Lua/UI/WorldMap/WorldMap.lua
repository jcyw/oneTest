--[[
    author:{zhanzhang}
    time:2019-06-28 13:44:25
    function:{外城地图}
]]
local WorldMap = {}
import("Model/WorldCityModel")
import("UI/WorldMap/ItemMapTown")

local ItemMoveBuild = import("GameLogic/ItemMoveBuild")
local ItemMapTownUI = import("UI/WorldMap/ItemMapTownUI")
local ItemMineUI = import("UI/WorldMap/ItemMineUI")
local ItemMonsterUI = import("UI/WorldMap/ItemMonsterUI")
local RelationEnum = import("Enum/RelationEnum")
local PinchGesture = CS.FairyGUI.PinchGesture
local MapEnum = import("Enum/MapEnum")
local MissionEventModel = import("Model/MissionEventModel")
local WorldMapModel = import("Model/WorldMapModel")
local DirectionEnum = import("Enum/DirectionEnum")
local MarchAnimModel = import("Model/MarchAnimModel")
local MarchLineModel = import("Model/MarchLineModel")
local Model = import("Model/Model")
local BuildingManager = import("UI/WorldMap/BuildingManager")
local MarchManagerModel = import("Model/MarchManagerModel")
local WelfareModel = import("Model/WelfareModel")
local UIType = _G.GD.GameEnum.UIType
local GlobalVars = GlobalVars

local ResMgr = _G.ResMgr
local CVector3 = _G.CVector3

local math_floor = math.floor
local math_ceil = math.ceil
local math_abs = math.abs

local Instance = nil

local MapUIView = nil
--地图UI缓存
local MapUICache = {}
--正在使用的地图UI
local MapUIUsed = {}
--打开地图首先跳转到目标位置
local gotoFunc
--打开地图后回调事件
local beforeCallbacks = {}
local after
-- local dicCategory = {}
--缓存的攻击行军id
local MapAttackCache = {}
local MapCachePoint = {}
local MarchLineCache = {}
--地图联盟标记
local MapAllianceMarkList = {}

local mapScreen
local screenHeight = Screen.height
local unitLen = 1
local extendRadius = 2
local posDiff
local cameraSize = 1

local SmoothTime = 0.5
local AnimationObj
local isFirstLoad = true
local delayPosX = 0
local delayPosY = 0
local isAnim = false
local beforeMapEvents = {}
local afterMapEvents = {}
local afterCloudEvent = {}
local touching = false
local isInMoveAnim = false
--是否等待下发地块请求（用于跳转刷新后注册事件的判定）
local isWaitReqMap = false
local tweenCaches = {}
mapOffset = 0
cameraScale = 0.6

--local lastRefreshAt = 0 -- 上次地图刷新时间
local refreshInterval = 0.7 -- 地图刷新间隔
local isStartRequest = false -- 是否是开始请求地图信息
local isRestartRequest = true
local lastRequestPosx = 0
local lastRequestPosY = 0
local loadedX = 0
local loadedY = 0
--地图边界
local borderRectList

local MapObjsCache = {}
local regGTweenListeners = {}
local RoyalPoint = {
    [5950595] = true,
    [5960595] = true,
    [5950596] = true,
    [5960596] = true,
    [6040595] = true,
    [6040596] = true,
    [6050595] = true,
    [6050596] = true,
    [5950604] = true,
    [5960604] = true,
    [5950605] = true,
    [5960605] = true,
    [6040604] = true,
    [6040605] = true,
    [6050604] = true,
    [6050605] = true,
    [5990599] = true,
    [5990600] = true,
    [5990601] = true,
    [6000599] = true,
    [6000600] = true,
    [6000601] = true,
    [6010599] = true,
    [6010600] = true,
    [6010601] = true
}
----------------------------------------------FairyGui注册事件--------------------------
local scaleGesture = function(context)
    if GlobalVars.IsInCity then
        return
    end
    local _gesture = context.sender
    if WorldMap.Instance().tween then
        WorldMap.Instance().tween:Kill()
    end
    local size = WorldMap.Instance().camera.orthographicSize - _gesture.delta * 3
    if size > 6 then
        size = 6
    elseif size < 2.5 then
        size = 2.5
    end

    WorldMap.Instance().camera.orthographicSize = size
    WorldMap.Instance().cameraSize = size
    WorldMap.Instance():CheckCamereMoveBorder()
end
local fingerGesture = function(data)
    if GlobalVars.IsInCity then
        return
    end
    local inputEvent = data.inputEvent
    if WorldMap.Instance().tween then
        GTween.Kill(WorldMap.Instance().tween)
    end
    local size = WorldMap.Instance().camera.orthographicSize + inputEvent.mouseWheelDelta * 0.1
    if size > 6 then
        size = 6
    elseif size < 2.5 then
        size = 2.5
    end

    WorldMap.Instance().camera.orthographicSize = size
    WorldMap.Instance().cameraSize = size
    WorldMap.Instance():CheckCamereMoveBorder()
end

local mapScreenClickFunc = function(context)
    if WorldMap.choosenMarchUnit then
        WorldMap.choosenMarchUnit = nil
        Event.Broadcast(EventDefines.UIOffAnim)
        return
    end
    local touchPosition = CVector3(context.inputEvent.x, Screen.height - context.inputEvent.y, 0)
    local worldPos = WorldMap.Instance().controller:ScreenToWorldPos(touchPosition)
    local pos = worldPos - WorldMap.Instance().transform.position
    WorldMap.Instance():OnClick(pos)
end

local mapScreenTouchBegin = function(context)
    if Stage.inst.touchCount > 1 then
        touching = false
        Event.Broadcast(EventDefines.UIOffAnim)
        return
    end
    touching = true
    context:CaptureTouch()
    local touchPosition = CVector3(context.inputEvent.x, screenHeight - context.inputEvent.y, 0)
    --beginPos = touchPosition
    local worldPos = WorldMap.Instance().controller:ScreenToWorldPos(touchPosition)
    posDiff = worldPos - WorldMap.Instance().transform.position

    WorldMap.Instance().movePosDiff = nil
    WorldMap.Instance().underInertia = false
    lastPos = worldPos
    if not WorldMap.choosenMarchUnit then
    end
end

local mapScreenTouchMove = function(context)
    if WorldMap.choosenMarchUnit then
        return
    end
    if not touching then
        return
    end

    local touchPosition = CVector3(context.inputEvent.x, screenHeight - context.inputEvent.y, 0)
    local worldPos = WorldMap.Instance().controller:ScreenToWorldPos(touchPosition)
    local pos = posDiff - worldPos
    if pos.x < mapOffset then
        pos.x = mapOffset
    end
    if pos.x > 1200 - mapOffset then
        pos.x = 1200 - mapOffset
    end
    if pos.z < mapOffset then
        pos.z = mapOffset
    end
    if pos.z > 1200 - mapOffset then
        pos.z = 1200 - mapOffset
    end
    WorldMap.Instance().controller:MoveToPos(pos)
    WorldMap.Instance().movePosDiff = lastPos - worldPos
    if not isAnim and (math_abs(WorldMap.Instance().movePosDiff.x) > 2 or math_abs(WorldMap.Instance().movePosDiff.z) > 2) then
        isAnim = true
        Event.Broadcast(EventDefines.UITriggerPanelAnim, false)
    end
    Event.Broadcast(EventDefines.UIOffAnim)
    lastPos = worldPos
end

local mapScreenTouchEnd = function(context)
    if not touching then
        if (isAnim) then
            Event.Broadcast(EventDefines.UITriggerPanelAnim, true)
            isAnim = false
        end
        if WorldMap.Instance().tween then
            WorldMap.Instance().tween:Kill()
        end
        WorldMap.Instance():CheckCamereMoveBorder()
        return
    end

    if WorldMap.choosenMarchUnit then
        WorldMap.choosenMarchUnit = nil
        Event.Broadcast(EventDefines.UIOffAnim)
        return
    end
    if WorldMap.Instance().movePosDiff then
        WorldMap.Instance().underInertia = true
        WorldMap.Instance().smoothTime = 0
    else
        if (isAnim) then
            Event.Broadcast(EventDefines.UITriggerPanelAnim, true)
            isAnim = false
        end
    end
end

local specialMapObjs = {}
local spyMonsterObjs = {}--key = activityid,valueList = key = item.id,value = obj  item.id 就是 posNum

--[[
地图层级管理：
第一层：基础地貌
第二层：插片地貌（树、山、水）
第三层：建筑（玩家城市、野矿、野外等等动态元素）
]]
-- controller 为世界地图的monobehaviour
local isInit = false

local tempTestList = {}
function WorldMap.InitMap(pos, screen)
    if isInit then
        return
    end
    isInit = true
    mapOffset = ConfigMgr.GetItem("ConfigMaps", Model.MapConfId).offset
    mapScreen = screen
    Instance = new(WorldMap)
    WorldMap.mapObj = CSWorldMap.Create(unitLen, extendRadius, mapOffset, Instance)
    WorldMap.mapObj.transform:SetParent(KSGame.Instance.gameObject.transform)
    CSCoroutine.Start(
        function()
            local list = {
                -- "uiatlas/building",
                --"uiatlas/tilemap",
                "uiatlas/worldmapui"
            }
            for i = 1, #list do
                coroutine.yield(ResMgr.Instance:LoadSpriteAtlas(list[i]))
            end
            --coroutine.yield(DynamicRes.GetBundle("worldmap_atlas",function()end))
            ObjectUtil.SetActive(WorldMap.mapObj, true)
            coroutine.yield(ResMgr.Instance:LoadPrefab("prefabs/plotchunk"))
            WorldMapModel.PreloadMapResSync()
        end
    )
end
function WorldMap.InitScreen(screen)
    mapScreen = screen
end

function WorldMap.Dispose()
    ObjectUtil.Destroy(WorldMap.mapObj)
    Net.MapInfos.LeaveMap()
    MarchAnimModel.DelAll()
    if WorldMap.gesture then
        WorldMap.gesture.onAction:Remove(scaleGesture)
        WorldMap.gesture:Dispose()
    end
    for i = 0, #tweenCaches do
        if tweenCaches[i] then
            tweenCaches[i]:Kill()
        end
    end

    local ins = WorldMap.Instance()
    if ins then
        ins:DisposeRegister()
    end
    Stage.inst.onMouseWheel:Remove(fingerGesture)
    if not mapScreen then
        return
    end
    mapScreen.onClick:Remove(mapScreenClickFunc)
    mapScreen.onTouchBegin:Remove(mapScreenTouchBegin)
    mapScreen.onTouchMove:Remove(mapScreenTouchMove)
    mapScreen.onTouchEnd:Remove(mapScreenTouchEnd)
end

function WorldMap:OnOpen()
end

-- 回调：注册地图对象类型
function WorldMap:OnRegister(controller)
    Instance.controller = controller
    Event.Broadcast(EventDefines.UIWorldMapInitFinish)

    local conf = ConfigMgr.GetList("configMaptiles")
    local Categories = {}
    for _, v in pairs(conf) do
        local cate = {
            category = v.id,
            layer = v.layer,
            source = v.path,
            width = v.width,
            height = v.height,
            radius = v.whole
        }
        Categories[#Categories + 1] = cate
    end

    self:OnSetUp()
    return Categories
end

function WorldMap:OnSetUp()
    self.requestAdd = {}
    self.requestDel = {}
    self.changePoints = {}
    self.camera = self.controller.camera
    self.transform = self.controller.transform
    self.posX = -1
    self.posY = -1
    self.forwardVec3 = self.camera.transform.forward
    self.moveCityNewPosNum = 0
    self.cameraPos = CVector3(20, 23.73, 20)
    self.cameraSize = 4
    self.pos = self.cameraPos
    self.cameraMaxPos = self.cameraPos + 14 * self.forwardVec3
    self.cameraMinPos = self.cameraPos - 12 * self.forwardVec3
    self:OnRegisterEvent()

    self:OnRegisterMoveBuild()
    self.RouteLayer = self.controller:GetMapLayer(3)
    MarchAnimModel.SetMarchRoot(self.RouteLayer)
    MarchLineModel.SetMarchRoot(self.RouteLayer)
    --创建地图UI层
    self.UILayer = self.controller:GetMapLayer(4)
    self.WorldMapUI = self.UILayer.transform:Find("WorldMapCanvas").transform
    self.NodeMix = self.WorldMapUI:Find("nodeMix").transform
    self.NodeSprite = self.WorldMapUI:Find("nodeSprite").transform
    self.NodeText = self.WorldMapUI:Find("nodeText").transform
    self.NodeWhite = self.WorldMapUI:Find("nodeTextWhite").transform
    self.NodeTextYellow = self.WorldMapUI:Find("nodeTextYellow").transform
    self.UILayer = self.UILayer:GetComponentInChildren(typeof(UIPanel))

    ------------
    --测试代码
    -- local prefab = ResMgr.Instance:GetPrefab("prefabs/worldmapui/worldmapcanvas")
    -- self.WorldMapCanvas = ObjectUtil.AttachChild(self.RouteLayer, prefab)
    ----------------
    self.UILayer.packageName = "Build"
    self.UILayer.componentName = "itemBuild"
    self.UILayer:CreateUI()
    self.UILayer.ui.fairyBatching = true
    self:InitPool(self.UILayer.ui.displayObject.cachedTransform)

    self.waitingRequest = function(isFocusRefresh)
        loadedX = self.requestMatrix.centerX
        loadedY = self.requestMatrix.centerY
        lastRequestPosx = self.requestMatrix.centerX
        lastRequestPosY = self.requestMatrix.centerY
        --print("MatrixInfo self.requestMatrix.centerX ===" .. self.requestMatrix.centerX.."   " ..self.requestMatrix.centerY.."   " ..os.clock())
        Net.MapInfos.MatrixInfo(
        -- Net.MapInfos.PointInfos(
                UserModel.SceneId(),
                Model.Account.accountId,
                self.requestMatrix.centerX,
                self.requestMatrix.centerY,
                self.requestMatrix.widthRadius,
                self.requestMatrix.heightRadius,
                isFocusRefresh,
                function(rsp)
                    --print("MatrixInfo rsp ===" .. table.inspect(rsp))
                    --lastRefreshAt = Time.fixedTime
                    --MapModel.ClearPoints(requestDel)
                    self:RefreshMap(rsp)
                    if isFirstLoad then
                        Event.Broadcast(EventDefines.UIWorldCityQueueFinish)
                    end
                    Event.Broadcast(EventDefines.UIMapLoadingFinish)
                    isFirstLoad = false
                    isWaitReqMap = false
                    -- print(dump(rsp))
                    for _, callback in ipairs(afterMapEvents) do
                        callback()
                    end
                    afterMapEvents = {}
                    self:RefreshMapObjects(rsp)
                    if(lastRequestPosx ~= self.requestMatrix.centerX or lastRequestPosY ~= self.requestMatrix.centerY)then
                        Scheduler.ScheduleOnceFast(self.waitingRequestHandle, refreshInterval)
                    else
                        -- 如果是开始移动的请求返回 等待一段时间后在申请地图数据（在一次刷新周期完成了网络请求的特殊处理）
                        if(isStartRequest)then
                            Scheduler.ScheduleOnceFast(self.waitingRequestHandle, refreshInterval)
                        else
                            isRestartRequest = true
                            -- 快速拖回回填被清除的地块
                            local currentLogicPoints = self.controller:getPoints(false)
                            local remainPoints = {}
                            for pos, _ in pairs(currentLogicPoints) do
                                if not MapModel.GetReponseAddTile()[pos] then
                                    remainPoints[pos] = true
                                end
                            end
                            self:RefreshMapRemainObjects(remainPoints)
                        end
                    end
                end
        )
    end

    self.waitingRequestHandle = function()
        isStartRequest = false
        --print("22222222 matrix.centerX = "..self.requestMatrix.centerX .. "   matrix.centerY = "..self.requestMatrix.centerY .. "   os.clock() = "..os.clock())
        self.waitingRequest(false)
    end

    self:mapTouchEvent()

    self.cameraPos = CVector3(29.5, 24, 29.5)
    self.pos = self.cameraPos
    -------废弃 40度标准
    --最小 14  16.6 14
    --最大 25.5 , 30.24  ,25.5
    --常态 20,23.73,20
    ------------

    --常态 4
    --最大 3
    --最小5.5  操作轮 0.7
    self:CreateScaleGesture()
    self:InitAllianceMark()
    self:OnRegisterFingerGesture()
    self:CreateRoyalBorder()
    self:CreateMapBorder()
    Event.AddListener(
        EventDefines.UIEnterCityScale,
        function(value)
            if self.tween1 then
                self.tween1:Kill()
                self.tween1 = nil
            end
            self.tween1 = GTween.ToDouble(self.cameraSize, self.cameraSize * 0.7, 1)
            self:GtweenOnComplete(
                self.tween1,
                function()
                    self.cameraSize = 4
                    self.camera.orthographicSize = self.cameraSize
                end
            )

            self:GtweenOnUpdate(
                self.tween1,
                function()
                    self.camera.orthographicSize = self.tween1.value.d
                    self.cameraSize = self.camera.orthographicSize
                end
            )
        end
    )

    Event.AddListener(
        EventDefines.FalconGetTech,
        function(value)
            if GlobalVars.IsInCity then
                return
            end

            if  not self.controller:getTileData(value.X,value.Y) then
                return
            end
            local TechId = value.TechId
            DynamicRes.GetBundle(
                    "effect_ab/effect_collect_map",
                    function()
                        DynamicRes.GetPrefab(
                            "effect_ab/effect_collect_map",
                            "effect_collect_map_perfab",
                            function(prefab)
                                local boomObj = GameObject.Instantiate(prefab)
                                boomObj.transform.parent = WorldMap.Instance().RouteLayer.transform
                                boomObj.transform.localPosition = CVector3(value.X, 0, value.Y)
                                Scheduler.ScheduleOnce(
                                    function()
                                        ObjectUtil.Destroy(boomObj)
                                    end,
                                    3
                                )
                            end
                        )
                    end
            )
            local screenX, screenY = MathUtil.ScreenRatio(self:LogicToScreenPos(value.X, value.Y))
            Event.Broadcast(EventDefines.FlyFalconGetTech,screenX,screenY,TechId)
        end
    )
end

function WorldMap:mapTouchEvent()
    local beginPos
    posDiff = 0
    local lastPos
    mapScreen.onClick:Add(mapScreenClickFunc)
    mapScreen.onTouchBegin:Add(mapScreenTouchBegin)
    mapScreen.onTouchMove:Add(mapScreenTouchMove)
    mapScreen.onTouchEnd:Add(mapScreenTouchEnd)
end

-- 回调: 刷新地图
function WorldMap:OnRefresh(matrix)
    Event.Broadcast(EventDefines.UIOnWorldMapChange, matrix.centerX, matrix.centerY)
    self.posX = matrix.centerX
    self.posY = matrix.centerY
    delayPosX = self.posX
    delayPosY = self.posY
    self.requestMatrix = matrix
    if (isRestartRequest) then
        isRestartRequest = false
        isStartRequest = true
        self.waitingRequest(false)
    end
end

function WorldMap:RefreshMap(rsp)
    MapModel.RefreshMap(rsp)
end

function WorldMap:RefreshAllianceLand(left, right, up, down, eLeft, eRight, eUp, eDown)
    self.controller:ClearAllianceLandLine()
    self.controller:ShowAllianceLand(left, "D", false)
    self.controller:ShowAllianceLand(right, "T", false)
    self.controller:ShowAllianceLand(up, "R", false)
    self.controller:ShowAllianceLand(down, "L", false)
    self.controller:ShowAllianceLand(eLeft, "D", true)
    self.controller:ShowAllianceLand(eRight, "T", true)
    self.controller:ShowAllianceLand(eUp, "R", true)
    self.controller:ShowAllianceLand(eDown, "L", true)
end

-------------------------------刷新地块建筑--------------------------------
local function doRefreshMapTypeBlank(self, item)
    --如果此处有特殊建筑不予修改
    if specialMapObjs[item.Id] then
        return
    end

    if MapCachePoint[item.Id] then
        Log.Debug("此处为战斗动画缓存对象，待战斗结束释放")
    else
        --空地
        if item.Id ~= self.moveCityOldPosNum then
            self.controller:DelChild(item.Id, 0)
        end
        WorldMapModel.PoolDelMapUI(item.Id)
    end
end

local function doRefreshMapTown(self, item)
    --基地建筑
    if item.Id ~= item.Occupied then
        return
    end
    --------临时处理迁城时，删除本地野怪---------
    if MapCachePoint[item.Id] then
        MapCachePoint[item.Id] = nil
        self.controller:DelChild(item.Id, 0)
        WorldMapModel.PoolDelMapUI(item.Id)
    end
    --在迁城中暂停创建
    if self.moveCityNewPosNum == item.Id then
        return
    end
    local obj = self.controller:AddChild(item.Id, 1000)
    if not obj then
        return
    end
    obj:SetActive(false)
    local building = WorldMapModel.PoolGetMapUI(item.Id, item.Category)
    ---- self:RefreshUIPos(building, obj)
    BuildingManager.RefreshMapTown(obj, item.Id)
    obj:SetActive(true)
    if building then
        building:Refresh(item.Id, obj.transform.position)
    end
end

local function doRefreshMapMine(self, item)
    --野矿
    local conf = ConfigMgr.GetItem("configMines", item.ConfId)
    local obj = self.controller:AddChild(item.Id, conf.mine_model)
    if not obj then
        return
    end
    local building = WorldMapModel.PoolGetMapUI(item.Id, item.Category)
    self:RefreshBuildingTile(item.Id, obj)
    if building then
        building:Refresh(item.Id, obj.transform.position)
    end
end

local function doRefreshMapMonster(self, item)
    --野怪
    local conf = ConfigMgr.GetItem("configMonsters", item.ConfId)
    if item.Occupied == 0 or item.Id == item.Occupied then
        -- 测试代码  地块重复刷怪
        -- if (tempTestList[item.Id]) then
        --     Log.Error("doRefreshMapMonster had exist : {0}  item.ConfId = {1}", item.Id, tempTestList[item.Id])
        --     return
        -- end
        local obj = self.controller:AddChild(item.Id, conf.monster_model)
        if not obj then
            return
        end
        -- tempTestList[item.Id] = item.ConfId
        if conf.monster_model < 2100 then
            local animId = 1
            if conf.level > 0 then
                animId = math_ceil(conf.level / 3)
            end
            MarchAnimModel.RefreshMonsterPos(item.Id, obj, animId)
            MarchAnimModel.PlayMonsterAnim(item.Id, "T" .. animId .. "_idle", true)
        elseif conf.type == 2 or conf.type == 3 then
            self:RefreshBuildingTile(item.Id, obj)
        elseif conf.type == 11 then
            local isCan = MapModel.IsCanScoutMonster(item.Id, conf.activity_id)
            local scoutTip = obj.transform:Find("spyed")
            scoutTip.gameObject:SetActive(not isCan)
            if not spyMonsterObjs[conf.activity_id] then --侦察怪GO装表，用来刷新
                spyMonsterObjs[conf.activity_id] = {}
            end
            spyMonsterObjs[conf.activity_id][item.Id] = obj
        end

        local building = WorldMapModel.PoolGetMapUI(item.Id, item.Category)
        if building then
            building:Refresh(item.Id, obj.transform.position)
        end
    end
end

local function doRefreshMapAllianceHospital(self, item)
    self.controller:AddChild(item.Id, 3081)
end

local function doRefreshMapFort(self, item)
    --炮台
    if item.Id ~= item.Occupied then
        return
    end
    local itemFort = BuildingManager.RefreshMapFort(item.Id)
    local building = WorldMapModel.PoolGetMapUI(item.Id, item.Category)
    local pos = self.RouteLayer.transform.position + CVector3(itemFort.posX, 0, itemFort.posY)
    building:Refresh(pos, item)
end
local function doRefreshMapSecretBase(self, item)
    --秘密基地
    if item.Id ~= item.Occupied then
        return
    end
    local obj = self.controller:AddChild(item.Id, 4001)
end
--联盟矿
local function doRefreshMapAllianceMine(self, item)
    if item.Id ~= item.Occupied then
        return
    end
    self.controller:AddChild(item.Id, 3101)
end
local function doRefreshMapThrone(self, item)
    if item.Id ~= item.Occupied then
        return
    end
    --王座
    BuildingManager.RefreshMapThrone()
    local building = WorldMapModel.PoolGetMapUI(item.Id, item.Category)
    building:Refresh(self.RouteLayer.transform.position, item)
end

local function doRefreshMapAllianceStore(self, item)
    if item.Id ~= item.Occupied then
        return
    end
    --联盟仓库
    local obj = self.controller:AddChild(item.Id, 3021)
    if not obj then
        return
    end
    local building = WorldMapModel.PoolGetMapUI(item.Id, item.Category)
    if building then
        building:Refresh(item.Id, obj.transform.position)
    end
    local BlackTileRender = obj.transform:Find("BlackTile"):GetComponent("SpriteRenderer")
    local CommonTileRender = obj.transform:Find("CommonTile"):GetComponent("SpriteRenderer")
    local posX, posY = MathUtil.GetCoordinate(item.Id)
    if MapModel.IsInBlackZone(posX, posY) then
        BlackTileRender.enabled = true
        CommonTileRender.enabled = false
    else
        BlackTileRender.enabled = false
        CommonTileRender.enabled = true
    end
end

local function doRefreshMapAllianceDomain(self, item)
    if item.Id ~= item.Occupied then
        return
    end
    --联盟据点
    local obj = self.controller:AddChild(item.Id, 3001)
    if not obj then
        return
    end
    local building = WorldMapModel.PoolGetMapUI(item.Id, item.Category)
    if building then
        building:Refresh(item.Id, obj.transform.position)
    end
    local BlackTileRender = obj.transform:Find("BlackTile"):GetComponent("SpriteRenderer")
    local CommonTileRender = obj.transform:Find("CommonTile"):GetComponent("SpriteRenderer")
    local posX, posY = MathUtil.GetCoordinate(item.Id)
    if MapModel.IsInBlackZone(posX, posY) then
        BlackTileRender.enabled = true
        CommonTileRender.enabled = false
    else
        BlackTileRender.enabled = false
        CommonTileRender.enabled = true
    end
end
--刷新扎营
local function doRefreshMapCamp(self, item)
    local obj = self.controller:AddChild(item.Id, 2501)
    if not obj then
        return
    end
    self:RefreshBuildingTile(item.Id, obj)
end
--刷新猎鹰活动野怪
local function doRefreshMapFalcon(self, item)
    local obj = self.controller:AddChild(item.Id, 2501)
    if not obj then
        return
    end
end

local RefreshMapObjList = {
    [Global.MapTypeTown] = doRefreshMapTown,
    [Global.MapTypeMine] = doRefreshMapMine,
    [Global.MapTypeBlank] = doRefreshMapTypeBlank,
    [Global.MapTypeMonster] = doRefreshMapMonster,
    [Global.MapTypeAllianceStore] = doRefreshMapAllianceStore,
    -- [Global.MapTypeAllianceDefenceTower]
    -- [Global.MapTypeAllianceHospital = doRefreshMapAllianceHospital,
    [Global.MapTypeAllianceDomain] = doRefreshMapAllianceDomain,
    [Global.MapTypeAllianceMine] = doRefreshMapAllianceMine,
    [Global.MapTypeFort] = doRefreshMapFort,
    [Global.MapTypeThrone] = doRefreshMapThrone,
    [Global.MapTypeSecretBase] = doRefreshMapSecretBase,
    [Global.MapTypeCamp] = doRefreshMapCamp
}

---------------------------------------------------------------------------------
--刷新建筑
function WorldMap:RefreshMapRemainObjects(nowPoint)
    if GlobalVars.IsInCity then
        self.mapChanged = true
        return
    end
    --补充缓存信息但是对象被回收地块
    for _, point in pairs(nowPoint or {}) do
        local area = MapModel.GetArea(_)
        if area and RefreshMapObjList[area.Category] then
            MapObjsCache[area.Id] = true
            RefreshMapObjList[area.Category](self, area)
        end
    end
end

--刷新建筑
function WorldMap:RefreshMapObjects(rsp)
    if GlobalVars.IsInCity then
        self.mapChanged = true
        return
    end
    for _, item in pairs(rsp.MapRecs) do
        local posX, posY = MathUtil.GetCoordinate(item.Id)
        if not MapModel.IsOutBorder(posX, posY) then
            if RefreshMapObjList[item.Category] then
                MapObjsCache[item.Id] = true
                RefreshMapObjList[item.Category](self, item)
            end
        end
    end
    for _, point in pairs(rsp.EmptyIds) do
        local posX, posY = MathUtil.GetCoordinate(point)
        local item = MapModel.GetArea(point)
        if not MapModel.IsOutBorder(posX, posY) then
            MapObjsCache[3] = true
            RefreshMapObjList[3](self, item)
        end
    end

    self:CheckFalconActivity()

    if #rsp.MarchLines == 0 then
        return
    end
    --刷新行军路线
    Event.Broadcast(EventDefines.UIOnRefreshMarchLine, rsp.MarchLines)
end
--检测猎鹰行动
function WorldMap:CheckFalconActivity()
    if not Model.MonsterVisitInfo or not Model.MonsterVisitInfo[WelfareModel.WelfarePageType.FALCON_ACTIVITY] then
        return
    end
    local list = Model.MonsterVisitInfo[WelfareModel.WelfarePageType.FALCON_ACTIVITY]
    for k, _ in pairs(specialMapObjs) do
        local area = MapModel.GetArea(k)
        if area and not area.IsFalcon then
            self.controller:DelChild(k)
            specialMapObjs[k] = nil
        end
    end
    local addList = {}
    for k, v in pairs(list.Avaliable) do
        local posNum = MathUtil.GetPosNum(v.X, v.Y)
        local area = MapModel.GetArea(posNum)
        if not v.Banned then
            if not area or area.Category == Global.MapTypeBlank then
                local areaInfo = {
                    AllianceId = area and area.AllianceId or "",
                    Category = Global.MapTypeMonster,
                    ConfId = v.ConfId,
                    DeadTime = 0,
                    FortressId = area and area.FortressId or 0,
                    FortressIdList = "",
                    Id = posNum,
                    Occupied = 0,
                    ServerId = Model.Player.Server,
                    IsFalcon = true
                }
                MapModel.AddMapInfo(posNum, areaInfo)
                self:CreateOtherMapObj(areaInfo, v.ConfId)
            end
            addList[posNum] = true
        end
    end
    for k, _ in pairs(specialMapObjs) do
        local area = MapModel.GetArea(k)
        if area and not addList[k] and area.IsFalcon then
            self.controller:DelChild(k)
            specialMapObjs[k] = nil
            MapModel.DelPoint(k)
        end
    end
end
--刷新侦察怪显示
function WorldMap:RefreshSpyMondters(oldSpyedPosList)
    for k, v in pairs(oldSpyedPosList) do
        local area = MapModel.GetArea(v)
        if area and RefreshMapObjList[area.Category] then
            MapObjsCache[area.Id] = true
            RefreshMapObjList[area.Category](self, area)
        end
    end
end
--全局设置中选择先选城市还是先选行军线
function WorldMap:OnClick(mapPos, isGuide, isFromMoveToPoint)
    if GlobalVars.IsInCity then
        return
    end
    --在迁城动画过程中不允许点击地图
    if isInMoveAnim then
        return
    end
    --弱引导
    if isGuide then
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.WorldMapUI)
    else
        Event.Broadcast(EventDefines.CloseGuide, true)
    end

    local logicPos = self.controller:MapToLogicPos(mapPos)
    local chunkInfo, elementType = MapModel.GetArea(logicPos)

    local isFirstSelect = true
    local selectSetting = PlayerDataModel:GetData("SyetemSet" .. 30003)

    if selectSetting then
        isFirstSelect = selectSetting.btnSelected
    end

    if isFirstSelect and chunkInfo and chunkInfo.Category == Global.MapTypeTown then
        self:ChooseLogicPos(logicPos, isGuide, isFromMoveToPoint)
        return
    end
    if RoyalPoint[logicPos] then
        self:ChooseLogicPos(logicPos, isGuide, isFromMoveToPoint)
        return
    end

    if self:CheckIsClickMarch(mapPos) then
        return
    end
    self:ChooseLogicPos(logicPos, isGuide, isFromMoveToPoint)
end

function WorldMap:CheckIsClickMarch(mapPos)
    local marchInfos = MarchAnimModel.GetMarchInfoList()
    local isClickMarch = true
    for i, v in pairs(marchInfos or {}) do
        local pos = v.unit.transform.localPosition
        local distance = MathUtil.GetDistance(mapPos.x - pos.x, mapPos.z - pos.z)
        --magic number 后续修改
        if distance < 1 then
            if v.data.OwnerId ~= Model.Account.accountId then
                isClickMarch = true
            else
                isClickMarch = false
                local marchInfo = MissionEventModel.GetEvent(v.data.Uuid)
                if marchInfo and marchInfo.Status == Global.MissionStatusMarch then
                    isClickMarch = true
                end
            end

            if isClickMarch then
                self:ClickMarchUnit(i)
            end
            return true
        end
    end
    return false
end

function WorldMap:ChooseLogicPos(logicPos, isGude, isFromMoveToPoint)
    local clickPos = MapModel.GetTargetPos(logicPos)
    local chunkInfo, elementType = MapModel.GetArea(logicPos)

    local detailPos = {}
    local posX, posY = MathUtil.GetCoordinate(logicPos)
    local screenX, screenY = MathUtil.ScreenRatio(self:LogicToScreenPos(posX, posY))

    if chunkInfo and chunkInfo.Occupied ~= 0 then
        posX, posY = MathUtil.GetCoordinate(chunkInfo.Occupied)
        -- if chunkInfo.Category == Global.MapTypeThrone then
        --     screenX, screenY = MathUtil.ScreenRatio(self:LogicToScreenPos(posX + 1, posY + 1))
        -- else
        screenX, screenY = MathUtil.ScreenRatio(self:LogicToScreenPos(posX - 0.5, posY - 0.5))
    -- end
    end
    local params = {posNum = logicPos, screenPos = {x = screenX, y = screenY}}
    Event.Broadcast(EventDefines.UIClickWorldMap, params, isGude, isFromMoveToPoint)
end
local lastTouchPos
local isTouch
function WorldMap:OnUpdate()
    --待优化
    if self.underInertia then
        local pos = self.movePosDiff / 2 - self.transform.position
        if pos.x < mapOffset then
            pos.x = mapOffset
        end
        if pos.x > 1200 - mapOffset then
            pos.x = 1200 - mapOffset
        end
        if pos.z < mapOffset then
            pos.z = mapOffset
        end
        if pos.z > 1200 - mapOffset then
            pos.z = 1200 - mapOffset
        end
        if self.smoothTime <= SmoothTime then
            self.controller:MoveToPos(pos)
            self.movePosDiff = CVector3.Lerp(self.movePosDiff, CVector3.zero, self.smoothTime)
            self.smoothTime = self.smoothTime + Time.smoothDeltaTime
        else
            self.controller:MoveToPos(pos)
            self.underInertia = false
            self.smoothTime = 0
            if (isAnim) then
                Event.Broadcast(EventDefines.UITriggerPanelAnim, true)
                isAnim = false
            end
        end
    end
end

function WorldMap:GotoClickMarchUnit(data)
    local marchInfo = MarchManagerModel.GetMarchLine(data.Uuid)
    local isExistAnim  = MarchAnimModel.GetMarchInfo(data.Uuid)

    if isExistAnim and isExistAnim.isEnterAttackState then
        self:ClickMarchUnit(data.Uuid)
        return
    end
    
    if not marchInfo or not isExistAnim then
        self:CreateRoute(data)
    end
    self:ClickMarchUnit(data.Uuid)
end

function WorldMap:ClickMarchUnit(id)
    Scheduler.UnScheduleFast(WorldMap.ClickMarchHandle)
    WorldMap.choosenMarchUnit = id
    local detailPos = self.camera:WorldToScreenPoint(CVector3.zero)
    local marchInfo = MarchAnimModel.GetMarchInfo(id)

    if not marchInfo then
        return
    end

    local interval = 0.02

    local transform = marchInfo.unit.transform
    -- WorldMap.Instance():GotoPoint(transform.localPosition.x, transform.localPosition.z)
    WorldMap.ClickMarchHandle = function()
        -- local transform = marchInfo.unit.transform
        if WorldMap.choosenMarchUnit == id then
            local pos = transform.localPosition
            local x, y = self.controller:MapToLogicPoint(pos)
            if x < 0 or y < 0 or x > 1200 or y > 1200 then
                Event.Broadcast(EventDefines.UIOffAnim)
                Scheduler.UnScheduleFast(WorldMap.ClickMarchHandle)
            else
                self.controller:MoveToPos(pos)
            end
        else
            Scheduler.UnScheduleFast(WorldMap.ClickMarchHandle)
        end
    end
    Scheduler.ScheduleFast(WorldMap.ClickMarchHandle, interval)
    marchInfo.unitHandle = WorldMap.ClickMarchHandle

    Event.Broadcast(EventDefines.UIClickMarchUnit, marchInfo)
end

function WorldMap:OnMapMove(delayX, delayY)
    if delayPosX == 0 then
        delayPosX = self.posX
    end
    if delayPosY == 0 then
        delayPosY = self.posY
    end

    delayPosX = delayPosX + delayX
    delayPosY = delayPosY + delayY
    if not self.movePosDiff then
        self.movePosDiff = CVector3(delayX, 0, delayY)
    else
        self.movePosDiff.x = delayX
        self.movePosDiff.z = delayY
    end
    self.smoothTime = 1
    self.underInertia = true

    -- self.movePosDiff
    -- self.underInertia then
    --     local pos = self.movePosDiff - self.transform.position
    -- self.controller:MoveToPos(CVector3(delayPosX, 0, delayPosY))
end

--生成行军路线
function WorldMap:CreateRoute(data)
    if(not data)then
        return
    end
    MarchAnimModel.CreateRoute(data)
    MarchLineModel.CreateLine(data)

    if data.Uuid == self.lastChoosenMarchUnit then
        self:ClickMarchUnit(data.Uuid)
    end
end

function WorldMap:ReturnToMyBase()
    local myBasePosX, myBasePosY = MapModel.GetMyTownPos()
    if self.posx ~= myBasePosX or self.posY ~= myBasePosY then
        self.controller:GotoPoint(myBasePosX, myBasePosY)
    end
end

function WorldMap:GotoPoint(pointX, pointY)
    Event.Broadcast(EventDefines.UIOnWorldMapMove)
    if (Instance) then
        local posX = math_floor(tonumber(pointX))
        local posY = math_floor(tonumber(pointY))
        if self.posX == posX or self.posY == posY then
            self:ForceRefresh()
        end
        self.controller:GotoPoint(posX, posY)

        self.posX = posX
        self.posY = posY
    end
end
--目标坐标，
--isFromCity 是否从内城跳转
--isGuideShortRange 是否使用指引的近距离
--isGuide是弱引导
--isRes为弱引导判断是否为资源或者野怪
function WorldMap:MoveToPoint(posX, posY, isFromCity, isGuideShortRange, isGuide, isRes)
    self.isRes = isRes
    Event.Broadcast(EventDefines.UIOnWorldMapMove)
    if (Instance) then
        local startX, startY
        if isFromCity then
            startX = Model.Player.X
            startY = Model.Player.Y
        else
            startX = self.posX
            startY = self.posY
        end

        local JumpComplete = function()
            self.tween = GTween.ToDouble(self:GetAndResetCamereSize(), 3, 0.4)
            self:GtweenOnComplete(
                self.tween,
                function()
                    if isGuide then
                        self:SetWorldTurnPos(posX, posY)
                        Scheduler.ScheduleOnceFast(
                            function()
                                self:OnClick(CVector3(posX, 0, posY), isGuide, true)
                            end,
                            0.7
                        )
                    else
                        self:OnClick(CVector3(posX, 0, posY), nil, true)
                    end
                end
            )
            self:GtweenOnUpdate(
                self.tween,
                function()
                    if (self.tween.value.d >= 6) then
                        self.camera.orthographicSize = 6
                        self.cameraSize = self.camera.orthographicSize
                    else
                        self.camera.orthographicSize = self.tween.value.d
                        self.cameraSize = self.camera.orthographicSize
                    end
                end
            )
        end
        local distance = MathUtil.GetDistance(posX - startX, posY - startY)
        --超过配置距离直接跳转，不需要位移
        if distance > Global.MapGuideMaxDistance then
            WorldMap.AddEventAfterMap(
                function()
                    if isGuideShortRange then
                        JumpComplete()
                    else
                        self:OnClick(CVector3(posX, 0, posY))
                    end
                end
            )
            self.controller:GotoPoint(math_floor(tonumber(posX)), math_floor(tonumber(posY)))
        elseif startX == posX and startY == posY then
            if isGuideShortRange then
                JumpComplete()
            else
                self:OnClick(CVector3(posX, 0, posY))
            end
        else
            local moveFunc = function()
                self.moveTween = GTween.To(CVector3(startX, 0, startY), CVector3(posX, 0, posY), distance / Global.MapGuideMaxDistance)
                self:GtweenOnComplete(
                    self.moveTween,
                    function()
                        WorldMap.AddEventAfterMap(
                            function()
                                if isGuideShortRange then
                                    JumpComplete()
                                else
                                    self:OnClick(CVector3(posX, 0, posY))
                                end
                            end,
                            posX,
                            posY
                        )
                    end
                )
                self:GtweenOnUpdate(
                    self.moveTween,
                    function()
                        self.controller:MoveToPos(self.moveTween.value.vec3)
                    end
                )
            end
            self.controller:GotoPoint(math_floor(tonumber(startX)), math_floor(tonumber(startY)))
            if isFromCity then
                WorldMap.AddEventAfterMap(
                    function()
                        Scheduler.ScheduleOnce(
                            function()
                                moveFunc()
                            end,
                            1
                        )
                    end,
                    startX,
                    startY,
                    false
                )
            else
                moveFunc()
            end
        end
    end
end

function WorldMap.Instance()
    return Instance
end

--在加载地图前执行的回调
function WorldMap.AddEventBeforeMap(cb)
    if not beforeMapEvents then
        beforeMapEvents = {}
    end

    if Instance and Instance.controller then
        cb()
        return
    end
    table.insert(beforeMapEvents, cb)
end
--在加载地图后执行的回调
function WorldMap.AddEventAfterMap(cb, posX, posY, isFocusWait)
    if posX == loadedX and posY == loadedY and not isFocusWait then
        cb()
        return
    end
    table.insert(afterMapEvents, cb)
end
function WorldMap.AddEventAfterCloud(cb)
    table.insert(afterCloudEvent, cb)
end

function WorldMap:AddChunkUsed(posNum, obj)
    if (not MapUIUsed[posNum]) then
        MapUIUsed[posNum] = {}
    end
    table.insert(MapUIUsed[posNum], obj)
end

function WorldMap:OnMapInit()
    Event.Broadcast(EventDefines.UIWorldMapInitFinish)
    for _, callback in ipairs(beforeMapEvents) do
        callback()
    end
    beforeMapEvents = {}
end

function WorldMap:OnDelChunk(posNum, oldCategory)
    self.controller:DelChild(posNum, oldCategory)
end

function WorldMap:ScreenToLogicPos(x, y)
    y = Screen.height - y
    local logicId = self.controller:ScreenToLogicPos(CVector3(x, y, 0))
    local posX, posY = math_floor(logicId / 10000), math_floor(logicId % 10000)
    return posX, posY
end

function WorldMap:ScreenToLogicPoint(x, y)
    y = Screen.height - y
    return self.controller:ScreenToLogicPoint(CVector3(x, y, 0))
end

function WorldMap:LogicToScreenPos(posX, posY)
    local worldPos = CVector3(posX, 0, posY) + self.transform.position
    local screenPos = self.camera:WorldToScreenPoint(worldPos)
    return screenPos.x, Screen.height - screenPos.y
end
--检测该地块是否为地形
function WorldMap:IsMapTerrain(posNum)
    return self.controller:IsMapTerrain(posNum)
end

---------- 地图UI对象池-----------------------------------------------
function WorldMap:InitPool(panel)
    self.MapObjPool = {}
    self.UIUrl = {}
    self.MapUIList = {}
end
-- --从池中获取对应UI
-- function WorldMap:PoolGetMapUI(posNum, category)
--     local info
--     if self.MapUIList[posNum] then
--         info = self.MapUIList[posNum]
--         if info.category == category then
--             return info.mapUI
--         else
--             WorldMapModel.PoolDelMapUI(posNum)
--         end
--     end
--     info = {}
--     local newUI = WorldMapModel.MapBuildUIGet(category)
--     info.category = category
--     info.mapUI = newUI
--     self.MapUIList[posNum] = info

--     return newUI
-- end
-- --回收对应地块的UI
-- function WorldMap:PoolDelMapUI(posNum)
--     local info = self.MapUIList[posNum]
--     if info then
--         if not info.mapUI then
--             Log.Warning("回收值为空")
--             return
--         end
--         WorldMapModel.MapBuildUIRelese(info.category, info.mapUI)
--         info.mapUI = nil
--         self.MapUIList[posNum] = nil
--     end
-- end

function WorldMap:GetMapPos()
    return self.controller:GetMapPos()
end
function WorldMap:CreateScaleGesture()
    WorldMap.gesture = PinchGesture(mapScreen)
    WorldMap.gesture.onAction:Add(scaleGesture)
end

function WorldMap:GetAndResetCamereSize()
    if self.cameraSize > 5.5 then
        self.cameraSize = 5.5
    elseif self.cameraSize < 3 then
        self.cameraSize = 3
    else
        self.cameraSize = self.cameraSize
    end
    self.camera.orthographicSize = self.cameraSize
    return self.cameraSize
end

function WorldMap:CheckCamereMoveBorder()
    -- if self.tween then
    --     self.tween:Kill()
    -- end
    -- local movePos = CVector3.zero
    -- --最小 14  16.6 14
    -- --最大 25.5 , 30.24  ,25.5
    -- --常态 20,23.73,20
    -- if (self.pos.x > 25.5) then
    --     movePos = -11 * self.forwardVec3
    -- elseif self.pos.x < 14 then
    --     movePos = 12 * self.forwardVec3
    -- else
    --     return
    -- end
    local pointSize = 0
    if self.cameraSize > 5.5 then
        pointSize = 5.5
    elseif self.cameraSize < 3 then
        pointSize = 3
    else
        pointSize = self.cameraSize
    end
    if pointSize > 0 and self.cameraSize ~= pointSize then
        self.tween = GTween.ToDouble(self.cameraSize, pointSize, 1)
        self:GtweenOnUpdate(
            self.tween,
            function()
                -- self.controller:SetCameraPos(self.tween.value.vec3)
                self.camera.orthographicSize = self.tween.value.d
                self.cameraSize = self.tween.value.d
            end
        )
    -- local scaleVec = CVector3(self.pos.x - self.cameraMinPos.x, self.pos.y - self.cameraMinPos.y, self.pos.z - self.cameraMinPos.z)
    -- cameraScale = CVector3.Dot(scaleVec, self.forwardVec3)
    end
end

----------------------
function WorldMap:GetLineColor(data)
    if not self.colorList then
        self.colorList = {}
        --白色代表中立
        self.colorList[RelationEnum.Neutrality] = CS.UnityEngine.Color(1, 1, 1, 1)
        --蓝色代表盟友
        self.colorList[RelationEnum.Ally] = CS.UnityEngine.Color(98 / 255, 151 / 255, 215 / 255, 1)
        --红色代表敌人
        self.colorList[RelationEnum.Enemy] = CS.UnityEngine.Color(210 / 255, 115 / 255, 82 / 255, 1)
        --黄色代表自己
        self.colorList[RelationEnum.Oneself] = CS.UnityEngine.Color(255 / 255, 229 / 255, 158 / 255, 1)
    end
    local relation = MapModel.CheckMarchRouteStatus(data)
    return self.colorList[relation]
end

--注册手势
function WorldMap:OnRegisterFingerGesture()
    Stage.inst.onMouseWheel:Add(fingerGesture)
end

function WorldMap:OnRegisterMoveBuild()
    Event.AddListener(
        EventDefines.BeginBuildingMove,
        function(data)
            if not self.ItemMoveBuild then
                local prefab = ResMgr.Instance:LoadPrefabSync("prefabs/plotChunk")
                local PlotChunk = ObjectUtil.AttachChild(self.RouteLayer, prefab)
                self.ItemMoveBuild = new(ItemMoveBuild)
                self.ItemMoveBuild:Init(PlotChunk.transform)
            end
            self.ItemMoveBuild:Open(data)
        end
    )
    Event.AddListener(
        EventDefines.BuildingMoveing,
        function(touchX, touchY)
            --移动迁城的时候需要推动屏幕
            local delayX = 0
            local delayY = 0
            local param = 0.18

            if (touchX < 150) then
                delayX = delayX + param
                delayY = delayY - param
            elseif touchX > 500 then
                delayX = delayX - param
                delayY = delayY + param
            end

            if touchY < 400 then
                delayX = delayX - param
                delayY = delayY - param
            elseif touchY > 1000 then
                delayY = delayY + param
                delayX = delayX + param
            end

            if touchY < 400 and touchX < 500 and touchX > 150 then
                delayX = delayX - param
                delayY = delayY - param
            elseif touchY > 1000 and touchX < 500 and touchX > 150 then
                delayY = delayY + param
                delayX = delayX + param
            end
            if delayX ~= 0 or delayY ~= 0 then
                self:OnMapMove(delayX, delayY)
            end

            if self.ItemMoveBuild then
                self.ItemMoveBuild:MoveTo(touchX, touchY)
            end
        end
    )
    Event.AddListener(
        EventDefines.WorldMapBuildAnim,
        function(oldPosNum, newPosNum)
            self.moveCityOldPosNum = oldPosNum
            self.moveCityNewPosNum = newPosNum
            self:PlayMoveCityAnim(oldPosNum, newPosNum)
        end
    )
end

function WorldMap:OnRegisterEvent()
    Event.AddListener(
        EventDefines.UICloseMapDetail,
        function()
            WorldMap.choosenMarchUnit = nil
            Event.Broadcast(EventDefines.UIOffAnim)
        end
    )

    Event.AddListener(
        --删除行军路线
        EventDefines.UIDelMarchLine,
        function(rsp)
            if WorldMap.choosenMarchUnit == rsp.Uuid then
                Scheduler.UnScheduleFast(WorldMap.ClickMarchHandle)
                WorldMap.ClickMarchHandle = nil
                self.lastChoosenMarchUnit = WorldMap.choosenMarchUnit
                WorldMap.choosenMarchUnit = nil
                Event.Broadcast(EventDefines.UIOffAnim)
            end
        end
    )
    Event.AddListener(
        EventDefines.WorldCloseClickUnit,
        function(eventId)
            if WorldMap.choosenMarchUnit == eventId then
                Scheduler.UnScheduleFast(WorldMap.ClickMarchHandle)
                WorldMap.ClickMarchHandle = nil
                self.lastChoosenMarchUnit = WorldMap.choosenMarchUnit
                WorldMap.choosenMarchUnit = nil
                Event.Broadcast(EventDefines.UIOffAnim)
            end
        end
    )
    Event.AddListener(
        EventDefines.WorldMarchAnimPoint,
        function(rsp)
            local id = MathUtil.GetPosNum(rsp.X, rsp.Y)
            if rsp.IsWin then
                local info = MapModel.GetArea(id)
                if info and info.Category == Global.MapTypeMonster then
                    local areaInfo = MapModel.GetArea(id)
                    if not MapCachePoint[id] then
                        if areaInfo and areaInfo.Category == Global.MapTypeMonster then
                            MapCachePoint[id] = true
                        else
                            Log.Warning("视野范围内没有野怪，不予记录")
                        end
                    end
                end
            end
            if MarchManagerModel.IsAISiegeOrNo(rsp.EventId) then
                return
            end

            local pointX, pointY, size = MarchManagerModel.GetBattlePoint(rsp.EventId)

            local battleEffect
            --0无巨兽 1为哥斯拉 2为金刚
            local isExistMonster = MarchManagerModel.GetMarchMonster(rsp)
            local battleEffectName = isExistMonster <= 1 and "effect_explosion_all" or "effect_ground_smoke"
            --local resConfig = ConfigMgr.GetItem("configResourcePaths", battleEffectName)
            Scheduler.ScheduleOnce(
                function()

                    DynamicRes.GetBundle(
                        "effect_worldmap",
                        function()
                            DynamicRes.GetPrefab(
                                "effect_worldmap",
                                battleEffectName,
                                function(prefab)
                                    local battleEffect = GameObject.Instantiate(prefab)
                                    battleEffect.transform.localScale = CVector3.one * (size == 2 and 1 or 0.5)
                                    battleEffect:SetActive(false)
                                    battleEffect.transform.parent = self.RouteLayer.transform
                                    battleEffect.transform.localPosition = CVector3(pointX, 0, pointY)
                                    battleEffect:SetActive(true)
                                    if isExistMonster > 0 then
                                        Scheduler.ScheduleOnce(
                                            function()
                                                battleEffect:SetActive(false)
                                                battleEffect:SetActive(true)
                                            end,
                                            2.1
                                        )
                                    end
                                    Scheduler.ScheduleOnce(
                                        function()
                                            ObjectUtil.Destroy(battleEffect)
                                        end,
                                        4
                                    )
                                end
                            )
                        end
                    )
                end,
                2.5
            )
        end
    )
    Event.AddListener(
        EventDefines.WorldMarchAnimFinish,
        function(rsp)
            local id = MathUtil.GetPosNum(rsp.StopX, rsp.StopY)
            if id and id > 0 and MapCachePoint[id] then
                MapCachePoint[id] = nil
                self.controller:DelChild(id, 0)
                WorldMapModel.PoolDelMapUI(id)
            end
            local list = MarchLineModel.GetMarchAttackAnimFinish(rsp.Uuid, rsp.AllianceBattleId)
            for i = 1, #list do
                local line = list[i]
                if line.FinishAt > Tool.Time() then
                    MarchLineModel.CreateLine(line)
                    MarchAnimModel.CreateRoute(line)
                end
            end
            --local data = {
            --    AllianceId = "",
            --    Category = 4,
            --    ConfId = 9406,
            --    DeadTime = 0,
            --    FortressId = 0,
            --    FortressIdList = "",
            --    Id = id,
            --    Occupied = 0,
            --    OwnerId = "",
            --    Params = "",
            --    ServerId = "s999",
            --    State = 0,
            --    Value = 0
            --}
            --MapModel.SetMapInfo(id, data)
            local area = MapModel.GetArea(id)
            if area and RefreshMapObjList[area.Category] and area.Category == 4 then
                MapObjsCache[area.Id] = true
                RefreshMapObjList[area.Category](self, area)
            end
        end
    )

    Event.AddListener(
        EventDefines.DelMarchAnim,
        function(eventId)
            local id = MapAttackCache[eventId]
            if id and id > 0 and MapCachePoint[id] then
                self.controller:DelChild(id, 0)
                WorldMapModel.PoolDelMapUI(id)
                MapCachePoint[id] = nil
            end
            MapAttackCache[eventId] = nil
            MarchLineCache[eventId] = nil
        end
    )
    --刷新行军路线
    Event.AddListener(
        EventDefines.UIOnRefreshMarchLine,
        function(list)
            if GlobalVars.IsInCity then
                return
            end
            MarchManagerModel.OnRefresh(list)
        end
    )
    Event.AddListener(
        EventDefines.WorldMapCameraPosReturn,
        function()
            self.camera.orthographicSize = 4
            self.cameraSize = self.camera.orthographicSize
            self.camera.enabled = true
        end
    )
    --断线重连
    Event.AddListener(
        EventDefines.NetLoginFromReconnect,
        function()
            self:ForceRefresh()
        end
    )
    --游戏重新获取焦点
    Event.AddListener(
        EventDefines.GameOnFocus,
        function()
            self:ForceRefresh()
        end
    )

    Event.AddListener(
        EventDefines.MapAddAllianceMark,
        function(info)
            if GlobalVars.IsInCity then
                return
            end
            self:CreateAllianceMark(info)
        end
    )

    Event.AddListener(
        EventDefines.MapDelAllianceMark,
        function(id)
            if GlobalVars.IsInCity then
                return
            end
            self:DelAllianceMark(id)
        end
    )
    --加入联盟刷新联盟标记
    Event.AddListener(
        EventDefines.UIAllianceJoin,
        function()
            if GlobalVars.IsInCity then
                return
            end
            self:InitAllianceMark()
        end
    )
    --退出联盟刷新联盟标记
    Event.AddListener(
        EventDefines.WorldMapAllianceRefresh,
        function()
            if GlobalVars.IsInCity then
                return
            end
            self:InitAllianceMark()
        end
    )

    Event.AddListener(
        SYSTEM_SETTING_EVENT.HideOtherAISiege,
        function()
            MarchManagerModel.RefreshOtherAISiege()
        end
    )
    Event.AddListener(
        EventDefines.IsInCity,
        function()
            -- MapCachePoint = {}
            self.camera.enabled = false
        end
    )
    --自己进入迁城状态，迁城完毕前不能点击地块
    Event.AddListener(
        EventDefines.UIOnMoveCity,
        function()
            isInMoveAnim = true
            Scheduler.ScheduleOnce(
                function()
                    isInMoveAnim = false
                end,
                3
            )
        end
    )

    Event.AddListener(
        EventDefines.UICloudOutFinish,
        function()
            for _, callback in ipairs(afterCloudEvent) do
                callback()
            end
            afterCloudEvent = {}
        end
    )
    --刷新地图边界
    Event.AddListener(
        EventDefines.RefreshWorldMapBorder,
        function()
            -- self:RefreshMapBorder()
        end
    )
    --刷新猎鹰活动地图野怪
    Event.AddListener(
        EventDefines.MapFalconMonster,
        function()
            self:CheckFalconActivity()
        end
    )
    --刷新侦察活动地图野怪
    Event.AddListener(
        EventDefines.MapSpyMonster,
        function(oldSpyedPosList)
            self:RefreshSpyMondters(oldSpyedPosList)
        end
    )
    Event.AddListener(
        EventDefines.WorldMapClickMarch,
        function(uuid)
            self:ClickMarchUnit(uuid)
        end
    )
end
--创建特殊地图对象
function WorldMap:CreateOtherMapObj(item, confId)
    local monster = ConfigMgr.GetItem("configMonsters", confId)
    local obj = self.controller:AddChild(item.Id, monster.monster_model)
    if not obj then
        return
    end

    specialMapObjs[item.Id] = item

    -- self:RefreshBuildingTile(item.Id, obj)
    local building = WorldMapModel.PoolGetMapUI(item.Id, Global.MapTypeMonster)
    if building then
        building:Refresh(item.Id, obj.transform.position)
    end
end

--创建联盟标记
function WorldMap:InitAllianceMark()
    if not self.MarkUILayer then
        self.MarkUILayer = GComponent()
        self.UILayer.ui:AddChild(self.MarkUILayer)
    end

    local list = Model.GetMap(ModelType.AllianceBookmarks)
    for k, v in pairs(MapAllianceMarkList) do
        self:DelAllianceMark(k)
    end

    for k, v in pairs(list) do
        self:CreateAllianceMark(v)
    end
end

function WorldMap:CreateAllianceMark(info)
    local item = MapAllianceMarkList[info.Category]
    if not item then
        WorldMapModel.MapUIInit("ItemMapAllianceMark", "WorldCity", "ItemMapAllianceMark")
        item = WorldMapModel.MapUIGet("ItemMapAllianceMark", "WorldCity", "ItemMapAllianceMark")
        MapAllianceMarkList[info.Category] = item
    end
    self.MarkUILayer:AddChild(item)
    item:Refresh(info)

    local tran = item.displayObject.cachedTransform
    tran.position = self.transform.position + CVector3(info.X-0.25, 0, info.Y)
end

function WorldMap:DelAllianceMark(category)
    local item = MapAllianceMarkList[category]
    if item then
        item.displayObject.cachedTransform.position = CVector3(-500, 1000, -500)
    end
end
--刷新建筑下方地块
function WorldMap:RefreshBuildingTile(posNum, obj)
    local blackTile = obj.transform:Find("BlackTile")
    local commonTile = obj.transform:Find("CommonTile")
    local posX, posY = MathUtil.GetCoordinate(posNum)
    if MapModel.IsInBlackZone(posX, posY) then
        blackTile.gameObject:SetActive(true)
        commonTile.gameObject:SetActive(false)
    else
        blackTile.gameObject:SetActive(false)
        commonTile.gameObject:SetActive(true)
    end
end

--创建地图边界
-- function WorldMap:RefreshMapBorder(addList, delList)
--     if not self.MapBorderList then
--         self.MapBorderList = {}
--     end
--     local resConfig = ConfigMgr.GetItem("configResourcePaths", PrefabType.WorldMap.Map_BorderLine)
--     --回收边界线
--     for _, k in ipairs(delList or {}) do
--         if self.MapBorderList[k] then
--             for i = 1, #self.MapBorderList[k] do
--                 ObjectPoolManager.Instance:Release(resConfig.name, self.MapBorderList[k][i])
--                 --主动释放table
--                 self.MapBorderList[k][i] = nil
--             end
--             self.MapBorderList[k] = nil
--         end
--     end

--     GameUtil.GetObjFromPool(
--         PrefabType.WorldMap.Map_BorderLine,
--         function()
--             local posX, posY
--             local obj
--             for _, k in ipairs(addList or {}) do
--                 posX, posY = MathUtil.GetCoordinate(k)
--                 if posX <= 1200 - mapOffset and posY <= 1200 - mapOffset and posX >= mapOffset and posY >= mapOffset then
--                     if not self.MapBorderList[k] then
--                         local delayX = 0
--                         local delayY = 0
--                         self.MapBorderList[k] = {}
--                         if posX == mapOffset or posX == 1200 - mapOffset then
--                             delayX = posX == mapOffset and -0.5 or 0.5
--                             obj = ObjectPoolManager.Instance:Get(resConfig.name)
--                             obj.transform.parent = self.RouteLayer.transform
--                             obj.transform.localPosition = CVector3(posX + delayX, 0, posY)
--                             obj.transform.localEulerAngles = CVector3(0, 90, 0)
--                             table.insert(self.MapBorderList[k], obj)
--                         end

--                         if posY == mapOffset or posY == 1200 - mapOffset then
--                             delayY = posY == mapOffset and -0.5 or 0.5
--                             obj = ObjectPoolManager.Instance:Get(resConfig.name)
--                             obj.transform.parent = self.RouteLayer.transform
--                             obj.transform.localPosition = CVector3(posX, 0, posY + delayY)
--                             obj.transform.localEulerAngles = CVector3.zero
--                             table.insert(self.MapBorderList[k], obj)
--                         end
--                     end
--                 end
--             end
--         end
--     )
-- end
--创建地图边界
function WorldMap:CreateMapBorder()
    local setBorder = function()
        local length = 1200 - mapOffset
        borderRectList[1].transform.localPosition = CVector3(749.5 + mapOffset, 0, mapOffset - 5.5)
        borderRectList[1].transform.localScale = CVector3(150, 1, 1)
        borderRectList[2].transform.localPosition = CVector3(mapOffset - 5.5, 0, 450.5 - mapOffset)
        borderRectList[2].transform.localScale = CVector3(1, 1, 150)
        borderRectList[3].transform.localPosition = CVector3(450.5 - mapOffset, 0, length + 5.5)
        borderRectList[3].transform.localScale = CVector3(150, 1, 1)
        borderRectList[4].transform.localPosition = CVector3(length + 5.5, 0, 749.5 + mapOffset)
        borderRectList[4].transform.localScale = CVector3(1, 1, 150)
    end
    if borderRectList then
        setBorder()
    else
        borderRectList = {}
        local borderRect = ConfigMgr.GetItem("configResourcePaths", 400101)
        --生成地图边境线
        CSCoroutine.Start(
            function()
                coroutine.yield(ResMgr.Instance:LoadPrefab(borderRect.resPath))

                local rectPrefab = ResMgr.Instance:GetPrefab(borderRect.resPath)
                for i = 1, 4 do
                    table.insert(borderRectList, ObjectUtil.AttachChild(self.RouteLayer, rectPrefab))
                end
                setBorder()
                -- length/2,0  0,length/2 ,length/2,length length, length/2
            end
        )
    end
end

function WorldMap:CreateRoyalBorder()
    -- local borderLine =
    CSCoroutine.Start(
        function()
            coroutine.yield(ResMgr.Instance:LoadPrefab("prefabs/maptiles/black_frame"))
            -- coroutine.yield( ResMgr )
            local list = {}
            local line = ResMgr.Instance:GetPrefab("prefabs/maptiles/black_frame")
            for i = 1, 8 do
                local lineObj = ObjectUtil.AttachChild(self.RouteLayer, line)
                table.insert(list, lineObj)
                if i > 4 then
                    lineObj:GetComponent("SpriteRenderer").size = CVector2(11.1, 1)
                end
            end
            local vec3 = CVector3(90, 90, 0)
            list[1].transform.localPosition = CVector3(600, 0, 626.5)
            list[2].transform.localPosition = CVector3(573.5, 0, 600)
            list[2].transform.localEulerAngles = vec3
            list[3].transform.localPosition = CVector3(600, 0, 573.5)
            list[4].transform.localPosition = CVector3(626.5, 0, 600)
            list[4].transform.localEulerAngles = vec3

            list[5].transform.localPosition = CVector3(600, 0, 605.5)
            list[6].transform.localPosition = CVector3(594.5, 0, 600)
            list[6].transform.localEulerAngles = vec3
            list[7].transform.localPosition = CVector3(600, 0, 594.5)
            list[8].transform.localPosition = CVector3(605.5, 0, 600)
            list[8].transform.localEulerAngles = vec3
        end
    )
end

function WorldMap:PlayMoveCityAnim(oldPosNum, newPosNum)

    DynamicRes.GetBundle(
        "effect_worldmap",
        function()
            DynamicRes.GetPrefab(
                "effect_worldmap",
                "moveCityEffect",
                function(prefab)
                    local oldPosX, oldPosY = MathUtil.GetCoordinate(oldPosNum)
                    local city = self.controller:GetChild(oldPosNum, 1000)
                    local effect
                    local delay = 2
                    if city then
                        delay = delay + 1
                        local itemTown = BuildingManager.GetItemTown(city)
                        itemTown:CloseCityUI()
                        local tempTween =
                            city.transform:DOLocalMoveY(1, 0.5):SetEase(CS.DG.Tweening.Ease.OutSine):OnComplete(
                            function()
                                city.transform.localPosition = CVector3(0, 1000, 0)
                                self.controller:DelChild(oldPosNum, 0)
                                self.moveCityOldPosNum = 0
                            end
                        )
                        table.insert(tweenCaches, tempTween)
                    end
                    effect = GameObject.Instantiate(prefab)
                    effect.transform.parent = self.RouteLayer.transform
                    local newPosX, newPosY = MathUtil.GetCoordinate(newPosNum)
                    effect.transform.localPosition = CVector3(newPosX - 0.5, 0, newPosY - 0.5)
                    effect:SetActive(false)
                    effect:SetActive(true)
                    Scheduler.ScheduleOnceFast(
                        function()
                            ObjectUtil.Destroy(effect)
                            local newPosX, newPosY = MathUtil.GetCoordinate(newPosNum)
                            city = self.controller:AddChild(newPosNum, 1000)
                            if not city then
                                self.moveCityNewPosNum = 0
                                self.moveCityOldPosNum = 0
                                return
                            end
                            city.transform.localPosition = CVector3(newPosX - 0.5, 1, newPosY - 0.5)
                            local itemTown = BuildingManager.GetItemTown(city)
                            itemTown:RefreshCity(newPosNum)
                            local tempTween1 =
                                city.transform:DOLocalMoveY(0, 0.5):SetEase(CS.DG.Tweening.Ease.OutCubic):OnComplete(
                                function()
                                    self.moveCityNewPosNum = 0
                                    self.moveCityOldPosNum = 0

                                    local building = WorldMapModel.PoolGetMapUI(newPosNum, Global.MapTypeTown)
                                    -- self:RefreshUIPos(building, city)
                                    if building then
                                        building:Refresh(newPosNum, city.transform.position)
                                    end
                                    itemTown:RefreshComponent(newPosNum)
                                end
                            )
                            table.insert(tweenCaches, tempTween1)
                        end,
                        delay
                    )
                end
            )
        end
    )
end

--设置弱引导跳转
function WorldMap:SetWorldTurnPos(posX, posY)
    local logicPos = self.controller:MapToLogicPos(CVector3(posX, 0, posY))
    local posX, posY = MathUtil.GetCoordinate(logicPos)
    local screenX, screenY = MathUtil.ScreenRatio(self:LogicToScreenPos(posX, posY))
    if logicPos ~= 0 then
        local info = {ScreenPos = Vector2(screenX, screenY), isRes = WorldMap.isRes}
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.WorldMapPoint, info)
    end
end

function WorldMap:ForceRefresh()
    if GlobalVars.IsInCity then
        return
    end
    MarchLineModel.DelAll()
    MarchAnimModel.DelAll()
    Scheduler.UnScheduleFast(WorldMap.ClickMarchHandle)
    WorldMap.ClickMarchHandle = nil
    self.lastChoosenMarchUnit = WorldMap.choosenMarchUnit
    WorldMap.choosenMarchUnit = nil
    Event.Broadcast(EventDefines.UIOffAnim)
    local list = self.controller:GetAllPoints()
    local delList = {}
    for point, _ in pairs(list) do
        self.changePoints[point] = (self.changePoints[point] or 0) + 1
        table.insert(delList, point)
    end
    Event.Broadcast(_G.EventDefines.CustomEventRefresh)
    --Log.Error("强制请求——————————————————————————————————————————————————————————————————————")
    MapModel.ClearPoints(delList)
    self.waitingRequest(true)
    isInMoveAnim = false
end

--------------------地图UI获取节点
function WorldMap:GetNodeSprite()
    return self.NodeSprite
end
function WorldMap:GetNodeMix()
    return self.NodeMix
end
function WorldMap:GetNodeText()
    return self.NodeText
end

--------------------------镜头为透视相机时处理方式 暂时封存不要删除---------------------------------------------------------------------------------
-- self.pos = self.pos + inputEvent.mouseWheelDelta * 0.1 * self.forwardVec3
-- if (self.pos.x > 26 and inputEvent.mouseWheelDelta < 0) then
--     self.pos = self.cameraMinPos
-- end

-- if self.pos.x < 13 and inputEvent.mouseWheelDelta > 0 then
--     self.pos = self.cameraMaxPos
-- end
-- self.controller:SetCameraPos(self.pos)
-- self:CheckCamereMoveBorder()
-- local scaleVec = CVector3(self.pos.x - self.cameraMinPos.x, self.pos.y - self.cameraMinPos.y, self.pos.z - self.cameraMinPos.z)
--  cameraScale = CVector3.Dot(scaleVec, self.forwardVec3)

-- self.pos = self.pos + _gesture.delta * 10 * self.forwardVec3
-- if (self.pos.x > 26 and _gesture.delta < 0) then
--     self.pos = self.cameraPos - 12 * self.forwardVec3
-- end

-- if self.pos.x < 13 and _gesture.delta > 0 then
--     self.pos = self.cameraPos + 14 * self.forwardVec3
-- end
-- self.controller:SetCameraPos(self.pos)
-- local scaleVec = CVector3(self.pos.x - self.cameraMinPos.x, self.pos.y - self.cameraMinPos.y, self.pos.z - self.cameraMinPos.z)
-- cameraScale = CVector3.Dot(scaleVec, self.forwardVec3)
--------------------------------------------------------------------------------------------------------------------------------------------------------------

function WorldMap:GtweenOnUpdate(gTween, handler)
    local listeners = regGTweenListeners[gTween]
    if not listeners then
        listeners = {}
        regGTweenListeners[gTween] = listeners
    end
    if listeners[GlobalVars.GtweenOnUpdate] and gTween.RemoveOnUpdate then
        gTween:RemoveOnUpdate(listeners[GlobalVars.GtweenOnUpdate])
    end
    listeners[GlobalVars.GtweenOnUpdate] = handler
    gTween:OnUpdate(handler)
    return gTween
end

function WorldMap:GtweenOnComplete(gTween, handler)
    local listeners = regGTweenListeners[gTween]
    if not listeners then
        listeners = {}
        regGTweenListeners[gTween] = listeners
    end
    if listeners[GlobalVars.GtweenOnComplete] and gTween.GtweenOnComplete then
        gTween:RemoveOnComplete(listeners[GlobalVars.GtweenOnComplete])
    end
    listeners[GlobalVars.GtweenOnComplete] = handler
    gTween:OnComplete(handler)
    return gTween
end

function WorldMap:DisposeRegister()
    for gTween, listeners in pairs(regGTweenListeners) do
        if listeners[GlobalVars.GtweenOnStart] and gTween.RemoveOnStart then
            gTween:RemoveOnStart(GlobalVars.GtweenOnStart)
        end
        if listeners[GlobalVars.GtweenOnComplete] and gTween.RemoveOnComplete then
            gTween:RemoveOnComplete(listeners[GlobalVars.GtweenOnComplete])
        end
        if listeners[GlobalVars.GtweenOnUpdate] and gTween.RemoveOnUpdate then
            gTween:RemoveOnUpdate(listeners[GlobalVars.GtweenOnUpdate])
        end
    end
end

return WorldMap
