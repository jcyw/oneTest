--author: 	Amu
--time:		2019-09-03 17:48:50

local MilitarySuppliesNum = fgui.extension_class(GButton)
fgui.register_extension("ui://Number/MilitarySuppliesNum", MilitarySuppliesNum)

local Supply = {}
local SupplyDouble = {}

function MilitarySuppliesNum:ctor()
end

function MilitarySuppliesNum:SetData(info,cb)
    self.cb = cb
    self.numRatio = info.numRatio
    self._number.text = "+"..Tool.FormatNumberThousands(info.num)

    if self.effect_func then
        self:UnScheduleFast(self.effect_func)
    end

    self:PlaySupplyEffect()
    if info.numRatio >= 2 then
        self._multiple.text = "x"..info.numRatio
        self.effect_func = function()
            self.effect_func = nil
            self:PlaySupplyDoubleEffect()
        end
        self:ScheduleOnceFast(self.effect_func, 1)
    end
end

function MilitarySuppliesNum:PlaySupplyEffect()
    NodePool.Init(NodePool.KeyType.SupplyEffect, "Effect", "EffectNode")
    local effect = NodePool.Get(NodePool.KeyType.SupplyEffect)
    effect.xy = Vector2(118, 38)
    self:AddChild(effect)
    table.insert(Supply, effect)
    effect:PlayDynamicEffectSingle("effect_collect", "effect_buji_general", function()
        if effect then
            NodePool.Set(NodePool.KeyType.SupplyEffect, effect)
        end
        table.removeItem(Supply, effect)
        if self.numRatio<2 and self.cb then
            self.cb()
            self.cb = nil
        end
    end, Vector3(100, 100, 100))
end

function MilitarySuppliesNum:PlaySupplyDoubleEffect()
    NodePool.Init(NodePool.KeyType.SupplyDoubleEffect, "Effect", "EffectNode")
    local effect = NodePool.Get(NodePool.KeyType.SupplyDoubleEffect)
    effect.xy = Vector2(307, 154)
    self:AddChild(effect)
    table.insert(SupplyDouble, effect)
    effect:PlayDynamicEffectSingle("effect_collect", "effect_buji_crit", function()
        NodePool.Set(NodePool.KeyType.SupplyDoubleEffect, effect)
        table.removeItem(SupplyDouble, effect)
        if self.cb then
            self.cb()
            self.cb = nil
        end
    end, Vector3(100, 100, 100))
end

function MilitarySuppliesNum:ClearSupplyEffect()
    for _, v in pairs(Supply) do
        v:Dispose()
    end
    NodePool.Remove(NodePool.KeyType.SupplyEffect)
    Supply = {}
end
function MilitarySuppliesNum:ClearSupplyDoubleEffect()
    for _, v in pairs(SupplyDouble) do
        v:Dispose()
    end
    NodePool.Remove(NodePool.KeyType.SupplyDoubleEffect)
    SupplyDouble = {}
end

function MilitarySuppliesNum:Clear()
    if self.effect_func then
        self:UnSchedule(self.effect_func)
    end
    self:ClearSupplyEffect()
    self:ClearSupplyDoubleEffect()
end

return MilitarySuppliesNum
