Net.AllianceShop = {}

-- 请求-获取联盟商店信息
function Net.AllianceShop.Info(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceShopInfoParams", fields, ...)
end

-- 请求-联盟商店采购
function Net.AllianceShop.Stock(...)
    local fields = {
        "ConfId", -- int32
        "Amount", -- int32
    }
    Network.RequestDynamic("AllianceShopStockParams", fields, ...)
end

-- 请求-联盟商店标记
function Net.AllianceShop.Mark(...)
    local fields = {
        "ConfId", -- int32
    }
    Network.RequestDynamic("AllianceShopMarkParams", fields, ...)
end

-- 请求-联盟商店购买
function Net.AllianceShop.Buy(...)
    local fields = {
        "ConfId", -- int32
        "Amount", -- int32
    }
    Network.RequestDynamic("AllianceShopBuyParams", fields, ...)
end

-- 请求-联盟商店记录
function Net.AllianceShop.Log(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("AllianceShopLogParams", fields, ...)
end

return Net.AllianceShop