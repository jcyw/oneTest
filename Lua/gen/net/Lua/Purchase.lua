Net.Purchase = {}

-- 请求-获取订阅相关信息
function Net.Purchase.GetSubscriptionInfo(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetSubscriptionInfoParams", fields, ...)
end

-- 请求-获取订阅福利
function Net.Purchase.GetSubAward(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetSubAwardParams", fields, ...)
end

-- 请求-获取月卡状态相关信息
function Net.Purchase.GetCardStatus(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("GetCardStatusParams", fields, ...)
end

-- 请求-获取月卡或者豪华特权的奖励
function Net.Purchase.GetCardAward(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetCardAwardParams", fields, ...)
end

-- 请求-成长基金的信息
function Net.Purchase.GetGrowthFundInfo(...)
    Network.RequestDynamic("GetGrowthFundInfoParams", {}, ...)
end

-- 请求-获取基金的奖励
function Net.Purchase.GetGrowthFundAward(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("GetGrowthFundAwardParams", fields, ...)
end

-- 请求-创建订单
function Net.Purchase.CreateOrder(...)
    local fields = {
        "ProductId", -- string
        "ConfId", -- int32
        "Category", -- int32
    }
    Network.RequestDynamic("CreateOrderParams", fields, ...)
end

-- 请求-获取每日礼包奖励
function Net.Purchase.GetEveryDayGift(...)
    Network.RequestDynamic("GetEveryDayGiftAwardParams", {}, ...)
end

-- 请求-个人设置礼包组信息
function Net.Purchase.SetPlayerGiftGroupInfo(...)
    local fields = {
        "GroupInfo", -- GiftGroupRpcInfo
    }
    Network.RequestDynamic("SetPlayerGiftGroupInfoParams", fields, ...)
end

-- 通知-充值完成
function Net.Purchase.RpcOnSuccess(...)
    local fields = {
        "CpOrderId", -- string
        "ProductId", -- string
        "SubCoin", -- int32
        "ExtraCoin", -- int32
        "Currency", -- string
        "Money", -- string
    }
    Network.RequestDynamic("PurchaseOnSuccessParams", fields, ...)
end

-- 通知-订阅完成
function Net.Purchase.RpcOnSubscriptionSuccess(...)
    local fields = {
        "OrderID", -- string
        "OriginalOrderID", -- int64
        "ProductId", -- string
        "ExpiresDate", -- int64
        "IsSandBox", -- int32
        "Type", -- int32
    }
    Network.RequestDynamic("SubscriptionOnSuccessParams", fields, ...)
end

-- 通知-充值完成
function Net.Purchase.SendOnSuccess(...)
    local fields = {
        "CpOrderId", -- string
        "ProductId", -- string
        "SubCoin", -- int32
        "ExtraCoin", -- int32
        "Currency", -- string
        "Money", -- string
    }
    Network.RequestDynamic("SendOnSuccessParams", fields, ...)
end

-- 请求-后台创建订单
function Net.Purchase.BackstageCreateOrder(...)
    local fields = {
        "ProductId", -- string
        "ConfId", -- int32
        "Category", -- int32
    }
    Network.RequestDynamic("BackstageCreateOrderParams", fields, ...)
end

return Net.Purchase