--[[
    Author: songzeming
    Function: 玩家升级弹窗
]]
local GD = _G.GD
local PlayerUpgradeBox = UIMgr:NewUI("PlayerUpgradeBox")

import("UI/Common/ItemPropBig")

function PlayerUpgradeBox:OnInit()
    local view = self.Controller.contentPane
    self._anim = view:GetTransition("Animation")
    local _textIntegral = view:GetChild("textIntegral")
    local _intergralCtrl = _textIntegral:GetController("c1")
    _intergralCtrl.selectedIndex = 0
    local _integraltext = _textIntegral:GetChild("_textIntegral")
    _integraltext.text = StringUtil.GetI18n(I18nType.Commmon, "AWARD_TITLE")

    self:AddListener(self._mask.onClick,
        function()
            self:PlayRewardEffect(tonumber(self._level.text),false)
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:PlayRewardEffect(tonumber(self._level.text),false)
        end
    )
    self:AddListener(self._btnShare.onClick,
        function()
            TipUtil.TipById(50259)
        end
    )
    self._btnReward.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_REWARD")
    self:AddListener(self._btnReward.onClick,
        function()
            self:PlayRewardEffect(tonumber(self._level.text),false)
        end
    )
    self.ScreenAdp(view)
    NodePool.Init(NodePool.KeyType.ItemPropBig, "Common", "itemPropBig")
end

---ui适配
function PlayerUpgradeBox.ScreenAdp(item)
    local scaleValue =(_G.Screen.height/_G.Screen.width)/(1334/750)
    if scaleValue >= 1 then
        return
    end
    item.scale = _G.Vector2(scaleValue,scaleValue)
    item.x = item.x + item.width*(1-scaleValue)*0.5
    item.y = item.y + item.height*(1-scaleValue)*0.5
end
function PlayerUpgradeBox:OnOpen(level)
    if not self.opening then
        self.opening = true
    end
    Event.Broadcast(EventDefines.UpgradeMask, true)
    self.addLevel = self.addLevel + 1
    if self.addLevel ~= 1 then
        self._anim:SetValue("blankAlpha", 1)
    else
        self._anim:SetValue("blankAlpha", 0)
    end
    self._groupBg.visible = true
    self._groupContent.visible = true
    self._anim:Play(
        function()
            self:PlayRewardEffect(level,true)
            if self.addLevel < self.times then
                self:GtweenOnComplete(self.Controller.contentPane:TweenFade(1, 0.2),function()
                    self:PlayRewardEffect(level + 1,false,true)
                end)
            else
                Event.Broadcast(EventDefines.UpgradeMask, false)
            end
        end
    )
end

function PlayerUpgradeBox:DoOpenAnim(level, times, cb)
    self.times = times
    self.cb = cb
    self.addLevel = 0
    self:RefreshData(level)
    self._groupBg.visible = false
    self._groupContent.visible = false
    AnimationLayer.PanelScaleOpenAnim(self, function()
        if self.opening then
            self._groupBg.visible = true
            self._groupContent.visible = true
            self:PlayRewardEffect(level,false,true)
        else
            self:OnOpen(level)
        end
    end)
end
function PlayerUpgradeBox:DoCloseAnim()
    AnimationLayer.PanelScaleCloseAnim(self)
end

function PlayerUpgradeBox:RefreshData(level)
    if level <= 1 then
        self.opening = false
        UIMgr:Close("PlayerUpgradeBox")
        return
    end
    self._level.text = level
    local conf = ConfigMgr.GetItem("configPlayerUpgrades", level)
    local confLast = ConfigMgr.GetItem("configPlayerUpgrades", level - 1)
    self._power.text = "+" .. Tool.FormatNumberThousands(conf.power - confLast.power)
    self._skill.text = "+" .. (conf.giftpoint - confLast.giftpoint)
    self:PlayEffect()
    self:PlayeTitleEffect()
end

function PlayerUpgradeBox:PlayEffect()
    if self.effect then
        return
    end
    self.effect = true
    CSCoroutine.Start(
        function()
            local resPath = "effects/player/playerupgradefire/prefab/fire"
            coroutine.yield(ResMgr.Instance:LoadPrefab(resPath))
            local prefab = ResMgr.Instance:GetPrefab(resPath)
            local object = GameObject.Instantiate(prefab)
            local wrapper = GoWrapper(object)
            self._graph.asGraph:SetNativeObject(wrapper)
        end
    )
end

function PlayerUpgradeBox:PlayeTitleEffect()
    if self.titleEffect then
        NodePool.Set(NodePool.KeyType.PlayerUpgradeBoxTitleEffect, self.titleEffect)
    else
        NodePool.Init(NodePool.KeyType.PlayerUpgradeBoxTitleEffect, "Effect", "EffectNode")
    end
    self.titleEffect = NodePool.Get(NodePool.KeyType.PlayerUpgradeBoxTitleEffect)
    self._effectNode:AddChild(self.titleEffect)
    self.titleEffect:InitNormal()
    self.titleEffect:PlayEffectLoop("effects/player/playerupgrade/prefab/effect_player_levelup")
end

function PlayerUpgradeBox:OnClose()
    Event.Broadcast(EventDefines.UpgradeMask, false)
    self._anim:Stop()
    if self.cb then
        self.cb()
    end
end

function PlayerUpgradeBox:Close()
    self.opening = false
    if self.titleEffect then
        NodePool.Set(NodePool.KeyType.PlayerUpgradeBoxTitleEffect, self.titleEffect)
    end
    UIMgr:Close("PlayerUpgradeBox")
end

--领奖特效
function PlayerUpgradeBox:PlayRewardEffect(level,flag,isRepeat)
    if flag then
        --打开动画
        local conf = ConfigMgr.GetItem("configPlayerUpgrades", level)
        local items = ConfigMgr.GetItem("configGifts", conf.reward).items
        UITool.SetRewardAnim(self._blank,items,50,20)
    else
        --关闭动画
        UITool.PlayRewardAinm(self._blank,function()
            if isRepeat then
                self:RefreshData(level)
                self:OnOpen(level)
            else
                self.opening = false
                UIMgr:Close("PlayerUpgradeBox")
            end
        end,50,20)
    end
end

return PlayerUpgradeBox
