--[[
    author:{maxiaolong}
    time:2020-01-17 11:06:20
    function:{desc}
]]
local ItemActivityCenterImage = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemActivityCenterImage", ItemActivityCenterImage)
local ActivityModel = import("Model/ActivityModel")
function ItemActivityCenterImage:ctor()
    self._icon = self:GetChild("icon")
    self._textTime = self:GetChild("textTime")
    self._textDec = self:GetChild("textDec")
    self._textTag = self:GetChild("textTag")
    --self._textTag.icon = UITool.GetIcon(StringUtil.GetI18n(I18nType.WordArt, "3001"))
    self._timeText = self:GetChild("textTime")
    self._touch = self:GetChild("touch")

    self:AddEvent(
        ACTIVITY_COUNTDOWN_EVENT.Banner,
        function()
            self:UnSchedule(self.callback)
        end
    )
    self:AddListener(
        self._touch.onClick,
        function()
            if not self.configData then
                return
            end

            --处于准备阶段的是弹出tips
            if self.readyTill and self.readyTill.id == self.configData.id then
                TipUtil.TipById(50317)
                return
            end

            --打开对应的页面
            if self._info.Open and self.configData.openPanel then
                UIMgr:Open(self.configData.openPanel, self._info)
            elseif self.configData.readyPanel and not self._info.Open then
                UIMgr:Open(self.configData.readyPanel, self._info)
            end
        end
    )
end

function ItemActivityCenterImage:SetData(info)
    --防止设置参数的时候还保留有上次的参数
    self.readyTill = nil
    self._info = nil
    self.configData = nil

    if not info then
        if self.callback then
            self:UnSchedule(self.callback)
        end
        self.configData = nil
        self._textDec.text = ""
        self._icon.icon = UITool.GetIcon(Global.ActivityCentreBanner)
        return
    end

    self.configData = info.Config
    self._info = info

    self._textDec.text = StringUtil.GetI18n(I18nType.Commmon, self.configData.activity_desc)
    self._textTag.text = StringUtil.GetI18n(I18nType.Commmon, self.configData.activity_name)
    self._icon.icon = UITool.GetIcon(self.configData.banner)

    --若有准备时间就切换为准备状态
    if self._info.ReadyTill > Tool.Time() then
        self.readyTill = {}
        self.readyTill["readyTime"] = self._info.ReadyTill
        self.readyTill["id"] = self.configData.id
    end
    if self.callback then
        self:UnSchedule(self.callback)
    end
    self:SetTimer()
end

function ItemActivityCenterImage:SetTimer()
    local timeFunc = function()
        if self.readyTill then
            return self.readyTill.readyTime - Tool.Time()
        elseif Tool.Equal(self.configData.id, 1001001) and self._info.Open then
            return Model.SingleActivity_EndAt and Model.SingleActivity_EndAt - _G.Tool.Time() or self._info.EndAt - _G.Tool.Time()
        elseif self._info.Open then
            return self._info.EndAt - Tool.Time()
        else
            return self._info.StartAt - Tool.Time()
        end
    end
    self.callback = function()
        if not self._info.EndAt then
            return
        end
        local t = timeFunc()
        --到达准备时间后切换回活动开始状态
        if t <= 0 and self.readyTill then
            self.readyTill = nil
            return
        end
        if t <= 0 then
            self:UnSchedule(self.callback)
            return
        end
        if self._info.Open and not self.readyTill then
            self._timeText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Deadline", {time = Tool.FormatTime(t)})
        else
            self._timeText.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_BEGIN_TIME", {time = Tool.FormatTime(t)})
        end
    end
    self:Schedule(self.callback, 1)
end

return ItemActivityCenterImage
