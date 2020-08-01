--[[
    Author: songzeming
    Function: 内城地图
]]
local CityMapCmpt = fgui.extension_class(GComponent)
fgui.register_extension("ui://City/Map", CityMapCmpt)

import("UI/City/MapRelated/ItemInnerMapPiece")
import("UI/City/MapRelated/ItemOuterMapPiece")
import("UI/City/MapRelated/ItemAreaLock")
import("UI/Effect/EffectNode")
local ParadeSquareModel = import("Model/Animation/ParadeSquareModel")
local CitySoldier = import("Model/CityCharacter/CitySoldier")
local CityWorker = import("Model/CityCharacter/CityWorker")
local WaterModel = import("Model/CityMap/WaterModel")
local GlobalVars = GlobalVars

function CityMapCmpt:ctor()
    --节点
    self:InitNode()
    --城内
    local innerPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneInnter)
    for pos = innerPosConf.start_pos + 1, innerPosConf.stop_pos do
        self["map" .. pos] = self:GetChild("map" .. pos)
    end
    --城外
    local outerPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneWild)
    for pos = outerPosConf.start_pos + 1, outerPosConf.stop_pos do
        self["map" .. pos] = self:GetChild("map" .. pos)
    end
    --巨兽
    local beastPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneBeast)
    for pos = beastPosConf.start_pos + 1, beastPosConf.stop_pos do
        self["map" .. pos] = self:GetChild("map" .. pos)
    end
    --巢穴
    local nestPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneNest)
    for pos = nestPosConf.start_pos + 1, nestPosConf.stop_pos do
        self["map" .. pos] = self:GetChild("map" .. pos)
    end

    self._areaLockGodzilla.visible = false
    self._areaLockKingkong.visible = false
    for id, _ in ipairs(ConfigMgr.GetList("configAreaUnlocks")) do
        if id > 3 then
            local item = self["_areaLock" .. id]
            item.sortingOrder = CityType.CITY_MAP_SORTINGORDER.Tree
            local _lock = item:GetChild("btnLock")
            self["_lock" .. id] = _lock
            CityMapModel.SetLockBtn(_lock)
            self:AddListener(item.onClick,
                function()
                    _lock:OnBtnLockClick()
                end
            )
        end
    end

    -- 点击地图空白区域
    NodePool.Init(NodePool.KeyType.ClickBlackEffect,  "Effect", "EffectNode")
    self:AddListener(self._btnBlack.onClick,
        function(data)
            CityMapModel.GetCityFunction():OffAnim()

            --播放动画
            local gLocalPos = GRoot.inst:GlobalToLocal(data.inputEvent.position)
            local rLocalPos = self:RootToLocal(gLocalPos)
            self:PlayEffect(rLocalPos)

            WaterModel.CheckShow()
        end
    )

    self:AddEvent(
        EventDefines.UICityBuildCenterUpgrade,
        function()
            self:UpdateUnlockArea()
        end
    )
    self:AddEvent(
        EventDefines.UICityBuildMove,
        function(type, pos)
            self:OnBuildMoveShow(type, pos)
        end
    )
    self:AddEvent(
        EventDefines.UIMapTurnLockPiece,
        function(piece)
            self:OnTurnMapLockPiece(piece)
        end
    )
    self:AddEvent(
        EventDefines.UIOnRefreshWall,
        function()
            self:OnCityFire()
        end
    )
    --城墙着火
    self:OnCityFire()

    --城墙层级
    for i = 1, 6 do
        self["_wall" .. i].sortingOrder = CityType.CITY_MAP_SORTINGORDER.Wall
    end
    --水
    self._water.displayObject.cachedTransform.name = "Water"
    --中远景
    self._shot.displayObject.cachedTransform.name = "Shot"

    self._plane.sortingOrder = CityType.CITY_MAP_SORTINGORDER.PlaneAnimation
    self.animPlaneIn = self._plane:GetTransition("PlaneIn")
    self.animPlaneOut = self._plane:GetTransition("PlaneOut")

    self:InitAnimeCB()
end

function CityMapCmpt:Init()
    self:PlayPlaneAnim()
    self:PlayCharactorAnim()
    self:InitParadeSquare()
    self:InitCloud()
end

function CityMapCmpt:InitNode()
    for _, v in pairs(CityType.CITY_MAP_NODE_TYPE) do
        local node = UIMgr:CreateObject("Common", "blankNode")
        node.sortingOrder = v.sortingOrder
        node.name = v.name
        node.displayObject.cachedTransform.name = v.name
        self[v.name] = node --可以通过 map.xx 访问,减少 GetChild("xx") 的消耗
        node.xy = Vector2(0, 0)
        self:AddChild(node)
    end
end

--初始化地块解锁区域
function CityMapCmpt:InitUnlockArea()
    --外城
    for id, _ in ipairs(ConfigMgr.GetList("configAreaUnlocks")) do
        local isLock = true
        for _, v in pairs(Model.UnlockedAreas) do
            if v == id then
                isLock = false
                break
            end
        end
        if id > 3 then
            self["_lock" .. id]:InitOuter(id, isLock)
        end
    end
    --巢穴
    -- for id, _ in ipairs(ConfigMgr.GetList("configBeastUnlocks")) do
    -- end
    self:SetMapPieceUnlock()
end

--设置解锁地块
function CityMapCmpt:SetMapPieceUnlock()
    for _, area in pairs(Model.UnlockedAreas) do
        local conf = ConfigMgr.GetItem("configAreaUnlocks", area)
        for _, pos in pairs(conf.position) do
            self:GetMapPiece(pos):SetPieceUnlock(true)
        end
    end
end

--指挥中心升级 刷新地块解锁区域
function CityMapCmpt:UpdateUnlockArea()
    for _, v in ipairs(ConfigMgr.GetList("configAreaUnlocks")) do
        if v.unlock_level == Model.Player.Level then
            self:InitUnlockArea()
            break
        end
    end
end

-- 根据位置获取地图按钮
function CityMapCmpt:GetMapPiece(pos)
    return self["map" .. pos]
end

--建筑移动显示
function CityMapCmpt:OnBuildMoveShow(moveType, waitPos)
    UIMgr:Close("BuildMoveTip")
    if moveType == BuildType.MOVE.Reset then
        --重置地图块
        self:OnResetMapPiece()
    elseif moveType == BuildType.MOVE.Move then
        --建筑移动
        self:OnMoveMapPiece(waitPos)
        UIMgr:Open("BuildMoveTip")
    elseif moveType == BuildType.MOVE.Item then
        --道具移动
        self:ItemMoveMapPiece()
        UIMgr:Open("BuildMoveTip")
    end
end
--重置地图块
function CityMapCmpt:OnResetMapPiece()
    local function piece_func(index)
        local piece = self:GetMapPiece(index)
        if not piece then
            return
        end
        if piece:GetPieceUnlock() then
            piece:SetMoveState(false)
            piece:SetPieceTouch(true)
            piece:SetPieceActive(not piece:GetPieceBuild())
        end
    end
    --城内
    for _, v in pairs(BuildModel.InnerMovePiece()) do
        piece_func(v)
    end
    --城外
    local outerPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneWild)
    for i = outerPosConf.start_pos + 1, outerPosConf.stop_pos do
        piece_func(i)
    end
    --巨兽
    local beastPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneBeast)
    for i = beastPosConf.start_pos + 1, beastPosConf.stop_pos do
        piece_func(i)
    end
end
--建筑移动
function CityMapCmpt:OnMoveMapPiece(waitPos)
    local function piece_func(index, isMove)
        local piece = self:GetMapPiece(index)
        if not piece then
            Log.Error("not find piece. index:{0}", index)
            return
        end
        if piece:GetPieceUnlock() then
            local isBuild = piece:GetPieceBuild()
            piece:SetMoveState(isMove)
            piece:SetMoveStateColor(true)
            piece:SetStartPiecePos(waitPos)
            if isMove then
                piece:SetPieceActive(true)
                piece:SetPieceTouch(not isBuild)
            else
                piece:SetPieceActive(not isBuild)
                piece:SetPieceTouch(false)
            end
        end
    end

    local function pieces_func(inner, outer, beast)
        --城内
        for _, v in pairs(BuildModel.InnerMovePiece()) do
            piece_func(v, inner)
        end
        --城外
        local outerPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneWild)
        for i = outerPosConf.start_pos + 1, outerPosConf.stop_pos do
            piece_func(i, outer)
        end
        --巨兽
        local beastPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneBeast)
        for i = beastPosConf.start_pos + 1, beastPosConf.stop_pos do
            piece_func(i, beast)
        end
    end

    local posType = BuildModel.GetBuildPosTypeByPos(waitPos)
    if posType == Global.BuildingZoneInnter then
        --城内
        pieces_func(true, false, false)
    elseif posType == Global.BuildingZoneWild then
        --城外
        pieces_func(false, true, false)
    elseif posType == Global.BuildingZoneBeast then
        --巨兽
        pieces_func(false, false, true)
    end

    --等待移动建筑显示
    local piece = self:GetMapPiece(waitPos)
    piece:SetMoveStateColor(false)
    CityType.BUILD_MOVE_POS = waitPos
    CityType.BUILD_MOVE_TYPE = BuildType.MOVE.Move
end
--道具移动
function CityMapCmpt:ItemMoveMapPiece()
    local function piece_func(index)
        local piece = self:GetMapPiece(index)
        if piece:GetPieceUnlock() then
            piece:SetMoveState(true)
            piece:SetMoveStateColor(true)
            piece:SetPieceTouch(false)
            piece:SetPieceActive(true)
        end
    end
    --城内
    for _, v in pairs(BuildModel.InnerMovePiece()) do
        piece_func(v)
    end
    --城外
    local outerPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneWild)
    for i = outerPosConf.start_pos + 1, outerPosConf.stop_pos do
        piece_func(i)
    end
    --巨兽
    local beastPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneBeast)
    for i = beastPosConf.start_pos + 1, beastPosConf.stop_pos do
        piece_func(i)
    end
    CityType.BUILD_MOVE_TYPE = BuildType.MOVE.Item
end

--跳转到地块解锁区域
function CityMapCmpt:OnTurnMapLockPiece(area)
    local function turn_func(a)
        Event.Broadcast(EventDefines.MoveMapEvent, false)
        local cb = function()
            Event.Broadcast(EventDefines.MoveMapEvent, true)
        end
        local conf = ConfigMgr.GetItem("configAreaUnlocks", a)
        local piece = CityMapModel.GetMapPiece(conf.position[2])
        ScrollModel.MoveScale(piece, nil, nil, true)
        ScrollModel.SetCb(cb)
        JumpMap:JumpTo({jump = 810500, para = a})
    end
    if area then
        turn_func(area)
    else
        for id, _ in ipairs(ConfigMgr.GetList("configAreaUnlocks")) do
            local isLock = true
            for _, v in pairs(Model.UnlockedAreas) do
                if v == id then
                    isLock = false
                    break
                end
            end
            if isLock then
                turn_func(id)
                return
            end
        end
    end
end

--城内着火
function CityMapCmpt:OnCityFire()
    if not GlobalVars.IsShowEffect() then
        return
    end
    local isFire = Model.GetMap(ModelType.Wall).IsOnFire
    if Tool.EqualBool(self.isFire, isFire) then
        return
    end
    self.isFire = isFire
    local parentNode = self[CityType.CITY_MAP_NODE_TYPE.WallFire.name]
    if not isFire then
        for i = parentNode.numChildren, 1, -1 do
            parentNode:GetChildAt(i - 1):Dispose()
        end
    else
        for _, v in pairs(Global.CityWallFirePos) do
            local _node = UIMgr:CreateObject("Effect", "EmptyNode")
            _node.xy = Vector2(v.x, v.y)
            parentNode:AddChild(_node)
            --动态资源加载
            DynamicRes.GetBundle("effect_collect", function()
                DynamicRes.GetPrefab("effect_collect", "effect_base_fire", function(prefab)
                    local object = GameObject.Instantiate(prefab)
                    object.transform.localScale = Vector3(140, 140, 140)
                    _node:GetGGraph():SetNativeObject(GoWrapper(object))
                end)
            end)
        end
    end
end

--地图点击空白区域 播放点击动画 (有缓存)
function CityMapCmpt:PlayEffect(pos)
    local item = NodePool.Get(NodePool.KeyType.ClickBlackEffect)
    item.xy = Vector2(pos.x - 6 , pos.y + 6)
    item.sortingOrder = CityType.CITY_MAP_SORTINGORDER.EffectClickBlack
    self:AddChild(item)
    item:InitNormal()
    local scaleValue =  1/self.scale.x
    item:PlayDynamicEffectSingle(
        "effect_collect",
        "Effect_cityBlackClick",
        function()
            NodePool.Set(NodePool.KeyType.ClickBlackEffect, item)
        end,
        Vector3.one*scaleValue
    )
end

--飞机动画
function CityMapCmpt:PlayPlaneAnim()
    self:PlayPlaneLandingAnim()
end

function CityMapCmpt:InitAnimeCB(  )
    self.animPlaneOutCB = function()
        self:GtweenOnComplete(self._plane:TweenFade(1, Global.CityPlaneIntervalTime),function()
            self:PlayPlaneLandingAnim()
        end)
    end

    self.animPlaneInCB = function()
        self:GtweenOnComplete(self._plane:TweenFade(1, Global.CityPlaneStayTime),function()
            self:PlayPlaneTakeOffAnim()
        end)
    end
end

--飞机起飞
function CityMapCmpt:PlayPlaneTakeOffAnim()
    self.animPlaneIn:Stop()
    self.animPlaneOut:Play(self.animPlaneOutCB)
end
--飞机降落
function CityMapCmpt:PlayPlaneLandingAnim()
    self.animPlaneOut:Stop()
    self.animPlaneIn:Play(self.animPlaneInCB)
end

--大兵、工人动画
function CityMapCmpt:PlayCharactorAnim()
    if not GlobalVars.IsShowEffect() then
        --低端机不显示
        return
    end
    CitySoldier.InitSoldierAnim(self)
    CityWorker.InitWorkerAnim(self)
end

--初始化阅兵广场
function CityMapCmpt:InitParadeSquare()
    --if not GlobalVars.IsShowEffect() then
    --    --低端机不显示
    --    return
    --end
    ParadeSquareModel.InitParadeSquare(self)
end

-- 云
function CityMapCmpt:InitCloud()
    if not GlobalVars.IsShowEffect() then
        --低端机不显示
        return
    end
    --动态资源加载
    DynamicRes.GetBundle("effect_collect", function()
        DynamicRes.GetPrefab("effect_collect", "effect_scene_cloud", function(prefab)
            local object = GameObject.Instantiate(prefab)
            self._cloudPoint:GetGGraph():SetNativeObject(GoWrapper(object))
        end)
    end)
end

return CityMapCmpt
