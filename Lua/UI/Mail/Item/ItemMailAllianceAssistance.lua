-- author:{Amu}
-- time:2019-06-13 16:05:45
local GD = _G.GD
local ItemMailAllianceAssistance = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailAllianceAssistance", ItemMailAllianceAssistance)

function ItemMailAllianceAssistance:ctor()
    self._title = self:GetChild("title")
    -- self._posText = self:GetChild("textAllianceName")
    -- self._timeText = self:GetChild("textTime")
    self._numText = self:GetChild("textGoldNum")
    self._icon = self:GetChild("icon")
    self.tempList = {}

    self._icon_x = self._icon.x

    self:InitEvent()
end

function ItemMailAllianceAssistance:InitEvent(  )
end

function ItemMailAllianceAssistance:SetData(index, info, res)
    self._icon.icon = GD.ResAgent.GetIconUrl(res.Category)
    self._title.text = ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_"..math.ceil(res.Category))
    self._numText.text = "+"..Tool.FormatAmountUnit(res.Amount)
end

return ItemMailAllianceAssistance