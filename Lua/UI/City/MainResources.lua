--[[
    Author: songzeming
    Function: 主界面最上面 资源数量显示和刷新 通用
]]
local MainResources = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/tagResources", MainResources)

local BuildModel = import("Model/BuildModel")
import("UI/City/ItemResources")

function MainResources:ctor()
    self:SetResources()
    self:AddEvent(
        EventDefines.UIMainResourcesAmount,
        function(amounts, oldAmounts)
            self:SetResLabelAnim(amounts, oldAmounts)
            self:SetResources()
        end
    )
    self:AddEvent(
        EventDefines.UIResourcesAnim,
        function(obj)
            self:AddChild(obj)
        end
    )

    NodePool.Init(NodePool.KeyType.ReceiveAwardLabel, "Effect", "EffectResLabel")

    self.listPosX = self._list.x
    self._list.x = self.listPosX + 30
end

function MainResources:InitMainUI()
    self.isMainUI = true
    self._list.x = self.listPosX + 10
end

function MainResources:InitMS()
    self.isMS = true
end

function MainResources:Check()
    local centerLv = BuildModel.GetCenterLevel()
    if centerLv == self.centerLv then
        return
    end
    self.centerLv = centerLv
    self.unlockTable = {}
    for _, v in ipairs(Global.ResUnlockLevel) do
        if centerLv >= v.level then
            table.insert(self.unlockTable, v.category)
        end
    end
    self._list.numItems = #self.unlockTable
end

function MainResources:SetResources()
    self:Check()
    for i = 1, self._list.numChildren do
        self._list:GetChildAt(i - 1):Init(self.unlockTable[i])
    end
end

function MainResources:SetResLabelAnim(amounts, oldAmounts)
    if self.isMainUI or self.isMS then
        for _, v in pairs(amounts) do
            local exgAmount = v.Amount - oldAmounts[v.Category].Amount
            if exgAmount ~= 0 and v.Category <= 4 then
                local label = NodePool.Get(NodePool.KeyType.ReceiveAwardLabel)
                self.parent:AddChild(label)
                label.x = (190 + (CommonType.SORT_RESOURCES[v.Category] - 1) * 120)
                if exgAmount > 0 then
                    --增加资源
                    label.y = 110
                    label.title = "+" .. Tool.FormatNumberThousands(exgAmount)
                    label:GetTransition("animAdd"):Play(
                        function()
                            NodePool.Set(NodePool.KeyType.ReceiveAwardLabel, label)
                        end
                    )
                else
                    --消耗资源
                    label.y = 70
                    label.title = "-" .. Tool.FormatNumberThousands(math.abs(exgAmount))
                    label:GetTransition("animDel"):Play(
                        function()
                            NodePool.Set(NodePool.KeyType.ReceiveAwardLabel, label)
                        end
                    )
                end
            end
        end
    end
    
end

function MainResources:GetResItemPos(category)
    for i=1, self._list.numChildren do
        local item = self._list:GetChildAt(i-1)
        if item.category == category then
            return item:LocalToGlobal(Vector2.zero)
        end
    end
end

return MainResources
