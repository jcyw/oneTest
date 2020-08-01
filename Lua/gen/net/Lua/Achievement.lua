Net.Achievement = {}

-- 请求-获取玩家所有的成就信息
function Net.Achievement.GetAchievementsInfo(...)
    Network.RequestDynamic("GetAchievementInfoParams", {}, ...)
end

-- 请求-成就完成后获取相应的奖励
function Net.Achievement.GetAwards(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetAchievementAwardsParams", fields, ...)
end

return Net.Achievement