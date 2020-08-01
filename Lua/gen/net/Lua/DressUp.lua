Net.DressUp = {}

-- 请求-玩家所有指定类型装扮物品
function Net.DressUp.GetDressUpType(...)
    local fields = {
        "DressUpType", -- int32
    }
    Network.RequestDynamic("GetDressUpTypeParams", fields, ...)
end

-- 请求-使用装扮
function Net.DressUp.UseDressUp(...)
    local fields = {
        "ConfigId", -- int32
    }
    Network.RequestDynamic("UseDressUpParams", fields, ...)
end

return Net.DressUp