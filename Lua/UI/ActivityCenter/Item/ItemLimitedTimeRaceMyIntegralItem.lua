--[[
    author:{author}
    time:2020-01-14 20:47:31
    function:{desc}
]]
local GD = _G.GD
local ItemLimitedTimeRaceMyIntegralItem = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemLimitedTimeRaceMyIntegralItem", ItemLimitedTimeRaceMyIntegralItem)
local WelfareModel = import("Model/WelfareModel")
function ItemLimitedTimeRaceMyIntegralItem:ctor()
    --self._iconBg = self:GetChild("iconBg")
    --self._icon = self:GetChild("icon")
    self._title = self:GetChild("titleName")
    self._integralText = self:GetChild("text")
    --self._amount = self:GetChild("amount")
    self._name = self:GetChild("title")
end

function ItemLimitedTimeRaceMyIntegralItem:SetData(info, index)
    self._integralText.text = info.point
    self.giftNum, self.items = nil
    self.isRes = false
    local resData, itemData = ActivityModel.GetItemConfigById(info.reward)
    local name = nil
    local mid = nil
    local dic = nil
    if resData.Items then
        name = StringUtil.GetI18n(I18nType.Commmon, resData.Items[1][1].key)
        self.items = resData.Items
        self.giftNum = resData.GiftNum
        mid = GD.ItemAgent.GetItemInnerContent(resData.Items[1][1].id)
        dic= name .. "X" .. self.items[1][2]
    else
        name = GD.ItemAgent.GetItemNameByConfId(itemData.Items[1][1].id)
        self.items = itemData.Items
        self.giftNum = itemData.GiftNum
        mid = GD.ItemAgent.GetItemInnerContent(itemData.Items[1][1].id)
        dic = GD.ItemAgent.GetItemDescByConfId(itemData.Items[1][1].id)
    end
    local icon = self.items[1][1].icon
    local color = self.items[1][1].color
    local amount = self.items[1][2]
    --self._iconBg.icon = GD.ItemAgent.GetItmeQualityByColor(color)
    --self._icon.icon = UITool.GetIcon(icon)
    --self._amount.text = amount
    local awardIndex = tostring(index)
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "AWARD_TITLE") .. awardIndex
    self._name.text = name
    self._itemProp:SetShowData(icon,color,amount,nil,mid)
    self._itemProp:SetTipsData({name,dic})
end

return ItemLimitedTimeRaceMyIntegralItem
