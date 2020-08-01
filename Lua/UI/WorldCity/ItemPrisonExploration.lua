--[[
    author:{zhanzhang}
    time:2019-11-19 11:25:45
    function:{秘密基地探索Item}
]]
local ItemPrisonExploration = fgui.extension_class(GButton)
fgui.register_extension("ui://WorldCity/itemPrisonExploration", ItemPrisonExploration)

---ItemPrisonExploration   环状操作列表item
function ItemPrisonExploration:ctor()
    self._controller = self:GetController("c1")
    self:OnRegister()
end

function ItemPrisonExploration:OnRegister()
    self.RefreshFunc = function()
        self:RefreshProgress()
    end
    self:AddEvent(
        EventDefines.UIOnClosePrison,
        function()
            self:UnSchedule(self.RefreshFunc)
        end
    )
end

function ItemPrisonExploration:Init(index, data, isLast, startTime)
    self:UnSchedule(self.RefreshFunc)
    self._textNum.text = index
    self.tripIndex = index
    self.startTime = startTime
    if isLast then
        self._text.text = StringUtil.GetI18n(I18nType.Commmon, "Confirm_Explore_Time")
        self._controller.selectedIndex = 1
        self:Schedule(self.RefreshFunc, 1, true)
    else
        -- self._progressImage.
        -- self._textNum
        -- self._text
        -- self._textTime
        self._controller.selectedIndex = 0
        if data.Reward.ConfId == Global.ResPlayerExp then
            self._text.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Explore_Exp", {num = data.Reward.Amount})
        else
            local config = ConfigMgr.GetItem("configResourcess", data.Reward.ConfId)
            self._text.text =
                StringUtil.GetI18n(
                I18nType.Commmon,
                "Ui_Explore_Res",
                {
                    res_type = StringUtil.GetI18n(I18nType.Commmon, config.key),
                    num = data.Reward.Amount
                }
            )
        end
        self._progressImage.fillAmount = 1
    end

    -- Reward:table: 000000008852D470
    -- Amount:41
    -- Category:1
    -- ConfId:6
    -- Type:0
    -- StringUtil.GetI18n(I18nType.Commmon, "UI_Explore_Events", {num = 1})
    -- StringUtil.GetI18n(I18nType.Commmon, "Ui_Explore_Res", {res_type = 1, num = 1})
    -- StringUtil.GetI18n(I18nType.Commmon, "Ui_Explore_Exp", {num = 100})
end

function ItemPrisonExploration:RefreshProgress()
    local delay = Global.SecretBaseRewardTime - math.floor(((Tool.Time() - self.startTime) % Global.SecretBaseRewardTime))
    local filla = 1 - delay / Global.SecretBaseRewardTime
    self._progressImage.fillAmount = filla
    self._textTime.text = TimeUtil.SecondToHMS(delay)
end

return ItemPrisonExploration
