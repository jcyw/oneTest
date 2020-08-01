--[[
	author : zixiao,maxiaolong
	time : 2019-11-20 09:50:34
	function : 七日活动
]] --
local SevenDayActivities = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/SevenDayActivities", SevenDayActivities)

local WelfareModel = import("Model/WelfareModel")
local WelfareCuePointModel = import("Model/CuePoint/WelfareCuePointModel")
local isRefresh = false --是否正在刷新页面
local GetAwardFunc = nil --获取奖励保存的方法

function SevenDayActivities:ctor()
    self._anim = self:GetTransition("inAnim")
    self._btnHelp = self:GetChild("btnHelp")
    self._componentBox = self:GetChild("box")
    self._btnDays = {}
    self._btnDaysPosiX = {} --记录x坐标 用于动画还原 免得狂点出现动画bug
    for i = 1, 5 do
        self._btnDays[i] = self:GetChild("btnDays" .. i)
        self._btnDays[i].text = StringUtil.GetI18n(I18nType.Commmon, "ROAD_GROWTH_DAYS", {num = i})
        self._btnDaysPosiX[i] = self._btnDays[i].x
        self:AddListener(
            self._btnDays[i].onClick,
            function()
                self:SwitchDay(i)
            end
        )
    end
    self._tags = {}
    self._tagsPosiX = {} --记录x坐标 用于动画还原 免得狂点出现动画bug
    for i = 1, 3 do
        self._tags[i] = self:GetChild("tag" .. i)
        self._tagsPosiX[i] = self._tags[i].x
        self:AddListener(
            self._tags[i].onClick,
            function()
                self:SwitchTag(i)
            end
        )
    end
    self._list = self:GetChild("liebiao")
    self._list:SetVirtual()
    self._list.itemRenderer = function(index, item)
        item:SetData(self.currPageInfos[index + 1])
        item:SetDay(self.day, self.today)
    end
    self._textDescribeNum = self:GetChild("textDescribeNum")
    self._textSalvation = self:GetChild("textSalvation")

    self._ctr1 = self:GetController("c1")
    self._ctr2 = self:GetController("c2")
    self._ctr3 = self:GetController("c3")
    self:AddListener(
        self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "ROAD_GROWTH_NAME"),
                info = StringUtil.GetI18n(I18nType.Commmon, "ROAD_GROWTH_EXPLAIN")
            }
            UIMgr:Open("ConfirmPopupTextCentered", data)
        end
    )

    self.day = 1
    self.tag = 1
    self:InitText()

    --[[
        infos = {Day, Tasks = {CurrentProcess,Id,Status}}
    ]]
    if WelfareModel.IsActivityOpen(WelfareModel.WelfarePageType.SEVEN_DAY_ACTIVITY) then
        self:RequestInfos()
    end

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.WelfareRookieGrowth)

    --领取奖励后的界面刷新
    self:AddEvent(
        EventDefines.SevenDayContentRefresh,
        function(id, day)
            self:GetAward(id, day)
        end
    )
end

function SevenDayActivities:InitText()
    self._textSalvation.text = StringUtil.GetI18n(I18nType.Commmon, "ROAD_GROWTH_DESC")
    local confs = ConfigMgr.GetList("configSevenDayShows")
    self.tagsText = {}
    for _, info in ipairs(confs) do
        self.tagsText[info.day] = self.tagsText[info.day] or {}
        local text = StringUtil.GetI18n(I18nType.Commmon, info.taskText)
        table.insert(self.tagsText[info.day], text)
    end
end

function SevenDayActivities:OnOpen(index)
    self:SetShow(true)
    self:RequestInfos()
    self.day = 1
    self.tag = 1
    -- self:RefreshAll()
    self:PlayAnim()
end

function SevenDayActivities:SwitchTag(tag)
    self.tag = tag
    self:RefreshWindow()
end

function SevenDayActivities:SwitchDay(day)
    self.day = day
    self.tag = 1
    self:RefreshDayPage()
end

function SevenDayActivities:RefreshBonus()
    if not self.awards then
        return
    end
    self._componentBox:SetAward(self.awards)
    self._componentBox:SetProgress(self.score)
end

function SevenDayActivities:RefreshAll()
    if not self.infos then
        return
    end
    for i = 1, 5 do
        if i > self.today then
            self._btnDays[i]:GetChild("lock").visible = true
        else
            self._btnDays[i]:GetChild("lock").visible = false
        end
    end
    self:RefreshDayPage()
end

function SevenDayActivities:RefreshDayPage()
    for i = 1, 3 do
        self._tags[i].text = self.tagsText[self.day][i]
    end
    self._ctr3.selectedIndex = self.day > self.today and 1 or 0
    self:RefreshWindow()
end

function SevenDayActivities:RefreshWindow()
    self._ctr1.selectedIndex = self.day - 1
    self._ctr2.selectedIndex = self.tag - 1
    self.currPageInfos = self.infos[self.day][self.tag]
    table.sort(
        self.currPageInfos,
        function(a, b)
            if a.CurrentProcess and b.CurrentProcess or (not a.CurrentProcess and not b.CurrentProcess and a.Acknowledged == b.Acknowledged) then
                -- 都未完成,或者都完成且已经领取,或者都完成且都未领取
                return a.Id < b.Id
            end

            if a.CurrentProcess and not b.CurrentProcess then -- 一个未完成一个完成,如果领奖了则在后,未领奖在前
                return b.Acknowledged
            end

            if not a.CurrentProcess then -- 两个都完成,一个已经领取一个未领取的情况。以及上面的另一种情况
                return not a.Acknowledged
            end
        end
    )
    self._list.numItems = #self.currPageInfos
    self._textDescribeNum.text = self.score
    self:RefreshCuePoint()
end

function SevenDayActivities:RequestInfos()
    WelfareModel.SevenDaysActivityInfo(
        function(rsp)
            --刷新提示点
            WelfareCuePointModel:CheckRookieGrowthPoint(rsp)
            self.finished = rsp.Finished
            self.score = rsp.Score
            self.today = rsp.Today
            local infos = rsp.Infos
            self.awards = rsp.Awards
            self.infos = {}
            for _, info in ipairs(infos) do
                local tasks = info.Tasks
                local t = self.infos[info.Day] or {}
                for _, task in ipairs(tasks) do
                    local item = ConfigMgr.GetItem("configSevenDayTasks", task.Id)
                    local tabType = item.tab % 3
                    if tabType == 0 then
                        tabType = 3
                    end
                    local tab = t[tabType] or {}
                    table.insert(tab, task)
                    t[tabType] = tab
                end
                self.infos[info.Day] = t
            end
            for _, info in ipairs(self.finished) do
                local day = info.Day
                local t = self.infos[day] or {}
                for _, task in ipairs(info.Tasks) do
                    local item = ConfigMgr.GetItem("configSevenDayTasks", task.Id)
                    local tabType = item.tab % 3
                    if tabType == 0 then
                        tabType = 3
                    end
                    local tab = t[tabType] or {}
                    table.insert(tab, task)
                    t[tabType] = tab
                end
                self.infos[day] = t
            end
            self:RefreshAll()
            self:RefreshBonus()
        end
    )
end

function SevenDayActivities:GetAward(id, day)
    local item = ConfigMgr.GetItem("configSevenDayTasks", id)
    local tag = item.tab % 3
    if tag == 0 then
        tag = 3
    end
    local dayInfo = self.infos[day]
    if next(dayInfo) then
        local tagInfo = dayInfo[tag]
        for _, v in ipairs(tagInfo) do
            if id == v.Id and not v.Acknowledged then
                v.Acknowledged = true
                self.score = self.score + 1
                self:RefreshBonus()
                self:RefreshWindow()
                return
            end
        end
    end
end

function SevenDayActivities:SetShow(isShow)
    self.visible = isShow
end

function SevenDayActivities:PlayAnim()
    for i = 1, #self._tags do
        local item = self._tags[i]
        item.x = self._tagsPosiX[i]
        AnimationLayer.UIHorizontalMove(self, item, i, 0.1, AnimationType.UILeftToRight, -self._bgTag.width)
    end
    for i = 1, #self._btnDays do
        local item = self._btnDays[i]
        item.x = self._btnDaysPosiX[i]
        AnimationLayer.UIHorizontalMove(self, item, i, 0.1, AnimationType.UILeftToRight, -self._bgTag.width)
    end
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        GTween.Kill(item)
        item.x = -item.width
        self:GtweenOnComplete(
            item:TweenMoveX(item.x, 0.1 * i),
            function()
                item:TweenMoveX(0, 0.2)
            end
        )
    end
end

--刷新红点
function SevenDayActivities:RefreshCuePoint()
    --中上
    for _, info in pairs(self.finished) do
        local count = 0
        if info.Day <= self.today then
            for _, v in pairs(info.Tasks) do
                if v.Acknowledged == false then
                    count = 1
                    break
                end
            end
        end
        CuePointModel:SetSingle(CuePointModel.Type.Red, count, self._btnDays[info.Day], CuePointModel.Pos.RightUp2212)
    end
    --中下
    if self.day <= self.today then
        for k, info in pairs(self.infos[self.day]) do
            local count = 0
            for _, v in pairs(info) do
                if v.Acknowledged == false then
                    count = 1
                end
            end
            CuePointModel:SetSingle(CuePointModel.Type.Red, count, self._tags[k], CuePointModel.Pos.RightUp12)
        end
    else
        for i = 1, 3 do
            CuePointModel:SetSingle(CuePointModel.Type.Red, 0, self._tags[i], CuePointModel.Pos.RightUp12)
        end
    end
end

return SevenDayActivities
