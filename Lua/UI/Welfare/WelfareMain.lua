--[[
    author:{maxiaolong}
    time:2019-09-28 13:44:11
    function:{福利中心显示}
]]
local GD = _G.GD
local WelfareMain = UIMgr:NewUI("WelfareMain")
local WelfareModel = import("Model/WelfareModel")
local DailyTask = import("UI/Common/DailyTask")
local BuildBubbleModel = import("Model/Common/BuildBubbleModel")
function WelfareMain:OnInit()
    self._view = self.Controller.contentPane
    self._list1 = self._view:GetChild("liebiaoTag")
    self._list2 = self._view:GetChild("liebiaoTag2")
    self._btnReturn = self._view:GetChild("btnReturn")
    self._textTitle = self._view:GetChild("textName")
    self._btnTopBar = self._view:GetChild("btnTopBgBar")

    self._view.sortingOrder = 10
    self._list1.sortingOrder = 10
    self._btnReturn.sortingOrder = 10
    self._textTitle.sortingOrder = 10
    self._btnTopBar.sortingOrder = 9

    self._list1.scrollItemToViewOnClick = false
    self._list1.scrollPane.inertiaDisabled = true
    self._list1.scrollPane.scrollStep = 1 -- 列表滚动速度
    self.midx = self._list1.scrollPane.posX + self._list1.viewWidth / 2
    local itemRenderer = function(index, item)
        local id = self.activitiyIds[index + 1]
        local data = ConfigMgr.GetItem("configActivitys", id)
        item:SetData(data, index)
    end
    self._list1.itemRenderer = itemRenderer

    self:AddListener(
        self._list1.onClickItem,
        function(context)
            local isTriggerStatus = GD.TriggerGuideAgent.CheckIsTriggerStatus()
            if isTriggerStatus then
                return
            end
            local item = context.data
            self:MoveMiddle(item)
        end
    )
    self:AddListener(
        self._list1.onTouchEnd,
        function()
            self:MoveMiddle()
        end
    )

    self._list2.sortingOrder = 10
    self._list2.scrollItemToViewOnClick = false
    self._list2.scrollPane.inertiaDisabled = true
    self._list2.scrollPane.scrollStep = 1
    self._list2.itemRenderer = itemRenderer
    self:AddListener(
        self._list2.onClickItem,
        function(context)
            local isTriggerStatus = GD.TriggerGuideAgent.CheckIsTriggerStatus()
            if isTriggerStatus then
                return
            end
            local item = context.data
            self:MoveMiddle(item)
        end
    )
    self:AddListener(
        self._list2.onTouchEnd,
        function()
            self:MoveMiddle()
        end
    )

    self:AddListener(
        self._btnReturn.onClick,
        function()
            UIMgr:Close("WelfareMain",
            function ()
                if self.triggerCallBack then
                    self.triggerCallBack()
                end
            end
        )
        end
    )

    self:AddEvent(
        EventDefines.WelareCenterClose,
        function()
            UIMgr:Close("WelfareMain")
            Event.Broadcast(EventDefines.UITaskRefreshRed)
        end
    )
    self:AddEvent(
        EventDefines.WelfareRefreshPoint,
        function(id, num)
            -- Log.Info("----- >>> 刷新福利中心提示点 id: {0}, num: {1}", id, num)
            for i = 1, self._list.numChildren do
                local item = self._list:GetChildAt(i - 1)
                local sub = item:GetSub()
                if sub and sub.Id == id then
                    if num then
                        CuePointModel:Set(sub, sub.Number + num, item, CuePointModel.Pos.RightUp15)
                    else
                        CuePointModel:SetSingle(sub.Type, sub.Number, item, CuePointModel.Pos.RightUp15)
                    end
                    break
                end
            end
        end
    )
    self:AddEvent(
        EventDefines.WelfareRefreshUI,
        function()
            self:RefreshUI()
        end
    )

    self.showWelfare = {}
end

function WelfareMain:DoOpenAnim(...)
    self:OnOpen(...)
    --AnimationLayer.PanelAnim(AnimationType.PanelMoveLeft, self)
end

--跳转到固定子页面
function WelfareMain:OnOpen(pageType)
    self.chooseItem = nil
    self:RefreshUI(pageType)

    if not self.firstOpen then
        self.firstOpen = true
        self:RefreshUI(pageType)
    end
end

function WelfareMain:RefreshUI(PageType)
    local show_set,activitiyIds = WelfareModel.GetActivityShowPag(PageType)
    self.activitiyIds = activitiyIds
    local I18nkey = show_set == 2 and "WELFAREACTIVITY_TITLE1" or "Recharge_Activities"
    I18nkey = show_set == 4 and "Sign_in_gift" or I18nkey
    self._textTitle.text = StringUtil.GetI18n(I18nType.Commmon, I18nkey)

    if #self.activitiyIds <= 5 then
        self._list1.visible = false
        self._list2.visible = true
        self._list2.scrollPane.touchEffect = false
        self._list2:SetVirtual()
        self._list2.numItems = #self.activitiyIds
        self._list = self._list2
    else
        self._list1.visible = true
        self._list2.visible = false
        self._list1:SetVirtualAndLoop()
        self._list1.scrollPane.touchEffect = true
        self._list1.numItems = #self.activitiyIds
        self._list = self._list1
    end

    if PageType then
        self:JumpItem(PageType)
    else
        local redTypePage = WelfareModel.GetRedPage(show_set)
        if redTypePage then
            self:JumpItem(redTypePage)
        else
            self:JumpItem(WelfareModel.WelfarePageType.DAILYTASK_ACTIVITY)
        end
    end
end

function WelfareMain:MoveMiddle(clickItem)
    local num = self._list.numChildren
    if num > 0 and num < 5 then
        if clickItem then
            self:ChooseItem(clickItem)
        end
        return
    end
    if clickItem == nil then
        local center = self._list.scrollPane.posX + self._list.viewWidth / 2
        local centerDistance = math.huge
        for i = 1, self._list.numChildren do
            local item = self._list:GetChildAt(i - 1)
            local iCenter = item.x + item.width / 2
            local distance = math.abs(center - iCenter)
            if distance < centerDistance then
                centerDistance = distance
                clickItem = item
            end
        end
    end
    local itemPosx = clickItem.x + 10 / 2
    local midx = self._list.scrollPane.posX + self.midx
    local revest = midx - itemPosx > 0 and -1 or 1
    local distance = math.abs(itemPosx - midx)
    local endPos = self._list.scrollPane.posX + distance * revest + 70
    self._list.scrollPane:SetPosX(endPos, self.chooseItem and true or false)
    self:ChooseItem(clickItem)
end

function WelfareMain:JumpItem(id)
    local index = 1
    for k, v in ipairs(self.activitiyIds) do
        if v == id then
            index = k
        end
    end
    --当没有活动数据时直接关闭活动
    if #self.activitiyIds < 1 then
        UIMgr:Close("WelfareMain")
        return
    end
    self._list:ScrollToView(index - 1)
    local itemIndex = self._list:ItemIndexToChildIndex(index - 1)
    local item = self._list:GetChildAt(itemIndex)
    self:MoveMiddle(item)
end

function WelfareMain:ClearChoose()
    for i = 1, self._list.numChildren do
        self._list:GetChildAt(i - 1):SetChoice(false)
    end
end

function WelfareMain:ChooseItem(item)
    if self.chooseItem and self.chooseItem:GetId() == item:GetId() then
        self:ClearChoose()
        item:SetChoice(true)
        return
    end
    if self.chooseItem and self.chooseItem:GetId() == WelfareModel.WelfarePageType.LUCKYTURNTABLE_ACTIVITY then
        local pageItem = WelfareModel:GetWelfarePageTable(WelfareModel.WelfarePageType.LUCKYTURNTABLE_ACTIVITY)
        if pageItem and pageItem.OnClose then
            pageItem:OnClose()
        end
    end
    self.chooseItem = item
    if item then
        self:ClearChoose()
        item:SetChoice(true)
        self:OpenPage(item:GetId())
    else
        Log.Error("ChoseItem: item is nil")
    end
end
--当前打开活动Id
local cutOpenActivityId = -1
--打开相关页面
function WelfareMain:OpenPage(index)
    if index == WelfareModel.WelfarePageType.FUNTYPE then
        SdkModel.TrackBreakPoint(10025) --打点
    elseif index == WelfareModel.WelfarePageType.GROWTHCAPITALTYPE then
        SdkModel.TrackBreakPoint(10027) --打点
    end
    local allPage = WelfareModel:GetWelfareAllPage()
    for _, v in pairs(allPage) do
        v:SetShow(false)
    end
    self:SetWelfareWindow(index)
    local pageItem = WelfareModel:GetWelfarePageTable(index)
    if pageItem then
        WelfareModel.SetCurentActivity(index)
        WelfareModel.SetSelectedIndex(index)
        cutOpenActivityId = index
        pageItem:OnOpen(index)
    end
end

-- 已经展示的活动路径写入WelfareWindowInfos表
local WelfareWindowInfos = {
    [WelfareModel.WelfarePageType.SPECIALGIFTTYPE] = {ObjectPath = {"Welfare", "MonthlyCard"}},
    [WelfareModel.WelfarePageType.CUMULATIVE_ATTENDANCE] = {ObjectPath = {"Welfare", "CumulativeAttendance"}},
    [WelfareModel.WelfarePageType.DAILY_ATTENDANCE] = {ObjectPath = {"Welfare", "DailyAttendance"}},
    [WelfareModel.WelfarePageType.SEVEN_DAY_ACTIVITY] = {ObjectPath = {"Welfare", "SevenDayActivities"}},
    [WelfareModel.WelfarePageType.DAILYTASK_ACTIVITY] = {ObjectPath = {"Welfare", "TaskDaily"}},
    [WelfareModel.WelfarePageType.GROWTHCAPITALTYPE] = {ObjectPath = {"Welfare", "GrowthFund"}},
    [WelfareModel.WelfarePageType.GAMBLING_ACTIVITY] = {ObjectPath = {"Welfare", "CasinoAggregation"}},
    [WelfareModel.WelfarePageType.DETECT_ACTIVITY] = {ObjectPath = {"Welfare", "DetectActvity"}},
    [WelfareModel.WelfarePageType.FALCON_ACTIVITY] = {ObjectPath = {"Welfare", "FalconActivitise"}},
    [WelfareModel.WelfarePageType.GEMFUND_ACTIVITY] = {ObjectPath = {"Welfare", "DiamondsFundPrice"}},
    [WelfareModel.WelfarePageType.HUNTINGDOG_GEMFUND_ACTIVITY] = {ObjectPath = {"Welfare", "HuntingDogActivity"}},
    [WelfareModel.WelfarePageType.MEMORIALDAY_ACTIVITY] = {ObjectPath = {"Welfare", "MemorialDay"}},
    [WelfareModel.WelfarePageType.DIAMOND_FUND_ACTIVITY] = {ObjectPath = {"Welfare", "SuperCheapCard"}},
    [WelfareModel.WelfarePageType.LUCKYTURNTABLE_ACTIVITY] = {ObjectPath = {"Welfare", "Turntable"}}
}
local WelfareNode = {}
function WelfareMain:SetWelfareWindow(index)
    local info = WelfareWindowInfos[index]
    if info == nil then
        return
    end
    if self.showWelfare[index] then
        return
    end
    local node = UIMgr:CreateObject(info.ObjectPath[1], info.ObjectPath[2])
    table.insert(WelfareNode, {id = index, node = node})
    node.sortingOrder = 1
    self._childPage:AddChild(node)
    node:MakeFullScreen()
    WelfareModel.SetWelfarePage(index, node)
    if WelfareModel.WelfarePageType.SPECIALGIFTTYPE == index then
        node:SetContext(self)
    end
    self.showWelfare[index] = node
end

--得到福利中心node
function WelfareMain.GetWelfareNode(id)
    for _, v in pairs(WelfareNode) do
        if v.id == id then
            return v.node
        end
    end
    return nil
end

function WelfareMain:OnClose()
    if not self._view.visible then
        return
    end
    UIMgr:Close("DailyTask")
    DailyTask:OnClose()
    Event.Broadcast(EventDefines.UITaskRefreshRed)
    BuildBubbleModel.CheckShip()
    BuildBubbleModel.CheckRank()
    BuildBubbleModel.CheckDiamond()
    cutOpenActivityId = -1
    Event.Broadcast(EventDefines.ExitWelfareMainEvnet)
    local pageItem = WelfareModel:GetWelfarePageTable(WelfareModel.WelfarePageType.LUCKYTURNTABLE_ACTIVITY)
    if pageItem and pageItem.OnClose then
        pageItem:OnClose()
    end
end

--检测相关页面是否打开
function WelfareMain.CheckPageIsOpen(activityId)
    if cutOpenActivityId == -1 then
        return false
    end
    if cutOpenActivityId == activityId then
        return true
    else
        return false
    end
end

function WelfareMain:TriggerOnclick(callback)
    self.triggerCallBack = callback
end

return WelfareMain
