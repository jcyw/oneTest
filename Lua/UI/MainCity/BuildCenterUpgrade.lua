--[[
    Author: songzeming
    Function: 指挥中心升级弹窗
]]
local BuildCenterUpgrade = UIMgr:NewUI("BuildCenterUpgrade")

function BuildCenterUpgrade:OnInit()
    self.view = self.Controller.contentPane
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnReceive.onClick,
        function()
            self:Close()
        end
    )
    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.BuildCenterUpgrade)

    self.IgnoreClose = true -- 屏蔽快捷关闭

    NodePool.Init(NodePool.KeyType.ItemPropBig, "Common", "itemPropBig")
    NodePool.Init(NodePool.KeyType.BaseUpgradeEffect, "Effect", "EffectNode")
    NodePool.Init(NodePool.KeyType.BaseUpgradeEffect .. "Num", "Effect", "EffectNode")
end

--飞机特效
function BuildCenterUpgrade:FlyPlane()
    self:SetVisible(false)
    self._flyStart.visible = true
    if self._flyEffectCB then
        self._flyEffectCB()
    end
    local planeEffect = NodePool.Get(NodePool.KeyType.BaseUpgradeEffect)
    local numEffect = NodePool.Get(NodePool.KeyType.BaseUpgradeEffect .. "Num")
    planeEffect.xy = self._flyStart.xy
    numEffect.xy = self._numEffect.xy
    GTween.Kill(planeEffect)
    self._flyStart:AddChild(planeEffect)
    self._numEffect:AddChild(numEffect)
    self._flyEffectCB = function()
        NodePool.Set(NodePool.KeyType.BaseUpgradeEffect, planeEffect)
        NodePool.Set(NodePool.KeyType.BaseUpgradeEffect .. "Num", numEffect)
    end
    planeEffect:InitNormal()
    numEffect:InitNormal()
    planeEffect:PlayEffectLoop("effects/baseupgrade/prefab/effect_base_upgrade")
    numEffect:PlayEffectSingle("effects/baseupgrade/prefab/effect_base_upgrade2")
    local particles = planeEffect.displayObject.gameObject:GetComponentsInChildren(typeof(CS.UnityEngine.ParticleSystem))
    for i = 0, particles.Length - 1 do
        particles[i]:Stop()
        particles[i]:Play()
    end
    planeEffect:TweenMove(self._flyEnd.xy, 3):SetEase(EaseType.Linear)
    --弹窗出现
    self:ScheduleOnceFast(
        function()
            AnimationLayer.PanelScaleOpenAnim(self, function()
                self:OnOpen()
            end)
        end,
        0.8
    )
end

function BuildCenterUpgrade:OnOpen()
    self.addLevel = self.addLevel + 1
    self:SetVisible(true)
    self._level.text = self.level
    self._force.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_MTR_Power") .. Tool.FormatNumberThousands(Model.Player.Power)
    self:PlayRewardAnim(true)

    if self.addLevel < self.times then
        Net.Buildings.GetCenterUpgradeGift(self.level)
        self:GtweenOnComplete(self.view:TweenFade(1, 1.2),function()
            self:SetVisible(false)
            self:PlayRewardAnim(false, true)
        end)
    else
        Event.Broadcast(EventDefines.UpgradeMask, false)
    end
end

function BuildCenterUpgrade:DoOpenAnim(args)
    Event.Broadcast(EventDefines.UpgradeMask, true)
    self.level = args.level
    self.times = args.times
    local conf = ConfigMgr.GetItem("configBuildings", Global.BuildingCenter)
    if self.level + self.times - 1 > conf.max_level then
        self.times = conf.max_level - self.level
    end
    self.addLevel = 0
    self:FlyPlane()
end

function BuildCenterUpgrade:Close()
    --向服务器请求领奖
    Net.Buildings.GetCenterUpgradeGift(self.level)
    self:SetVisible(false)
    self:PlayRewardAnim(false)
end

function BuildCenterUpgrade:OnClose()
    if self._flyEffectCB then
        self._flyEffectCB()
    end
    Event.Broadcast(EventDefines.UpgradeMask, false)
end

--设置界面显示
function BuildCenterUpgrade:SetVisible(flag)
    for i = 1, self.view.numChildren do
        self.view:GetChildAt(i - 1).visible = flag
    end
    if flag then
        self._btnClose.visible = false
    else
        self._blank.visible = true
    end
end

--刷新界面动画
function BuildCenterUpgrade:RefreshAnim()
    if self._flyEffectCB then
        self._flyEffectCB()
    end
    self:ScheduleOnceFast(
        function()
            self:GtweenOnComplete(self.view:TweenFade(1, 0.2),function()
                self.level = self.level + 1
                self:FlyPlane()
            end)
        end,
        0.2
    )
end

--奖励动画
function BuildCenterUpgrade:PlayRewardAnim(flag, isRepeat)
    if flag then
        --打开动画
        local buildConf = ConfigMgr.GetItem("configBuildingUpgrades", Global.BuildingCenter + self.level)
        local giftConf = ConfigMgr.GetItem("configGifts", buildConf.gift)
        UITool.SetRewardAnim(self._blank, giftConf.items, 50, 0)
    else
        --关闭动画
        UITool.PlayRewardAinm(
            self._blank,
            function()
                if isRepeat then
                    self:RefreshAnim()
                else
                    if self._flyEffectCB then
                        self._flyEffectCB()
                    end
                    UIMgr:Close("BuildCenterUpgrade")
                end
            end,
            50,
            20
        )
    end
end

return BuildCenterUpgrade
