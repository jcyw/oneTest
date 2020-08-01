--[[
    Author: songzeming
    Function: 建筑 战区医院
]]
local BuildHospital = fgui.extension_class(GButton)
fgui.register_extension("ui://Build/Building411000", BuildHospital)

local EventModel = import("Model/EventModel")
local ParadeSquareModel = import("Model/Animation/ParadeSquareModel")

function BuildHospital:ctor()
    self:AddEvent(
        EventDefines.UIInjuredArmyAmountExg,
        function()
            self:CheckInjuredArmy()
        end
    )

    NodePool.Init(NodePool.KeyType.HospitalBuildCure, "Effect", "EffectNode")
end

function BuildHospital:Init(building)
    self.building = building
    self:CheckInjuredArmy()
end

function BuildHospital:CheckInjuredArmy()
    --阅兵广场部队变化
    ParadeSquareModel.ParadeSquareShow()
    --有升级拆除事件 不显示特效
    local event = EventModel.GetEvent(self.building)
    if event and event.Category ~= EventType.B_CURE then
        self:StopCureAnim()
        return
    end

    --没有伤兵
    if next(Model.InjuredArmies) == nil then
        self:StopCureAnim()
        return
    end

    for _, v in pairs(Model.InjuredArmies) do
        if v.Amount > 0 then
            --有伤兵
            self:StartCureAnim()
            return
        end
    end

    --没有伤兵
    self:StopCureAnim()
end

--开始播放治疗动画
function BuildHospital:StartCureAnim()
    if self.isCureAnim then
        return
    end
    self.isCureAnim = true

    local item = NodePool.Get(NodePool.KeyType.HospitalBuildCure)
    item.xy = Vector2(self.x + 120, self.y + 100)
    self:AddChild(item)
    item:InitNormal()
    item:PlayEffectLoop("effects/build/cure/cure", Vector3(100, 100, 100))
    self.BuildCureAnim = item
end

--停止播放治疗动画
function BuildHospital:StopCureAnim()
    if not self.isCureAnim then
        return
    end
    self.isCureAnim = false

    self.BuildCureAnim:StopEffect()
    NodePool.Set(NodePool.KeyType.HospitalBuildCure, self.BuildCureAnim)
end

return BuildHospital
