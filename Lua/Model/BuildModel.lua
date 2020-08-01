local BuildModel = {}
local EventModel = import("Model/EventModel")
local BuildQueueModel = import("Model/CityMap/BuildQueueModel")
local Model = _G.Model

local innerConf = {} --内城建筑配置
local innerMoveConf = {} --内城可移动建筑配置
local innerCreateConf = {} --内城可创建建筑配置
local innerMovePiece = {} --内城可移动地块
local outerConf = {} --外城建筑配置
local beastConf = {} --巨兽建筑配置
local beastCreateConf = {} --巨兽可创建建筑配置
local buildObject = {} --建筑节点
local armyBuild = {}
local GodzillaUpgradeData --哥斯拉梯级对应建筑等级表
local KingkongUpgradeData --金刚梯级对应建筑等级表
local GlobalVars = GlobalVars
-------------------------------------------------指挥中心
-- 获取指挥中心建筑信息
function BuildModel.GetCenter()
    return BuildModel.FindByConfId(Global.BuildingCenter)
end
-- 获取指挥中心等级
function BuildModel.GetCenterLevel()
    local build = BuildModel.GetCenter()
    if not build then
        return 0
    end
    return build.Level
end

-------------------------------------------------建筑配置表 conf
-- 通过配置ID获取建筑配置
function BuildModel.GetConf(confId)
    return ConfigMgr.GetItem("configBuildings", confId)
end
-- 内城建筑配置列表
function BuildModel.InnerConf()
    if next(innerConf) ~= nil then
        return innerConf
    end
    local conf = ConfigMgr.GetList("configBuildings")
    for _, v in pairs(conf) do
        if v.zone == Global.BuildingZoneInnter and v.position then
            innerConf[v.position] = v
        end
    end
    return innerConf
end
-- 内城可移动建筑配置列表
function BuildModel.InnerMoveConf()
    if next(innerMoveConf) ~= nil then
        return innerMoveConf
    end
    for _, v in pairs(BuildModel.InnerConf()) do
        if v.zone == Global.BuildingZoneInnter and v.movable == BuildType.BUILD_MOVEABLE.Yes then
            table.insert(innerMoveConf, v)
        end
    end
    table.sort(
        innerMoveConf,
        function(a, b)
            return a.unlock_level < b.unlock_level
        end
    )
    return innerMoveConf
end
-- 内城可创建建筑配置列表
function BuildModel.InnerCreateConf(isRefresh, recommendPos)
    if not isRefresh and next(innerCreateConf) ~= nil then
        return innerCreateConf
    end
    innerCreateConf = {}
    local recommend = {}
    for _, v in pairs(BuildModel.InnerMoveConf()) do
        if not BuildModel.FindByConfId(v.id) then
            if v.position == recommendPos then
                recommend = v
            else
                table.insert(innerCreateConf, v)
            end
        end
    end
    table.sort(
        innerCreateConf,
        function(a, b)
            return a.unlock_level < b.unlock_level
        end
    )
    if next(recommend) ~= nil then
        table.insert(innerCreateConf, 1, recommend)
    end
    return innerCreateConf
end
-- 内城可移动地块
function BuildModel.InnerMovePiece()
    if next(innerMovePiece) ~= nil then
        return innerMovePiece
    end
    innerMovePiece = {}
    local notMovablePos = {} --城内不可移动建筑位置
    for _, v in pairs(BuildModel.InnerConf()) do
        if v.movable == BuildType.BUILD_MOVEABLE.No then
            table.insert(notMovablePos, v.position)
        end
    end
    local innerPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneInnter)
    local noPos = innerPosConf.no_pos
    for i = innerPosConf.start_pos + 1, innerPosConf.stop_pos do
        local isMovable = true
        for k, pos in pairs(notMovablePos) do
            if i == pos then
                isMovable = false
                table.remove(notMovablePos, k)
                break
            end
        end
        if isMovable then
            local isNoPos = false
            if noPos then
                for _, np in pairs(noPos) do
                    if np == i then
                        isNoPos = true
                    end
                end
            end
            if not isNoPos then
                table.insert(innerMovePiece, i)
            end
        end
    end
    return innerMovePiece
end
-- 外城建筑配置列表
function BuildModel.OuterConf()
    if next(outerConf) ~= nil then
        return outerConf
    end
    local conf = ConfigMgr.GetList("configBuildings")
    for _, v in pairs(conf) do
        if v.zone == Global.BuildingZoneWild then
            table.insert(outerConf, v)
        end
    end
    table.sort(
        outerConf,
        function(a, b)
            return a.unlock_level < b.unlock_level
        end
    )
    return outerConf
end
-- 巨兽建筑配置列表
function BuildModel.BeastConf()
    if next(beastConf) ~= nil then
        return beastConf
    end
    local conf = ConfigMgr.GetList("configBuildings")
    for _, v in pairs(conf) do
        if v.zone == Global.BuildingZoneBeast then
            table.insert(beastConf, v)
        end
    end
    table.sort(
        beastConf,
        function(a, b)
            return a.unlock_level < b.unlock_level
        end
    )
    return beastConf
end

--巢穴
function BuildModel.NestConf()
end

-- 巨兽可创建建筑配置列表
function BuildModel.BeastCreateConf(isRefresh, recommendPos)
    if not isRefresh and next(beastCreateConf) ~= nil then
        return beastCreateConf
    end
    beastCreateConf = {}
    local recommend = {}
    for _, v in pairs(BuildModel.BeastConf()) do
        if not BuildModel.FindByConfId(v.id) then
            if v.position == recommendPos then
                recommend = v
            else
                table.insert(beastCreateConf, v)
            end
        end
    end
    table.sort(
        beastCreateConf,
        function(a, b)
            return a.unlock_level < b.unlock_level
        end
    )
    if next(recommend) ~= nil then
        table.insert(beastCreateConf, 1, recommend)
    end
    return beastCreateConf
end

-- 根据配置ID判断建筑位置类型
function BuildModel.GetBuildPosType(confId)
    return BuildModel.GetConf(confId).zone
end
-- 根据位置判断建筑位置类型
function BuildModel.GetBuildPosTypeByPos(pos)
    --城内
    local innerPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneInnter)
    if pos > innerPosConf.start_pos and pos <= innerPosConf.stop_pos then
        return Global.BuildingZoneInnter
    end
    --城外
    local outerPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneWild)
    if pos > outerPosConf.start_pos and pos <= outerPosConf.stop_pos then
        return Global.BuildingZoneWild
    end
    --巨兽
    local beastPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneBeast)
    if pos > beastPosConf.start_pos and pos <= beastPosConf.stop_pos then
        return Global.BuildingZoneBeast
    end
    --巢穴
    local nestPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneNest)
    if pos > nestPosConf.start_pos and pos <= nestPosConf.stop_pos then
        return Global.BuildingZoneNest
    end
    --未知位置
    Log.Error("根据位置判断建筑位置类型 ERROR pos:", pos)
    return
end
-- 根据配置ID获取是否是城内或者巨兽建筑
function BuildModel.IsInnerOrBeast(confId)
    return Tool.Equal(BuildModel.GetBuildPosType(confId), Global.BuildingZoneInnter, Global.BuildingZoneBeast)
end
-- 根据位置获取是否是城内或者巨兽建筑
function BuildModel.IsInnerOrBeastByPos(pos)
    return Tool.Equal(BuildModel.GetBuildPosTypeByPos(pos), Global.BuildingZoneInnter, Global.BuildingZoneBeast)
end

-- 根据位置获取是否是城内包括巨兽或哥斯拉
function BuildModel.IsInnerByConfigId(confId)
    return Tool.Equal(BuildModel.GetBuildPosType(confId), Global.BuildingZoneInnter, Global.BuildingZoneBeast, Global.BuildingZoneNest)
end

-- 根据配置ID获取建筑图片组件
function BuildModel.GetIconCmptName(confId)
    local conf = BuildModel.GetConf(confId)
    return conf.building_control
end

-------------------------------------------------建筑配置 Model.Buildings
-- 通过建筑位置获取建筑数据
function BuildModel.FindByPos(pos)
    for _, v in pairs(Model.Buildings) do
        if v.Pos == pos then
            return v
        end
    end
end

function BuildModel.FindById(id)
    for _, v in pairs(Model.Buildings) do
        if v.Id == id then
            return v
        end
    end
end

--获取外城资源建筑最高等级的一个建筑，如果没有建筑则返回空值
function BuildModel.FindAssetBuildMax()
    local temp = {Level = 0}
    local buildings = {}
    local building
    --稀土建筑
    buildings[1] = BuildModel.FindMaxLevel(Global.BuildingStone) or temp
    --钢铁厂
    buildings[2] = BuildModel.FindMaxLevel(Global.BuildingWood) or temp
    --油厂
    buildings[3] = BuildModel.FindMaxLevel(Global.BuildingIron) or temp
    --食品厂
    buildings[4] = BuildModel.FindMaxLevel(Global.BuildingFood) or temp

    local max = 0
    for _, v in pairs(buildings) do
        if v.Level >= max then
            max = v.Level
            building = v
        end
    end
    return building
end

-- 通过配置Id获取建筑 如果是外城建筑则获取最高等级的建筑
function BuildModel.FindByConfId(confId, levelType)
    if BuildModel.IsInnerOrBeast(confId) then
        --内城和外城建筑ConfId唯一
        for _, v in pairs(Model.Buildings) do
            if v.ConfId == confId then
                return v
            end
        end
        return
    end
    if not levelType then
        levelType = "Max"
    end
    if levelType == "Max" then
        --外城建筑ConfId不唯一 获取最高等级的建筑
        return BuildModel.FindMaxLevel(confId)
    elseif levelType == "Min" then
        --外城建筑ConfId不唯一 获取最高等级的建筑
        return BuildModel.FindMinLevel(confId)
    end
end
-- 通过配置Id获取等级最高的建筑
function BuildModel.FindMaxLevel(confId)
    local max = 0
    local building
    for _, v in pairs(Model.Buildings) do
        if v.ConfId == confId and v.Level >= max then
            max = v.Level
            building = v
        end
    end
    return building
end
-- 通过配置Id获取等级最低的建筑
function BuildModel.FindMinLevel(confId)
    local min = math.huge
    local building
    for _, v in pairs(Model.Buildings) do
        if v.ConfId == confId then
            if v.Level == 0 then
                return v
            elseif v.Level < min then
                min = v.Level
                building = v
            end
        end
    end
    return building
end
-- 通过配置Id检查建筑是否存在
function BuildModel.CheckExist(confId)
    for _, v in pairs(Model.Buildings) do
        if v.ConfId == confId then
            return v
        end
    end
    return
end
-- 根据兵种ID获取建筑的ID
function BuildModel.GetConfIdByArmId(armId)
    armId = math.floor(armId / 100) * 100
    local buildId = armyBuild[armId]
    if buildId then
        return buildId
    end
    local conf = ConfigMgr.GetList("configBuildings")
    for _, v in pairs(conf) do
        if v.category == Global.BuildingTypeArmy then
            armyBuild[v.army.base_level] = v.id
        end
    end
    return armyBuild[armId]
end
-- 根据兵种ID获取建筑的ID
function BuildModel.GetConfIdById(armId)
    armId = math.floor(armId / 100) * 100
    local buildId = armyBuild[armId]
    if buildId then
        return buildId
    end
    local conf = ConfigMgr.GetList("configBuildings")
    for _, v in pairs(conf) do
        if v.army then
            armyBuild[v.army.base_level] = v.id
        end
    end
    return armyBuild[armId]
end
-- 通过配置Id获取所有相同的建筑
function BuildModel.GetAll(confId)
    local obj = {}
    for _, v in pairs(Model.Buildings) do
        if v.ConfId == confId then
            table.insert(obj, v)
        end
    end
    return obj
end
-- 获取建筑训练的最大数量
function BuildModel.GetTrainMaxNumber(confId)
    if confId == Global.BuildingSecurityFactory then
        local building = BuildModel.FindByConfId(confId)
        local lv = building.Level
        lv = lv > 0 and lv or 1
        local conf = ConfigMgr.GetItem("configSecurityFactorys", confId + lv)
        if not conf then
            return
        end
        return conf.SF_limit
    end
    local buildings = BuildModel.GetAll(Global.BuildingMarchTent)
    local max = Global.BaseTrainNum
    for _, v in ipairs(buildings) do
        if v.Level > 0 then
            local conf = ConfigMgr.GetItem("configMarchTents", (v.ConfId + v.Level))
            max = max + conf.train_max
        end
    end
    return max
end
-- 获取建筑训练速度
function BuildModel.GetTrainSpeed(confId)
    if confId == Global.BuildingSecurityFactory then
        return 0
    end
    local buildings = BuildModel.GetAll(Global.BuildingMarchTent)
    local speed = 0
    for _, v in ipairs(buildings) do
        if v.Level > 0 then
            local conf = ConfigMgr.GetItem("configMarchTents", (v.ConfId + v.Level))
            speed = speed + conf.train_speed
        end
    end
    return speed
end

-------------------------------------------------建筑国际化
-- 获取建组名称 I18n
function BuildModel.GetName(confId)
    return ConfigMgr.GetI18n("configI18nBuildings", confId .. "_NAME")
end
-- 获取建筑描述 I18n
function BuildModel.GetDesc(confId)
    return ConfigMgr.GetI18n("configI18nBuildings", confId .. "_DESC")
end
-- 获取建筑信息 I18n
function BuildModel.GetInfo(confId)
    return ConfigMgr.GetI18n("configI18nBuildings", confId .. "_INFO")
end

-------------------------------------------------建筑状态
-- 拥有免费时间的状态
function BuildModel.FreeState(category)
    return category == EventType.B_BUILD or category == EventType.B_DESTROY
end

-- 可以联盟帮助的事件状态
function BuildModel.UnionHelpState(category)
    local conf = ConfigMgr.GetItem("configQueues", category)
    if conf then
        return conf.help
    end
    return false
end
-------------------------------------------------建筑对象
-- 保存建筑对象 bid建筑Id
function BuildModel.AddObject(bid, obj)
    buildObject[bid] = obj
end
-- 删除建筑对象
function BuildModel.DelObject(bid)
    buildObject[bid] = nil
end
-- 获取建筑对象
function BuildModel.GetObject(bid)
    return buildObject[bid]
end
-- 获取所有建筑对象
function BuildModel.GetAllObject()
    return buildObject
end

--根据ConfId获取建筑
function BuildModel.GetObjectByConfid(confid)
    local buildings = Model.Buildings
    if not buildings then
        return false
    end
    if buildings then
        for k, v in pairs(buildings) do
            if v.ConfId == confid then
                return v.Id
            end
        end
    end
end

--根据confId获取外城建筑
function BuildModel.GetOuterBuildingByConfid(confId)
    local buildings = Model.Buildings
    if not buildings then
        return false
    end

    local result = {}
    for _, v in pairs(buildings) do
        if v.ConfId == confId then
            table.insert(result, v)
        end
    end
    return result
end

-------------------------------------------------资源建筑
-- 获取当前资源建筑产量
function BuildModel.GetResYield(info)
    --return info.Storage + ((info.BuffRatio + 1) * (Tool.Time() - info.UpdatedAt) * info.Produce) / 3600
    return (Tool.Time() - info.UpdatedAt) * info.Produce / 3600
end

-- 或者资源建筑刷新时间
function BuildModel.GetResTime(info)
    return (3600 - info.Storage) / (info.Produce * (info.BuffRatio + 1))
end

-- 根据唯一Id获取该资源建筑是否有增产buff
function BuildModel.IsAddBuffByConfid(id)
    local resBuilds = Model.ResBuilds
    for _, v in pairs(resBuilds) do
        if v.Id == id and v.BuffExpireAt > Tool.Time() then
            return true
        end
    end

    return false
end

-------------------------------------------------建筑队列
-- 找到等级最低且没有事件的建筑
function BuildModel.FindAllMinLevel()
    local lev = math.huge
    local building
    for _, v in pairs(Model.Buildings) do
        local conf = BuildModel.GetConf(v.ConfId)
        if conf and conf.max_level > 1 then
            if v.Level > 0 and v.Level < lev then
                local event = EventModel.GetUpgradeEvent(v.Id)
                if not event then
                    lev = v.Level
                    building = v
                end
            end
        end
    end
    return building
end
-- 检查建筑队列是否满足[升级、创建等]
function BuildModel.CheckBuilder(from, time, name, cb)
    local freeQueue = Model.Builders[BuildType.QUEUE.Free]
    if freeQueue.IsWorking then
        local chargeQueue = Model.Builders[BuildType.QUEUE.Charge]
        local activeTime = chargeQueue.ExpireAt - Tool.Time()
        if activeTime > 0 then
            --金币队列激活中
            if chargeQueue.IsWorking then
                --金币队列进行中
                TipUtil.TipById(50050)
                return false,true
            else
                --金币队列空闲中
                if activeTime >= time then
                    --队列时间充裕
                    return true
                else
                    --队列时间不足
                    UIMgr:Open("BuildRelated/QueuePopup", from, time, name, cb)
                    return false
                end
            end
        else
            --金币队列未激活
            UIMgr:Open("BuildRelated/QueuePopup", from, time, name, cb)
            return false
        end
    else
        --免费队列空闲中
        return true
    end
end

--是否有空闲队列
function BuildModel.CheckQueueIdle()
    local freeQueue = Model.Builders[BuildType.QUEUE.Free]
    local chargeQueue = Model.Builders[BuildType.QUEUE.Charge]
    local isFreeIdle = false
    local ischargeIdle = false
    if freeQueue.IsWorking then
        isFreeIdle = false
    else
        --免费队列空闲中
        isFreeIdle = true
    end
    if not BuildQueueModel.GetChargeLock() then
        --金币队列激活中
        if chargeQueue.IsWorking then
            --金币队列进行中
            ischargeIdle = false
        else
            ischargeIdle = true
        end
    else
        ischargeIdle = false
    end
    return isFreeIdle or ischargeIdle
end

--建筑升级提示
function BuildModel.UpgradePrompt()
    local isFreeWorking = Model.Builders[BuildType.QUEUE.Free].IsWorking
    local isChargeWorking = Model.Builders[BuildType.QUEUE.Charge].IsWorking
    local isChargeUnlock = Model.Builders[BuildType.QUEUE.Charge].ExpireAt > Tool.Time()

    if isFreeWorking and (not isChargeUnlock or isChargeWorking) then
        --不显示升级提示 (免费队列工作中 并且 付费队列未解锁或者付费队列工作中)
        for _, v in pairs(Model.Buildings) do
            BuildModel.GetObject(v.Id):ShowUpgradePrompt(false)
        end
    else
        --显示升级提示 (免费队列空闲中 或者 付费队列已解锁并且付费队列空闲中)
        for _, v in pairs(Model.Buildings) do
            local node = BuildModel.GetObject(v.Id)
            --建筑倒计时是否显示
            local bConf = ConfigMgr.GetItem("configBuildings", v.ConfId)
            local isCond = true
            if node:GetCmptCDActive() or 1 ~= bConf.showlevel then
                isCond = false
            else
                --建筑是否达到最高等级
                if v.Level >= bConf.max_level or bConf.max_level <= 1 then
                    isCond = false
                else
                    --升级资源消耗是否满足
                    local uConf = ConfigMgr.GetItem("configBuildingUpgrades", v.ConfId + v.Level + 1)
                    -- for _, res in pairs(uConf.res_req) do
                    --     if Model.Resources[res.category].Amount < res.amount then
                    --         isCond = false
                    --         break
                    --     end
                    -- end
                    --升级条件是否满足
                    for _, condition in pairs(uConf.condition) do
                        local building = BuildModel.FindByConfId(condition.confId)
                        if not building or building.Level < condition.level then
                            isCond = false
                            break
                        end
                    end
                    --升级建筑消耗道具不足
                    if isCond then
                        local item = uConf.item
                        if item then
                            if Model.Items[item.item] then
                                isCond = Model.Items[item.item].Amount >= item.amount
                            else
                                isCond = false
                            end
                        end
                    end
                end
            end
            node:ShowUpgradePrompt(isCond)
        end
    end
end

--根据ConfId获取建筑的创建位置
function BuildModel.GetCreatPos(confId)
    local pos
    local conf = ConfigMgr.GetItem("configBuildings", confId)
    local suggestPos = conf.position
    if conf.zone == Global.BuildingZoneInnter then
        --城内
        --查看推荐位置是否被建造
        local findBuild = BuildModel.FindByPos(suggestPos)
        if not findBuild or confId == findBuild.ConfId then
            --跳转推荐位置
            pos = suggestPos
        else
            for _, v in pairs(BuildModel.InnerMovePiece()) do
                if not BuildModel.FindByPos(v) then
                    pos = v
                    break
                end
            end
        end
    elseif conf.zone == Global.BuildingZoneWild then
        --城外
        --查看推荐位置是否被建造
        for i = suggestPos, suggestPos + 4 do
            local findBuild = BuildModel.FindByPos(i)
            local piece = CityMapModel.GetMapPiece(i)
            if not findBuild and piece and piece:GetPieceUnlock() then
                pos = i
                break
            end
        end
        if not pos then
            local minPos, unlock
            local outerPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneWild)
            for i = outerPosConf.start_pos + 1, outerPosConf.stop_pos do
                if not BuildModel.FindByPos(i) then
                    if not minPos then
                        minPos = i
                    end
                    local piece = CityMapModel.GetMapPiece(i)
                    if piece and piece:GetPieceUnlock() then
                        unlock = true
                        pos = i
                        break
                    end
                end
            end
            if not unlock then
                pos = minPos
            end
        end
    elseif conf.zone == Global.BuildingZoneBeast then
        --巨兽
        --查看推荐位置是否被建造
        if not BuildModel.FindByPos(suggestPos) then
            --跳转推荐位置
            pos = suggestPos
        else
            for _, v in pairs(BuildModel.BeastConf()) do
                if not BuildModel.FindByPos(v.position) then
                    pos = v.position
                    break
                end
            end
        end
    elseif conf.zone == Global.BuildingZoneNest then
        --巢穴
        pos = suggestPos
    end
    return pos
end

--判断id是否是科研中心
function BuildModel.GetTechCenterId(techdispId)
    local config = ConfigMgr.GetItem("configTechDisplays", techdispId)
    if not config then
        return nil
    end
    if config.id ~= nil then
        return 403000
    else
        return nil
    end
end

--根据资源建筑配置id获取等级最高的没有增产buff的建筑
function BuildModel.GetMaxNoBuffResBuildingById(confId)
    local buildings = BuildModel.GetOuterBuildingByConfid(confId)
    local default
    table.sort(
        buildings,
        function(a, b)
            return a.Level > b.Level
        end
    )
    for _, v in pairs(buildings) do
        if not BuildModel.IsAddBuffByConfid(v.Id) then
            return true, v
        end
        default = v
    end

    return false, default
end

--根据建筑配置id获取建筑是否解锁
function BuildModel.GetUnlockByConfId(confId)
    return Model.Player.Level >= BuildModel.GetConf(confId).unlock_level
end

--检查战区医院伤兵情况
function BuildModel.CheckBuildHospital()
    for _, v in pairs(Model.Buildings) do
        if v.ConfId == Global.BuildingHospital then
            BuildModel.GetObject(v.Id):ResetCD()
        end
    end
end

--获取有空闲状态的医院且不在拆除中
function BuildModel.GetIdleHospital()
    for _, v in pairs(Model.Buildings) do
        if v.ConfId == Global.BuildingHospital then
            if not EventModel.GetEvent(v) then
                return v
            end
        end
    end
    return
end

--建筑队列指引顺序
function BuildModel.QueueGuideOrder()
    local orderBuildings = {}
    local centerBuilding = nil
    for _, v in pairs(Model.Buildings) do
        if v.ConfId == Global.BuildingCenter then
            centerBuilding = v
        end
        local conf = BuildModel.GetConf(v.ConfId)
        if conf.order and v.Level > 0 then
            repeat
                local event = EventModel.GetEvent(v)
                if event then
                    break
                end
                v.Order = conf.order
                if #orderBuildings > 0 and BuildModel.GetBuildPosType(v.ConfId) == Global.BuildingZoneWild then
                    for k, vv in pairs(orderBuildings) do
                        if vv.ConfId == v.ConfId then
                            if v.Level > vv.Level then
                                orderBuildings[k] = v
                            end
                            break
                        end
                    end
                else
                    table.insert(orderBuildings, v)
                end
            until true
        end
    end
    table.sort(
        orderBuildings,
        function(a, b)
            if a.Level == b.Level then
                return a.Order < b.Order
            else
                return a.Level < b.Level
            end
        end
    )
    for _, v in ipairs(orderBuildings) do
        if v.Level < centerBuilding.Level then
            --有建筑等级低于指挥中心
            GlobalVars.ClickBuilder = true
            JumpMap:JumpTo({jump = 814000, para = v.ConfId, para1 = v})
            return
        end
    end

    --没有建筑等级低于指挥中心
    local event = EventModel.GetEvent(centerBuilding)
    if event then
        --指挥中心处于对列
        GlobalVars.ClickBuilder = true
        JumpMap:JumpTo({jump = 814000, para = centerBuilding.ConfId, para1 = centerBuilding})
    else
        --指挥中心未处于对列
        local minConfId = math.huge
        local obj
        for _, v in pairs(buildObject) do
            if v:CheckShowUpgredeArrow() and v.building.ConfId < minConfId then
                obj = v
                minConfId = v.building.ConfId
            end
        end
        if obj then
            GlobalVars.ClickBuilder = true
            JumpMap:JumpTo({jump = 814000, para = obj.building.ConfId, para1 = obj.building})
        else
            TipUtil.TipById(50296)
        end
    end
end

--点击建筑队列
function BuildModel.OnBuilderClick(builderType)
    if builderType then
        --点击建筑队列
        local builder = Model.Builders[builderType]
        if builder.IsWorking then
            --队列进行中
            local bid = builder.EventId
            local building = Model.Find(ModelType.Buildings, bid)
            if not building then
                return
            end
            JumpMap:JumpTo({jump = 814000, para = building.ConfId, para1 = building})
        else
            --队列空闲中
            BuildModel.QueueGuideOrder()
        end
    else
        --推荐建筑队列
        local freeQueue = Model.Builders[BuildType.QUEUE.Free]
        if freeQueue.IsWorking then
            local chargeQueue = Model.Builders[BuildType.QUEUE.Charge]
            if chargeQueue.IsWorking then
                BuildModel.OnBuilderClick(BuildType.QUEUE.Free)
            else
                BuildModel.QueueGuideOrder()
            end
        else
            BuildModel.QueueGuideOrder()
        end
    end
end

--检测巢穴是否解锁
function BuildModel.CheckBuildNestUnlock(confId)
    if confId == Global.BuildingGodzilla then
        --哥斯拉
        local ab = ABTest.Kingkong_ABLogic() and 1 or 2
        return Model.Player.Level >= Global.Kingkongnestlevel[ab]
    elseif confId == Global.BuildingKingkong then
        --金刚
        return Model.Player.isUnlockKingkong
    else
        Log.Debug("检测巢穴是否解锁 confId: {0}", confId)
    end
end

--检测是否已获得巨兽
function BuildModel.CheckBeastUnlock(confId)
    if confId == Global.BuildingGodzilla then
        --哥斯拉
        local ab = ABTest.Kingkong_ABLogic() and 1 or 2
        if Model.Player.Level < Global.Kingkongnestlevel[ab] then
            return false
        else
            local building = BuildModel.FindByConfId(confId)
            local itemBuild = BuildModel.GetObject(building.Id)
            if not itemBuild then
                return false
            end
            return not (itemBuild._itemLock and itemBuild._itemLock.visible)
        end
    elseif confId == Global.BuildingKingkong then
        --金刚
        return Model.Player.isUnlockKingkong
    else
        Log.Debug("检测是否已获得巨兽 confId: {0}", confId)
    end
end

--通过建筑位置检测是否是巨兽巢穴
function BuildModel.IsNestBuilding(pos)
    local posType = BuildModel.GetBuildPosTypeByPos(pos)
    if Tool.Equal(posType, Global.BuildingZoneNest) then
        return true
    end

    return false
end
function BuildModel.InitMonsterUpgradeData()
    if not GodzillaUpgradeData then
        local conf = ConfigMgr.GetDictionary("configArmys")
        GodzillaUpgradeData = {}
        for id,data in pairs(conf) do
            if math.floor(id / 100) == 1080 and math.floor(id % 100) ~= 0 then
                local tab = {needBuildLevel = math.floor(data.building % 100),monsterLevel = math.floor(id % 100)+1,type = 1,monsterId = id}
                GodzillaUpgradeData[#GodzillaUpgradeData + 1] = tab
            end
        end
    end
    if not KingkongUpgradeData then
        local conf = ConfigMgr.GetDictionary("configArmys")
        KingkongUpgradeData = {}
        for id,data in pairs(conf) do
            if math.floor(id / 100) == 1081 and math.floor(id % 100) ~= 0 then
                local tab = {needBuildLevel = math.floor(data.building % 100),monsterLevel = math.floor(id % 100)+1,type = 2,monsterId = id}
                KingkongUpgradeData[#KingkongUpgradeData + 1] = tab
            end
        end
    end
end

--本地记录巨兽巢穴升级中的状态
function BuildModel.SetGodzillaUpgradingMark(curBuildLevel)
    if not GodzillaUpgradeData then
        BuildModel.InitMonsterUpgradeData()
    end
    for k,v in pairs(GodzillaUpgradeData) do
        if curBuildLevel + 1 == v.needBuildLevel then
            local godzillaUpgradingMark = {newBuildLevel = v.needBuildLevel,newMonsterLevel = v.monsterLevel}
            Util.SetPlayerData("GodzillaUpgradingMark", JSON.encode(godzillaUpgradingMark))
        else
            Util.SetPlayerData("GodzillaUpgradingMark", nil)
        end
    end
end

function BuildModel.SetKingkongUpgradingMark(curBuildLevel)
    if not KingkongUpgradeData then
        BuildModel.InitMonsterUpgradeData()
    end
    for k,v in pairs(KingkongUpgradeData) do
        if curBuildLevel + 1 == v.needBuildLevel then
            local KingkangUpgradingMark = {newBuildLevel = v.needBuildLevel,newMonsterLevel = v.monsterLevel}
            Util.SetPlayerData("KingkangUpgradingMark", JSON.encode(KingkangUpgradingMark))
        else
            Util.SetPlayerData("KingkangUpgradingMark", nil)
        end
    end
end
--检查是否够梯级弹出巨兽弹窗  立刻
function BuildModel.CheckGodzillaUpgradingPopup_Now(curBuildLevel)
    if not GodzillaUpgradeData then
        BuildModel.InitMonsterUpgradeData()
    end
    for k,v in pairs(GodzillaUpgradeData) do
        if curBuildLevel == v.needBuildLevel then
            PopupWindowQueue:Push("MonsterNetUpgradePopup", v)
            --Util.SetPlayerData("GodzillaUpgradingMark", nil)
            break
        end
    end
end

function BuildModel.CheckKingkongUpgradingPopup_Now(curBuildLevel)
    if not KingkongUpgradeData then
        BuildModel.InitMonsterUpgradeData()
    end
    for k,v in pairs(KingkongUpgradeData) do
        if curBuildLevel == v.needBuildLevel then
            PopupWindowQueue:Push("MonsterNetUpgradePopup", v)
            --Util.SetPlayerData("KingkangUpgradingMark", nil)
            break
        end
    end
end

--检查是否够梯级弹出巨兽弹窗  每次登录
function BuildModel.CheckGodzillaUpgradingPopup()
    if not GodzillaUpgradeData then
        BuildModel.InitMonsterUpgradeData()
    end
    local json = Util.GetPlayerData("GodzillaUpgradingMark")
    local data = {}
    if json ~= "" then
        data = JSON.decode(json)
        data.newMonsterLevel = math.floor(data.newMonsterLevel)
        data.newBuildLevel = math.floor(data.newBuildLevel)
    else
        return
    end
    --巢穴等级
    local netLevel
    local buildings = Model.Buildings
    if not buildings then
        return
    else
        for k, v in pairs(buildings) do
            if v.ConfId == Global.BuildingGodzilla then
                netLevel = v.Level
            end
        end
    end
    if data.newBuildLevel ~= netLevel then
        return
    end
    for k,v in pairs(GodzillaUpgradeData) do
        if data.newBuildLevel == v.needBuildLevel then
            PopupWindowQueue:Push("MonsterNetUpgradePopup", v)
            --Util.SetPlayerData("GodzillaUpgradingMark", nil)
            break
        end
    end
end

function BuildModel.CheckKingkongUpgradingPopup()
    if not KingkongUpgradeData then
        BuildModel.InitMonsterUpgradeData()
    end
    local json = Util.GetPlayerData("KingkangUpgradingMark")
    local data = {}
    if json ~= "" then
        data = JSON.decode(json)
        data.newMonsterLevel = math.floor(data.newMonsterLevel)
        data.newBuildLevel = math.floor(data.newBuildLevel)
    else
        return
    end
    --巢穴等级
    local netLevel
    local buildings = Model.Buildings
    if not buildings then
        return
    else
        for k, v in pairs(buildings) do
            if v.ConfId == Global.BuildingGodzilla then
                netLevel = v.Level
                break
            end
        end
    end
    if data.newBuildLevel ~= netLevel then
        return
    end
    for k,v in pairs(KingkongUpgradeData) do
        if data.newBuildLevel == v.needBuildLevel then
            PopupWindowQueue:Push("MonsterNetUpgradePopup", v)
            --Util.SetPlayerData("KingkangUpgradingMark", nil)
            break
        end
    end
end

function BuildModel.CheckMonsterUpgradingPopup()
    BuildModel.CheckGodzillaUpgradingPopup()
    BuildModel.CheckKingkongUpgradingPopup()
end

-------------------------------------------------补给
local militarySuppliesResList = {_G.RES_TYPE.Wood, _G.RES_TYPE.Food, _G.RES_TYPE.Iron, _G.RES_TYPE.Stone} --补给资源类型
--已经补给的次数
function BuildModel.GetMilitarySuppliesTotalTimes()
    local totalTimes = 0
    local msInfos = Model.GetMap(_G.ModelType.MSInfos)
    for i, v in ipairs(militarySuppliesResList) do
        totalTimes = totalTimes + (msInfos.MSItems[v] and msInfos.MSItems[v].TotalTimes or 0)
    end
    return totalTimes
end
--剩余可增加次数
function BuildModel.GetMilitarySuppliesCanAddTime()
    local msInfos = Model.GetMap(_G.ModelType.MSInfos)
    local FreeTimes = msInfos.FreeTimes
    local totalTimes = BuildModel.GetMilitarySuppliesTotalTimes()

    return _G.MILITARY_SUPPLY.MilitarySupplyLimit - FreeTimes - totalTimes
end

function BuildModel.GetBuildIconSmall(confId)
    local conf = BuildModel.GetConf(confId)
    return conf and conf.building_icon_small or nil
end

--判断建筑是否解锁
function BuildModel.GetBuildLock(confId)
    local building = BuildModel.FindByConfId(confId)
    if not building then
        return
    end
    local itemBuild = BuildModel.GetObject(building.Id)
    if not itemBuild then
        return
    end
    return itemBuild._itemLock
end

--建筑队列是否空闲
function BuildModel.GetBuildQueueIdle()
    local freeQueue = Model.Builders[BuildType.QUEUE.Free]
    if not freeQueue.IsWorking then
        return true
    end
    local chargeQueue = Model.Builders[BuildType.QUEUE.Charge]
    return not chargeQueue.IsWorking and chargeQueue.ExpireAt > Tool.Time()
end

return BuildModel
