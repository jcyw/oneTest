Net.Vip = {}

-- 请求-获取玩家的所有vip信息
function Net.Vip.GetVipInfo(...)
    Network.RequestDynamic("GetVipInfoParams", {}, ...)
end

-- 请求-刷新玩家vip信息
function Net.Vip.VipExpire(...)
    Network.RequestDynamic("VipExpireParams", {}, ...)
end

return Net.Vip