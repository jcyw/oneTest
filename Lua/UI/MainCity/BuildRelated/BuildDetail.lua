--[[
    Author: songzeming
    Function: 建筑详情 通用
]]
local BuildDetail = UIMgr:NewUI("BuildRelated/BuildDetail")

local BuildModel = import("Model/BuildModel")
local DetailModel = import("Model/DetailModel")
local CommonModel = import("Model/CommonModel")
local EventModel = import("Model/EventModel")
local TrainModel = import("Model/TrainModel")
local InfoShow = import("UI/MainCity/BuildRelated/InfoShow")
local TechModel = import("Model/TechModel")
import("UI/MainCity/BuildRelated/ItemDetailBar")
import("UI/MainCity/BuildRelated/ItemDetailCenterList")
import("UI/MainCity/BuildRelated/ItemDetailInfoList")
import("UI/MainCity/BuildRelated/BuildCommon/ItemBuildInfo")
import("UI/Common/ItemPressPrompt")
local CTR = {
    Normal = "Normal",
    Single = "Single",
    SingleCD = "SingleCD",
    Double = "Double",
    DoubleCD = "DoubleCD",
    Share = "Share",
    DoubleShare = "DoubleShare"
}
local CTR_TAG = {
    Normal = "Normal",
    Special = "Special",
    Detail = "Detail"
}

local _pressPrompt = nil
local pressPromptTrue = function()
    if _pressPrompt then
        _pressPrompt:SetVisible(true)
    end
end

local pressPromptFalse = function()
    if _pressPrompt then
        _pressPrompt:SetVisible(false)
    end
end

function BuildDetail:OnInit()
    local view = self.Controller.contentPane
    self._ctr = view:GetController("Ctr")
    self._ctrTag = view:GetController("CtrTag")
    self._upgradeTime = self._cd:GetChild("time")

    self._listInfo = self._listDown:GetChild("liebiao")
    self:AddListener(self._btnRemove.onClick,
        function()
            if self.isEvent then
                self:OnBtnCancelClick()
            else
                self:OnBtnRemoveClick()
            end
        end
    )
    self._btnMove.title = StringUtil.GetI18n(I18nType.Commmon, "Button_Move")
    self:AddListener(self._btnMove.onClick,
        function()
            Event.Broadcast(EventDefines.UICityBuildMove, BuildType.MOVE.Move, self.building.Pos)
            self:DoClose()
        end
    )
    self._btnShare.visible = false
    self._btnShare.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_SHARE")
    self:AddListener(self._btnShare.onClick,
        function()
            TipUtil.TipById(50259)
        end
    )
    self:AddListener(self._btnReturn.onClick,
        function()
            self:DoClose()
        end
    )
    self._ctrBtnInfo = self._btnInfo:GetController("button")
    self:AddListener(self._btnInfo.onClick,
        function()
            self:OnBtnInfoClick()
        end
    )
    self._ctrBtnMore = self._btnMore:GetController("button")
    self:AddListener(self._btnMore.onClick,
        function()
            self:OnBtnMoreClick()
        end
    )

    _pressPrompt = self._pressPrompt
end

function BuildDetail:OnOpen(building)
    ScrollModel.Scale(building.Pos, true)

    self.building = building
    self.confId = self.building.ConfId
    self.Level = self.building.Level
    self.tLevel = self.Level < 1 and 1 or self.Level
    self.curConfId = self.confId + self.tLevel

    self:UpdateData()
    self:OnBtnInfoClick()
    self:TouchDescShow()
end

function BuildDetail:UpdateData()
    self.event = EventModel.GetEvent(self.building)
    self.isEvent = self.event and (type(self.event) ~= "table" or next(self.event))
    if self.isEvent then
        local category = self.event.Category
        local i18n = ""
        if category == EventType.B_BUILD then
            if self.building.Level == 0 then
                i18n = "BUTTON_Cancel_Build"
            else
                i18n = "BUTTON_Cancel_UPGRADE"
            end
        elseif category == EventType.B_DESTROY then
            i18n = "BUTTON_Cancel_Remove"
        elseif category == EventType.B_TRAIN then
            i18n = "BUTTON_Cancel_Train"
        elseif category == EventType.B_TECH or category == EventType.B_BEASTTECH then
            i18n = "BUTTON_Cancel_Tech"
        elseif category == EventType.B_CURE or category == EventType.B_BEASTCURE then
            i18n = "Button_Cancel_Treatment"
        end
        self._btnRemove.title = StringUtil.GetI18n(I18nType.Commmon, i18n)
        if self.confId == Global.BuildingCenter then
            -- self._ctr.selectedPage = CTR.DoubleShare
            self._ctr.selectedPage = CTR.SingleCD --todo 取消FB分享
        elseif self.confId == Global.BuildingEquipFactory then
            -- 装备制造中不能取消
            self._ctr.selectedPage = CTR.Single
        elseif BuildModel.GetConf(self.confId).movable == BuildType.BUILD_MOVEABLE.No then
            self._ctr.selectedPage = CTR.SingleCD
        else
            self._ctr.selectedPage = CTR.DoubleCD
        end
        self:ShowTime()
    else
        local posType = BuildModel.GetBuildPosTypeByPos(self.building.Pos)
        if posType == Global.BuildingZoneInnter then
            --城内
            if self.confId == Global.BuildingCenter then
                self._ctr.selectedPage = CTR.Share
            elseif BuildModel.GetConf(self.confId).movable == BuildType.BUILD_MOVEABLE.Yes then
                self._ctr.selectedPage = CTR.Single
            else
                self._ctr.selectedPage = CTR.Normal
            end
        elseif posType == Global.BuildingZoneWild then
            --城外
            self._ctr.selectedPage = CTR.DoubleCD
            self._btnRemove.title = StringUtil.GetI18n(I18nType.Commmon, "Button_Remove")
            local conf = ConfigMgr.GetItem("configBuildingUpgrades", self.curConfId)
            self._upgradeTime.text = Tool.FormatTime(conf.destroy_time)
        elseif posType == Global.BuildingZoneBeast then
            --巨兽
            self._ctr.selectedPage = CTR.Single
        elseif posType == Global.BuildingZoneNest then
            --巢穴
            self._ctr.selectedPage = CTR.Normal
        end
    end

    self.infoName = BuildModel.GetName(self.confId)
    local infoLevel =  StringUtil.GetI18n(I18nType.Commmon, "Ui_Level", {number = self.Level})
    self._info:Init(infoLevel, self.infoName)
    self._textDesc.text = BuildModel.GetDesc(self.confId)
    self._pressPrompt:SetArrowRight(BuildModel.GetInfo(self.confId))
end

function BuildDetail:DoClose()
    UIMgr:Close("BuildRelated/BuildDetail")
    if self.time_func then
        self:UnSchedule(self.time_func)
    end
end

function BuildDetail:OnClose()
    ScrollModel.SetScaling(false)
    self:RemoveListener(self._touchDescGesture.onBegin, pressPromptTrue)
    self:RemoveListener(self._touchDescGesture.onEnd, pressPromptFalse)
end

function BuildDetail:ShowTime()
    local function get_time()
        return self.event.FinishAt - Tool.Time()
    end
    if get_time() <= 0 then
        self:DoClose()
        return
    end
    if self.time_func then
        self:UnSchedule(self.time_func)
    end
    local bar_func = function()
        self._upgradeTime.text = Tool.FormatTime(get_time())
    end
    bar_func()
    self.time_func = function()
        if get_time() >= 0 then
            bar_func()
            return
        end
        self:DoClose()
    end
    self:Schedule(self.time_func, 1)
end

-- 移除
function BuildDetail:OnBtnRemoveClick()
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "Building_Demolish"),
        sureCallback = function()
            local conf = ConfigMgr.GetItem("configBuildingUpgrades", self.curConfId)
            if not BuildModel.CheckBuilder("Destroy", conf.destroy_time, self.infoName) then
                return
            end
            Net.Buildings.Destroy(
                self.building.Id,
                function(rsp)
                    if rsp.Event then
                        Model.Create(ModelType.UpgradeEvents, rsp.Event.Uuid, rsp.Event)
                    end
                    local node = BuildModel.GetObject(self.building.Id)
                    node:ResetCD()
                    self:DoClose()
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end
-- 取消升级/拆除
function BuildDetail:OnBtnCancelClick()
    local category = self.event.Category
    local cancel_func = function()
        Net.Events.Cancel(
            category,
            self.event.Uuid,
            function(rsp)
                local node = BuildModel.GetObject(self.building.Id)
                if category == EventType.B_BUILD then
                    local values = {
                        building_name = BuildModel.GetName(self.building.ConfId)
                    }
                    if self.building.Level == 0 then
                        TipUtil.TipById(50096, values)
                    else
                        values.building_level = self.building.Level
                        TipUtil.TipById(50097, values)
                    end
                    Model.Delete(ModelType.UpgradeEvents, self.event.Uuid)
                    node:ResetCD()
                elseif category == EventType.B_DESTROY then
                    local values = {
                        building_name = BuildModel.GetName(self.building.ConfId)
                    }
                    TipUtil.TipById(50098, values)
                    Model.Delete(ModelType.UpgradeEvents, self.event.Uuid)
                    node:ResetCD()
                elseif category == EventType.B_TRAIN then
                    local values = {
                        army_name = TrainModel.GetName(self.event.ConfId)
                    }
                    TipUtil.TipById(50099, values)
                    Model.Delete(ModelType.TrainEvents, self.event.Uuid)
                    node:ResetCD()
                    node:TrainArmyEndAnim(true)
                elseif category == EventType.B_TECH then
                    local values = {
                        tech_name = TechModel.GetTechName(self.event.TargetId)
                    }
                    TipUtil.TipById(50100, values)
                    Model.Delete(ModelType.UpgradeEvents, self.event.Uuid)
                    node:ResetCD()
                elseif category == EventType.B_CURE then
                    TipUtil.TipById(50101)
                    Model.Delete(ModelType.CureEvents, self.event.Uuid)
                    BuildModel.CheckBuildHospital()
                elseif category == EventType.B_BEASTTECH then
                    local values = {
                        tech_name = TechModel.GetTechName(self.event.TargetId)
                    }
                    TipUtil.TipById(50100, values)
                    Model.Delete(ModelType.UpgradeEvents, self.event.Uuid)
                    node:ResetCD()
                elseif category == EventType.B_BEASTCURE then
                    TipUtil.TipById(50101)
                    Model.Delete(ModelType.BeastCureEvents, self.event.Uuid)
                    node:ResetCD()
                end
                self:DoClose()
            end
        )
    end
    --移除不消耗资源不提示
    if category == EventType.B_DESTROY then
        cancel_func()
        return
    end

    local desc = ""
    if category == EventType.B_TRAIN then
        if self.confId == Global.BuildingSecurityFactory then
            desc = StringUtil.GetI18n(I18nType.Commmon, "UI__Cancel_Make")
        else
            desc = StringUtil.GetI18n(I18nType.Commmon, "Training_Army_Cancel")
        end
    elseif category == EventType.B_CURE then
        desc = StringUtil.GetI18n(I18nType.Commmon, "Cancel_Treatment")
    elseif category == EventType.B_TECH then
        desc = StringUtil.GetI18n(I18nType.Commmon, "Tech_Cancel")
    else
        local values = {
            behavior_name = self.infoName
        }
        desc = StringUtil.GetI18n(I18nType.Commmon, "Queue_Cancel", values)
    end
    local data = {
        content = desc,
        sureCallback = function()
            cancel_func()
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

------------------------------------- 列表
--点击信息
function BuildDetail:OnBtnInfoClick()
    self._ctrBtnInfo.selectedPage = "down"
    self._ctrBtnMore.selectedPage = "up"
    self:ShowDesc()
    if Tool.Equal(self.confId, Global.BuildingCenter, Global.BuildingScience, Global.BuildingRadar) then
        --指挥中心、科研中心、雷达
        self._ctrTag.selectedPage = CTR_TAG.Special
        self._textSpecialDesc.text = StringUtil.GetI18n(I18nType.Building, self.confId .. "_LEVEL_TIPS")
    elseif Tool.Equal(self.confId, Global.BuildingBeastBase) then
        --巨兽基地
        self._ctrTag.selectedPage = CTR_TAG.Special
        self._textSpecialDesc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_BEAST_BASE")
    elseif Tool.Equal(self.confId, Global.BuildingBeastScience) then
        --巨兽研究院
        self._ctrTag.selectedPage = CTR_TAG.Special
        self._textSpecialDesc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_BEAST_TECH")
    else
        --通用 有详情列表
        self._ctrTag.selectedPage = CTR_TAG.Normal
        self._textSpecialDesc.text = ""
    end
end
--点击更多信息
function BuildDetail:OnBtnMoreClick()
    self._ctrBtnInfo.selectedPage = "up"
    self._ctrBtnMore.selectedPage = "down"
    self:ListShow()
    self._ctrTag.selectedPage = CTR_TAG.Detail
end

function BuildDetail:ListShow()
    self._listInfo.numItems = 0
    self.detail = DetailModel.GetType(self.confId)
    if not self.detail then
        return
    end
    self.col = self.detail.Col
    if Tool.Equal(self.confId, Global.BuildingRadar) then --雷达文本标题显示特调
        UITool.RadarFormatListText(self._listTitle, self.col)
    else
        UITool.FormatListText(self._listTitle, self.col)
    end
    self:SetListTitle()
    self:SetListInfo()
end

function BuildDetail:ShowDesc()
    if CommonModel.IsAllTrainFactoryOrNest(self.confId) then
        -- 训练工厂、安保工厂 或者 巢穴(哥斯拉、金刚)
        InfoShow.DetailTrainRes(self._listBuildInfo, self.confId, self.building.Level)
    elseif CommonModel.IsResBuild(self.confId) then
        -- 资源建筑
        InfoShow.DetailBuildRes(self._listBuildInfo, self.building)
    elseif self.confId == Global.BuildingCenter then
        --指挥中心
        InfoShow.DetailBuildBase(self._listCenterInfo)
    elseif self.confId == Global.BuildingScience then
        --研究中心
        self._listCenterInfo.numItems = 0
    elseif self.confId == Global.BuildingWall then
        --城墙
        InfoShow.DetailBuildWall(self._listBuildInfo, self.confId, self.building.Level)
    elseif self.confId == Global.BuildingMarchTent then
        --行军帐篷/营房
        InfoShow.DetailBuildMarchTent(self._listBuildInfo, self.confId)
    elseif self.confId == Global.BuildingHospital then
        --战区医院
        InfoShow.DetailBuildHospital(self._listBuildInfo, self.confId, self.building.Level)
    elseif self.confId == Global.BuildingVault then
        --仓库
        InfoShow.DetailBuildVault(self._listBuildInfo, self.confId, self.building.Level)
    elseif self.confId == Global.BuildingDillGround then
        --作战指挥部
        InfoShow.DetailBuildDillGround(self._listBuildInfo, self.confId, self.building.Level)
    elseif self.confId == Global.BuildingJointCommand then
        --联合指挥部
        InfoShow.DetailBuildJointCommand(self._listBuildInfo, self.confId, self.building.Level)
    elseif self.confId == Global.BuildingUnionBuilding then
        --联盟大厦
        InfoShow.DetailBuildUnion(self._listBuildInfo, self.confId, self.building.Level)
    elseif self.confId == Global.BuildingTransferStation then
        --物流中转站
        InfoShow.DetailBuildTransferStation(self._listBuildInfo, self.confId, self.building.Level)
    elseif self.confId == Global.BuildingMilitarySupply then
        --军需站
        InfoShow.DetailBuildMilitarySupply(self._listBuildInfo, self.confId, self.building.Level)
    elseif self.confId == Global.BuildingRadar then
        --雷达
        self._listCenterInfo.numItems = 0
    elseif self.confId == Global.BuildingBeastBase then
        --巨兽基地
        self._listCenterInfo.numItems = 0
    elseif self.confId == Global.BuildingBeastHospital then
        --巨兽医院
        InfoShow.DetailBuildBeastHospital(self._listBuildInfo, self.confId, self.building.Level)
    elseif self.confId == Global.BuildingBeastScience then
        --巨兽研究院
        self._listCenterInfo.numItems = 0
    elseif self.confId == Global.BuildingEquipFactory then
        --装备制造工厂
        InfoShow.DetailBuildEquipFactory(self._listBuildInfo, self.confId, self.building.Level)
    end
end

-- 设置列表标题显示
function BuildDetail:SetListTitle()
    for i = 1, self.col do
        local item = self._listTitle:GetChildAt(i - 1)
        item.text = StringUtil.GetI18n(I18nType.Commmon, self.detail.Title[i])
        item.color = Color(242 / 255, 201 / 255, 82 / 255, 1)
    end
end

-- 设置列表信息显示
function BuildDetail:SetListInfo()
    local listNum = BuildModel.GetConf(self.confId).max_level
    self._listInfo.numItems = listNum
    -- 获取战斗力
    local get_power = function(lv)
        return DetailModel.GetUpConf(self.confId + lv).power
    end
    -- 当前等级特殊显示
    local cur_show = function()
        local child = self._listInfo:GetChildAt(self.tLevel - 1)
        child:SetChoose()
        CSCoroutine.Start(
            function()
                coroutine.yield(self._listInfo.numItems == listNum)
                self._listInfo.scrollPane:SetPosY(child.y)
            end
        )
    end
    -- Col4 指挥中心
    if Tool.Equal(self.confId, Global.BuildingCenter) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetCenterConf(self.confId + i)
            local collect_iron = conf.collect_speed_iron
            local collect_food = conf.collect_speed_food
            item:Init(i, collect_iron, collect_food, get_power(i))
        end
        cur_show()
        return
    end
    -- Col3 坦克工厂(步) / 战车工厂(骑) / 直升机工厂(弓) / 重型载具工厂(车) / 安保工厂  哥斯拉巢穴、金刚巢穴
    if CommonModel.IsAllTrainFactoryOrNest(self.confId) then
        local conf = ConfigMgr.GetItem("configBuildings", self.confId)
        local obj = {}
        for i = 1, conf.army.amount do
            table.insert(obj, ConfigMgr.GetItem("configArmys", conf.army.base_level + i - 1).building)
        end

        local count = 1
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local effect = ""
            if (obj[count] - math.floor(obj[count] / 100) * 100) == i then
                local values = {
                    army_name = StringUtil.GetI18n(I18nType.Army, conf.army.base_level + count - 1 .. "_NAME")
                }
                effect = StringUtil.GetI18n(I18nType.Commmon, "UI_BUILDINGS_ARMY_DETAILS", values)
                count = count + 1
            end
            item:Init(i, effect, get_power(i))
        end
        cur_show()
        return
    end
    -- Col4 稀土工厂 / 钢铁厂 / 炼制工厂 / 食品厂
    if Tool.Equal(self.confId, Global.BuildingStone, Global.BuildingWood, Global.BuildingIron, Global.BuildingFood) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetResConf(self.confId + i)
            local yield = conf.produce
            local limit = conf.storage
            item:Init(i, yield, limit, get_power(i))
        end
        cur_show()
        return
    end
    -- Col4 营房
    if Tool.Equal(self.confId, Global.BuildingMarchTent) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetMarchTentConf(self.confId + i)
            local yield = math.floor(conf.train_speed * 100)
            local limit = conf.train_max
            item:Init(i, yield, limit, get_power(i))
        end
        cur_show()
        return
    end
    -- Col6 物资仓库
    if Tool.Equal(self.confId, Global.BuildingVault) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetVaultConf(self.confId + i)
            local res = ResReset(conf.safe_res)
            item:Init(i, res.wood, res.stone, res.iron, res.food, get_power(i))
        end
        cur_show()
        return
    end
    -- Col3 战区医院
    if Tool.Equal(self.confId, Global.BuildingHospital) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetHospitalConf(self.confId + i)
            local limit = conf.limit
            item:Init(i, limit, get_power(i))
        end
        cur_show()
        return
    end
    -- Col4 城墙
    if Tool.Equal(self.confId, Global.BuildingWall) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetWallConf(self.confId + i)
            local limit = conf.defense_limit
            local durable = conf.durable
            item:Init(i, limit, durable, get_power(i))
        end
        cur_show()
        return
    end
    -- Col3 作战指挥部
    if Tool.Equal(self.confId, Global.BuildingDillGround) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetDillGroundConf(self.confId + i)
            local limit = conf.limit
            item:Init(i, limit, get_power(i))
        end
        cur_show()
        return
    end
    -- Col7 军需站
    if Tool.Equal(self.confId, Global.BuildingMilitarySupply) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetMilitarySupplyConf(self.confId + i)
            local times = conf.free_times
            local res = ResReset(conf.res)
            item:Init(i, times, res.wood, res.food, res.iron, res.stone, get_power(i))
        end
        cur_show()
        return
    end
    -- Col3 雷达
    if Tool.Equal(self.confId, Global.BuildingRadar) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetRadarConf(self.confId + i)
            local effect = ""
            local title = conf.Radar_Effect
            if title and title ~= "" then
                effect = StringUtil.GetI18n(I18nType.Commmon, title)
            end
            item:RadarInit(i, effect, get_power(i)) --雷达各等级详细信息显示特调
        end
        cur_show()
        return
    end
    -- Col3 联合指挥部
    if Tool.Equal(self.confId, Global.BuildingJointCommand) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetJointCommandConf(self.confId + i)
            local limit = conf.mass_limit
            item:Init(i, limit, get_power(i))
        end
        cur_show()
        return
    end
    -- Col4 物流中转站
    if Tool.Equal(self.confId, Global.BuildingTransferStation) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetTransferStationConf(self.confId + i)
            local limit = conf.res_support
            local tax = math.floor(conf.tax * 100) .. "%"
            item:Init(i, limit, tax, get_power(i))
        end
        cur_show()
        return
    end
    -- Col5 联盟大厦
    if Tool.Equal(self.confId, Global.BuildingUnionBuilding) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetUnionBuildingConf(self.confId + i)
            local time = conf.help_time
            local times = conf.help_num
            local limit = conf.help_limit
            item:Init(i, time, times, limit, get_power(i))
        end
        cur_show()
        return
    end
    -- Col4 警戒塔
    if Tool.Equal(self.confId, Global.BuildingTower) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetTowerConf(self.confId + i)
            local atk = conf.attack
            local atkSpeed = conf.attack_speed
            item:Init(i, atk, atkSpeed, get_power(i))
        end
        cur_show()
        return
    end
    -- Col3 巨兽医院
    if Tool.Equal(self.confId, Global.BuildingBeastHospital) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetBeastHospitalConf(self.confId + i)
            local cure = conf.beast_cure
            item:Init(i, cure, get_power(i))
        end
        cur_show()
        return
    end
    -- Col2 科研中心 / 巨兽基地 / 巨兽研究院
    if Tool.Equal(self.confId, Global.BuildingScience, Global.BuildingBeastBase, Global.BuildingBeastScience) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            item:Init(i, get_power(i))
        end
        cur_show()
        return
    end

    -- Col4 装备生产工厂
    if Tool.Equal(self.confId, Global.BuildingEquipFactory) then
        for i = 1, self._listInfo.numChildren do
            local item = self._listInfo:GetChildAt(i - 1)
            local conf = DetailModel.GetEquipFactoryConf(self.confId + i)
            local speed = conf.equip_speed.."%"
            local cost = conf.resource_cost.."%"
            item:Init(i, speed, cost, get_power(i))
        end
        cur_show()
        return
    end

    self._listInfo.numItems = 0
end

function ResReset(res)
    local obj = {}
    for _, v in pairs(res) do
        if v.category == Global.ResWood then
            obj.wood = v.amount
        elseif v.category == Global.ResStone then
            obj.stone = v.amount
        elseif v.category == Global.ResIron then
            obj.iron = v.amount
        elseif v.category == Global.ResFood then
            obj.food = v.amount
        end
    end
    return obj
end

--描述框触摸显示
function BuildDetail:TouchDescShow()
    self._touchDescGesture = UIMgr:GetLongPressGesture(self._touchDesc)
    self._touchDescGesture.trigger = 0
    self:AddListener(self._touchDescGesture.onBegin,pressPromptTrue)
    self:AddListener(self._touchDescGesture.onEnd,pressPromptFalse)     
end

return BuildDetail
