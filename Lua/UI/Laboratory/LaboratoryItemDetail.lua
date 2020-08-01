-- 科技树界面中的科技图标
local LaboratoryItemDetail = fgui.extension_class(GButton)
fgui.register_extension("ui://Laboratory/btnItemLaboratoryDetail", LaboratoryItemDetail)

local TechModel = import("Model/TechModel")

function LaboratoryItemDetail:ctor()
    self._icon = self:GetChild("icon")
    self._bg = self:GetChild("bg")
    self._txtLv = self:GetChild("text")
    self._redTip = self:GetChild("redPoint")
    self._txtTime = self:GetChild("textTime")
    self._bgTime = self:GetChild("bgTime")
    self._txtTitle = self:GetChild("title")
    self._lightBox = self:GetChild("boxIng")
    self._lockControl = self:GetController("lockControl")
    self._pointControl = self:GetController("pointControl")

    self:AddListener(self._button.onClick,
        function()
            self.callback(self.config.id)
            if self.triggerCallBack then
                self.triggerCallBack()
            end
        end
    )
end

function LaboratoryItemDetail:Init(config, techType, upgrade, callback)
    self.config = config
    self.callback = callback
    self.upgrade = upgrade
    self.techType = techType
    self._pointControl.selectedPage = "light"

    self._redTip.visible = false
    self._txtTitle.text = TechModel.GetTechName(config.id)
    self._icon.url = UITool.GetIcon(config.icon)

    if self.schedule_funtion then
        self:UnSchedule(self.schedule_funtion)
    end

    local isEffect = false
    if upgrade == nil then
        -- self._txtTime.visible = false
        -- self._bgTime.visible = false
        self._lockControl.selectedPage = "unlock"
    else
        -- self._txtTime.visible = true
        -- self._bgTime.visible = true
        self._lockControl.selectedPage = "research"
        isEffect = true
        local function time_func()
            return upgrade.FinishAt - Tool.Time()
        end
        if time_func() > 0 then
            local formatCT = Tool.FormatTime(time_func())
            self.schedule_funtion = function()
                local t = time_func()
                if t >= 0 then
                    self._txtTime.text = Tool.FormatTime(t)
                else
                    self._txtTime.visible = false
                    self._bgTime.visible = false
                    if self:CheckMax() then
                        self._lockControl.selectedPage = "max"
                    else
                        self._lockControl.selectedPage = "unlock"
                    end
                    isEffect = false
                    if self.schedule_funtion then
                        self:UnSchedule(self.schedule_funtion)
                    end
                end
            end
            self.schedule_funtion()
            self:Schedule(self.schedule_funtion, 1)
        end
    end
    -- self._lightBox.visible = false
    self:PlayResearchingEffect(isEffect)

    local model = TechModel.FindByConfId(config.id)
    if model ~= nil then
        self._txtLv.text = model.Level .. "/" .. config.max_lv
    else
        self._txtLv.text = "0/" .. config.max_lv
    end

    local canUnlock = TechModel.CheckUnlock(config, self.techType)
    if canUnlock then
        if self:CheckMax() then
            self._lockControl.selectedPage = "max"
        else
            if upgrade == nil then
                self._lockControl.selectedPage = "unlock"
            end
        end

        local canUpgrade = TechModel.CheckTechCanUpgrade(config, self.techType)
        self._txtLv.color = canUpgrade and Color.green or Color.white
    else
        if model and model.Level > 0 then
            self._lockControl.selectedPage = "unlock"
            self._pointControl.selectedPage = "light"
            self._txtLv.color = Color.green
        else
            self._lockControl.selectedPage = "lock"
            self._pointControl.selectedPage = "gray"
            self._txtLv.color = Color.white
        end
    end
end

function LaboratoryItemDetail:CheckMax()
    local model = TechModel.FindByConfId(self.config.id)
    if model ~= nil then
        if model.Level >= self.config.max_lv then
            return true
        end
    else
        return false
    end
end

function LaboratoryItemDetail:SetPoint(type)
    self._pointControl.selectedPage = type
end

function LaboratoryItemDetail:TriggerOnclick(callback)
        self.triggerCallBack = callback
end

function LaboratoryItemDetail:PlayEffect()
    if not GlobalVars.IsShowEffect() then
        --低端机不显示
        return
    end
    if self.effectNode then
        return
    end
    self.effectNode = UIMgr:CreateObject("Effect", "EffectNode")
    self.effectNode.xy = Vector2(90, 77)
    self:AddChild(self.effectNode)
    self.effectNode:PlayEffectLoop("effects/researchtips/prefab/effect_research_tips2",Vector3(170, 170, 170),0)
    -- --动态资源加载
    -- DynamicRes.GetBundle("effect_collect", function()
    --     DynamicRes.GetPrefab("effect_collect", "effect_research_tips2", function(prefab)
    --         local object = GameObject.Instantiate(prefab)
    --         object.transform.localScale = Vector3(170, 170, 170)
    --         self.effectNode:GetGGraph():SetNativeObject(GoWrapper(object))
    --     end)
    -- end)
end

function LaboratoryItemDetail:ClearEffect()
    if self.effectNode then
        self.effectNode:Dispose()
        self.effectNode = nil
    end
end

function LaboratoryItemDetail:PlayResearchingEffect(isPlay)
    if isPlay then
        if self.researchEffect then
            return
        end
        NodePool.Init(NodePool.KeyType.LaboratoryResearching, "Effect", "EffectNode")
        self.researchEffect = NodePool.Get(NodePool.KeyType.LaboratoryResearching)
        self:AddChild(self.researchEffect)
        self.researchEffect:SetXY(self.width / 2 + 6, self.height / 2 - 1)
        self.researchEffect:InitNormal()
        self.researchEffect:PlayDynamicEffectLoop("effect_collect", "Effect_researching_Star", Vector3(115, 115, 115))
    else
        if self.researchEffect then
            self.researchEffect:StopEffect()
            NodePool.Set(NodePool.KeyType.LaboratoryResearching, self.researchEffect)
            self.researchEffect = nil
        end
    end
end

function LaboratoryItemDetail:PlayResearchEndEffect(isPlay)
    if isPlay then
        if self.researchEndEffect then
            return
        end
        NodePool.Init(NodePool.KeyType.LaboratoryResearchEnd, "Effect", "EffectNode")
        self.researchEndEffect = NodePool.Get(NodePool.KeyType.LaboratoryResearchEnd)
        self:AddChild(self.researchEndEffect)
        self.researchEndEffect:SetXY(self.width / 2, self.height / 2 - 25)
        self.researchEndEffect:InitNormal()
        self.researchEndEffect:PlayDynamicEffectLoop("effect_collect", "Effect_Research_end", Vector3(110, 110, 110))
    else
        if self.researchEndEffect then
            self.researchEndEffect:StopEffect()
            NodePool.Set(NodePool.KeyType.LaboratoryResearchEnd, self.researchEndEffect)
            self.researchEndEffect = nil
        end
    end
end

return LaboratoryItemDetail
