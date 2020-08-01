--军队Model
local ArmiesModel = {}
--拥有士兵缓存
local missionArmies = {}
--出征士兵缓存
local expeditionList = {}
--出征巨兽
local expeditionBeasts = {}

local WorldCityModel = import("Model/WorldCityModel")
local GameUtil = import("Utils/GameUtil")
local ModelType = import("Enum/ModelType")
local MissionEventModel = import("Model/MissionEventModel")
local VIPModel = import("Model/VIPModel")
local TechModel = import("Model/TechModel")
local BuildModel = import("Model/BuildModel")
local MonsterModel = import("Model/MonsterModel")
local EventModel = import("Model/EventModel")
local EquipModel = import("Model/EquipModel")

local nowExpeditionCount = 0
local ExpeditionLimit = -1 -- 出征上限 -1时是为自己出兵上限

--初始化所有士兵缓存
function ArmiesModel.Init()
    missionArmies = {}
    local allList = Model.GetMap("Armies")
    for k, v in pairs(allList) do
        local configInfo = GameUtil.Clone(ConfigMgr.GetItem("configArmys", k))
        --初始化可出征队伍，9以后为城防单位
        if (configInfo.arm < 9) and v.Amount > 0 then
            configInfo.Amount = v.Amount
            configInfo.NowCount = v.Amount
            table.insert(missionArmies, configInfo)
        end
    end
    table.sort(missionArmies, ArmiesModel.SortFuncById)
    return missionArmies
end

--清空出征数据
function ArmiesModel.ClearArmies()
    expeditionList = {}
    expeditionBeasts = {}
end

--设置出征数据
function ArmiesModel.SetExpeditionArmies(confId, count, amount)
    local index = -1
    local army
    for i = 1, #expeditionList do
        if expeditionList[i].id == confId then
            index = i
        end
    end
    if (index < 0) then
        table.insert(expeditionList, GameUtil.Clone(ConfigMgr.GetItem("configArmys", confId)))
        index = #expeditionList
    end
    expeditionList[index].NowCount = count
    expeditionList[index].Amount = amount
    -- if count == 0 then
    --     table.remove(expeditionList, index)
    -- end
    Event.Broadcast(EventDefines.UIOnExpetionNumChange)
end

--获取出征数据中对应兵种信息
function ArmiesModel.GetExpeditionArmy(confId)
    for _,v in pairs(expeditionList) do
        if v.id == confId then
            return v
        end
    end
end

--设置出征巨兽
function ArmiesModel.SetExpeditionBeast(model, isAdd)
    if isAdd then
        local canAdd = true
        for k,v in pairs(expeditionBeasts) do
            if v.Id == model.Id then
                canAdd = false
                break
            end
        end
        
        if canAdd then
            table.insert(expeditionBeasts, model)
        end
    else
        for k,v in pairs(expeditionBeasts) do
            if v.Id == model.Id then
                table.remove(expeditionBeasts, k)
                break
            end
        end
    end

    Event.Broadcast(EventDefines.UIOnExpetionNumChange)
end

--获取出征士兵简单信息，仅含数量
function ArmiesModel.GetExpeditionArmies()
    local list = {}
    for _, val in pairs(expeditionList) do
        if val.NowCount > 0 then
            local army = {}
            army.ConfId = val.id
            army.Amount = val.NowCount
            table.insert(list, army)
        end
    end
    return list
end

--获取出征巨兽
function ArmiesModel.GetExpeditionBeast()
    return expeditionBeasts
end

--获取出征巨兽里有没有指定巨兽
function ArmiesModel.GetExpeditionBeastById(id)
    for _,v in pairs(expeditionBeasts) do
        if v.Id == id then
            return true
        end
    end

    return false
end

--获取本次出征士兵详细士兵
function ArmiesModel.GetArmiesDetail()
    return expeditionList
end

-- 获取行军队列士兵信息
function ArmiesModel.GetMissionArmies()
    local result = {}

    local missions = MissionEventModel.GetList()
    for _, v in pairs(missions) do
        for _, v0 in pairs(v.MissionTeams) do
            if v0.UserId == Model.Account.accountId then                
                local beasts = v0.Beasts
                local armies = v0.Armies
                local cur = {}
                cur.beasts = {}
                cur.armies = {}

                for _, v1 in pairs(beasts) do
                    table.insert(cur.beasts, v1)
                end

                for _, v1 in pairs(armies) do
                    table.insert(cur.armies, {ConfId = v1.ConfId, Amount = v1.Amount})
                end
                table.insert(result, cur)
            end
        end
    end
    return result
end

--获取城内和出征的所有部队
function ArmiesModel.GetAllArmies()
    local allArmies = {}

    --城内部队
    local armies = Model.GetMap("Armies")
    for k, v in pairs(armies) do
        local configInfo = GameUtil.Clone(ConfigMgr.GetItem("configArmys", k))
        if (configInfo.arm < 9) and v.Amount > 0 then
            if allArmies[k] then
                allArmies[k].Amount = allArmies[k].Amount + v.Amount
                allArmies[k].NowCount = allArmies[k].NowCount + v.Amount
            else
                configInfo.Amount = v.Amount
                configInfo.NowCount = v.Amount
                allArmies[k] = configInfo
            end
        end
    end

    --出征部队
    local missions = MissionEventModel.GetList()
    for _, v in pairs(missions) do
        for _, v0 in pairs(v.MissionTeams) do
            if v0.UserId == Model.Account.accountId then
                local armies = v0.Armies
                local cur = {}
                for _, v1 in pairs(armies) do
                    local configInfo = GameUtil.Clone(ConfigMgr.GetItem("configArmys", v1.ConfId))
                    if allArmies[v1.ConfId] then
                        allArmies[v1.ConfId].Amount = allArmies[v1.ConfId].Amount + v1.Amount
                        allArmies[v1.ConfId].NowCount = allArmies[v1.ConfId].NowCount + v1.Amount
                    else
                        configInfo.Amount = v1.Amount
                        configInfo.NowCount = v1.Amount
                        allArmies[v1.ConfId] = configInfo
                    end
                end
            end
        end
    end

    local result = {}
    for k, v in pairs(allArmies) do
        table.insert(result, v)
    end

    table.sort(result, ArmiesModel.SortFuncByLevel)
    return result
end

--构造行军参数
--{X: int32, Y: int32, HeroId: string, Armies: array-Army}
function ArmiesModel.GetExpeditionNetParam()
    -- local Param =
    return {
        X = WorldCityModel.GetX(),
        Y = WorldCityModel.GetY(),
        HeroId = "",
        Armies = ArmiesModel.GetExpeditionArmies()
    }
end

-- 根据配置id获取士兵配置
function ArmiesModel.FindByConfId(confId)
    local armies = Model.GetMap("Armies")
    if not armies then
        return
    end

    for _, v in pairs(armies) do
        if v.ConfId == confId then
            return v
        end
    end
end

-- 获取所有军队数量
function ArmiesModel.GetAllCount()
    local count = 0
    for k, v in pairs(missionArmies) do
        count = count + v.Amount
    end
    return count
end

-- 获取当前出征士兵数量
function ArmiesModel.GetExpeditionCount()
    local num = 0
    for key, val in pairs(expeditionList) do
        num = num + val.NowCount
    end
    return num
end

---刷新现在部队数量
function ArmiesModel.RefreshArmies(list)
    for i = 1, #list do
        if (missionArmies[list[i].ConfId]) then
            missionArmies[list[i].ConfId].NowCount = list[i].NowCount
        end
    end
    Model.UpdateList(ModelType.Armies, "ConfId", list)
end

--获得出征页面上限
function ArmiesModel.GetExpetionNum(maxLimit)
    local limit = ArmiesModel.GetMarchLimit()
    local num = 0
    if maxLimit then
        limit = maxLimit < limit and maxLimit or limit
    end
    -- for key, val in pairs(expeditionList) do
    --     num = num + val.Amount
    -- end
    num = ArmiesModel.GetExpeditionCount()
    nowExpeditionCount = num
    return num .. "/" .. limit
end

--获取选择部队总攻击力
function ArmiesModel.GetTotalAttack()
    local attack = 0
    for _,v in pairs(expeditionBeasts) do
        attack = math.ceil(attack + MonsterModel.GetMonsterRealPower(v.Id, v.Level))
    end

    for key, val in pairs(expeditionList) do
        attack = attack + val.power * val.NowCount
    end

    local equipInfo = EquipModel.GetEquipPart()
    for _,v in ipairs(equipInfo)do
        if v.EquipId > 0 then
            local config = EquipModel.GetEquipQualityById(v.EquipId)
            if config then
                attack = attack + config.power
            end
        end
    end
    return math.floor(attack)
end

--获取部队负重
function ArmiesModel.GetArmiesLoad(list)
    local loadNum = 0
    for v, k in pairs(list) do
        local item = ConfigMgr.GetItem("configArmys", k.ConfId)
        loadNum = loadNum + item.load
    end
    return loadNum
end

--根据内部构建的部队数量获取部队负重
function ArmiesModel.GetLoadByExpedition(isPlunder)
    local loadNum = 0
    for _,v in pairs(expeditionBeasts) do
        local config = ConfigMgr.GetItem("configArmys", MonsterModel.GetMonsterRealID(v.Id, v.Level))
        loadNum = loadNum + config.load
    end
    
    for _, v in pairs(expeditionList) do
        local rate = ArmiesModel.GetCurLoadOfArmy(v.arm, isPlunder)
        loadNum = loadNum + v.load * (1 + rate) * v.NowCount
    end
    return math.floor(loadNum)
end

--根据内部构建的部队数量获取部队行军速度
function ArmiesModel:GetSpeedByExpedition(type, initSpeed)
    local speed = initSpeed or 0
    local commonArmyBuff = Model.Find(ModelType.Buffs, 13700)
    commonArmyBuff = commonArmyBuff and commonArmyBuff.Value or 0

    for _,v in pairs(expeditionBeasts) do
        local config = ConfigMgr.GetItem("configArmys", v.Id)
        local curSpeed = math.floor(config.speed * (1 + commonArmyBuff * 0.0001))
        if speed == 0 or (speed and speed > curSpeed) then
            speed = curSpeed
        end
    end

    for _,v in pairs(expeditionList) do
        local armyBuff = Model.Find(ModelType.Buffs, 13700 + v.arm)
        local curSpeed = armyBuff and (armyBuff.Value + commonArmyBuff) or commonArmyBuff
        curSpeed = math.floor(v.speed * (1 + curSpeed * 0.0001))
        if v.NowCount > 0 and (speed == 0 or (speed and speed > curSpeed)) then
            speed = curSpeed
        end
    end
    
    local buff = 0
    local mapBuff = Model.Find(ModelType.Buffs, 10400)
    buff = buff + (mapBuff and mapBuff.Value or 0)
    if type > 0 then
        local specBuff = Model.Find(ModelType.Buffs, 10400 + type)
        buff = buff + (specBuff and specBuff.Value or 0)
    end
    
    return speed * (1 + buff * 0.0001)
end

--根据士兵配置获取每种兵种计算buff后的负重
function ArmiesModel.GetCurLoadOfArmy(arm, isPlunder)
    local buff = Model.GetInfo(ModelType.Buffs, 13600)
    buff = buff and buff.Value or 0
    local armyBuff = Model.GetInfo(ModelType.Buffs, 13600 + arm)
    armyBuff = armyBuff and armyBuff.Value or 0

    if isPlunder then
        local pluBuff = Model.GetInfo(ModelType.Buffs, 16202)
        pluBuff = pluBuff and pluBuff.Value or 0
        return (buff + armyBuff + pluBuff) * 0.0001
    else
        return (buff + armyBuff) * 0.0001
    end
end

-- 限制部队负重
function ArmiesModel.LimitArmiesLoad(assistLimit)
    if assistLimit then
        local beasts = ArmiesModel.GetExpeditionBeast()
        for _,v in pairs(beasts) do
            local config = ConfigMgr.GetItem("configArmys", MonsterModel.GetMonsterRealID(v.Id, v.Level))
            assistLimit = assistLimit - config.load
            assistLimit = assistLimit < 0 and 1 or assistLimit
        end

        local curLimit = 0
        for _, v in pairs(expeditionList) do
            if curLimit >= assistLimit then
                v.NowCount = 0
            end

            local rate = ArmiesModel.GetCurLoadOfArmy(v.arm, false)
            local curLoad = curLimit + v.load * (1 + rate) * v.NowCount
            if curLoad > assistLimit then
                local remain = assistLimit - curLimit
                local amount = math.ceil(remain / (v.load * (1 + rate)))
                v.NowCount = amount
                curLimit = assistLimit
            else
                curLimit = curLoad
            end
        end
    end

    return expeditionList
end

--根据行军上限获取剩余可添加数量
function ArmiesModel.GetSurplusNum()
    local limit = ArmiesModel.GetMarchLimit()
    if ExpeditionLimit ~= -1 then
        limit = ExpeditionLimit < limit and ExpeditionLimit or limit
    end
    return limit - ArmiesModel.GetExpeditionCount()
end

--获取出征队列上限
function ArmiesModel.GetMarchQueueMax()
    return Model.GetInfo(ModelType.Limits, Global.LimitTypeMarchQueue).Amount
end

--获取出征士兵上限
function ArmiesModel.GetMarchLimit()
    return Model.GetInfo(ModelType.Limits, Global.LimitTypeMarch).Amount
end

--检查出征上限
function ArmiesModel.CheckMissionLimit()
    if MissionEventModel.GetMissionAmount() < ArmiesModel.GetMarchQueueMax() then
        return false
    end

    -- 寻找还未升级的可以提升出征上限的科技
    local tech
    for _,v in pairs(Global.AdditionMissionLimitTechs) do
        if not TechModel.CheckTechByLv(v, 1) then
            tech = TechModel.GetDisplayConfigItem(Global.NormalTech, v)
            break
        end
    end

    local func_vip = function()
        Net.Vip.GetVipInfo(
            function(msg)
                UIMgr:Open("VIPMain", msg)
            end
        )
    end
    local func_tech = function()
        if not tech then
            return
        end

        local building = BuildModel.CheckExist(Global.BuildingScience)
        if not building then
            UIMgr:ClosePopAndTopPanel()
            TurnModel.BuildTurnCreatePos(Global.BuildingScience)
            return
        end

        local building = BuildModel.FindByConfId(Global.BuildingScience)
        local update = EventModel.GetUpgradeEvent(building.Id)
        if building.Level <= 0 or update then
            local data = {jump = 810000, para = Global.BuildingScience}
            JumpMap:JumpTo(data)
            return
        end

        UIMgr:ClosePopAndTopPanel()
        UIMgr:Open("LaboratorySkill", tech.tab,Global.NormalTech,tech.id,true,nil,nil,true)
    end

    local data
    if (VIPModel.GetVipLevel() < Global.AdditionMissionLimitVipLv or not VIPModel.GetVipActivated()) and tech then
        data = {
            textContent = StringUtil.GetI18n(I18nType.Commmon, "ALERT_QUEUE_1", {queue_num = ArmiesModel.GetMarchQueueMax(), tech_name = StringUtil.GetI18n(I18nType.Tech, tech.id.."_NAME"), level = tech.first_lev}),
            controlType = "double",
            textBtnRight = StringUtil.GetI18n(I18nType.Commmon, VIPModel.GetVipLevel() < Global.AdditionMissionLimitVipLv and "QUEUE_BUTTON_UPGRADE_VIP" or "QUEUE_BUTTON_ACTIVE_VIP"),
            textBtnLeft = StringUtil.GetI18n(I18nType.Commmon,  "QUEUE_BUTTON_RESEARCH"),
            cbBtnRight = func_vip,
            cbBtnLeft = func_tech,
        }
    elseif VIPModel.GetVipLevel() < Global.AdditionMissionLimitVipLv or not VIPModel.GetVipActivated() then
        data = {
            textContent = StringUtil.GetI18n(I18nType.Commmon, "ALERT_QUEUE_2", {queue_num = ArmiesModel.GetMarchQueueMax()}),
            controlType = "single",
            textBtnLeft = StringUtil.GetI18n(I18nType.Commmon, VIPModel.GetVipLevel() < Global.AdditionMissionLimitVipLv and "QUEUE_BUTTON_UPGRADE_VIP" or "QUEUE_BUTTON_ACTIVE_VIP"),
            cbBtnLeft = func_vip,
        }
    elseif tech then
        data = {
            textContent = StringUtil.GetI18n(I18nType.Commmon, "ALERT_QUEUE_3", {queue_num = ArmiesModel.GetMarchQueueMax(), tech_name = StringUtil.GetI18n(I18nType.Tech, tech.id.."_NAME"), level = tech.first_lev}),
            controlType = "single",
            textBtnLeft = StringUtil.GetI18n(I18nType.Commmon,  "QUEUE_BUTTON_RESEARCH"),
            cbBtnLeft = func_tech,
        }
    else
        data = {
            textContent = StringUtil.GetI18n(I18nType.Commmon, "ALERT_QUEUE_4"),
            controlType = "none"
        }
    end
    UIMgr:Open("ConfirmPopupDouble", data)
    return true
end

--获取指定巨兽是否已出征
function ArmiesModel.IsBeastExpedition(id)
    for _,v in pairs(Model.MissionEvents) do
        for _,v1 in pairs(v.MissionTeams) do
            for _,v2 in pairs(v1.Beasts) do
                if v2.Id == id then
                    return true
                end
            end
        end
    end

    return false
end

function ArmiesModel.GetLevelText(lv)
    return StringUtil.GetI18n(I18nType.Commmon, "Ui_ArmyLevel"..lv)
end

------------------------------------------------------------部队排序规则-------------
function ArmiesModel.GetListByType(selectType, armyLimit, assistLimit)
    local result = {}
    if not armyLimit or armyLimit == -1 then
        --此处为服务器下发单次出征上限
        ExpeditionLimit = ArmiesModel.GetMarchLimit()
    else
        ExpeditionLimit = armyLimit
    end

    if (selectType == 0) then --选择数置为0
        for _, v in pairs(expeditionList) do
            v.NowCount = 0
        end
        result = expeditionList
    else
        local total = 0
        expeditionList = {}
        if selectType == 4 then --搭配优先
            expeditionList = ArmiesModel.SortByMatch(ExpeditionLimit)
        else
            if selectType == 1 then --等级优先
                table.sort(missionArmies, ArmiesModel.SortFuncByLevel)
            elseif selectType == 2 then --负重优先
                table.sort(missionArmies, ArmiesModel.SortFuncByLoad)
                -- 矿车默认排第一位
                local index
                for k, v in pairs(missionArmies) do
                    if v.id == 107301 then
                        index = k
                        break
                    end
                end
                local item = table.remove(missionArmies, index)
                table.insert(missionArmies, 1, item)
            elseif selectType == 3 then --速度优先
                table.sort(missionArmies, ArmiesModel.SortFuncBySpeed)
            end

            local army
            for i = 1, #missionArmies do
                army = GameUtil.Clone(missionArmies[i])
                if ExpeditionLimit < army.Amount + total then
                    army.NowCount = ExpeditionLimit - total
                else
                    army.NowCount = army.Amount
                end
                total = total + army.NowCount
                table.insert(expeditionList, army)
            end
        end
        result = GameUtil.Clone(expeditionList)
    end

    if assistLimit and assistLimit >= 0 then
        result = ArmiesModel.LimitArmiesLoad(assistLimit)
    end

    return result
end

--按照负重排序
function ArmiesModel.SortFuncByLoad(a, b)
    local aWeight = a.load
    local bWeight = b.load
    local r

    if (aWeight == bWeight) then
        if a.army_type == b.army_type then
            r = false
        else
            r = a.army_type < b.army_type
        end
    else
        r = aWeight > bWeight
    end
    return r
end

--按照等级排序
function ArmiesModel.SortFuncByLevel(a, b)
    local aLevel = a.level
    local bLevel = b.level
    local r

    if (aLevel == bLevel) then
        if a.army_type == b.army_type then
            r = false
        else
            r = a.army_type < b.army_type
        end
    else
        r = aLevel > bLevel
    end
    return r
end

--按照速度排序
function ArmiesModel.SortFuncBySpeed(a, b)
    local r
    local aSpeed = a.speed
    local bSpeed = b.speed

    if (aSpeed == bSpeed) then
        if a.army_type == b.army_type then
            if a.level == b.level then
                r = false
            else
                r = a.level > b.level
            end
        else
            r = a.army_type < b.army_type
        end
    else
        r = aSpeed > bSpeed
    end
    return r
end

function ArmiesModel.SortFuncById(a, b)
    local aID = a.id
    local bID = b.id

    if (aID == bID) then
        return false
    else
        return aID > bID
    end
end

--搭配优先排序
function ArmiesModel.SortByMatch(limit)
    local result = {}

    table.sort(missionArmies, ArmiesModel.SortFuncByLevel)

    local total = ArmiesModel.GetAllCount()
    if total <= limit then
        -- 部队总数不超过出兵上限时全部分配
        local mainProtective = {} -- 主要防御兵种
        local subProtective = {} -- 次要防御兵种
        local temp = {}
        for _, v in pairs(missionArmies) do
            if v.arm == 1 then
                table.insert(mainProtective, 1, v)
            elseif v.arm == 8 then
                table.insert(subProtective, 1, v)
            else
                table.insert(temp, v)
            end
        end

        -- 主要防御兵种排在最前
        for _, v in pairs(subProtective) do
            table.insert(temp, 1, v)
        end

        -- 次要防御兵种排在次前
        for _, v in pairs(mainProtective) do
            table.insert(temp, 1, v)
        end

        local army
        for i = 1, #temp do
            army = GameUtil.Clone(temp[i])
            army.NowCount = army.Amount
            table.insert(result, army)
        end
    else
        local cloneArmies = {}
        for _, v in pairs(missionArmies) do
            local army = GameUtil.Clone(v)
            army.NowCount = 0
            table.insert(cloneArmies, army)
        end

        -- 防御兵种占30%
        local protectiveNum = math.floor(limit * 0.3)
        local otherNum = limit - protectiveNum

        local mainProtective = {} -- 主要防御兵种
        local subProtective = {} -- 次要防御兵种
        local other = {} -- 其余兵种
        local mainProtectiveAmount = 0 -- 主防御兵种数量
        local subProtectiveAmount = 0 -- 次防御兵种数量
        local otherAmount = 0 -- 其余兵种数量
        for _, v in pairs(cloneArmies) do
            if v.arm == 1 then
                mainProtectiveAmount = mainProtectiveAmount + v.Amount
                table.insert(mainProtective, v)
            elseif v.arm == 8 then
                subProtectiveAmount = subProtectiveAmount + v.Amount
                table.insert(subProtective, v)
            else
                otherAmount = otherAmount + v.Amount
                table.insert(other, v)
            end
        end

        -- 调整兵种分配数量
        local allProtectiveAmount = mainProtectiveAmount + subProtectiveAmount -- 总防御兵种数量
        if allProtectiveAmount < protectiveNum then
            otherNum = otherNum + protectiveNum - allProtectiveAmount
        elseif otherAmount < otherNum then
            protectiveNum = protectiveNum + otherNum - otherAmount
        end

        -- 按等级区间组织数据，每3级一个区间
        mainProtective = ArmiesModel.RebuildByRange(mainProtective) -- 整理主防御兵种数据
        subProtective = ArmiesModel.RebuildByRange(subProtective) -- 整理次防御兵种数据
        other = ArmiesModel.RebuildByRange(other) -- 整理其它兵种数据

        -- 分配主防御兵种数量
        local remain = ArmiesModel.AllocByRange(mainProtective, protectiveNum)
        -- 分配次防御兵种数量
        ArmiesModel.AllocByRange(subProtective, remain)
        -- 分配其它兵种数量
        ArmiesModel.AllocByRange(other, otherNum)

        -- 最后整合
        local temp = {}
        for _, v in pairs(mainProtective) do
            for _, v1 in pairs(v) do
                if v1.NowCount > 0 then
                    table.insert(result, v1)
                else
                    table.insert(temp, v1)
                end
            end
        end
        for _, v in pairs(subProtective) do
            for _, v1 in pairs(v) do
                if v1.NowCount > 0 then
                    table.insert(result, v1)
                else
                    table.insert(temp, v1)
                end
            end
        end
        for _, v in pairs(other) do
            for _, v1 in pairs(v) do
                if v1.NowCount > 0 then
                    table.insert(result, v1)
                else
                    table.insert(temp, v1)
                end
            end
        end

        for _, v in pairs(temp) do
            table.insert(result, v)
        end
    end

    return result
end

function ArmiesModel.RebuildByRange(armies)
    local result = {}
    if #armies <= 0 then
        return result
    end

    local maxLv = armies[1].level
    local rangeNum = math.ceil(maxLv / 3)
    local curLv = maxLv
    for i = 1, rangeNum do
        for j = 1, 3 do
            if curLv <= 0 then
                break
            end

            for _, v in pairs(armies) do
                if v.level == curLv then
                    if not result[i] then
                        result[i] = {}
                    end
                    table.insert(result[i], v)
                end
            end
            curLv = curLv - 1
        end
    end

    return result
end

function ArmiesModel.AllocByRange(armies, amount)
    local remain = amount
    for _, v in pairs(armies) do
        if remain <= 0 then
            break
        end

        -- 当前等级区间拥有士兵总数
        local curAmount = 0
        for _, v1 in pairs(v) do
            curAmount = curAmount + v1.Amount
        end

        if curAmount <= remain then
            for _, v1 in pairs(v) do
                v1.NowCount = v1.Amount
            end
            remain = remain - curAmount
        else
            table.sort(
                v,
                function(a, b)
                    return a.Amount < b.Amount
                end
            )

            local average = math.floor(remain / #v)
            local slag = math.fmod(remain, #v)
            for k, v1 in pairs(v) do
                local curRemain = v1.Amount - average
                if curRemain > 0 then
                    if curRemain > slag then
                        v1.NowCount = average + slag
                        slag = 0
                    else
                        v1.NowCount = v1.Amount
                        slag = slag - curRemain
                    end
                else
                    v1.NowCount = v1.Amount

                    curRemain = math.abs(curRemain)
                    local left = #v - k
                    if left > 0 then
                        average = average + math.floor(curRemain / left)
                        slag = slag + math.fmod(curRemain, left)
                    end
                end
            end

            remain = 0
        end
    end

    return remain
end
-----------------------------------------------------

function ArmiesModel.GetArmyConfig(Id)
    return ConfigMgr.GetItem("configArmys", Id)
end

-- 获取指定兵种指定数量消耗
function ArmiesModel.GetArmyCost(confId, amount)
    local config = ArmiesModel.GetArmyConfig(confId)

    return config.upkeep * amount
end

-- 获取所有兵种消耗
function ArmiesModel.GetAllArmyCost()
    local result = 0
    local armies = Model.GetMap("Armies")
    for _,v in pairs(armies) do
        result = result + ArmiesModel.GetArmyCost(v.ConfId, v.Amount)
    end

    local mission = ArmiesModel.GetMissionArmies()
    for _,v in pairs(mission) do
        for _,v1 in pairs(v.armies) do
            result = result + ArmiesModel.GetArmyCost(v1.ConfId, v1.Amount)
        end
    end
    
    -- 计算军队消耗减少buff
    local upKeepBuff = Model.GetInfo(ModelType.Buffs, 16005)
    if upKeepBuff then
        result = result * (1 - upKeepBuff.Value * 0.0001)
    end
    
    return math.floor(result / 144) * 6 --先算每10分钟消耗后向下取整，再算出每小时消耗。保持与服务器算法取整位置相同
end

-- 获取是否有伤兵
function ArmiesModel.IsHaveInjuredArmy()
    for _, v in pairs(Model.InjuredArmies) do
        if v.Amount > 0 then
            return true
        end
    end
    return false
end

--获取医院剩余伤病容量
function ArmiesModel:GetCureArmyLimit( )        
    local all = BuildModel.GetAll(411000)
    local limit = Global.HospitalBaseLimit
    for _, v in pairs(all) do
        if v.Level > 0 then
            local conf = ConfigMgr.GetItem("configHospitals", v.ConfId + v.Level)
            limit = limit + conf.limit
        end
    end
    limit = (limit + BuffModel.GetCureArmyLimit()) * BuffModel.GetCureArmyLimitPerc()
    local injurNum = 0
    for _, v in pairs(Model.InjuredArmies) do
        if v.Amount > 0 then
            
        end
        injurNum = injurNum + v.Amount
    end
    return limit - injurNum
end

return ArmiesModel
