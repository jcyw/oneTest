-- 道具
local PropModel = {}

-------------------------------------------------道具配置
-- 通过配置ID获取配置
function GetConf(confId)
    return ConfigMgr.GetItem('configItems', confId)
end
-- 通过配置ID获取道具 [类型]
function GetType(confId)
    local c = GetConf(confId)
    if not c then
        return
    end
    return c.type
end
-- 通过配置ID获取道具 [子类型]
function GetSubtype(confId)
    local c = GetConf(confId)
    if not c then
        return
    end
    return c.type2
end
-- 通过配置ID获取道具 [数值(时间)]
function GetValue(confId)
    local c = GetConf(confId)
    if not c then
        return
    end
    return c.value
end

-------------------------------------------------道具
-- 判断道具加速时间是否远大于队列时间
function PropModel.CheckFarTime(propTime, accTime)
    return propTime - accTime > PropType.FARTIME
end

local timerList = {86400,28800,7200,3540,240,0}
local itemTimerList = {86400,28800,7200,3600,300,60}

-- 一键加速道具推荐
function PropModel.OnPropDirUseRecommend(items,remianTimer)
    local useTable ={}
    local tempList ={}
    local tempNum1
    local tempNum2
    local tempNum3
    local tempRemianTimer = remianTimer
    local addReduceTimer = 0
    for k, v in pairs(items) do
        tempNum1 = tempList[v.value]
        if(tempNum1)then
            tempList[v.value] = tempNum1 + v.Amount
        else
            tempList[v.value] = v.Amount
        end
    end
    
    for i = 1, 6 do
        tempNum1 =  itemTimerList[i]
        tempNum2 = math.floor(remianTimer / tempNum1)
        tempNum3 = tempList[tempNum1]
        if(tempNum3 and tempNum3 > 0 and tempNum2>0)then
            if(tempNum2 > tempNum3)then
                remianTimer = remianTimer - tempNum1* tempNum3
                useTable[tempNum1] = tempNum3
                tempList[tempNum1] = nil
                addReduceTimer = addReduceTimer + tempNum1* tempNum3
            else
                remianTimer = remianTimer - tempNum1* tempNum2
                useTable[tempNum1] = tempNum2
                tempList[tempNum1] = tempNum3 - tempNum2
                addReduceTimer = addReduceTimer + tempNum1* tempNum2
            end
            if(remianTimer <= 0)then
                return useTable
            end
        end
    end
    
    if(remianTimer > 0)then
        for i = 6, 1, -1 do
            tempNum1 =  itemTimerList[i]
            tempNum2 = tempList[tempNum1]
            tempNum3 = useTable[tempNum1]
            if(tempNum2 and tempNum2>0)then
                if(tempNum1 >= tempRemianTimer and tempNum1 >= addReduceTimer)then
                    useTable = {}
                    useTable[tempNum1] = 1
                else
                    if(tempNum3)then
                        useTable[tempNum1] = tempNum3 + 1
                    else
                        useTable[tempNum1] = 1
                    end
                end
                return useTable
            end
        end
    end
    
    
    return useTable
end

function PropModel.FindFirstTimer(items,remianTimer)
    local index  = 6
    for i, v in ipairs(timerList) do
        if(remianTimer>v) then
            index = i
            break
        end
    end
    for i = index, 6 do
        for k, v in pairs(items) do
            if(itemTimerList[i] == v.value)then
                return v.ConfId
            end
        end
    end
    return 0
end

-- 道具重新分类 [k,v] k-子类型 v-道具  remianTimer 优先时间
function PropModel.ResortUseId(items,remianTimer)
    local useid =  PropModel.FindFirstTimer(items,remianTimer)
    if(useid == 0)then
        for _, v in pairs(items) do
            return v.ConfId
        end
    else
        return useid
    end
end

-- 道具重新分类 [k,v] k-子类型 v-道具  remianTimer 优先时间
function PropModel.ResortFirstTimer(items,remianTimer)
    local p = {}
    local temp = {}
    local fitTimer =  PropModel.FindFirstTimer(items,remianTimer)
    if(fitTimer == 0)then
        for _, v in ipairs(items) do
            table.insert(p, v)
        end
        table.sort(
                p,
                function(a, b)
                    return a.value < b.value
                end
        )
        return p
    else
        for _, v in ipairs(items) do
            if(v.value ==  fitTimer)then
                table.insert(p, v)
            else
                table.insert(temp, v)
            end
        end
        table.sort(
                temp,
                function(a, b)
                    return a.value < b.value
                end
        )

        for _, v in ipairs(temp) do
            table.insert(p, v)
        end
        return p
    end
end

-- 道具重新分类 [k,v] k-子类型 v-道具  isMult是否多元化[默认false]
function PropModel.Resort(items, isMult)
    local p = {}
    local sortArr = {}
    for _, v in ipairs(items) do
        local subtype = GetSubtype(v.ConfId)
        if not p[subtype] then
            p[subtype] = {}
        end
        table.insert(p[subtype], v)

        local isExit = false
        for _, vv in ipairs(sortArr) do
            if vv == subtype then
                isExit = true
                break
            end
        end
        if not isExit then
            table.insert(sortArr, subtype)
        end
    end
    for _, v in ipairs(p) do
        table.sort(
            v,
            function(a, b)
                return a.value < b.value
            end
        )
    end
    if not isMult then
        local m = {}
        for _, v in ipairs(sortArr) do
            for _, vv in ipairs(p[v]) do
                table.insert(m, vv)
            end
        end
        return m
    end
    return p
end

-------------------------------------------------加速道具
function GetAccItems(type)
    local items = {}
    for _, v in pairs(Model.Items) do
        local isAcc = GetType(v.ConfId) == PropType.ALL.Accelerate
        if isAcc and GetSubtype(v.ConfId) == type then
            if v.Amount > 0 then
                v.value = GetValue(v.ConfId)
                table.insert(items, v)
            end
        end
    end
    return items
end
-- 获取玩家已有通用加速道具 [参数-是否加上其他道具]
function PropModel.GetCommonAccItems(type)
    local items = GetAccItems(PropType.ACCELERATE.Common)
    if not type then
        return items
    end
    return Tool.MergeTables(GetAccItems(type), items)
end

--根据道具类型获取该类型所有道具
function PropModel.GetAccItemsByCategory(category, confId)
    if category == EventType.B_BUILD or category == EventType.B_DESTROY then
        return GetAccItems(PropType.ACCELERATE.Build)
    elseif category == EventType.B_TRAIN then
        local isTrap = confId == Global.BuildingSecurityFactory
        return GetAccItems(isTrap and PropType.ACCELERATE.Trap or PropType.ACCELERATE.Army)
    elseif category == EventType.B_TECH then
        return GetAccItems(PropType.ACCELERATE.Technology)
    elseif category == EventType.B_CURE then
        return GetAccItems(PropType.ACCELERATE.Injured)
    elseif category == EventType.B_BEASTCURE then
        return GetAccItems(PropType.ACCELERATE.BeastCure)
    elseif category == EventType.B_BEASTTECH then
        return GetAccItems(PropType.ACCELERATE.BeastTech)
    elseif category == EventType.B_EQUIPTRAN then
        return GetAccItems(PropType.ACCELERATE.EquipMake)
    end
end

return PropModel
