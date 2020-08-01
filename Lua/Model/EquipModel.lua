-- 装备Model

local ConfigMgr = _G.ConfigMgr
local Model = _G.Model
local ModelType = _G.ModelType
local Global = _G.Global
local Event = _G.Event
local EventDefines = _G.EventDefines
local Tool = _G.Tool
local EventType = _G.EventType
local BuildModel = import("Model/BuildModel")
local Net = _G.Net
local EventModel = import("Model/EventModel")

local EQUIPFACTORYID = 444000
local EquipModel = {}
--装备最高和最低品质
EquipModel.EquipQuality = {
    EquipQuialityMin = 1,
    EquipQuialityMax = 6
}

local MaterialGroup = {}

local colorCode = {
    [1] = "899099",
    [2] = "2a9f57",
    [3] = "6a87d9",
    [4] = "9647dc",
    [5] = "d9833f",
    [6] = "ffe558",
}
local colorName = {
    [1] = "quality_color_0",
    [2] = "quality_color_1",
    [3] = "quality_color_2",
    [4] = "quality_color_3",
    [5] = "quality_color_4",
    [6] = "quality_color_5",
}
--获取材料信息 通过ID
function EquipModel.GetMaterialById(id)
    return ConfigMgr.GetItem("configEquipMaterialTypes", id)
end

--获取材料信息 通过详细品质材料ID
function EquipModel.GetMaterialByQualityId(id)
    return ConfigMgr.GetItem("configEquipMaterialTypes", EquipModel.QualityID2TypeID(id))
end

--获取材料信息 通过Type
function EquipModel.GetMaterialsByType(type)
    if not next(MaterialGroup) then
        local configs = ConfigMgr.GetList("configEquipMaterialTypes")
        for _,v in pairs(configs) do
            if not MaterialGroup[v.type] then
                MaterialGroup[v.type] = {}
            end

            table.insert(MaterialGroup[v.type], v)
        end
    end

    return MaterialGroup[type]
end

--获取详细品质材料信息 通过ID
function EquipModel.GetQualityMaterialById(id)
    return ConfigMgr.GetItem("configEquipMaterialQualitys", id)
end

--获取装备部位信息 通过ID
function EquipModel.GetEquipPartById(id)
    return ConfigMgr.GetItem("configEquipParts", id)
end

--获取装备属性信息 通过ID
function EquipModel.GetEquipQualityById(id)
    return ConfigMgr.GetItem("configEquipQualitys", id)
end

--获取装备信息 通过ID
function EquipModel.GetEquipTypeById(id)
    return ConfigMgr.GetItem("configEquipTypes", id)
end
--获取所有装备信息
function EquipModel.GetEquipTypes()
    return ConfigMgr.GetDictionary("configEquipTypes")
end

--获取装备信息 通过EquipQuality表ID
function EquipModel.GetEquipTypeByEquipQualityID(id)
    return ConfigMgr.GetItem("configEquipTypes", EquipModel.QualityID2TypeID(id))
end

--获取装备背包
function EquipModel.GetEquipBag()
    return Model.GetMap(ModelType.EquipBag)
end

--获取宝石背包
function EquipModel.GetJewelBag()
    return Model.GetMap(ModelType.JewelBag)
end

--更新宝石背包
function EquipModel.UpdateJewelBag(confId, data)
    Model.Create(ModelType.JewelBag, confId, data)
end
--宝石背包添加材料
function EquipModel.AddJewelBag(Jewels)
    local jewelsbag = EquipModel.GetJewelBag()
    for _,v in pairs(Jewels) do
        local jewel = jewelsbag[v.ConfId]
        if jewel then
            jewel.Amount = v.Amount
        else
            EquipModel.UpdateJewelBag(v.ConfId,v)
        end
    end
end

--获取拥有指定材料的数量
function EquipModel.GetMaterialAmountById(confId)
    return Model.Find(ModelType.JewelBag, confId)
end

--获取装备插槽信息
function EquipModel.GetEquipPart()
    return Model.GetMap(ModelType.EquipSlot)
end
--获取一个装备插槽信息
function EquipModel.GetEquipPartByPos(pos)
    return Model.GetInfo(ModelType.EquipSlot,pos)
end
--获取装备交易事件
function EquipModel.GetEquipEvents()
    local event = Model.GetMap(ModelType.EquipEvents)
    if event then
        event.Category = EventType.B_EQUIPTRAN
    end
    return event
end
--更新装备交易事件
function EquipModel.UpdateEquipEvent(event)
    Model.InitOtherInfo(ModelType.EquipEvents, event)
    Event.Broadcast(EventDefines.RefreshEquipEvent)
end
--去除装备交易事件
function EquipModel.RemoveEquipEvent(Uuid)
    local event = EquipModel.GetEquipEvents()
    if not event then
        return
    end
    if event.Uuid == Uuid then
        Model.InitOtherInfo(ModelType.EquipEvents, nil)
        Event.Broadcast(EventDefines.RefreshEquipEvent)
    end
end
-- 设置装备交易结束
function EquipModel.SetEquipEventEnd(uuid)
    local event = EquipModel.GetEquipEvents()
    if not event then
        return
    end
    if event.Uuid ~= uuid then
        return
    end
    event.FinishAt = Tool.Time()
    
    Event.Broadcast(EventDefines.RefreshEquipEvent)
end
--获取材料生产信息
function EquipModel.GetMaterialMakeInfo()
    return Model.JewelMakeInfo
end
--获取正在生产材料信息
function EquipModel.GetMaterialMakeEvent()
    local event = Model.JewelMakeInfo.RunEvent
    if event and event.JewelId ~= 0 then
        event.Category = EventType.B_EQUIPMATERIALMAKE
    end
    return event
end
--根据装备的Uuid获取Id
function EquipModel.GetEquipModelByUuid(Uuid)
    local equips = EquipModel.GetEquipBag()
    for _,v in pairs(equips) do
        if v.Uuid == Uuid then
            return v
        end
    end
    return nil
end
--修改装备信息
function EquipModel.UpdateEquipInfo(equip)
    local equipBag = Model.GetMap(ModelType.EquipBag)
    for _,v1 in pairs(equip.EquipList) do
        -- for i2,v2 in ipairs(equipBag) do
        --     if v2.Uuid == v1.Uuid then
        --         equipBag[i2] = v1
        --         break
        --     end
        -- end
        equipBag[v1.Uuid] = v1
    end
end
--修改装备槽信息
function EquipModel.UpdateEquipPartInfo(equip)
    local EquipSlot = Model.GetMap(ModelType.EquipSlot)
    for i,v in ipairs(EquipSlot) do
        if v.Pos == equip.Pos then
            EquipSlot[i] = equip
            break
        end
    end
end

--删除指定装备
function EquipModel.DelEquip(uuid)
    Model.Delete(ModelType.EquipBag, uuid)
end

--获取正在生产材料
function EquipModel.GetMakingMaterial()
    local runEvent = Model.JewelMakeInfo.RunEvent
    if runEvent.JewelId == 0 then
        return nil
    end
    return runEvent
end
--获取结束材料生产格子所需钻石
function EquipModel.GetUnlockMaterialMakeSlotPrice(index)
    local prices = Global.EquipMaterialQueueUnlockDiamonds
    for k,v in pairs(prices) do
        if k == index then
            return v
        end
    end
end
--判断需要的材料装备是否充足
function EquipModel.IsMaterialAdequate(equipTypesID,materials)
    --计算需要的材料是否充足
    local Jewels = EquipModel.GetJewelBag()
    local tempjewels = {}
    table.deepCopy(Jewels,tempjewels)
    for _,v1 in pairs(materials) do
        local currentAdequate = false
        local needNum = 0
        local needMaterialID = nil
        for _,v2 in pairs(tempjewels) do
            if v1.material_id == EquipModel.QualityID2TypeID(v2.ConfId) then
                if v1.amount <= v2.Amount then
                    needNum = v1.amount
                    needMaterialID = v2.ConfId
                    currentAdequate = true
                    break
                end
            end
        end
        if not currentAdequate then
            return false
        end
        if needMaterialID then
            tempjewels[needMaterialID].Amount = tempjewels[needMaterialID].Amount - needNum
        end
    end
    --计算需要的装备是否充足
    if not equipTypesID then
        return true
    end
    local equips = EquipModel.GetEquipBag()
    for _,v1 in pairs(equips) do
        for _,v2 in pairs(equipTypesID) do
            if EquipModel.QualityID2TypeID(v1.Id) == v2 then
                return true
            end
        end
    end
    return false
end

--计算合成装备各个品阶的概率
--min max可能获取到的最低最高品质]
-- equipQuality 消耗装备品质
-- continueMatNumb 装备权重
-- jewels消耗宝石 key：品质  value：消耗的对应品质的宝石的数量
-- return EquipModel[{},{}] key：品质 value 品质对应概率
function EquipModel.CalcQualitysRatio(min,max,equipQuality,continueMatNumb,jewels)
    local baseWeight = {}
    local QualitysRatio = {}
    local sum = 0
    local sumWeight = 0.0
    local tem = {}
    for i = EquipModel.EquipQuality.EquipQuialityMin , EquipModel.EquipQuality.EquipQuialityMax do
        if i < min or i > max  then
            baseWeight[i] = 0
        else
            if i == equipQuality then
                baseWeight[i] =jewels[i] + continueMatNumb
            else
                baseWeight[i] =jewels[i]
            end
            sum = baseWeight[i] + sum
            tem[i] = sum*(max-i)*Global.EquipQualityFactor
            baseWeight[i] = baseWeight[i] + tem[i]
            sumWeight = sumWeight + baseWeight[i]
        end
    end
    for i = EquipModel.EquipQuality.EquipQuialityMin , EquipModel.EquipQuality.EquipQuialityMax do
        QualitysRatio[i] = baseWeight[i] / sumWeight
    end
    return QualitysRatio
end
--在装备材料里寻找最匹配的材料 typeID:材料typeID num：材料数目
-- return  {ConfId=nil,Amount=nil,quality = nil}
function EquipModel.GetMatchMaterialByTypeID(materials,isworst)
    local jewels = EquipModel.GetJewelBag()
    local tempjewels = {}
    local result = {}
    local maxQuality = EquipModel.EquipQuality.EquipQuialityMin
    if not isworst then
        isworst = false
    end
    table.deepCopy(jewels,tempjewels)
    local qualitydecide = function (a, b)
        return isworst == (a < b)
    end
    for k,v in pairs(materials) do
        local typeID = v.material_id
        local num = v.amount
        local targetJewel = nil
        
        for _,v2 in pairs(tempjewels) do
            if EquipModel.QualityID2TypeID(v2.ConfId) == typeID then
                local materialquality = EquipModel.QualityID2Quality(v2.ConfId)
                maxQuality = maxQuality > materialquality and maxQuality or materialquality
                if not targetJewel then
                    local addNum =  num < v2.Amount and num or v2.Amount
                    targetJewel = {ConfId=v2.ConfId,Amount= addNum,quality = materialquality}
                else
                    if qualitydecide(materialquality , targetJewel.quality) and v2.Amount >= num then
                        targetJewel = {ConfId=v2.ConfId,Amount=num,quality =materialquality}
                    elseif v2.Amount >= num and  targetJewel.Amount < num then
                        targetJewel = {ConfId=v2.ConfId,Amount=num,quality = materialquality}
                    end
                end
            end
        end
        if not targetJewel then
            targetJewel = {ConfId=typeID +1,Amount=0,quality =1}
        end
        table.insert(result,targetJewel)
        if tempjewels[targetJewel.ConfId] then
            tempjewels[targetJewel.ConfId].Amount = tempjewels[targetJewel.ConfId].Amount-targetJewel.Amount
        end
    end
    return result,maxQuality
end
-- 获取放入材料祭品框后剩余的材料数
function EquipModel.GetLastMaterialafterPart(materials,qualityID)
    local Num = EquipModel.GetJewelBag()[qualityID].Amount
    for _,v in pairs(materials) do
        if v.ConfId == qualityID then
            Num = Num - v.Amount
        end
    end
    return Num
end
--在装备表里寻找材料消耗信息 JewelIds：材料id
-- return  {ConfId=nil,Amount=nil,quality = nil}
function EquipModel.GetMaterialConsumeByTypeID(typeID,JewelIds)
    local equip =EquipModel.GetEquipTypeByEquipQualityID(typeID)
    local targetJewel = {}
    for i = 1,#equip.need_material_Serial_ids do
        targetJewel[i] = {
            ConfId=JewelIds[i],
            Amount=equip.need_material_Serial_ids[i].amount,
            quality=EquipModel.QualityID2Quality(JewelIds[i])
        }
    end
    return targetJewel
end
-- 通过typesID选出合适的装备信息
function EquipModel.GetEquipBagByTypeId(typesID)
    if not typesID then
        return nil
    end

    local result = {}
    local JewelBag = EquipModel.GetEquipBag()
    for _,v1 in pairs(JewelBag) do
        for _,v2 in pairs(typesID) do
            if EquipModel.QualityID2TypeID(v1.Id) * 100 == v2 then
                table.insert(result,v1)
            end
        end
    end
    return result
end
function EquipModel.GetEquipBagByTypeId(typesID)
    if not typesID then
        return nil
    end

    local result = {}
    local JewelBag = EquipModel.GetEquipBag()
    for _,v1 in pairs(JewelBag) do
        for _,v2 in pairs(typesID) do
            if EquipModel.QualityID2TypeID(v1.Id) == v2 then
                table.insert(result,v1)
            end
        end
    end
    return result
end

-- quilityID转typeid   装备材料通用
function EquipModel.QualityID2TypeID(qalityID)
    return math.modf(qalityID/ 100) * 100
end
-- qtypeid 获取材质   装备材料通用
function EquipModel.QualityID2Quality(qalityID)
    return math.fmod( qalityID, 100 )
end
-- typpeID和材质转qualiyID 装备材料通用
function EquipModel.TypeID2QualityID(typeIDID,quality)
    return typeIDID + quality
end
--获取拥有指定装备
function EquipModel.GetEquipsById(id)
    local equips = {}
    local list = Model.GetMap(ModelType.EquipBag)
    for _,v in pairs(list) do
        if id == v.Id then
            table.insert(equips, v)
        end
    end

    return equips
end

--获取拥有的相同品质和等级的装备
function EquipModel.GetEquipsByQulityLevel(quality, lv)
    local equips = {}
    local list = Model.GetMap(ModelType.EquipBag)
    for _,v in pairs(list) do
        local config = EquipModel.GetEquipQualityById(v.Id)
        local typeConfig = EquipModel.GetEquipTypeById(EquipModel.QualityID2TypeID(v.Id))
        if config.quality == quality and typeConfig.equip_level == lv then
            table.insert(equips, v)
        end
    end

    return equips
end

--判断装备是否有同类ID在交易
function EquipModel.IsAlikeIDTransaction(id)
    local EquipEvent = EquipModel.GetEquipEvents()
    if EquipEvent and
        EquipModel.QualityID2TypeID(EquipEvent.EquipId) == EquipModel.QualityID2TypeID(id) then
            return EquipEvent
    end
    return false
end
-- 装备工厂是否在升级
function EquipModel.IsEquipFactoryUpgrade()
    local build = BuildModel.FindByConfId(EQUIPFACTORYID)
    if not build then
        return false
    end
    local upevent =  EventModel.GetUpgradeEvent(build.Id)
    if upevent then
        return true
    end
    return false
end
-- 获取装备工厂的building
function EquipModel.GetEquipFactory()
    local build = BuildModel.FindByConfId(EQUIPFACTORYID)
    return build
end
-- 获取装备工厂的配置
function EquipModel.GetEquipFactoryConfig()
    local build = EquipModel.GetEquipFactory()
    return ConfigMgr.GetItem("configEquipFactorys", build.Level + EQUIPFACTORYID)
end
-- 计算补充x资源需要消耗的钻石
function EquipModel.ConsumeSupplementChip(ChipNum)
    local cost = ChipNum*Global.Resource4EquipDiamondCost
    return math.ceil(cost)
end

-- 根据品质获取色号
function EquipModel.GetColorCodeByQuality(quality)
    return colorCode[quality]
end
-- 根据品质获取色名字
function EquipModel.GetColorNameByQuality(quality)
    return colorName[quality]
end
-- 判断对应的装备槽是否有装备可以穿戴
function EquipModel.IsEquipOfPart(part)
    local equips = EquipModel.GetEquipBag()
    for _,v in pairs(equips) do
        local equipType = EquipModel.GetEquipTypeByEquipQualityID(v.Id)
        if equipType then
            if equipType.equip_part == part and equipType.equip_level <= Model.Player.HeroLevel then
                return true
            end
        end
    end
    return false
end
-- 判断装备交易是否结束
function EquipModel.IsEquipEventEnd()
    local EquipEvent = EquipModel.GetEquipEvents()
    if not EquipEvent then
        return false
    end
    return EquipEvent.FinishAt - Tool.Time() <= 0
end
------------------------net操作
--提取装备
function EquipModel.Taketequip(Uuid,cb,surecb)
    assert(Uuid, "Taketequip self.Uuid is nil")
    local Net_func = function(rsp)
        EquipModel.RemoveEquipEvent(rsp.EventId)
        EquipModel.EquipFactoryAnim(false)
        _G.UIMgr:Open("EquipDetail", rsp.EquipUuid, true,function ()
            if surecb then
                surecb()
            end
        end)
        if cb then
            cb()
        end
    end
    Net.Equip.TakeExchangeEquip(
        Uuid,
        function(rsp)
            Net_func(rsp)
        end
    )
end

function EquipModel.EquipFactoryAnim(flag,EquipId)
    if flag then
        --收取气泡
        local typeConfig = EquipModel.GetEquipTypeById(EquipModel.QualityID2TypeID(EquipId))
        local buildId = BuildModel.GetObjectByConfid(Global.BuildingEquipFactory)
        BuildModel.GetObject(buildId):EquipMakeAnim(true, typeConfig.icon)
        return
    end
    local buildId = BuildModel.GetObjectByConfid(Global.BuildingEquipFactory)
    BuildModel.GetObject(buildId):EquipMakeAnim(false)
end
--装备钻石加速
function EquipModel.EquipSpeed(Uuid,equipID)
    assert(Uuid, "Speedequip self.Uuid is nil")

    _G.Net.Events.Speedup(_G.EventType.B_EQUIPTRAN, Uuid, function (rsp)
        EquipModel.EquipFactoryAnim(true,rsp.EquipId)
        EquipModel.SetEquipEventEnd(Uuid)
    end)
end
return EquipModel