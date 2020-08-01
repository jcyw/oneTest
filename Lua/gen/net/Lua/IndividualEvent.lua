Net.IndividualEvent = {}

-- 请求-获取信息
function Net.IndividualEvent.IndividualEventInfo(...)
    Network.RequestDynamic("GetIndividualEventInfoParams", {}, ...)
end

return Net.IndividualEvent