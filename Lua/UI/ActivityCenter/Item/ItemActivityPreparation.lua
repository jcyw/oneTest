--author: 	maxiaolong
--time:		2020-1-13 11:56:19
local GD = _G.GD
local ItemActivityPreparation = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemActivityPreparation", ItemActivityPreparation)
local MIN_HEIGHT = 100 --文本框最低高度
local MAX_HEIGHT = 148 --文本框最大高度
function ItemActivityPreparation:ctor()
    self._textName = self:GetChild("textActivityName1")
    self._textTime = self:GetChild("textTime")
    self._startTime = self:GetChild("textTime")
    --self._desText = self:GetChild("text")
    self._textName1 = self:GetChild("textActivityName2")
    self._awardList = self:GetChild("liebiao")

    self._awardList.itemRenderer = function(index, item)
        local configData = self.awrardData[index + 1]
        local title = GD.ItemAgent.GetItemNameByConfId(configData.id)
        local midStr = GD.ItemAgent.GetItemInnerContent(configData.id)
        item:SetAmount(configData.icon, configData.color, nil, title, midStr)
    end
    self:InitEvent()
    MAX_HEIGHT = self._label.height
end

function ItemActivityPreparation:InitEvent()
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon,"UI_ACTIVITY_DESC")
    self._textName1.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_REWARD")
    ConfirmPopupTextUtil.SetContent(MIN_HEIGHT,MAX_HEIGHT,self._label,StringUtil.GetI18n(I18nType.Commmon, "STORY_LIMIT_RACE"))
end

function ItemActivityPreparation:SetData(awards,startTime)
    local nums = #awards
    self.awrardData = awards
    self._awardList.numItems = nums
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
    local function get_time()
        return startTime - Tool.Time()
    end
    if get_time() > 0 then
        local refreshTimeFunc = function()
            self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TIME_RENEW", {time = Tool.FormatTime(get_time())})
        end
        self.cd_func = function()
            if get_time() >= 0 then
                refreshTimeFunc()
                return
            else
                self:UnSchedule(self.cd_func)
                Event.Broadcast(EventDefines.CloseActivityUI)
                --Event.Broadcast(EventDefines.RefreshActivityUI)
                self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TIME_RENEW", {time = "24:00:00"})
            end
        end
        self:Schedule(self.cd_func, 1)
    end
end

return ItemActivityPreparation
