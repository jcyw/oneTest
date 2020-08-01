--author: 	Amu
--time:		2019-12-03 11:56:19

local ItemActivityCenterCalendar2 = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemActivityCenterCalendar2", ItemActivityCenterCalendar2)

function ItemActivityCenterCalendar2:ctor()
    self._textName = self:GetChild("textName")
    self._textTime = self:GetChild("textTime")

    self:InitEvent()
end

function ItemActivityCenterCalendar2:InitEvent()
end

function ItemActivityCenterCalendar2:SetData(week, monthDay)
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Calendar" .. math.fmod(week, 7))
    self._textTime.text = tostring(monthDay.month) .. "." .. tostring(monthDay.day)
end

return ItemActivityCenterCalendar2
