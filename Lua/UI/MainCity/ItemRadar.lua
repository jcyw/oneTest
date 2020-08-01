--[[
    author:{zhanzhang}
    time:2019-06-26 11:01:23
    function:{雷达预警 Item}
]]
local ItemRadar = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemRadar", ItemRadar)

local MissionType = import("Enum/MissionType")

function ItemRadar:ctor()
    self._nameText = self:GetChild("textName")
    self._icon = self:GetChild("icon")
    self._textProgress = self:GetChild("textProgress")
    self._progress = self:GetChild("ProgressBar")

    self._textRally = self:GetChild("textProgressAggregation")
    self._textAttack = self:GetChild("textProgressUnion")
    self._progressRally = self:GetChild("ProgressBarAggregation")
    self._progressAttack = self:GetChild("ProgressBarUnion")

    self._barProgress = self._progress:GetChild("bar")

    self._ctrView = self:GetController("c1")

    self:AddListener(self._btnDetail.onClick,
        function()
            self:ShowDetail()
        end
    )
    self.totalTime = 0
    self.refreshBarFunc = function()
        self:RefreshProgressBar()
    end
end

function ItemRadar:Init(data)
    self:UnSchedule(self.refreshBarFunc)
    self.data = data
    self._nameText.text = data.Name
    if (data.RallyTill - Tool.Time()) > 0 then
        self._ctrView.selectedIndex = 1
    else
        self._ctrView.selectedIndex = 0
    end

    if self.data.IsCustomEvent then
        if self.data.IsCustomEvent == 1004 then
            -- CommonModel.SetUserAvatar(self._icon, data.Avatar,data.UserId)
            self._icon:SetAvatar(data, nil, data.UserId)
        else
            -- self._icon.icon = UITool.GetIcon(data.Avatar)
            self._icon:SetAvatar(data.Avatar, "custom")
        end
    else
        -- CommonModel.SetUserAvatar(self._icon, data.Avatar)
        self._icon:SetAvatar(data)
    end
    if data.Category == Global.MissionAssit then
        self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Assistance")
        self._textState.color = Color.green
        self._barProgress.color = Color.green
    elseif data.Category == Global.MissionAttack then
        if (data.RallyTill - Tool.Time()) > 0 then
            self._textAggregation.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RADAR_MASS_TIME")
            self._textUnion.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARRIVE_TIME")
            self._textState.color = Color.red
        else
            self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Attack")
            self._textState.color = Color.red
            self._barProgress.color = Color.red
        end
    elseif data.Category == Global.MissionRally then
        -- self._barProgress.color = Color.red
        --集结
        self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Attack")
        self._textState.color = Color.red
    elseif data.Category == Global.MissionSpy then
        -- self._barProgress.color = Color.red
        --侦查
        self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Investigate")
        self._textState.color = Color.red
    elseif data.Category == Global.MissionAISiege then
        self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Attack")
        self._textState.color = Color.red
        -- self._barProgress.color = Color.red
        local config = ConfigMgr.GetItem("configKnightBases", data.Level)
        self._nameText.text = StringUtil.GetI18n(I18nType.Commmon, config.I18n)
        -- self._icon.icon = UITool.GetIcon(config.icon)
        self._icon:SetAvatar(config.icon, "custom")
    end
    self.isBase = data.StopX == Model.Player.X and data.StopY == Model.Player.Y
    -- if data.RallyTill > 0 then
    --     self.totalTime = data.RallyTill - data.CreatedAt
    -- else
    --     self.totalTime = data.ArriveAt - data.CreatedAt
    -- end
    self._progress.max = 100
    self._progressRally.max = 100
    self._progressAttack.max = 100
    self._progressAttack.value = 0

    self:RefreshProgressBar()
    self:Schedule(self.refreshBarFunc, 1, true)
end

function ItemRadar:ShowDetail()
    UIMgr:Open("RadarDetail", self.data)
end

function ItemRadar:RefreshProgressBar()
    local rallyTime
    local countTime = self.data.ArriveAt - Tool.Time()
    if (countTime <= 0) then
        self.visible = false
        Event.Broadcast(EventDefines.UIOnRadarItemArrived, self)
        self:UnSchedule(self.refreshBarFunc)
        return
    end
    if self.data.RallyTill > 0 then
        rallyTime = self.data.RallyTill - Tool.Time()
        if rallyTime == 0 then
            -- Event.Broadcast(EventDefines.UIOnRadarItemArrived, self)
            Event.Broadcast(EventDefines.UIOnRadarRefresh, self.data)
            self._ctrView.selectedIndex = 0
        elseif rallyTime > 0 then
            self._progressRally.value = (Tool.Time() - self.data.CreatedAt) / (self.data.RallyTill - self.data.CreatedAt) * 100
            self._progressAttack.value = (Tool.Time() - self.data.CreatedAt) / (self.data.ArriveAt - self.data.CreatedAt) * 100
        end
        rallyTime = TimeUtil.SecondToHMS(rallyTime)
    end
    local str = ""
    local rallyStr = ""
    local enemyHandle = ""
    local countTime = TimeUtil.SecondToHMS(countTime)
    self._progress.visible = true
    if self.data.IsCustomEvent and self.data.IsCustomEvent == 1002 then
        str = StringUtil.GetI18n(I18nType.Commmon, self.data.progressText, {time = countTime})
    elseif self.data.Category == Global.MissionAssit then
        str = StringUtil.GetI18n(I18nType.Commmon, self.isBase and "Ui_Friend_Behavior_Base" or "Ui_Friend_Behavior_Army", {time = countTime})
    else
        local info = BuildModel.FindByConfId(Global.BuildingRadar)
        if info.Level > 4 or self.data.IsCustomEvent or self.data.Category == Global.MissionAISiege then
            if self.data.Category == Global.MissionSpy then
                --敌方侦查
                enemyHandle = StringUtil.GetI18n(I18nType.Commmon, "UI_Investigate")
            elseif self.data.Category == Global.MissionAttack or self.data.Category == Global.MissionAISiege then
                --敌方攻击
                enemyHandle = StringUtil.GetI18n(I18nType.Commmon, "UI_Attack")
                rallyStr = StringUtil.GetI18n(I18nType.Commmon, "Ui_Enemy_Behavior_Mass", {time = rallyTime, behavior = enemyHandle})
            end
            if (self.data.RallyTill - Tool.Time()) > 0 then
                str = StringUtil.GetI18n(I18nType.Commmon, "Ui_Enemy_Behavior_Base", {time = countTime, behavior = enemyHandle})
            else
                str = StringUtil.GetI18n(I18nType.Commmon, self.isBase and "Ui_Enemy_Behavior_Base" or "Ui_Enemy_Behavior_Army", {time = countTime, behavior = enemyHandle})
            end
        else
            self._progress.visible = false
        end
    end
    self._textProgress.text = str
    self._textAttack.text = str
    self._textRally.text = rallyStr
    local proval = (Tool.Time() - self.data.CreatedAt) / (self.data.ArriveAt - self.data.CreatedAt) * 100
    self._progress.value = proval
end

function ItemRadar:OnClose()
    self:UnSchedule(self.refreshBarFunc)
end

return ItemRadar
