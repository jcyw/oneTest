--[[
    Author: songzeming
    Function: 主界面UI 左上角头像
]]
local GD = _G.GD
local MainUIHead = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/mainHead", MainUIHead)

local CommonModel = import("Model/CommonModel")
local DressUpModel = import("Model/DressUpModel")
local GlobalVars = GlobalVars

function MainUIHead:ctor()
    self.fairyBatching = true
    -- self._icon = self._btnHead:GetChild("icon")
    self._anim = self:GetTransition("headEffect")
    self._ctrView = self:GetController("casetype")
    --self._groupEffect.alpha = 0
    self._barExp.value = -1
    self._barHp.value = -1
    self:AddListener(self._btnHead.onClick,
        function()
            if self.triggerFunc then
                self.triggerFunc()
            end
            if self.unBindEffect then
                self.unBindEffect:Dispose()
                self.unBindEffect = nil
            end
            TurnModel.PlayerDetails()
        end
    )
    self:AddEvent(
        EventDefines.UIPlayerExpEffectShow,
        function(rsp)
            self:ScheduleOnceFast(function()self:ShowPlayerExp(rsp)end, 1.5)
            --self:ShowPlayerExp(rsp)
        end
    )
    --玩家信息变化通知
    self:AddEvent(
        EventDefines.UIPlayerInfoExchange,
        function()
            if Model.Player.HeroLevel >= 4 then
                --引导
                Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.Level, 11500, 0)
            end
            self:Init()
        end
    )
    self:AddEvent(
        EventDefines.GetNewAchievement,
        function()
            if UnlockModel:UnlockCenter(UnlockModel.Center.Achievement) then
                CuePointModel.SubType.Player.PlayerWall.Number = 1
                CuePointModel:CheckPlayer()
            end
        end
    )

    self:AddEvent(GM_MSG_EVENT.NewMsgNotRead, function()
        CuePointModel.SubType.Player.PlayerSet.Number = UserModel:NotReadPlayerNumber()
        CuePointModel:CheckPlayer()
    end)

    self:AddEvent(GM_MSG_EVENT.MsgIsRead, function()
        CuePointModel.SubType.Player.PlayerSet.Number = UserModel:NotReadPlayerNumber()
        CuePointModel:CheckPlayer()
    end)

    self:AddEvent(DRESSUP_EVENT.ChangeDressUp, function()
        self._btnHead:SetAvatar({Avatar = Model.User.Avatar, DressUpUsing = DressUpModel.usingDressUp})
        self._ctrView.selectedIndex = self._btnHead:GetState()
    end)

    self.level = Model.Player.HeroLevel
    self.upLevel = self.level
    self:Init()

    NodePool.Init(NodePool.KeyType.PlayerPowerExpEffect, "Effect", "EffectPlayerPower")
    self:SetExpShow()
    CuePointModel:CheckPlayer(self)
end

function MainUIHead:Init()
    -- CommonModel.SetUserAvatar(self._icon)
    self._btnHead:SetAvatar({Avatar = Model.User.Avatar, DressUpUsing = DressUpModel.usingDressUp})
    self._ctrView.selectedIndex = self._btnHead:GetState()
    self._level.text = Model.Player.HeroLevel

    if Model.Player.HeroLevel > self.level then
        local upLevel = Model.Player.HeroLevel - self.level
        self.level = Model.Player.HeroLevel
        self._anim:Play()
        for _ = 1, upLevel do
            self:UpgradeBox()
        end
    end
    --经验值
    if Model.Player.HeroLevel >= Global.MaxPlayerLevel then
        self._barExp.value = 100
    else
        local conf = ConfigMgr.GetItem("configPlayerUpgrades", Model.Player.HeroLevel + 1)
        self._barExp.value = Model.Player.HeroExp / conf.exp * 100
    end
    --体力
    self._barHp.value = GD.ResAgent.GetEnergy()
    --体力刷新
    self:RefreshHp()
    --设置未绑定时特效
    if UserModel:NotReadPlayerNumber() > 0 then
        if self.unBindEffect == nil then
            -- self.unBindEffect = UIMgr:CreateObject("Effect", "EmptyNode")
            -- self.unBindEffect.xy = Vector2(5, 0)
            -- self:AddChild(self.unBindEffect)
            -- DynamicRes.GetBundle("effect_collect", function()
            --     DynamicRes.GetPrefab("effect_collect", "effect_kuang_add", function(prefab)
            --         local object = GameObject.Instantiate(prefab)
            --         self.unBindEffect:GetGGraph():SetNativeObject(GoWrapper(object))
            --     end)
            -- end)
            NodePool.Init(NodePool.KeyType.MainUIHeadEffect, "Effect", "EffectNode")
            self.unBindEffect = NodePool.Get(NodePool.KeyType.MainUIHeadEffect)
            self.unBindEffect.xy = Vector2(54, 54)
            self:AddChild(self.unBindEffect)
            self.unBindEffect:PlayDynamicEffectLoop("effect_collect", "effect_kuang_add", Vector3(130, 130, 130))
        end
    else
        if self.unBindEffect then
            self.unBindEffect:Dispose()
            self.unBindEffect = nil
        end
    end
end

--玩家升级弹窗
function MainUIHead:UpgradeBox()
    if Model.Player.HeroLevel <= Global.CommanderUpgradePopupShow then
        self.level = Model.Player.HeroLevel
        self.upLevel = self.level
        return
    end
    if not self.boxCount then
        self.boxCount = 0
    end
    if GlobalVars.IsTriggerStatus then
        self.boxCount = 0
        self.upLevel = Model.Player.HeroLevel
        return
    end

    local function box_func()
        if GlobalVars.IsTriggerStatus then
            self.boxCount = 0
            self.upLevel = Model.Player.HeroLevel
            return
        end
        local upLevel = self.upLevel + 1
        local times = Model.Player.HeroLevel - self.upLevel
        UIMgr:Open(
            "PlayerUpgradeBox",
            upLevel,
            times,
            function()
                --关闭弹窗 回调
                self.boxCount = self.boxCount - times
                if self.boxCount > 0 then
                    self.upLevel = self.upLevel + times
                    self:ScheduleOnceFast(box_func, 0.2)
                else
                    self.upLevel = Model.Player.HeroLevel
                end
            end
        )
    end

    if self.boxCount == 0 then
        self.boxCount = self.boxCount + 1
        box_func()
    else
        self.boxCount = self.boxCount + 1
    end
end

--设置经验显示
function MainUIHead:SetExpShow()
    self.exp = Model.Player.HeroExp
end
--玩家信息
function MainUIHead:ShowPlayerExp(info)
    if info.ChangedExp <= 0 then
        return
    end
    if info.Source < 1 or info.Source > 4 then
        return
    end
    --播放增加经验动画
    local _exp = NodePool.Get(NodePool.KeyType.PlayerPowerExpEffect)
    _exp.xy = Vector2(GRoot.inst.width / 2, GRoot.inst.height / 2.65)
    self.parent:AddChild(_exp)
    local values = {
        num = info.ChangedExp
    }
    _exp:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "TIPS_MAIN_EXP", values)
    local anim = _exp:GetTransition("anim")
    local ctr = _exp:GetController("Ctr")
    ctr.selectedPage = "exp"
    anim:Play(
        function()
            NodePool.Set(NodePool.KeyType.PlayerPowerExpEffect, _exp)
            Model.Player.HeroExp = info.Exp
            self:SetExpShow()
        end
    )
    --特效
    AnimationModel.PlayerExpEffect(_exp, self.parent)
end

function MainUIHead:TriggerOnclick(callback)
        self.triggerFunc = callback
end

--刷新体力
function MainUIHead:RefreshHp()
    self:UnSchedule(self.hp_func)
    if GD.ResAgent.GetEnergy() >= 100 then
        return
    end
    self.hp_func = function()
        local energy = GD.ResAgent.GetEnergy()
        self._barHp.value = energy
        if energy >= 100 then
            self:UnSchedule(self.hp_func)
        end
    end
    self:Schedule(self.hp_func, 1)
end

return MainUIHead
