--[[
    author:{zhanzhang}
    time:2019-09-16 14:03:43
    function:{function}
]]
if ItemType then
    return ItemType
end

ItemType = {
    --普通道具
    CommonProp = 1,
    --加速道具
    SpeedupProp = 2,
    --体力道具
    ApProp = 3,
    --提升出征上限
    ExpeditionLimitProp = 4,
    --采集加速
    CollectBuffProp = 5,
    --行军召回
    MarchRecell = 6,
}

return ItemType
