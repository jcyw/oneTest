--author: 	Amu
--time:		2020-03-11 20:43:54

local ItemBeautySkill = fgui.extension_class(GComponent)
fgui.register_extension("ui://BeautySystem/itemBeautySkill", ItemBeautySkill)

function ItemBeautySkill:ctor()
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")
    self._desc = self:GetChild("text")

    self._ctrView = self:GetController("c1")

    self._unLocalAnim = self:GetTransition("Lock")

    self:InitEvent()
    self:AddListener(self.onClick,function ()
        if self._info and self._info.favor > self._exp then
            TipUtil.TipById(50310, {num = self._info.favor})
        end
    end)
end

function ItemBeautySkill:InitEvent()

end

function ItemBeautySkill:SetData(info, exp)
    self._info = info
    self._exp = exp

    if info.favor > exp then
        self._ctrView.selectedIndex = 1 
    else
        self._ctrView.selectedIndex = 0
    end

    local config = ConfigMgr.GetItem("configGirlskills", info.skill)

    self._title.text = StringUtil.GetI18n("configI18nCommons", config.name)
    self._icon.icon = UITool.GetIcon(config.icon)
    local desc = ""
    for k,v in ipairs(config.buff_id)do
        local buffInfo = ConfigMgr.GetItem("configAttributes", v)
        local data = {}
        if buffInfo.value_type == 2 then
            data.num = tostring(math.floor(config.buff_num[k]/100)).."%"
        elseif buffInfo.value_type == 1 then
            data.num = config.buff_num[k]
        end
        desc = desc..StringUtil.GetI18n("configI18nSkills", string.format("SKILL_%d_DESC", v), data)
        if k ~= #config.buff_id then
            desc = desc.."\n"
        end
    end
    self._desc.text = desc
end

function ItemBeautySkill:PlayUnLockAnime(skillId, cb)
    self.cb = cb
    self._ctrView.selectedIndex = 1
    
    local config = ConfigMgr.GetItem("configGirlskills", skillId)

    self._title.text = StringUtil.GetI18n("configI18nCommons", config.name)
    self._icon.icon = UITool.GetIcon(config.icon)
    local desc = ""
    for k,v in ipairs(config.buff_id)do
        local buffInfo = ConfigMgr.GetItem("configAttributes", v)
        local data = {}
        if buffInfo.value_type == 2 then
            data.num = tostring(math.floor(config.buff_num[k]/100)).."%"
        elseif buffInfo.value_type == 1 then
            data.num = config.buff_num[k]
        end
        desc = desc..StringUtil.GetI18n("configI18nSkills", string.format("SKILL_%d_DESC", v), data)
        if k ~= #config.buff_id then
            desc = desc.."\n"
        end
    end
    self._desc.text = desc
    self._unLocalAnim:Play()
    self:PlayeSkillEffect()
end

function ItemBeautySkill:PlayeSkillEffect()
    NodePool.Init(NodePool.KeyType.BeautyGirl_SkillEffect, "Effect", "EffectNode")
    local item = NodePool.Get(NodePool.KeyType.BeautyGirl_SkillEffect)
    self.continueffect = item
    item.x = self.width/2
    item.y = self.height/3 + 20
    self:AddChild(item)
    item:InitNormal()
    -- local scale = 1 / 0.0075
    item:PlayEffectSingle("effects/beauty/prefab/effect_jiesuo", function()
        NodePool.Set(NodePool.KeyType.BeautyGirl_SkillEffect, self.continueffect)
        if self.cb then
            self.cb()
        end
    end, Vector3(80, 80, 80))
end

return ItemBeautySkill
