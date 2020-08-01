--[[
    author:{maxiaolong }
    time:2019-09-29 13:47:04
    function:{月卡列表元素单元}
]]
local GD = _G.GD
local itemMonthlyCard = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemMonthlyCard", itemMonthlyCard)

local WelfareModel = import("Model/WelfareModel")
local rewardNum = 0
function itemMonthlyCard:ctor()
    self._bgImage = self:GetChild("image")
    self._title = self:GetChild("textName")
    self._tagText = self:GetChild("textNew")
    self._tagBg = self:GetChild("bgNew")
    self._helpBtn = self:GetChild("btnHelp")
    self._maxNum = self:GetChild("textMaximum")
    self.c1 = self:GetController("c1")
    self._desText = self:GetChild("textRenew")
    self._wineText = self:GetChild("textWine")
    self._actionText = self:GetChild("textAction")
    self._renewNum = self:GetChild("textRenewNum")
    self._wineNum = self:GetChild("textWineNum")
    self._actionNum = self:GetChild("textActionNum")
    self._textTime = self:GetChild("textTime")
    self.itemsName = {
        [1] = self._desText,
        [2] = self._wineText,
        [3] = self._actionText
    }
    self.itemsNum = {
        [1] = self._renewNum,
        [2] = self._wineNum,
        [3] = self._actionNum
    }
    self._integralText = self:GetChild("textIntegral")
    self._priceBtn = self:GetChild("btnOnly")
    EffectTool.AddBtnLightEffect(self._priceBtn, {x = -1, y = -8}, {x = 0.48, y = 0.8, z = 0.9})
    self._listView = self:GetChild("liebiao")
    self._priceTitle = self._priceBtn:GetChild("title")
    self._receivedBtn = self:GetChild("receivedBtn")
    self._expiryTime = self:GetChild("textDayNums")
    self._receivedTitle = self._receivedBtn:GetChild("title")
    self._receiveBtn = self:GetChild("receiveBtn")
    self._receiveTitle = self._receiveBtn:GetChild("title")
    self._expiryTime = self:GetChild("textDayNums")
    self:AddListener(self._helpBtn.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                info = StringUtil.GetI18n(I18nType.Commmon, self.packTips)
            }
            UIMgr:Open("ConfirmPopupTextCentered", data)
            --查看月卡打点
        end
    )
    self:AddListener(self._priceBtn.onClick,
        function()
            SdkModel.Rcharge37(PurchaseType.ITEM_TYPE_APP, RCHARGE.MonthlyPack, self.confId, self.giftId)
        end
    )
    self:AddListener(self._receiveBtn.onClick,
        function()
            if self.msgInfo.RestTimes > 0 then
                Net.Purchase.GetCardAward(
                    self.confId,
                    function(msg)
                        if msg.RestTimes == 0 then
                            --刷新红点
                            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.MonthCard.Id, -1)
                        end
                        --播放领奖动画
                        local rewards = {}
                        for _, v in pairs(self.itemsData) do
                            local reward = {
                                Category = Global.RewardTypeItem,
                                ConfId = v.confId,
                                Amount = v.amount
                            }
                            table.insert(rewards, reward)
                        end
                        UITool.ShowReward(rewards)
                        Event.Broadcast(EventDefines.RefreshMonthData, msg)
                    end
                )
            end
        end
    )
    self._listView.itemRenderer = function(index, item)
        -- local icon = tonumber(self.gifts[index + 1].confId)
        -- local itemIcon = ConfigMgr.GetItem("configItems", icon)
        -- item:SetAmount(itemIcon.icon, itemIcon.color, self.gifts[index + 1].amount)
        local data = self.itemsData[index + 1]
        --item:SetControl(1)
        --item:SetImg(data.image)
        --item:SetQuality(data.color)
        --item:SetAmount(data.amount)
        --item:SetAmountMid(data.confId)
        item.name = "index"

        local mid = GD.ItemAgent.GetItemInnerContent(data.confId)
        item:SetShowData(data.image,data.color,data.amount,nil,mid)

        self:ClearListener(item.onTouchBegin)
        self:ClearListener(item.onTouchEnd)
        self:ClearListener(item.onRollOut)
        self:AddListener(item.onTouchBegin,
            function()
                self.detailPop:OnShowUI(GD.ItemAgent.GetItemNameByConfId(data.confId), GD.ItemAgent.GetItemDescByConfId(data.confId), item, false)
            end
        )
        self:AddListener(item.onTouchEnd,
            function()
                self.detailPop:OnHidePopup()
            end
        )
        self:AddListener(item.onRollOut,
            function()
                self.detailPop:OnHidePopup()
            end
        )
    end

    --设置Banner
    self._bgImage.icon = UITool.GetIcon(GlobalBanner.WelfareMonthlyCard)

    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
end

function itemMonthlyCard:SetData(params)
    if not params then
        return
    end
    self.confId = params.id
    self.giftId = params.giftId
    self.packTips = params.packTips
    --月卡查看打点
    local strId = tostring(self.confId)
    Net.UserInfo.RecordLog(
        4101,
        strId,
        function(rsp)
        end
    )
    local info, index = WelfareModel.GetMonthCardInfoById(params.id)
    self.msgInfo = info
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, params.packTitle)
    if not params.packSign then
        self._tagBg.visible = false
    else
        self._tagBg.visible = true
        self._tagText.text = StringUtil.GetI18n(I18nType.Commmon, params.packSign)
    end
    if self.msgInfo.IsActivated == true or self.msgInfo.RestTimes > 0 then
        if self.msgInfo.RestTimes >= 1 then
            self.c1.selectedIndex = 2
            if self.msgInfo.RestTimes == 1 then
                self._receiveTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
            else
                self._receiveTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get") .. " x" .. self.msgInfo.RestTimes
            end
            if self.msgInfo.ExpiryTime and self.msgInfo.ExpiryTime >= Tool.Time() then
                local restDay = math.floor((self.msgInfo.ExpiryTime - Tool.Time()) / 86400)
                self._expiryTime.text = StringUtil.GetI18n(I18nType.Commmon, "UI_MONTHLY_CARD_REST_TIME", {num = restDay})
            end
        elseif self.msgInfo.RestTimes == 0 then
            if self.msgInfo.IsActivated == true then
                self.c1.selectedIndex = 1
                self:NextTimeRender(self.msgInfo.NextTime)
                self._receivedTitle.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_39")
                if self.msgInfo.ExpiryTime then -- 领取奖励回调里没有ExpiryTime 和 IsActivated 也不需要
                    local restDay = math.floor((self.msgInfo.ExpiryTime - Tool.Time()) / 86400)
                    self._expiryTime.text = StringUtil.GetI18n(I18nType.Commmon, "UI_MONTHLY_CARD_REST_TIME", {num = restDay})
                end
            else
                self.c1.selectedIndex = 0
                local price = ShopModel:GetCodeAndPriceByProductId(params.giftId)
                local priceStr = StringUtil.GetI18n(I18nType.Commmon, "PRICE_BUTTON", {price = price})
                self._priceTitle.text = priceStr
            end
        end
    else
        self.c1.selectedIndex = 0
        local price = ShopModel:GetCodeAndPriceByProductId(params.giftId)
        local priceStr = StringUtil.GetI18n(I18nType.Commmon, "PRICE_BUTTON", {price = price})
        self._priceTitle.text = priceStr
    end

    self._maxNum.text = StringUtil.GetI18n(I18nType.Commmon, "Month_Text1")
    self._integralText.text = StringUtil.GetI18n(I18nType.Commmon, "Month_Text2")
    local giftId = tonumber(params.dailyGift)
    -- self.gifts = ConfigMgr.GetItem("configGifts", giftId).items
    self.itemsData, self.itemCount = WelfareModel.GetResOrItemByGiftId(giftId)

    local dailyAmount = params.time
    local index = 1
    self._listView.numItems = self.itemCount
    for i = 1, self._listView.numChildren do
        local title = nil
        if self.itemsData[i].isRes then
            local key = ConfigMgr.GetItem("configResourcess", self.itemsData[i].confId).key
            title = StringUtil.GetI18n(I18nType.Commmon, key)
        else
            title = GD.ItemAgent.GetItemNameByConfId(self.itemsData[i].confId)
        end
        self.itemsName[i].text = title
        self.itemsNum[i].text = "x" .. Tool.FormatNumberThousands(dailyAmount * self.itemsData[i].amount)
    end
end

function itemMonthlyCard:NextTimeRender(nextTime)
    local mTimeFunc = function()
        return nextTime - Tool.Time()
    end
    local time = mTimeFunc()
    self.callbackTime = function()
        if mTimeFunc() > 0 then
            self._textTime.text = TimeUtil.SecondToDHMS(time)
        end
        if time <= 0 then
            self:UnSchedule(self.callbackTime)
            return
        end
        time = mTimeFunc()
    end
    self:Schedule(self.callbackTime, 1)
end

return itemMonthlyCard
