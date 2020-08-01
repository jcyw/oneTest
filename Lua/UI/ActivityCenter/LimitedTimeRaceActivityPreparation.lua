--[[
    author:{maxiaolong}
    time:2020-01-13 16:14:25
    function:{活动准备页}
]]
local LimitedTimeRaceActivityPreparation = UIMgr:NewUI("LimitedTimeRaceActivityPreparation")

function LimitedTimeRaceActivityPreparation:OnInit()
    self._view = self.Controller.contentPane
    self._closeBtn = self._view:GetChild("btnClose")
    self._ActivityTitle = self._view:GetChild("titleName")
    self._btnRank = self._view:GetChild("btnStrongest")
    self._bgMask = self._view:GetChild("bgMask")
    self._limitActivitys = self._view:GetChild("liebiao")
    self._ActivityTitle.text=StringUtil.GetI18n(I18nType.Commmon,"ACTIVITY_LIMIT_RACE")
    self._btnRank:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_HISTORY_STRONGEST")
    self._desTitle=self._view:GetChild("desTitle")
    self._desTitle.text=StringUtil.GetI18n(I18nType.Commmon,"ACTIVITY_LIMIT_RACE")
    self:AddListener(self._btnRank.onClick,
        function()
            UIMgr:Open("LimitedTimeRaceStageRanking", true)
        end
    )

    self:AddListener(self._closeBtn.onClick,
        function()
            self:OnClosePanel()
        end
    )

    self:AddListener(self._bgMask.onClick,
        function()
            self:OnClosePanel()
        end
    )

    self._limitActivitys.itemRenderer = function(index, item)
        item:SetData(self._awardDatas, self.info.StartAt)
    end

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.ActivityLimitedTimeRace)

    self:AddEvent(
        EventDefines.CloseActivityUI,
        function()
            self:OnClosePanel()
        end
    )
end

function LimitedTimeRaceActivityPreparation:OnOpen(info)
    self._awardDatas = ActivityModel.GetActivityAward(info.Id)
    self.info = info
    self._limitActivitys.numItems = 1
end

function LimitedTimeRaceActivityPreparation:OnClosePanel()
    UIMgr:Close("LimitedTimeRaceActivityPreparation")
end

function LimitedTimeRaceActivityPreparation:OnClose()
    UIMgr:Close("LimitedTimeRaceRankingAward")
    UIMgr:Close("LimitedTimeRaceStageRanking")
end

return LimitedTimeRaceActivityPreparation
