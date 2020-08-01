--[[
    Author: songzeming
    Function: (高级)幸运币使用或购买 item
]]
local GD = _G.GD
local ItemRangeChip = fgui.extension_class(GComponent)
fgui.register_extension('ui://Casino/itemRangeChip', ItemRangeChip)

import("UI/Common/ItemPropBig")
local FROM = {
    Normal = "Normal",
    High = "High"
}

function ItemRangeChip:ctor()
    self._gold = self._btnBuy:GetChild("text")
    self:AddListener(self._btnBuy.onClick,function()
        self:OnBtnBuyClick()
    end)
    self:AddListener(self._btnUse.onClick,function()
        self:OnBtnUseClick()
    end)
end

function ItemRangeChip:Init(from, item, cb)
    self.from = from
    self.item = item
    self.cb = cb

    self._title.text = GD.ItemAgent.GetItemNameByConfId(item.id)
    self._desc.text = GD.ItemAgent.GetItemDescByConfId(item.id)

    self.name = ""
    if from == FROM.Normal then
        self.name = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_3") --幸运币
    elseif from == FROM.High then
        self.name = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_4") --高级幸运币
    end

    self:UpdateData()
end

function ItemRangeChip:UpdateData()
    local itemId = self.item.id
    local conf = ConfigMgr.GetItem("configItems", itemId)
    local mid = Tool.FormatAmountUnit(conf.value)
    if Model.Items[itemId] then
        self._btnUse.visible = true
        self._btnBuy.visible = false
        self._itemProp:SetAmount(self.item.icon, self.item.color, Model.Items[itemId].Amount, nil, mid)
    else
        self._btnUse.visible = false
        self._btnBuy.visible = true
        self._gold.text = UITool.UBBTipGoldText(self.item.price)
        self._itemProp:SetAmount(self.item.icon, self.item.color, 0, nil, mid)
    end
end

--点击购买(高级)幸运币
function ItemRangeChip:OnBtnBuyClick()
    local chooseAmount = 1
    local slide_func = function(amount)
        chooseAmount = amount
        return nil, chooseAmount * self.item.price 
    end
    local buy_func = function()
        if chooseAmount * self.item.price > Model.Player.Gem then
            --金币不足提示
            UITool.GoldLack()
            return
        end
        local net_func = function()
            local v = {
                item_name = self.name,
                item_num = self.item.value * chooseAmount
            }
            TipUtil.TipById(50031, v, self.item.icon)
            self.cb(v.item_num)
        end
        Net.Items.BuyAndUse(self.item.id, chooseAmount, net_func)
    end
    local max = math.floor(Model.Player.Gem / self.item.price)
    if max == 0 then
        --金币不足
        UITool.GoldLack()
        return
    end
    local data = {
        max = max,
        content = StringUtil.GetI18n(I18nType.Commmon, "Onsale_Tips2"),
        gold = chooseAmount * self.item.price,
        ctrType = "Icon",
        item = self.item,
        iconContent = self._desc.text,
        initMax = 1,
        slideCallback = slide_func,
        sureCallback = buy_func
    }
    UIMgr:Open("ConfirmPopupSlide", data)
end

--点击使用(高级)幸运币
function ItemRangeChip:OnBtnUseClick()
    local itemAmount = Model.Items[self.item.id].Amount
    local chooseAmount = itemAmount
    local choose_func = function(cAmount)
        chooseAmount = cAmount
    end
    local use_func = function()
        local net_func = function()
            --使用道具成功
            local v = {
                item_name = self.name,
                item_num = self.item.value * chooseAmount
            }
            TipUtil.TipById(50031, v, self.item.icon)
            self.cb(v.item_num)
        end
        Net.Items.Use(self.item.id, chooseAmount, nil, net_func)
    end
    local data = {
        max = itemAmount,
        content = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_USE_TIPS", {item_name = self._title.text}),
        ctrType = "Text",
        slideCallback = choose_func,
        sureCallback = use_func
    }
    UIMgr:Open("ConfirmPopupSlide", data)
end

return ItemRangeChip
