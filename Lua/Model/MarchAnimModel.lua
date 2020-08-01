--[[
    author:{zhanzhang}
    time:2019-12-26 15:57:08
    function:{大地图行军动画}
    --行军流程步骤
    --1、创建空对象（用于放置所有兵）
    --2、将空对象置于目前起点（需要计算当前行军是否从起点开始）
    --3、根据行军类型获取相关配置信息
    --4、从对象池获取兵种对象，置于空对象的规定位置
    --5、使用dotween移动空对象
    --6、开始移动时根据兵种处理显示关系 （待调整）如果行军不是从起点开始，不用显示显隐关系
    --7、移动到指定位置前面进行变阵处理
    --8、变阵完毕后执行显示动画
    --9、执行攻击动画(目前播放3轮)
    --10、创建攻击特效   （尚无资源）
    --11、攻击完毕，执行回城动画------------------------------------------------------
]]
---
--特殊情况1、具体不够的情况下不播放行军动画，直接展开进攻动画，
--marchInfo 数据结构
-- Cache
-- SpineCache
-- TweenCache
-- GameObjectCache
-- Data
--原始数据
--BaseInfo
--根据配置计算的基础信息
--MarchState
--行军状态

--
-----
local MarchAnimModel = {}
local MissionEventModel = import("Model/MissionEventModel")
local MarchLineModel = import("Model/MarchLineModel")
local MapModel = import("Model/MapModel")
local DOTween = CS.DG.Tweening.DOTween
--------缓存---------------

local MarchInfoList = {}
local MarchParentNode

local MarchAttackList = {}
local MarchAllianceBattleList = {}

local MapMonsterList = {}

local DotweenCache = {}
local lookAtUuid

--路线点位缓存
local AnimRota = CVector3(30, -135, 0)
local RecyclePos = CVector3(10000, 1000, 10000)
local MarchState = {
    Normal = 1,
    SpeedUp = 2,
    Recall = 3
}
local MarchAnimState = {
    Create = 1,
    Show = 2,
    Move = 3,
    WaitAttack = 4,
    Attack = 5,
    Recycle = 6
}
local MarchAnimPrefabIndex = {
    Empty = 300101,
    MarchAnim_Scout = 300102,
    MarchAnim_Mine = 300103,
    MarchAnim_Tank = 300104,
    MarchAnim_Chariot = 300105,
    MarchAnim_Plane = 300106,
    MarchAnim_Truck = 300107,
    MarchAnim_AISiege = 300108,
    MarchAnim_Falcon = 300109,
    MarchAnim_Godzilla = 301101,
    MarchAnim_Kingkong = 302101
}

-----------------

function MarchAnimModel.InitMarchPool()
    CSCoroutine.Start(
        function()
            for k, v in pairs(MarchAnimPrefabIndex) do
                local resConfig = ConfigMgr.GetItem("configResourcePaths", v)
                coroutine.yield(ObjectPoolManager.Instance:CreatePool(resConfig.name, 1, resConfig.resPath))
            end
        end
    )
    DOTween.defaultEaseType = _G.CS.DG.Tweening.Ease.Linear
    Event.AddListener(
        EventDefines.GameReStart,
        function()
            for i = 1, #DotweenCache do
                if DotweenCache[i] then
                    DotweenCache[i]:Kill()
                end
            end
        end
    )
end
function MarchAnimModel.SetMarchRoot(parentNode)
    MarchParentNode = parentNode.transform
end

function MarchAnimModel.OnRefresh(data)
    for _, v in pairs(data) do
        MarchAnimModel.CreateRoute(v)
    end
end

--通过Id获取MarchInfo
function MarchAnimModel.GetMarchInfo(id)
    return MarchInfoList[id]
end
function MarchAnimModel.GetMarchInfoList()
    return MarchInfoList
end

--构建行军路线信息
function MarchAnimModel.CreateRoute(data)
    if not data.StartPointSize or not data.StopPointSize then
        Log.Error("出错了")
    end
    --判断行军动画已经创建过
    local marchState = MarchState.Normal
    if MarchInfoList[data.Uuid] then
        local info = MarchInfoList[data.Uuid]
        if info.data.Category == data.Category then
            if info.data.IsReturn ~= data.IsReturn then
                marchState = MarchState.Recall
            elseif info.data.FinishAt ~= data.FinishAt then
                marchState = MarchState.SpeedUp
            else
                return
            end
        end
    end
    MarchAnimModel.PlayAnim(data, marchState)
    MissionEventModel.IsRallyNow()
end

function MarchAnimModel.BeginAttackAnim(rsp)
    local marchInfo = MarchInfoList[rsp.EventId]
    if not marchInfo then
        return
    end
    if marchInfo.data.AllianceBattleId ~= "" then
        MarchAllianceBattleList[marchInfo.data.AllianceBattleId] = true
    else
        MarchAttackList[rsp.EventId] = true
    end
    marchInfo.isEnterAttackState = true
    marchInfo.isWin = rsp.IsWin
    if marchInfo.data.Category == Global.MissionAISiege then
        --黑骑士战斗
        MarchAnimModel.PlayAISiegeAnim(marchInfo)
    else
        --正常战斗需要调整阵形
        MarchAnimModel.EnterAttackState(marchInfo)
    end
end
------------------------------------------------------------------动画实现部分
local marchType = {
    [Global.MissionSpy] = MarchAnimPrefabIndex.MarchAnim_Scout,
    [Global.MissionVisit] = MarchAnimPrefabIndex.MarchAnim_Scout,
    [Global.MissionHunt] = MarchAnimPrefabIndex.MarchAnim_Falcon,
    [Global.MissionMining] = MarchAnimPrefabIndex.MarchAnim_Mine,
    [Global.MissionResStore] = MarchAnimPrefabIndex.MarchAnim_Mine,
    [Global.MissionResAssist] = MarchAnimPrefabIndex.MarchAnim_Mine,
    [Global.MissionAISiege] = MarchAnimPrefabIndex.MarchAnim_AISiege
}

function MarchAnimModel.PlayAnim(data, marchState)
    -- 判断行军路线是否已经创建，防止切屏导致频繁回收
    --to do 判断特殊情况 是否加速
    --to do 判断目标点距离出发点距离
    local prefabInfo
    if marchType[data.Category] then
        prefabInfo = ConfigMgr.GetItem("configResourcePaths", marchType[data.Category])
        MarchAnimModel.CreateMarchTween(data, prefabInfo, marchState)
    elseif (data.Category == Global.MissionAttack and data.TargetMapType == Global.MapTypeMine) then
        prefabInfo = ConfigMgr.GetItem("configResourcePaths", MarchAnimPrefabIndex.MarchAnim_Mine)
        MarchAnimModel.CreateMarchTween(data, prefabInfo, marchState)
    else
        MarchAnimModel.CreateAttackMarchAnim(data, marchState)
    end

    if lookAtUuid and not GlobalVars.IsInCity then
        Event.Broadcast(EventDefines.WorldMapClickMarch, lookAtUuid)
        lookAtUuid = nil
    end
end

--创建一般行军——采矿，侦查
function MarchAnimModel.CreateMarchTween(data, prefabInfo, marchState)
    local startX, startY = MissionEventModel.GetReturnPoint(data)
    if startX < 0.01 or startY < 0.01 then
        return
    end

    local animObj
    local marchInfo

    MarchInfoList = MarchInfoList or {}
    if marchState == MarchState.Recall then
        marchInfo = MarchInfoList[data.Uuid]
        marchInfo.IsReturn = data.IsReturn
        animObj = marchInfo.unit
        marchInfo.marchTween:Kill()
    elseif marchState == MarchState.SpeedUp then
        marchInfo = MarchInfoList[data.Uuid]
        animObj = marchInfo.unit
        marchInfo.marchTween:Kill()
    else
        marchInfo = MissionEventModel.InitMarchInfo(data)
    end

    if not marchInfo.unit then
        animObj = ObjectPoolManager.Instance:Get(prefabInfo.name)
        marchInfo.unitName = prefabInfo.name
        marchInfo.unit = animObj
    end
    animObj:SetActive(true)
    marchInfo.data = data
    MarchInfoList[data.Uuid] = marchInfo

    local baseInfo = MarchAnimModel.GetMarchBaseInfo(data)
    -- if marchState == MarchState.Recall or marchState == MarchState.SpeedUp then
    -- startX, startY = MissionEventModel.GetReturnPoint(data)
    baseInfo.StartVec3 = CVector3(startX, 0, startY)
    --     Log.Error("进入初始化")
    -- end
    animObj.transform.localEulerAngles = AnimRota
    animObj.transform.parent = MarchParentNode
    animObj.transform.localPosition = baseInfo.StartVec3
    local anim = animObj:GetComponent("SkeletonAnimation")
    anim.skeleton:SetSlotsToSetupPose()
    anim.state:SetAnimation(0, "move_" .. baseInfo.Direct, true)
    marchInfo.marchTween = animObj.transform:DOLocalMove(baseInfo.StopVec3, data.FinishAt - Tool.Time()):SetEase(CS.DG.Tweening.Ease.Linear)

    marchInfo.marchTween:OnComplete(
        function()
            Event.Broadcast(EventDefines.WorldCloseClickUnit, marchInfo.data.Uuid)
            if marchInfo.data.Category ~= Global.MissionAISiege then
                MarchAnimModel.DelMarchAnim(marchInfo.data.Uuid, true)
            end
        end
    )
    table.insert(DotweenCache, marchInfo.marchTween)
    marchInfo.BaseInfo = baseInfo
    marchInfo.NowMarchState = MarchAnimState.Create
    MarchInfoList[data.Uuid] = marchInfo
end

function MarchAnimModel.CreateAttackMarchAnim(data, marchState)
    local delay = data.FinishAt - Tool.Time()
    if delay <= 0 then
        Log.Info("加速失败了")
    end
    --0无巨兽 1为哥斯拉 2为金刚
    local isExistMonster = 0
    for _, v in pairs(data.ArmyTypes) do
        if v == 620 then
            isExistMonster = 1
        elseif v == 621 then
            isExistMonster = 2
        end
    end
    local marchInfo
    local startX, startY
    local marchAnimRoot

    if marchState == MarchState.Recall or marchState == MarchState.SpeedUp then
        -- startX, startY = MissionEventModel.GetReturnPoint(data)
        marchInfo = MarchInfoList[data.Uuid]
        marchAnimRoot = marchInfo.unit
        marchInfo.data = data

        if marchInfo.marchTween then
            marchInfo.marchTween:Kill()
        end
    else
        marchInfo = MissionEventModel.InitMarchInfo(data)
        marchAnimRoot = ObjectPoolManager.Instance:Get("Empty")
        marchInfo.unitName = "Empty"
        MarchInfoList[data.Uuid] = marchInfo
    end
    --清除渐现动画
    if marchInfo.marchTween then
        marchInfo.marchTween:Kill()
    end
    if marchInfo.MarchShowTween then
        marchInfo.MarchShowTween:Kill()
    end

    local baseInfo = MarchAnimModel.GetMarchBaseInfo(data)
    MarchAnimModel.CalArmyPosList(baseInfo, data)
    -- if marchState == MarchState.Recall or marchState == MarchState.SpeedUp then
    startX, startY = MissionEventModel.GetReturnPoint(data)
    baseInfo.StartVec3 = CVector3(startX, 0, startY)
    -- end
    --建立行军动画信息池（防止多次创建以及信息变更）
    marchInfo.BaseInfo = baseInfo
    marchAnimRoot.transform.parent = MarchParentNode.transform
    marchAnimRoot.transform.localPosition = baseInfo.StartVec3

    marchInfo.unit = marchAnimRoot

    MarchInfoList[data.Uuid] = marchInfo

    ----------------------------------------大部队行军以及后续进攻动画
    marchInfo.marchTween =
        marchAnimRoot.transform:DOLocalMove(baseInfo.StopVec3, delay, false):SetEase(CS.DG.Tweening.Ease.Linear):OnComplete(
        function()
            Event.Broadcast(EventDefines.WorldCloseClickUnit, marchInfo.data.Uuid)
            if
                data.IsReturn or data.Category == Global.MissionRally or data.Category == Global.MissionAssit or data.Category == Global.MissionResStore or data.Category == Global.MissionCamp or
                    data.Category == Global.MissionExplore or
                    data.Category == Global.MissionAISiege or
                    data.Category == Global.MissionAssit
             then
                MarchAnimModel.DelMarchAnim(data.Uuid)
            end
        end
    )
    table.insert(DotweenCache, marchInfo.marchTween)
    if marchState == MarchState.Normal then
        MarchAnimModel.CreateArmySpine(marchInfo)
    end
    if baseInfo.IsShowAnim and marchState ~= MarchState.SpeedUp then
        MarchAnimModel.EnterMoveFlow(data.Uuid, baseInfo)
    else
        MarchAnimModel.MarchAnimChangeMove(marchInfo.data.Uuid, baseInfo)
    end
end
------------------------------------------------------------

-----------------------------------------------------行军进攻相关方法------------------------------------------------------------------------------------------------------------------

function MarchAnimModel.CreateArmySpine(marchInfo)
    local itemArmy
    local MarchSpineList = {}
    --只是缓存，方便回收
    local AnimCacheList = {}
    for k, itemArmy in pairs(marchInfo.BaseInfo.MovePosList) do
        for j = 1, #itemArmy do
            local soillder = ObjectPoolManager.Instance:Get(itemArmy[j].prefabName)
            if not AnimCacheList[itemArmy[j].prefabName] then
                AnimCacheList[itemArmy[j].prefabName] = {}
            end
            soillder.transform.parent = marchInfo.unit.transform
            soillder.transform.localEulerAngles = AnimRota
            soillder.transform.localPosition = RecyclePos
            if not MarchSpineList[k] then
                MarchSpineList[k] = {}
            end
            local spine = soillder.transform:GetComponent("SkeletonAnimation")
            -- spine.skeleton:SetSlotsToSetupPose()
            spine:ClearState()

            table.insert(MarchSpineList[k], soillder.transform)
            table.insert(AnimCacheList[itemArmy[j].prefabName], soillder)
        end
    end
    marchInfo.AnimCacheList = AnimCacheList
    marchInfo.MarchSpineList = MarchSpineList
end

--行军攻击进入战斗状态
function MarchAnimModel.EnterAttackState(marchInfo)
    if marchInfo.marchTween then
        marchInfo.marchTween:Kill()
    end
    local marchList = MarchInfoList[marchInfo.data.Uuid]
    local baseInfo = marchList.BaseInfo
    local list = {}
    if marchInfo.MarchShowTween then
        marchInfo.MarchShowTween:Kill()
    end
    marchInfo.unit.transform.localPosition = baseInfo.StopVec3
    -- print(dump(marchInfo.BaseInfo.AttackPosList))
    -- print(dump(marchInfo.MarchSpineList))
    for k, itemArmy in pairs(marchInfo.BaseInfo.AttackPosList) do
        for j = 1, #itemArmy do
            local obj = marchInfo.MarchSpineList[k][j]
            if not obj then
                return
            end
            MarchAnimModel.PlayAttackAnim(obj, itemArmy[j])
        end
    end

    Scheduler.ScheduleOnce(
        function()
            MarchAnimModel.FinishMarchAnim(marchInfo)
        end,
        6
    )

    --播放野怪受击动画
    if marchInfo.data.Category == Global.MissionPVE then
        local monsterPosNum = MathUtil.GetPosNum(marchInfo.data.StopX, marchInfo.data.StopY)
        local area = MapModel.GetArea(monsterPosNum)
        --如果野怪不在地图内不予播放爆炸动画
        if area and area.ConfId > 0 then
            local conf = ConfigMgr.GetItem("configMonsters", area.ConfId)
            if not conf then
                Log.Info("野怪配置查找失败  id==" .. area.Id .. " ConfId  " .. area.ConfId)
                MarchAnimModel.FinishMarchAnim(marchInfo)
                return
            end

            if conf and conf.monster_anim then
                marchInfo.isExistAnim = true
                local info = MapMonsterList[monsterPosNum]
                if not info then
                    Log.Info("MapMonsterList中找不到怪物信息 marchInfo.data.StopX  " .. marchInfo.data.StopX .. " marchInfo.data.StopY  " .. marchInfo.data.StopY)
                    MarchAnimModel.FinishMarchAnim(marchInfo)
                    return
                end
                Scheduler.ScheduleOnce(
                    function()
                        local info = MapMonsterList[monsterPosNum]
                        if not info then
                            return
                        end
                        info.SpineAnim.state:SetAnimation(0, info.AnimName .. "_attack", true)
                    end,
                    2
                )
                Scheduler.ScheduleOnce(
                    function()
                        local info = MapMonsterList[monsterPosNum]
                        if not info then
                            return
                        end
                        if marchInfo.isWin then
                            info.SpineAnim.state:SetAnimation(0, info.AnimName .. "_hit", false)
                        else
                            info.SpineAnim.state:SetAnimation(0, info.AnimName .. "_idle", false)
                        end
                        -- Event.Broadcast(EventDefines.)
                    end,
                    6
                )
            end
        else
            Log.Info("无法获取野怪位置信息，不予播放爆炸特效")
        end
    end
    --
end

function MarchAnimModel.FinishMarchAnim(marchInfo)
    MarchAttackList[marchInfo.data.Uuid] = nil
    if marchInfo.data.AllianceBattleId ~= "" then
        MarchAllianceBattleList[marchInfo.data.AllianceBattleId] = nil
    end
    MarchAnimModel.DelMarchAnim(marchInfo.data.Uuid)
    Event.Broadcast(EventDefines.WorldMarchAnimFinish, marchInfo.data)
end

--单个部队进入布阵状态
function MarchAnimModel.PlayAttackAnim(obj, attackPosInfo)
    local pointVec3 = CVector3(attackPosInfo.x, 0, attackPosInfo.y)
    if not obj then
        Log.Error("出错了")
    end

    local tempTween =
        obj.transform:DOLocalMove(pointVec3, 1.5, false):SetEase(CS.DG.Tweening.Ease.Linear):OnComplete(
        function()
            MarchAnimModel:MarchAnimChangeBattle(obj, attackPosInfo.attackDirect)
        end
    )
    table.insert(DotweenCache, tempTween)
end

--单个兵切换战斗状态
function MarchAnimModel:MarchAnimChangeBattle(obj, direct)
    local sp = obj:GetComponent("SkeletonAnimation")
    -- sp:ClearState()
    -- sp.state:SetAnimation(0, "show_" .. direct, false)
    Scheduler.ScheduleOnceFast(
        function()
            sp:ClearState()
            sp.state:SetAnimation(0, "attack_" .. direct, true)
        end,
        0.3
    )
end
local isExistMonster = true
function MarchAnimModel.EnterMoveFlow(id, baseInfo)
    local marchInfo = MarchInfoList[id]
    if not marchInfo then
        Log.Warning("警告~~~~~~~~~~，未找到对应行军缓存")
        return
    end

    local marchList = marchInfo.MarchSpineList
    marchInfo.isCancel = false

    local delayTime = Global.MarchAnimationIntervalDistance / baseInfo.Speed
    if delayTime < 0.1 then
        Log.Info("间隔时间太小return")
        return
    end
    local delayTimes = {}
    local lastTime = 0
    for i = 1, #baseInfo.DelayDistances do
        delayTimes[i] = baseInfo.DelayDistances[i] / baseInfo.Speed + lastTime
        lastTime = delayTimes[i]
    end

    local index = 0
    local tempList = {}
    for k, val in pairs(marchList) do
        table.insert(tempList, val)
    end
    marchInfo.ShowIndex = 1
    marchInfo.MoveIndex = 1
    local index = 0
    marchInfo.MarchShowTween = DOTween.Sequence()
    for k, val in pairs(marchList) do
        index = index + 1
        marchInfo.MarchShowTween:InsertCallback(
            delayTimes[index - 1],
            function()
                for j = 1, #val do
                    local tran = val[j]
                    local posInfo = marchInfo.BaseInfo.MovePosList[k][j]
                    tran.localPosition = CVector3(posInfo.x, 0, posInfo.y)
                    local spine = tran:GetComponent("SkeletonAnimation")
                    spine:ClearState()
                    spine.state:SetAnimation(0, "show_" .. baseInfo.Direct, false)
                    local changeAnim = function()
                        spine:ClearState()
                        spine.state:SetAnimation(0, "move_" .. baseInfo.Direct, true)
                    end
                    Scheduler.ScheduleOnceFast(changeAnim, 0.7)
                end
            end
        )
    end
end

function MarchAnimModel.MarchAnimChangeMove(id)
    local marchInfo = MarchInfoList[id]
    if not marchInfo then
        Log.Error("变成移动状态失败 MarchAnimModel.MarchAnimChangeMove")
        return
    end
    local movePosList = marchInfo.BaseInfo.MovePosList
    local list = marchInfo.MarchSpineList
    for key, val in pairs(list) do
        for i = 1, #val do
            local posInfo = movePosList[key][i]
            local tran = list[key][i]
            local spine = tran:GetComponent("SkeletonAnimation")
            spine:ClearState()
            spine.state:SetAnimation(0, "move_" .. marchInfo.BaseInfo.Direct, true)
            tran.localPosition = CVector3(posInfo.x, 0, posInfo.y)
        end
    end
end

function MarchAnimModel.DelMarchAnim(Id, isMustDel)
    local marchLineInfo = MarchLineModel.GetMarchLine(Id)
    local marchInfo = MarchInfoList[Id]
    if not marchInfo then
        return
    end
    if MarchAnimModel.IsAttacking(marchInfo.data) then
        Log.Info("正在战斗中，不予删除")
        return
    end
    if marchInfo.MarchShowTween then
        marchInfo.MarchShowTween:Kill()
        Log.Info("成功kill sequeue")
    end
    if marchInfo.marchTween then
        marchInfo.marchTween:Kill()
    end
    if marchInfo.AnimCacheList then
        for k, v in pairs(marchInfo.AnimCacheList) do
            for i = 1, #v do
                ObjectPoolManager.Instance:Release(k, v[i])
            end
        end
    end

    ObjectPoolManager.Instance:Release(marchInfo.unitName, marchInfo.unit)
    MarchInfoList[Id] = nil
    Event.Broadcast(EventDefines.DelMarchAnim, Id)
end

function MarchAnimModel.DelAll()
    for key, _ in pairs(MarchInfoList) do
        MarchAnimModel.DelMarchAnim(key, true)
    end
end
------------------------------------------封装接口部分

--获取行军路线基础信息：1、方向 2、计算系数
function MarchAnimModel.GetMarchBaseInfo(data)
    local baseInfo = {}
    if data.StartPointSize == 0 or data.StopPointSize == 0 then
        Log.Error("出错了")
    end

    local startX, startY, stopX, stopY = MapModel.GetMarchPoint(data)

    baseInfo.Duration = data.Duration
    baseInfo.Direct = MathUtil.GetDirect(startX, startY, stopX, stopY)
    baseInfo.Angle = MathUtil.GetPointAngle(startX, startY, stopX, stopY) - 225
    baseInfo.DelayY = math.cos(math.rad(baseInfo.Angle))
    baseInfo.DelayX = math.sin(math.rad(baseInfo.Angle))

    local distance = MathUtil.GetDistance(startX, startY, stopX, stopY)
    local sizeVal = Global.MarchAnimationTargetDistance[data.StopPointSize]
    local vec = CVector3(stopX - startX, 0, stopY - startY)
    if not data.IsReturn and (data.Category == Global.MissionAttack or data.Category == Global.MissionPVE or data.Category == Global.MissionAISiege) then
        local stopV3 = vec.normalized * sizeVal
        baseInfo.StopX = stopX - stopV3.x
        baseInfo.StopY = stopY - stopV3.z
    else
        baseInfo.StopX = stopX
        baseInfo.StopY = stopY
    end

    ------行军路线的起点不一定是动画的起点,主要是地图刷新的路线
    local delayTime = Tool.Time() - data.CreatedAt
    baseInfo.AnimStartX = startX + (baseInfo.StopX - startX) / data.Duration * delayTime

    baseInfo.AnimStartY = startY + (baseInfo.StopY - startY) / data.Duration * delayTime
    --print("baseInfo.StopX  " .. baseInfo.StopX)
    --print("baseInfo.StopY   " .. baseInfo.StopY)
    --print("startX   " .. startX)
    --print(" startY " .. startY)
    --print("   data.Duration " .. data.Duration)

    baseInfo.StartVec3 = CVector3(baseInfo.AnimStartX, 0, baseInfo.AnimStartY)
    baseInfo.StopVec3 = CVector3(baseInfo.StopX, 0, baseInfo.StopY)
    local showAnimDistance = MathUtil.GetDistance(baseInfo.AnimStartX - startX, baseInfo.AnimStartY - startY)
    baseInfo.IsShowAnim = showAnimDistance < Global.MarchAnimationMinDistance and not data.IsReturn

    baseInfo.Distance = MathUtil.GetDistance(baseInfo.StopX - baseInfo.AnimStartX, baseInfo.StopY - baseInfo.AnimStartY)
    baseInfo.Speed = baseInfo.Distance / data.Duration
    baseInfo.SizeVal = sizeVal

    if data.Category == Global.MissionAISiege then
        baseInfo.EffectX = stopX + vec.normalized.x
        baseInfo.EffectY = stopY + vec.normalized.z
    end

    return baseInfo
end
--计算行军的一系列坐标
function MarchAnimModel.CalArmyPosList(baseInfo, data)
    local NowConfig = MarchAnimModel.GetMapQueueConfig(data.IsRally, data.ArmyTotal)
    local movePosList = {}
    local attackPosList = {}
    --判断是否有巨兽，如果有巨兽提前加入坐标列表
    local isExistMonster = 0
    local tempPosX = 0
    local tempPosY = 0
    local listIndex = 0
    local FirstLineWidth = 0

    for k, v in pairs(data.ArmyTypes) do
        if v == 620 then
            -- table.insert(baseInfo.DelayDistances, Global.GothDistance)
            isExistMonster = 1
        elseif v == 621 then
            isExistMonster = 2
        -- table.insert(baseInfo.DelayDistances, Global.KingkongDistance)
        -- else
        --     table.insert(baseInfo.DelayDistances, Global.ArmiesDistance)
        end
    end

    local delayY = math.cos(math.rad(baseInfo.Angle))
    local delayX = math.sin(math.rad(baseInfo.Angle))

    if isExistMonster > 0 then
        listIndex = 1
        local posInfo = {}
        local moveConfig
        local attackConfig
        local prefabName

        if isExistMonster == 1 then
            FirstLineWidth = Global.GargantuaQueueDistance
            moveConfig = NowConfig["goth_coord"]
            attackConfig = NowConfig["goth_attackcoord"]
            prefabName = MarchAnimModel.GetPrefabNameByName(MarchAnimPrefabIndex.MarchAnim_Godzilla).name
        elseif isExistMonster == 2 then
            FirstLineWidth = Global.KondolaQueueDistance
            moveConfig = NowConfig["kingkong_coord"]
            attackConfig = NowConfig["king_attackcoord"]
            prefabName = MarchAnimModel.GetPrefabNameByName(MarchAnimPrefabIndex.MarchAnim_Kingkong).name
        else
            Log.Error("没有此种情况，请检查错误")
        end
        movePosList[1] = {}
        attackPosList[1] = {}
        tempPosX = moveConfig.x * baseInfo.DelayY + moveConfig.y * baseInfo.DelayX
        tempPosY = moveConfig.y * baseInfo.DelayY - moveConfig.x * baseInfo.DelayX
        table.insert(movePosList[1], {x = tempPosX, y = tempPosY, prefabName = prefabName, list = 1})
        --根据目标点确定巨兽攻击范围
        local temp = attackConfig[data.StopPointSize]
        local monsterDirect = (temp.direct + baseInfo.Direct - 3 - 1) % 8 + 1
        tempPosX = temp.x * delayY + temp.y * delayX
        tempPosY = temp.y * delayY - temp.x * delayX

        table.insert(attackPosList[1], {x = tempPosX, y = tempPosY, list = 1, attackDirect = monsterDirect})
    end
    ---------------------------------------------------------

    -- for i = 1, 4 do
    --     local list = NowConfig["coord" .. i]
    --     for _, v in pairs(list) do
    --         if not movePosList[v.list + listIndex] then
    --             movePosList[v.list + listIndex] = {}
    --         end
    --         local posInfo = {}
    --         posInfo["prefabName"] = MarchAnimModel.GetPrefabNameByType(i).name

    --         posInfo.list = v.list + listIndex
    --         tempPosX = v.x
    --         tempPosY = v.y
    --         -- end
    --         if isExistMonster == 1 then
    --             tempPosX = tempPosX + Global.BeastGothArmyOffset.x
    --             tempPosY = tempPosY + Global.BeastGothArmyOffset.y
    --         elseif isExistMonster == 2 then
    --             tempPosX = tempPosX + Global.BeastKingArmyOffset.x
    --             tempPosY = tempPosY + Global.BeastKingArmyOffset.y
    --         else
    --             -- tempPosX = tempPosX + 0.8
    --             -- tempPosY = tempPosY - 0.8
    --         end

    --         posInfo.x = tempPosX * baseInfo.DelayY + tempPosY * baseInfo.DelayX
    --         posInfo.y = tempPosY * baseInfo.DelayY - tempPosX * baseInfo.DelayX
    --         table.insert(movePosList[v.list + listIndex], posInfo)
    --     end
    -- end

    local queueIndex = NowConfig.queue
    local configNew = ConfigMgr.GetList("configNewArmyQueues")

    local theta = -(baseInfo.Angle + 45)
    local st = math.sin(math.rad(theta))
    local ct = math.cos(math.rad(theta))

    local extraTheta = 135 - theta
    local aa = math.floor(extraTheta / 90)
    local bb = extraTheta % 90
    local extraRadians = aa % 2 == 0 and 90 - bb or bb
    local extra = math.sin(math.rad(extraRadians)) * 0.8 -- 由于角度原因,会在x方向做一定的偏移
    local zRate = 1 - math.sin(math.rad(extraRadians)) * 0.25
    local zOff = 0
    for _, v in ipairs(configNew) do
        if v.Queue == queueIndex then
            local currentLine = v.Row + listIndex
            movePosList[currentLine] = {}
            local val = v.Armynum
            local xOff = -(v.Armydistance * (1 + extra))
            local isOdd = val % 2 == 1
            local midIndex = math.ceil(val / 2)
            local lineWidth = v.Row == 1 and FirstLineWidth or v.Armylinewidth
            zOff = zOff + lineWidth * zRate
            for j = 1, val do
                local preX
                local preZ = zOff
                if isOdd then
                    preX = xOff * 2 * (midIndex - j)
                else
                    local offset = j <= midIndex and 0 or 1
                    local direct = j <= midIndex and 1 or -1
                    preX = xOff * 2 * (midIndex - j + offset) + direct * xOff
                end
                local realX = -preX * st + preZ * ct
                local realZ = preX * ct + preZ * st
                local posInfo = {x = realX, y = realZ}

                posInfo["prefabName"] = MarchAnimModel.GetPrefabNameByType(v.Armytype).name
                posInfo.list = currentLine
                table.insert(movePosList[currentLine], posInfo)
            end
        end
    end

    for i = 1, 4 do
        local configArmy = NowConfig["attackCoord" .. i]

        for k, v in pairs(configArmy) do
            if not attackPosList[v.list + listIndex] then
                attackPosList[v.list + listIndex] = {}
            end

            local attackPos = {}

            attackPos.list = v.list
            attackPos.x = (v.x - Global.MarchTargetOffset) * delayY + (v.y + Global.MarchTargetOffset) * delayX
            attackPos.y = (v.y + Global.MarchTargetOffset) * delayY - (v.x - Global.MarchTargetOffset) * delayX

            if isExistMonster > 0 then
                local backDistance
                if isExistMonster == 1 then
                    backDistance = Global.GothDistance
                elseif isExistMonster == 2 then
                    backDistance = Global.KingkongDistance
                end
                attackPos.x = attackPos.x + ct * backDistance
                attackPos.y = attackPos.y + st * backDistance
            end
            if not v.direct then
                Log.Error("报错拉")
            end
            attackPos.attackDirect = (v.direct + baseInfo.Direct - 3 - 1) % 8 + 1

            table.insert(attackPosList[v.list + listIndex], attackPos)
        end
    end
    baseInfo.MovePosList = movePosList
    baseInfo.AttackPosList = attackPosList

    baseInfo.DelayDistances = {}
    local startIndex = 2
    if isExistMonster == 1 then
        table.insert(baseInfo.DelayDistances, Global.GothDistance)
    elseif isExistMonster == 2 then
        table.insert(baseInfo.DelayDistances, Global.KingkongDistance)
    else
        startIndex = 1
    end
    for i = startIndex, #movePosList do
        table.insert(baseInfo.DelayDistances, Global.ArmiesDistance)
    end
end

--根据配置获取对应信息
function MarchAnimModel.GetMapQueueConfig(isRally, num)
    local config = ConfigMgr.GetList("configArmyQueues")
    local nowConfig
    for i = 1, #config do
        local v = config[i]
        if v.mass == isRally and v.range <= num then
            nowConfig = v
        elseif nowConfig and v.mass == isRally and v.range > num then
            return nowConfig
        end
    end
    return nowConfig
end

function MarchAnimModel.GetPrefabNameByType(index)
    local resId = 300103 + index
    return ConfigMgr.GetItem("configResourcePaths", resId)
end
function MarchAnimModel.GetPrefabNameByName(index)
    return ConfigMgr.GetItem("configResourcePaths", index)
end

function MarchAnimModel.IsAttacking(data)
    local isAttacking = false
    if data.AllianceBattleId ~= "" then
        if MarchAllianceBattleList[data.AllianceBattleId] then
            Log.Info("data.AllianceBattleId   " .. data.AllianceBattleId)
            return true
        end
    else
        return MarchAttackList[data.Uuid]
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------
function MarchAnimModel.RefreshMonsterPos(posNum, obj, confId)
    local spineAnim = obj:GetComponent("SkeletonAnimation")
    local temp = {}
    temp.SpineAnim = spineAnim
    temp.AnimName = "T" .. confId
    MapMonsterList[posNum] = temp
    -- print("MapMonsterList-------", table.inspect(MapMonsterList))
end

function MarchAnimModel.DelMapMonster(posNum)
    MapMonsterList[posNum] = nil
end

function MarchAnimModel.PlayMonsterAnim(posNum, animName, isLoop)
    local spine = MapMonsterList[posNum].SpineAnim
    if not spine then
        Log.Error("获取野怪受击动画失败，请程序检查bug")
        return
    end
    -- spine.skeleton:SetSlotsToSetupPose()
    spine:ClearState()
    spine.state:SetAnimation(0, animName, isLoop)
end

function MarchAnimModel.PlayAISiegeAnim(marchInfo)
    local animObj = marchInfo.unit
    if marchInfo.marchTween then
        marchInfo.marchTween:Kill()
    end
    local baseInfo = marchInfo.BaseInfo
    animObj.transform.localPosition = baseInfo.StopVec3

    DynamicRes.GetBundle(
        "effect_worldmap",
        function()
            DynamicRes.GetPrefab(
                "effect_worldmap",
                "effect_aiattack_anim",
                function(prefab)
                    local stopVec3 = CVector3(baseInfo.EffectX, 0, baseInfo.EffectY)
                    local tempTween = animObj.transform:DOLocalMove(stopVec3, 5, false)
                    local cache = {}
                    for i = 1, 5 do
                        Scheduler.ScheduleOnceFast(
                            function()
                                local obj = GameObject.Instantiate(prefab)
                                obj.transform.parent = MarchParentNode
                                cache[i] = obj
                                obj:SetActive(false)
                                local pos = animObj.transform.localPosition
                                obj.transform.localPosition = pos
                                obj:SetActive(true)
                                Scheduler.ScheduleOnceFast(
                                    function()
                                        ObjectUtil.Destroy(cache[i])
                                    end,3)
                            end,
                            (i + 1) * 0.5,
                            2
                        )
                    end
                    table.insert(DotweenCache, tempTween)
                    Scheduler.ScheduleOnce(
                        function()
                            for i = 1, 3 do
                                ObjectUtil.Destroy(cache[i])
                            end
                            MarchAttackList[marchInfo.data.Uuid] = nil
                            if marchInfo.data.AllianceBattleId ~= "" then
                                MarchAllianceBattleList[marchInfo.data.AllianceBattleId] = nil
                            end
                            MarchAnimModel.DelMarchAnim(marchInfo.data.Uuid)
                        end,
                        6
                    )
                end
            )
        end
    )
end

function MarchAnimModel.SetLookAt(uuid)
    lookAtUuid = uuid
end

function MarchAnimModel.ClearLookAt()
    lookAtUuid = nil
end

return MarchAnimModel

------------------------------------------
--[[播放需求：1、在进攻event结束时播放战斗动画，同时缓存战斗信息和状态
2、收到服务器返程消息后，检测缓存的战斗信息，如果有，先不显示，等待战斗播完后执行
3、判断一般类型用uuid, marchline isrally true 就判断集结类型使用allianceBattleId
]]
-----------------------------------------
