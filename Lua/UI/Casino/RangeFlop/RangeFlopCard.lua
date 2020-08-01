--[[
    Author: songzeming
    Function: 靶场翻牌组件 牌正面
]]
local GD = _G.GD
local RangeFlopCard = fgui.extension_class(GComponent)
fgui.register_extension('ui://Casino/itemRangeCard', RangeFlopCard)

local CTR = {
    Normal = "Normal",
    Flip = "Flip"
}

function RangeFlopCard:ctor()
    self._ctr = self:GetController("Ctr")
    self._ctrFlip = self:GetController("CtrFlip")
    self._card.text = "A"
end

function RangeFlopCard:SetCardVisible(flag)
    self.visible = flag
end

function RangeFlopCard:InitCard(data)
    self._ctr.selectedIndex = data.Card --随机花色
    self:SetCardVisible(true)
    self._multiple.visible = false

    local isResource =  data.Category == CommonType.RANGE_HIGH_CARD_TYPE.Resource
    local isMultiple = data.Category == CommonType.RANGE_HIGH_CARD_TYPE.Multiple
    local icon = nil
    local color = 0
    local mid = nil
    if isResource then
        --资源
        local conf = ConfigMgr.GetItem("configItems", data.RewardId)
        icon = conf.icon
        color = conf.color
        mid = GD.ItemAgent.GetItemInnerContent(data.RewardId)
    elseif isMultiple then
        --翻倍
        icon = nil
        color = 5
        self._multiple.visible = true
        self._multiple.text = "x" .. data.RewardId
    end
    local amount = data.Amount > 0 and data.Amount or nil
    self._item:SetShowData(icon,color,amount,nil,mid)
end

function RangeFlopCard:SetStep(data)
    local values = {
        num = data.Order
    }
    self._textStep.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_26", values)
    self._textStep.visible = true

    if data.Order == 0 then
        --未翻牌
        self._ctrFlip.selectedPage = CTR.Normal
    else
        --已翻牌
        self._ctrFlip.selectedPage = CTR.Flip
        local amount = data.Amount > 0 and data.Amount or nil
        self._item:SetAmountActive(amount)
    end
end

return RangeFlopCard
