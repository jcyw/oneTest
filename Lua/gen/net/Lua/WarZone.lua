Net.WarZone = {}

-- 请求-获取新城竞赛任务信息
function Net.WarZone.WarZoneTaskInfo(...)
    Network.RequestDynamic("GetWarZoneTaskInfoParams", {}, ...)
end

-- 请求-获取新城竞赛排名信息
function Net.WarZone.WarZoneRankInfo(...)
    Network.RequestDynamic("GetWarZoneRankInfoParams", {}, ...)
end

return Net.WarZone