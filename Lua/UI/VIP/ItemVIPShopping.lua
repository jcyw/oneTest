--author: 	Amu
--time:		2019-08-20 11:45:17
local GD = _G.GD
local ShopModel = import("Model/ShopModel")

local ItemVIPShopping = fgui.extension_class(GComponent)
fgui.register_extension("ui://VIP/itemVIPShopping", ItemVIPShopping)

function ItemVIPShopping:ctor()
    --self._itemProp = self:GetChild("itemProp")
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
    self._hotText = self:GetChild("textHot")
    self:InitEvent()
end

function ItemVIPShopping:InitEvent()
    self:AddListener(self._btnBuy.onClick,
        function()
            if Model.Player.VipLevel < self.vipItemInfo.vip_limit then
                TipUtil.TipById(50256)
                return
            end
            local itemInfo = {
                ConfId = self.vipItemInfo.item_id.item,
                Id = self._info.VipGoods.Id,
                Amount = self._info.VipGoods.Amount
            }
            local gold = {
                Amount = self.vipItemInfo.price,
                type = self.vipItemInfo.price_type
            }
            UIMgr:Open("UnionShopReplenishment", SHOP_TYPE.VipShop, itemInfo, gold)
        end
    )

    self:AddListener(self._iconClick.onTouchBegin,
        function()
            if not self._info then
                return
            end
            local id = self.vipItemInfo.item_id.item
            local amount = self._info.VipGoods.Amount
            local icon = self._itemProp
            local title = GD.ItemAgent.GetItemNameByConfId(id)
            self.detailPop:OnShowUI(title, GD.ItemAgent.GetItemDescByConfId(id), icon, false)
            local worldPos = icon:LocalToGlobal(icon.xy)
            self._par:SetDetailItem(self)
        end
    )

    self:AddListener(self._iconClick.onTouchEnd,
        function()
            self._par:SetDetailItem()
            self:HideTip()
        end
    )
    self:AddListener(self._iconClick.onRollOut,function()
        self.detailPop:OnHidePopup()
    end)
end

function ItemVIPShopping:HideTip()
    self.detailPop:OnHidePopup()
end

function ItemVIPShopping:SetData(info, _par)
    self._par = _par
    self._info = info

    self:RefreshItem()
end

function ItemVIPShopping:RefreshItem()
    self.vipItemInfo = ConfigMgr.GetItem("configVipShops", self._info.VipGoods.Id)
    self.itemInfo = ConfigMgr.GetItem("configItems", self.vipItemInfo.item_id.item)
    if self.vipItemInfo.discount < 1 then
        -- self._itemProp:SetHotText(TextUtil:GetDisCountText(math.modf(self.vipItemInfo.discount * 100 / 10)))
        -- self._hotText.text = TextUtil:GetDisCountText(math.modf(self.vipItemInfo.discount * 100 / 10))
        local disCount = math.floor(self.vipItemInfo.discount * 10) 
        self._hotText.text = TextUtil:GetDisCountText(disCount)
        self._itemProp:SetHotActive(false)
    end
    self._title.text = GD.ItemAgent.GetItemNameByConfId(self.vipItemInfo.item_id.item)
    -- self._textLimitedNum.text = self._info.VipGoods.Amount
    self._btnBuy.text = self.vipItemInfo.price
    if self.itemInfo then
        local image = self.itemInfo.icon
        local color = self.itemInfo.color or 0
        local quality = color
        self._itemProp:SetPage("false")
        -- GD.ItemAgent
        self._itemProp:SetShowData(image, quality, 1, nil, GD.ItemAgent.GetItemInnerContent(self.itemInfo.id))
    end
    -- VipActivated
    if Model.Player.VipActivated then -- 激活
        if Model.Player.VipLevel >= self.vipItemInfo.vip_limit then
            self._textLimited.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Store_Amount", {store_item_amount = self._info.VipGoods.Amount})
            if self._info.VipGoods.Amount > 0 then
                self._btnBuy.enabled = true
            else
                self._btnBuy.enabled = false
            end
        else
            self._btnBuy.enabled = false
            self._textLimited.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Store_Lev", {vip_level = self.vipItemInfo.vip_limit})
        end
    else -- 未激活
        self._textLimited.text = ConfigMgr.GetI18n("configI18nCommons", "Vip_Store_Activate")
        self._btnBuy.enabled = false
    end
    self._itemProp:SetAmountActive(false)
end

function ItemVIPShopping:SetChoose(flag)
    self._item:SetChoose(flag)
end

function ItemVIPShopping:GetData()
    return self._info
end

return ItemVIPShopping
