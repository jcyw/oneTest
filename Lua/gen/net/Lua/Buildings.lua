Net.Buildings = {}

-- 请求-创建建筑
function Net.Buildings.Create(...)
    local fields = {
        "Pos", -- int32
        "ConfId", -- int32
        "Instant", -- bool
    }
    Network.RequestDynamic("BuildingCreateParams", fields, ...)
end

-- 请求-建筑升级
function Net.Buildings.Upgrade(...)
    local fields = {
        "BuildingId", -- int32
        "Instant", -- bool
    }
    Network.RequestDynamic("BuildingUpgradeParams", fields, ...)
end

-- 请求-建筑拆除
function Net.Buildings.Destroy(...)
    local fields = {
        "BuildingId", -- int32
    }
    Network.RequestDynamic("BuildingDestroyParams", fields, ...)
end

-- 请求-移动建筑
function Net.Buildings.Move(...)
    local fields = {
        "FromPos", -- int32
        "ToPos", -- int32
    }
    Network.RequestDynamic("BuildingMoveParams", fields, ...)
end

-- 请求-购买建筑队列
function Net.Buildings.BuyBuilder(...)
    local fields = {
        "UseGem", -- bool
        "Amount", -- int32
    }
    Network.RequestDynamic("BuildingBuyBuilderParams", fields, ...)
end

-- 请求-解锁区域
function Net.Buildings.UnlockArea(...)
    local fields = {
        "ConfId", -- int32
    }
    Network.RequestDynamic("BuildingUnlockAreaParams", fields, ...)
end

-- 请求-领取指挥中心升级礼包
function Net.Buildings.GetCenterUpgradeGift(...)
    local fields = {
        "Level", -- int32
    }
    Network.RequestDynamic("GetCenterUpgradeGiftParams", fields, ...)
end

return Net.Buildings