Net.Items = {}

-- 请求-使用道具
function Net.Items.Use(...)
    local fields = {
        "ConfId", -- int32
        "Amount", -- int32
        "ChooseItemId", -- int32
    }
    Network.RequestDynamic("ItemUseParams", fields, ...)
end

-- 请求-使用定点飞城道具
function Net.Items.UseFlyCity(...)
    local fields = {
        "X", -- int32
        "Y", -- int32
    }
    Network.RequestDynamic("ItemUseFlyCityParams", fields, ...)
end

-- 请求-使用新手飞城道具
function Net.Items.UseRookieFlyCity(...)
    local fields = {
        "ServerId", -- string
    }
    Network.RequestDynamic("ItemUseRookieFlyCityParams", fields, ...)
end

-- 请求-使用联盟飞城道具
function Net.Items.UseAllianceFlyCity(...)
    Network.RequestDynamic("ItemUseAllianceFlyCityParams", {}, ...)
end

-- 请求-购买道具
function Net.Items.Buy(...)
    local fields = {
        "ConfId", -- int32
        "Amount", -- int32
    }
    Network.RequestDynamic("ItemBuyParams", fields, ...)
end

-- 请求-购买并用道具
function Net.Items.BuyAndUse(...)
    local fields = {
        "ConfId", -- int32
        "Amount", -- int32
    }
    Network.RequestDynamic("ItemBuyAndUseParams", fields, ...)
end

-- 请求-批量使用道具
function Net.Items.BatchUse(...)
    local fields = {
        "ItemAmounts", -- array-Item
    }
    Network.RequestDynamic("ItemBatchUseParams", fields, ...)
end

-- 请求-获取联盟飞城的位置
function Net.Items.GetAllianceFlyCityPos(...)
    Network.RequestDynamic("GetAllianceFlyCityPosParams", {}, ...)
end

-- 请求-使用累储获得的兑换道具
function Net.Items.UseAddUpExchange(...)
    local fields = {
        "ConfId", -- int32
        "Category", -- int32
    }
    Network.RequestDynamic("UseAddUpExchangeParams", fields, ...)
end

-- 请求-购买资源
function Net.Items.BuyRes(...)
    local fields = {
        "ResAmounts", -- array-ResAmount
    }
    Network.RequestDynamic("ItemBuyResParams", fields, ...)
end

-- 通知-召唤集结野怪
function Net.Items.CallRallyMonster(...)
    local fields = {
        "ConfId", -- int32
    }
    Network.RequestDynamic("ItemCallRallyMonsterParams", fields, ...)
end

-- 通知-使用cdkey
function Net.Items.UseCDKEY(...)
    local fields = {
        "Key", -- string
    }
    Network.RequestDynamic("UseCDKeyParams", fields, ...)
end

-- 请求-删除随机飞城物品
function Net.Items.DeleteRookieFlyCity(...)
    Network.RequestDynamic("DeleteRookieFlyCityItemParams", {}, ...)
end

return Net.Items