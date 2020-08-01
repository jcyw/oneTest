--[[
	author : zixiao
	time : 2019-11-20 09:49:21
	function : 每日签到
]] --
local GD = _G.GD
local DailyAttendance = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/DailyAttendance", DailyAttendance)
local WelfareModel = import("Model/WelfareModel")
local UIType = _G.GD.GameEnum.UIType
local ItemState = {
    Awarded = 0,
    NotGet = 1,
    CanGet = 2
}

function DailyAttendance:ctor()
    self._textTitleName = self:GetChild("titleName")
    self._btnHelp = self:GetChild("btnHelp")
    self._textIntegral = self:GetChild("text")
    self._btnGoods = self:GetChild("btnGoods")
    self._c1Controller = self:GetController("c1")
    self._btnItems = {}
    for i = 1, 7 do
        local btn = self:GetChild("item" .. i)
        self._btnItems[i] = btn
        self:AddListener(self._btnItems[i].onTouchBegin,
            function()
                if self.infos then
                    local info = self.infos.Infos[i]
                    local icon = self._btnItems[i]._icon
                    local title = GD.ItemAgent.GetItemNameByConfId(info.Bonus.ConfId) .. "X" .. info.Bonus.Amount
                    self.detailPop:OnShowUI(title, GD.ItemAgent.GetItemDescByConfId(info.Bonus.ConfId), icon, false)
                end
            end
        )
        self:AddListener(self._btnItems[i].onTouchEnd,
            function()
                self.detailPop:OnHidePopup()
            end
        )
        self:AddListener(self._btnItems[i].onRollOut,function()
            self.detailPop:OnHidePopup()
        end)
    end
    self:GetChild("titleName").icon = UITool.GetIcon(StringUtil.GetI18n(I18nType.WordArt, "2001"))
    self:AddListener(self._btnHelp.onClick,
        function()
            self.dGuild:SetShow(false)
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "UI_DAILY_MATERIAL"),
                info = StringUtil.GetI18n(I18nType.Commmon, "DAILY_MATERIAL_EXPLAIN")
            }
            UIMgr:Open("ConfirmPopupTextCentered", data)
        end
    )
    self:AddListener(self._btnGoods.onClick,
        function()
            self.dGuild:SetShow(false)
            if self.infos and not self.infos.Signed then
                local rewards = {}
                for _, v in ipairs(self.infos.Infos) do
                    if not v.Signed then
                        local reward = {
                            Category = Global.RewardTypeItem,
                            ConfId = v.Bonus.ConfId,
                            Amount = v.Bonus.Amount
                        }
                        table.insert(rewards, reward)
                        break
                    end
                end
                WelfareModel.DailySign(
                    function(infos)
                        UITool.ShowReward(rewards)
                        self.infos = infos
                        self:RefreshItemAndProgress()

                        --刷新红点
                        Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.DailySign.Id, -1)
                    end
                )
            end
        end
    )
    self._textTitleName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_EVERYDAY_REWARD")
    self._btnGoods.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_RECEIVE_MATERIAL")
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
    if WelfareModel.IsActivityOpen(WelfareModel.WelfarePageType.DAILY_ATTENDANCE) then
        self:RequestInfo()
    end
    self:SetGuild()
    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.WelfareDailyAttendance)
    self:AddEvent(
        EventDefines.RefreshDailyAttend,
        function()
            if self.visible then
                self:RequestInfo()
            end
        end
    )
end

function DailyAttendance:OnOpen(index)
    self:SetShow(true)
    -- if not self.infos then
        -- self:RequestInfo()
    -- end
    self:RequestInfo()
    self:RefreshItemAndProgress()
    self:PlayAnim()
    if Language.Current() == Language.ChineseSimplified then
        self._c1Controller.selectedIndex = 0
    elseif Language.Current() == Language.ChineseTraditional then
        self._c1Controller.selectedIndex = 1
    else
        self._c1Controller.selectedIndex = 2
    end
end

function DailyAttendance:RequestInfo()
    WelfareModel.GetDailySignInfos(
        function(rsp)
            self.infos = WelfareModel.GetActivityInfoByID(WelfareModel.WelfarePageType.DAILY_ATTENDANCE)
            self:RefreshItemAndProgress()
        end
    )
end

function DailyAttendance:RefreshItemAndProgress()
    if not self.infos then
        return
    end
    local infos = self.infos.Infos
    local signed = self.infos.Signed
    local currDay = 0
    for i = 1, 7 do
        local info = infos[i]
        self._btnItems[i]:SetData(info)
        if info.Signed then
            self._btnItems[i]:SetState(ItemState.Awarded)
            currDay = currDay + 1
        else
            if not signed then
                self._btnItems[i]:SetState(ItemState.CanGet)
                signed = true
            else
                self._btnItems[i]:SetState(ItemState.NotGet)
            end
        end
    end

    self._textIntegral.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RECEIVED_NUMBER", {num = currDay})
    self._btnGoods.grayed = self.infos.Signed
end

function DailyAttendance:SetShow(isShow)
    self.visible = isShow
    self:PlayEffect()
    if self.visible == false then
        self.dGuild:SetShow(false)
        if self.effect then
            NodePool.Set(NodePool.KeyType.SevenDaySignInEffect .. "main", self.effect)
        end
    end
end

function DailyAttendance:GuildShow()
    if self.infos and not self.infos.Signed then
        return self._btnGoods
    end
end
function DailyAttendance:SetGuild()
    self.dGuild = UIMgr:CreateObject("Common", "Guide")
    self._btnGoods:AddChild(self.dGuild)
    self.dGuild:SetPivot(1, 1)
    self.dGuild:SetXY(60, -75)
    self.dGuild:SetShow(false)
    self:AddEvent(
        EventDefines.GuideDailyShow,
        function()
            self:ScheduleOnceFast(
                function()
                    if self._btnGoods.grayed == false then
                        self.dGuild:SetShow(true)
                        self.dGuild:PlayLoop()
                    end
                end,
                0.2
            )
        end
    )
end

function DailyAttendance:PlayAnim()
    for i = 1, 7 do
        local item = self._btnItems[i]
        GTween.Kill(item)
        item.pivot = Vector2(0.5, 0.5)
        item.scale = Vector2.zero
        self:GtweenOnComplete(item:TweenScaleX(0, 0.1 * i),function()
            self:GtweenOnComplete(item:TweenScale(Vector2(1.05, 1.05), 0.1):SetEase(EaseType.CubicOut),function()
                item:TweenScale(Vector2(1, 1), 0.1):SetEase(EaseType.CubicOut)
            end)
        end)
    end
end

function DailyAttendance:PlayEffect()
    if self.effect then
        NodePool.Set(NodePool.KeyType.SevenDaySignInEffect .. "main", self.effect)
    end
    NodePool.Init(NodePool.KeyType.SevenDaySignInEffect .. "main", "Effect", "EffectNode")
    self.effect = NodePool.Get(NodePool.KeyType.SevenDaySignInEffect .. "main")
    self:AddChild(self.effect)
    local posx, posy = MathUtil.ScreenRatio(Screen.width, Screen.height)
    self.effect.xy = Vector2(posx / 2, posy / 2)
    self.effect:PlayEffectLoop("effects/signineffect/prefab/effect_qirijiangli_huoxing", Vector3(100, 100, 1))
end

return DailyAttendance
