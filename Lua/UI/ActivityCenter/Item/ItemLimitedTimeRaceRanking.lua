--[[
    author:{maxiaolong}
    time:2020-01-14 20:16:09
    function:{desc}
]]
local ItemLimitedTimeRaceRanking = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemLimitedTimeRaceRanking", ItemLimitedTimeRaceRanking)
local ActivityModel = import("Model/ActivityModel")
local WelfareModel = import("Model/WelfareModel")
function ItemLimitedTimeRaceRanking:ctor()
    self._titleName = self:GetChild("titleName")
    self._btnHelp = self:GetChild("btnHelp")
    self._integralText = self:GetChild("textIntegral")
    self._list = self:GetChild("liebiaoRanking")
    self._btnView = self:GetChild("btnView")
    self._btnView:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_VIEW_ALL_REWARD")
    self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "STAGE_RANK_REWARD")
    self._integralText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RANK_NUMBER", {num = 1})
    self._list.scrollPane.touchEffect = false
    self._list.itemRenderer = function(index, item)
        local itemData = self.itemData[index + 1]
        item:SetData(itemData)
    end
    self:AddListener(self._btnView.onClick,
        function()
            UIMgr:Open("LimitedTimeRaceRankingAward", self.stageId)
        end
    )
    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                info = StringUtil.GetI18n(I18nType.Commmon, "EXPLAIN_LIMIT_RACE_RANK")
            }
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )
end

function ItemLimitedTimeRaceRanking:SetData(confId)
    self.stageId = confId
    local rankAwards = ActivityModel.GetRankAwards(confId)
    local itemData, listNum = ActivityModel.GetItemRewardConfig(rankAwards[1].id)
    self.giftNum = listNum
    self.itemData = itemData
    self._list.numItems = self.giftNum
    self._list:ResizeToFit(self._list.numChildren)
end

return ItemLimitedTimeRaceRanking
