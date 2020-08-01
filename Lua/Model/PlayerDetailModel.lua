local PlayerDetailModel = {}

--获取成就墙是否有未领取的奖励
function PlayerDetailModel.CheckNoAwardTaken()
    if UnlockModel:UnlockCenter(UnlockModel.Center.Achievement) then
        for _, v in pairs(Model.AccomplishedAchievement) do
            if not v.AwardTaken then
                return true
            end
        end
    else
        return false
    end
end

--设置成就墙是否有奖励
function PlayerDetailModel.SetAchievementAward()
    CuePointModel.SubType.Player.PlayerWall.Number = PlayerDetailModel.CheckNoAwardTaken() and 1 or 0
end

return PlayerDetailModel
