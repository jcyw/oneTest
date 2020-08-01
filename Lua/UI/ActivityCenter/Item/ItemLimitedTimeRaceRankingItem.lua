--[[
    author:{maxiaolong}
    time:2020-01-15 15:15:01
    function:{desc}
]]
local GD = _G.GD
local ItemLimitedTimeRaceRankingItem = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemLimitedTimeRaceRankingItem", ItemLimitedTimeRaceRankingItem)

function ItemLimitedTimeRaceRankingItem:ctor()
    --self._bgIocon = self:GetChild("iconBg")
    --self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")
    self._text = self:GetChild("text")
end

function ItemLimitedTimeRaceRankingItem:SetData(data)
    local itemConfig = data.Item[1]
    local itemAmount = data.Item[2]
    local name = nil
    local desc = nil
    if data.IsRes then
        name = StringUtil.GetI18n(I18nType.Commmon, itemConfig.key)
        desc = name .. "X" .. itemAmount
    else
        name = GD.ItemAgent.GetItemNameByConfId(itemConfig.id)
        desc = GD.ItemAgent.GetItemDescByConfId(itemConfig.id)
    end

    --self._bgIocon.icon = GD.ItemAgent.GetItmeQualityByColor(itemConfig.color)
    --self._icon.icon = UITool.GetIcon(itemConfig.icon)
    self._title.text = name
    self._text.text = itemAmount
    local mid = GD.ItemAgent.GetItemInnerContent(itemConfig.id)
    self._itemProp:SetShowData(itemConfig.icon,itemConfig.color,nil,nil,mid)
    self._itemProp:SetTipsData({name,desc})
end

return ItemLimitedTimeRaceRankingItem
