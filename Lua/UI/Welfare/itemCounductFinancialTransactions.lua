--[[
    author:{maxiaolong}
    time:2019-09-19 15:15:22
    function:{理财投资列表单个元素的数据赋值，跳转}
]]
local itemCounductFinancialTransactions = fgui.extension_class(GButton)
fgui.register_extension("ui://Welfare/itemConductFinancialTransactions", itemCounductFinancialTransactions)
local investModel = import("Model/InvestActivityModel")
import("Enum/ActivityType")
function itemCounductFinancialTransactions:ctor()
    self._titleName = self:GetChild("title")
    self._itemIcon = self:GetChild("_icon")
    self._investTimeText = self:GetChild("textFinancial")
    self._investNum = self:GetChild("textFinancialNum")
    self._investRateText = self:GetChild("textInterest")
    self._investRateNum = self:GetChild("textInterestNum")
    self._RateText = self:GetChild("textReturn")
    self._starIcon1 = self:GetChild("iconStar1")
    self._starIcon2 = self:GetChild("iconStar2")
    self._starIcon3 = self:GetChild("iconStar3")
    self._starIcon4 = self:GetChild("iconStar4")
    self._starIcon5 = self:GetChild("iconStar5")
    self._btnController = self:GetController("c1")
    self._mbtnLookup = self:GetChild("btnLookUp")
    self._mViewBtn = self:GetChild("btnView")
    self._btnComplete = self:GetChild("btnComplete")
    self._mCompleteTitle = self._btnComplete:GetChild("title")
    self._mViewBtnTitle = self._mViewBtn:GetChild("title")
    self._btnLookupTitle = self._mbtnLookup:GetChild("title")
    self.startIconArray = {
        self._starIcon1,
        self._starIcon2,
        self._starIcon3,
        self._starIcon4,
        self._starIcon5
    }
    self:AddListener(self._mbtnLookup.onClick,
        function()
            local isInvesting = investModel:IsInvesting()
            if isInvesting == true then
                TipUtil.TipById(50045)
            else
                UIMgr:Open("ConductFinancialTransactionsPopup", self.selectConfig, "", self.invsetMain)
            end
        end
    )
    self:AddListener(self._mViewBtn.onClick,
        function()
            local lockStr = StringUtil.GetI18n(I18nType.Commmon, "FUND_UNLOCK_BUTTON")
            local viewStr = StringUtil.GetI18n(I18nType.Commmon, "FUND_VIEW_BUTTON")
            if self._mViewBtnTitle.text == lockStr then
                local data = {
                    titleText = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                    content = StringUtil.GetI18n(I18nType.Commmon, "Fund_Unlock_Tips"),
                    sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "FUND_UNLOCK_BUTTON"),
                    sureCallback = function()
                        -- 打开充值商场功能
                        TipUtil.TipById(50259)
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
            elseif self._mViewBtnTitle.text == viewStr then
                self:GetInvestInfo()
            end
        end
    )
    self:AddListener(self._btnComplete.onClick,
        function()
            self:GetInvestInfo()
        end
    )
end

function itemCounductFinancialTransactions:GetInvestInfo()
    Net.ChargeActivity.GetInvestInfo(
        self.selectConfig.id,
        function(params)
            UIMgr:Open("ConductFinancialTransactionsPopup", self.selectConfig, params, self.invsetMain)
        end
    )
end

function itemCounductFinancialTransactions:SetData(configData, invsetMain)
    self.selectConfig = configData
    self.invsetMain = invsetMain
    local day = configData.time
    local rate = configData.rate
    local level = configData.level
    self._titleName.text = day .. StringUtil.GetI18n(I18nType.Commmon, "Fund_Title")
    self._investTimeText.text = StringUtil.GetI18n(I18nType.Commmon, "Fund_Cycle")
    self._investRateText.text = StringUtil.GetI18n(I18nType.Commmon, "Fund_Rate")
    self._RateText.text = StringUtil.GetI18n(I18nType.Commmon, "Fund_Point")
    self._investNum.text = day
    self._investRateNum.text = rate
    for i, v in pairs(self.startIconArray) do
        v.visible = false
    end
    for i = 1, tonumber(level) do
        self.startIconArray[i].visible = true
    end
    self._btnController.selectedIndex = 0
    local btnStr = ""
    local status = configData.Status
    local btnTitle
    local selectIndex = 0
    if status == Global.InvestStatusIdle then
        btnStr = "FUND_INVEST_BUTTON"
        btnTitle = self._btnLookupTitle
        selectIndex = 0
    elseif status == Global.InvestStatusInvesting then
        btnStr = "FUND_VIEW_BUTTON"
        btnTitle = self._mViewBtnTitle
        selectIndex = 1
    elseif status == Global.InvestStatusFinished then
        btnStr = "FUND_FINISH_BUTTON"
        btnTitle = self._mCompleteTitle
        selectIndex = 2
    elseif status == Global.InvestStatusLocked then
        btnStr = "FUND_UNLOCK_BUTTON"
        btnTitle = self._mViewBtnTitle
        selectIndex = 1
    end
    self._btnController.selectedIndex = selectIndex
    btnStr = StringUtil.GetI18n(I18nType.Commmon, btnStr)
    btnTitle.text = btnStr
end

function itemCounductFinancialTransactions:SetStatus()
    --完成按钮状态
    self._btnController.selectedIndex = 2
end

return itemCounductFinancialTransactions
