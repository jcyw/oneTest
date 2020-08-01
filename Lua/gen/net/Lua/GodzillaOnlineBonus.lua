Net.GodzillaOnlineBonus = {}

-- 请求-获取哥斯拉在线奖励信息
function Net.GodzillaOnlineBonus.GetGodzillaOnlineBonusInfo(...)
    Network.RequestDynamic("GetGodzillaOnlineBonusInfoParams", {}, ...)
end

-- 请求-获取哥斯拉在线奖励
function Net.GodzillaOnlineBonus.GetGodzillaOnlineBonusAward(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetGodzillaOnlineBonusAwardParams", fields, ...)
end

return Net.GodzillaOnlineBonus