--[[
    author:{zhanzhang}
    time:2019-08-09 10:01:24
    function:{多语言类型}
]]
if I18nType then
    return I18nType
end

I18nType = {
    --通用国际化文本
    Commmon = "configI18nCommons",
    --建筑名称国际化文本
    Building = "configI18nBuildings",
    --兵种国际化文本
    Army = "configI18nArmys",
    --道具国际化文本
    Item = "configI18nItems",
    --
    Quests = "configI18nQuests",
    --技能描述国际化文本
    Skills = "configI18nSkills",
    --科技国际化文本
    Tech = "configI18nTechs",
    --主线任务国际化文本
    Tasks = "configI18nTasks",
    -- --活动国际化文本
    Activitys = "configI18nActivitys",
    -- 新手引导国际化文本
    NoviceDialog = "configI18nDialogs",
    -- 角色名国际化文本
    Spokesman = "configI18nRoles",
    -- 艺术字
    WordArt = "configI18nWordarts",
    -- 装备
    Equip = "configI18nEquips",
}
_G.I18nType = I18nType
return I18nType
