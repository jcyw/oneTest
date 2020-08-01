--[[
	author : zixiao
	time : 2019-11-20 11:52:49
	function : 每日签到
]] --
local GD = _G.GD
local DailyAttendancePopup = UIMgr:NewUI("DailyAttendancePopup")
local WelfareModel = import("Model/WelfareModel")

local ItemState = {
    Awarded = 0,
    NotGet = 1,
    CanGet = 2
}

function DailyAttendancePopup:OnInit()
    local view = self.Controller.contentPane
    self._btnClose = view:GetChild("btnClose")
    self._textIntegral = view:GetChild("text")
    self._textTitle = view:GetChild("titleName")
    self._btnGoods = view:GetChild("btnGoods")
    self._btnHelp = view:GetChild("btnHelp")
    self._touchBg = view:GetChild("bgTounch")
    self._btnItems = {}
    self._progressBars = {}
    for i = 1, 7 do
        local btn = view:GetChild("item" .. i)
        self._btnItems[i] = btn
    end
    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "UI_DAILY_MATERIAL"),
                info = StringUtil.GetI18n(I18nType.Commmon, "DAILY_MATERIAL_EXPLAIN")
            }
            UIMgr:Open("ConfirmPopupTextCentered", data)
        end
    )
    view:GetChild("titleName").icon = UITool.GetIcon(StringUtil.GetI18n(I18nType.WordArt, "2001"))
    self:AddListener(self._btnGoods.onClick,
        function()
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
                        --播放领奖动画
                        UITool.ShowReward(rewards)

                        self.infos = infos
                        self:RefreshItemAndProgress()
                        self:Close()

                        --刷新红点
                        CuePointModel.SubType.Welfare.DailySign.Number = 0
                    end
                )
            end
        end
    )
    self:AddListener(self._touchBg.onClick,
        function()
            self:Close()
        end
    )
    self._btnGoods.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_RECEIVE_MATERIAL")
    self._textTitle.text = StringUtil.GetI18n(I18nType.Commmon, "UI_DAILY_MATERIAL")
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
end

function DailyAttendancePopup:Close()
    UIMgr:Close("DailyAttendancePopup")
end

function DailyAttendancePopup:OnClose()
end

function DailyAttendancePopup:OnOpen(index)
    self.infos = WelfareModel.GetActivityInfoByID(WelfareModel.WelfarePageType.DAILY_ATTENDANCE)
    self:RefreshItemAndProgress()
end

function DailyAttendancePopup:RefreshItemAndProgress()
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
        self:AddListener(self._btnItems[i].onTouchBegin,
            function()
                local icon = self._btnItems[i]._icon
                local title = GD.ItemAgent.GetItemNameByConfId(info.Bonus.ConfId) .. "X" .. info.Bonus.Amount
                self.detailPop:OnShowUI(title, GD.ItemAgent.GetItemDescByConfId(info.Bonus.ConfId), icon, false)
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

    self._textIntegral.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RECEIVED_NUMBER", {num = currDay})
    self._btnGoods.grayed = self.infos.Signed
end

return DailyAttendancePopup
