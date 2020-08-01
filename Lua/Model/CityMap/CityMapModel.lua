--[[
    Author: songzeming
    Function: 内城地图
]]
local CityMapModel = {}

CityMapModel.Middle = nil
CityMapModel.Map = nil
local MapPieceObject = {} --地图快缓存
local CityContext = nil --City.lua 上下文
local cutBtn = nil
local isCity = false
local cityLocks = {}

--设置City.lua的上下文
function CityMapModel.SetCityContext(ctx)
    CityContext = ctx
end
--获取City.lua的上下文
function CityMapModel.GetCityContext()
    return CityContext
end
--获取内城地图Middle
function CityMapModel.GetCityMiddle()
    return CityContext._middle
end
--获取内城地图
function CityMapModel.GetCityMap()
    return CityContext._map
end
--获取内城功能列表
function CityMapModel.GetCityFunction()
    return CityContext._itemDetail
end

--设置地图块
function CityMapModel.SetMapPiece(pos, node)
    MapPieceObject[pos] = node
end
--根据建筑位置获取地图块
function CityMapModel.GetMapPiece(pos)
    return MapPieceObject[pos]
end

--移动地图时判断该建筑是否在移动位置
function CityMapModel.CheckBuildPosEqualMovePos(confId)
    local building = BuildModel.FindByConfId(confId)
    local buildObj = BuildModel.GetObject(building.Id)
    local _middle = CityMapModel.GetCityMiddle()
    local _map = CityMapModel.GetCityMap()
    local isEqualX = math.abs(_middle.scrollPane.posX - (buildObj.x * _map.scaleX - _middle.width / 2)) < 1
    local isEqualY = math.abs(_middle.scrollPane.posY - (buildObj.y * _map.scaleY - _middle.height / 2)) < 1
    return isEqualX and isEqualY
end

function CityMapModel.CheckSpaceNodeIsMoved(x, y)
    local _middle = CityMapModel.GetCityMiddle()
    local _map = CityMapModel.GetCityMap()
    local isEqualX = math.abs(_middle.scrollPane.posX - (x * _map.scaleX - _middle.width / 2)) < 1
    local isEqualY = math.abs(_middle.scrollPane.posY - (y * _map.scaleY - _middle.height / 2)) < 1
    return isEqualX and isEqualY
end

function CityMapModel.SetCutPos(btn, isEnterCity)
    cutBtn = btn
    isCity = isEnterCity
end

function CityMapModel.GetCutBtn()
    if cutBtn ~= nil then
        return cutBtn, isCity
    end
end

function CityMapModel.SetLockBtn(lockData)
    if lockData then
        table.insert(cityLocks, lockData)
    end
end
function CityMapModel:SetComplete(complete)
    self.complete = complete
end

function CityMapModel:GetComplete()
    return self.complete
end

--得到解锁区域
function CityMapModel.GetLockBtn(lockNum)
    local num=lockNum-3
    return cityLocks[num]
end

return CityMapModel
