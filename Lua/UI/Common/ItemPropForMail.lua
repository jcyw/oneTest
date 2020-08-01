--author: 	Amu
--time:		2019-10-24 15:52:14
local GD = _G.GD
local ItemPropForMail = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/itemPropForMail", ItemPropForMail)

function ItemPropForMail:ctor()
    self._ctr = self:GetController("c1")
    self._groupMid.visible = false
end
--data.Category
--data.Amount
--data.ConfId
function ItemPropForMail:SetData(itemInfo)
    local url
    local bgUrl
    if itemInfo.Category == REWARD_TYPE.Res then
        local resConfigInfo = ConfigMgr.GetItem("configResourcess", math.ceil(itemInfo.ConfId))
        url = GD.ResAgent.GetIconUrl(math.ceil(itemInfo.ConfId))
        bgUrl = GD.ItemAgent.GetItmeQualityByColor(resConfigInfo.color)
    elseif itemInfo.Category == REWARD_TYPE.Item then
        local itemConfigInfo = ConfigMgr.GetItem("configItems", math.ceil(itemInfo.ConfId))
        url = UITool.GetIcon(itemConfigInfo.icon, self._icon)
        bgUrl = GD.ItemAgent.GetItmeQualityByColor(itemConfigInfo.color)
    end
    local _icon = url
    if not _icon then
        _icon = url
    end
    self._icon.icon = _icon
    self._bg.url = bgUrl
    self._groupMid.visible = false
end

function ItemPropForMail:SetAmount(amount)
    self._amount.text = amount
end

function ItemPropForMail:SetIcon(icon)
    self._icon.icon = icon
end

function ItemPropForMail:SetImg(icon)
    self._icon.icon = UITool.GetIcon(icon)
end

function ItemPropForMail:SetControl(num)
    self._ctr.selectedIndex = num
end
function ItemPropForMail:SetQuality(color)
    self._bg.url = GD.ItemAgent.GetItmeQualityByColor(color)
end

function ItemPropForMail:SetAmountMid(confId, isIcon)
    local config = GD.ItemAgent.GetItemModelByConfId(confId)
    local mid = GD.ItemAgent.GetItemInnerContent(confId)
    if mid then
        self._groupMid.visible = true
        self._amountMid.text = mid
        GD.ItemAgent.SetMiddleBg(self._numBg, config.color)
    else
        self._groupMid.visible = false
    end

    if isIcon then
        local conf = ConfigMgr.GetItem("configItems", math.ceil(confId))
        self._icon.icon = UITool.GetIcon(conf.icon, self._icon)
    end
end

function ItemPropForMail:SetMiddleActive(active)
    self._groupMid.visible = active
end

-- function ItemPropForMail:SetAmountMidText(midStr)
--     self._amountMid.text = midStr
-- end

return ItemPropForMail
