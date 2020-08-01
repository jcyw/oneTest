--[[
    Author: songzeming
    Function: Buff增益相关
]]
local BuffModel = {}
local RES_PRODUCE = 10100 --资源产量 基础产量值*(1+K%)
local TRAIN_SPEED = 10300 --造兵速度 造兵时间=基础时间/(1+K%)
local TRAIN_TRAP_SPEED = 16006 --造陷阱速度 陷阱时间=基础时间/(1+K%)
local TRAIN_AMOUNT = 16104 --单次招募士兵更多 单次募兵数=单次募兵数+K
local TRAIN_TRAP_LIMIT = 16000 --(安保武器容量)陷阱数量上限增加 基础上限+K
local TRAIN_TRAP_RES_EXPEND = 16001 --陷阱消耗减少% 基础消耗*(1-K%)
local Wall_DEFENSE_VALUE = 10700 -- (防御值)兵种防御值增加_所有兵种 防御值 = (基础防御+防御值_add)*(1+防御百分比1+防御百分比2+…)
local CURE_ARMY_LIMIT = 16205 --伤兵上限 医院容量+K
local CURE_ARMY_LIMIT_PERC = 16206 --伤兵上限 伤兵上限=医院容量*（1+K%)
local CURE_ARMY_RES_EXPEND = 16207 --治疗消耗资源降低 治疗资源系数=heal_res*(1-K%)
local CURE_ARMY_SPEED = 16211 --伤兵恢复速度提升、治疗 治疗时间=治疗时间/(1+K%)
local BUILD_SPEED = 16007 --建筑速度 建筑时间=基础时间/(1+K%)
local ENERGY_SPEED = 16004 -- 体力恢复速度  实际体力恢复速度=单位时间恢复体力值/单位时间*（1+K%）
local EXPEDITION_LIMIT = 16100 --(出征上限)出征队列增加 行军队伍数=1+K
local ASSEMBLY_LIMIT = 16307 --(集结成员数目)战争大厅集结部队数增加 集结部队数+K
local EXPEDITION_AMOUNT = 16101 --单支部队兵力上限增加 统率值
local EXPEDITION_AMOUNT_PERCENT = 16102 --单支部队兵力上限增加 统率百分比
local UNION_HELP_TIMES = 16310 --帮助人数上限增加 基础人数+K
local UNION_HELP_TIME = 16305 --联盟帮助时间 帮助时间+K
local UNION_HELP_REINFORCEMENT_LIMIT = 16304 --(援军容纳上限)援军上限 基础上限+K
local CITY_PROTECT_STATUS = 16012 --保护罩
local TECH_RESEARCH_SPEED = 16008 --科技研究加速
local WarehouseCapacityValue = 16200 --仓库容量
local WarehouseCapacityPerc = 16201 --仓库容量
local SKILL_COOLINT = 16508 --j技能冷却时间
local INVESTIGATION_CONSUMPTION = 16513
local INVESTIGATION_SPEED = 10401
--数值
local GetValue = function(baseId)
    local buff = Model.Buffs[baseId]
    if not buff then
        return 0
    end
    return buff.Value
end
--百分比
local GetValuePerc = function(baseId, symbol)
    local buff = Model.Buffs[baseId]
    if not buff then
        return 1
    end
    return 1 + symbol * buff.Value / 10000
end

--仓库容量buff
function BuffModel.GetWarehouseCapacity(baseValue)
    local buffvalue = GetValue(WarehouseCapacityValue)
    local buffPrec = GetValuePerc(WarehouseCapacityPerc, 1) - 1
    return buffvalue + buffPrec * baseValue
end
--资源产量 基础产量值*(1+K%)
function BuffModel.GetResProduce(category)
    local buffAll = GetValuePerc(RES_PRODUCE, 1) - 1
    local buffSingle = GetValuePerc(RES_PRODUCE + category, 1) - 1
    return 1 + buffAll + buffSingle
end
--士兵 训练速度 造兵时间=基础时间/(1+K%)
function BuffModel.GetArmySpeed(armyId)
    local armyConf = ConfigMgr.GetItem("configArmys", armyId)
    local armyType = armyConf.army_type
    local armyLevel = armyConf.level

    local buff = 1
    --用于计算单个兵总
    local buff_func = function(id, index, level)
        local findBuff = Model.Buffs[id]
        if not findBuff then
            return
        end
        if index and armyType ~= index then
            return
        end
        if level and armyLevel ~= level then
            return
        end
        buff = buff + findBuff.Value / 10000
        return true
    end

    --用于计算所有兵总
    local buff_func2 = function(id, level)
        local findBuff = Model.Buffs[id]
        if not findBuff then
            return
        end
        if level and armyLevel ~= level then
            return
        end
        buff = buff + findBuff.Value / 10000
        return true
    end

    local baseId = TRAIN_SPEED
    --造兵速度
    buff_func(baseId)
    local findit = false
    --分类型造兵速度
    for i = 1, 4 do
        baseId = baseId + 1
        findit = buff_func(baseId, i)
        if findit then
            findit = false
            break
        end
    end
    local curId = baseId
    --7级以下造兵速度
    for lv = 1, 7 do
        if findit then
            break
        end
        baseId = curId
        for i = 1, 4 do
            baseId = baseId + 1
            findit = buff_func(baseId, i, lv)
            if findit then
                break
            end
        end
    end
    baseId = curId + 4
    --8-10级造兵速度
    for lv = 8, 10 do
        if findit then
            break
        end
        for i = 1, 4 do
            baseId = baseId + 1
            findit = buff_func(baseId, i, lv)
            if findit then
                break
            end
        end
    end

    curId = baseId
    for lv = 1, 9 do
        if findit then
            break
        end
        baseId = curId
        for i = 1, 3 do
            baseId = baseId + 1
            findit = buff_func2(baseId, lv)
            if findit then
                break
            end
        end
    end

    return buff
end

--营房用 训练速度 造兵时间=基础时间/(1+K%)
function BuffModel.GetTrainSpeed()
    return GetValuePerc(TRAIN_SPEED, 1)
end

--陷阱 制造速度 造兵时间=基础时间/(1+K%)
function BuffModel.GetTrapSpeed()
    return GetValuePerc(TRAIN_TRAP_SPEED, 1)
end

--单次招募士兵更多 单次募兵数=单次募兵数+K
function BuffModel.GetArmyAmount()
    return GetValue(TRAIN_AMOUNT)
end

--陷阱数量上限增加 基础上限+K
function BuffModel.GetTrapLimit()
    return GetValue(TRAIN_TRAP_LIMIT)
end

--陷阱消耗减少% 基础消耗*(1-K%)
function BuffModel.GetTrapResExpend()
    return GetValuePerc(TRAIN_TRAP_RES_EXPEND, -1)
end

--伤兵上限 医院容量+K
function BuffModel.GetCureArmyLimit()
    return GetValue(CURE_ARMY_LIMIT)
end

--伤兵上限 伤兵上限=医院容量*（1+K%)
function BuffModel.GetCureArmyLimitPerc()
    return GetValuePerc(CURE_ARMY_LIMIT_PERC, 1)
end

--治疗消耗资源降低 治疗资源系数=heal_res*(1-K%)
function BuffModel.GetCureArmyResExpend()
    return GetValuePerc(CURE_ARMY_RES_EXPEND, -1)
end

--伤兵恢复速度提升、治疗 治疗时间=治疗时间/(1+K%)
function BuffModel.GetCureArmySpeed()
    return GetValuePerc(CURE_ARMY_SPEED, 1)
end

--建筑速度 建筑时间=基础时间/(1+K%)
function BuffModel.GetBuildSpeed()
    return GetValuePerc(BUILD_SPEED, 1)
end
--体力恢复速度
function BuffModel.GetEnergyBuff()
    return GetValuePerc(ENERGY_SPEED, 1)
end

--出征上限
function BuffModel.GetExpeditionLimit()
    return GetValue(EXPEDITION_LIMIT)
end

--单支部队兵力上限增加 统率值 总出征 = (基础统率+统率值_add)*(1+统率百分比1+统率百分比2+…)
function BuffModel.GetExpeditionAmount()
    return GetValue(EXPEDITION_AMOUNT)
end
-- 单支部队兵力上限增加 统率百分比
function BuffModel.GetExpeditionAmountPerc()
    return GetValuePerc(EXPEDITION_AMOUNT_PERCENT, 1)
end

--集结成员数目
function BuffModel.GetAssemblyLimit()
    return GetValue(ASSEMBLY_LIMIT)
end

--联盟帮助人数上限
function BuffModel.GetUnionHelpTimes()
    return GetValue(UNION_HELP_TIMES)
end
--联盟帮助时间
function BuffModel.GetUnionHelpTime()
    return GetValue(UNION_HELP_TIME)
end
--援军容纳上限
function BuffModel.GetUnionReinforcementLimit()
    return GetValue(UNION_HELP_REINFORCEMENT_LIMIT)
end

--城墙防御值
function BuffModel.GetWallDefenseValue()
    return GetValue(Wall_DEFENSE_VALUE)
end

--是否有保护罩
function BuffModel.CheckIsProtect()
    local tmp = GetValue(CITY_PROTECT_STATUS)
    return tmp == 1
end

--研究加速
function BuffModel.GetTechResearchSpeed()
    return GetValuePerc(TECH_RESEARCH_SPEED, 1)
end

--主动技能冷却
function BuffModel.GetSkillCooling()
    return GetValuePerc(SKILL_COOLINT, -1)
end

--侦查消耗
function BuffModel.GetInvestigationConsumption()
    return GetValuePerc(INVESTIGATION_CONSUMPTION, -1)
end

--侦查速度
function BuffModel.GetInvestigationSpeed()
    return GetValuePerc(INVESTIGATION_SPEED, 1)
end

return BuffModel
