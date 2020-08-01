--author: 	Amu
--time:		2020-05-20 19:41:29

if EffectTool then
    return
end

EffectTool = {}

function EffectTool.AddBtnLightEffect(parent, posOffset, scale)
    NodePool.Init(NodePool.KeyType.BtnEffect, "Effect", "EffectNode")
    local _effect = NodePool.Get(NodePool.KeyType.BtnEffect)
    _effect.xy = Vector2(parent.width/2 + posOffset.x, parent.height/2+ posOffset.y)
    -- _effect.transform.localScale = Vector3(self.modelScale, self.modelScale, self.modelScale)
    parent:AddChild(_effect)
    _effect:InitNormal()
    _effect:PlayEffectLoop("effects/giftbtneffect/prefab/effect_icon_saoguang", scale)

    return _effect
end

return EffectTool