--author: 	Amu
--time:		2020-03-12 20:09:31

local ItemCurtainAnim = fgui.extension_class(GButton)
fgui.register_extension("ui://BeautySystem/itemCurtainAnim", ItemCurtainAnim)

function ItemCurtainAnim:ctor()
    self._icon = self:GetChild("iconCup1")
    self._openAnim = self:GetTransition("open")
    self._closeAnim = self:GetTransition("close")
    self._loopAnim = self:GetTransition("loop")

    self._markCtrView = self:GetController("c1")
    self.effect = nil
    self:InitEvent()
end

function ItemCurtainAnim:InitEvent()

end

function ItemCurtainAnim:SetData(num)
end

function ItemCurtainAnim:Play(cb)
    self._markCtrView.selectedIndex = 0
    self._closeAnim:Play(function()
        self:PlayEffect()
        Event.Broadcast(EventDefines.GirlDisappearEvent, false)
        self._markCtrView.selectedIndex = 1
        self._loopAnim:Play(function()
            self._markCtrView.selectedIndex = 0
            self:StopEffect()
            Event.Broadcast(EventDefines.GirlDisappearEvent, true)
            self._openAnim:Play(function()
                if cb then
                    cb()
                end
            end)
        end)
    end)
end

function ItemCurtainAnim:PlayEffect()
    NodePool.Init(NodePool.KeyType.BeautyGirl_CurtainEffect, "Effect", "EffectNode")
    local item = NodePool.Get(NodePool.KeyType.BeautyGirl_CurtainEffect)
    self.effect = item
    item.x = self.width/2
    item.y = self.height/2 + 200
    self:AddChild(item)
    item:InitNormal()
    local scale = 1 / 0.0075
    item:PlayEffectLoop("effects/beauty/prefab/effect_yuehui_aixin", Vector3(80, 80, 80))
end

function ItemCurtainAnim:StopEffect()
    NodePool.Set(NodePool.KeyType.BeautyGirl_CurtainEffect, self.effect)
end

return ItemCurtainAnim