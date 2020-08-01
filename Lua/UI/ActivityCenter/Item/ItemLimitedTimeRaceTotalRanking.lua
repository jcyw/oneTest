--[[
    author:{maxiaolong}
    time:2020-01-14 20:17:15
    function:{desc}
]]
local GD = _G.GD
local ItemLimitedTimeRaceTotalRanking = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemLimitedTimeRaceTotalRanking", ItemLimitedTimeRaceTotalRanking)
local ActivityModel = import("Model/ActivityModel")
local WelfareModel = import("Model/WelfareModel")
function ItemLimitedTimeRaceTotalRanking:ctor()
    self._titleName = self:GetChild("titleName")
    self._btnHelp = self:GetChild("btnHelp")
    self._integral = self:GetChild("textIntegral")
    self._list = self:GetChild("liebiaoRanking")
    self._btnAll = self:GetChild("btnAll")
    self._btnView = self:GetChild("btnView")
    self._btnViewHistory = self:GetChild("btnViewHistory")
    self._list.scrollPane.touchEffect = false
    self._list.itemRenderer = function(index, item)
        item:SetData(self.items[index + 1])
    end
    self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_STRONGEST_REWARD")
    self._integral.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RANK_NUMBER", {num = 1})
    self._btnAll:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_VIEW_ALL_REWARD")
    self._btnView:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_HISTORY_RANK")
    self._btnViewHistory:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_HISTORY_STRONGEST")
    self:AddListener(self._btnAll.onClick,
        function()
            UIMgr:Open("LimitedTimeRaceRankingAward", self.stageId, true)
        end
    )
    self:AddListener(self._btnView.onClick,
        function()
            UIMgr:Open("LimitedTimeRaceStageRanking", false)
        end
    )
    self:AddListener(self._btnViewHistory.onClick,
        function()
            UIMgr:Open("LimitedTimeRaceStageRanking", true)
        end
    )
    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                info = StringUtil.GetI18n(I18nType.Commmon, "EXPLAIN_STRONGEST_REWARD")
            }
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )
end

function ItemLimitedTimeRaceTotalRanking:SetData(data)
    self.stageId = data
    local maxRanks = ActivityModel.GetMaxPowerRanks()[1]
    -- self.giftNum, self.items = WelfareModel:GetGiftInfoById(maxRanks.id, 1)
    local itemData, listNum = ActivityModel.GetItemRewardConfig(maxRanks.id)
    self.items = itemData
    self._list.numItems = listNum

    self._list:ResizeToFit(self._list.numChildren)
end

return ItemLimitedTimeRaceTotalRanking
