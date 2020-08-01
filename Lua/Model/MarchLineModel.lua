--[[
    author:{zhanzhang}
    time:2019-06-24 14:44:21
    function:{行军路线model}
]]
local MarchLineModel = {}

local MapModel = import("Model/MapModel")
local RelationEnum = import("Enum/RelationEnum")

local rootNode
local startX = 0
local startY = 0
local stopX = 0
local stopY = 0
local nowCount = 0
local colorList
local marchCacheList = {}
local mapAttackCache = {}
--进攻中缓存的行军路线
local MapAttackLine = {}
--集结进攻的行军路线
local MapUnionAttackLine = {}

local MapHideOtherAISeige = {}

function MarchLineModel.InitPool()
    CSCoroutine.Start(
        function()
            coroutine.yield(ObjectPoolManager.Instance:CreatePool("MarchRoute", 1, "prefabs/marchroute"))
        end
    )
end
function MarchLineModel.SetMarchRoot(parentNode)
    rootNode = parentNode.transform
end

--创建和刷新行军路线
function MarchLineModel.OnRefresh(list)
    local info
    for _, MarchLine in pairs(list) do
        info = marchCacheList[MarchLine.Uuid]

        if (not info or info.IsReturn ~= MarchLine.IsReturn) then
            MarchLineModel.CreateLine(MarchLine)
        elseif info.FinishAt ~= MarchLine.FinishAt then
            MarchLineModel.CreateLine(MarchLine)
        end
    end
end
--创建单条路线
function MarchLineModel.CreateLine(data)
    if not data.StartPointSize or not data.StopPointSize then
        Log.Error("出错了")
    end
    local startX, startY, stopX, stopY = MapModel.GetMarchPoint(data)
    local speedVal = 0
    local speed = MathUtil.GetDistance(stopX - startX, stopY - startY) / (data.FinishAt - data.CreatedAt)
    if marchCacheList[data.Uuid] then
        if data.FinishAt ~= marchCacheList[data.Uuid].FinishAt then
            local render = marchCacheList[data.Uuid].lineRender
            speedVal = MarchLineModel.GetLineSpeed(speed)
            local prop = MaterialPropertyBlock()
            render:GetPropertyBlock(prop)
            prop:SetFloat("_ScrollX", -speedVal)
            render:SetPropertyBlock(prop)
        end

        return
    end
    local lineInfo = {}
    local obj = ObjectPoolManager.Instance:Get("MarchRoute")

    obj.transform.parent = rootNode
    local render = obj:GetComponent("SpriteRenderer")

    render.enabled = true

    local xDistance, yDistance = stopX - startX, stopY - startY
    local xDiff, yDiff = startX + xDistance / 2, startY + yDistance / 2

    render.transform.localPosition = CVector3(xDiff, 0, yDiff)

    local fromVector = CVector3(xDistance, 0, yDistance)
    render.size = CS.UnityEngine.Vector2(fromVector.magnitude, render.size.y)

    local angle = CVector3.Angle(fromVector, CVector3.right)
    local isForward = (CVector3.Dot(CVector3.up, CVector3.Cross(fromVector, CVector3.left)) > 0 and 1 or -1)

    render.transform.localEulerAngles = CVector3(-90, isForward * angle, 0)
    speedVal = MarchLineModel.GetLineSpeed(speed)
    local color = MarchLineModel.GetLineColor(data)
    -- render.material:SetColor("_MainColor", color)
    local prop = MaterialPropertyBlock()
    render:GetPropertyBlock(prop)
    prop:SetColor("_MainColor", color)
    prop:SetFloat("_ScrollX", -speedVal)
    -- print("speedVal  " .. speedVal)
    render:SetPropertyBlock(prop)

    data.lineRender = render
    marchCacheList[data.Uuid] = data
end

function MarchLineModel.GetMarchLine(eventId)
    return marchCacheList[eventId]
end

--删除行军路线
function MarchLineModel.DelMarchLine(key)
    if MapAttackLine[key] then
        local line = MapAttackLine[key]
        if line.AllianceBattleId ~= "" and MapUnionAttackLine[line.AllianceBattleId] then
            MapUnionAttackLine[line.AllianceBattleId][line.Uuid] = nil
        end
        MapAttackLine[key] = nil
    end

    if not marchCacheList[key] then
        return
    end

    local render = marchCacheList[key].lineRender
    render.enabled = false
    ObjectPoolManager.Instance:Release("MarchRoute", render.gameObject)
    marchCacheList[key] = nil
end

--检测行军路线是否应该回收
function MarchLineModel.CheckRectMarchLine(posX, posY)
    for k, v in pairs(marchCacheList) do
        --超出界面需要回收
        if (MathUtil.PointToLineDistance(posX, posY, v.StartX, v.StartY, v.StopX, v.StopY) > 10) then
            if not v.IsCustomEvent then
                MarchLineModel.DelMarchLine(v.Uuid)
            end
        end
    end
end

function MarchLineModel.GetLineColor(data)
    if not colorList then
        colorList = {}
        --白色代表中立
        colorList[RelationEnum.Neutrality] = CS.UnityEngine.Color(1, 1, 1, 1)
        --蓝色代表盟友
        colorList[RelationEnum.Ally] = CS.UnityEngine.Color(70 / 255, 182 / 255, 237 / 255, 1)
        --红色代表敌人
        colorList[RelationEnum.Enemy] = CS.UnityEngine.Color(197 / 255, 45 / 255, 27 / 255, 1)
        --色代表自己
        colorList[RelationEnum.Oneself] = CS.UnityEngine.Color(49 / 255, 179 / 255, 43 / 255, 1)
    end
    local relation = MapModel.CheckMarchRouteStatus(data)
    --是否是特殊自定义事件
    if data.IsCustomEvent and (data.IsCustomEvent == 1002 or data.IsCustomEvent == 1003 or data.IsCustomEvent == 1004) then
        relation = RelationEnum.Ally
    end

    return colorList[relation]
end

function MarchLineModel.GetLineSpeed(speed)
    local val = Global.MarchLineSpeedMin + speed * Global.MarchLineSpeedScale * Global.MarchSpeedParamK1
    return math.min(val, Global.MarchLineSpeedMax)

    -- MarchLineSpeedMin = 0.1,
    -- MarchLineSpeedMax = 10.0,
    -- MarchLineSpeedScale = 0.1
end

function MarchLineModel.CacheAttackLine(line)
    MapAttackLine[line.Uuid] = line
    if line.AllianceBattleId ~= "" then
        if not MapUnionAttackLine[line.AllianceBattleId] then
            MapUnionAttackLine[line.AllianceBattleId] = {}
        end
        MapUnionAttackLine[line.AllianceBattleId][line.Uuid] = true
    end
end

function MarchLineModel.GetMarchAttackAnimFinish(key, allianceBattleId)
    local lineList = {}
    if allianceBattleId ~= "" then
        local list = MapUnionAttackLine[allianceBattleId]
        if not list then
            return lineList
        end
        for k, v in pairs(list) do
            table.insert(lineList, MapAttackLine[k])
        end
        MapUnionAttackLine[allianceBattleId] = nil
    else
        if MapAttackLine[key] then
            table.insert(lineList, MapAttackLine[key])
        end
    end

    return lineList
end

function MarchLineModel.DelAll()
    for key, _ in pairs(marchCacheList) do
        MarchLineModel.DelMarchLine(key)
    end
    MapAttackLine = {}
    MapUnionAttackLine = {}
end

return MarchLineModel
