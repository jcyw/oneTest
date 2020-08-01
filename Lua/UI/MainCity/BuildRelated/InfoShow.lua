--[[
    Author: songzeming
    Function: 信息显示
]]
local InfoShow = {}

local BuffModel = import("Model/BuffModel")
local CommonModel = import("Model/CommonModel")
local TrainModel = import("Model/TrainModel")

-----------------------------------------------------升级相关属性显示
--[升级]资源建筑 显示每小时产量、容量
function InfoShow.UpgradeBuildRes(node, confId, level)
    node.visible = true
    node.numItems = 2
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = level == 0 and {produce = 0, storage = 0} or ConfigMgr.GetItem("configResBuilds", confId + level)
    local v2 = ConfigMgr.GetItem("configResBuilds", confId + level + 1)
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --每小时产量
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Single_Production")
            base = math.ceil(v1.produce)
            add = " + " .. Tool.FormatNumberThousands(math.ceil(v2.produce) - base)
        elseif i == 2 then
            --容量
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_FACTORY_CAPACITY")
            base = v1.storage
            add = " + " .. Tool.FormatNumberThousands(v2.storage - base)
        end
        item:Init(title, base, add)
    end
end

--[升级]城墙
function InfoShow.UpgradeBuildWall(node, confId, level)
    node.visible = true
    node.numItems = 2
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = level == 0 and {defense_limit = 0, durable = 0} or ConfigMgr.GetItem("configWalls", confId + level)
    local v2 = ConfigMgr.GetItem("configWalls", confId + level + 1)
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --安保武器容量
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Weapons")
            base = v1.defense_limit
            add = " + " .. Tool.FormatNumberThousands(v2.defense_limit - base)
        elseif i == 2 then
            --防御值
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Defense")
            base = v1.durable
            add = " + " .. Tool.FormatNumberThousands(v2.durable - base)
        end
        item:Init(title, base, add)
    end
end

--[升级]行军帐篷/营房
function InfoShow.UpgradeBuildMarchTent(node, confId, level)
    node.visible = true
    node.numItems = 2
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = level == 0 and {train_speed = 0, train_max = 0} or ConfigMgr.GetItem("configMarchTents", confId + level)
    local v2 = ConfigMgr.GetItem("configMarchTents", confId + level + 1)
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --训练速度
            title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Army_Training_Speed")
            base = math.floor(v1.train_speed * 100) .. "%"
            add = " + " .. math.floor((v2.train_speed - v1.train_speed) * 100 + 0.5) .. "%"
        elseif i == 2 then
            --单次训练数量
            title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Army_Training_number")
            base = v1.train_max
            add = " + " .. Tool.FormatNumberThousands(v2.train_max - base)
        end
        item:Init(title, base, add)
    end
end

--[升级]战区医院
function InfoShow.UpgradeBuildHospital(node, confId, level)
    node.visible = true
    node.numItems = 1
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = level == 0 and {limit = 0} or ConfigMgr.GetItem("configHospitals", confId + level)
    local v2 = ConfigMgr.GetItem("configHospitals", confId + level + 1)
    --伤员容量
    local title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Hospital_Capacity")
    local base = v1.limit
    local add = " + " .. Tool.FormatNumberThousands(v2.limit - base)
    node:GetChildAt(0):Init(title, base, add)
end

--[升级]仓库
function InfoShow.UpgradeBuildVault(node, confId, level)
    node.visible = true
    node.numItems = 4
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1
    if level == 0 then
        v1 = {
            safe_res = {
                {category = 1, amount = 0},
                {category = 4, amount = 0},
                {category = 3, amount = 0},
                {category = 2, amount = 0}
            }
        }
    else
        v1 = ConfigMgr.GetItem("configVaults", confId + level)
    end
    local v2 = ConfigMgr.GetItem("configVaults", confId + level + 1)
    local function GetResAmount(arr, category)
        for _, v in pairs(arr.safe_res) do
            if category == v.category then
                return v.amount
            end
        end
    end
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --钢铁
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_1")
            base = GetResAmount(v1, Global.ResWood)
            add = " + " .. Tool.FormatNumberThousands(GetResAmount(v2, Global.ResWood) - base)
        elseif i == 2 then
            --食品
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_4")
            base = GetResAmount(v1, Global.ResFood)
            add = " + " .. Tool.FormatNumberThousands(GetResAmount(v2, Global.ResFood) - base)
        elseif i == 3 then
            --石油
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_3")
            base = GetResAmount(v1, Global.ResIron)
            add = " + " .. Tool.FormatNumberThousands(GetResAmount(v2, Global.ResIron) - base)
        elseif i == 4 then
            --稀土
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_2")
            base = GetResAmount(v1, Global.ResStone)
            add = " + " .. Tool.FormatNumberThousands(GetResAmount(v2, Global.ResStone) - base)
        end
        item:Init(title, base, add)
    end
end

--[升级]作战指挥部
function InfoShow.UpgradeBuildDillGround(node, confId, level)
    node.visible = true
    node.numItems = 1
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = level == 0 and {limit = 0} or ConfigMgr.GetItem("configDillGrounds", confId + level)
    local v2 = ConfigMgr.GetItem("configDillGrounds", confId + level + 1)
    --出征上限
    local title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Army_Numb")
    local base = v1.limit
    local add = " + " .. Tool.FormatNumberThousands(v2.limit - base)
    node:GetChildAt(0):Init(title, base, add)
end

--[升级]联合指挥部
function InfoShow.UpgradeBuildJointCommand(node, confId, level)
    node.visible = true
    node.numItems = 1
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = level == 0 and {mass_limit = 0} or ConfigMgr.GetItem("configJointCommands", confId + level)
    local v2 = ConfigMgr.GetItem("configJointCommands", confId + level + 1)
    --集结成员数目
    local title = StringUtil.GetI18n(I18nType.Commmon, "Ui_AssemblyArmy_Numb")
    local base = v1.mass_limit
    local add = " + " .. Tool.FormatNumberThousands(v2.mass_limit - base)
    node:GetChildAt(0):Init(title, base, add)
end

--[升级]联盟大厦
function InfoShow.UpgradeBuildUnion(node, confId, level)
    node.visible = true
    node.numItems = 3
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = level == 0 and {help_time = 0, help_num = 0, help_limit = 0} or ConfigMgr.GetItem("configUnionBuildings", confId + level)
    local v2 = ConfigMgr.GetItem("configUnionBuildings", confId + level + 1)
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --帮助次数
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_HelpTimes")
            base = v1.help_num
            add = " + " .. Tool.FormatNumberThousands(v2.help_num - base)
        elseif i == 2 then
            --帮助减少时间
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_HelpTime")
            base = v1.help_time
            add = " + " .. Tool.FormatNumberThousands(v2.help_time - base)
        elseif i == 3 then
            --援军容纳上限
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_HelpArmy")
            base = v1.help_limit
            add = " + " .. Tool.FormatNumberThousands(v2.help_limit - base)
        end
        item:Init(title, base, add)
    end
end

--[升级]物流中转站
function InfoShow.UpgradeBuildTransferStation(node, confId, level)
    node.visible = true
    node.numItems = 2
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = level == 0 and {res_support = 0, tax = 0} or ConfigMgr.GetItem("configTransferStations", confId + level)
    local v2 = ConfigMgr.GetItem("configTransferStations", confId + level + 1)
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --援助上限
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Resource")
            base = v1.res_support
            add = " + " .. Tool.FormatNumberThousands(v2.res_support - base)
        elseif i == 2 then
            --税率
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Tax")
            base = math.floor(v1.tax * 100) .. "%"
            add = " - " .. math.floor((v1.tax - v2.tax) * 100) .. "%"
        end
        item:Init(title, base, add)
    end
end

--[升级]军需站
function InfoShow.UpgradeBuildMilitarySupply(node, confId, level)
    node.visible = true
    node.numItems = 5
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1
    if level == 0 then
        v1 = {
            free_times = 0,
            res = {
                {category = 1, amount = 0},
                {category = 4, amount = 0},
                {category = 3, amount = 0},
                {category = 2, amount = 0}
            }
        }
    else
        v1 = ConfigMgr.GetItem("configMilitarySupplys", confId + level)
    end
    local v2 = ConfigMgr.GetItem("configMilitarySupplys", confId + level + 1)
    local function GetResAmount(arr, category)
        for _, v in pairs(arr.res) do
            if category == v.category then
                return v.amount
            end
        end
    end
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --免费次数
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Supply")
            base = v1.free_times
            add = " + " .. Tool.FormatNumberThousands(v2.free_times - base)
        elseif i == 2 then
            --钢铁
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_1")
            base = GetResAmount(v1, Global.ResWood)
            add = " + " .. Tool.FormatNumberThousands(GetResAmount(v2, Global.ResWood) - base)
        elseif i == 3 then
            --食品
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_4")
            base = GetResAmount(v1, Global.ResFood)
            add = " + " .. Tool.FormatNumberThousands(GetResAmount(v2, Global.ResFood) - base)
        elseif i == 4 then
            --石油
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_3")
            base = GetResAmount(v1, Global.ResIron)
            add = " + " .. Tool.FormatNumberThousands(GetResAmount(v2, Global.ResIron) - base)
        elseif i == 5 then
            --稀土
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_2")
            base = GetResAmount(v1, Global.ResStone)
            add = " + " .. Tool.FormatNumberThousands(GetResAmount(v2, Global.ResStone) - base)
        end
        item:Init(title, base, add)
    end
end

--[升级]指挥中心
function InfoShow.UpgradeBuildBase(node, confId, level)
    node.visible = true
    node.numItems = 2
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = level == 0 and {collect_speed_iron = 0, collect_speed_food = 0} or ConfigMgr.GetItem("configBases", confId + level)
    local v2 = ConfigMgr.GetItem("configBases", confId + level + 1)
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --钢铁
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_1")
            base = v1.collect_speed_iron
            add = " + " .. Tool.FormatNumberThousands(v2.collect_speed_iron - base)
        elseif i == 2 then
            --食品
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_4")
            base = v1.collect_speed_food
            add = " + " .. Tool.FormatNumberThousands(v2.collect_speed_food - base)
        end
        item:Init(title, base, add)
    end
end

--[升级]巨兽医院
function InfoShow.UpgradeBuildBeastHospital(node, confId, level)
    node.visible = true
    node.numItems = 1
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = level == 0 and {beast_cure = 0} or ConfigMgr.GetItem("configBeastHospitals", confId + level)
    local v2 = ConfigMgr.GetItem("configBeastHospitals", confId + level + 1)
    --治疗血量/小时
    local title = StringUtil.GetI18n(I18nType.Commmon, "UI_TREAT_BEAST")
    local base = v1.beast_cure
    local add = " + " .. Tool.FormatNumberThousands(v2.beast_cure - base)
    node:GetChildAt(0):Init(title, base, add)
end

--[升级]装备制造工厂
function InfoShow.UpgradeBuildEquipFactory(node, confId, level)
    node.visible = true
    node.numItems = 2
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = level == 0 and {equip_speed = 0, resource_cost = 0} or ConfigMgr.GetItem("configEquipFactorys", confId + level)
    local v2 = ConfigMgr.GetItem("configEquipFactorys", confId + level + 1)
    
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --制造速度
            title = StringUtil.GetI18n(I18nType.Commmon, "equip_building_1")
            base = v1.equip_speed .. "%"
            add = " + " .. (v2.equip_speed - v1.equip_speed) .. "%"
        elseif i == 2 then
            --消耗减少
            title = StringUtil.GetI18n(I18nType.Commmon, "equip_building_2")
            base = v1.resource_cost .. "%"
            add = " + " .. (v2.resource_cost - v1.resource_cost) .. "%"
        end
        item:Init(title, base, add)
    end
end

-----------------------------------------------------详情相关属性显示
--[详情]指挥中心
function InfoShow.DetailBuildBase(node)
    local arr = {}
    for _, v in pairs(ConfigMgr.GetList("configBaseShows")) do
        if Model.Player.Level >= v.level then
            table.insert(arr, v)
        end
    end
    table.sort(
        arr,
        function(a, b)
            return a.order < b.order
        end
    )

    node.numItems = #arr
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    for i = 1, node.numChildren do
        node:GetChildAt(i - 1):Init(i, arr[i])
    end
end
--[详情]训练工厂/安保工厂
function InfoShow.DetailTrainRes(node, confId, level)
    node.numItems = 1
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local buildConf = ConfigMgr.GetItem("configBuildings", confId)
    local armyConf = buildConf.army
    local armyId = armyConf.base_level
    local unlockLevel = level
    if level == buildConf.max_level then
        --最高等级
        armyId = armyId + armyConf.amount - 1
    else
        for i = 1, armyConf.amount do
            local lv = armyConf.base_level + i - 1
            local conf = TrainModel.GetConf(lv)
            if confId + level < conf.building then
                armyId = lv
                unlockLevel = conf.building - math.floor(conf.building / 100) * 100
                break
            end
        end
    end
    local values = {
        army_name = TrainModel.GetName(armyId),
        building_level = unlockLevel
    }
    local title = StringUtil.GetI18n(I18nType.Commmon, "Building_Lock_Army", values)
    node:GetChildAt(0):Init(1, title, "", "")
end
--[详情]资源建筑 显示每小时产量、容量
function InfoShow.DetailBuildRes(node, building)
    node.numItems = 2
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = ConfigMgr.GetItem("configResBuilds", building.ConfId + building.Level)
    local parameter = CommonModel.GetResParameter(building.ConfId)
    local isIncrease = Model.ResBuilds[building.Id].BuffExpireAt > Tool.Time()
    local buff = math.floor(v1.produce * (BuffModel.GetResProduce(parameter.category) - 1) + 0.5)
    local addProduce = isIncrease and math.ceil(v1.produce) + buff * 2 or buff
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --每小时产量+Buff加成值
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Single_Production")
            base = math.ceil(v1.produce)
            add = addProduce >= 0 and ("+%s"):format(Tool.FormatNumberThousands(addProduce)) or ("%s"):format(Tool.FormatNumberThousands(addProduce))
        elseif i == 2 then
            --容量+Buff加成值*10
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_FACTORY_CAPACITY")
            base = v1.storage
            add = addProduce * 10 >= 0 and ("+%s"):format(Tool.FormatNumberThousands(addProduce * 10)) or ("%s"):format(Tool.FormatNumberThousands(addProduce * 10))
        end
        item:Init(i, title, base, add)
        if i == 2 then
            item:SetBtnDetailActive(true, StringUtil.GetI18n(I18nType.Commmon, "UI_FACTORY_DESC"))
        end
    end
end

--[详情]城墙
function InfoShow.DetailBuildWall(node, confId, level)
    node.numItems = 2
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = ConfigMgr.GetItem("configWalls", confId + level)
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --安保武器容量
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Weapons")
            base = v1.defense_limit
            add = " + " .. Tool.FormatNumberThousands(BuffModel.GetTrapLimit())
        elseif i == 2 then
            --防御值
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Defense")
            base = v1.durable
            add = " + " .. Tool.FormatNumberThousands(BuffModel.GetWallDefenseValue())
        end
        item:Init(i, title, base, add)
    end
end

--[详情]行军帐篷/营房
function InfoShow.DetailBuildMarchTent(node, confId)
    node.numItems = 2
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local totalTrainSpeed, totalTrainMax = 0, 0
    for _, v in pairs(Model.Buildings) do
        if v.ConfId == confId and v.Level > 0 then
            local conf = ConfigMgr.GetItem("configMarchTents", v.ConfId + v.Level)
            totalTrainSpeed = totalTrainSpeed + conf.train_speed * 100
            totalTrainMax = totalTrainMax + conf.train_max
        end
    end
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --训练速度
            title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Army_Training_Speed")
            base = math.floor(totalTrainSpeed) .. "%%"
            add = " + " .. math.floor((BuffModel.GetTrainSpeed() - 1)) .. "%%"
        elseif i == 2 then
            --单次训练数量
            title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Army_Training_number")
            base = totalTrainMax
            add = " + " .. Tool.FormatNumberThousands(BuffModel.GetArmyAmount())
        end
        item:Init(i, title, base, add)
        if i == 2 then
            item:SetBtnDetailActive(true, StringUtil.GetI18n(I18nType.Commmon, "UI_BARRACKS_DESC"))
        end
    end
end

--[详情]战区医院
function InfoShow.DetailBuildHospital(node, confId, level)
    node.numItems = 2
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local totalInjuredAmount = Global.HospitalBaseLimit
    for _, v in pairs(Model.Buildings) do
        if v.ConfId == confId and v.Level > 0 then
            local conf = ConfigMgr.GetItem("configHospitals", v.ConfId + v.Level)
            totalInjuredAmount = totalInjuredAmount + conf.limit
        end
    end
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --伤员容量
            local v1 = ConfigMgr.GetItem("configHospitals", confId + level)
            title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Hospital_Capacity")
            base = v1.limit
            add = " + " .. Tool.FormatNumberThousands(math.ceil((base + BuffModel.GetCureArmyLimit()) * BuffModel.GetCureArmyLimitPerc()) - base)
        elseif i == 2 then
            --伤员总容量
            title = StringUtil.GetI18n(I18nType.Commmon, "Ui_ALLHospital_Capacity")
            base = totalInjuredAmount
            add = " + " .. Tool.FormatNumberThousands(math.ceil((base + BuffModel.GetCureArmyLimit()) * BuffModel.GetCureArmyLimitPerc()) - base)
        end
        item:Init(i, title, base, add)
        if i == 2 then
            item:SetBtnDetailActive(true, StringUtil.GetI18n(I18nType.Commmon, "Ui_HOSPITAL_DESC"))
        end
    end
end

--[详情]仓库
function InfoShow.DetailBuildVault(node, confId, level)
    node.numItems = 4
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1
    if level == 0 then
        v1 = {
            safe_res = {
                {category = 1, amount = 0},
                {category = 4, amount = 0},
                {category = 3, amount = 0},
                {category = 2, amount = 0}
            }
        }
    else
        v1 = ConfigMgr.GetItem("configVaults", confId + level)
    end
    local function GetResAmount(arr, category)
        for _, v in pairs(arr.safe_res) do
            if category == v.category then
                return v.amount
            end
        end
    end
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --钢铁
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_1")
            base = GetResAmount(v1, Global.ResWood)
            local value = math.ceil(BuffModel.GetWarehouseCapacity(base))
            add = value < 0 and Tool.FormatNumberThousands(value) or  ("+%s"):format(Tool.FormatNumberThousands(value))
        elseif i == 2 then
            --食品
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_4")
            base = GetResAmount(v1, Global.ResFood)
            local value = math.ceil(BuffModel.GetWarehouseCapacity(base))
            add = value < 0 and Tool.FormatNumberThousands(value) or  ("+%s"):format(Tool.FormatNumberThousands(value))
        elseif i == 3 then
            --石油
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_3")
            base = GetResAmount(v1, Global.ResIron)
            local value = math.ceil(BuffModel.GetWarehouseCapacity(base))
            add = value < 0 and Tool.FormatNumberThousands(value) or  ("+%s"):format(Tool.FormatNumberThousands(value))
        elseif i == 4 then
            --稀土
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_2")
            base = GetResAmount(v1, Global.ResStone)
            local value = math.ceil(BuffModel.GetWarehouseCapacity(base))
            add = value < 0 and Tool.FormatNumberThousands(value) or  ("+%s"):format(Tool.FormatNumberThousands(value))
        end
        item:Init(i, title, base, add)
    end
end

--[详情]作战指挥部
function InfoShow.DetailBuildDillGround(node, confId, level)
    node.numItems = 1
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = ConfigMgr.GetItem("configDillGrounds", confId + level)
    --集结成员数目
    local title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Army_Numb")
    local base = v1.limit
    local add = " + " .. Tool.FormatNumberThousands(((v1.limit + BuffModel.GetExpeditionAmount()) * BuffModel.GetExpeditionAmountPerc() - v1.limit))
    node:GetChildAt(0):Init(1, title, base, add)
end

--[详情]联合指挥部
function InfoShow.DetailBuildJointCommand(node, confId, level)
    node.numItems = 1
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = ConfigMgr.GetItem("configJointCommands", confId + level)
    --集结成员数目
    local title = StringUtil.GetI18n(I18nType.Commmon, "Ui_AssemblyArmy_Numb")
    local base = v1.mass_limit
    local add = " + " .. Tool.FormatNumberThousands(BuffModel.GetAssemblyLimit())
    node:GetChildAt(0):Init(1, title, base, add)
end

--[详情]联盟大厦
function InfoShow.DetailBuildUnion(node, confId, level)
    node.numItems = 3
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = ConfigMgr.GetItem("configUnionBuildings", confId + level)
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base, add
        if i == 1 then
            --帮助次数
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_HelpTimes")
            base = v1.help_num
            add = " + " .. Tool.FormatNumberThousands(BuffModel.GetUnionHelpTimes())
        elseif i == 2 then
            --帮助减少时间
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_HelpTime")
            base = v1.help_time
            add = " + " .. Tool.FormatNumberThousands(BuffModel.GetUnionHelpTime())
        elseif i == 3 then
            --援军容纳上限
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_HelpArmy")
            base = v1.help_limit
            add = " + " .. Tool.FormatNumberThousands(BuffModel.GetUnionReinforcementLimit())
        end
        item:Init(i, title, base, add)
    end
end

--[详情]物流中转站
function InfoShow.DetailBuildTransferStation(node, confId, level)
    node.numItems = 2
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = ConfigMgr.GetItem("configTransferStations", confId + level)
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base
        if i == 1 then
            --援助资源上限
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Resource")
            base = v1.res_support
        elseif i == 2 then
            --税率
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Tax")
            base = math.floor(v1.tax * 100) .. "%%"
        end
        item:Init(i, title, base, "")
    end
end

--[详情]军需站
function InfoShow.DetailBuildMilitarySupply(node, confId, level)
    node.numItems = 5
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1
    if level == 0 then
        v1 = {
            free_times = 0,
            res = {
                {category = 1, amount = 0},
                {category = 4, amount = 0},
                {category = 3, amount = 0},
                {category = 2, amount = 0}
            }
        }
    else
        v1 = ConfigMgr.GetItem("configMilitarySupplys", confId + level)
    end
    local function GetResAmount(arr, category)
        for _, v in pairs(arr.res) do
            if category == v.category then
                return v.amount
            end
        end
    end
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base
        if i == 1 then
            --免费次数
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Supply")
            base = v1.free_times
        elseif i == 2 then
            --钢铁
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_1")
            base = GetResAmount(v1, Global.ResWood)
        elseif i == 3 then
            --食品
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_4")
            base = GetResAmount(v1, Global.ResFood)
        elseif i == 4 then
            --石油
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_3")
            base = GetResAmount(v1, Global.ResIron)
        elseif i == 5 then
            --稀土
            title = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_2")
            base = GetResAmount(v1, Global.ResStone)
        end
        item:Init(i, title, base, "")
    end
end

--[详情]巨兽医院
function InfoShow.DetailBuildBeastHospital(node, confId, level)
    node.numItems = 1
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = ConfigMgr.GetItem("configBeastHospitals", confId + level)
    --治疗血量/小时
    local title = StringUtil.GetI18n(I18nType.Commmon, "UI_TREAT_BEAST")
    local base = v1.beast_cure
    local add = "" --TODO 有Buff
    node:GetChildAt(0):Init(1, title, base, add)
end

--[详情]装备制造厂
function InfoShow.DetailBuildEquipFactory(node, confId, level)
    node.numItems = 2
    node:EnsureBoundsCorrect()
    node.scrollPane.touchEffect = node.scrollPane.contentHeight > node.height

    local v1 = ConfigMgr.GetItem("configEquipFactorys", confId + level)
    for i = 1, node.numChildren do
        local item = node:GetChildAt(i - 1)
        local title, base
        if i == 1 then
            --装备生产速度
            title = StringUtil.GetI18n(I18nType.Commmon, "equip_building_1")
            base = v1.equip_speed.."%%"
        elseif i == 2 then
            --芯片消耗减少
            title = StringUtil.GetI18n(I18nType.Commmon, "equip_building_2")
            base = v1.resource_cost.."%%"
        end
        item:Init(i, title, base, "")
    end
end

return InfoShow
