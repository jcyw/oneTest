--author: 	Amu
--time:		2020-05-20 16:21:59

local GiftItem = fgui.extension_class(GComponent)
fgui.register_extension("ui://Recharge/giftItem", GiftItem)

function GiftItem:ctor()
    self._effectNode = self:GetChild("_effectNode")
    if not self._giftIconEffect then
        NodePool.Init(NodePool.KeyType.GiftIconEffect, "Effect", "EffectNode")
        self._giftIconEffect = NodePool.Get(NodePool.KeyType.GiftIconEffect)
        --effect.xy = Vector2(40, 45)
        self._effectNode:AddChild(self._giftIconEffect)
        self._giftIconEffect:InitNormal()
        self._giftIconEffect:PlayEffectLoop("effects/firstflushgift/prefab/effect_gift_icon", Vector3(1.8, 1.8, 1.8))
    end
    self:InitEvent()
end

function GiftItem:InitEvent()
end

function GiftItem:SetData(index)
    self.index = index
end

function GiftItem:GetIndex()
    return self.index
end

return GiftItem