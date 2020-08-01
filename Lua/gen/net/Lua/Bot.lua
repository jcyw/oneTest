Net.Bot = {}

-- 请求-升级机器人建筑
function Net.Bot.BotUpgradeBuilding(...)
    local fields = {
        "Level", -- int32
    }
    Network.RequestDynamic("BotUpgradeBuildingParams", fields, ...)
end

return Net.Bot