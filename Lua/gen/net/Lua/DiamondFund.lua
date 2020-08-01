Net.DiamondFund = {}

-- 请求-购买钻石基金
function Net.DiamondFund.Buy(...)
    local fields = {
        "Tier", -- int32
    }
    Network.RequestDynamic("BuyDiamondFundParams", fields, ...)
end

-- 请求-领取钻石基金
function Net.DiamondFund.Claim(...)
    local fields = {
        "Tier", -- int32
    }
    Network.RequestDynamic("ClaimDiamondFundParams", fields, ...)
end

return Net.DiamondFund