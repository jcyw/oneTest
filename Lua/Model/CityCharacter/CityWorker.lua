--[[
    Author: songzeming
    Function: 工程师交互模板 动画
]]
local CityWorker = {}

local CityType = _G.CityType
local ConfigMgr = _G.ConfigMgr
local ResMgr = _G.ResMgr
local Vector2 = _G.Vector2
local Vector3 = _G.Vector3
local Global = _G.Global
local GoWrapper = _G.GoWrapper
local GameObject = _G.GameObject
local MathUtil = _G.MathUtil
local EaseType = _G.EaseType
local CityCharacter = import("Model/CityCharacter/CityCharacter")

local WorkerNode = nil
local WALK_MOVE_SPEED = 20 --行走移动速度
local OFFSET_POS = Vector2(20, 50)
--打点位置 工程师
local WORKER_POINT = {}

--播放工程师动画
local function PlayWorkerAnim()
    if next(WORKER_POINT) == nil then
        WORKER_POINT = ConfigMgr.GetList("configWorkerPositions")
    end
    _G.CSCoroutine.Start(function()
        local path = "prefabs/character/worker/prefab/worker"
        _G.coroutine.yield(ResMgr.Instance:LoadPrefab(path))
        for k = 1, #WORKER_POINT do
            local info = WORKER_POINT[k]
            --改变配置表位置（位差）
            for _, v in pairs(info.Pos) do
                v.x = v.x + OFFSET_POS.x
                v.y = v.y + OFFSET_POS.y
            end
            for i = 1, info.TotalAmount do
                local node = _G.UIMgr:CreateObject("Effect", "EmptyNode")
                local col = (i - 1) % info.RowAmount
                local row = math.modf((i - 1) / info.RowAmount)
                local startPos = info.Pos[1]
                local nextPos = info.Pos[2]
                node.xy = CityCharacter.GetPosition(startPos, nextPos, row, col)
                node.sortingOrder = math.floor(node.y)
                WorkerNode:AddChild(node)

                local prefab = ResMgr.Instance:GetPrefab(path)
                local object = GameObject.Instantiate(prefab)
                node:GetGGraph():SetNativeObject(GoWrapper(object))
                local scale = 100 * Global.CityCharacterScale
                object.transform.localScale = Vector3(scale, scale, scale)
                node["anim"] = object:GetComponent("Animator")
                node["sprite_render"] = object:GetComponent("SpriteRenderer")

                CityWorker.OnWorkerMove(node, info, 1)
            end
        end
    end)
end

--行走
function CityWorker.OnWorkerMove(node, info, posIndex)
    local pLen = #info.Pos
    if posIndex > pLen then
        posIndex = 1
    end
    local originPos = info.Pos[posIndex]
    local nextPos = posIndex == pLen and info.Pos[1] or info.Pos[posIndex + 1]
    node.sortingOrder = math.floor(node.y)
    local distance = MathUtil.GetDistanceByPos(originPos, nextPos)
    local time = distance / WALK_MOVE_SPEED
    node:GetContext():GtweenOnComplete(node:TweenMove(nextPos, time):SetEase(EaseType.Linear),function()
        CityWorker.OnWorkerMove(node, info, posIndex + 1)
    end)
    local dir = CityCharacter.GetDirection(originPos, nextPos)
    local w_dir, w_flip = CityCharacter.GetDirectionAndFlip(dir)
    local animState = string.format("Walk_%s", w_dir)
    node["state"] = animState
    node["anim"]:Play(animState)
    node["sprite_render"].flipX = w_flip
end

function CityWorker.InitWorkerAnim(ctx)
    WorkerNode = ctx[CityType.CITY_MAP_NODE_TYPE.Worker.name]
    PlayWorkerAnim()
end

function CityWorker.Clear()
    if WorkerNode then
        for i = WorkerNode.numChildren, 1, -1 do
            WorkerNode:GetChildAt(i - 1):Dispose()
        end
    end
end

return CityWorker
