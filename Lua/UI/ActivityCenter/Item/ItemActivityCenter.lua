--author: 	maxiaolong
--time:		2019-12-03 19:34:26

local ItemActivityCenter = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemActivityCenter", ItemActivityCenter)

function ItemActivityCenter:ctor()
    self._icon = self:GetChild("icon")
    self._iconBg = self:GetChild("bg")
    self._bgNew = self:GetChild("bgNew")
    self._c1 = self:GetController("c1")
    self._titleName = self:GetChild("titleName")
    self._text = self:GetChild("text")
    self._time = self:GetChild("textTimeNum")
    self._clockIcon = self:GetChild("iconTime")
    self._btnGreen = self:GetChild("btnGreen")
    self._lightBg = self:GetChild("light")
    self._viewTouch = self:GetChild("ViewTouch")
    self._lightBg.visible = false
    self._redPoint = self:GetChild("redPoint")
    self._redPoint.visible = false

    --------有准备阶段的相关设置
    self._c2 = self:GetController("c2")
    self._readyText = self:GetChild("readyTitleName")
    self._btnReadyStage = self:GetChild("btnGray")
    self._btnReadyStage.title = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "FUND_VIEW_BUTTON")

    self:InitEvent()
end

function ItemActivityCenter:InitEvent()
    self.refreshTime = function()
        self:RefreshTime()
    end
    self.viewFunc = function()
        self:ViewFunc()
    end

    self:AddListener(self._btnGreen.onClick, self.viewFunc)
    self:AddListener(self._viewTouch.onClick, self.viewFunc)

    self:AddListener(
        self._btnReadyStage.onClick,
        function()
            TipUtil.TipById(50317)
        end
    )

    self:AddEvent(
        ACTIVITY_COUNTDOWN_EVENT.Start,
        function()
            self:UnSchedule(self.refreshTime)
            self:Schedule(self.refreshTime, 1)
        end
    )

    self:AddEvent(
        ACTIVITY_COUNTDOWN_EVENT.End,
        function()
            self:UnSchedule(self.refreshTime)
        end
    )
    self:AddEvent(
        EventDefines.CloseIsNewTag,
        function()
            if self._info.Open then
                local isNew = _G.ActivityModel.GetActivityIsNew(self._info.Id)
                self:SetCloseNewTip(isNew)
            end
        end
    )
end

function ItemActivityCenter:GetConfigEndTime()
    local curStageEndTime = 0
    if self._info.Open and self.config.type == 1 then
        for i = 1, self._info.Stage + 1 do
            curStageEndTime = curStageEndTime + _G.ActivityModel.GetActivityRaceTime(self.config.para[i]).time
        end
    end
    return self._info.StartAt + curStageEndTime
end

function ItemActivityCenter:RefreshTime()
    if self._endTime then
        if self._endTime - _G.Tool.Time() <= 0 and self.config.type == 5 then
            self._clockIcon.visible = false
            return
        end
        self.limitedEndTimeData = not self.limitedEndTimeData and self:GetConfigEndTime() or self.limitedEndTimeData
        local timeData = self.config.type == 1 and self.limitedEndTimeData - _G.Tool.Time() or self._endTime - _G.Tool.Time()
        --SingleActivityModel里的endAt时间是准确的，这里是防止在切换活动状态的时候还没来得及取到single的时间
        if self.config.type == 10 then
            timeData = Model.SingleActivity_EndAt and Model.SingleActivity_EndAt - _G.Tool.Time() or self._endTime - _G.Tool.Time()
        end
        --如果有准备时间则倒计时等于准备时间
        if self.readyTill then
            timeData = self.readyTill - _G.Tool.Time()
        end
        if timeData >= 0 then
            local i18nkey = (self.Open and not self.readyTill) and "Ui_Vote_Deadline" or "UNION_ARMY_BEGIN_TIME"
            self._time.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, i18nkey, {time = _G.TimeUtil.SecondToDHMS(timeData)})
        end
        --到达准备时间后切换回活动开始状态
        if timeData <= 0 and self.readyTill then
            self.readyTill = nil
            self._c2.selectedIndex = 0
            return
        end
        if timeData <= 0 then
            self.limitedEndTimeData = nil
            self:UnSchedule(self.refreshTime)
            self._scheduler = false
        end
    end
end

function ItemActivityCenter:ViewFunc()
    self._lightBg.visible = false

    --设置new标签
    if self._info.Open then
        local isNew = _G.ActivityModel.AddUseActivityData(self._info.Id)
        self:SetCloseNewTip(isNew)
    end

    --处于准备阶段的是弹出tips
    if self._c2.selectedIndex == 1
    or (not self.config.readyPanel and not self._info.Open)
    then
        TipUtil.TipById(50317)
        return
    end
    --如果活动开启 没有详情UI 跳转UI是Jump activityId是configJump的id
    if self._info.Open
    and not self.config.openPanel
    and self.config.jumpPage
    and self.config.jumpPage.page == "Jump"
    then
        JumpMap:JumpSimple(self.config.jumpPage.activityId)
        return
    end

    --打开对应的页面
    if self._info.Open and self.config.openPanel then
        UIMgr:Open(self.config.openPanel, self._info)
    elseif self.config.readyPanel and not self._info.Open then
        UIMgr:Open(self.config.readyPanel, self._info)
    end
end

function ItemActivityCenter:SetData(info, selectID)
    self._lightBg.visible = info.Id == selectID and true or false
    self._info = info
    self.Open = info.Open
    self.config = self._info.Config

    --若有准备时间就切换为准备状态
    if info.ReadyTill > Tool.Time() then
        self.readyTill = info.ReadyTill
    else
        self.readyTill = nil
    end
    self._c2.selectedIndex = self.readyTill and 1 or 0
    self._readyText.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, self.config.activity_name) .. _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_Activity_Be_Ready")

    self._titleName.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, self.config.activity_name)
    self._text.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, self.config.activity_desc)
    self._time.text = ""
    local icon = UITool.GetIcon(self.config.icon)
    self._icon.icon = icon
    if info.Open then
        self._endTime = info.EndAt
        local isNew = _G.ActivityModel.GetActivityIsNew(info.Id)
        self:SetCloseNewTip(isNew)
    else
        self:SetCloseNewTip(false)
        self._endTime = info.StartAt
    end
    self:UnSchedule(self.refreshTime)
    self:Schedule(self.refreshTime, 1)
end

--设置新标签显示隐藏
function ItemActivityCenter:SetCloseNewTip(isShow)
    local index = isShow and 1 or 0
    self._c1.selectedIndex = index
end

return ItemActivityCenter
