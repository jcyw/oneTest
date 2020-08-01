Net.Techs = {}

-- 请求-科技升级
function Net.Techs.Upgrade(...)
    local fields = {
        "ConfId", -- int32
        "Instant", -- bool
    }
    Network.RequestDynamic("TechUpgradeParams", fields, ...)
end

-- 请求-领取研发奖励
function Net.Techs.GetGift(...)
    local fields = {
        "Type", -- int32
    }
    Network.RequestDynamic("GetTechResearchGiftParams", fields, ...)
end

return Net.Techs