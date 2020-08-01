--[[
    Author: songzeming
    Function: 靶场翻牌组件 牌背面
]]
local GD = _G.GD
local RangeFlopCardBack = fgui.extension_class(GComponent)
fgui.register_extension('ui://Casino/itemRangeCardBack', RangeFlopCardBack)

import("UI/Casino/RangeFlop/RangeFlopCard")

function RangeFlopCardBack:ctor()
    self._anim = self:GetTransition("animFlip")
    self:AddListener(self._back.onClick,function()
        self:OnBtnBackClick()
    end)
end

function RangeFlopCardBack:InitContext(ctx)
    self.ctx = ctx
end

--赌场信息
function RangeFlopCardBack:InitData(casinoData)
    self.casinoData = casinoData
end

--翻牌
function RangeFlopCardBack:InitFront(data)
    self._card:InitCard(data)
    self:SetBackVisible(false)
end

--未翻牌
function RangeFlopCardBack:InitBack(key)
    self.key = key
    self._card:SetCardVisible(false)
    self:SetBackVisible(true)
    self:SetBackTouchable(true)
end

function RangeFlopCardBack:SetBackVisible(flag)
    self._back.visible = flag
    self._card.visible = not flag
end

function RangeFlopCardBack:SetBackTouchable(flag)
    self._back.touchable = flag
end

--播放点击特效
function RangeFlopCardBack:PlayEffect()
    NodePool.Init(NodePool.KeyType.CardCilckEffect, "Effect", "EffectNode")
    local effect = NodePool.Get(NodePool.KeyType.CardCilckEffect)
    self._blank:AddChild(effect)
    effect:InitNormal()
    effect:PlayEffectLoop("effects/beauty/prefab/effect_pai_shine",Vector3(105, 100, 100))
    self:ScheduleOnceFast(function()
            NodePool.Set(NodePool.KeyType.CardCilckEffect, effect)
        end,1)
end

--点击抽奖
function RangeFlopCardBack:OnBtnBackClick()
    local count = 0 --已翻牌数量
    for _, v in pairs(self.casinoData.HyperGamblingInfo) do
        if v.Order > 0 then
            count = count + 1
        end
    end
    local spendAmount = math.floor(2 ^ (count - 1)) --消耗高级幸运币数量
    --抽奖
    local lottery_func = function()
        self:SetBackTouchable(false)
        self.ctx:SetCardTouchable(false)
        Net.Casino.HyperGamble(self.key, function(rsp)
            --奖励表现
            if rsp.Reward.Category == CommonType.RANGE_HIGH_CARD_TYPE.Resource then
                --资源
                local conf = ConfigMgr.GetItem("configItems", rsp.Reward.RewardId)
                local values = {
                    item_name = GD.ItemAgent.GetItemNameByConfId(rsp.Reward.RewardId),
                    item_num = math.floor(Tool.FormatNumberThousands(rsp.Reward.Amount) * rsp.Reward.BonusTimes)
                }
                TipUtil.TipById(50032, values, conf.icon)
            elseif rsp.Reward.Category == CommonType.RANGE_NORMAL_CARD_TYPE.Item then
                --翻倍
                local num = rsp.Reward.RewardId
                if rsp.Reward.BonusTimes ~= 1 then
                    num = rsp.Reward.RewardId + rsp.Reward.BonusTimes
                end
                local values = {
                    item_name = "",
                    item_num = math.floor(num)
                }
                TipUtil.TipById(50032, values)
            end
            --刷新数据
            self.casinoData.HyperCounts = self.casinoData.HyperCounts - spendAmount
            self._card:InitCard(rsp.Reward)

            self._anim:Play(function()
                self.ctx:SetCardTouchable(true)
                self:SetBackVisible(false)

                for k, v in ipairs(self.casinoData.HyperGamblingInfo) do
                    if v.ConfigIndex == rsp.Reward.ConfigIndex then
                        self.casinoData.HyperGamblingInfo[k] = self.casinoData.HyperGamblingInfo[rsp.Reward.ShowIndex]
                        break
                    end
                end
                self.casinoData.HyperGamblingInfo[rsp.Reward.ShowIndex] = rsp.Reward
                Event.Broadcast(EventDefines.UIRangeTurntableData, self.casinoData)
            end)
            self:PlayEffect()
        end)
    end

    if count == 0 then
        --首次免费
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_30"),
            sureBtnIcon = UITool.GetIcon(ConfigMgr.GetItem("configResourcess", Global.ResCasinoHyperCounter).img),
            itemNum = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_34"),
            sureCallback = lottery_func
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        if spendAmount > self.casinoData.HyperCounts then
            --高级幸运币不够
            local values = {
                num = spendAmount
            }
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_28", values),
                sureBtnIcon = UITool.GetIcon(ConfigMgr.GetItem("configResourcess", Global.ResCasinoHyperCounter).img),
                sureCallback = function()
                    UIMgr:Open("RangeChip", "High", self.casinoData)
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        else
            --高级幸运币足够
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_30"),
                itemNum = spendAmount,
                sureBtnIcon = UITool.GetIcon(ConfigMgr.GetItem("configResourcess", Global.ResCasinoHyperCounter).img),
                sureCallback = lottery_func
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    end
end

return RangeFlopCardBack
