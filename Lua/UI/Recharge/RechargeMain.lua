--[[
    Author: songzeming,maxiaolong
    Function: 活动 获得金条
]]
local RechargeMain = UIMgr:NewUI("RechargeMain")

local GiftModel = import("Model/GiftModel")
local RechargeModel = import("Model/RechargeModel")
local WelfareModel = import("Model/WelfareModel")

function RechargeMain:OnInit()
    local view = self.Controller.contentPane
    self.goldDatas = RechargeModel.GetRechargeDatas()
    self._pageControl = view:GetController("pageControl")
    self._giftControl = view:GetController("giftControl")
    self._giftTypeControl = view:GetController("giftTypeControl")
    self._emptyControl = view:GetController("emptyControl")
    self._btnImage:GetController("c1").selectedIndex = 1
    self.curGiftIndex = 1
    self.pointIndex = 1
    self.curGiftItem = nil
    self.isPlayGiftAnim = true
    self.scrollDis = 0

    NodePool.Init(NodePool.KeyType.GiftEffect, "Effect", "EffectNode")

    self.purchaseGiftSuccess = function(confId)
        local config = GiftModel.GetGiftConfig(confId)
        self:OpenSuccessWindow(config)
    end

    self.refreshGiftsFunc = function()
        self:RefreshGiftList()
    end

    self.refreshDailyGiftBtnFunc = function()
        self:RefreshGiftShow("show")
    end

    self._listGifts:SetVirtualAndLoop()
    self._listGifts.itemRenderer = function(index, item)
        local nextPage = index + 1
        item.width = self._listGifts.width
        item.height = self._listGifts.height
        item:Init(self.gifts[nextPage], self.isOnlyGift, self.isPlayGiftAnim, function()
            self.scrollDis = nil
        end)

        self.pointIndex = index + 1
        self.curGiftItem = item
    end

    --钻石刷新显示
    self:AddEvent(
        EventDefines.RefreshDiamondData,
        function(id, isPayed)
            RechargeModel.SetGoldData(id, isPayed)
            if self._pageControl.selectedPage == "gold" then
                self:RefreshGoldList()
            end
        end
    )

    self:AddListener(self._btnGift.onClick,
        function()
            UIMgr:Open(
                "RechargeGiftPackagePopupGift",
                function(rewards)
                    UITool.ShowReward(rewards)
                    GiftModel.SetDailyGiftFlag(true)
                    self:RefreshGiftShow("hide")
                    self:CheckDailyGiftPoint()
                    Event.Broadcast(TIME_REFRESH_EVENT.Refresh)
                end
            )
        end
    )

    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("RechargeMain")
        end
    )

    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("RechargeMain")
        end
    )

    self:AddListener(self._btnGetGift.onClick,
        function()
            if self._pageControl.selectedPage == "gift" then
                return
            end
            self:OpenGiftUI()
        end
    )

    self:AddListener(self._btnGetGold.onClick,
        function()
            if self._pageControl.selectedPage == "gold" then
                return
            end
            self.isPlayGiftAnim = true
            self:OpenGoldUI()
        end
    )

    --------------------优化拖动手感
    self:AddListener(self._listGifts.onTouchBegin,
        function()
            self.scrollDis = Stage.inst:GetTouchPosition(1).x
        end
    )

    self:AddListener(self._listGifts.onTouchEnd,
        function()
            if self.scrollDis then
                local cur = Stage.inst:GetTouchPosition(1).x
                local dis = cur - self.scrollDis
                self.scrollDis = 0
                if dis < -80 and dis > -(Screen.width * 0.3) then
                    self._listGifts.scrollPane:ScrollRight(1, true)
                elseif dis > 80 and dis < (Screen.width * 0.3) then
                    self._listGifts.scrollPane:ScrollLeft(1, true)
                end
            end
        end
    )
    ----------------------------------

    self:AddListener(self._listGifts.scrollPane.onScroll,
        function()
            self.isPlayGiftAnim = false
        end
    )

    self:AddListener(self._listGifts.scrollPane.onScrollEnd,
        function()
            local curPage = 1
            if self.curGiftItem then
                local isView = self._listGifts:IsChildInView(self.curGiftItem)
                curPage = isView and self.pointIndex or self.pointIndex - 1
                curPage = curPage <= 0 and #self.points or curPage
                for k, v in pairs(self.points) do
                    if k == curPage then
                        self.curGroupId = self.gifts[curPage] and self.gifts[curPage].group_id or nil
                        v:GetController("c1").selectedIndex = 1
                    else
                        v:GetController("c1").selectedIndex = 0
                    end
                end
            end

            -- if self.isOnlyGift then
            --     local group = ConfigMgr.GetItem("configGiftGroups", self.gifts[curPage].group_id)
            --     self._textTitle.text = StringUtil.GetI18n(I18nType.Activitys, group.gift_name)
            -- end
        end
    )

    --设置Banner
    self._btnImage:GetChild("image").icon = UITool.GetIcon(GlobalBanner.GiftDefault)
end
function RechargeMain:DoOpenAnim(...)
    self:OnOpen(...)
    --AnimationLayer.PanelAnim(AnimationType.PanelMoveLeft, self)
end

--[[
    isGoldPage bool值，默认礼包界面
    isOnlyGift bool值，礼包界面使用，默认有切换标签
    giftNum 显示第几个礼包，默认第一个
]]
function RechargeMain:OnOpen(isGoldPage, isOnlyGift, groupId)
    Event.Broadcast(EventDefines.OpenRangeRewardRecord)
    SdkModel.TrackBreakPoint(10034) --打点
    self.isPlayGiftAnim = true
    self.isOnlyGift = isOnlyGift
    self.curBuyGift = null
    self._giftTypeControl.selectedPage = isOnlyGift and "only" or "notOnly"
    self.curGroupId = groupId
    self._listGifts.numItems = 0 -- _listGifts设置为循环虚列表后需要初始化，否则直接打开GoldUI会报错
    if isGoldPage then
        self:OpenGoldUI()
    else
        self:OpenGiftUI()
    end

    self:AddEvent(EventDefines.PurchaseGiftSuccess, self.purchaseGiftSuccess)
    self:AddEvent(EventDefines.RefreshGiftPacks, self.refreshGiftsFunc)
    self:AddEvent(EventDefines.RefreshDailyGiftFlag, self.refreshDailyGiftBtnFunc)
end

function RechargeMain:OnClose()
    Event.RemoveListener(EventDefines.PurchaseGiftSuccess, self.purchaseGiftSuccess)
    Event.RemoveListener(EventDefines.RefreshGiftPacks, self.refreshGiftsFunc)
    Event.RemoveListener(EventDefines.RefreshDailyGiftFlag, self.refreshDailyGiftBtnFunc)
    Event.Broadcast(EventDefines.ExitRangeRewardRecord)
    local tables = table.contains(WelfareModel.GetActiveActivityId(), 1900902)
    if tables then
        Event.Broadcast(EventDefines.GemFundUIRefresh)
    end
    self:UnSchedule(self.timerFunc)
end

function RechargeMain:OpenGiftUI()
    self.gifts = {}
    self.points = {}

    self._btnGetGift.selected = true
    self._btnGetGold.selected = false
    self._pageControl.selectedPage = "gift"
    self:RefreshGiftShow((self.isOnlyGift or not GiftModel.HasDailyGift()) and "hide" or "show")
    self._textTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get_GIFT")
    self:RefreshGiftList()

    -- 只显示礼包
    -- if self.isOnlyGift and #self.gifts > 0 then
    --     local group = ConfigMgr.GetItem("configGiftGroups", self.gifts[self.curGiftIndex].group_id)
    --     self._textTitle.text = StringUtil.GetI18n(I18nType.Activitys, group.gift_name)
    --     self:Schedule(self.timerFunc, 1)
    -- end
end

function RechargeMain:OpenGoldUI()
    if Model.BoughtGemIds then
        RechargeModel.SetGoldDataLogin(Model.BoughtGemIds)
    end
    self._btnGetGift.selected = false
    self._btnGetGold.selected = true
    self._pageControl.selectedPage = "gold"
    self:RefreshGiftShow("hide")
    self._textTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get_Diamonds")
    self:RefreshGoldList()
    self:PlayAnim()
end

function RechargeMain:RefreshGiftList()
    self.gifts = GiftModel.GetCurGiftList()
    if #self.gifts > 0 then
        self._emptyControl.selectedPage = "normal"
    else
        self._emptyControl.selectedPage = "empty"
    end

    local index = 1
    self._listPoint:RemoveChildrenToPool()
    self.points = {}
    for k, v in pairs(self.gifts) do
        local point = self._listPoint:AddItemFromPool()
        if v.group_id == self.curGroupId then
            point:GetController("c1").selectedIndex = 1
            index = k
        else
            point:GetController("c1").selectedIndex = 0
        end
        table.insert(self.points, point)
    end

    if not self.curGroupId and #self.gifts > 0 then
        self.points[1]:GetController("c1").selectedIndex = 1
    end

    self._listGifts.numItems = #self.gifts
    self._listGifts.scrollPane:SetCurrentPageX(index - 1)
end

--打开购买成功弹窗
function RechargeMain:OpenSuccessWindow(config)
    UIMgr:Open("RechargeGiftPackagePopup", config, true)
end

function RechargeMain:RefreshGoldList()
    self._emptyControl.selectedPage = "normal"
    self._listGolds:RemoveChildrenToPool()
    for _, v in pairs(self.goldDatas) do
        local item = self._listGolds:AddItemFromPool()
        item:SetData(v)
    end
end

--播放动画
function RechargeMain:PlayAnim()
    local mvDistance = 300
    for i = 1, self._listGolds.numChildren do
        local item = self._listGolds:GetChildAt(i - 1)
        GTween.Kill(item)
        item.y = (i - 1) * (self._listGolds.lineGap + item.height) + mvDistance
        item:TweenMoveY(item.y - mvDistance, 0.1 * i)
    end
end

--刷新礼包显示
function RechargeMain:RefreshGiftShow(type)
    self._giftControl.selectedPage = type
    CuePointModel:SetSingle(CuePointModel.Type.Warning, type == "show" and 1 or 0, self._btnGift, CuePointModel.Pos.Warning)
    if type == "show" then-- and not self.giftEffect
        self.front, self.behind = AnimationModel.GiftEffect(self._btnGift, Vector3(2, 2, 1), nil, "RechargeMainGift", self.front, self.behind)
    else
        AnimationModel.DisPoseGiftEffect("RechargeMainGift", self.front, self.behind)
    end
    self:CheckDailyGiftPoint()
end

--检测提示点
function RechargeMain:CheckDailyGiftPoint()
    local number = GiftModel.HasDailyGift() and 1 or 0
    CuePointModel:Set(CuePointModel.SubType.Gift.DailyGift, number, self._btnGift)
end

return RechargeMain
