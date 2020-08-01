Net.GiantBeast = {}

-- 请求-获取巨兽的信息
function Net.GiantBeast.GetGiantBeastInfo(...)
    Network.RequestDynamic("GetGiantBeastInfoParams", {}, ...)
end

-- 请求-巨兽医院治疗巨兽
function Net.GiantBeast.CureGiantBeast(...)
    local fields = {
        "Id", -- int32
        "HealHealth", -- int32
        "Instant", -- bool
    }
    Network.RequestDynamic("CureGiantBeastParams", fields, ...)
end

return Net.GiantBeast