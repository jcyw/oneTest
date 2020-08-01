local TrainModel = {}

local Model = _G.Model

local ArmyTypeList = {}

-------------------------------------------------兵种配置表 conf
--通过兵种配置ID获取配置
function TrainModel.GetConf(armId)
    return ConfigMgr.GetItem('configArmys', armId)
end
--通过兵种配置ID获取兵种解锁等级
function TrainModel.GetUnlockLevel(armId)
    local conf = TrainModel.GetConf(armId)
    if not conf then
        return
    end
    return conf.building
end
--通过兵种配置ID获取兵种是否解锁
function TrainModel.GetArmUnlock(armId)
    local unlock = TrainModel.GetUnlockLevel(armId)
    for _, v in pairs(Model.Buildings) do
        if v.ConfId == TrainModel.GeBaseById(unlock) and unlock <= (v.ConfId + v.Level) then
            return true
        end
    end
    return false
end
--通过兵种配置ID获取兵种战斗力
function TrainModel.GetArmPower(armId)
    local conf = TrainModel.GetConf(armId)
    if not conf then
        return
    end
    return conf.power
end
--通过建筑配置ID对应兵种
function TrainModel.GetArm(confId)
    local data = ConfigMgr.GetItem('configBuildings', confId)
    if not data then
        return
    end
    if not data.army then
        return
    end
    return data.army
end
--通过建筑配置ID获取兵种基础ID
function TrainModel.GetBaseArmId(confId)
    local arm = TrainModel.GetArm(confId)
    if not arm then
        return
    end
    return arm.base_level
end
--通过兵种配置ID获取已解锁部队信息
function TrainModel.GetUnlockInfo(confId, currentLv)
    local arm = TrainModel.GetArm(confId)
    if not arm then
        return
    end
    local info = {}
    local baseId = arm.base_level
    for k = 1, arm.amount do
        local armId = baseId + k - 1
        local buildLv = TrainModel.GetLevelById(armId)
        if currentLv >= buildLv then
            table.insert(info, buildLv)
        end
    end
    return info
end
--兵种排序 以T级排序,高在上,同T级为坦克>战车>大于直升机>重型载具
function TrainModel.SortArmy(armies)
    table.sort(armies, function(a, b)
        local aconf = TrainModel.GetConf(a.ConfId)
        local bconf = TrainModel.GetConf(b.ConfId)
        local flag
        if aconf.level == bconf.level then
            if aconf.army_type == bconf.army_type then
                flag = false
            else
                flag = aconf.army_type > bconf.army_type
            end
        else
            flag = aconf.level > bconf.level
        end
        return flag
    end)
end

-------------------------------------------------兵种配置 Model.Armies
--通过兵种配置ID获取兵种数量
function TrainModel.GetArmAmount(confId)
    if not Model.Armies[confId] then
        return 0
    end
    return Model.Armies[confId].Amount or 0
end
--通过兵种配置ID获取兵种总数 (包括城内士兵、出征士兵、伤兵)
function TrainModel.GetArmTotal(confId)
    local num = 0
    if Model.Armies[confId] then
        num = num + Model.Armies[confId].Amount
    end
    if Model.InjuredArmies[confId] then
        num = num + Model.InjuredArmies[confId].Amount
    end
    local ArmiesModel = import("Model/ArmiesModel")
    local missions = ArmiesModel.GetMissionArmies()
    for _, v in pairs(missions) do
        for _, vv in pairs(v.armies) do
            if confId == vv.ConfId then
                num = num + vv.Amount
            end
        end
    end
    return num
end

-------------------------------------------------兵种国际化
--通过兵种配置ID获取兵种名称 I18n
function TrainModel.GetName(armId)
    return ConfigMgr.GetI18n('configI18nArmys', armId .. '_NAME')
end
--通过兵种配置ID获取兵种描述 I18n
function TrainModel.GetDesc(armId)
    return ConfigMgr.GetI18n('configI18nArmys', armId .. '_DESC')
end
--通过兵种配置ID获取兵种解释 I18n
function TrainModel.GetExplain(armId)
    return ConfigMgr.GetI18n('configI18nArmys', armId .. '_EXPLAIN')
end
--通过名称获取兵种国际化 I18n
function TrainModel.GetArmyI18n(title)
    return ConfigMgr.GetI18n('configI18nArmys', title)
end
--通过名称获取技能国际化 I18n
function TrainModel.GetSkillI18n(title)
    return ConfigMgr.GetI18n('configI18nSkills', title)
end

-------------------------------------------------其他
--通过兵种配置ID获取兵种基础ID
function TrainModel.GeBaseById(armId)
    local str = tostring(armId)
    local baseId = string.sub(str, 1, #str - 2) .. '00'
    return tonumber(baseId)
end
--通过兵种配置ID获取等级
function TrainModel.GetLevelById(armId)
    local unlock = TrainModel.GetUnlockLevel(armId)
    local str = tostring(unlock)
    return tonumber(string.sub(str, #str - 2))
end
--通过兵种配置ID获取兵种图片 大图
function TrainModel.GetImageNormal(armId)
    local conf = TrainModel.GetConf(armId)
    if not conf then
        return
    end
    return UITool.GetIcon(conf.army_model)
end
--通过兵种配置ID获取兵种图片 大图
function TrainModel.GetImageAvatar(armId)
    local conf = TrainModel.GetConf(armId)
    if not conf then
        return
    end
    return UITool.GetIcon(conf.army_port)
end

--通过兵种配置ID获取兵种背景
function TrainModel.GetBgAvatar(armId)
    local conf = TrainModel.GetConf(armId)
    if not conf then
        return
    end
    return UITool.GetIcon(conf.amry_icon_bg)
end

--获取兵种类型图标
function TrainModel.GetArmIcon(arm)
    return UIPackage.GetItemURL("IconArm", "armytype_"..arm)
end

--通过建筑ConfId获取兵种数量
function TrainModel.GetArmyNumberByConfId(confId)
    local conf = ConfigMgr.GetItem("configBuildings", confId)
    local amount = 0
    for i = 1, conf.army.amount do
        local armyId = conf.army.base_level + i - 1
        amount = amount + TrainModel.GetArmAmount(armyId)
    end
    return amount
end

function TrainModel.CheckAdvanced(armyId)
    local conf = TrainModel.GetConf(armyId)
    if not conf then
        return
    end

    if TrainModel.GetArmAmount(armyId) == 0 then
        return
    end

    TrainModel.InitArmyTypeList()

    local maxArmyId = nil
    local maxLevel = 0
    for _, v in ipairs(ArmyTypeList[conf.army_type]) do
        if conf.level < v.level and maxLevel < v.level and conf.arm == v.subType and TrainModel.GetArmUnlock(v.armyId) then
            maxArmyId = v.armyId
        end
    end

    if not maxArmyId then
        return
    end
    
    return true, maxArmyId
end

function TrainModel.InitArmyTypeList()
    if next(ArmyTypeList) then
        return
    end

    for _, v in ipairs(ConfigMgr.GetList("configArmys")) do
        if not ArmyTypeList[v.army_type] then
            ArmyTypeList[v.army_type] = {}
        end
        table.insert(ArmyTypeList[v.army_type], {
            armyId = v.id,
            subType = v.arm,
            level = v.level,
            power = v.power
        })
    end
end

function TrainModel.GetMaxArmyPower(armyId)
    local conf = TrainModel.GetConf(armyId)
    if not conf then
        return
    end

    TrainModel.InitArmyTypeList()
    if next(ArmyTypeList) == nil then
        return
    end

    local array = ArmyTypeList[conf.army_type]
    return array[#array].power
end

function TrainModel.GetBuildingConfIdByArmyId(armyId)
    local conf = TrainModel.GetConf(armyId)
    if not conf then
        return
    end
    
    return math.floor(conf.building / 100) * 100
end

function TrainModel.GetResDifferent(armyId, advancedArmyId)
    local conf = TrainModel.GetConf(armyId)
    local confAdvanced = TrainModel.GetConf(advancedArmyId)
    if not conf or not confAdvanced then
        return
    end

    local array = {}
    for _, v in pairs(conf.res_req) do
        for _, vv in pairs(confAdvanced.res_req) do
            if v.category == vv.category then
                table.insert(array, {
                    category = v.category,
                    amount = vv.amount - v.amount
                })
                break
            end
        end
    end
    return array
end

return TrainModel