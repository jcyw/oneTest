--author: 	maxiaolong
--time:		2020-04-23 14:48:35

local BeautyIntroduce = UIMgr:NewUI("BeautyIntroduce")

function BeautyIntroduce:OnInit()
    self:InitEvent()
end
local IsTriggerOk = false
function BeautyIntroduce:InitEvent()
    self.view = self.Controller.contentPane
    self._touch = self.view:GetChild("touch")
    self._anim = self.view:GetTransition("Anim")
    self._text1 = self.view:GetChild("text1")
    self._text2 = self.view:GetChild("text2")
    self._text3 = self.view:GetChild("text3")
    self:AddListener(self._touch.onClick,
        function()
            if not IsTriggerOk then
                return
            end
            if self.TriggerFunc then
                self.TriggerFunc()
            end
        end
    )
end

function BeautyIntroduce:OnOpen(strName, strOld, strWork)
    self._text1.text = strName
    self._text2.text = strOld
    self._text3.text = strWork
    IsTriggerOk = false
    self._anim:Play(
        0,
        0,
        function()
            IsTriggerOk = true
        end
    )
    self:PlayEffect()
end

function BeautyIntroduce:PlayEffect()
    NodePool.Init(NodePool.KeyType.BeautyIntroduceEffect, "Effect", "EffectNode")
    self.effect = NodePool.Get(NodePool.KeyType.BeautyIntroduceEffect)
    self._effectNode:AddChild(self.effect)
    self.effect:InitNormal()
    self.effect:PlayEffectLoop("effects/beauty/prefab/effect_beauty_introduce")
end

function BeautyIntroduce:RefreshText()
end

function BeautyIntroduce:Close()
    NodePool.Set(NodePool.KeyType.BeautyIntroduceEffect, self.effect)
    UIMgr:Close("BeautyIntroduce")
end

function BeautyIntroduce:TriggerOnclick(callBack)
        self.TriggerFunc = callBack
end
return BeautyIntroduce
