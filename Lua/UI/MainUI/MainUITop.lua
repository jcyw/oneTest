--[[
    Author: songzeming
    Function: 主界面UI 上侧面板
]]
local GD = _G.GD
local MainUITop = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/mainTop", MainUITop)

local GiftModel = import("Model/GiftModel")
local VIPModel = import("Model/VIPModel")
local SOURCE = {
    BuildingUpgrade = 1,
    TrainArmy = 2,
    Tech = 3,
    CureArmy = 4,
    BuildingDestroy = 5,
    BeastUpgrade = 6,
    BeastInjured = 7,
    BeastTech = 8,
    BeastCure = 9
}
local CacheBeastPower = 0

function MainUITop:ctor()
    self.fairyBatching = true
    self._effctPower = self._btnPower:GetChild("_effect")
    self._effctPower.alpha = 0
    self._powerAnim = self._btnPower:GetTransition("effect")
    self._vipUpdateTip = self._btnVip:GetChild("_updateTip")
    self._vipController = self._btnVip:GetController("vipc")
    self._vipBtnText = self._btnVip:GetChild("text")
    self:AddListener(self._btnPower.onClick,
        function()
            UIMgr:Open("PlayerInfo/PlayerInfo")
             --local value = {}
             --value.X = 260
             --value.Y = 935
             --value.TechId = 7000200
             --Event.Broadcast(EventDefines.FalconGetTech,value)
        end
    )
    local _mainResources = self:GetChild("tagResources")
    _mainResources:InitMainUI()
    MainCity.ResourceAnimTarget = _mainResources

    self:AddEvent(
        EventDefines.UIResourcesAmount,
        function(amounts)
            local oldAmounts = GameUtil.Clone(Model.Resources)
            GD.ResAgent.Update(amounts)
            Event.Broadcast(EventDefines.UIMainResourcesAmount, amounts, oldAmounts)
        end
    )
    self:AddEvent(
        EventDefines.UIPlayerPowerEffectShow,
        function(rsp)
            self:ScheduleOnceFast(function()self:ShowPlayerPower(true, rsp)end, 1.5)
            --self:ShowPlayerPower(true, rsp)
        end
    )
    self:AddEvent(
        EventDefines.UIPlayerInfoExchange,
        function()
            self:ShowPlayerPower(false)
        end
    )

    MainCity.MainTop = self
    NodePool.Init(NodePool.KeyType.PlayerPowerExpEffect, "Effect", "EffectPlayerPower")
    self:SetPowerShow()
    self:CheckBaseRecovered()
    self:InitVip()
    CuePointModel:CheckGift(self._btnGold)
end
--设置战斗力显示
function MainUITop:SetPowerShow()
    if self.power ~= Model.Player.Power then
        self._btnPower.title = Tool.FormatNumberThousands(Model.Player.Power)
        self.power = Model.Player.Power
    end
end

--战斗力按钮上的数字，动态显示方法
function MainUITop:SetPowerAnimShow(oldPower, newPower)
    local frameValue = (newPower - oldPower) / 24
    for i = 1, 23 do
        local var = math.floor(frameValue * i) + oldPower
        self._powerAnim:SetValue("p" .. i, tostring(Tool.FormatNumberThousands(var)))
    end
    self._powerAnim:SetValue("p24", tostring(Tool.FormatNumberThousands(newPower)))
    self.power = newPower
end

--玩家信息
function MainUITop:ShowPlayerPower(isPlayEffect, info)
    if isPlayEffect then
        --播放增加战斗力动画
        if info.ChangedPower <= 0 then
            return
        end
        if Tool.Equal(info.Source, SOURCE.BuildingDestroy, SOURCE.BeastInjured) then
            return
        end
        if info.Source == SOURCE.BeastUpgrade then
            CacheBeastPower = info.ChangedPower
            return
        end
        if info.Source == SOURCE.BuildingUpgrade then
            info.ChangedPower = info.ChangedPower + CacheBeastPower
            CacheBeastPower = 0
        end
        local _power = NodePool.Get(NodePool.KeyType.PlayerPowerExpEffect)
        _power.xy = Vector2(GRoot.inst.width / 2, GRoot.inst.height / 3)
        self:AddChild(_power)
        local values = {
            num = Tool.FormatNumberThousands(info.ChangedPower)
        }
        _power:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "TIPS_MAIN_POWER", values)
        local anim = _power:GetTransition("anim")
        local ctr = _power:GetController("Ctr")
        ctr.selectedPage = "power"
        self:SetPowerAnimShow(Model.Player.Power, info.Power)
        anim:Play(
            function()
                NodePool.Set(NodePool.KeyType.PlayerPowerExpEffect, _power)
                Model.Player.Power = info.Power
                self:SetPowerShow()
                if not self._powerAnim.playing then
                    self._powerAnim:Play()
                end
            end
        )
        --特效
        AnimationModel.PlayerPowerEffect(_power, self)
    else
        -- if Model.Player.Power <= self.power then
        --     self:SetPowerShow()
        --     return
        -- end
        -- if not self._powerAnim.playing then
        --     self._powerAnim:Play()
        -- end
        self:SetPowerShow()
    end
end

--VIP
function MainUITop:InitVip()
    self._vipUpdateTip.visible = false
    self._vipBtnText.text = Model.Player.VipLevel
    self:AddListener(self._btnVip.onClick,
        function()
            Net.Vip.GetVipInfo(
                function(msg)
                    UIMgr:Open("VIPMain", msg)
                end
            )
        end
    )
    if Model.Player.VipActivated then
        self._vipController.selectedIndex = 1
        self._vipBtnText.grayed = false
    else
        self._vipController.selectedIndex = 0
        self._vipBtnText.grayed = true
        if Model.Player.VipActivated == false then
            if Model.Player.VipExpiration ~= 0 then
                if PlayerDataModel:GetDayNotTip(TipType.NOTREMIND.DayVipActive) then
                    return
                else
                    local data = {
                        parent = self,
                        content = StringUtil.GetI18n(I18nType.Commmon, "Vip_Login_Activate"),
                        sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO"),
                        onlineType = TipType.NOTREMIND.T_TipVipActive,
                        dayType = TipType.NOTREMIND.DayVipActive,
                        sureCallback = function()
                            Net.Vip.GetVipInfo(
                                function(msg)
                                    UIMgr:Open("VIPMain", msg)
                                end
                            )
                        end
                    }
                    PopupWindowQueue:Push("ConfirmPopupText", data)
                end
            end
        end
    end

    if VIPModel.ItemEnoughToUpgrade({VipLevel = Model.Player.VipLevel, VipPoints = Model.Player.VipPoints}) then
        self._vipUpdateTip.visible = true
    end

    self:AddEvent(
        EventDefines.UIVipInfo,
        function(rsp)
            self._vipBtnText.text = rsp.VipLevel
            if rsp.VipIsActivated == true then
                self._vipController.selectedIndex = 1
                self._vipBtnText.grayed = false
            else
                self._vipController.selectedIndex = 0
                self._vipBtnText.grayed = true
            end
            if VIPModel.ItemEnoughToUpgrade(rsp) then
                self._vipUpdateTip.visible = true
            else
                self._vipUpdateTip.visible = false
            end
        end
    )
    self:AddEvent(
        EventDefines.RefreshVipUpgradeTip,
        function()
            if VIPModel.ItemEnoughToUpgrade({VipLevel = Model.Player.VipLevel, VipPoints = Model.Player.VipPoints}) then
                self._vipUpdateTip.visible = true
            else
                self._vipUpdateTip.visible = false
            end
        end
    )
end
--该提示为优先级最高
function MainUITop:CheckBaseRecovered()
    if Model.Player.BaseRecovered then
        local data = {
            parent = self,
            content = StringUtil.GetI18n(I18nType.Commmon, "TIPS_RECYCLE_BASE"),
            sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES"),
        }
        PopupWindowQueue:Push("ConfirmPopupText", data)
    end
end

return MainUITop
