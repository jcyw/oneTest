--[[
    author:Temmie
    time:2019-09-24 15:07:00
    function:指挥官技能Model
]]
local SkillModel = {}
local ActiveSkillIds = {}
local ActiveSkillData = {}
function SkillModel.GetConfigs()
    return ConfigMgr.GetList("configPlayerSkills")
end

function SkillModel.GetConfigById(id)
    return ConfigMgr.GetItem("configPlayerSkills", id)
    --
end

function SkillModel.GetModelById(id, page)
    local skills = Model.GetInfo(ModelType.PlayerSkills, page).Skills
    for _, v in pairs(skills) do
        if v.Id == id then
            return v
        end
    end
end

-- 重置技能
function SkillModel.ResetSkills(skills, page)
    Model.GetInfo(ModelType.PlayerSkills, page).Skills = {}
    for k, v in pairs(skills) do
        Model.GetInfo(ModelType.PlayerSkills, page).Skills[k] = v
    end
    ActiveSkillIds = {}
end

-- 更新model技能数据
function SkillModel.UpdateSkillModel(data, page)
    local skills = Model.GetInfo(ModelType.PlayerSkills, page).Skills
    for k, v in pairs(skills) do
        if v.Id == data.Id then
            Model[ModelType.PlayerSkills][page].Skills[k] = data
            return
        end
    end
    table.insert(Model[ModelType.PlayerSkills][page].Skills, data)
end

-- 更新技能页剩余技能点
function SkillModel.UpdateSkillPoints(points, page)
    Model[ModelType.PlayerSkills][page].Points = points
end

-- 获取指定页剩余技能点数
function SkillModel.GetSkillPoints(page)
    return Model[ModelType.PlayerSkills][page].Points
end

-- 更新当前启用技能页
function SkillModel.UpdateCurPage(page)
    Model.PlayerSkillCurPage = page
end

-- 获取当前启动技能页
function SkillModel.GetCurPage()
    return Model.PlayerSkillCurPage
end

-- 获取技能页是否激活
function SkillModel.GetPageActive(page)
    return Model[ModelType.PlayerSkills][page].Unlocked
end

-- 根据科技类别获取配置
function SkillModel.GetConfigsByType(type)
    local configs = SkillModel.GetConfigs()
    local typeConfig = {}
    for _, v in pairs(configs) do
        if v.skill_type2 == type then
            table.insert(typeConfig, v)
        end
    end

    return typeConfig
end

--根据技能类型
function SkillModel.GetConfigBySkillType()
    local configs = SkillModel.GetConfigs()
    local typeConfig = {}
    for _, v in pairs(configs) do
        if v.skill_type == 2 then
            table.insert(typeConfig, v)
        end
    end

    return typeConfig
end

function SkillModel:GetActiveSkillConfig(params)
    local configs = GameUtil.Clone(self.GetConfigBySkillType())
    local skillConfig = {}
    for i, v in pairs(configs) do
        for item, value in pairs(params) do
            local skillId = tonumber(value.Id)
            if v.id == skillId then
                v.isActive = true
                v.cookAt = value.CoolAt
                v.expireAt = value.ExpireAt
                break
            end
        end
        if (v.cookAt == nil) then
            v.isActive = false
            v.cookAt = -1
            v.expireAt = -1
        end
        table.insert(skillConfig, v)
        -- end
    end
    table.sort(
        skillConfig,
        function(a, b)
            if a.cookAt > b.cookAt then
                return true
            end
        end
    )
    if skillConfig ~= nil then
        return skillConfig
    end
end

--设置主动技能红点信息
function SkillModel.SetASRedPointData(id, func)
    SkillModel:SetRedByNetHeroSkills(
        function(isUse, id)
            SkillModel:SetRedDataByNet(isUse, id)
            if func then
                func()
            end
        end,
        id
    )
end

function SkillModel:SetRedDataByNet(isUse, id)
    if SkillModel.IsRedPoint(id) and not isUse then
        table.insert(ActiveSkillIds, id)
    end
end
function SkillModel.SetRedData(id)
    if SkillModel.IsRedPoint(id) then
        table.insert(ActiveSkillIds, id)
    end
end

function SkillModel:SetRedByNetHeroSkills(func, id)
    Net.HeroSkills.GetActiveSkillsInfo(
        function(params)
            local tempId = id
            local skillUseId = {}
            for _, v in pairs(params.Skills) do
                if (v.CookAt and v.CoolAt - Tool.Time > 0) or (v.expireAt and v.expireAt - Tool.Time() > 0) then
                    local skillId = tonumber(v.Id)
                    table.insert(skillUseId, skillId)
                end
            end
            local isUse = false
            for _1, v1 in pairs(skillUseId) do
                if v1 == tempId then
                    isUse = true
                end
            end
            func(isUse, id)
        end
    )
end

function SkillModel.RemoveRedPointData(id)
    for i = #ActiveSkillIds, 1, -1 do
        if ActiveSkillIds[i] == id then
            table.remove(ActiveSkillIds, i)
        end
    end
end

function SkillModel.IsRedPoint(id)
    local config = SkillModel.GetConfigById(id)
    for _, v in pairs(ActiveSkillIds) do
        if v == id then
            return false
        end
    end
    if config.skill_type == 2 then
        return true
    else
        return false
    end
end

function SkillModel.GetActiveSkillNum()
    return #ActiveSkillIds
end

-- 根据类别和位置获取技能配置
function SkillModel.GetConfigByPos(type, x, y)
    local configs = SkillModel.GetConfigs()
    for _, v in pairs(configs) do
        if v.skill_type2 == type and v.position.x == x and v.position.y == y then
            return v
        end
    end
end

-- 获取指定类别已使用技能点总数
function SkillModel.GetPointAmountOfType(type, page)
    local amount = 0
    local skills = Model.GetInfo(ModelType.PlayerSkills, page).Skills
    for _, v in pairs(skills) do
        local config = SkillModel.GetConfigById(v.Id)
        if config.skill_type2 == type then
            amount = amount + v.Level
        end
    end

    return amount
end

--获取主动技能可使用技能数量
function SkillModel.GetActiveSkillUseIcon()
    return SkillModel.GetSkillMaxNum()
end

--获取主动技能最多项
function SkillModel.GetSkillMaxNum()
    local imageSkillIcon = {}
    local isActiveflag = false
    local activeAmount1  = 0
    local activeAmount2  = 0
    local activeAmount3  = 0
    isActiveflag,activeAmount1,activeAmount2,activeAmount3  = SkillModel.IsActiveSkill()
    if isActiveflag then
        local amounts = {}
        --当所有主动技能点数相同时
        local passiveAmount1 = SkillModel.GetPointAmountOfType(_G.Global.PlayerSkillBattle, SkillModel.GetCurPage())
        local passiveAmount2 = SkillModel.GetPointAmountOfType(_G.Global.PlayerSkillProgress, SkillModel.GetCurPage())
        local passiveAmount3 = SkillModel.GetPointAmountOfType(_G.Global.PlayerSkillAssist, SkillModel.GetCurPage())

        amounts[1] = {Amount = activeAmount1,Amount2 = passiveAmount1, Type = _G.Global.PlayerSkillBattle}
        amounts[2] = {Amount = activeAmount2,Amount2 = passiveAmount2, Type = _G.Global.PlayerSkillProgress}
        amounts[3] = {Amount = activeAmount3,Amount2 = passiveAmount3, Type = _G.Global.PlayerSkillAssist}
        table.sort(
            amounts,
            function(a, b)
                if a.Amount == b.Amount then
                    if a.Amount2 == b.Amount2 then
                        return a.Type < b.Type
                    else
                        return a.Amount2 > b.Amount2
                    end
                else
                    return a.Amount > b.Amount
                end
            end
        )
        --战斗
        if amounts[1].Type == _G.Global.PlayerSkillBattle then
            --发展
            imageSkillIcon = {"Common", "btn_fight_commander_01"}
        elseif amounts[1].Type == _G.Global.PlayerSkillProgress then
            --协助
            imageSkillIcon = {"Common", "btn_develop_commander_01"}
        elseif amounts[1].Type == _G.Global.PlayerSkillAssist then
            imageSkillIcon = {"Common", "btn_assist_01"}
        end

        return imageSkillIcon
    else
        return nil
    end
end
--是否有主动技能
function SkillModel.IsActiveSkill()
    local amount1 = 0
    local amount2 = 0
    local amount3 = 0
    local skills = Model.GetInfo(ModelType.PlayerSkills, SkillModel.GetCurPage()).Skills
    for _, v in pairs(skills) do
        local config = SkillModel.GetConfigById(v.Id)
        if config.skill_type == 2 then
            if _G.Global.PlayerSkillBattle == config.skill_type2 then
                amount1 = amount1 + v.Level
            elseif _G.Global.PlayerSkillProgress == config.skill_type2 then
                amount2 = amount2 + v.Level
            elseif _G.Global.PlayerSkillAssist == config.skill_type2 then
                amount3 = amount3 + v.Level
            end
        end
    end
    if amount1 > 0 or amount2 > 0 or amount3 > 0  then
        return true,amount1,amount2,amount3
    else
        return false,amount1,amount2,amount3
    end
end


return SkillModel
