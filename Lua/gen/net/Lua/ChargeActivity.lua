Net.ChargeActivity = {}

-- 请求-理财
function Net.ChargeActivity.Invest(...)
    local fields = {
        "Capital", -- int32
        "Category", -- int32
    }
    Network.RequestDynamic("InvestParams", fields, ...)
end

-- 请求-获取理财相关状态信息
function Net.ChargeActivity.GetInvestStatus(...)
    Network.RequestDynamic("GetInvestStatusParams", {}, ...)
end

-- 请求-获取特定理财的信息
function Net.ChargeActivity.GetInvestInfo(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("GetInvestInfoParams", fields, ...)
end

-- 请求-放弃理财
function Net.ChargeActivity.CancelInvest(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("CancelInvestParams", fields, ...)
end

-- 请求-领取投资完成后的奖励
function Net.ChargeActivity.GetInvestAward(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("GetInvestAwardParams", fields, ...)
end

-- 请求-获取抽奖信息
function Net.ChargeActivity.GetLotteryInfo(...)
    Network.RequestDynamic("GetRechargeLotteryInfoParams", {}, ...)
end

-- 请求-抽奖
function Net.ChargeActivity.Lotto(...)
    Network.RequestDynamic("RechargeLottoParams", {}, ...)
end

-- 请求-领取奖励
function Net.ChargeActivity.GetReward(...)
    Network.RequestDynamic("GetRechargeLotteryRewardParams", {}, ...)
end

-- 请求-领取每日奖励
function Net.ChargeActivity.DailyBonus(...)
    Network.RequestDynamic("RechargeDailyBonusParams", {}, ...)
end

return Net.ChargeActivity