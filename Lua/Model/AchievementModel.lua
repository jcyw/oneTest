--[[
    author:Temmie
    time:2020-3-4
    function:成就Model
]]

local AchievementModel = {}

AchievementModel.tmpDatas = {}

function AchievementModel.SetData(datas)
    for _, v in ipairs(datas.Accomplished) do
        v.Accomplished = true
        AchievementModel.tmpDatas[v.Id] = v
    end
    for _, v in ipairs(datas.Unlocked) do
        AchievementModel.tmpDatas[v.Id] = v
    end
end

function AchievementModel.SetUnlockData(datas)
    for _,v in pairs(datas.Tasks) do
        AchievementModel.tmpDatas[v.Id] = v
    end
end

function AchievementModel.SetAccomplishedData(datas)
    for _,v in pairs(datas.Achievements) do
        v.Accomplished = true
        AchievementModel.tmpDatas[v.Id] = v
    end
end

function AchievementModel.SetTaken(Id)
    if AchievementModel.tmpDatas[Id] and Tool.EqualBool(AchievementModel.tmpDatas[Id].AwardTaken, false) then
        AchievementModel.tmpDatas[Id].AwardTaken = true
    end
end

return AchievementModel