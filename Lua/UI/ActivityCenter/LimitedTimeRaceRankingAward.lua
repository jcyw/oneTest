--[[
    author:{author}
    time:2020-01-15 16:35:22
    function:{desc}
]]
local LimitedTimeRaceRankingAward = UIMgr:NewUI("LimitedTimeRaceRankingAward")
local ActivityModel = import("Model/ActivityModel")

function LimitedTimeRaceRankingAward:OnInit()
    self._view = self.Controller.contentPane
    self._touch = self._view:GetChild("bgMask")
    self._closeBtn = self._view:GetChild("btnClose")
    self._list = self._view:GetChild("liebiao")
    self._title = self._view:GetChild("titleName")
    self:AddListener(self._closeBtn.onClick,
        function()
           UIMgr:Close("LimitedTimeRaceRankingAward")
        end
    )
    self:AddListener(self._touch.onClick,
        function()
           UIMgr:Close("LimitedTimeRaceRankingAward")
        end
    )
    self._list:SetVirtual()
    self._list.itemRenderer = function(index, item)
        item:SetData(self.awards[index + 1], index + 1, self.isMax)
    end
end

function LimitedTimeRaceRankingAward:OnOpen(stageId, isMax)
    local awards = nil
    if isMax then
        awards = ActivityModel.GetMaxPowerRanks()
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_STRONGEST_REWARD")
    else
        awards = ActivityModel.GetRankAwards(stageId)
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "STAGE_RANK_REWARD")
    end
    self.isMax = isMax
    local index = 1
    self.awards = awards
    self._list.numItems = #awards
    self._list.scrollPane:ScrollTop()
end

function LimitedTimeRaceRankingAward:OnClose()
end

return LimitedTimeRaceRankingAward
