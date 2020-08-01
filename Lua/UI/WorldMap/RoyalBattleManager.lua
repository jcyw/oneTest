--[[
    author:{zhanzhang}
    time:2020-03-16 16:43:17
    function:{王城战管理器}
]]
local RoyalBattleManager = {}

local tweenCache = {}
local DOTween = CS.DG.Tweening.DOTween
local DOPathType = CS.DG.Tweening.PathType
local DOEase = CS.DG.Tweening.Ease
local DORotateMode = CS.DG.Tweening.RotateMode

local flyDuration

local pointPos = {
    [6050605] = {{x = 599.5, y = 599.7}, {x = 599.76, y = 600.68}, {x = 600.42, y = 600.19}},
    [6050596] = {{x = 599.85, y = 599.04}, {x = 600.03, y = 600.2}, {x = 600.46, y = 599.14}},
    [5960605] = {{x = 598.65, y = 599.73}, {x = 598.98, y = 600.6}, {x = 598.44, y = 600.34}},
    [5960596] = {{x = 598.76, y = 598.98}, {x = 598.18, y = 598.73}, {x = 599.18, y = 598.61}}
}
local startPoints = {
    [6050605] = {x = 604, y = 604},
    [6050596] = {x = 604, y = 595},
    [5960605] = {x = 595, y = 604},
    [5960596] = {x = 595, y = 595}
}

function RoyalBattleManager.Init()
    Event.AddListener(
        EventDefines.RoyalDartFly,
        function(msg)
            if  GlobalVars.IsInCity then
                return
            end
            RoyalBattleManager.PlayDartFly(msg)
        end
    )
end

local function PlayDartFlyFromPoint(list, posNum)
    local posX, posY = MathUtil.GetCoordinate(posNum)
    local startPos = startPoints[posNum]
    Scheduler.ScheduleOnceFast(
        function()
            -- local smoke = GameObject.Instantiate(ResMgr.Instance:LoadPrefabSync("effects/missile_smoke/prefab/effect_missile_smoke"))
            -- smoke.transform.parent = WorldMap.Instance().RouteLayer.transform
            -- smoke.transform.localPosition = CVector3(startPos.x + 0.7, 0, startPos.y + 0.77)
            -- Scheduler.ScheduleOnce(
            --     function()
            --         ObjectUtil.Destroy(smoke)
            --     end,
            --     4
            -- )
            DynamicRes.GetBundle("effect_ab/missile_smoke", function()
                DynamicRes.GetPrefab("effect_ab/missile_smoke", "effect_missile_smoke", function(prefab)
                    local smoke =  GameObject.Instantiate(prefab)
                    smoke.transform.parent = WorldMap.Instance().RouteLayer.transform
                    smoke.transform.localPosition = CVector3(startPos.x + 0.7, 0, startPos.y + 0.77)
                    Scheduler.ScheduleOnce(
                        function()
                            ObjectUtil.Destroy(smoke)
                        end,
                        4
                    )
                end)
            end)
        end,
        0.3
    )
    local DartFire = DOTween.Sequence()
    local path = {}
    local pointX = 0
    local pointY = 0
    local angle = MathUtil.GetDirect(posX, posY, 600, 600)
    local rotateAngle
    if angle == 1 then
        rotateAngle = CVector3(100, 0, 0)
    elseif angle == 3 then
        rotateAngle = CVector3(0, 0, -120)
    elseif angle == 5 then
        rotateAngle = CVector3(-200, 0, 0)
    elseif angle == 7 then
        rotateAngle = CVector3(0, 0, 120)
    end

    for i = 1, 3 do
        local obj = list[i]
        local endX = pointPos[posNum][i].x
        local endY = pointPos[posNum][i].y
        local endPoints = CVector3(endX, 0, endY)
        pointX = startPos.x + 0.4
        pointY = startPos.y + i * 0.05 + 0.4
        obj.transform.parent = WorldMap.Instance().RouteLayer.transform

        obj.transform.localPosition = CVector3(pointX, 0, pointY)
        obj.transform.localEulerAngles = CVector3(40, -135, 0)

        path[0] = obj.transform.localPosition
        path[1] = CVector3((endX + pointX) / 2, 2, (endY + pointY) / 2)
        path[2] = endPoints
        local tweenPath = obj.transform:DOLocalPath(path, 5, DOPathType.CatmullRom):SetEase(DOEase.InCubic)
        local tweenRotate = obj.transform:DOLocalRotate(rotateAngle, 5, DORotateMode.LocalAxisAdd):SetEase(DOEase.InCubic)
        local delay = (i - 1) * 0.2

        local playBoomEffect = function()
            -- local boomObj = GameUtil.CreateObj("effects/missile_explosion/prefab/effect_missile_explosion")
            -- boomObj.transform.parent = WorldMap.Instance().RouteLayer.transform
            -- boomObj.transform.localPosition = endPoints
            -- obj.transform.localPosition = CVector3.one * 3000
            -- ObjectUtil.Destroy(obj)
            -- Scheduler.ScheduleOnce(
            --         function()
            --             ObjectUtil.Destroy(boomObj)
            --         end,
            --         3
            -- )
            ObjectUtil.Destroy(obj)
            DynamicRes.GetBundle("effect_ab/missile_explosion", function()
            DynamicRes.GetPrefab("effect_ab/missile_explosion", "Effect_Missile_explosion", function(prefab)
                local initObject =  GameObject.Instantiate(prefab)
                initObject.transform.parent = WorldMap.Instance().RouteLayer.transform
                initObject.transform.localRotation = Quaternion(0, 0, 0,0)
                initObject.transform.localScale = Vector3.one
                initObject.transform.localPosition = endPoints
                initObject:SetActive(true)
                Scheduler.ScheduleOnce(
                    function()
                        ObjectUtil.Destroy(initObject)
                    end
                , 3)
            end)
    end)
        end
        DartFire:Insert(delay, tweenPath):Insert(delay, tweenRotate):AppendCallback(playBoomEffect)
    end
end

local CreateDart = function(path, posNum)
    local list = {}
    for i = 1, 3 do
        local obj = ObjectPoolManager.Instance:Get("prefabs/tomahawk")
        table.insert(list, obj)
    end
    PlayDartFlyFromPoint(list, posNum)
end

function RoyalBattleManager.PlayDartFly(msg)
    local isExist = ObjectPoolManager.Instance:IsExistPool("prefabs/tomahawk")
    local obj
    -- local posX = msg.X + (msg.X == 605 and -1 or 1)
    -- local posY = msg.Y + (msg.Y == 605 and -1 or 1)
    local posNum = MathUtil.GetPosNum(msg.X, msg.Y)
    --{6040604, 5950595, 5950604, 6040595}
    local list = {}

    if isExist then
        CreateDart("prefabs/tomahawk", posNum)
    else
        CSCoroutine.Start(
            function()
                coroutine.yield(ObjectPoolManager.Instance:CreatePool("prefabs/tomahawk", 1, "prefabs/tomahawk"))
                CreateDart("prefabs/tomahawk", posNum)
            end
        )
    end
end

return RoyalBattleManager
