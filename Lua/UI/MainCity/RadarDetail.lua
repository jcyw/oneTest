--[[
    author:{zhanzhang}
    time:2019-06-26 11:29:35
    function:{雷达详情图}
]]
local RadarDetail = UIMgr:NewUI("RadarDetail")
local BuildModel = import("Model/BuildModel")
local RadarModel = import("Model/RadarModel")
-- Buildings_Radar_Effect_1	    [行军信息]会告知向你行军部队的所属指挥官名称和这支部队的行军目的
-- Buildings_Radar_Effect_3	    [行军信息]会告知向你行军的部队来自什么坐标
-- Buildings_Radar_Effect_5	    [行军信息]会告知向你行军部队的抵达时间
-- Buildings_Radar_Effect_7	    [行军信息]会告知向你行军部队的部队总数
-- Buildings_Radar_Effect_9	    [行军信息]会告知向你行军的所有指挥官的确切等级
-- Buildings_Radar_Effect_11	[行军信息]会告知向你行军的部队里包含哪些兵种
-- Buildings_Radar_Effect_13	[行军信息]会告知向你行军的部队中部队的详细信息和数量

function RadarDetail:OnInit()
    -- body
    self.view = self.Controller.contentPane
    self._btnReturn = self.view:GetChild("btnReturn")
    self._playerIcon = self.view:GetChild("n86")
    self._textPlayerName = self.view:GetChild("textPlayerName")
    self._textFrom = self.view:GetChild("textFrom")
    self._textFromPoint = self.view:GetChild("textFromNum")
    self._textTargetPoint = self.view:GetChild("textTargetNum")
    self._textState = self.view:GetChild("textAttack")
    self._textMemberNum = self.view:GetChild("textMemberNum")
    self._progress = self.view:GetChild("ProgressBar")
    self._textProgress = self.view:GetChild("textProgressTime")
    self._textLevel = self.view:GetChild("textLevel")
    self._btnHelp = self.view:GetChild("btnHelp")

    self._noInfoTip = self.view:GetChild("groupState1")
    self._btnIgnore = self.view:GetChild("btnIgnore")
    self._contentList = self.view:GetChild("liebiao")
    --group
    self._groupMember = self.view:GetChild("groupMember")
    self._groupCoordinate = self.view:GetChild("groupCoordinate")
    self._groupProgress = self.view:GetChild("groupProgress")
    self._btnController = self.view:GetController("c1")
    self._typeController = self.view:GetController("c2")
    self._groupLevel = self.view:GetChild("groupLevel")

    self._memberContent = self.view:GetChild("memberContent")
    self._armiesContent = self.view:GetChild("armiesContent")
    self._armiesDetail = self.view:GetChild("armiesDetail")

    self.membersList = {}
    self.armiesList = {}

    self:OnRegister()
end

function RadarDetail:OnRegister()
    self.fairyBatching = true
    self.refreshBarFunc = function()
        self:RefreshProgressBar()
    end
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("RadarDetail")
        end
    )
    self:AddListener(self._textFromPoint.onClick,
        function()
            UIMgr:ClosePopAndTopPanel()
            Event.Broadcast(EventDefines.OpenWorldMap, self.data.StartX, self.data.StartY)
        end
    )
    self:AddListener(self._textTargetPoint.onClick,
        function()
            UIMgr:ClosePopAndTopPanel()
            Event.Broadcast(EventDefines.OpenWorldMap, self.data.StopX, self.data.StopY)
        end
    )

    self:AddListener(self._btnHelp.onClick,
        function()
            UIMgr:Open("ConfirmPopupTextList", {title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"), info = StringUtil.GetI18n(I18nType.Commmon, "Radar_Explain")})
        end
    )
    --求援
    self:AddListener(self._btnSeekHelp.onClick,
        function()
            if self.data.IsCustomEvent then
                self.data.AskedHelp = true
                self._btnSeekHelp.enabled = false
                RadarModel.AddItem(self.data)
                return
            end
            Net.AllianceBattle.AskArmyAssist(
                self.data.Uuid,
                function()
                    self.data.AskedHelp = true
                    self._btnSeekHelp.enabled = false
                    RadarModel.AddItem(self.data)
                end
            )
        end
    )
    self:AddListener(self._btnIgnore.onClick,
        function()
            if self.data.IsCustomEvent then
                RadarModel.IgnoreItem(self.data.Uuid)
                return
            end
            Net.Missions.IgnoreWarning(
                self.data.Uuid,
                function(val)
                    self._btnIgnore.enabled = false
                    RadarModel.IgnoreItem(self.data.Uuid)
                end
            )
        end
    )
    self:AddEvent(
        EventDefines.UIOnRadarRefresh,
        function(msg)
            self:OnOpen(msg)
        end
    )
end
function RadarDetail:OnOpen(data)
    self.data = data
    self._btnSeekHelp.enabled = (Model.Player.AllianceId ~= "" and not data.AskedHelp)
    if self.data.IsCustomEvent then
        if self.data.IsCustomEvent == 1004 then
            -- CommonModel.SetUserAvatar(self._playerIcon, data.Avatar,data.UserId)
            self._playerIcon:SetAvatar(data, nil, data.UserId)
        else
            -- self._playerIcon.icon = UITool.GetIcon(data.Avatar)
            self._playerIcon:SetAvatar(data.Avatar, "custom")
        end
    else
        -- CommonModel.SetUserAvatar(self._playerIcon, data.Avatar)
        self._playerIcon:SetAvatar(data)
    end
    if data.Category == Global.MissionAssit then
        self._btnController.selectedIndex = 1
    else
        self._btnController.selectedIndex = 0
        if Model.Player.AllianceId == "" then
            self._btnSeekHelp.visible = false
            self._btnIgnore.x = self.view.width / 2 - self._btnIgnore.width / 2
        else
            self._btnSeekHelp.visible = true
            self._btnIgnore.x = self._btnSeekHelp.x - 370
        end
    end

    self._btnIgnore.enabled = not data.Ignore
    self._textPlayerName.text = data.Name
    self.isBase = data.StopX == Model.Player.X and data.StopY == Model.Player.Y
    self:UnSchedule(self.refreshBarFunc)
    self:ShowRadarInfo(data.Category)
    if data.Category == Global.MissionAssit then
        --援助
        self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Assistance")
        self._textState.color = Color.green
        self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Assistance")
    else
        if data.Category == Global.MissionAttack then
            -- self._armiesContent.height = #data.Armies * 200
            --进攻
            if (data.RallyTill - Tool.Time()) > 0 then
                self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RADAR_MASS_ATTACK")
                self._textState.color = Color.red
                self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RADAR_MASS_ATTACK")
            else
                self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Attack")
                self._textState.color = Color.red
                self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Attack")
            end
        elseif data.Category == Global.MissionRally then
            -- local item = self._memberContent:AddItemFromPool()
            -- item:Init(data.Missions)
            --集结
            self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Attack")
            self._textState.color = Color.red
        elseif data.Category == Global.MissionSpy then
            --侦查
            self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Investigate")
            self._textState.color = Color.red
            self._groupMember.visible = false
        elseif data.Category == Global.MissionAISiege then
            self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Attack")
            self._textState.color = Color.red
            local config = ConfigMgr.GetItem("configKnightBases", data.Level)
            self._textPlayerName.text = StringUtil.GetI18n(I18nType.Commmon, config.I18n)
            -- self._playerIcon.icon = UITool.GetIcon(config.icon)
            self._playerIcon:SetAvatar(config.icon, "custom")
        end
    end
end

function RadarDetail:RefreshProgressBar()
    local delay = self.data.ArriveAt - Tool.Time()
    if (delay <= 0) then
        UIMgr:Close("RadarDetail")
        return
    end
    local str = ""
    local enemyHandle = ""
    local countTime = TimeUtil.SecondToHMS(self.data.ArriveAt - Tool.Time())
    -- if self.data.IsCustomEvent and self.data.IsCustomEvent==1002 then
    --     countTime = StringUtil.GetI18n("")
    -- end

    self._textProgress.text = countTime
    self._progress.value = (Tool.Time() - self.data.CreatedAt) / self.totalTime * 100
end
function RadarDetail:OnClose()
    self:UnSchedule(self.refreshBarFunc)
end

function RadarDetail:ShowRadarInfo(category)
    self._armiesContent:RemoveChildrenToPool()
    self._memberContent:RemoveChildrenToPool()
    local info = BuildModel.FindByConfId(Global.BuildingRadar)
    local buildLevel = info.Level
    --3级解锁坐标
    self._textTargetPoint.text = StringUtil.GetCoordinataWithLetter(self.data.StopX, self.data.StopY)
    if (buildLevel > 2 or category == Global.MissionAssit or category == Global.MissionAISiege) or self.data.IsCustomEvent then
        self._textFrom.visible = true
        self._textFromPoint.text = StringUtil.GetCoordinataWithLetter(self.data.StartX, self.data.StartY)
    else
        self._textFromPoint.text = ""
        self._textFrom.visible = false
    end
    --5级解锁进度条,等级
    if (buildLevel > 4 or category == Global.MissionAssit or category == Global.MissionAISiege) or self.data.IsCustomEvent then
        self._groupProgress.visible = true
        self._textLevel.text = self.data.Level
        self.totalTime = self.data.ArriveAt - self.data.CreatedAt
        self.refreshBarFunc()
        self:Schedule(self.refreshBarFunc, 1, true)
    else
        self._groupProgress.visible = true
        self._textLevel.text = ""
        self._textProgress.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RADAR_ATTACK_TEXT")
        self._progress.value = 0
    end

    --7级解锁成员数量
    if (buildLevel > 6 or category == Global.MissionAssit or category == Global.MissionAISiege) or self.data.IsCustomEvent then
        self._groupMember.visible = true
        local memberCount = 0
        for i = 1, #self.data.Armies do
            memberCount = memberCount + self.data.Armies[i].Amount
        end
        self._textMemberNum.text = Tool.FormatNumberThousands(memberCount)
    else
        self._groupMember.visible = false
    end
    self._groupLevel.visible = buildLevel > 8

    --7级解锁巨兽信息 11级解锁敌方部队  侦查不显示兵力  援助要显示兵力
    if (((buildLevel > 6 or category == Global.MissionAssit or category == Global.MissionAISiege) and category ~= Global.MissionSpy) or self.data.IsCustomEvent)  and self.data.IsCustomEvent ~=1004 then
        if #self.data.Missions > 1 then
            self._typeController.selectedIndex = 1
            for i = 1, #self.data.Missions do
                local item = self._memberContent:AddItemFromPool()
                item:Init(self.data.Missions[i])
            end
        else
            self._typeController.selectedIndex = 0
            -- self._memberContent.numItems = #self.membersList
            self._armiesContent:RemoveChildrenToPool()
            local item = self._armiesContent:AddItemFromPool()
            item:Init(self.data, 0, category)
        end
    else
        self._typeController.selectedIndex = 0
        self._armiesContent:RemoveChildrenToPool()
        self._memberContent:RemoveChildrenToPool()
    end
    --26级解锁敌方科技
    if (buildLevel > 25 or category == Global.MissionAISiege) then
    end
    --29级解锁敌方技能
    if (buildLevel > 28 or category == Global.MissionAISiege) then
    end
end
return RadarDetail
