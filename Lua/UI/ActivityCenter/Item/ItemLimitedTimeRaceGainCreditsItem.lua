--[[
    author:{author}
    time:2020-01-15 11:11:31
    function:{desc}
]]
local ItemLimitedTimeRaceGainCreditsItem = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemLimitedTimeRaceGainCreditsItem", ItemLimitedTimeRaceGainCreditsItem)

function ItemLimitedTimeRaceGainCreditsItem:ctor()
    self._title = self:GetChild("title")
    self._text = self:GetChild("text")
    self._icon = self:GetChild("icon")
end

function ItemLimitedTimeRaceGainCreditsItem:SetData(info)
    self._title.text = info.key
    self._text.text = info.value
end

return ItemLimitedTimeRaceGainCreditsItem
