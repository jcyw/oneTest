--[[
    Author: songzeming
    Function: 大兵、工程师公用模板
]]
local CityCharacter = {}

local Global = _G.Global
local Vector2 = _G.Vector2

local DIR_TYPE = {
    LeftTop = "LT", --左上
    LeftDown = "LD", --坐下
    RightTop = "RT", --右上
    RightDown = "RD" --右下
}
local OFFSET_X = 30 * Global.CityCharacterScale
local OFFSET_Y = 15 * Global.CityCharacterScale

--获取移动方向
function CityCharacter.GetDirection(p1, p2)
    if p1.x <= p2.x then
        if p1.y <= p2.y then
            return DIR_TYPE.RightDown
        else
            return DIR_TYPE.RightTop
        end
    else
        if p1.y <= p2.y then
            return DIR_TYPE.LeftDown
        else
            return DIR_TYPE.LeftTop
        end
    end
end

--方向是否相等
function CityCharacter.EqualDirection(dir1, dir2)
    if dir1 == dir2 then
        return true
    end
    if dir1 == DIR_TYPE.LeftTop and dir2 == DIR_TYPE.RightDown then
        return true
    end
    if dir1 == DIR_TYPE.LeftDown and dir2 == DIR_TYPE.RightTop then
        return true
    end
    if dir1 == DIR_TYPE.RightTop and dir2 == DIR_TYPE.LeftDown then
        return true
    end
    if dir1 == DIR_TYPE.RightDown and dir2 == DIR_TYPE.LeftTop then
        return true
    end
    return false
end

--获取敬礼方向
function CityCharacter.GetSaluteDirection(p1, p2)
    if p1.x <= p2.x then
        return DIR_TYPE.RightDown
    else
        return DIR_TYPE.LeftDown
    end
end

--获取位置
function CityCharacter.GetPosition(p1, p2, row, col)
    local dir = CityCharacter.GetDirection(p1, p2)
    if dir == DIR_TYPE.LeftTop then
        return Vector2(p1.x + col * OFFSET_X - row * OFFSET_X, p1.y - row * OFFSET_Y - col * OFFSET_Y)
    elseif dir == DIR_TYPE.LeftDown then
        return Vector2(p1.x + col * OFFSET_X + row * OFFSET_X, p1.y - row * OFFSET_Y - col * OFFSET_Y)
    elseif dir == DIR_TYPE.RightTop then
        return Vector2(p1.x - col * OFFSET_X - row * OFFSET_X, p1.y + row * OFFSET_Y + col * OFFSET_Y)
    elseif dir == DIR_TYPE.RightDown then
        return Vector2(p1.x + col * OFFSET_X + row * OFFSET_X, p1.y + row * OFFSET_Y - col * OFFSET_Y)
    end
end

--获取跟随位置
function CityCharacter.GetFollowPosition(dir, p1, row, col)
    if dir == DIR_TYPE.LeftTop then
        return Vector2(p1.x + col * OFFSET_X + row * OFFSET_X, p1.y + row * OFFSET_Y - col * OFFSET_Y)
    elseif dir == DIR_TYPE.LeftDown then
        return Vector2(p1.x + col * OFFSET_X + row * OFFSET_X, p1.y - row * OFFSET_Y - col * OFFSET_Y)
    elseif dir == DIR_TYPE.RightTop then
        return Vector2(p1.x - col * OFFSET_X - row * OFFSET_X, p1.y + row * OFFSET_Y + col * OFFSET_Y)
    elseif dir == DIR_TYPE.RightDown then
        return Vector2(p1.x + col * OFFSET_X - row * OFFSET_X, p1.y - row * OFFSET_Y - col * OFFSET_Y)
    end
end

--获取方向和是否反转
function CityCharacter.GetDirectionAndFlip(dir)
    if dir == DIR_TYPE.LeftDown or dir == DIR_TYPE.LeftTop then
        return dir, false
    end
    if dir == DIR_TYPE.RightDown then
        return DIR_TYPE.LeftDown, true
    end
    if dir == DIR_TYPE.RightTop then
        return DIR_TYPE.LeftTop, true
    end
end

return CityCharacter