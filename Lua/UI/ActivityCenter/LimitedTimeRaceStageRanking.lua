--[[
    author:{maxiaolong}
    time:2020-01-13 16:52:46
    function:{限时比赛排行榜}
]]
local LimitedTimeRaceStageRanking = UIMgr:NewUI("LimitedTimeRaceActivityPreparation")
function LimitedTimeRaceStageRanking:OnInit()
    self._view = self.Controller.contentPane
    self._c1 = self._view:GetController("c1")
    self._list = self._view:GetChild("liebiao")
    self._title = self._view:GetChild("titleName")
    self._btnClose = self._view:GetChild("btnClose")
    self._nullText = self._view:GetChild("text")
    self._bgBtn = self._view:GetChild("bgMask")
    self._btnHistory = self._view:GetChild("btnHistory")
    self._btnHistory:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_HISTORY_STRONGEST")
    self:AddListener(self._btnHistory.onClick,
        function()
            self:GetNetRank(2)
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:SetClose()
        end
    )
    self:AddListener(self._bgBtn.onClick,
        function()
            self:SetClose()
        end
    )
    self._list:SetVirtual()
    self._list.itemRenderer = function(index, item)
        item:SetData(self.ranks, self.rankCatgroal, index + 1)
    end
end

--isAll如果是真，1为阶段积分，2为总积分
function LimitedTimeRaceStageRanking:OnOpen(isAll)
    local rankCatgroal = isAll and 2 or 1
    self:GetNetRank(rankCatgroal)
end

function LimitedTimeRaceStageRanking:GetNetRank(rankCatgroal)
    Net.LimitTimeMatch.RankInfo(
         rankCatgroal,
        function(info)
            if rankCatgroal == 1 and  next(info.Rank.Ranks) then
                self._c1.selectedIndex = 0
            elseif rankCatgroal == 2 and  next(info.Rank.Ranks) then
                self._c1.selectedIndex = 2
            else
                self._c1.selectedIndex = 1
                self._nullText.text = StringUtil.GetI18n(I18nType.Commmon, "TITTLE_NONE_HISTORY_RANK")
            end

            --TODO目前只显示1组数据
            if rankCatgroal == 1 then
                self.ranks = info.Rank.Ranks
                self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_STAGE_RANK")
            elseif rankCatgroal == 2 then
                self.ranks = info.Rank.Ranks
                self._title.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_HISTORY_STRONGEST")
            end
            self.rankCatgroal = rankCatgroal
            self._list.numItems = #self.ranks
        end
    )
end

function LimitedTimeRaceStageRanking:SetClose()
    UIMgr:Close("LimitedTimeRaceStageRanking")
end

return LimitedTimeRaceStageRanking
