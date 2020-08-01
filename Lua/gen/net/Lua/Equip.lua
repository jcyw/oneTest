Net.Equip = {}

-- 请求-解锁宝石生产栏位
function Net.Equip.UnlockJewelColumn(...)
    Network.RequestDynamic("UnlockJewelColumn", {}, ...)
end

-- 请求-宝石生产
function Net.Equip.DoMakeJewel(...)
    local fields = {
        "JewelId", -- int32
    }
    Network.RequestDynamic("DoMakeJewel", fields, ...)
end

-- 请求-删除在等待栏位的宝石
function Net.Equip.DeleteWaitJewel(...)
    local fields = {
        "Index", -- int32
    }
    Network.RequestDynamic("DeleteWaitJewel", fields, ...)
end

-- 请求-收取宝石
function Net.Equip.CollectJewel(...)
    Network.RequestDynamic("CollectJewel", {}, ...)
end

-- 请求-材料合成
function Net.Equip.CompoundJewel(...)
    local fields = {
        "JewelId", -- int32
        "UseAmount", -- int32
    }
    Network.RequestDynamic("CompoundJewel", fields, ...)
end

-- 请求-材料分解
function Net.Equip.ResolveJewel(...)
    local fields = {
        "JewelId", -- int32
        "ResolveAmount", -- int32
    }
    Network.RequestDynamic("ResolveJewel", fields, ...)
end

-- 请求-装备交易
function Net.Equip.ExchangeEquip(...)
    local fields = {
        "EquipSerialId", -- int32
        "Uuid", -- string
        "JewelIds", -- array-int32
        "Instant", -- bool
    }
    Network.RequestDynamic("ExchangeEquip", fields, ...)
end

-- 请求-领取交易的装备
function Net.Equip.TakeExchangeEquip(...)
    local fields = {
        "EventId", -- string
    }
    Network.RequestDynamic("TakeExchangeEquip", fields, ...)
end

-- 请求-装备合成
function Net.Equip.CompoundEquip(...)
    local fields = {
        "Uuids", -- array-string
        "EquipId", -- int32
    }
    Network.RequestDynamic("CompoundEquip", fields, ...)
end

-- 请求-装备分解
function Net.Equip.ResolveEquip(...)
    local fields = {
        "Uuid", -- string
    }
    Network.RequestDynamic("ResolveEquip", fields, ...)
end

-- 请求-穿戴装备
function Net.Equip.PutonEquip(...)
    local fields = {
        "Uuid", -- string
    }
    Network.RequestDynamic("PutonEquip", fields, ...)
end

-- 请求-脱下装备
function Net.Equip.PutoffEquip(...)
    local fields = {
        "Uuid", -- string
    }
    Network.RequestDynamic("PutoffEquip", fields, ...)
end

-- 请求-锁定装备
function Net.Equip.LockEquip(...)
    local fields = {
        "Uuid", -- string
    }
    Network.RequestDynamic("LockEquip", fields, ...)
end

-- 请求-解锁装备
function Net.Equip.UnlockEquip(...)
    local fields = {
        "Uuid", -- string
    }
    Network.RequestDynamic("UnlockEquip", fields, ...)
end

return Net.Equip