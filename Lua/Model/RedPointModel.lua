--author: 	Amu
--time:		2020-03-01 17:25:22

if RedPointModel then
    return RedPointModel
end

RedPointModel = {}
local redPointList = {}

function RedPointModel.Init()

end

function RedPointModel.AddRedPoint(pointType, refreshFun)
    if not redPointList[pointType] then
        redPointList[pointType] = {}
    end
    if not refreshFun or type(refreshFun) ~= "function" then
        error("======AddRedPoint========  refreshFun  : " .. type(refreshFun) .. " not right")
    end
    -- redPointList[pointType].redPoint = redPoint
    redPointList[pointType].refreshFun = refreshFun
end

function RedPointModel.RefreshPoint(pointType, ...)
    if redPointList[pointType] then
        redPointList[pointType].refreshFun(pointType, ...)
    end
end


return RedPointModel