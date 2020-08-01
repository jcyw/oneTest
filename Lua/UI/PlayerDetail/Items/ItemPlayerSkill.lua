--[[
    author:zhangrenkai
    time:2019-09-24 19:51:01
    function:Temmie
]]
local ItemPlayerSkill = fgui.extension_class(GComponent)
fgui.register_extension("ui://PlayerDetail/itemPlayerSkill", ItemPlayerSkill)

local SkillModel = import("Model/SkillModel")

function ItemPlayerSkill:ctor()
    self._lockControl = self:GetController("lockControl")
    self._tipControl = self:GetController("tipControl")
    self._outCircleControl = self:GetController("box")
    NodePool.Init(NodePool.KeyType.ActiveSkillEffect, "Effect", "EffectNode")

    self:AddListener(self.onClick,
        function()
            if self.cb then
                self.cb(self.config.id)
            end
            if self.triggerFunc then
                self.triggerFunc()
            end
        end
    )
end

function ItemPlayerSkill:Init(config, page, callback)
    self.cb = callback
    self.curPage = page
    self.model = SkillModel.GetModelById(config.id, self.curPage)

    if self.model then
        self:ConditionInit(config,self.model.Level)
        self._lockControl.selectedPage = "unlock"
        self._textLv.text = self.model.Level .. "/" .. self.config.max_lv

        if self.model.Level >= self.config.max_lv then
            --self._bgBoxLight.visible = true
            self._outCircleControl.selectedIndex = "0"
            self._textLv.color = Color.white
        else
            self._outCircleControl.selectedIndex = "0"
            self._textLv.color = Color.green
        end

        --学会的主动技能显示特效
        if self.model.Level > 0 and self.config.skill_type == 2 then
            self._outCircleControl.selectedIndex = "2"
            self.effect = NodePool.Get(NodePool.KeyType.ActiveSkillEffect)
            self:AddChild(self.effect)
            self.effect.xy = Vector2(80, 113)
            self.effect:PlayEffectLoop("effects/skill/weakenlight/prefab/effect_rouhua_gq", Vector3(150, 150, 150))
        end
    else
        self:ConditionInit(config,0)
        self._lockControl.selectedPage = "lock"
        self._outCircleControl.selectedIndex = "0"
        self._textLv.text = "0/" .. self.config.max_lv
    end
end

function ItemPlayerSkill:ConditionInit(config, lv)
    self.config = config
    self._icon.url = UITool.GetIcon(config.icon)
    --self._bgBoxLight.visible = false
    self._textLv.color = Color.white
    self._textLv.text = lv .. "/" .. self.config.max_lv
    if self.config.class then
        self._tipControl.selectedPage = "show"
        self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, self.config.class)
    else
        self._tipControl.selectedPage = "hide"
    end
end

function ItemPlayerSkill:SetUpLineVisible(value)
    self._upLine.visible = value
end

function ItemPlayerSkill:SetDownLineVisible(value)
    self._downLine.visible = value
end

function ItemPlayerSkill:SetUpLineLight(value)
    self._upLine:SetLight(value)
end

function ItemPlayerSkill:SetDownLineLight(value)
    self._downLine:SetLight(value)
end

function ItemPlayerSkill:SetIconGrayed(value)
    self._icon.grayed = value
end

function ItemPlayerSkill:SetTip(value)
    self._tipControl.selectedPage = value
end

function ItemPlayerSkill:TriggerOnclick(triggerClick)
    self.triggerFunc = triggerClick
end

function ItemPlayerSkill:GetEffect()
    return self.effect
end

function ItemPlayerSkill:StopEffect()
    if self.effect then
        self.effect:StopEffect()
        NodePool.Set(NodePool.KeyType.ActiveSkillEffect, self.effect)
        self.effect = nil
    end
end

return ItemPlayerSkill
