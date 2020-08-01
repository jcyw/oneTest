--[[
    Author: songzeming
    Function: 主界面下面按钮 邮件、任务、背包、联盟
]]
local ItemBtnMainDown = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/btnMainDownItem", ItemBtnMainDown)

local UnionModel = import("Model/UnionModel")

function ItemBtnMainDown:ctor()
    self._ctr = self:GetController("ctr")
    self._bg = self:GetChild("bg")
    self._behindEffect = self:GetChild("behindEffect")
    self._frontEffect = self:GetChild("frontEffect")
end

--联盟：是否解锁
function ItemBtnMainDown:CheckShow(flag)
    self.touchable = flag
    for i = 1, self.numChildren do
        self:GetChildAt(i - 1).visible = flag
    end
    self._bg.visible = true
    if self.effect then
        self.effect.visible = PlayerDataModel:GetData(PlayerDataEnum.AddedUnion) and not UnionModel.CheckJoinUnion()
    end
end

--是否加入联盟
function ItemBtnMainDown:CheckJoinUnion(flag)
    if self.effect then
        self.effect:StopEffect()
        NodePool.Set(NodePool.KeyType.ActiveSkillEffect, self.effect)
    end

    local isAddedUnion = PlayerDataModel:GetData(PlayerDataEnum.AddedUnion)
    if not isAddedUnion and not flag then
        --初次加入
        self._ctr.selectedIndex = 1
        self._behindEffect:PlayEffectLoop("effects/union/joinunionfirst/prefab/effect_fist_jiarulianmeng", Vector3(140, 140, 140))
    elseif isAddedUnion and not flag then
        --再次加入
        self._ctr.selectedIndex = 2
        self._behindEffect:PlayEffectLoop("effects/union/joinunion/prefab/effect_union_join_b", Vector3(100, 100, 100))
        self._frontEffect:PlayEffectLoop("effects/union/joinunion/prefab/effect_union_join", Vector3(100, 100, 100))
    else
        self._ctr.selectedIndex = 0
        self._behindEffect:EffectDispose()
        self._frontEffect:EffectDispose()
    end
end

--联盟提示点初始化
function ItemBtnMainDown:InitUnionPoint()
    CuePointModel:CheckUnion(self)
end

return ItemBtnMainDown
