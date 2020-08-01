--[[
    author:Temmie
    time:2019-12-14 14:44:32
    function:礼品使用后获得物品弹窗
]]
local GD = _G.GD
local UIMgr = _G.UIMgr
local BackpackPopup = _G.UIMgr:NewUI("BackpackPopup")

local NodePool = _G.NodePool
local Global = _G.Global
local ConfigMgr = _G.ConfigMgr
local Event = _G.Event
local EventDefines = _G.EventDefines
local Tool = _G.Tool
local I18nType = _G.I18nType

function BackpackPopup:OnInit()
    NodePool.Init(NodePool.KeyType.BackpackPopupEffect, "Effect", "EffectNode")

    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("BackpackPopup")
            if self.triggerFunc then
                -- Event.Broadcast(EventDefines.TriggerGuideShow, true)
                self.triggerFunc()
            end
        end
    )

    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("BackpackPopup")
            if self.triggerFunc then
                -- Event.Broadcast(EventDefines.TriggerGuideShow, true)
                self.triggerFunc()
            end
        end
    )
end

function BackpackPopup:OnOpen(list, effectFlag)
    self._list:RemoveChildrenToPool()
    for _, v in pairs(list) do
        local item = self._list:AddItemFromPool()

        if v.Category == Global.RewardTypeRes then
            local resConfig = ConfigMgr.GetItem("configResourcess", v.ConfId)
            item:SetAmount(resConfig.img,
                resConfig.color,
                Tool.FormatNumberThousands(v.Amount),
                ConfigMgr.GetI18n(I18nType.Commmon, resConfig.key)
            )
        else
            local itemConfig = ConfigMgr.GetItem("configItems", v.ConfId)
            item:SetAmount(itemConfig.icon,
                itemConfig.color,
                Tool.FormatNumberThousands(v.Amount),
                GD.ItemAgent.GetItemNameByConfId(v.ConfId),
                GD.ItemAgent.GetItemInnerContent(v.ConfId)
            )
        end
    end

    if effectFlag then
        local effect = NodePool.Get(NodePool.KeyType.BackpackPopupEffect)
        self.Controller.contentPane:AddChild(effect)
        effect:InitNormal()
        effect:PlayEffectSingle("effects/backpack/itemget/prefab/effect_item_get", function()
            NodePool.Set(NodePool.KeyType.BackpackPopupEffect, effect)
        end)
    end
end

function BackpackPopup:TriggerOnclick(callback)
        self.triggerFunc = callback
end

function BackpackPopup:OnClose()
    Event.Broadcast(EventDefines.NextNoviceStep,1013)
end

return BackpackPopup
