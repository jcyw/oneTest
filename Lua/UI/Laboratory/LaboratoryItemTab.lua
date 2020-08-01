local LaboratoryItemTab = fgui.extension_class(GButton)
fgui.register_extension("ui://Laboratory/btnItemLaboratoryTab", LaboratoryItemTab)

local TechModel = import("Model/TechModel")

function LaboratoryItemTab:ctor()
    self._txtName = self:GetChild("title")
    self._txtpercent = self:GetChild("text")
    self._icon = self:GetChild("icon")
    self._bgTime = self:GetChild("bgTime")
    self._lightBox = self:GetChild("boxIng")
    self._lockControl = self:GetController("lockControl")

    local button = self:GetChild("button")
    self:AddListener(button.onClick,
        function()
            if self.data then
                if self.disabled then
                    TipUtil.TipById(50315)
                    return
                end
                if self._onClick ~= nil then
                    self._onClick(self.data.id)
                end
                if self.triggerCallBack then
                    self.triggerCallBack()
                end
            else
                TipUtil.TipById(50066)
            end
        end
    )
end

function LaboratoryItemTab:Init(data, techType, onClick)
    local isEffect = false
    self.disabled = false
    if data.id ~= nil then
        self.data = data
        local percent = TechModel.GetTabPercent(self.data.id, techType)
        local icon = UITool.GetIcon(self.data.icon)
        self._icon.url = icon
        self._lockControl.selectedPage = "normal"
        self._onClick = onClick
        self._txtName.text = TechModel.GetTechTypeName(techType, self.data.id)
        self._txtpercent.text = percent .. "%"
        self._bgTime.fillAmount = percent / 100
        self.touchable = true

        if percent == 100 then
            self._lockControl.selectedPage = "max"
        else
            local upgrade = TechModel.GetUpdateDataByTab(data.id, techType)
            if upgrade then
                isEffect = true
                self._lockControl.selectedPage = "research"
            end
        end

        if not TechModel.CheckTabEnabled(data.id, techType) then
            self._lockControl.selectedPage = "disabled"
            self.disabled = true
        end
    else
        self.data = nil
        self._icon.url = nil
        self._lockControl.selectedPage = "lock"
        self._txtName.text = TechModel.GetTechTypeName(techType, "0")
    end
    -- self._lightBox.visible = false
    self:SetResearchEffect(isEffect)
end

function LaboratoryItemTab:SetResearchEffect(flag)
    if flag then
        if self.researchEffect then
            return
        end
        NodePool.Init(NodePool.KeyType.LaboratoryResearching, "Effect", "EffectNode")
        self.researchEffect = NodePool.Get(NodePool.KeyType.LaboratoryResearching)
        self:AddChild(self.researchEffect)
        self.researchEffect:SetXY(self.width / 2 + 7, self.height / 2 + 16)
        self.researchEffect:InitNormal()
        self.researchEffect:PlayDynamicEffectLoop("effect_collect", "Effect_researching_Star", Vector3(135, 135, 135))
    else
        if self.researchEffect then
            self.researchEffect:StopEffect()
            NodePool.Set(NodePool.KeyType.LaboratoryResearching, self.researchEffect)
            self.researchEffect = nil
        end
    end
end

function LaboratoryItemTab:TriggerOnclick(callback)
        self.triggerCallBack = callback
end

return LaboratoryItemTab
