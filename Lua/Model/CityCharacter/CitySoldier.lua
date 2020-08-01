--[[
    Author: songzeming
    Function: 大兵交互模板 动画
]]
local CitySoldier = {}

local Vector2 = _G.Vector2
local Vector3 = _G.Vector3
local MathUtil = _G.MathUtil
local GTween = _G.GTween
local EaseType = _G.EaseType
local Scheduler = _G.Scheduler
local ConfigMgr = _G.ConfigMgr
local CityType = _G.CityType
local GoWrapper = _G.GoWrapper
local Global = _G.Global
local GameObject = _G.GameObject
local ResMgr = _G.ResMgr
local DialogType = _G.GD.GameEnum.DialogType
local CityCharacter = import("Model/CityCharacter/CityCharacter")
local DialogModel = import("Model/Common/DialogModel")

local SoldierNode = nil
local SoldierOrderUpNode = nil
local WALK_MOVE_SPEED = 20 --行走移动速度
local OFFSET_POS = Vector2(20, 50)
local DIALOG_SORTING_ORDER = 10000
--大兵巡逻位置
local SOLDIER_POINT = {}

--特殊层级
local function SpecialOrder(node, special, index)
    if special == 1 then
        if index <= 3 or index >= 12 or index == 7 then
            SoldierOrderUpNode:AddChild(node)
        else
            SoldierNode:AddChild(node)
        end
    elseif special == 2 then
        SoldierOrderUpNode:AddChild(node)
    end
end
--一队列大兵移动完成 检测是否统一方向
local function CheckDirection(key)
    local info = SOLDIER_POINT[key]
    local dir
    local same = true
    for _, node in ipairs(info.SoldierArr) do
        local np = node["next_pos"]
        if not dir then
            dir = np
        else
            if not np or dir ~= np then
                same = false
            end
        end
    end
    return same
end

--大兵移动
local function OnSoldierMove(key, posIndex, node)
    local info = SOLDIER_POINT[key]
    local pLen = #info.Pos
    if posIndex > pLen then
        posIndex = 1
    end
    node["posIndex"] = posIndex
    local originPos = info.Pos[posIndex]
    local nextPos = posIndex == pLen and info.Pos[1] or info.Pos[posIndex + 1]
    local dir = CityCharacter.GetDirection(originPos, nextPos)
    SpecialOrder(node, info.Specail, posIndex)
    node.sortingOrder = node["i"] == 1 and DIALOG_SORTING_ORDER or math.floor(node.y)
    node["goalPosIndex"] = posIndex
    --播放行走动画
    local w_dir, w_flip = CityCharacter.GetDirectionAndFlip(dir)
    local animState = string.format("Walk_%s", w_dir)
    node["state"] = animState
    node["anim"]:Play(animState)
    node["sprite_render"].flipX = w_flip
    node["next_pos"] = nextPos
    if info.TotalAmount > 1 and CheckDirection(key) then
        CitySoldier.CorrectPosition(key, posIndex, nextPos, dir)
    else
        --播放移动动画
        local distance = MathUtil.GetDistanceByPos(node.xy, nextPos)
        local time = distance / WALK_MOVE_SPEED
        node:GetContext():GtweenOnComplete(node:TweenMove(nextPos, time):SetEase(EaseType.Linear), function()
            --移动完成
            local toNextIndex = posIndex + 1
            if toNextIndex > pLen then
                toNextIndex = 1
            end
            local toNextPos = toNextIndex == pLen and info.Pos[1] or info.Pos[toNextIndex + 1]
            local toDir = CityCharacter.GetDirection(nextPos, toNextPos)
            if CityCharacter.EqualDirection(dir, toDir) then
                local saluteInfo = SOLDIER_POINT[key]
                local posArray = {}
                for _, _soldier in ipairs(saluteInfo.SoldierArr) do
                    GTween.Kill(_soldier)
                    table.insert(posArray, _soldier.xy)
                end
                for k, _soldier in ipairs(saluteInfo.SoldierArr) do
                    _soldier.xy = posArray[#posArray - k + 1]
                    OnSoldierMove(key, toNextIndex, _soldier)
                end
            else
                GTween.Kill(node)
                OnSoldierMove(key, toNextIndex, node)
            end
        end)
    end
end
--大兵敬礼完成
local function OnSoldierSaluteComplete(key)
    local info = SOLDIER_POINT[key]
    for _, node in ipairs(info.SoldierArr) do
        node["next_pos"] = nil
        node:SetTouchable(true)
        local goalPosIndex = node["goalPosIndex"]
        SpecialOrder(node, info.Specail, goalPosIndex)
        node.sortingOrder = node["i"] == 1 and DIALOG_SORTING_ORDER or math.floor(node.y)
        OnSoldierMove(key, goalPosIndex, node)
    end
end
--大兵敬礼
local function OnSoldierSalute(key)
    local info = SOLDIER_POINT[key]
    for k, node in ipairs(info.SoldierArr) do
        node:SetTouchable(false)
        GTween.Kill(node)
        local posIndex = node["posIndex"]
        local pLen = #info.Pos
        if posIndex > pLen then
            posIndex = 1
        end
        local originPos = info.Pos[posIndex]
        local nextPos = posIndex == pLen and info.Pos[1] or info.Pos[posIndex + 1]
        local dir = CityCharacter.GetSaluteDirection(originPos, nextPos)
        node["anim"]:Play("Salute_LD")
        node["sprite_render"].flipX = dir ~= "LD"
        
        if k == 1 then
            DialogModel.ShowDialog(node, DialogType.Soldier)
        end
        if k == info.TotalAmount then
            Scheduler.UnScheduleFast(OnSoldierSaluteComplete)
            Scheduler.ScheduleOnceFast(function()
                OnSoldierSaluteComplete(key)
            end, 1)
        end
    end
end
--大兵巡逻动画
local function PlaySoldierAnim()
    if next(SOLDIER_POINT) == nil then
        SOLDIER_POINT = ConfigMgr.GetList("configDabingPositions")
        for _, v in pairs(SOLDIER_POINT) do
            v.SoldierArr = {}
        end
    end
    _G.CSCoroutine.Start(function()
        local path = "prefabs/character/soldier/prefab/soldier"
        _G.coroutine.yield(ResMgr.Instance:LoadPrefab(path))
        for key = 1, #SOLDIER_POINT do
            local info = SOLDIER_POINT[key]
            --改变配置表位置（位差）
            for _, v in pairs(info.Pos) do
                v.x = v.x + OFFSET_POS.x - 10
                v.y = v.y + OFFSET_POS.y - 30
            end
            for i = 1, info.TotalAmount do
                local node = _G.UIMgr:CreateObject("Effect", "EmptyNode")
                table.insert(info.SoldierArr, node)
                node:SetSize(20, 36)
                local col = (i - 1) % info.RowAmount
                local row = math.modf((i - 1) / info.RowAmount)
                local startPos = info.Pos[1]
                local nextPos = info.Pos[2]
                node.xy = CityCharacter.GetPosition(startPos, nextPos, row, col)
                SpecialOrder(node, info.Specail, 1)
                node["i"] = i
                node.sortingOrder = i == 1 and DIALOG_SORTING_ORDER or math.floor(node.y)
                SoldierNode:AddChild(node)

                local prefab = ResMgr.Instance:GetPrefab(path)
                local object = GameObject.Instantiate(prefab)
                node:GetGGraph():SetNativeObject(GoWrapper(object))
                local scale = 100 * Global.CityCharacterScale
                object.transform.localScale = Vector3(0, 0, 0)
                node:GetContext():GtweenOnComplete(node:TweenFade(1, 0.2), function()
                    object.transform.localScale = Vector3(scale, scale, scale)
                end)
                object.transform.localPosition = Vector3(10, -30, 0)
                node["anim"] = object:GetComponent("Animator")
                node["sprite_render"] = object:GetComponent("SpriteRenderer")
                node["sign"] = key

                node:SetTouchable(true)
                node:ClickCallback(function()
                    OnSoldierSalute(key)
                    _G.WeatherModel.CheckWeatherRain()
                end)
            end
            for _, node in ipairs(info.SoldierArr) do
                OnSoldierMove(key, 1, node)
            end
        end
    end)
end

function CitySoldier.InitSoldierAnim(ctx)
    SoldierNode = ctx[CityType.CITY_MAP_NODE_TYPE.Soldier.name]
    SoldierOrderUpNode = ctx[CityType.CITY_MAP_NODE_TYPE.SoldierOrderUp.name]
    PlaySoldierAnim()
end

function CitySoldier.Clear()
    Scheduler.UnScheduleFast(OnSoldierSaluteComplete)
    if SoldierNode then
        for i = SoldierNode.numChildren, 1, -1 do
            local item = SoldierNode:GetChildAt(i - 1)
            GTween.Kill(item)
            item:Dispose()
        end
        SoldierNode = nil
    end
    if SoldierOrderUpNode then
        for i = SoldierOrderUpNode.numChildren, 1, -1 do
            local item = SoldierOrderUpNode:GetChildAt(i - 1)
            GTween.Kill(item)
            item:Dispose()
        end
        SoldierOrderUpNode = nil
    end
end

function CitySoldier.Pause(isPause)
    for key, value in ipairs(SOLDIER_POINT) do
        for _, _soldier in ipairs(value.SoldierArr) do
            if isPause then
                GTween.Kill(_soldier)
            else
                _soldier["next_pos"] = nil
                OnSoldierMove(key, _soldier.posIndex, _soldier)
            end
        end
    end
end

--矫正大兵位置
function CitySoldier.CorrectPosition(key, posIndex, nextPos, dir)
    local info = SOLDIER_POINT[key]
    local pLen = #info.Pos
    for i, node in ipairs(info.SoldierArr) do
        if i ~= 1 then
            --根据排头兵重新校对位置
            local col = (i - 1) % info.RowAmount
            local row = math.modf((i - 1) / info.RowAmount)
            local originPos = info.SoldierArr[1].xy
            node.xy = CityCharacter.GetFollowPosition(dir, originPos, row, col)
        end
        local distance = MathUtil.GetDistanceByPos(node.xy, nextPos)
        local time = distance / WALK_MOVE_SPEED
        node:GetContext():GtweenOnComplete(node:TweenMove(nextPos, time):SetEase(EaseType.Linear), function()
            --移动完成
            local toNextIndex = posIndex + 1
            if toNextIndex > pLen then
                toNextIndex = 1
            end
            local toNextPos = toNextIndex == pLen and info.Pos[1] or info.Pos[toNextIndex + 1]
            local toDir = CityCharacter.GetDirection(nextPos, toNextPos)
            if CityCharacter.EqualDirection(dir, toDir) then
                local saluteInfo = SOLDIER_POINT[key]
                local posArray = {}
                for _, _soldier in ipairs(saluteInfo.SoldierArr) do
                    GTween.Kill(_soldier)
                    table.insert(posArray, _soldier.xy)
                end
                for k, _soldier in ipairs(saluteInfo.SoldierArr) do
                    _soldier.xy = posArray[#posArray - k + 1]
                    OnSoldierMove(key, toNextIndex, _soldier)
                end
            else
                OnSoldierMove(key, toNextIndex, node)
            end
        end)
    end
end

return CitySoldier