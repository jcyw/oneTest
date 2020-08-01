--[[
    Author: songzeming
    Function: 建筑 巨兽医院
]]
local BuildBeastHospital = fgui.extension_class(GButton)
fgui.register_extension("ui://Build/Building441000", BuildBeastHospital)

local EventModel = import("Model/EventModel")
local MonsterModel = import("Model/MonsterModel")
local BuildNest = import("UI/MainCity/BuildRelated/BuildAnim/BuildNest")

function BuildBeastHospital:ctor()
    self:AddEvent(
        EventDefines.UIInjuredBeastExg,
        function()
            self:CheckInjuredArmy()
        end
    )

    NodePool.Init(NodePool.KeyType.HospitalBuildCure, "Effect", "EffectNode")
    self:PlayEffect()
end

function BuildBeastHospital:Init(building)
    self.building = building
    self:CheckInjuredArmy()
end

function BuildBeastHospital:CheckInjuredArmy()
    --显示巨兽受伤动画
    self:ShowInjuredAnim()

    --有升级拆除事件 不显示特效
    if EventModel.GetUpgradeEvent(self.building.Id) then
        self:StopCureAnim()
        return
    end
    local cureEvent = EventModel.GetBeastCureEvent()
    if cureEvent and next(cureEvent) ~= nil then
        self:StopCureAnim()
        return
    end

    --没有伤兵
    if next(MonsterModel.GetBeastModels()) == nil then
        self:StopCureAnim()
        return
    end

    for _, v in pairs(MonsterModel.GetBeastModels()) do
        if MonsterModel.GetMonsterRealMaxHealth(v) > v.DisplayHealth then
            --有伤兵
            self:StartCureAnim()
            return
        end
    end

    --没有伤兵
    self:StopCureAnim()
end

--开始播放治疗动画
function BuildBeastHospital:StartCureAnim(monsterId)
    if self.isCureAnim then
        return
    end
    self.isCureAnim = true

    local item = NodePool.Get(NodePool.KeyType.HospitalBuildCure)
    item.xy = Vector2(self.x + 200, self.y + 100)
    self:AddChild(item)
    item:InitNormal()
    item:PlayEffectLoop("effects/build/cure/cure", Vector3(100, 100, 100))
    self.BuildCureAnim = item
end

--停止播放治疗动画
function BuildBeastHospital:StopCureAnim()
    if not self.isCureAnim then
        return
    end
    self.isCureAnim = false

    self.BuildCureAnim:StopEffect()
    NodePool.Set(NodePool.KeyType.HospitalBuildCure, self.BuildCureAnim)
end

--显示巨兽受伤动画
function BuildBeastHospital:ShowInjuredAnim()
    for _, v in pairs(MonsterModel.GetBeastModels()) do
        local max = MonsterModel.GetMonsterRealMaxHealth(v)
        local percent = math.floor((v.DisplayHealth) / max * 100)
        local injure = percent < 10
        BuildNest.PlayMonsterInjuredAnim(v.Id, injure)
    end
end

function BuildBeastHospital:PlayEffect()
    NodePool.Init(NodePool.KeyType.BuildBeastHospitalEffect, "Effect", "EffectNode")
    local effect = NodePool.Get(NodePool.KeyType.BuildBeastHospitalEffect)
    self:AddChild(effect)
    effect.xy = Vector2(self.x, self.y)
    effect:InitNormal()
    effect:PlayEffectSingle("effects/build/jushoubuild/prefab/effect_jushou_yanjiusuo")
end

return BuildBeastHospital
