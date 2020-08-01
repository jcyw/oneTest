local LaboratoryPopupPanel = UIMgr:NewUI("LaboratoryPopupPanel")

local TechModel = import("Model/TechModel")

function LaboratoryPopupPanel:OnInit()
    local view = self.Controller.contentPane
    self._txtTitle = view:GetChild("titleName")
    self._txtName = view:GetChild("titleDescribe")
    self._txtDes = view:GetChild("textResources")
    self._list = view:GetChild("liebiao")

    local btnClose = view:GetChild("btnClose")
    self:AddListener(btnClose.onClick,function()
        UIMgr:Close("LaboratoryPopupPanel")
    end)

    local bgMask = view:GetChild("bgMask")
    self:AddListener(bgMask.onClick,function()
        UIMgr:Close("LaboratoryPopupPanel")
    end)
end

function LaboratoryPopupPanel:OnOpen(configId, techType)
    self.techType = techType
    self._config = TechModel.GetDisplayConfigItem(self.techType, configId)
    self._model = TechModel.FindByConfId(configId)
    self._txtTitle.text = TechModel.GetTechName(self._config.id)..StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Level")..((self._model == nil) and 0 or self._model.Level)
    self._txtName.text = StringUtil.GetI18n(I18nType.Commmon, "Tech_Detail2", {tech_name = TechModel.GetTechName(self._config.id)}) 
    self._txtDes.text = TechModel.GetTechDesc(self._config.id)

    self:InitList()
end

function LaboratoryPopupPanel:InitList()
    self._list:RemoveChildrenToPool()

    local maxLv = self._config.max_lv
    for i=1, maxLv do
        local item = self._list:AddItemFromPool()
        item:GetChild("groupState1").visible = false
        item:GetChild("groupState2").visible = false
        item:GetChild("groupState3").visible = true
        local lvConfig = TechModel.GetTechConfigItem(self.techType, self._config.id + i)
        if lvConfig ~= nil then
            item:GetChild("textLevelNumber").text = i
            item:GetChild("textResourcesNumber").text = self._config.show == 2 and lvConfig.para2[1] or ((lvConfig.para2[1]/100).."%")
            item:GetChild("textBattleNumber").text = lvConfig.power
            local control = item:GetController("c1")
            if self._model and self._model.Level == i then
                control.selectedIndex = 0
            else
                control.selectedIndex = 1
            end
        end
    end
end

return LaboratoryPopupPanel