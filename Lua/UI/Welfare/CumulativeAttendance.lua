--[[
	author : maxiaolong
	time : 2019-11-20 09:50:15
	function : 新手签到
]] --
local CumulativeAttendance = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/CumulativeAttendance", CumulativeAttendance)
local WelfareModel = import("Model/WelfareModel")
local ItemState = {
    Awarded = 0,
    NotGet = 2,
    CanGet = 1
}

function CumulativeAttendance:ctor()
    self._textNoticeTitle = self:GetChild("textName")
    self._textNoticeDesc = self:GetChild("textDescribe")
    self._bgGrayDown = self:GetChild("bgGrayDown")
    self._textTitle = self:GetChild("titleName")
    self._textIntegral = self:GetChild("textIntegral")
    self._btnHelp = self:GetChild("btnHelp")
    self._btnGet = self:GetChild("btnGet")
    -- self._textTitle.text = StringUtil.GetI18n(I18nType.Activitys, "CHARGEACTIVITY_TITLE12")
    self._btnGet.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_RECEIVE_MATERIAL")
    self._textNoticeTitle.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Meeting_Gift")
    self._textNoticeDesc.text = StringUtil.GetI18n(I18nType.Commmon, "Meeting_Gift_EXPLAIN")
    self:InitEvent()
    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.WelfareRookieSign)
end

function CumulativeAttendance:InitEvent()
    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "UI_Meeting_Gift"),
                info = StringUtil.GetI18n(I18nType.Commmon, "Meeting_Gift_EXPLAIN")
            }
            UIMgr:Open("ConfirmPopupTextCentered", data)
        end
    )

    self:AddListener(self._btnGet.onClick,
        function()
            if not self.canSign then
                return
            end
            local rewards = {}

            for _, v in ipairs(self.infos) do
                if not v.Signed then
                    local _, items = WelfareModel:GetGiftInfoById(v.Bonus.ConfId, 2)
                    for _, v in ipairs(items) do
                        local reward = {
                            Category = Global.RewardTypeItem,
                            ConfId = v[1].id,
                            Amount = v[2]
                        }
                        table.insert(rewards, reward)
                    end
                    break
                end
            end
            WelfareModel.RookieSign(
                function(datas)
                    UITool.ShowReward(rewards)
                    self.infos = datas.Infos
                    self.canSign = datas.CanSign
                    self:RefreshWindow()

                    --刷新红点
                    Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.RookieSign.Id, -1)
                end
            )
        end
    )

    self.awardBtn = {}
    local t = ConfigMgr.GetList("configRookieSigns")
    for i = 1, 7 do
        local btn = self:GetChild("Box" .. i)
        btn:SetName(StringUtil.GetI18n(I18nType.Commmon, "ROAD_GROWTH_DAYS", {num = i}))
        -- btn:SetType(true)
        -- btn:SetState(false)
        if i == 7 then
            btn:SetC2Controller(1)
            btn.x = btn.x + btn.width / 2 + 5
        else
            btn:SetC2Controller(0)
        end
        btn:SetData(t[i])
        self.awardBtn[i] = btn
    end

    if WelfareModel.IsActivityOpen(WelfareModel.WelfarePageType.CUMULATIVE_ATTENDANCE) then
        self:RequestInfo()
    end

    self:AddEvent(
        TIME_REFRESH_EVENT.Refresh,
        function()
            if self.visible then
                self:RequestInfo()
            end
        end
    )
    self:AddEvent(
        EventDefines.RefreshDailyCumA,
        function()
            if self.visible then
                self:RequestInfo()
            end
        end
    )
    self:ScreenAdp();
end

function CumulativeAttendance:ScreenAdp()
    local scaleValue =_G.Screen.height/_G.Screen.width
    if scaleValue <= 1.66667 then
        self._textNoticeTitle.visible = false
        self._textNoticeDesc.visible = false
        self._bgGrayDown.visible = false
    end
end

function CumulativeAttendance:OnOpen(index)
    -- if not self.infos then
    --     self:RequestInfo()
    -- end
    self:RequestInfo()
    self:SetShow(true)
    self:RefreshWindow()
    self:PlayAnim()
end

function CumulativeAttendance:RequestInfo(...)
    WelfareModel.GetRookieSignInfos(
        function(rsp)
            self.infos = rsp.Infos or {}
            self.canSign = rsp.CanSign
            if self.visible then
                self:RefreshWindow()
            end
        end
    )
end

function CumulativeAttendance:SetShow(isShow)
    self.visible = isShow
end

function CumulativeAttendance:RefreshWindow()
    if not self.infos or not next(self.infos) then
        return
    end
    local totalNum = 0
    local signed = self.canSign
    for i, info in ipairs(self.infos) do
        -- self.awardBtn[i]:SetState(info.Signed)
        if info.Signed then
            self.awardBtn[i]:SetState(ItemState.Awarded)
            totalNum = totalNum + 1
        else
            if not signed then
                self.awardBtn[i]:SetState(ItemState.NotGet)
            else
                self.awardBtn[i]:SetState(ItemState.CanGet)
                signed = false
            end
        end
    end
    self._btnGet.grayed = not self.canSign
    --self._textIntegral.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RECEIVED_NUMBER", {num = totalNum})
    local intergralCtrl = self._textIntegral:GetController("c1")
    intergralCtrl.selectedIndex = 1
    local integraltext = self._textIntegral:GetChild("_textIntegral")
    integraltext.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RECEIVED_NUMBER", {num = totalNum})
end

function CumulativeAttendance:PlayAnim()
    for i = 1, 7 do
        local item = self.awardBtn[i]
        GTween.Kill(item)
        item.pivot = Vector2(0.5, 0.5)
        item.scale = Vector2.zero
        self:GtweenOnComplete(item:TweenScaleX(0, 0.05 * i),function()
            self:GtweenOnComplete(item:TweenScale(Vector2(1.3, 1.3), 0.1):SetEase(EaseType.CubicOut),function()
                item:TweenScale(Vector2(1, 1), 0.1):SetEase(EaseType.CubicOut)
            end)
        end
        )
    end
end

return CumulativeAttendance
