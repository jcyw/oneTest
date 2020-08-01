--[[
    Author: songzeming
    Function: 领奖动画 加遮罩 通用界面
]]
local GD = _G.GD
local EffectRewardMask = UIMgr:NewUI("EffectRewardMask")

import("UI/Effect/EffectNode")

function EffectRewardMask:OnInit()
    NodePool.Init(NodePool.KeyType.OnlineRewardEffect, "Effect", "EffectNode")
end

function EffectRewardMask:OnOpen(from, ...)
    self.args = {...}
    if from == CommonType.REWARD_TYPE.OnlineReward then
        --在线奖励
        self:PlayOnlineRewardAnim()
    elseif from == CommonType.REWARD_TYPE.GetEquipMaterial then
        self:PlayGetEquipMaterialAnim()
    end
end

function EffectRewardMask:Close()
    UIMgr:Close("EffectRewardMask")
end

--播放在线奖励领奖动画
function EffectRewardMask:PlayOnlineRewardAnim()
    local mBouns = Model.GetMap(ModelType.CutOnlineBouns)
    if not mBouns then
        self:Close()
        return
    end

    local item = NodePool.Get(NodePool.KeyType.OnlineRewardEffect)
    item.xy = Vector2(GRoot.inst.width / 2, GRoot.inst.height / 2)
    self.Controller.contentPane:AddChild(item)

    local conf = ConfigMgr.GetItem("configItems", mBouns.ConfId)
    local icon = UITool.GetIcon(conf.icon, item:GetIconLoader())
    local amountMid = GD.ItemAgent.GetItemInnerContent(mBouns.ConfId)
    if not amountMid then
        item:InitIcon(icon, mBouns.Amount)
    else
        item:IconMiddle(icon, mBouns.Amount, amountMid, conf.color)
    end
    item:PlayEffectSingle("effects/reward/rewardonline/prefab/effect_online_reward")
    item:PlayOnlineRewardAnim(function()
        self:Close()
    end)
end

function EffectRewardMask:PlayGetEquipMaterialAnim()
    local item = NodePool.Get(NodePool.KeyType.OnlineRewardEffect)
    item.xy = Vector2(GRoot.inst.width / 2, GRoot.inst.height / 2)
    self.Controller.contentPane:AddChild(item)

    local conf = EquipModel.GetMaterialByQualityId(self.args[1])
    local icon = UITool.GetIcon(conf.icon, item:GetIconLoader())
    item:InitIcon(icon)
    item:PlayEffectSingle("effects/reward/rewardonline/prefab/effect_online_reward")
    item:PlayOnlineRewardAnim(function()
        if self.args[2] then
            self.args[2]()
        end
        self:Close()
    end)
end

return EffectRewardMask
