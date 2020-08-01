local WorldCityData = {}
local infoMap = {}

--获取地块信息
function WorldCityData.getNowData(idx, idy, cb)
    local params = {
        ServerId = "1",
        UserId = UserModel.data.accountId,
        StartX = startX,
        StartY = startY,
        StopX = stopX,
        StopY = stopY
    }
    Network.Request(ApiMap.protos.PT_MapMatrixInfoParams, params)
end


return WorldCityData
