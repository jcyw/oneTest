-- 部队详情界面
local TroopsDetails = UIMgr:NewUI("TroopsDetails")

import("UI/MainCity/TroopsDetailsPopup")
import("UI/MainCity/TroopsDetailsFormation")
local ArmiesModel = import("Model/ArmiesModel")
local DetailModel = import('Model/DetailModel')
local BuildModel = import('Model/BuildModel')
local VIPModel = import("Model/VIPModel") 
local MonsterModel = import("Model/MonsterModel")

function TroopsDetails:OnInit()
    self._list.scrollItemToViewOnClick = false
    self.refreshFunc = function()
        self:OnOpen(self.callback)
    end

    self._btnTroops:Init(nil, false, function(index, formation, name)
        self._btnTroops:SelectedBtn(0)
        UIMgr:Open("TroopsDetailsFormation", index)
    end)

    -- local btnReturn = view:GetChild("btnReturn")
    self:AddListener(self._btnReturn.onClick,function()
        UIMgr:Close("TroopsDetails")
        if self.callback ~= nil then
            self.callback()
        end
    end)
end

function TroopsDetails:OnOpen()
    self.securityCount = 0
    self.missions = ArmiesModel.GetMissionArmies()
    self._btnTroops:RefreshTeamButton()

    self:InitDetailPanel()
    self:InitTroopsList()

    self:AddEvent(EventDefines.UIArmiesRefresh, self.refreshFunc)
end

function TroopsDetails:OnClose( )
    Event.RemoveListener(EventDefines.UIArmiesRefresh, self.refreshFunc)
end

function TroopsDetails:InitDetailPanel()
    local armyAmount = 0
    local marchAmount = 0
    local hurtAmount = 0
    local armyUpKeep = ArmiesModel.GetAllArmyCost()
    local totalInjuredAmount = Global.HospitalBaseLimit
    local armies = Model.GetMap("Armies")
    for k,v in pairs(armies) do
        local config = ArmiesModel.GetArmyConfig(v.ConfId)
        if config.army_type ~= Global.SecurityArmyType then
            armyAmount = armyAmount + v.Amount
        else
            self.securityCount = self.securityCount + v.Amount
        end
    end

    for _,v in pairs(Model.InjuredArmies) do
        hurtAmount = hurtAmount + v.Amount
    end

    for _, v in pairs(Model.Buildings) do
        if v.ConfId == Global.BuildingHospital and v.Level > 0 then
            local conf = ConfigMgr.GetItem("configHospitals", v.ConfId + v.Level)
            totalInjuredAmount = totalInjuredAmount + conf.limit
        end
    end

    for _,v in pairs(self.missions) do
        for _,v1 in pairs(v.armies) do
            marchAmount = marchAmount + 1
        end
    end

    local missions = self.missions

    self._txtTotalForceNumber.text = Tool.FormatNumberThousands(armyAmount)
    self._txtGrainConsumptionNumber.text = Tool.FormatNumberThousands(math.ceil(armyUpKeep)).."/h"
    self._txtMarchNum.text = #missions.."/"..ArmiesModel.GetMarchQueueMax()
    self._txtHurtNum.text = Tool.FormatNumberThousands(hurtAmount).."/"..Tool.FormatNumberThousands(math.floor((totalInjuredAmount + BuffModel.GetCureArmyLimit()) * BuffModel.GetCureArmyLimitPerc()))
end

-- 列表显示所有部队概览
function TroopsDetails:InitTroopsList()
    self._list:RemoveChildrenToPool()
    
    -- 部队信息
    local item = self._list:AddItemFromPool()
    item:GetChild("btnArrow").visible = false
    self:ClearListener(item:GetChild("btnTitle").onClick)
    ArmiesModel.Init()
    item:GetChild("title").text = ConfigMgr.GetI18n(I18nType.Commmon, "UI_Army_Army").."("..ArmiesModel.GetAllCount()..")"
    local list = item:GetChild("list")
    list:RemoveChildrenToPool()
    local armyBuildings = ConfigMgr.GetListBySearchKeyValue("configBuildings", "category", 2)
    local index = 0
    
    -- 巨兽信息
    local beasts = {}
    for _,v in pairs(MonsterModel.GetBeastModels()) do
        if not ArmiesModel.IsBeastExpedition(v.Id) and MonsterModel.IsUnlock(v.Id) then
            table.insert(beasts, v)
        end
    end
    if next(beasts) then
        local armyDetailPanel = list:AddItemFromPool()
        armyDetailPanel:BeastInit(ConfigMgr.GetI18n(I18nType.Commmon, "UI_BEAST"), beasts, false)
        index = index + 1
    end
    
    -- 根据不同造兵建筑分类显示
    for k,v in pairs(armyBuildings) do
        local type = v["army"]["base_level"]
        local maxLv = v["army"]["amount"]
        if TroopsDetails:CheckArmy(type, maxLv) then
            local arm = ConfigMgr.GetItem("configArmys", type).army_type
            local name = ConfigMgr.GetI18n("configI18nArmys", "UI_Army_"..arm)
            local armyDetailPanel = list:AddItemFromPool()            
            armyDetailPanel:Init(name, self:GetArmiesAndAmount(type, maxLv), false, false)
            index = index + 1
        end
    end
    if list.numChildren > 0 then
        item:GetController("typeControl").selectedPage = "open"
        list:ResizeToFit(index)
    else
        item:GetController("typeControl").selectedPage = "empty"
        item:GetChild("_textEmpty").text = StringUtil.GetI18n(I18nType.Commmon, "UI_NOARMIES_INBASE")
        item.height = 348
    end

    -- 陷阱信息
    item = self._list:AddItemFromPool()
    item:GetChild("btnArrow").visible = false
    self:ClearListener(item:GetChild("btnTitle").onClick)
    self._list.scrollPane:ScrollTop()
    local building = BuildModel.FindByConfId(Global.BuildingWall)
    local confWall = DetailModel.GetWallConf(building.ConfId + building.Level)
    local defensMax = confWall and confWall.defense_limit or 0
    item:GetChild("title").text = ConfigMgr.GetI18n(I18nType.Commmon, "UI_Army_Weapon").."("..self.securityCount.."/"..defensMax..")"
    list = item:GetChild("list")
    list:RemoveChildrenToPool()
    for k,v in pairs(armyBuildings) do
        local type = v["army"]["base_level"]
        local maxLv = v["army"]["amount"]
        if TroopsDetails:CheckSecurity(type, maxLv) then
            local arm = ConfigMgr.GetItem("configArmys", type).arm
            -- local name = ConfigMgr.GetI18n("configI18nArmys", "ARMY_TYPE_"..arm.."_NAME")
            local armyDetailPanel = list:AddItemFromPool()            
            armyDetailPanel:Init("", self:GetArmiesAndAmount(type, maxLv), true, false)
            index = index + 1
        end
    end
    if list.numChildren > 0 then
        item:GetController("typeControl").selectedPage = "open"
        list:ResizeToFit(index)
    else
        item:GetController("typeControl").selectedPage = "empty"
        item:GetChild("_textEmpty").text = StringUtil.GetI18n(I18nType.Commmon, "UI_NOWEAPON_INBASE")
        item.height = 348
    end

    -- 出征信息
    self:InitMarchList()
end

-- 列表显示出征部队概览
function TroopsDetails:InitMarchList()
    -- self._list:RemoveChildrenToPool()

    for k,v in pairs(self.missions) do
        local item = self._list:AddItemFromPool()
        local typeControl = item:GetController("typeControl")
        local click = item:GetChild("btnTitle").onClick
        typeControl.selectedPage = "open"
        item:GetChild("btnArrow").visible = true
        self:ClearListener(click)
        self:AddListener(click,function()
            if typeControl.selectedPage == "open" then
                typeControl.selectedPage = "close"
            else
                typeControl.selectedPage = "open"
            end
        end)

        local list = item:GetChild("list")
        list:RemoveChildrenToPool()
        local armyDetailPanel = list:AddItemFromPool()

        local curAmount = 0
        for _,v1 in pairs(v.armies) do
            curAmount = curAmount + v1.Amount
        end

        armyDetailPanel:MixInit("", v, true, true)
        item:GetChild("title").text = ConfigMgr.GetI18n(I18nType.Commmon, "UI_Army_Army")..k.."("..curAmount..")"
        list:ResizeToFit(1)
    end
end

-- 单个士兵信息
-- function TroopsDetails:InitArmyDetailPanel(panel, type, maxLv)
--     local armyList = panel:GetChild("list")
--     armyList:RemoveChildrenToPool()
--     local index = 0
--     for i=1, maxLv do
--         local lv = i-1
--         local id = type + lv
--         local army = ArmiesModel.FindByConfId(id)
--         if army ~= nil then
--             index = index + 1
--             local armyConfig = ConfigMgr.GetItem("configArmys", id)
--             local armyPanel = armyList:AddItemFromPool()
--             armyPanel:Init(id, lv, "ico"..(type + lv), army.Amount)
--         end
--     end
--     armyList:ResizeToFit(index)
-- end

-- 是否是部队
function TroopsDetails:CheckArmy(type, maxLv)
    for i=1, maxLv do
        local lv = i-1
        local id = type + lv
        local army = ArmiesModel.FindByConfId(id)
        if army ~= nil and army.Amount > 0 then
            local config = ConfigMgr.GetItem("configArmys", army.ConfId)
            if config.army_type ~= Global.SecurityArmyType then
                return true;
            end
        end
    end

    return false;
end

function TroopsDetails:CheckSecurity(type, maxLv)
    for i=1, maxLv do
        local lv = i-1
        local id = type + lv
        local army = ArmiesModel.FindByConfId(id)
        if army ~= nil and army.Amount > 0 then
            local config = ConfigMgr.GetItem("configArmys", army.ConfId)
            if config.army_type == Global.SecurityArmyType then
                return true;
            end
        end
    end

    return false;
end

function TroopsDetails:GetArmiesAndAmount(type, maxLv)
    local armies = {}
    local amount = 0
    for i=1, maxLv do
        local lv = i-1
        local id = type + lv
        local army = ArmiesModel.FindByConfId(id)
        if army ~= nil and army.Amount > 0 then
            amount = amount + army.Amount
            table.insert(armies, {ConfId = army.ConfId, Amount = army.Amount})
        end
    end

    return armies, amount
end

return TroopsDetails