--author: 	Amu,maxiaolong
--time:		2019-12-02 16:42:26

local ACTIVITY_TYPE = {}
ACTIVITY_TYPE.Open = 0
ACTIVITY_TYPE.Close = 1

local ActivityCenter = UIMgr:NewUI("ActivityCenter")
local tipOpenText
local tipStartText
function ActivityCenter:OnInit()
    self._view = self.Controller.contentPane
    self._btnReturn = self._view:GetChild("btnReturn")
    self._btnInventory = self._view:GetChild("btnInventory")
    self._btnStore = self._view:GetChild("btnStore")
    self._btnSun = self._view:GetChild("btnGift")
    self._pageList = self._view:GetChild("liebiaoPage")
    self._pointList = self._view:GetChild("liebiaoPoint")
    self._listView = self._view:GetChild("liebiao")
    self._ctrView = self._view:GetController("c1")
    self._tipCtr = self._view:GetController("c2")
    self._tipText = self._view:GetChild("tipText")
    tipOpenText = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "UI_NO_ACTIVITY_UNDERWAY")
    tipStartText = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "UI_NO_ACTIVITY_BEGINSOON")
    self._pointList:SetVirtual()
    self._pageList:SetVirtualAndLoop()
    self:InitEvent()
    self._tipCtr.selectedIndex = 0
end

function ActivityCenter:InitEvent()
    self:AddListener(
        self._btnReturn.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(
        self._btnInventory.onClick,
        function()
            self._ctrView.selectedIndex = ACTIVITY_TYPE.Open
            self:RefreshListView()
            self:PlayAinm()
        end
    )
    self:AddListener(
        self._btnStore.onClick,
        function()
            self._ctrView.selectedIndex = ACTIVITY_TYPE.Close
            self:RefreshListView()
            self:PlayAinm()
        end
    )
    self:AddListener(
        self._btnSun.onClick,
        function()
            UIMgr:Open("ActivityCenterCalendarPopup")
        end
    )
    self:AddListener(
        self._btnLeft.onClick,
        function()
            self._pageList.scrollPane:ScrollLeft(1.0, true)
        end
    )
    self:AddListener(
        self._btnRight.onClick,
        function()
            self._pageList.scrollPane:ScrollRight(1.0, true)
        end
    )
    self._pageList.itemRenderer = function(index, item)
        if not index then
            return
        end
        --如果没有活动显示默认banner
        if self._pointList.numChildren == 0 and self._tipCtr.selectedIndex == 1 then
            item:SetData()
            return
        end
        item:SetData(self.allActivity[index + 1])
    end
    self:AddListener(
        self._pageList.scrollPane.onScroll,
        function(context)
            self:RefreshPointListView()
        end
    )
    self:AddListener(
        self._pageList.onClickItem,
        function(context)
            local item = context.data
        end
    )
    self._pointList.itemRenderer = function(index, item)
        if not index then
            return
        end

        if next(self.allActivity) and #self.allActivity > 0 then
            local currentPageX = math.fmod(self._pageList.scrollPane.currentPageX, #self.allActivity)
            item:SetData(currentPageX, index)
        else
            item:SetData(0, index)
        end
    end

    self._listView.itemRenderer = function(index, item)
        if not index then
            return
        end
        if self._ctrView.selectedIndex == ACTIVITY_TYPE.Open then
            item:SetData(self.openActivity[index + 1], self.cutSelectedId)
        elseif self._ctrView.selectedIndex == ACTIVITY_TYPE.Close then
            item:SetData(self.closeActivity[index + 1])
        end
    end
    self:AddEvent(
        EventDefines.CloseActivityUI,
        function()
            self:Close()
        end
    )
    self:AddEvent(
        EventDefines.RefreshActivityUI,
        function()
            if not self.OnHide then
                self:RefereshUI()
            end
        end
    )
end

function ActivityCenter:DoOpenAnim(...)
    self:OnOpen(...)
    --AnimationLayer.PanelAnim(AnimationType.PanelMoveLeft, self)
end

function ActivityCenter:OnOpen(cutActivityId)
    ActivityModel.InitActivityData()
    SdkModel.TrackBreakPoint(10076) --打点
    self._ctrView.selectedIndex = ACTIVITY_TYPE.Open
    if cutActivityId and cutActivityId > 0 then
        self.cutSelectedId = cutActivityId
    else
        self.cutSelectedId = nil
    end
    self:RefereshUI(false)
    self:PlayAinm()
end

function ActivityCenter:RefereshUI(isReferesh)
    self.openActivity = _G.ActivityModel.GetActivityData(_G.ActivityModel.TypeModel.Open)
    for k,v in ipairs(self.openActivity)do  -- 问卷调查  不显示再活动中心  （特殊处理）
        if v.Id == 1001501 then
            table.remove(self.openActivity, k)
            break
        end
    end
    self.closeActivity = _G.ActivityModel.GetActivityData(_G.ActivityModel.TypeModel.Close)
    self.allActivity = _G.ActivityModel.GetActivityData(_G.ActivityModel.TypeModel.All)
    for k,v in ipairs(self.allActivity)do  -- 问卷调查  不显示再活动中心  （特殊处理）
        if v.Id == 1001501 then
            table.remove(self.allActivity, k)
            break
        end
    end
    self:RefreshListView()
    if not isReferesh then
        Event.Broadcast(ACTIVITY_COUNTDOWN_EVENT.Start)
        self:BanerTimer()
    end
end

function ActivityCenter:RefreshListView()
    local openDataNums = next(self.openActivity) and #self.openActivity or 0
    local closeDataNums = next(self.closeActivity) and #self.closeActivity or 0
    if self._ctrView.selectedIndex == ACTIVITY_TYPE.Open then
        self._listView.numItems = openDataNums
        local bl = not self.openActivity or not next(self.openActivity)
        self._tipCtr.selectedIndex = bl and 1 or 0
        self._tipText.text = bl and tipOpenText or tipStartText
    end
    if self._ctrView.selectedIndex == ACTIVITY_TYPE.Close then
        self._listView.numItems = closeDataNums
        local bl = not self.closeActivity or not next(self.closeActivity)
        self._tipCtr.selectedIndex = bl and 1 or 0
    end
    self:SetPageNum()
end

function ActivityCenter:PlayAinm()
    AnimationLayer.PlayListLeftToRightAnim(AnimationType.UILeftToRight,self._listView,0.1,self)
    self._listView.scrollPane:ScrollTop()
end

function ActivityCenter:RefreshPointListView()
    local pageNum = 0
    if self.allActivity and #self.allActivity > 0 then
        pageNum = #self.allActivity
    end
    self._pointList.numItems = pageNum
end

function ActivityCenter:SetPageNum()
    local pageNum = 0
    if self.allActivity and #self.allActivity > 0 then
        pageNum = #self.allActivity
    end
    self._pageList.numItems = pageNum > 0 and pageNum or 1
    self._pointList.numItems = pageNum
end

function ActivityCenter:BanerTimer()
    self.func = function()
        self._pageList.scrollPane:ScrollRight(1.0, true)
    end
    self:Schedule(self.func, Global.ActivityBannerTime, true, Global.ActivityBannerTime)
end

function ActivityCenter:Close()
    UIMgr:Close("ActivityCenter")
end

function ActivityCenter:OnClose()
    Event.Broadcast(ACTIVITY_COUNTDOWN_EVENT.End)
    self:UnSchedule(self.func)
    Event.Broadcast(ACTIVITY_COUNTDOWN_EVENT.Banner)
end

return ActivityCenter
