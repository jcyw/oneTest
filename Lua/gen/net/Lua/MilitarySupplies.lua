Net.MilitarySupplies = {}

-- 请求-军需补给
function Net.MilitarySupplies.Exchange(...)
    local fields = {
        "Category", -- int32
        "IsFree", -- bool
    }
    Network.RequestDynamic("MSExchangeParams", fields, ...)
end

-- 请求-兑换补给次数
function Net.MilitarySupplies.AddChance(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("MSAddChanceParams", fields, ...)
end

-- 请求-军需信息
function Net.MilitarySupplies.Info(...)
    Network.RequestDynamic("MSInfoParams", {}, ...)
end

return Net.MilitarySupplies