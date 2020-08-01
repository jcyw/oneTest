Net.GemFund = {}

-- 请求-获取钻石基金的信息
function Net.GemFund.GetInfo(...)
    Network.RequestDynamic("GetGemFundInfoParams", {}, ...)
end

-- 请求-获取钻石基金奖励
function Net.GemFund.GetGemFundAward(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("GetGemFundAwardParams", fields, ...)
end

-- 请求-购买钻石基金
function Net.GemFund.BuyGemFund(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("BuyGemFundParams", fields, ...)
end

return Net.GemFund