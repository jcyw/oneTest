Net.Walls = {}

-- 请求-使用道具修复城墙
function Net.Walls.RepairByItem(...)
    local fields = {
        "BuildingId", -- int32
    }
    Network.RequestDynamic("WallRepairByItemParams", fields, ...)
end

-- 请求-免费修复城墙
function Net.Walls.RepairByFree(...)
    local fields = {
        "BuildingId", -- int32
    }
    Network.RequestDynamic("WallRepairByFreeParams", fields, ...)
end

-- 请求-城墙灭火
function Net.Walls.Outfire(...)
    local fields = {
        "BuildingId", -- int32
    }
    Network.RequestDynamic("WallOutfireParams", fields, ...)
end

-- 请求-城墙燃烧完毕
function Net.Walls.FinishBurn(...)
    Network.RequestDynamic("WallFinishBurnParams", {}, ...)
end

return Net.Walls