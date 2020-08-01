Net.OnlineBonus = {}

-- 请求-获取在线奖励
function Net.OnlineBonus.GetBonus(...)
    Network.RequestDynamic("GetOnlineBonusParams", {}, ...)
end

return Net.OnlineBonus