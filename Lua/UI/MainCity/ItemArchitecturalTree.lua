local GD = _G.GD
local ItemArchitecturalTree = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemArchitecturalTree", ItemArchitecturalTree)

local BuildModel = import("Model/BuildModel")

function ItemArchitecturalTree:ctor()
    self._groupState1 = self:GetChild("groupState1")
    self._groupState2 = self:GetChild("groupState2")
    self._groupArrow = self:GetChild("arrow")
    self._light = self:GetChild("light")
    self._txtPower = self:GetChild("textBattleNum")
    self._txtName = self:GetChild("textIcon3Name")
    self._txtResNum1 = self:GetChild("textSpeed1")
    self._txtResNum2 = self:GetChild("textSpeed2")
    self._iconRes1 = self:GetChild("iconResources1")
    self._iconRes2 = self:GetChild("iconResources2")
    self._iconMain = self:GetChild("icon3")
    self._iconCondition1 = self:GetChild("icon1")
    self._iconCondition2 = self:GetChild("icon2")
    self._iconCondition = self:GetChild("icon4")
    self._txtConditionName1 = self:GetChild("textIconName1")
    self._txtConditionName2 = self:GetChild("textIconName2")
    self._txtConditionName = self:GetChild("textIconName4")

end

function ItemArchitecturalTree:Init(baseConfig)
    self.baseConfig = baseConfig
    self.buildConfig = ConfigMgr.GetItem("configBuildingUpgrades", baseConfig.id)

    self._txtPower.text = "战力"..self.buildConfig.power
    self._iconMain.url = UITool.GetIcon(self.buildConfig.building_model)
    self._txtName.text = (BuildModel.GetName(self.buildConfig.id - (self.buildConfig.id%100)))..(self.buildConfig.id%100).."级"

    if (baseConfig.id % 400000) == BuildModel.GetCenterLevel() then
        self._light.visible = true
        self._txtName.color = Color(1, 0.89, 0.62)
        self._txtPower.color = Color(1, 0.89, 0.62)
    elseif (baseConfig.id % 400000) < BuildModel.GetCenterLevel() then
        self._light.visible = false
        self._txtName.color = Color.white
        self._txtPower.color = Color.white
    else
        self._light.visible = false
        self._txtName.color = Color(0.55, 0.56, 0.58)
        self._txtPower.color = Color(0.55, 0.56, 0.58)
    end

    local speed1 = self.baseConfig.collect_speed_iron
    if speed1 ~= nil then
        self._iconRes1.url =  GD.ResAgent.GetIconUrl(speed1.category)
        self._txtResNum1.text = speed1.amount.."/h"
    end
    local speed2 = self.baseConfig.collect_speed_food
    if speed2 ~= nil then
        self._iconRes2.url =  GD.ResAgent.GetIconUrl(speed2.category)
        self._txtResNum2.text = speed2.amount.."/h"
    end
    
    if self.buildConfig.condition == nil or #self.buildConfig.condition <= 0 then
        self._groupState1.visible = false
        self._groupState2.visible = false
        self._groupArrow.visible = false
    elseif #self.buildConfig.condition == 1 then
        local config = ConfigMgr.GetItem("configBuildingUpgrades", (self.buildConfig.condition[1].confId + self.buildConfig.condition[1].level))
        local model = BuildModel.FindByConfId(self.buildConfig.condition[1].confId)
        self._groupState1.visible = true
        self._groupState2.visible = false
        self._groupArrow.visible = true
        self._iconCondition.url = UITool.GetIcon(config.building_model)
        self._txtConditionName.text = BuildModel.GetName(self.buildConfig.condition[1].confId).." "..ConfigMgr.GetI18n(I18nType.Commmon, "UI_Details_Level")..self.buildConfig.condition[1].level

        if model == nil or model.Level < self.buildConfig.condition[1].level then
            self._iconCondition.grayed = true
            self._txtConditionName.color = Color(0.55, 0.56, 0.58)
        else
            self._iconCondition.grayed = false
            self._txtConditionName.color = Color.white
        end
    else
        local config1 = ConfigMgr.GetItem("configBuildingUpgrades", (self.buildConfig.condition[1].confId + self.buildConfig.condition[1].level))
        local config2 = ConfigMgr.GetItem("configBuildingUpgrades", (self.buildConfig.condition[2].confId + self.buildConfig.condition[2].level))
        local model1 = BuildModel.FindByConfId(self.buildConfig.condition[1].confId)
        local model2 = BuildModel.FindByConfId(self.buildConfig.condition[2].confId)
        self._groupState1.visible = false
        self._groupState2.visible = true
        self._groupArrow.visible = true
        self._iconCondition1.url = UITool.GetIcon(config1.building_model)
        self._txtConditionName1.text = BuildModel.GetName(self.buildConfig.condition[1].confId).." "..ConfigMgr.GetI18n(I18nType.Commmon, "UI_Details_Level")..self.buildConfig.condition[1].level
        self._iconCondition2.url = UITool.GetIcon(config2.building_model)
        self._txtConditionName2.text = BuildModel.GetName(self.buildConfig.condition[2].confId).." "..ConfigMgr.GetI18n(I18nType.Commmon, "UI_Details_Level")..self.buildConfig.condition[2].level

        if model1 == nil or model1.Level < self.buildConfig.condition[1].level then
            self._iconCondition1.grayed = true
            self._txtConditionName1.color = Color(0.55, 0.56, 0.58)
        else
            self._iconCondition1.grayed = false
            self._txtConditionName1.color = Color.white
        end

        if model2 == nil or model2.Level < self.buildConfig.condition[2].level then
            self._iconCondition2.grayed = true
            self._txtConditionName2.color = Color(0.55, 0.56, 0.58)
        else
            self._iconCondition2.grayed = false
            self._txtConditionName2.color = Color.white
        end
    end
end