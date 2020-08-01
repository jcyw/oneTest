--[[
    author:{maxiaolong}
    time:2020-01-13 16:05:34
    function:{限时比赛}
]]
local LimitedTimeRace = UIMgr:NewUI("LimitedTimeRace")

local listNum = 3
function LimitedTimeRace:OnInit()
    self.isScroll = true
    self._view = self.Controller.contentPane
    self._title = self._view:GetChild("titleName")
    self._phaseText = self._view:GetChild("textPhase")
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_LIMIT_RACE")
    self.c1 = self._view:GetController("c1")
    self._limitedList = self._view:GetChild("liebiao")
    self._limitedList.scrollItemToViewOnClick = false
    self._bgMask = self._view:GetChild("bgMask")
    self._btnClose = self._view:GetChild("btnClose")
    self._btnIntegral = self._view:GetChild("btnMyIntegral")

    self._btnIntegral:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "UI_INTEGRAL_NOW")
    self._btnRank = self._view:GetChild("btnRanking")
    self._btnRank:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "UI_STAGE_RANK")
    self._btnToalRank = self._view:GetChild("btnTotalRanking")
    self._btnToalRank:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "UI_TOTAL_RANK")

    self._limitedList.itemRenderer = function(index, item)
        if index == 0 then
            item:SetData(
                self.stageId,
                function(timeText)
                    self:EndTimeRender(timeText)
                end,
                self.progressValue
            )
        else
            item:SetData(self.stageId)
        end
    end
    self:AddListener(self._btnClose.onClick,
        function()
             UIMgr:Close("LimitedTimeRace")
        end
    )
    self:AddListener(self._bgMask.onClick,
        function()
             UIMgr:Close("LimitedTimeRace")
        end
    )
    self:AddListener(self._btnIntegral.onClick,
        function()
            self.isScroll = false
            local itemView = self._limitedList:GetChildAt(0)
            self._limitedList.scrollPane:ScrollToView(itemView)
        end
    )
    self:AddListener(self._btnRank.onClick,
        function()
            self.isScroll = false
            local itemView = self._limitedList:GetChildAt(1)
            self._limitedList.scrollPane:ScrollToView(itemView)
        end
    )
    self:AddListener(self._btnToalRank.onClick,
        function()
            self.isScroll = false
            local itemView = self._limitedList:GetChildAt(2)
            self._limitedList.scrollPane:ScrollToView(itemView)
        end
    )
    self:AddListener(self._limitedList.scrollPane.onScroll,
        function()
            self:UpdateController()
        end
    )
    self:AddListener(self._limitedList.onTouchBegin,
        function()
            self.isScroll = true
        end
    )
end

function LimitedTimeRace:OnOpen(info)
    local stageNum = 0
    stageNum = info.Stage + 1
    self.stageNum = stageNum
    self.stageId = info.Param[stageNum]

    self.id = info.Id
    self.infoData = info

    -- 总分，总排行，阶段积分，阶段排行
    --阶段积分， 阶段排名，总排名
    Net.LimitTimeMatch.Info(
        function(params)
            local stageScore = params.StageScore == 0 and "~" or params.StageScore
            local stageRank = params.StageRank == 0 and "5000+" or params.StageRank
            self._btnIntegral:GetChild("num").text = stageScore
            self._btnRank:GetChild("num").text = stageRank
            self._btnToalRank:GetChild("num").text = params.TotalRank
            local stageInfo = ActivityModel.GetStageAward(self.stageId)
            local maxScore = stageInfo[3].point
            self.progressValue = tonumber(params.StageScore)
            self._limitedList.numItems = listNum
        end
    )
    local config = ActivityModel.GetActivityRaceTime(self.stageId)
    local title = StringUtil.GetI18n(I18nType.Commmon, config.tittle)

    local stageStr = StringUtil.GetI18n(I18nType.Commmon, "UI_STAGE")
    self._phaseText.text = stageStr .. stageNum .. "/" .. #info.Param .. title
    self.c1.selectedIndex = 0
    self._limitedList.scrollPane:ScrollTop()
    self.itemHeight = self._limitedList:GetChildAt(0).height
    self.itemHeight1 = self._limitedList:GetChildAt(1).height + self.itemHeight
    self.itemHeight2 = self._limitedList:GetChildAt(2).height + self.itemHeight + self.itemHeight1
end

function LimitedTimeRace:UpdateController()
    if self.isScroll == false then
        return
    end
    local scrollPosY = self._limitedList.scrollPane.scrollingPosY
    if scrollPosY <= self.itemHeight then
        self.c1.selectedIndex = 0
    elseif scrollPosY > self.itemHeight and scrollPosY <= self.itemHeight1 then
        self.c1.selectedIndex = 1
    elseif scrollPosY > self.itemHeight1 and scrollPosY <= self.itemHeight2 then
        self.c1.selectedIndex = 2
    end
end

function LimitedTimeRace:EndTimeRender(timeText)
    self:UnSchedule(self.callbackTime)
    local curStageEndTime = 0
    local activeConfig = ConfigMgr.GetItem("configActivitys", self.id)
    for i = 1, self.stageNum do
        curStageEndTime = curStageEndTime + ConfigMgr.GetItem("configTimeRaces", activeConfig.para[i]).time
    end
    local endTime = self.infoData.StartAt + curStageEndTime
    local mTimeFunc = function()
        return endTime - Tool.Time()
    end
    local time = mTimeFunc()
    self.callbackTime = function()
        timeText.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_OVER_TIME", {time = TimeUtil.SecondToDHMS(time)})
        if time <= 0 then
             UIMgr:Close("LimitedTimeRace")
            return
        end
        time = mTimeFunc()
    end
    self:Schedule(self.callbackTime, 1)
end

function LimitedTimeRace:OnClose()
    self:UnSchedule(self.callbackTime)
    UIMgr:Close("LimitedTimeRaceRankingAward")
    UIMgr:Close("LimitedTimeRaceStageRanking")
    UIMgr:Close("ConfirmPopupTextList")
end

return LimitedTimeRace
