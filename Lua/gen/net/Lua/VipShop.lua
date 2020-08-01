Net.VipShop = {}

-- 请求-所有vip商品的信息
function Net.VipShop.GetGoodsList(...)
    Network.RequestDynamic("GetVipGoodsListParams", {}, ...)
end

-- 请求-购买vip商品
function Net.VipShop.BuyGoods(...)
    local fields = {
        "Category", -- int32
        "Amount", -- int32
    }
    Network.RequestDynamic("BuyVipGoodsParams", fields, ...)
end

return Net.VipShop