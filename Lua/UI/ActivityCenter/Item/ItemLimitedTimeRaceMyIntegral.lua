--[[
    author:{maxiaolong}
    time:2020-01-14 20:15:06
    function:{desc}
]]
local ItemLimitedTimeRaceMyIntegral = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemLimitedTimeRaceMyIntegral", ItemLimitedTimeRaceMyIntegral)
local ActivityModel = import("Model/ActivityModel")
function ItemLimitedTimeRaceMyIntegral:ctor()
    self._title = self:GetChild("titleName")
    self._btnHelp = self:GetChild("btnHelp")
    self._progressBar = self:GetChild("progressBar")
    self._integralList = self:GetChild("liebiaoIntegral")
    self.integralText = self:GetChild("titleGainName")
    self._integralHelp = self:GetChild("btnHelpGain")
    self.list2 = self:GetChild("liebiaoGain")
    self._timeText = self:GetChild("titleTime")
    -- self._btnTest = self:GetChild("n56")
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_POINT_TARGET_REWARD")
    self.integralText.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_POINT")
    self._progressBar.max = 100
    self._integralList.scrollPane.touchEffect = false
    self._integralList.itemRenderer = function(index, item)
        local awardIndex = #self.stageAwards - (index)
        item:SetData(self.stageAwards[awardIndex], awardIndex)
    end
    self.list2.itemRenderer = function(index, item)
        item:SetData(self.typeAwards[index + 1])
    end
    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                info = StringUtil.GetI18n(I18nType.Commmon, "EXPLAIN_LIMIT_RACE_POINT")
            }
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )
    self:AddListener(self._integralHelp.onClick,
        function()
            local configData = ActivityModel.GetActivityRaceTime(self.stageId)
            if configData.desc then
                local des = configData.desc
                local helpDes = StringUtil.GetI18n(I18nType.Commmon, des)
                local data = {
                    title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                    info = helpDes
                }
                UIMgr:Open("ConfirmPopupTextList", data)
            end
        end
    )

end

function ItemLimitedTimeRaceMyIntegral:SetData(confId, func, mScore)
    if func then
        func(self._timeText)
    end
    self.stageId = confId
    local stageData = ActivityModel.GetStageAward(confId)
    local typeAwards = ActivityModel.GetActivityTimeRace(confId)
    self.stageAwards = stageData
    self.typeAwards = typeAwards
    local maxValue = stageData[3].point
    self.maxValue = maxValue
    self.mScore = mScore
    mScore = mScore > maxValue and maxValue or mScore
    local cutProgress = mScore / maxValue * 100
    self._progressBar.value = cutProgress
    self._integralList.numItems = #stageData
    self.list2.numItems = #typeAwards

    self.list2:ResizeToFit(self.list2.numChildren)
end

return ItemLimitedTimeRaceMyIntegral
