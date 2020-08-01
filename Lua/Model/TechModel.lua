-- 科技Model
local GD = _G.GD
local TechModel = {}

local EventModel = import("Model/EventModel")
local BuildModel = import("Model/BuildModel")

TechModel.TechFinishCallBacks = {}
-- TechModel.Building = nil

function TechModel.GetTechBuilding(techType)
    if techType == Global.BeastTech then
        return BuildModel.CheckExist(Global.BuildingBeastScience)
    else
        return BuildModel.CheckExist(Global.BuildingScience)
    end
end

function TechModel.GetTechModel(techType)
    if techType == Global.BeastTech then
        return Model.GetMap(ModelType.BeastTechs)
    else
        return Model.GetMap(ModelType.Techs)
    end
    -- return isBeast and Model.GetMap(ModelType.BeastTechs) or Model.GetMap(ModelType.Techs)
end

-- 获取正在升级的科技（同时只有一个升级科技）
function TechModel.GetUpgradeTech(techType)
    local events = {}
    if techType == Global.BeastTech then
        events = EventModel.GetUpgradeEventByCategory(Global.EventTypeBeastTech)
    else
        events = EventModel.GetUpgradeEventByCategory(Global.EventTypeTech)
    end
    -- local events = EventModel.GetUpgradeEventByCategory(isBeast and Global.EventTypeBeastTech or Global.EventTypeTech)
    if #events > 0 then
        return events[1]
    end
end

-- 获取科技研究倒计时
function TechModel.GetResearchTime(techType)
    local upgrade = TechModel.GetUpgradeTech(techType)
    if not upgrade then
        return
    end
    return upgrade.FinishAt - Tool.Time()
end

-- 通过配置Id获取
function TechModel.FindByConfId(confId)
    local model = Model.Find(ModelType.Techs, confId)
    if not model then
        model = Model.Find(ModelType.BeastTechs, confId)
    end
    return model
end

-- 获取科技名字
function TechModel.GetTechName(confId)
    return ConfigMgr.GetI18n("configI18nTechs", confId .. "_NAME")
end

-- 获取科技说明
function TechModel.GetTechDesc(confId)
    return ConfigMgr.GetI18n("configI18nTechs", confId .. "_DESC")
end

-- 获取科技类型文本
function TechModel.GetTechTypeName(techType, tab)
    return ConfigMgr.GetI18n("configI18nTechs", (techType == Global.BeastTech and "BEAST_TECHTYPE_" or "TECHTYPE_") .. tab)
end

-- 获取前置科技Model
function TechModel.GetPreTechModel(techType, confId)
    local data = {}
    local hasPreTech = false
    local config = TechModel.GetTechConfigItem(techType, confId + 1)
    if config.tech_condition then
        hasPreTech = true
        for _, v in pairs(config.tech_condition) do
            local model = TechModel.FindByConfId(v.confId)
            if model and model.Level > 0 then
                table.insert(data, model)
            end
        end
    end

    return data, hasPreTech
end

-- 更新model
--[[
    ConfId
    Level
    Type
]]
function TechModel.UpdateTechModel(tech)
    if tech.Type == Global.BeastTech then
        Model.Create(ModelType.BeastTechs, tech.ConfId, tech)
    else
        Model.Create(ModelType.Techs, tech.ConfId, tech)
    end
end

function TechModel.GetDisplayConfigItem(techType, id)
    if techType == Global.BeastTech then
        return ConfigMgr.GetItem("configBeastTechDisplays", id)
    else
        return ConfigMgr.GetItem("configTechDisplays", id)
    end
end

function TechModel.GetDisplayConfigList(techType)
    if techType == Global.BeastTech then
        return ConfigMgr.GetList("configBeastTechDisplays")
    else
        return ConfigMgr.GetList("configTechDisplays")
    end
end

function TechModel.GetTechConfigItem(techType, id)
    if techType == Global.BeastTech then
        return ConfigMgr.GetItem("configBeastTechs", id)
    else
        return ConfigMgr.GetItem("configTechs", id)
    end
end

function TechModel.GetTechConfigList(techType)
    if techType == Global.BeastTech then
        return ConfigMgr.GetList("configBeastTechs")
    else
        return ConfigMgr.GetList("configTechs")
    end
end

-- 获取指定类别里正在升级的技能
function TechModel.GetUpdateDataByTab(tab, techType)
    local upgrade = TechModel.GetUpgradeTech(techType)
    if upgrade then
        local config = TechModel.GetDisplayConfigItem(techType, upgrade.TargetId)
        if config.tab == tab then
            return upgrade
        end
    end
end

-- 根据技能配置Id获取分类
function TechModel.GetTabByConfId(confId, techType)
    local config = TechModel.GetDisplayConfigItem(techType, confId)
    return config.tab
end

-- 判断有没有学指定科技
function TechModel.CheckLearnTechById(configId)
    local models = Model.GetMap(ModelType.Techs)
    for k, v in pairs(models) do
        if v.ConfId == configId and v.Level > 0 then
            return true
        end
    end

    local beastModels = Model.GetMap(ModelType.BeastTechs)
    for k, v in pairs(beastModels) do
        if v.ConfId == configId and v.Level > 0 then
            return true
        end
    end

    return false
end

--检测科研中心是否存在研究了
function TechModel.CheckLearnTechHave()
    local models = Model.GetMap(ModelType.Techs)
    for k, v in pairs(models) do
        if v.Level > 0 then
            return true
        end
    end
    local beastModels = Model.GetMap(ModelType.BeastTechs)
    for k, v in pairs(beastModels) do
        if v.Level > 0 then
            return true
        end
    end

    return false
end

-- 判断是否已经拥有某个等级的某个科技
function TechModel.CheckTechByLv(configId, level)
    local models = Model.GetMap(ModelType.Techs)
    for k, v in pairs(models) do
        if v.ConfId == configId and v.Level >= level then
            return true
        end
    end

    local beastModels = Model.GetMap(ModelType.BeastTechs)
    for k, v in pairs(beastModels) do
        if v.ConfId == configId and v.Level >= level then
            return true
        end
    end

    return false
end

-- 技能分类是否解锁
function TechModel.CheckTabEnabled(confId, techType)
    if techType == Global.BeastTech then
        if confId == 2 then
            return Model.Player.isUnlockKingkong
        end
    end

    return true
end

-- 获取每个分类完成百分比
function TechModel.GetTabPercent(tabId, techType)
    local tab = tabId
    local curAmountLv = 0
    local maxAmountLv = 0

    local models = TechModel.GetTechModel(techType)
    for k, v in pairs(models) do
        local config = TechModel.GetDisplayConfigItem(techType, v.ConfId)
        if config ~= nil and config.tab == tab then
            curAmountLv = curAmountLv + v.Level
        end
    end

    local configs = TechModel.GetDisplayConfigList(techType)
    for k, v in pairs(configs) do
        if v.tab == tab then
            maxAmountLv = maxAmountLv + v.max_lv
        end
    end

    return math.ceil((curAmountLv / maxAmountLv) * 100)
end

--如果有科技完成奖励则领取奖励
function TechModel.TryGetScienceAward(type)
    if (type == Global.NormalTech and Model.ResearchGift) or (type == Global.BeastTech and Model.BeastResearchGift) then
        Net.Techs.GetGift(
            type,
            function(rsp)
                if rsp.Fail then
                    return
                end
                --播放领奖动画
                if rsp.Gift then
                    local reward = {
                        Category = Global.RewardTypeRes,
                        ConfId = rsp.Gift.Category,
                        Amount = rsp.Gift.Amount
                    }
                    UITool.ShowReward({reward})
                end

                if type == Global.BeastTech then
                    Model.BeastResearchGift = false
                else
                    Model.ResearchGift = false
                end
            end
        )
    end
end

-- 获取计算buff后的研究时间
function TechModel.GetRealResearchTime(config)
    return config.duration / BuffModel.GetTechResearchSpeed()
end

-- 检查科技是否解锁
function TechModel.CheckUnlock(config, techType)
    local model = TechModel.GetTechModel(techType)[config.id]
    if model ~= nil and model.Level < config.max_lv then
        local nextLv = TechModel.GetTechConfigItem(techType, config.id + model.Level + 1)
        if nextLv == nil or (TechModel.CheckTechCondition(nextLv.tech_condition) and TechModel.CheckBuildingCondition(nextLv.building_condition)) then
            return true
        end
    end

    local lv1 = TechModel.GetTechConfigItem(techType, config.id + 1)
    if lv1 ~= nil and TechModel.CheckTechCondition(lv1.tech_condition) and TechModel.CheckBuildingCondition(lv1.building_condition) then
        return true
    end

    return false
end

-- 检查资源是否满足升级, 不满足则返回缺少资源
function TechModel.CheckTechUpgradeRes(config, techType)
    local model = TechModel.GetTechModel(techType)[config.id]
    if model ~= nil and model.Level >= config.max_lv then
        return false
    end

    if model ~= nil and model.Level < config.max_lv then
        local nextLv = TechModel.GetTechConfigItem(techType, config.id + model.Level + 1)
        local pass, res = TechModel.CheckResConditionDetail(nextLv.res_req)
        if nextLv ~= nil and pass then
            return true
        else
            return false, res
        end
    end

    local lv1 = TechModel.GetTechConfigItem(techType, config.id + 1)
    local pass, res = TechModel.CheckResConditionDetail(lv1.res_req)
    if lv1 ~= nil and pass then
        return true
    else
        return false, res
    end

    return false
end

-- 检查是否有科技可以升级
function TechModel.CheckTechCanUpgradeOfAll(techType)
    local configs = TechModel.GetDisplayConfigList(techType)
    for _, v in pairs(configs) do
        if TechModel.CheckTechCanUpgrade(v, techType, false, true) then
            return true
        end
    end

    return false
end

-- 检查是否可以升级
function TechModel.CheckTechCanUpgrade(config, techType, checkUpgrade, ignoredRes)
    if checkUpgrade then
        --检查是否有科技正在升级
        local upgrade = TechModel.GetUpgradeTech(techType)
        if upgrade ~= nil then
            return false
        end
    end

    local model = TechModel.GetTechModel(techType)[config.id]
    if model ~= nil and model.Level >= config.max_lv then
        return false
    end

    if model ~= nil and model.Level < config.max_lv then
        local nextLv = TechModel.GetTechConfigItem(techType, config.id + model.Level + 1)
        if
            nextLv ~= nil and TechModel.CheckTechCondition(nextLv.tech_condition) and TechModel.CheckBuildingCondition(nextLv.building_condition) and
                (ignoredRes and true or TechModel.CheckResCondition(nextLv.res_req))
         then
            return true, nextLv
        else
            return false
        end
    end

    local lv1 = TechModel.GetTechConfigItem(techType, config.id + 1)
    if
        lv1 ~= nil and TechModel.CheckTechCondition(lv1.tech_condition) and TechModel.CheckBuildingCondition(lv1.building_condition) and
            (ignoredRes and true or TechModel.CheckResCondition(lv1.res_req))
     then
        return true, lv1
    end

    return false
end

function TechModel.CheckTechCondition(conditions)
    if conditions == nil then
        return true
    end

    for k, v in pairs(conditions) do
        if not TechModel.CheckTechByLv(v.confId, v.level) then
            return false
        end
    end

    return true
end

function TechModel.CheckBuildingCondition(conditions)
    if conditions == nil then
        return true
    end

    for k, v in pairs(conditions) do
        local buildModel = BuildModel.FindByConfId(v.confId)
        if buildModel == nil or v.level > buildModel.Level then
            return false
        end
    end

    return true
end

function TechModel.CheckResCondition(conditions)
    if conditions == nil then
        return true
    end

    for k, v in pairs(conditions) do
        if v.amount > 0 and GD.ResAgent.Amount(v.category) < v.amount then
            return false
        end
    end

    return true
end

function TechModel.CheckResConditionDetail(conditions)
    if conditions == nil then
        return true
    end

    local lackRes = {}
    for _, v in pairs(conditions) do
        local amount = GD.ResAgent.Amount(v.category)
        if v.amount > 0 and amount < v.amount then
            table.insert(lackRes, {category = v.category, amount = v.amount - amount})
        end
    end

    if #lackRes > 0 then
        return false, lackRes
    else
        return true
    end
end

return TechModel
