Net.AllianceGift = {}

-- 请求领取联盟礼物
function Net.AllianceGift.RequestGetGift(...)
    local fields = {
        "AllianceId", -- string
        "ItemId", -- string
    }
    Network.RequestDynamic("AllianceRequestGetGiftParams", fields, ...)
end

-- 请求联盟礼物信息
function Net.AllianceGift.RequestGiftInfo(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceRequestGiftInfoParams", fields, ...)
end

return Net.AllianceGift