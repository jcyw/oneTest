local GD = _G.GD
local BuffItemModel = {}

local buffItem = {}

function BuffItemModel.Refresh()
    buffItem = {}
    local items = Model.GetMap(ModelType.BuffItem)
    for _,v in pairs(items) do
        if not buffItem[v.Source] then
            buffItem[v.Source] = {}
        end
        table.insert(buffItem[v.Source], v)
    end
end

function BuffItemModel.GetBuffItemsByType(type)
    return buffItem[type] and buffItem[type] or {}
end

function BuffItemModel.GetResBonus(type, bufftype)
    local produce = GD.ResAgent.GetResBasicOutPut(type)  -- 基本产量
    local buffs = Model.GetMap(ModelType.BuffItem)
    if bufftype then
        buffs = BuffItemModel.GetBuffItemsByType(bufftype)
    end
    local produceAllBonus = 10000 + 100 + 0 --所有产量加成
    local produceBonus = 10000 + 100 + type --产量加成 id
    -- local produceSpeedBonus = 10000 + 200 + type --采集速度加成 id
    local bonus = 0
    for _,v in pairs(buffs)do
        if v.ConfId == produceAllBonus then
            bonus = bonus + produce*v.Value/10000
        elseif v.ConfId == produceBonus then
            bonus = bonus + produce*v.Value/10000
        -- elseif v.ConfId == produceSpeedBonus then
        end
    end
    if not bufftype or produceAllBonus == BuffItem.TypedBuffItem then
        local resBuildInfo = Model.GetMap(ModelType.ResBuilds)
        local _resBuildList = {}
        for _,v in pairs(resBuildInfo)do
            if v.Category == type then
                table.insert(_resBuildList, v)
            end
        end
        for _,v in ipairs(_resBuildList)do
            if v.BuffExpireAt > Tool.Time() then
                bonus = bonus + v.Produce
            end
        end
    end
    -- return Tool.FormatNumberThousands(math.ceil(bonus))
    return math.ceil(bonus)
end

function BuffItemModel.GetModelByConfigId(configId)
    local items = Model.GetMap(ModelType.BuffItem)

    local expireAt = 0
    local result
    for k,v in pairs(items) do
        if v.ConfId == configId and v.ExpireAt > expireAt then
            result = v
            expireAt = v.ExpireAt
        end
    end

    return result
    -- return Model.Find(ModelType.BuffItem, configId)
end

function BuffItemModel.GetModelByIdType(configId, type)
    local items = Model.GetMap(ModelType.BuffItem)
    for k,v in pairs(items) do
        if v.ConfId == configId and v.Source == type then
            return v
        end
    end
end

function BuffItemModel.GetModelByIdSourceId(configId, id)
    local items = Model.GetMap(ModelType.BuffItem)
    for k,v in pairs(items) do
        if v.ConfId == configId and v.SourceId == id then
            return v
        end
    end
end

return BuffItemModel