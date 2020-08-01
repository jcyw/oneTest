Net.SpecialShop = {}

-- 请求-所有商品信息
function Net.SpecialShop.GetGoodsList(...)
    Network.RequestDynamic("GetSpecialGoodListsParams", {}, ...)
end

-- 请求-购买商品
function Net.SpecialShop.BuyGoods(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("BuySpecialGoodsParams", fields, ...)
end

-- 请求-刷新商品
function Net.SpecialShop.RefreshGoods(...)
    Network.RequestDynamic("RefreshSpecialGoodsParams", {}, ...)
end

return Net.SpecialShop