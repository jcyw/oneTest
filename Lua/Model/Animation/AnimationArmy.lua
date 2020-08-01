--[[
    Author: songzeming
    Function: 兵种动画
]]
--数值
local AnimationArmy = {}

local ArmyPool = import("Model/Animation/ArmyPool")
local ParadeSquareModel = import("Model/Animation/ParadeSquareModel")

local STATUS = false
local MOVE_SPEED = 100
--训练完成收集初始位置打点
local WAYS = {}
--生成路径
local function GeneraGPointWay(pos, confId)
    local conf = ConfigMgr.GetItem("configTrainArmyPoss", pos)
    local points = {}
    if confId == Global.BuildingHelicopterFactory then
        points[1] = conf.end_pos
        points[2] = conf.pos
    else
        for _, v in ipairs(WAYS[conf.way].pos) do
            table.insert(points, v)
            if conf.pos.x == v.x and conf.pos.y == v.y then
                break
            end
        end
    end
    return Tool.ReverseTable(points)
end
--获取士兵移动方向
local function GetMoveDirection(p1, p2, confId)
    local isHelicopter = confId == Global.BuildingHelicopterFactory
    if p1.x < p2.x then
        if p1.y < p2.y then
            if isHelicopter then
                return (p2.x - p1.x) * 2 > (p2.y - p1.y) and "right_down" or "down"
            else
                return "right_down"
            end
        else
            return "right_up"
        end
    else
        if p1.y < p2.y then
            if isHelicopter then
                return (p1.x - p2.x) * 2 > (p2.y - p1.y) and "left_down" or "down"
            else
                return "left_down"
            end
        else
            return "left_up"
        end
    end
end
--获取士兵转动方向和是否翻转
local function GetTurnDirection(p1, p2, p3)
    local preDir = GetMoveDirection(p1, p2)
    local nextDir = GetMoveDirection(p2, p3)
    local function gsub_func(dir)
        return string.gsub(dir, "_", "")
    end
    local function get_dir(reverse)
        return gsub_func(reverse and nextDir or preDir) .. "_" .. gsub_func(reverse and preDir or nextDir), reverse
    end
    if p2.x < p1.x and p2.y < p1.y and p2.x > p3.x and p2.y < p3.y then
        return get_dir(true)
    elseif p2.x > p1.x and p2.y < p1.y and p2.x > p3.x and p2.y > p3.y then
        return get_dir(true)
    elseif p2.x < p1.x and p2.y > p1.y and p2.x < p3.x and p2.y < p3.y then
        return get_dir(true)
    elseif p2.x > p1.x and p2.y > p1.y and p2.x < p3.x and p2.y > p3.y then
        return get_dir(true)
    else
        return get_dir(false)
    end
end
--获取士兵序列中图片数量
local function GetPictureNumber(confId)
    if confId == Global.BuildingTankFactory then
        return 7
    end
    if Tool.Equal(confId, Global.BuildingHelicopterFactory, Global.BuildingWarFactory) then
        return 6
    end
    if confId == Global.BuildingVehicleFactory then
        return 5
    end
end

local COLLECT_DELAY_TIME = 2 --收集士兵显示间隔时间
--训练完成收集动画
function AnimationArmy.PlayTrainCollectAnim(building, amount, confId, cb)
    STATUS = true
    if next(WAYS) == nil then
        WAYS = ConfigMgr.GetList("configTrainArmyWays")
    end
    local _map = CityMapModel.GetCityMap()
    local armyNode = _map[CityType.CITY_MAP_NODE_TYPE.CollectArmy.name]
    local helicopterNode = _map[CityType.CITY_MAP_NODE_TYPE.CollectHelicopter.name]
    local collect_num = math.ceil(amount / Global.TrainCollectArmyAmount)
    local limit_num = math.min(collect_num, Global.TrainCollectArmyAmountLimit)
    local function create_func(num)
        if not STATUS then
            return
        end
        if num <= limit_num then
            local image = ArmyPool.GetCollect()
            image:DefaultTypeset()
            local isHelicopter = building.ConfId == Global.BuildingHelicopterFactory
            if isHelicopter then
                helicopterNode:AddChild(image)
            else
                armyNode:AddChild(image)
            end
            image.xy = ConfigMgr.GetItem("configTrainArmyPoss", building.Pos).pos
            local order = limit_num - num
            image["order"] = order
            image.sortingOrder = image.y + order
            AnimationArmy.TrainArmyMove(image, building, confId, num == 1)
            image.alpha = 0
            image:TweenFade(1, 1)
            Scheduler.ScheduleOnce(
                function()
                    create_func(num + 1)
                end,
                COLLECT_DELAY_TIME
            )
        else
            cb()
        end
    end
    CSCoroutine.Start(
        function()
            coroutine.yield(UIMgr:AddPackage("MarchAnimation"))
            create_func(1)
        end
    )
end
--主城训练完成军队移动动画
function AnimationArmy.TrainArmyMove(node, building, armyId, isParadeShow)
    armyId = math.floor(armyId / 10) * 10
    local isHelicopter = building.ConfId == Global.BuildingHelicopterFactory
    local points = GeneraGPointWay(building.Pos, building.ConfId)
    local function move_func(k)
        if not STATUS then
            return
        end
        if k == #points then
            node:GetContext():GtweenOnComplete(node:TweenFade(0, 1), function()
                ArmyPool.SetCollect(node)
            end)
            if isParadeShow then
                ParadeSquareModel.ParadeSquareShow()
            end
            return
        end
        local point = points[k]
        local nextPoint = points[k + 1]
        --移动
        local function move_fc()
            if not STATUS then
                return
            end
            local dir = GetMoveDirection(point, nextPoint, building.ConfId)
            local idx = 0
            local function rotate_func()
                if not STATUS then
                    Scheduler.UnScheduleFast(rotate_func)
                    return
                end
                idx = idx == 1 and 2 or 1
                local imgName = "army_" .. armyId .. "_" .. dir .. "_" .. idx
                node:SetImage(UIPackage.GetItemURL("MarchAnimation", imgName))
            end
            if isHelicopter then
                --直升机有螺旋桨转动动画
                rotate_func()
                Scheduler.ScheduleFast(rotate_func, 0.02)
            else
                --其他部队没有
                node:SetImage(UIPackage.GetItemURL("MarchAnimation", "army_" .. armyId .. "_" .. dir))
            end
            local distance = MathUtil.GetDistanceByPos(point, nextPoint)
            local time = distance / MOVE_SPEED
            node:GetContext():GtweenOnComplete(node:TweenMove(nextPoint, time):SetEase(EaseType.Linear), function()
                Scheduler.UnScheduleFast(rotate_func)
                move_func(k + 1)
            end)
        end
        --转向动画
        if k == 1 then
            --初始没有转向动画
            move_fc()
        else
            node.sortingOrder = node.y + node["order"]
            local prePoint = points[k - 1]
            local dir, isReverse = GetTurnDirection(prePoint, point, nextPoint)
            local function turn_func(index)
                if not STATUS then
                    return
                end
                local imgName = "army_" .. armyId .. "_" .. dir .. "_" .. Tool.FormateNumberZero(index)
                local turnImg = UIPackage.GetItemURL("MarchAnimation", imgName)
                if not turnImg then
                    --转向完成 开始移动
                    move_fc()
                else
                    --转向
                    node:SetImage(turnImg)
                    Scheduler.ScheduleOnceFast(
                        function()
                            turn_func(isReverse and index - 1 or index + 1)
                        end,
                        0.05
                    )
                end
            end
            turn_func(isReverse and GetPictureNumber(building.ConfId) or 1)
        end
    end
    move_func(1)
end

function AnimationArmy.Clear()
    STATUS = false
    local _map = CityMapModel.GetCityMap()
    local armyNode = _map[CityType.CITY_MAP_NODE_TYPE.CollectArmy.name]
    local helicopterNode = _map[CityType.CITY_MAP_NODE_TYPE.CollectHelicopter.name]
    for i = armyNode.numChildren, 1, -1 do
        armyNode:GetChildAt(i - 1):Dispose()
    end
    for i = helicopterNode.numChildren, 1, -1 do
        helicopterNode:GetChildAt(i - 1):Dispose()
    end
    ArmyPool.ClearCollect()
end

return AnimationArmy
