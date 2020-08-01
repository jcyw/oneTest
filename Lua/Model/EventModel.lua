--[[
    Author: songzeming
    Function: 事件
]]
local EventModel = {}

-- 获取建筑的相关事件
function EventModel.GetEvent(building)
    if not building then
        return
    end
    --建筑 升级事件
    local event = EventModel.GetUpgradeEvent(building.Id)
    if event then
        return event
    end

    local confId = building.ConfId
    if confId == Global.BuildingScience then
        --科研中心[科技升级事件]
        return EventModel.GetTechEvent(confId)
    elseif confId == Global.BuildingBeastScience then
        --巨兽科研中心[巨兽科技升级事件]
        return EventModel.GetTechEvent(confId)
    elseif confId == Global.BuildingHospital then
        --医院[战区医院/联盟医院 士兵治疗事件]
        return EventModel.GetCureEvent()
    elseif confId == Global.BuildingBeastHospital then
        local e = EventModel.GetBeastCureEvent()
        if next(e) == nil then
            return
        end
        return e
    elseif confId == Global.BuildingEquipFactory then
        --装备制造
        return EquipModel.GetEquipEvents()
    elseif confId == Global.BuildingEquipMaterialFactory then
        --装备材料生产
        return EquipModel.GetMaterialMakeEvent()
    end
    --军队建筑 训练事件
    local conf = ConfigMgr.GetItem("configBuildings", confId)
    if conf.category == Global.BuildingTypeArmy then
        return EventModel.GetTrainEvent(confId)
    end
    return
end

--获取建筑建造、升级事件
function EventModel.GetUpgradeEvent(id)
    for _, v in pairs(Model.UpgradeEvents) do
        if v.TargetId == id then
            return v
        end
    end
end

-- 通过事件类型获取升级事件
function EventModel.GetUpgradeEventByCategory(type)
    if not type then
        return
    end

    local result = {}
    for _, v in pairs(Model.UpgradeEvents) do
        if v.Category == type then
            table.insert(result, v)
        end
    end
    return result
end

-- 通过士兵ID获取建筑训练事件
function EventModel.GetTrainEvent(confId)
    local TrainModel = import("Model/TrainModel")
    local baseArmId = TrainModel.GetBaseArmId(confId)
    if not baseArmId then
        return
    end
    for _, v in pairs(Model.TrainEvents) do
        if TrainModel.GeBaseById(v.ConfId) == baseArmId then
            v.Category = Global.EventTypeTrain
            return v
        end
    end
    return
end

-- 获取医院治疗事件 [联盟医院/战区医院]
function EventModel.GetCureEvent(isAlliance)
    for _, v in pairs(Model.CureEvents) do
        if Tool.EqualBool(v.IsAlliance, isAlliance) then
            v.Category = Global.EventTypeCure
            return v
        end
    end
    return
end

-- 获取巨兽医院治疗事件
function EventModel.GetBeastCureEvent()
    local beastcureevents = {}
    for _, v in pairs(Model.BeastCureEvents) do
        beastcureevents = v
    end
    return beastcureevents
end

-- 通过建筑配置Id获取科技升级事件
function EventModel.GetTechEvent(configId)
    local buildConfig = ConfigMgr.GetItem("configBuildings", configId)
    local funcs = buildConfig.funcs
    if not funcs then
        return
    end
    for _, v in pairs(funcs) do
        local funcConfig = ConfigMgr.GetItem("configBuildingFuncs", v)
        if funcConfig.name == "Research" then
            local models = Model.GetMap(ModelType.Techs)
            for _, vv in pairs(models) do
                local data = EventModel.GetUpgradeEvent(vv.ConfId)
                if data ~= nil then
                    return data
                end
            end
            break
        elseif funcConfig.name == "BeastResearch" then
            local models = Model.GetMap(ModelType.BeastTechs)
            for _, vv in pairs(models) do
                local data = EventModel.GetUpgradeEvent(vv.ConfId)
                if data ~= nil then
                    return data
                end
            end
            break
        end
    end
end

-- 兵种训练完成 将兵种事件结束时间设为当前时间
function EventModel.SetTrainEnd(uuid)
    local event = Model.Find(ModelType.TrainEvents, uuid)
    if not event then
        return
    end
    event.FinishAt = Tool.Time()
end

-- 巨兽治疗完成 将巨兽治疗事件结束时间设为当前时间
function EventModel.SetCureMonsterEnd(uuid)
    local event = Model.Find(ModelType.BeastCureEvents, uuid)
    if not event then
        return
    end
    event.FinishAt = Tool.Time()
end

return EventModel
