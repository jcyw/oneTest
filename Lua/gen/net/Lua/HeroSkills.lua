Net.HeroSkills = {}

-- 请求-获取玩家指挥官技能的信息
function Net.HeroSkills.GetHeroSkillsInfo(...)
    Network.RequestDynamic("GetHeroSkillsInfoParams", {}, ...)
end

-- 请求-学习指定的指挥官技能
function Net.HeroSkills.LearnHeroSkill(...)
    local fields = {
        "Page", -- int32
        "Id", -- int32
        "Category", -- int32
    }
    Network.RequestDynamic("LearnHeroSkillParams", fields, ...)
end

-- 请求-使用指定的主动技能
function Net.HeroSkills.UseActiveSkill(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("UseActiveSkillParams", fields, ...)
end

-- 请求-重置所有技能
function Net.HeroSkills.ResetAllSkills(...)
    local fields = {
        "Page", -- int32
    }
    Network.RequestDynamic("ResetAllSkillsParams", fields, ...)
end

-- 请求-切换技能页
function Net.HeroSkills.SwitchSkillPage(...)
    local fields = {
        "Page", -- int32
    }
    Network.RequestDynamic("SwitchHeroSkillPageParams", fields, ...)
end

-- 请求-获取主动技能列表
function Net.HeroSkills.GetActiveSkillsInfo(...)
    Network.RequestDynamic("GetActiveSkillsParams", {}, ...)
end

return Net.HeroSkills