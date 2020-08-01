--[[
    author:{laofu}
    time:2020-06-03 23:06:52
    function:{联盟徽章特效组件}
]]
local ItemUnionMedal = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemUnionMedal", ItemUnionMedal)

function ItemUnionMedal:ctor()
    self._icon = self:GetChild("icon")
    self._effect = self:GetChild("effect")
    NodePool.Init(NodePool.KeyType.UnionMedalEffect, "Effect", "EffectNode")
end

--设置联盟徽章
function ItemUnionMedal:SetMedal(id, scale)
    self:Remove()
    self._icon.icon, id = UnionModel.GetUnionBadgeIcon(id)
    local type = math.fmod(id, 10)
    self.unionMedalEffect = NodePool.Get(NodePool.KeyType.UnionMedalEffect)
    self._effect:AddChild(self.unionMedalEffect)
    self.unionMedalEffect.xy = Vector2(0, 0)
    self.unionMedalEffect:InitNormal()
    --local path = string.format("effects/unionmedal/medal_0%d/prefab/effect_medal_0%d", type, type)
    local path = string.format("effect_medal_0%d", type)
    local abName = string.format("effect_unionmedal/medal_0%d", type)
    --self.unionMedalEffect:PlayEffectSingle(path, nil, scale)
    self.unionMedalEffect:PlayDynamicEffectSingle(abName, path, nil, scale,nil,1)
end

function ItemUnionMedal:Remove()
    if self.unionMedalEffect then
        NodePool.Set(NodePool.KeyType.UnionMedalEffect, self.unionMedalEffect)
        NodePool.Remove(NodePool.KeyType.UnionMedalEffect)
    end
end

return ItemUnionMedal
