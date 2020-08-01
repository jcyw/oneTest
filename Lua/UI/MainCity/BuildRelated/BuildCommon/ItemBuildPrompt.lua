--[[
    Author: songzeming
    Function:
]]
local ItemBuildPrompt = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/ItemBuildPrompt", ItemBuildPrompt)

local CommonModel = import("Model/CommonModel")
local TrainModel = import("Model/TrainModel")
local InfoShow = import("UI/MainCity/BuildRelated/InfoShow")
import("UI/MainCity/BuildRelated/BuildCommon/ItemBuildPromptImage")

local normalListSize = 180
local NestListSize = 260

function ItemBuildPrompt:ctor()
    self._ctr = self:GetController("Ctr")

    self:AddListener(self._listImage.scrollPane.onScroll,
        function()
            self:RefreshImageList()
        end
    )
    self:AddListener(self._listImage.scrollPane.onScrollEnd,
        function()
            self:RefreshImageList()
        end
    )
    self:AddListener(self._btnL.onClick,function()
        self._listImage.scrollPane:SetCurrentPageX(self._listImage.scrollPane.currentPageX - 1, true)
    end)
    self:AddListener(self._btnR.onClick,function()
        self._listImage.scrollPane:SetCurrentPageX(self._listImage.scrollPane.currentPageX + 1, true)
    end)
end

function ItemBuildPrompt:InitUpgrade(confId, level, pos)
    self.confId = confId
    self.level = level
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_BUILD_NEXT_LEVEL", {num = level + 1})

    self._listImage.width = normalListSize
    self._listImage.height = normalListSize

    self._ctr.selectedIndex = 1
    if CommonModel.IsAllTrainFactoryOrNest(confId) then
        self._ctr.selectedIndex = 0
        -- 军队建筑
        self.unlockInfo = {}
        local indexArr = {}
        local arm = TrainModel.GetArm(confId)
        local baseId = arm.base_level
        for k = 1, arm.amount do
            local armId = baseId + k - 1
            local buildLv = TrainModel.GetLevelById(armId)
            if self.level < buildLv then
                table.insert(self.unlockInfo, buildLv)
                indexArr[buildLv] = k
            end
        end
        
        local curSize = normalListSize
        if BuildModel.IsNestBuilding(pos) then
            curSize = NestListSize
        end
        self._listImage.width = curSize
        self._listImage.height = curSize

        self._listImage.numItems = #self.unlockInfo
        for k, v in ipairs(self.unlockInfo) do
            local item = self._listImage:GetChildAt(k - 1)
            item.width = curSize
            item.height = curSize
            local id = baseId + indexArr[v] - 1
            item:InitArmy(confId, id)
        end
        self:ResetImageList()
        self.pageX = nil
        self:RefreshImageList()
    elseif CommonModel.IsResBuild(confId) then
        -- 资源建筑
        InfoShow.UpgradeBuildRes(self._listText, confId, self.level)
    elseif confId == Global.BuildingScience then
        --研究中心
        self._ctr.selectedIndex = 0
        self._desc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_NEXT_LEVEL_UNLOCKED")
        if not self.arrTechUnlock then
            --科技建筑等级可解锁科技
            self.arrTechUnlock = {}
            for _, v in pairs(ConfigMgr.GetList("configTechs")) do
                local lv = v.building_condition[1].level
                if not self.arrTechUnlock[lv] then
                    self.arrTechUnlock[lv] = {}
                end
                table.insert(self.arrTechUnlock[lv], v.id)
            end
        end
        local info = self.arrTechUnlock[self.level + 1]
        --去除相同科技不同等级 只保留一个
        local diffArr = {}
        for _, id in pairs(info) do
            local preid = math.floor(id / 100)
            if not diffArr[preid] then
                diffArr[preid] = id
            end
        end
        self._listImage:RemoveChildrenToPool()
        for k, _ in pairs(diffArr) do
            local item = self._listImage:AddItemFromPool()
            item.width = normalListSize
            item.height = normalListSize
            local id = k * 100
            item:InitScience(confId, id)
        end
        self:ResetImageList()
    elseif confId == Global.BuildingCenter then
        --指挥中心
        InfoShow.UpgradeBuildBase(self._listText, confId, self.level)
    elseif confId == Global.BuildingWall then
        --城墙
        InfoShow.UpgradeBuildWall(self._listText, confId, self.level)
    elseif confId == Global.BuildingMarchTent then
        --行军帐篷/营房
        InfoShow.UpgradeBuildMarchTent(self._listText, confId, self.level)
    elseif confId == Global.BuildingHospital then
        --战区医院
        InfoShow.UpgradeBuildHospital(self._listText, confId, self.level)
    elseif confId == Global.BuildingVault then
        --仓库
        InfoShow.UpgradeBuildVault(self._listText, confId, self.level)
    elseif confId == Global.BuildingDillGround then
        --作战指挥部
        InfoShow.UpgradeBuildDillGround(self._listText, confId, self.level)
    elseif confId == Global.BuildingJointCommand then
        --联合指挥部
        InfoShow.UpgradeBuildJointCommand(self._listText, confId, self.level)
    elseif confId == Global.BuildingUnionBuilding then
        --联盟大厦
        InfoShow.UpgradeBuildUnion(self._listText, confId, self.level)
    elseif confId == Global.BuildingTransferStation then
        --物流中转站
        InfoShow.UpgradeBuildTransferStation(self._listText, confId, self.level)
    elseif confId == Global.BuildingMilitarySupply then
        --军需站
        InfoShow.UpgradeBuildMilitarySupply(self._listText, confId, self.level)
    elseif confId == Global.BuildingRadar then
        --雷达
        self._ctr.selectedIndex = 2
        local conf = ConfigMgr.GetItem("configRadars", confId + self.level + 1)
        if not conf.Radar_Effect then
            self._info.text = ""
        else
            self._info.text = StringUtil.GetI18n(I18nType.Commmon, conf.Radar_Effect)
        end
    elseif confId == Global.BuildingBeastBase then
        --巨兽基地
        self._ctr.selectedIndex = 2
        self._info.text = StringUtil.GetI18n(I18nType.Building, Global.BuildingBeastBase .. "_DESC")
    elseif confId == Global.BuildingBeastHospital then
        --巨兽医院
        InfoShow.UpgradeBuildBeastHospital(self._listText, confId, self.level)
    elseif confId == Global.BuildingBeastScience then
        --巨兽研究院
        self._ctr.selectedIndex = 0
        self._desc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_NEXT_LEVEL_UNLOCKED")
        if not self.arrBeastTechUnlock then
            --科技建筑等级可解锁科技
            self.arrBeastTechUnlock = {}
            for _, v in pairs(ConfigMgr.GetList("configBeastTechs")) do
                local lv = v.building_condition[1].level
                if not self.arrBeastTechUnlock[lv] then
                    self.arrBeastTechUnlock[lv] = {}
                end
                table.insert(self.arrBeastTechUnlock[lv], v.id)
            end
        end
        local info = self.arrBeastTechUnlock[self.level + 1]
        --去除相同科技不同等级 只保留一个
        local diffArr = {}
        if info then
            for _, id in pairs(info) do
                local preid = math.floor(id / 100)
                if not diffArr[preid] then
                    diffArr[preid] = id
                end
            end
        end
        self._listImage:RemoveChildrenToPool()
        for k, _ in pairs(diffArr) do
            local item = self._listImage:AddItemFromPool()
            item.width = normalListSize
            item.height = normalListSize
            local id = k * 100
            item:InitMonsterScience(confId, id)
        end
        self:ResetImageList()
    elseif confId == Global.BuildingEquipFactory then
        InfoShow.UpgradeBuildEquipFactory(self._listText, confId, self.level)
    end
end

function ItemBuildPrompt:ResetImageList()
    self._listImage.scrollPane.currentPageX = 0
end
function ItemBuildPrompt:RefreshImageList()
    if self.pageX == self._listImage.scrollPane.currentPageX then
        return
    end
    self.pageX = self._listImage.scrollPane.currentPageX

    if CommonModel.IsAllTrainFactoryOrNest(self.confId) then
        --训练(造兵工厂/安保工厂)
        local values = {
            building_name = BuildModel.GetName(self.confId),
            building_level = self.unlockInfo[self.pageX + 1]
        }
        --self._desc.text = StringUtil.GetI18n(I18nType.Commmon, "Building_Lock_Base_Level", values)
        self._desc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_BUILDING_LOCK_LEVEL", {building_level = values.building_level})
    end
end

return ItemBuildPrompt
