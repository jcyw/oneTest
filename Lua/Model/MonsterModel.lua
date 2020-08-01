--[[
    Author:muyu
    Function:Monster配置数据
]]
local MonsterModel = {}

local Monstertable = {}

local BloodCTR = {
    Green = "Green", --精力充沛
    Orange = "Orange", --轻伤
    Red = "Red", --重伤
    Dark = "Dark" --濒死
}

local MonsterBaseId = {
    Godzilla = 108000, --哥斯拉
    KingKong = 108100 --金刚
}

--刷新巨兽列表
function MonsterModel.RequestGetMonsterList(isLogin, callback)
    Net.GiantBeast.GetGiantBeastInfo(
        function(rsp)
            Monstertable = rsp.Info
            local canopen = MonsterModel.CheckoutMonsters()
            if canopen then
                if #Monstertable > 1 then
                    -- MonsterModel.SortMonster(Monstertable)
                    table.sort(Monstertable, function(a, b)
                        return a.Id < b.Id
                    end)
                end
                if callback then
                    callback(Monstertable)
                end
            else
                if not isLogin then
                    TipUtil.TipById(50060)
                end
            end
        end
    )
end

--刷新巨兽血量
function MonsterModel.RefreshMonsterHealth(id, add, isHealing)
    for _, v in pairs(Monstertable) do
        if v.Id == id then
            v.Health = v.Health + add
            v.DisplayHealth = v.Health
            v.Healing = isHealing
            return
        end
    end
end

function MonsterModel.GetBeastModels()
    return Model.GiantBeasts
end

function MonsterModel.CheckoutMonsters()
    -- for i = #Monstertable, 1, -1 do
    --     if MonsterModel.IsUnlock(Monstertable[i].Id) then
    --         table.remove(Monstertable, i)
    --     end
    -- end
    -- if #Monstertable == 0 then
    --     return false
    -- else
    --     return true
    -- end
    for _,v in pairs(Monstertable) do
        if MonsterModel.IsUnlock(v.Id) then
            return true
        end
    end

    return false
end

function MonsterModel.IsUnlock(id)
    local buildId = BuildModel.GetConfIdById(id)
    return BuildModel.CheckBeastUnlock(buildId)
end

function MonsterModel.GetMonsterHurtNum()
    local amount = 0
    for _, v in pairs(MonsterModel.GetBeastModels()) do
        --有伤兵
        if MonsterModel.GetMonsterRealMaxHealth(v) > v.DisplayHealth then
            amount = amount + 1
        end
    end
    return amount
end

function MonsterModel.GetMonsterList()
    return Monstertable
end

--获得是否有巨兽正在治疗
function MonsterModel.GetIsHealing()
    for _, v in pairs(Monstertable) do
        if v.Healing then
            return v.Healing
        end
    end
    return false
end

--获取正在治疗巨兽
function MonsterModel.GetHealingId()
    for _,v in pairs(Monstertable) do
        if v.Healing then
            return v
        end
    end
end

--获得巨兽的血量百分比数值
function MonsterModel.GetBloodPercent(index, cureNum)
    -- local monsterId = MonsterModel.GetMonsterRealID(Monstertable[index].Id, Monstertable[index].Level)
    -- local MonsterConf = ConfigMgr.GetItem("configArmys", monsterId)
    local maxHealth = MonsterModel.GetMonsterRealMaxHealth(Monstertable[index])
    local monsterBloodPercent = (Monstertable[index].DisplayHealth + cureNum) / maxHealth * 100
    return monsterBloodPercent < 1 and 1 or monsterBloodPercent
end

--获得巨兽的血量
function MonsterModel.GetMonsterDisplayHealth(index)
    return Monstertable[index].DisplayHealth
end

--获得巨兽的血量损失值
function MonsterModel.GetBloodMaxNumber(index)
    return MonsterModel.GetMonsterRealMaxHealth(Monstertable[index]) - Monstertable[index].DisplayHealth
end

--获得巨兽血量显示颜色
function MonsterModel.GetBloodColor(bloodpercent)
    if bloodpercent >= 1 and bloodpercent <= 10 then
        return BloodCTR.Dark
    elseif bloodpercent >= 11 and bloodpercent <= 60 then
        return BloodCTR.Red
    elseif bloodpercent >= 61 and bloodpercent <= 90 then
        return BloodCTR.Orange
    else
        return BloodCTR.Green
    end
end

--获得巨兽对应兵种信息
function MonsterModel.GetMonsterTypeId(monsterId)
    return ConfigMgr.GetItem("configArmys", monsterId).arm
end

--巨兽显示排序 濒死>重伤>轻伤>精力充沛，相同状态T级高的在上,正在治疗的优先显示切无法切换下边的治疗状态显示
function MonsterModel.SortMonster(monsters)
    table.sort(
        monsters,
        function(a, b)
            local aRealId = MonsterModel.GetMonsterRealID(a.Id, a.Level)
            local bRealId = MonsterModel.GetMonsterRealID(b.Id, b.Level)
            local amonsterconf = ConfigMgr.GetItem("configArmys", aRealId)
            local bmonsterconf = ConfigMgr.GetItem("configArmys", bRealId)
            local amonsterbloodpercent = math.floor(a.DisplayHealth / MonsterModel.GetMonsterRealMaxHealth(a) * 100)
            local bmonsterbloodpercent = math.floor(b.DisplayHealth / MonsterModel.GetMonsterRealMaxHealth(b) * 100)
            local flag
            if a.Healing == b.Healing then
                if amonsterbloodpercent == bmonsterbloodpercent then
                    if a.Level == b.Level then
                        flag = a.Id > b.Id
                    else
                        flag = a.Level > b.Level
                    end
                else
                    flag = amonsterbloodpercent < bmonsterbloodpercent
                end
            else
                flag = a.Healing
            end
            return flag
        end
    )
end

function MonsterModel.GetMonsterRealID(id, level)
    return id + level - 1
end

--获取计算buff后的巨兽最大血量
function MonsterModel.GetMonsterRealMaxHealth(info)
    local maxHealth = Model.GiantBeasts[info.Id].MaxHealth
    if maxHealth > 0 then
        return maxHealth
    else
        local monsterId = MonsterModel.GetMonsterRealID(info.Id, info.Level)
        local MonsterConf = ConfigMgr.GetItem("configArmys", monsterId)
        if not MonsterConf then
            return 0
        end
        -- 所有巨兽增加血量上限
        local allBuff = Model.GetInfo(ModelType.Buffs, 20800)
        allBuff = allBuff and allBuff.Value or 0
        -- 当前巨兽增加血量上限
        local curBuff = 0
        -- 所有巨兽增加血量上限百分比
        local allPerBuff = Model.GetInfo(ModelType.Buffs, 22000)
        allPerBuff = allPerBuff and allPerBuff.Value or 0
        -- 当前巨兽增加血量上限百分比
        local curPerBuff = 0
        if info.Id == MonsterBaseId.Godzilla then
            curBuff = Model.GetInfo(ModelType.Buffs, 20820)
            curPerBuff = Model.GetInfo(ModelType.Buffs, 22020)
        elseif info.Id == MonsterBaseId.KingKong then
            curBuff = Model.GetInfo(ModelType.Buffs, 20821)
            curPerBuff = Model.GetInfo(ModelType.Buffs, 22021)
        end
        curBuff = curBuff and curBuff.Value or 0
        curPerBuff = curPerBuff and curPerBuff.Value or 0
        return math.floor((MonsterConf.health + allBuff + curBuff) * (1 + (allPerBuff + curPerBuff) / 10000))
    end
end

--获取计算buff后的巨兽最大攻击力
function MonsterModel.GetMonsterBuffAttack(info)
    local monsterId = MonsterModel.GetMonsterRealID(info.Id, info.Level)
    local MonsterConf = ConfigMgr.GetItem("configArmys", monsterId)
    if not MonsterConf then
        return 0
    end

    -- 所有巨兽增加攻击力
    local allBuff = Model.GetInfo(ModelType.Buffs, 20600)
    allBuff = allBuff and allBuff.Value or 0
    -- 当前巨兽增加攻击力
    local curBuff = 0
    -- 所有巨兽增加攻击力百分比
    local allPerBuff = Model.GetInfo(ModelType.Buffs, 21800)
    allPerBuff = allPerBuff and allPerBuff.Value or 0
    -- 当前巨兽增加攻击力百分比
    local curPerBuff = 0

    if info.Id == MonsterBaseId.Godzilla then
        curBuff = Model.GetInfo(ModelType.Buffs, 20620)
        curPerBuff = Model.GetInfo(ModelType.Buffs, 21820)
    elseif info.Id == MonsterBaseId.KingKong then
        curBuff = Model.GetInfo(ModelType.Buffs, 20621)
        curPerBuff = Model.GetInfo(ModelType.Buffs, 21821)
    end
    curBuff = curBuff and curBuff.Value or 0
    curPerBuff = curPerBuff and curPerBuff.Value or 0

    return math.floor((MonsterConf.attack + allBuff + curBuff) * (1 + (allPerBuff + curPerBuff) / 10000))
end

--获取计算buff后的巨兽最大防御力
function MonsterModel.GetMonsterBuffDefence(info)
    local monsterId = MonsterModel.GetMonsterRealID(info.Id, info.Level)
    local MonsterConf = ConfigMgr.GetItem("configArmys", monsterId)
    if not MonsterConf then
        return 0
    end

    -- 所有巨兽增加攻击力
    local allBuff = Model.GetInfo(ModelType.Buffs, 20700)
    allBuff = allBuff and allBuff.Value or 0
    -- 当前巨兽增加攻击力
    local curBuff = 0
    -- 所有巨兽增加攻击力百分比
    local allPerBuff = Model.GetInfo(ModelType.Buffs, 21900)
    allPerBuff = allPerBuff and allPerBuff.Value or 0
    -- 当前巨兽增加攻击力百分比
    local curPerBuff = 0

    if info.Id == MonsterBaseId.Godzilla then
        curBuff = Model.GetInfo(ModelType.Buffs, 20720)
        curPerBuff = Model.GetInfo(ModelType.Buffs, 21920)
    elseif info.Id == MonsterBaseId.KingKong then
        curBuff = Model.GetInfo(ModelType.Buffs, 20721)
        curPerBuff = Model.GetInfo(ModelType.Buffs, 21921)
    end
    curBuff = curBuff and curBuff.Value or 0
    curPerBuff = curPerBuff and curPerBuff.Value or 0

    return math.floor((MonsterConf.defence + allBuff + curBuff) * (1 + (allPerBuff + curPerBuff) / 10000))
end

--巨兽当前战力
function MonsterModel.GetMonsterRealPower(id, level, health, maxHealth)
    local model = Model.GetInfo(ModelType.GiantBeasts, id)
    local curHealth = health and health or model.DisplayHealth
    local maxHealth = maxHealth and maxHealth or MonsterModel.GetMonsterRealMaxHealth(model)
    local config = ConfigMgr.GetItem("configArmys", MonsterModel.GetMonsterRealID(id, level))
    return config.power * (curHealth / maxHealth) ^ GlobalBattle.M2
end
--巨兽健康战力
function MonsterModel.GetMonsterPower(id, level)
    local config = ConfigMgr.GetItem("configArmys", MonsterModel.GetMonsterRealID(id, level))
    return config.power
end

function MonsterModel.GetMonsterRealAttack(id)
    local model = Model.GetInfo(ModelType.GiantBeasts, id)
    -- local config = ConfigMgr.GetItem("configArmys", MonsterModel.GetMonsterRealID(id, level))
    local attack = MonsterModel.GetMonsterBuffAttack(model)
    return attack * (model.DisplayHealth / MonsterModel.GetMonsterRealMaxHealth(model)) ^ GlobalBattle.M0
end

function MonsterModel.GetMonsterRealMaxAttack(id)
    local model = Model.GetInfo(ModelType.GiantBeasts, id)
    return MonsterModel.GetMonsterBuffAttack(model) * 1 ^ GlobalBattle.M0
end

function MonsterModel.GetMonsterRealDefence(id)
    local model = Model.GetInfo(ModelType.GiantBeasts, id)
    -- local config = ConfigMgr.GetItem("configArmys", MonsterModel.GetMonsterRealID(id, level))
    local defence = MonsterModel.GetMonsterBuffDefence(model)
    return defence * (model.DisplayHealth / MonsterModel.GetMonsterRealMaxHealth(model)) ^ GlobalBattle.M1
end

function MonsterModel.GetMonsterRealMaxDefence(id)
    local model = Model.GetInfo(ModelType.GiantBeasts, id)
    return MonsterModel.GetMonsterBuffDefence(model) * 1 ^ GlobalBattle.M1
end

function MonsterModel.GetArmyType(monsterId)
    local confArmy = ConfigMgr.GetItem("configArmys", monsterId)
    local confArmyType = ConfigMgr.GetItem("configArmyTypes", confArmy.arm)
    return confArmyType
end

function MonsterModel.GetMonsterStory(monsterId)
    return StringUtil.GetI18n(I18nType.Army, monsterId .. "_STORY")
end

function MonsterModel.GetMonsterNames(monsterId)
    local name = StringUtil.GetI18n(I18nType.Army, monsterId .. "_NAME")
    local desc = StringUtil.GetI18n(I18nType.Army, monsterId .. "_DESC")
    return name, desc
end

function MonsterModel.GetLevelLabel(monsterId)
    local conf = ConfigMgr.GetItem("configArmys", monsterId)
    return ArmiesModel.GetLevelText(conf.level)
end

function MonsterModel.GetMonsterLevel(monsterId)
    local conf = ConfigMgr.GetItem("configArmys", monsterId)
    return conf.level
end

return MonsterModel
