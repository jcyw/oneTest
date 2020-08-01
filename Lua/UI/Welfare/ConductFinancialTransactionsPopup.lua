--[[
    author:{maxiaolong}
    time:2019-09-18 15:15:22
    function:{理财基金弹窗，点击投资开始，查看投资时间，完成时领取投资}
]]
local ConductFinancialTransactionsPopup = UIMgr:NewUI("ConductFinancialTransactionsPopup")
import("Enum/ActivityType")
local invsetPanel = import("UI/Welfare/ConductFinancialTransactions")
local isShow = false

function ConductFinancialTransactionsPopup:OnInit()
    self._view = self.Controller.contentPane
    self._bgMask = self._view:GetChild("bgMask")
    self._title = self._view:GetChild("titleName")
    self._btnClose = self._view:GetChild("btnClose")
    self._dayText = self._view:GetChild("textFinancial1")
    self._dayTextNum = self._view:GetChild("textFinancial1Num")
    self._interestRate = self._view:GetChild("textInterest1")
    self._intersetRateNum = self._view:GetChild("textInterest1Num")
    --投资额
    self._investmentText = self._view:GetChild("textFinancial2")
    self._investmentNum = self._view:GetChild("textFinancial2Num")
    --投资结束时获得
    self._investmentSumText = self._view:GetChild("textInterest2")
    self._investmentSumNum = self._view:GetChild("textInterest2Num")
    self._upperLimit = self._view:GetChild("textIcon")
    self.upperText = self._view:GetChild("textNum")
    self.downText = self._view:GetChild("textMinimum")
    self._inputTextBtn = self._view:GetChild("_btnInput")
    self._inputText = self._view:GetChild("_text")
    self._coinProgress = self._view:GetChild("slider")

    self._btnDel = self._view:GetChild("_btnDel")
    self.btnAdd = self._view:GetChild("_btnAdd")
    --获取金币
    self._getCoinsBtn = self._view:GetChild("btnObtain")
    self._getCoinsTitle = self._getCoinsBtn:GetChild("title")
    --开始投资
    self._startInverstmentBtn = self._view:GetChild("btnFinancing")
    self._startInvertstmentTitle = self._startInverstmentBtn:GetChild("title")
    self._pageController = self._view:GetController("c1")
    ---投资进行时放弃投资页面
    self._timeProgressText = self._view:GetChild("textProgressBar")
    self._timeProgressBar = self._view:GetChild("ProgressBar")
    self._finishText = self._view:GetChild("textFinish")
    self._finishNum = self._view:GetChild("textFinishNum")
    self._btnGiveUp = self._view:GetChild("btnGiveUp")
    self._btnGiveUpTitle = self._btnGiveUp:GetChild("title")
    self._btnText = self._view:GetChild("btnText")
    self._timeProgressBar.value = 0
    ---投资结束领取页面
    self._btnReceive = self._view:GetChild("btnGo")
    self.btnGoTitle = self._btnReceive:GetChild("title")
    self.btnGoTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._bgMask.onClick,
        function()
            self:Close()
        end
    )

    self:AddListener(self._inputTextBtn.onClick,
        function()
            local limitMax = 2e+20
            --2*10^20
            UIMgr:Open(
                "Keyboard",
                30,
                702,
                limitMax,
                function(num)
                    self:ComitInput(num)
                end,
                function(curNum)
                    self._inputText.text = curNum
                    self._investmentNum.text = curNum
                    self._investmentSumNum.text = self:CountRate()
                end,
                function(num)
                    self:ComitInput(num)
                end
            )
        end
    )
    self:AddListener(self._coinProgress.onChanged,
        function()
            self._inputText.text = math.floor(self._coinProgress.value)
            self._investmentSumNum.text = self:CountRate()
            self._investmentNum.text = math.floor(self._coinProgress.value)
        end
    )
    self:AddListener(self._startInverstmentBtn.onClick,
        function()
            local capital = tonumber(self._investmentNum.text)
            self.capital = capital
            if (capital < self.minValue) then
                TipUtil.TipById(50043)
                return
            end
            Net.ChargeActivity.Invest(
                capital,
                self.configItem.id,
                function(params)
                    if params.OK == true then
                        self._pageController.selectedIndex = 1
                        self._finishNum.text = self:CountRate()
                        Net.ChargeActivity.GetInvestInfo(
                            self.configItem.id,
                            function(params)
                                local t = params.FinishAt
                                self:TimeRefreshText(t, self.configItem.time)
                            end
                        )
                    end
                end
            )
        end
    )
    self:AddListener(self._btnGiveUp.onClick,
        function()
            UIMgr:Open(
                "ConductFinancialTransactionsTips",
                {
                    id = self.configItem.id,
                    title = StringUtil.GetI18n(I18nType.Commmon, "Fund_Stop_Title"),
                    content = StringUtil.GetI18n(I18nType.Commmon, "Fund_Stop_Tips1"),
                    capitalText = StringUtil.GetI18n(I18nType.Commmon, "Fund_Stop_Tips2"),
                    capitalNum = self.capital,
                    confirmText = StringUtil.GetI18n(I18nType.Commmon, "Fund_Stop_Tips3")
                },
                function()
                    self:Close()
                end
            )
        end
    )

    self:AddListener(self._btnReceive.onClick,
        function()
            Net.ChargeActivity.GetInvestAward(
                self.configItem.id,
                function(params)
                    if (params.OK == true) then
                        self:Close()
                    end
                end
            )
        end
    )

    self:AddListener(self._btnDel.onClick,
        function()
            self._coinProgress.value = self._coinProgress.value - 1
            self._inputText.text = math.floor(self._coinProgress.value)
            self._investmentSumNum.text = self:CountRate()
            self._investmentNum.text = math.floor(self._coinProgress.value)
        end
    )
    self:AddListener(self._btnAdd.onClick,
        function()
            self._coinProgress.value = self._coinProgress.value + 1
            self._inputText.text = math.floor(self._coinProgress.value)
            self._investmentSumNum.text = self:CountRate()
            self._investmentNum.text = math.floor(self._coinProgress.value)
        end
    )
    self:AddListener(self._getCoinsBtn.onClick,
        function()
            -- 打开礼包界面
            TipUtil.TipById(50259)
        end
    )
    self:AddEvent(
        EventDefines.UIInvestFinishedAction,
        function(params)
            if isShow == false then
                return
            end
            self._pageController.selectedIndex = 2
            self:PopDataTextSet(
                {
                    invest = params.Capital,
                    day = self.configItem.time .. "d",
                    rate = self.configItem.rate .. "%",
                    sumInvest = tonumber(params.Capital) + tonumber(params.Interest)
                }
            )
        end
    )
    self:InitEvent()
end

function ConductFinancialTransactionsPopup:ComitInput(num)
    local coinCount = num < self.minValue and self.minValue or num
    if coinCount > self.minValue then
        coinCount = num > self.upperLimit and self.upperLimit or num
    end
    self._inputText.text = coinCount
    self._coinProgress.value = coinCount
    self._investmentNum.text = coinCount
    self._investmentSumNum.text = self:CountRate()
end

function ConductFinancialTransactionsPopup:InitEvent()
    self._coinProgress.value = 0
end

function ConductFinancialTransactionsPopup:OnOpen(configItem, viewParams, invsetMain)
    if not configItem then
        return
    end
    isShow = true
    self.capital = viewParams.Capital
    self.configItem = configItem
    self.viewParams = viewParams
    self.invsetMain = invsetMain
    self.upperLimit = configItem.upLimit
    self.minValue = configItem.downLimt
    self._coinProgress.value = self.minValue
    self._inputText.text = self.minValue
    self._coinProgress.max = math.floor(self.upperLimit)
    self._dayText.text = StringUtil.GetI18n(I18nType.Commmon, "Fund_Cycle")
    self._interestRate.text = StringUtil.GetI18n(I18nType.Commmon, "Fund_Rate")
    self._investmentText.text = StringUtil.GetI18n(I18nType.Commmon, "Fund_Value")
    self._investmentSumText.text = StringUtil.GetI18n(I18nType.Commmon, "Fund_Award")
    local upLimitText = StringUtil.GetI18n(I18nType.Commmon, "Fund_Limit")
    self._upperLimit.text = "(" .. upLimitText .. ")"
    self.downText.text = StringUtil.GetI18n(I18nType.Commmon, "Fund_Lowest")
    self._startInvertstmentTitle.text = StringUtil.GetI18n(I18nType.Commmon, "FUND_START_BUTTON")
    self._getCoinsTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_GetDiamonds_Now")
    self._title.text = configItem.time .. StringUtil.GetI18n(I18nType.Commmon, "Fund_Title")
    self._btnText.text = StringUtil.GetI18n(I18nType.Commmon, "Fund_Tips3")
    self._finishText.text = StringUtil.GetI18n(I18nType.Commmon, "Fund_Award")
    self._btnGiveUpTitle.text = StringUtil.GetI18n(I18nType.Commmon, "FUND_QUIT_BUTTON")

    if configItem.Status == Global.InvestStatusIdle then
        self._pageController.selectedIndex = 0
        self:PopDataTextSet(
            {
                invest = self.minValue,
                day = configItem.time .. "d",
                rate = configItem.rate .. "%",
                sumInvest = self:CountRate()
            }
        )
    elseif configItem.Status == Global.InvestStatusInvesting then --查看未完成
        self._pageController.selectedIndex = 1
        self._finishNum.text = self:CountRate()
        local sum = tonumber(viewParams.Capital) + tonumber(viewParams.Interest)
        self:PopDataTextSet(
            {
                invest = viewParams.Capital,
                day = configItem.time .. "d",
                rate = configItem.rate .. "%",
                sumInvest = sum
            }
        )
        self:TimeRefreshText(viewParams.FinishAt, configItem.time)
    elseif configItem.Status == Global.InvestStatusFinished then --查看已经完成
        self._pageController.selectedIndex = 2
        local sum = tonumber(viewParams.Capital) + tonumber(viewParams.Interest)
        self:PopDataTextSet(
            {
                invest = viewParams.Capital,
                day = configItem.time .. "d",
                rate = configItem.rate .. "%",
                sumInvest = sum
            }
        )
    end
end

function ConductFinancialTransactionsPopup:PopDataTextSet(paramData)
    self._investmentNum.text = paramData.invest
    self._dayTextNum.text = paramData.day
    self._intersetRateNum.text = paramData.rate
    self._investmentSumNum.text = paramData.sumInvest
end

function ConductFinancialTransactionsPopup:TimeRefreshText(t, day)
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
    if day == 0 then
        return
    end
    local second = (day * 24) * 3600
    local mTimeFunc = function()
        return t - Tool.Time()
    end
    local curTime =mTimeFunc()
    self._timeProgressBar.max = math.floor(second)
    if curTime > 0 then
        local refreshTimeFunc = function(t)
            self._timeProgressText.text = Tool.FormatTime(t)
            local curtValue = self._timeProgressBar.max - t
            local progressValue = curtValue
            self._timeProgressBar.value = math.floor(progressValue)
        end
        refreshTimeFunc(curTime)
        self.cd_func = function()
            curTime = mTimeFunc()
            if curTime >= 0 then
                refreshTimeFunc(curTime)
                return
            else
                self._timeProgressText.text = "00:00:00"
            end
        end
        self:Schedule(self.cd_func, 1)
    end
end

function ConductFinancialTransactionsPopup:CountRate()
    local number = tonumber(self._inputText.text)
    local rateNum = number * self.configItem.rate / 100
    local sumNum = number + math.floor(rateNum)
    return sumNum
end

function ConductFinancialTransactionsPopup:Close()
    isShow = false
    UIMgr:Close("ConductFinancialTransactionsPopup")
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
    self.invsetMain:OnOpen()
end
return ConductFinancialTransactionsPopup
