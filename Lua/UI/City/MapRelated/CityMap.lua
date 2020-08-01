--[[
    Author: songzeming
    Function: 内城地图
]]
local CityMap = fgui.extension_class(GComponent)
fgui.register_extension("ui://City/Middel", CityMap)

local Vector2 = _G.Vector2
local GlobalVars = _G.GlobalVars
local Global = _G.Global
local CityType = _G.CityType
local BuildType = _G.BuildType
local EventDefines = _G.EventDefines
local BuildModel = import("Model/BuildModel")
local BuildQueueModel = import("Model/CityMap/BuildQueueModel")
local DialogModel = import("Model/Common/DialogModel")
import("UI/City/MapRelated/CityMapCmpt")

local SCALE_MAX = 1.75 --地图缩放最大值
local SCALE_MIN = 0.45 --地图缩放最小值
local SPRING_MAX = 1.5 --回弹最大
local SPRING_MIN = 0.5 --回弹最小
local SCALE_DEFAULT = 0.6 --地图默认缩放值
local SCALE_WHEEL_OFFSET = 0.05 --鼠标滚轮地图缩放偏移量
-- local SCALE_HAND_OFFSET = 0.03 --手指地图缩放偏移量
local CHECK_OFFSET = 5 --地图检查偏移量
local SCALE_STANDARD_INNER = 1.1 --城内或巨兽建筑跳转升级详情建造缩放大小
local SCALE_STANDARD_OUTER = 1.8 --城外建筑跳转升级详情建造缩放大小
local SCALE_STANDARD_CENTER = 0.5 --指挥中心跳转升级详情建造缩放大小
local SCALE_STANDARD_WALL = 0.8 --城墙跳转升级详情建造缩放大小
local SCALE_STANDARD_NEST = 1.2 --巢穴升级详情建造缩放大小
local SCALE_STANDARD_EQUIPMATERIALMAKE = 1 --装备材料生产工厂缩放大小
local SCALE_TIME = 0.5 --缩放时间
local SCALE_NORMAL = 1 --原始大小
local SCALE_NOVICE = 0.5 -- 新手引导缩放大小
local SCALE_POSY = 600

--获取缩放大小 受限最大最小值
local function GetScale(scale)
    return scale > SCALE_MAX and SCALE_MAX or (scale < SCALE_MIN and SCALE_MIN or scale)
end
--隐藏队列提示
local function HideQueueTip()
    if BuildQueueModel.IsShowQueTip then
        BuildQueueModel.HideQueueTip()
    end
end

function CityMap:ctor()
    -- self.scrollPane.inertiaDisabled = true --惯性禁用
    self._map = self:GetChild("Map")
    self._map.fairyBatching = true
    self:AddListener(self._map.onTouchBegin,HideQueueTip)
    self:AddListener(self._map.onClick,

        function()
            if not GlobalVars.ClickBuildFunction then
                self.isMoveScale = false
            end
            GlobalVars.ClickBuildFunction = false
            GlobalVars.ClickBuilder = false
            HideQueueTip()
        end
    )

    self:AddEvent(
        EventDefines.NoviceMapScale,
        function()
            self._map:SetScale(SCALE_NORMAL, SCALE_NORMAL)
            self:SetDialogScale()
            self:RefreshMap()
        end
    )
    self:AddEvent(
        EventDefines.NoviceMapTweenMove,
        function()
            self._map:TweenMove(Vector2(3300, 1000), SCALE_TIME * 6):SetEase(EaseType.Custom)
            self:GtweenOnComplete(self._map:TweenScale(Vector2(SCALE_NOVICE, SCALE_NOVICE), SCALE_TIME * 6):SetEase(EaseType.Custom),function()
                self:RefreshMap()
            end)
        end
    )
    self:AddEvent(
        EventDefines.UIOutCityScale,
        function()
            AnimationModel:StopResCollectAnima()
            self:OutCityScale()
        end
    )
    self:AddEvent(EventDefines.EventDialogSoldier, function(cb)
        self:CheckSolderShowScreen(cb)
    end)
    self:AddEvent(EventDefines.EventDialogScale, function()
        self:SetDialogScale()
    end)

    --中远景初始化
    self:InitMiddleVisionShot()
    --初始化对话框
    self:InitDialog()
end

function CityMap:RefreshMap()
    self:SetBoundsChangedFlag()
    self:EnsureBoundsCorrect()
end

--初始化地图大小
function CityMap:InitMapData()
    self._map.xy = Vector2.zero
    self._map:SetScale(SCALE_DEFAULT, SCALE_DEFAULT)
    self:SetDialogScale()
    self.scaleValue = SCALE_DEFAULT
    self.lastScale = self.scaleValue
    self:RefreshMap()
end

--是否禁止地图缩放
function CityMap:BanMapScale()
    if not GlobalVars.IsInCity then
        return true
    end
    --新手引导或者触发式引导时不能缩放屏幕
    if GlobalVars.IsTriggerStatus or GlobalVars.IsNoviceGuideStatus or GlobalVars.IsSidebarOpen then
        return true
    end
    if UIMgr:GetShowPanelCount() > 0 then
        return true
    end
    if self.isMapCityScaling then
        return true
    end
    if self.isMapCityMoving then
        return true
    end
    return false
end

function CityMap:InitMap()
    if self.isInit then
        return
    end
    self.isInit = true

    self:InitMapData()
    --鼠标滚轮监听缩放地图
    self:AddListener(Stage.inst.onMouseWheel,
        function(data)
            if not GlobalVars.IsInCity then
                return
            end
            if self:BanMapScale() then
                return
            end
            local inputEvent = data.inputEvent
            if inputEvent.mouseWheelDelta > 0 then
                self.scaleValue = self.scaleValue - SCALE_WHEEL_OFFSET --缩小
            else
                self.scaleValue = self.scaleValue + SCALE_WHEEL_OFFSET --放大
            end
            self:ScaleMap(self.scaleValue)
            self:CheckCameraMoveBorder()
        end
    )

    --双指触摸移动缩放地图
    self:AddListener(self.onTouchBegin,
        function()
            if (GlobalVars.IsTriggerStatus or GlobalVars.IsNoviceGuideStatus) or self.isMapCityScaling then
                self.scrollPane.touchEffect = false
                return
            end
            self.p1 = nil
            self.p2 = nil
            self.scrollPane.touchEffect = Stage.inst.touchCount == 1
        end
    )
    local isScaleGesture = false
    self:AddListener(self.onTouchEnd,
            function()
                if Stage.inst.touchCount == 0 and isScaleGesture then
                    --双指缩放结束：开启内城可滑动
                    if self.isMapCityScaling or GlobalVars.IsTriggerStatus then
                        return
                    end
                    self.scrollPane.touchEffect = true 
                end
            end
    )
    self:AddListener(self.onTouchMove,
        function()
            if Stage.inst.touchCount == 2 then
                if self:BanMapScale() then
                    return
                end
                
                --双指缩放时：关闭内城可滑动
                isScaleGesture = true
                self.scrollPane.touchEffect = false
                
                local touchIds = Stage.inst:GetAllTouch(nil)
                local p1 = Stage.inst:GetTouchPosition(touchIds[0])
                local p2 = Stage.inst:GetTouchPosition(touchIds[1])
                if not self.p1 then
                    self.p1 = p1
                    self.p2 = p2
                    return
                end

                local lastDistance = MathUtil.GetDistance(self.p2.x - self.p1.x, self.p2.y - self.p1.y)
                local distance = MathUtil.GetDistance(p2.x - p1.x, p2.y - p1.y)
                self.p1 = p1
                self.p2 = p2

                if lastDistance - distance > CHECK_OFFSET or lastDistance - distance < -CHECK_OFFSET then
                    self.scaleValue = self.scaleValue * (1 + (distance - lastDistance) / _G.Screen.width * 1.5)
                else
                    self.p1 = p1
                    self.p2 = p2
                    return
                end
                self:ScaleMap(self.scaleValue)
                self:CheckCameraMoveBorder()
            end
        end
    )
    self.scrollPane.decelerationRate = 0.97
    self:AddListener(self.scrollPane.onScroll,
        function()
            --self:InvalidateBatchingState()
            self:OnScrollMap()
            self.isScrollFlag = true
        end
    )
    self:AddListener(self.scrollPane.onScrollEnd,
        function()
            self.isScrollFlag = false
            --self:InvalidateBatchingState()
        end
    )
end

--动态设置对话框大小
function CityMap:SetDialogScale()
    if self._dialogNode then
        self._dialogNode.scale = Vector2(1 / self._map.scale.x, 1 / self._map.scale.y)
    end
end

--设置地图可触摸
function CityMap:SetTouchable()
    self:GtweenOnComplete(self._map:TweenFade(1, GlobalVars.ScrollDelayTime),function()
        self.isMapCityScaling = false
        self:OnScrollMap()
    end)
end

--获取是否移动中
function CityMap:GetMoving()
    return self.isScrollFlag
end
--获取是否正在缩放中
function CityMap:GetScaling()
    return self.isMapCityScaling
end
--设置是否在缩放中
function CityMap:SetScaling(flag)
    self.isMapCityScaling = flag
end

--地图大小缩放 (鼠标滚轮缩放、双指触摸缩放)
function CityMap:ScaleMap(scale, force)
    if self.isMapCityScaling then
        return
    end
    if self.tween then
        GTween.Kill(self.tween)
    end
    self.isMapCityScaling = true
    scale = force and scale or GetScale(scale)
    self.scaleValue = scale
    if self.lastScale == scale then
        self:SetTouchable()
        return
    end
    GTween.Kill(self._map)
    self:SetMapScaleValue(scale)
    self:RefreshMap()
    self:SetTouchable()
end
function CityMap:SetMapScaleValue(scale)
    self:SetScreenDeviation(scale)
    self._map:SetScale(scale, scale)
    self:SetDialogScale()
end
---当地图缩放后使用此函数调整偏移
function CityMap:SetScreenDeviation(scale)
    if not self.lastScale then
        return
    end
    local mvx = ((self.scrollPane.posX+ self.width / 2 )/self.lastScale )*scale - self.width  / 2
    local mvy = ((self.scrollPane.posY+ self.height/ 2 )/self.lastScale )*scale - self.height / 2
    self.scrollPane:SetContainerPosX(mvx)
    self.scrollPane:SetContainerPosY(mvy)
    self.lastScale = scale
end
function CityMap:CheckCameraMoveBorder()
    -- local pointSize = 0
    -- if self._map.scale.x >SPRING_MAX  then
    --     pointSize = SPRING_MAX
    -- elseif self._map.scale.x < SPRING_MIN then
    --     pointSize =SPRING_MIN
    -- else
    --     pointSize = self._map.scale.x
    -- end
    -- if pointSize > 0 and self._map.scale.x ~= pointSize then
    --     self.scrollPane.touchEffect = false
    --     local scalevalue
    --     self.tween = GTween.ToDouble(self._map.scale.x, pointSize, 1):OnUpdate(
    --         function()
    --             --self:ScaleMap(self.tween.value.d)
    --             self:SetMapScaleValue(self.tween.value.d)
    --             scalevalue = self.tween.value.d
    --         end
    --     ):OnComplete(function()
    --         self:SetScreenDeviation(scalevalue)
    --         self:RefreshMap()
    --         self.scrollPane.touchEffect = true
    --     end)
    -- end
end
function CityMap:SetCb(cb)
    self.cb = cb
end
function CityMap:DoCb()
    if self.cb then
        self.cb()
        self.cb = nil
        if GlobalVars.IsNoviceGuideStatus == true then
            if Model.Player.GuideStep == 10042 and (Model.Player.GuideVersion == 0 or Model.Player.GuideVersion == 1) then
                Event.Broadcast(EventDefines.BuildingCenterJumpNovice)
            elseif Model.Player.GuideStep == 10035 and Model.Player.GuideVersion == 2 then
                Event.Broadcast(EventDefines.BuildingCenterJumpNovice)
            elseif Model.Player.GuideStep == 10034 and Model.Player.GuideVersion == 3 then
                Event.Broadcast(EventDefines.BuildingCenterJumpNovice)
            end
        end
    end
end

function CityMap:SetWhetherMoveScale(flag)
    self.isMoveScale = flag
end
function CityMap:GetWhetherMoveScale()
    return self.isMoveScale
end
function CityMap:GetLastScalePiece()
    return self.lastScalePiece
end

-- 指挥中心缩放
function CityMap:CenterMoveScale()
    self:ForceStop()
    Event.Broadcast(EventDefines.CityMask, true)
    self.isMapCityScaling = true
    GTween.Kill(self._map)
    self._map.xy = Vector2.zero
    local scale = SCALE_DEFAULT
    local goalPos = Vector2(self.width / 2, self.height / 2)
    local building = BuildModel.FindByConfId(Global.BuildingCenter)
    local piece = self._map:GetMapPiece(building.Pos)
    local originScale = self._map.scale
    self._map.scale = Vector2(scale, scale)
    local ltgPos = self:GlobalToLocal(piece:LocalToGlobal(Vector2.zero))
    local mvx = goalPos.x - ltgPos.x
    local mvy = goalPos.y - ltgPos.y
    self._map:TweenMove(Vector2(mvx, mvy), SCALE_TIME * 2):SetEase(EaseType.Custom)
    self._map.scale = originScale
    self:GtweenOnComplete(self._map:TweenScale(Vector2(scale, scale), SCALE_TIME * 2):SetEase(EaseType.Custom),function()
        self._map.xy = Vector2.zero
        self:SetScreenDeviation(scale)
        self:MoveMap(piece.x, piece.y)
        self.scaleValue = scale
        self:SetTouchable()
        self:DoCb()
        Event.Broadcast(EventDefines.CityMask, false)
    end)
end

-- 地图移动缩放
function CityMap:MoveScaleMap(piece, scale, confId, isAnime)
    if self.isMapCityScaling then
        return
    end
    Event.Broadcast(EventDefines.CityMask, true)
    self.isMapCityScaling = true
    self.isMoveScale = true
    self.lastScaleValue = self.lastScale
    self.lastScalePiece = piece
    self.lastScaleConfig = confId
    self.isCamera = true
    GTween.Kill(self._map)
    self._map.xy = Vector2.zero
    local originScale = Vector2(self.lastScale, self.lastScale)
    self._map.scale = originScale

    local goalPos = Vector2(self.width / 2, self.height / 2)
    -- 移动
    self._map.scale = Vector2(scale, scale)
    local ltgPos = self:GlobalToLocal(piece:LocalToGlobal(Vector2.zero))
    if confId == Global.BuildingCenter then
        --指挥中心
        ltgPos = Vector2(ltgPos.x + BuildType.OFFSET_CENTER.x, ltgPos.y + BuildType.OFFSET_CENTER.y)
    elseif confId == Global.BuildingWall then
        --城墙
        ltgPos = Vector2(ltgPos.x + BuildType.OFFSET_WALL.x, ltgPos.y + BuildType.OFFSET_WALL.y)
    elseif confId == Global.BuildingBridge then
        --桥头建筑（在线领奖）
        ltgPos = Vector2(ltgPos.x + BuildType.OFFSET_BRIDGE.x, ltgPos.y + BuildType.OFFSET_BRIDGE.y)
    elseif confId == Global.BuildingGodzilla then
        --巢穴 哥斯拉
        ltgPos = Vector2(ltgPos.x + BuildType.OFFSET_GODZILLA.x, ltgPos.y + BuildType.OFFSET_GODZILLA.y)
    elseif confId == Global.BuildingKingkong then
        --巢穴 金刚
        ltgPos = Vector2(ltgPos.x + BuildType.OFFSET_KINGKONG.x, ltgPos.y + BuildType.OFFSET_KINGKONG.y)
    end
    local mvx = goalPos.x - ltgPos.x
    local mvy = goalPos.y - ltgPos.y

    if isAnime then
        self._map:TweenMove(Vector2(mvx, mvy), SCALE_TIME * 2):SetEase(EaseType.CubicOut)
        --缩放
        self._map.scale = originScale
        self:GtweenOnComplete(self._map:TweenScale(Vector2(scale, scale), SCALE_TIME * 2):SetEase(EaseType.CubicOut),function()
            self:MoveScaleMapCallback(confId, piece, scale)
        end)
    else
        self._map.xy = Vector2(mvx, mvy)
        self._map.scale = Vector2(scale, scale)
        self:MoveScaleMapCallback(confId, piece, scale)
    end
end

function CityMap:MoveScaleMapCallback(confId, piece, scale)
    self._map.xy = Vector2.zero
    self:SetScreenDeviation(scale)
    if confId == Global.BuildingCenter then
        --指挥中心
        self:MoveMap(piece.x + BuildType.OFFSET_CENTER.x, piece.y + BuildType.OFFSET_CENTER.y)
    elseif confId == Global.BuildingWall then
        --城墙
        self:MoveMap(piece.x + BuildType.OFFSET_WALL.x, piece.y + BuildType.OFFSET_WALL.y)
    elseif confId == Global.BuildingBridge then
        --桥头建筑（在线领奖）
        self:MoveMap(piece.x + BuildType.OFFSET_BRIDGE.x, piece.y + BuildType.OFFSET_BRIDGE.y)
    elseif confId == Global.BuildingGodzilla then
        --巢穴 哥斯拉
        self:MoveMap(piece.x + BuildType.OFFSET_GODZILLA.x, piece.y + BuildType.OFFSET_GODZILLA.y)
    elseif confId == Global.BuildingKingkong then
        --巢穴 金刚
        self:MoveMap(piece.x + BuildType.OFFSET_KINGKONG.x, piece.y + BuildType.OFFSET_KINGKONG.y)
    else
        self:MoveMap(piece.x, piece.y)
    end
    self.scaleValue = scale
    self:SetTouchable()
    self.isMoveScale = false
    self:DoCb()
    Event.Broadcast(EventDefines.CityMask, false)
end

-- 屏幕移动
function CityMap:MoveMap(x, y, flag)
    self.isMapCityMoving = true
    if x then
        self.scrollPane:SetPosX(x * self._map.scaleX - self.width / 2, flag)
    end
    if y then
        self.scrollPane:SetPosY(y * self._map.scaleY - self.height / 2, flag)
    end
    if flag then
        self:ScheduleOnceFast(
            function()
                self.isMapCityMoving = false
                self:DoCb()
            end, GlobalVars.ScrollAnimTime
        )
    else
        self:ScheduleOnceFast(
            function()
                self.isMapCityMoving = false
                self:DoCb()
            end, GlobalVars.ScrollDelayTime
        )
    end
end

-- 建筑跳转详情、升级、建造放大
function CityMap:OnMapScale(pos, isAnim)
    if self.isMapCityScaling then
        return
    end
    Event.Broadcast(EventDefines.CityMask, true)
    self.isMapCityScaling = true
    self.isCamera = true
    GTween.Kill(self._map)
    self._map.xy = Vector2.zero
    local goalPos = Vector2(self.width / 2, SCALE_POSY)
    --放大
    local piece = self._map:GetMapPiece(pos)
    local mapScale = 1
    if piece.visible then
        --建筑建造
        local posType = BuildModel.GetBuildPosTypeByPos(pos)
        if Tool.Equal(posType, Global.BuildingZoneInnter, Global.BuildingZoneBeast) then
            --城内建筑或巨兽建筑
            mapScale = SCALE_STANDARD_INNER
        elseif Tool.Equal(posType, Global.BuildingZoneWild) then
            --城外
            mapScale = SCALE_STANDARD_OUTER
        elseif Tool.Equal(posType, Global.BuildingZoneNest) then
            --巢穴
            mapScale = SCALE_STANDARD_NEST
        end
    else
        --建筑详情或升级
        local confId = BuildModel.FindByPos(pos).ConfId
        if confId == Global.BuildingCenter then
            --指挥中心
            mapScale = SCALE_STANDARD_CENTER
        elseif confId == Global.BuildingWall then
            --城墙
            mapScale = SCALE_STANDARD_WALL
        elseif confId == Global.BuildingEquipMaterialFactory then
            --材料工厂
            mapScale = SCALE_STANDARD_EQUIPMATERIALMAKE
        elseif BuildModel.IsInnerOrBeast(confId) then
            --城内建筑或巨兽建筑
            mapScale = SCALE_STANDARD_INNER
        elseif Tool.Equal(BuildModel.GetBuildPosType(confId), Global.BuildingZoneWild) then
            --城外
            mapScale = SCALE_STANDARD_OUTER
        elseif Tool.Equal(BuildModel.GetBuildPosType(confId), Global.BuildingZoneNest) then
            mapScale = SCALE_STANDARD_NEST
        end
    end
    -- 移动
    local originScale = self._map.scale
    self._map.scale = Vector2(mapScale, mapScale)
    local ltgPos = self:GlobalToLocal(piece:LocalToGlobal(Vector2.zero))
    local offset = Vector2.zero
    local offsetY = 0
    if UIMgr:GetUIOpen("BuildRelated/BuildCreate") then
        local ui = UIMgr:GetUI("BuildRelated/BuildCreate")
        offsetY = ui._touchDesc.y - 280
    elseif UIMgr:GetUIOpen("BuildRelated/BuildUpgrade") then
        local ui = UIMgr:GetUI("BuildRelated/BuildUpgrade")
        offsetY = ui._touchDesc.y - 280
    elseif UIMgr:GetUIOpen("BuildRelated/BuildDetail") then
        local ui = UIMgr:GetUI("BuildRelated/BuildDetail")
        offsetY = ui._touchDesc.y - 280
    end
    if not piece.visible then
        --建筑详情或升级
        local confId = BuildModel.FindByPos(pos).ConfId
        if confId == Global.BuildingCenter then
            --指挥中心
            offset = Vector2(-180, 100)
        elseif confId == Global.BuildingWall then
            --城墙
            offset = Vector2(-100, 80)
        elseif confId == Global.BuildingGodzilla then
            --巢穴 哥斯拉
            offset = Vector2(-150, 180)
        elseif confId == Global.BuildingKingkong then
            --巢穴 金刚
            offset = Vector2(-150, 100)
        elseif confId == Global.BuildingEquipMaterialFactory then
            --装备材料生产
            offset = Vector2(0, 150)
        else
            offset = Vector2(-160, 30)
        end
    end
    local mvx = goalPos.x - ltgPos.x + offset.x
    local mvy = goalPos.y - ltgPos.y + offset.y + offsetY
    if isAnim then
        self._map:TweenMove(Vector2(mvx, mvy), SCALE_TIME):SetEase(EaseType.Custom)
        --缩放
        self._map.scale = originScale
        self:GtweenOnComplete(self._map:TweenScale(Vector2(mapScale, mapScale), SCALE_TIME):SetEase(EaseType.Custom),function()
            self:RefreshMap()
            self:SetTouchable()
            Event.Broadcast(EventDefines.CityMask, false)
        end)
    else
        self._map.xy = Vector2(mvx, mvy)
        self._map.scale = Vector2(mapScale, mapScale)
        self:RefreshMap()
        self:SetTouchable()
        Event.Broadcast(EventDefines.CityMask, false)
    end
end

function CityMap:OutCityScale()
    CSCoroutine.Start(
        function()
            local originScale = self._map.scale.x
            local scaleValue = originScale * 0.015
            for i = 1, 20 do
                coroutine.yield()
                local toScale = originScale - scaleValue * i
                self:ScaleMap(toScale, true)
                self:CheckCameraMoveBorder()
            end
            self._map:SetScale(SCALE_DEFAULT, SCALE_DEFAULT)
            self:SetDialogScale()
            self.scaleValue = SCALE_DEFAULT
            self.lastScale = self.scaleValue
        end
    )
end

--强制停止播放地图缩放和移动动画
function CityMap:ForceStop()
    if self.isMoveScale then
        self._map.xy = Vector2.zero
        local scale = self.lastScaleValue
        local piece = self.lastScalePiece
        self:SetScreenDeviation(scale)
        self:MoveMap(piece.x, piece.y)
        self.scaleValue = scale
    else
        self._map.xy = Vector2.zero
        self._map.scale = Vector2(self.lastScale, self.lastScale)
    end
    GTween.Kill(self._map)
    self.isCamera = false
    self.giveUpCloseScale = false
    self.isMapCityScaling = false
    self.isMoveScale = false
    self:RefreshMap()
    self:OnScrollMap()
    Event.Broadcast(EventDefines.CityMask, false)
end

function CityMap:GiveUpCloseScale()
    self.giveUpCloseScale = true
end

function CityMap:SetLastScale(pos)
    local piece = self._map:GetMapPiece(pos)
    self.isMoveScale = true
    self.lastScaleValue = self.lastScale
    self.lastScalePiece = piece
end

function CityMap:OnCancelScale(isAnim)
    if self.isMapCityScaling then
        self.giveUpCloseScale = false
        return
    end
    if not self.isCamera then
        self.giveUpCloseScale = false
        return
    end
    self.isCamera = false
    if GTween.IsTweening(self._map) then
        Log.Error("----------------------------------------------------重复调用OnCancelScale,{0}",isAnim)
        -- GTween.Kill(self._map)
        -- self:SetMapScaleValue(self.lastScale)
        -- self:RefreshMap()
        -- self:SetTouchable()
        -- self:DoCb()
        -- Event.Broadcast(EventDefines.CityMask, false)
        return
    else
        GTween.Kill(self._map)
    end

    if self.isMoveScale then
        self.giveUpCloseScale = false
        self.isMoveScale = false
        self.isMapCityScaling = true
        if self.lastScale == self.lastScaleValue then
            if ScrollModel.MoveDir then
                ScrollModel.LRMove(1, false)
                self:GtweenOnComplete(self._map:TweenFade(1, 0.01),function()
                    self:OnCancelScaleAnim()
                end)
            else
                self:OnCancelScaleAnim()
            end
            return
        end
        if GlobalVars.IsTriggerStatus or GlobalVars.IsNoviceGuideStatus then
            self:OnCancelScaleAnim()
            return
        end
        self:OnCancelScaleR()
        return
    end

    if isAnim then
        --播放缩放动画
        if self.giveUpCloseScale then
            self.giveUpCloseScale = false
            return
        end
        self.isMapCityScaling = true
        self:OnCancelScaleAnim()
    else
        --不播放缩放动画
        self.giveUpCloseScale = false
        self._map.xy = Vector2.zero
        self._map.scale = Vector2(self.lastScale, self.lastScale)
        self:RefreshMap()
    end
end

--取消移动 带动画
function CityMap:OnCancelScaleAnim()
    if self.lastScale == self._map.scale.x then
        self:RefreshMap()
        self:SetTouchable()
        self:DoCb()
        return
    end
    -- Event.Broadcast(EventDefines.CityMask, true)
    self._map:TweenMove(Vector2.zero, SCALE_TIME):SetEase(EaseType.Custom)
    self:GtweenOnComplete(self._map:TweenScale(Vector2(self.lastScale, self.lastScale), SCALE_TIME):SetEase(EaseType.Custom),function()
        self:RefreshMap()
        self:SetTouchable()
        self:DoCb()
        Event.Broadcast(EventDefines.CityMask, false)
    end)
end

--取消移动 缩放
function CityMap:OnCancelScaleR()
    --缩放还原
    Event.Broadcast(EventDefines.CityMask, true)
    self._map.xy = Vector2.zero
    local originScale = Vector2(self.lastScale, self.lastScale)
    local scale = self.lastScaleValue
    local piece = self.lastScalePiece
    local confId = self.lastScaleConfig
    local goalPos = Vector2(self.width / 2, self.height / 2)
    -- 移动
    self._map.scale = Vector2(scale, scale)
    local ltgPos = self:GlobalToLocal(piece:LocalToGlobal(Vector2.zero))
    if confId == Global.BuildingCenter then
        --指挥中心
        ltgPos = Vector2(ltgPos.x + BuildType.OFFSET_CENTER.x, ltgPos.y + BuildType.OFFSET_CENTER.y)
    elseif confId == Global.BuildingWall then
        --城墙
        ltgPos = Vector2(ltgPos.x + BuildType.OFFSET_WALL.x, ltgPos.y + BuildType.OFFSET_WALL.y)
    elseif confId == Global.BuildingBridge then
        --桥头建筑（在线领奖）
        ltgPos = Vector2(ltgPos.x + BuildType.OFFSET_BRIDGE.x, ltgPos.y + BuildType.OFFSET_BRIDGE.y)
    elseif confId == Global.BuildingGodzilla then
        --巢穴 哥斯拉
        ltgPos = Vector2(ltgPos.x + BuildType.OFFSET_GODZILLA.x, ltgPos.y + BuildType.OFFSET_GODZILLA.y)
    elseif confId == Global.BuildingKingkong then
        --巢穴 金刚
        ltgPos = Vector2(ltgPos.x + BuildType.OFFSET_KINGKONG.x, ltgPos.y + BuildType.OFFSET_KINGKONG.y)
    end
    local mvx = goalPos.x - ltgPos.x
    local mvy = goalPos.y - ltgPos.y
    self._map:TweenMove(Vector2(mvx, mvy), SCALE_TIME):SetEase(EaseType.Custom)
    --缩放
    self._map.scale = originScale
    self:GtweenOnComplete(self._map:TweenScale(Vector2(scale, scale), SCALE_TIME):SetEase(EaseType.Custom),function()
        self._map.xy = Vector2.zero
        self:SetScreenDeviation(scale)
        if confId == Global.BuildingCenter then
            --指挥中心
            self:MoveMap(piece.x + BuildType.OFFSET_CENTER.x, piece.y + BuildType.OFFSET_CENTER.y)
        elseif confId == Global.BuildingWall then
            --城墙
            self:MoveMap(piece.x + BuildType.OFFSET_WALL.x, piece.y + BuildType.OFFSET_WALL.y)
        elseif confId == Global.BuildingBridge then
            --桥头建筑（在线领奖）
            self:MoveMap(piece.x + BuildType.OFFSET_BRIDGE.x, piece.y + BuildType.OFFSET_BRIDGE.y)
        elseif confId == Global.BuildingGodzilla then
            --巢穴 哥斯拉
            self:MoveMap(piece.x + BuildType.OFFSET_GODZILLA.x, piece.y + BuildType.OFFSET_GODZILLA.y)
        elseif confId == Global.BuildingKingkong then
            --巢穴 金刚
            self:MoveMap(piece.x + BuildType.OFFSET_KINGKONG.x, piece.y + BuildType.OFFSET_KINGKONG.y)
        else
            self:MoveMap(piece.x, piece.y)
        end
        self.scaleValue = scale
        self:SetTouchable()
        Event.Broadcast(EventDefines.CityMask, false)
    end)
end

--中远景初始化
function CityMap:InitMiddleVisionShot()
    --天空
    self._sky = UIMgr:CreateObject("City", "Sky")
    self._sky.xy = Vector2(0, 0)
    self._sky.sortingOrder = 2
    self._map._shot:AddChild(self._sky)
    --远山
    self._mountainFar = UIMgr:CreateObject("City", "MountainFar")
    self._mountainFar.xy = Vector2(1345, 330)
    self._mountainFar.sortingOrder = 3
    self._map._shot:AddChild(self._mountainFar)
    --近山
    self._mountain = UIMgr:CreateObject("City", "Mountain")
    self._mountain.xy = Vector2(0, 0)
    self._mountain.sortingOrder = 4
    self._map._shot:AddChild(self._mountain)
    self._mountain.fairyBatching = true
end

local SHOT_TYPE = {
    Sky = 1,
    MountainFar = 2,
    Mountain = 3
}
function CityMap:GetShotMovePosX(shotType)
    if shotType == SHOT_TYPE.Mountain then
        return 0.4 * self.scrollPane.posX / self._map.scale.x * GlobalVars.ScreenRatio.x
    end
    if shotType == SHOT_TYPE.MountainFar then
        return 0.5 * self.scrollPane.posX / self._map.scale.x * GlobalVars.ScreenRatio.x + 400
    end
    if shotType == SHOT_TYPE.Sky then
        return 0.6 * self.scrollPane.posX / self._map.scale.x * GlobalVars.ScreenRatio.x
    end
end
function CityMap:OnScrollMap()
    self._mountain:InvalidateBatchingState()
    self._map:InvalidateBatchingState()
    if self.isMapCityMoving then
        if self.isScrollMoving then
            return
        end
        self.isScrollMoving = true
        local t = 0.5
        self:GtweenOnComplete(self._sky:TweenMoveX(self:GetShotMovePosX(SHOT_TYPE.Sky), t + 0.2),function()
            self.isScrollMoving = false
            self._mountain.x = self:GetShotMovePosX(SHOT_TYPE.Mountain)
            self._sky.x = self:GetShotMovePosX(SHOT_TYPE.Sky)
            self._mountainFar.x = self:GetShotMovePosX(SHOT_TYPE.MountainFar)
        end)
        self._mountain:TweenMoveX(self:GetShotMovePosX(SHOT_TYPE.Mountain), t)
        self._mountainFar:TweenMoveX(self:GetShotMovePosX(SHOT_TYPE.MountainFar), t)
    else
        if self.isScrollMoving then
            self.isScrollMoving = false
            GTween.Kill(self._sky)
            GTween.Kill(self._mountain)
            GTween.Kill(self._mountainFar)
        end
        self._sky.x = self:GetShotMovePosX(SHOT_TYPE.Sky)
        self._mountain.x = self:GetShotMovePosX(SHOT_TYPE.Mountain)
        self._mountainFar.x = self:GetShotMovePosX(SHOT_TYPE.MountainFar)
    end
end

function CityMap:ScreenShock()
    Event.Broadcast(EventDefines.Mask, true)
    self:GtweenOnComplete(self:TweenMove(Vector2(5, 5), 0.05), function()
        self:GtweenOnComplete(self:TweenMove(Vector2(0, 0), 0.05), function()
            Event.Broadcast(EventDefines.Mask, false)
        end)
    end)
end


--初始化对话框
function CityMap:InitDialog()
    local parentNode = self._map[CityType.CITY_MAP_NODE_TYPE.Dialog.name]
    local dialogNode = _G.UIMgr:CreateObject("Common", "ItemDialog")
    if not dialogNode then
        Log.Error("加载ItemDialog失败")
        return
    end
    
    dialogNode:SetVisible(false)
    parentNode:AddChild(dialogNode)
    DialogModel.Check(dialogNode)
    self._dialogNode = dialogNode
end

--大兵是否显示在屏幕中间
function CityMap:CheckSolderShowScreen(cb)
    local soldierNode = self._map:GetChild("Soldier")
    if not soldierNode then
        return
    end

    local num = soldierNode.numChildren
    if num < 1 then
        return
    end

    if num == 1 then
        cb(soldierNode:GetChildAt(0))
        return
    end

    local randomArray = Tool.ShuffleArray(soldierNode.numChildren)
    for _, v in pairs(randomArray) do
        local node = soldierNode:GetChildAt(v - 1)
        if node and node["i"] and node["i"] == 1 then
            cb(node)
            return
        end
    end
    
    return
end

function CityMap:ResetCharacterState()
    local soldierNode = self._map[CityType.CITY_MAP_NODE_TYPE.Soldier.name]
    if soldierNode then
        for i = 1, soldierNode.numChildren do
            local node = soldierNode:GetChildAt(i - 1)
            local anim = node["anim"]
            local animState = node["state"]
            if anim and animState then
                anim:Play(animState)
            end
        end
    end

    local workerNode = self._map[CityType.CITY_MAP_NODE_TYPE.Worker.name]
    if workerNode then
        for i = 1, workerNode.numChildren do
            local node = workerNode:GetChildAt(i - 1)
            local anim = node["anim"]
            local animState = node["state"]
            if anim and animState then
                anim:Play(animState)
            end
        end
    end 
end

return CityMap
