--[[
    author:{zhanzhang}
    time:2019-06-30 16:47:35
    function:{数学工具类}
]]
local DirectionEnum = import("Enum/DirectionEnum")
local math_sqrt = math.sqrt
local math_floor = math.floor

local MathUtil = {}
-- 角度转弧度
function MathUtil.AngleToRadian(angle)
    return angle * math.pi / 180
end

-- 弧度转角度
function MathUtil.RadianToAngle(radian)
    return radian * 180 / math.pi
end
-- 获取两点之间的距离
function MathUtil.GetDistanceByPos(p1, p2)
    return math_sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2)
end

function MathUtil.GetDistance(x, y)
    return math_sqrt(x * x + y * y)
end
--到基地的距离
function MathUtil.GetDistanceToBase(x, y)
    return MathUtil.GetDistance(Model.Player.X - x, Model.Player.Y - y)
end

function MathUtil.Lerp(a, b, t)
    return a + (b - a) * t
end
--计算坐标方向角
function MathUtil.CalDirect(x, y, deflectAngle)
    local a = math.deg(math.atan(y / x)) + deflectAngle
    a = (a + 360) % 360
    return math_floor(a / 45)
end
local showXPos, showYPos
--获取坐标值
function MathUtil.GetCoordinate(posNum)
    showXPos = math_floor(posNum / 10000)
    showYPos = posNum % 10000
    return showXPos, showYPos
end
--获取地块编号
function MathUtil.GetPosNum(x, y)
    return x * 10000 + y
end

function MathUtil.Formatnumberthousands(sum)
    local function checknumber(value)
        return tonumber(value) or 0
    end
    local sum = checknumber(sum)
    local newNum = ""
    repeat
        if sum <= 1000 then
            newNum = sum .. newNum
            return newNum
        end
        newNum = "," .. string.format("%03d", sum % 1000) .. newNum
        sum = math_floor((sum - sum % 1000) / 1000) --为了得到的是整数没有.0
    until (false)
end

--计算点到线段的距离
function MathUtil.PointToLineDistance(pos1X, pos1Y, pos2X, pos2Y, pos3X, pos3Y)
    local distance = 0
    --线段的距离
    local a = MathUtil.GetDistance(pos2X - pos3X, pos2Y - pos3Y)
    local b = MathUtil.GetDistance(pos1X - pos2X, pos1Y - pos2Y)
    local c = MathUtil.GetDistance(pos1X - pos3X, pos1Y - pos3Y)

    if (c * c >= a * a + b * b) then
        return b
    end

    if (b * b >= a * a + c * c) then
        return c
    end
    local p = (a + b + c) / 2 -- 半周长
    local s = math.sqrt(p * (p - a) * (p - b) * (p - c)) -- 海伦公式求面积
    distance = 2 * s / a -- 返回点到线的距离（利用三角形面积公式求高）
    return distance
end
--获得两点之间的夹角
function MathUtil.GetPointAngle(x1, y1, x2, y2)
    local xLen, yLen = x2 - x1, y2 - y1
    local fromVector = CVector3(xLen, 0, yLen)
    local v3 = CVector3.Cross(CVector3.right, fromVector)
    if v3.y > 0 then
        return CVector3.Angle(CVector3.right, fromVector)
    else
        return 360 - CVector3.Angle(CVector3.right, fromVector)
    end
end

function MathUtil.GetDirect(x1, y1, x2, y2)
    local angle = MathUtil.GetPointAngle(x1, y1, x2, y2)
    if angle < 0 then
        angle = angle + 360
    end
    for i = 1, #Global.MapMarchQueueAngle do
        if angle < Global.MapMarchQueueAngle[i] then
            return (DirectionEnum.Down + i - 1) % 8 + 1
        end
    end
    return DirectionEnum.LeftDown

    -- MapMarchQueueAngle
    -- if angle >= 337.5 or angle < 22.5 then
    --     return DirectionEnum.LeftDown
    -- elseif angle >= 22.5 and angle < 67.5 then
    --     return DirectionEnum.Left
    -- elseif angle >= 67.5 and angle < 112.5 then
    --     return DirectionEnum.LeftTop
    -- elseif angle >= 112.5 and angle < 157.5 then
    --     return DirectionEnum.Top
    -- elseif angle >= 157.5 and angle < 202.5 then
    --     return DirectionEnum.RightTop
    -- elseif angle >= 202.5 and angle < 247.5 then
    --     return DirectionEnum.Right
    -- elseif angle >= 247.5 and angle < 292.5 then
    --     return DirectionEnum.RightDown
    -- elseif angle >= 292.5 and angle < 337.5 then
    --     return DirectionEnum.Down
    -- end
    -- Global.

    -- return DirectionEnum.Right
end

--目前预设分辨率为 1334 X 750  从屏幕坐标转FairyGUI坐标需要用这个
--分辨率比较奇葩的情况需要计算宽高比
--1334 X 750 宽高比 0.562
--1080 X 1812 宽高比 0.596
--1080 X 2244 宽高比 0.48
function MathUtil.ScreenRatio(posX, posY)
    local ratio = 0
    if MathUtil.isDefaultRaito() then
        ratio = Screen.width / 750
    else
        ratio = Screen.height / 1334
    end
    return posX / ratio, posY / ratio
end

function MathUtil.FairyToScreeen(posX, posY)
    local ratio = 0
    if MathUtil.isDefaultRaito() then
        ratio = Screen.width / 750
    else
        ratio = Screen.height / 1334
    end
    return posX * ratio, posY * ratio
end
--获取当前屏幕宽高比
function MathUtil.isDefaultRaito()
    local isDefault = MathUtil.HaveMatch()
    if isDefault then
        return true
    end

    isDefault = Screen.width / Screen.height < 750 / 1334
    return isDefault
end

--是否是宽屏适配
function MathUtil.HaveMatch()
    local height = 1334
    local heightRatio = height / GRoot.inst.height
    if GRoot.inst.height == 1250 then
        return false
    end
    if heightRatio > 1 then
        return true
    else
        return false
    end
end

function MathUtil.NegativeV3(v3)
    v3.x = -v3.x
    v3.y = -v3.y
    v3.z = -v3.z
    return v3
end

function MathUtil.V3Minus(v3a, v3b)
    v3a.x = v3a.x - v3b.x
    v3a.y = v3a.y - v3b.y
    v3a.z = v3a.z - v3b.z
    return v3a
end

function MathUtil.V3Plus(v3a, v3b)
    v3a.x = v3a.x + v3b.x
    v3a.y = v3a.y + v3b.y
    v3a.z = v3a.z + v3b.z
    return v3a
end

function MathUtil.EaseInOut(t, b, c)
    if ((t * 2) < 1) then
        return c / 2 * math.pow(t * 2, 3) + b
    else
        return c / 2 * (math.pow(t * 2 - 2, 3) + 2) + b
    end
end
-- 首先b、c、d三个参数（即初始值，变化量，持续时间）
function MathUtil.QuadEaseOut(b, c, d, t)
    t = t / d
    return -c * t * (t - 2) + b
end

function MathUtil.CubicEaseOut(b, c, d, t)
    t = t / d
    return c * ((t - 1) * t * t + 1) + b
end

function MathUtil.QuadEaseInOut(t, b, c, d)
    local temp = t / (d / 2)
    if temp < 1 then
        return c / 2 * t * t + b
    end
    return -c / 2 * ((t - 1) * (t - 2) - 1) + b
end
-- Quad: {
--     easeIn: function(t,b,c,d){
--         return c*(t/=d)*t + b;
--     },
--     easeOut: function(t,b,c,d){
--         return -c *(t/=d)*(t-2) + b;
--     },
--     easeInOut: function(t,b,c,d){
--         if ((t/=d/2) < 1) return c/2*t*t + b;
--         return -c/2 * ((--t)*(t-2) - 1) + b;
--     }
-- },

-- Cubic: {
--     easeIn: function(t,b,c,d){
--         return c*(t/=d)*t*t + b;
--     },
--     easeOut: function(t,b,c,d){
--         return c*((t=t/d-1)*t*t + 1) + b;
--     },
--     easeInOut: function(t,b,c,d){
--         if ((t/=d/2) < 1) return c/2*t*t*t + b;
--         return c/2*((t-=2)*t*t + 2) + b;
--     }
-- },
_G.MathUtil = MathUtil
return MathUtil
