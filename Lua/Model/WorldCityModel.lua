--军队Model
local WorldCityModel = {}
--当前选择区域X,Y
local nowPosX
local nowPosY
--刷新当前点击区域
function WorldCityModel.SetCurrentPos(posX, posY)
    nowPosX = posX
    nowPosY = posY
end

function WorldCityModel.GetX()
    return nowPosX
end

function WorldCityModel.GetY()
    return nowPosY
end


return WorldCityModel