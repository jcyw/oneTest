--[[
    Author: songzeming
    Function: 靶场翻牌
]]
local ChatModel = import("Model/ChatModel")

local RangeFlop = UIMgr:NewUI("RangeFlop/RangeFlop")

import("UI/Casino/RangeFlop/RangeFlopCmpt")
local CTR = {
    Start = "Start",
    Cancel = "Cancel"
}
local SHARE_TIME_LIMIT = 5 --可分享分享时间间距

function RangeFlop:OnInit()
    local view = self.Controller.contentPane
    self._ctr = view:GetController("Ctr")
    local uibg= self._uibg:GetChild("_icon")
    UITool.GetIcon({"falcon", "range_bg_02"},uibg)

    self:AddListener(self._btnReturn.onClick,function()
        ChatModel:CloseCasinoRadio()
        UIMgr:Close("RangeFlop/RangeFlop")
    end)
    self:AddListener(self._bgNormal.onClick,function()
        UIMgr:Open("RangeChip", "Normal", self.casinoData)
    end)
    self:AddListener(self._bgHigh.onClick,function()
        UIMgr:Open("RangeChip", "High", self.casinoData)
    end)
    self:AddListener(self._btnHelp.onClick,function()
        self:OnBtnHelpClick()
    end)
    self:AddListener(self._btnLottery.onClick,function()
        self:OnBtnLotteryClick()
    end)
    self:AddListener(self._btnShare.onClick,function()
        self:OnBtnShareClick()
    end)
    self:AddListener(self._btnPreview.onClick,function()
        self:OnBtnPreview()
    end)

    self:AddEvent(EventDefines.UIRangeTurntableData, function(casinoData)
        if next(casinoData.HyperGamblingInfo) == nil then
            return
        end
        self.casinoData = casinoData
        self:UpdateData()
    end)
end

function RangeFlop:OnOpen(casinoData)
    self.casinoData = casinoData
    self.isCancel = false
    self:UpdateData()
end

function RangeFlop:UpdateData()
    Net.Casino.GetCasinoInfo(
            function(rsp)
                self.casinoData = rsp
                self._textNormal.text = Tool.FormatNumberThousands(self.casinoData.Counts)
                self._textHigh.text = Tool.FormatNumberThousands(self.casinoData.HyperCounts)
            end
        )
    -- self._textNormal.text = Tool.FormatNumberThousands(self.casinoData.Counts)
    -- self._textHigh.text = Tool.FormatNumberThousands(self.casinoData.HyperCounts)

    self._btnLottery.enabled = true
    self._cmptRangeFlop:InitContext(self)
    if not PlayerDataModel:GetData(PlayerDataEnum.RANGE_SHUFFLE) then
        --未洗牌 显示开始抽奖
        self._cmptRangeFlop:InitNotShuffle(self.casinoData)
        self._ctr.selectedPage = CTR.Start
    else
        self._ctr.selectedPage = CTR.Cancel
        self._cmptRangeFlop:InitShuffle(self.casinoData)
    end
end

--点击开始抽奖/取消抽奖
function RangeFlop:OnBtnLotteryClick()
    if self._ctr.selectedPage == CTR.Start then
        --洗牌
        PlayerDataModel:SetData(PlayerDataEnum.RANGE_SHUFFLE, true)
        self._btnLottery.enabled = false
        Event.Broadcast(EventDefines.Mask, true)
        self._cmptRangeFlop:PlayAnim(function()
            Event.Broadcast(EventDefines.Mask, false)
            self._btnLottery.enabled = true
            self._ctr.selectedPage = CTR.Cancel
            self._cmptRangeFlop:InitShuffle(self.casinoData)
        end)
    elseif self._ctr.selectedPage == CTR.Cancel then
        --取消抽奖
        for _, v in pairs(self.casinoData.HyperGamblingInfo) do
            if v.Order == 0 then
                --未翻完牌
                local data = {
                    content = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_29"),
                    sureCallback = function()
                        self:OnCancelLottery()
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
                return
            end
        end
        --牌已经翻完 不弹提示
        self:OnCancelLottery()
    end
end

--取消抽奖
function RangeFlop:OnCancelLottery()
    Net.Casino.QuitHyperGambling(function()
        self.isCancel = true
        PlayerDataModel:SetData(PlayerDataEnum.RANGE_SHUFFLE, false)
        self.casinoData.HyperGamblingInfo = {}
        UIMgr:Close("RangeFlop/RangeFlop")
        Event.Broadcast(EventDefines.RangeFlopClose,self.casinoData)
    end)
end

--检测是否可分享
function RangeFlop:Share_Limit()
    if not self.lastShareTime then
        self.lastShareTime = Tool.Time()
        return true
    else
        if Tool.Time() - self.lastShareTime <= SHARE_TIME_LIMIT then
            TipUtil.TipById(50064)
            return false
        else
            self.lastShareTime = Tool.Time()
            return true
        end
    end
end

--点击分享按钮
function RangeFlop:OnBtnShareClick()
    local share_city_func = function()
        if not self:Share_Limit() then
            return
        end
        Net.Chat.SendChat("World", Model.Account.accountId, "", PUBLIC_CHAT_TYPE.ChatRangeRewardRecordShare, JSON.encode(self.casinoData.HyperGamblingInfo), function()
            TipUtil.TipById(50065)
        end)
    end
    local share_union_func = function()
        if not self:Share_Limit() then
            return
        end
        if Model.Player.AllianceId == "" then
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "ConfirmJionAlliance"),
                sureCallback = function()
                    UIMgr:Close("ConfirmPopupDouble")
                    UIMgr:Close("RangeRewardRecord")
                    UIMgr:Open("UnionView/UnionView")
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
            return
        end
        Net.Chat.SendChat(Model.Player.AllianceId, Model.Account.accountId, "", PUBLIC_CHAT_TYPE.ChatRangeRewardRecordShare, JSON.encode(self.casinoData.HyperGamblingInfo), function()
            TipUtil.TipById(50065)
        end)
    end
    local data = {
        textContent = StringUtil.GetI18n(I18nType.Commmon, 'ShootingReward_36'),
        textTitle = StringUtil.GetI18n(I18nType.Commmon, 'ShootingReward_23'),
        textBtnLeft = StringUtil.GetI18n(I18nType.Commmon, 'ShootingReward_37'),
        textBtnRight = StringUtil.GetI18n(I18nType.Commmon, 'ShootingReward_38'),
        cbBtnLeft = share_city_func,
        cbBtnRight = share_union_func
    }
    UIMgr:Open("ConfirmPopupDouble", data)
end

--点击预览按钮
function RangeFlop:OnBtnPreview()
    local share_func = function()
        self:OnBtnShareClick()
    end
    UIMgr:Open("RangeRewardRecord", self.casinoData.HyperGamblingInfo, "Range", share_func)
end

--点击帮助按钮
function RangeFlop:OnBtnHelpClick()
    local data = {
        title = StringUtil.GetI18n(I18nType.Commmon, 'Tips_TITLE'),
        info = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_16")
    }
    UIMgr:Open("ConfirmPopupTextList", data)
end

function RangeFlop:OnClose()
    Event.Broadcast(EventDefines.Mask, false)
    if not self.isCancel and UIMgr:GetUIOpen("RangeTurntable") then
        UIMgr:Close("RangeTurntable")
    end
end

return RangeFlop
