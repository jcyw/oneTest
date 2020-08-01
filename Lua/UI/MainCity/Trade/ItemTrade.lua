--author: 	Amu
--time:		2019-08-12 14:12:06
local GD = _G.GD
local ShopModel = import("Model/ShopModel")
local WelfareModel = import("Model/WelfareModel")
local ItemTrade = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemTrade", ItemTrade)

ItemTrade.tempList = {}

function ItemTrade:ctor()
    --self._icon = self:GetChild("icon")
    self._textDiscount = self:GetChild("textDiscount")
    self._textName = self:GetChild("textName")
    --self._textNum = self:GetChild("textNum")
    self._btnBuy = self:GetChild("btnBuy")
    self._iconGold = self._btnBuy:GetChild("icon")
    --self._iconBg = self:GetChild("iconBg")
    self._textGoldNum = self._btnBuy:GetChild("title")
    self._textDiscountBefore = self._btnBuy:GetChild("textDiscountBefore")

    self._btnBuy2 = self:GetChild("btnBuy2")
    self._iconGold2 = self._btnBuy2:GetChild("icon")
    self._textGoldNum2 = self._btnBuy2:GetChild("title")

    self._ctrView2 = self:GetController("c2")
    self._ctrView3 = self:GetController("c3")

    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")

    self:InitEvent()
end

function ItemTrade:InitEvent()
    self:AddListener(self._btnBuy.onClick,
        function()
            UIMgr:Open("Trade/TradeTips", SHOP_TYPE.SpecialShop, self.info)
        end
    )

    self:AddListener(self._btnBuy2.onClick,
        function()
            UIMgr:Open("Trade/TradeTips", SHOP_TYPE.SpecialShop, self.info)
        end
    )
end

function ItemTrade:SetData(info)
    self.info = info
    self:ClearListener(self._btnIcon.onTouchBegin)
    self:ClearListener(self._btnIcon.onTouchEnd)
    self:ClearListener(self._btnIcon.onRollOut)
    -- local num, items = WelfareModel:GetGiftInfoById(self.info.configInfo.item, 2)
    local num, items, icon, name, midNum, color
    local giftConfig = ConfigMgr.GetItem("configGifts", tonumber(self.info.configInfo.item))
    if giftConfig.res then
        items = ConfigMgr.GetItem("configResourcess", tonumber(giftConfig.res[1].category))
        name = StringUtil.GetI18n(I18nType.Commmon,items.key)
        num = giftConfig.res[1].amount
        icon = items.img128
        midNum = nil
        color = items.shop_color
    elseif giftConfig.items then
        items = ConfigMgr.GetItem("configItems", tonumber(giftConfig.items[1].confId))
        num = giftConfig.items[1].amount
        icon = items.icon
        name = GD.ItemAgent.GetItemNameByConfId(items.id)
        midNum = GD.ItemAgent.GetItemInnerContent(items.id)
        color = items.color

        self:AddListener(self._btnIcon.onTouchBegin,function()
            self.detailPop:InitLabel(GD.ItemAgent.GetItemNameByConfId(items.id), GD.ItemAgent.GetItemDescByConfId(items.id), self._icon, false)
        end)
        self:AddListener(self._btnIcon.onTouchEnd,function()
            self.detailPop:OnHidePopup()
        end)
        self:AddListener(self._btnIcon.onRollOut,function()
            self.detailPop:OnHidePopup()
        end)
    end
    local itemConfig = items
    --[[self._icon.icon = UITool.GetIcon(icon)
    if midNum then
        self._groupMid.visible = true
        self._amountMid.text = midNum
        GD.ItemAgent.SetMiddleBg(self._numBg, color)
    else
        self._groupMid.visible = false
    end

    self._iconBg.icon = GD.ItemAgent.GetItmeQualityByColor(color)]]
    self._item:SetShowData(icon,color,nil,nil,midNum)
    -- self._textName.text = GD.ItemAgent.GetItemNameByConfId(itemConfig.id)
    self._textName.text = name .. UITool.GetTextColor(GlobalColor.Yellow, "x" .. Tool.FormatNumberThousands(num))
    --self._textNum.text = "x" .. Tool.FormatNumberThousands(num)
    self:UpdateLightEffect(info.configInfo.effect)

    if info.configInfo.value >= 1 then
        self._ctrView3.selectedIndex = 0
    else
        self._ctrView3.selectedIndex = 1
    end
    if not info.configInfo.original_price or info.configInfo.price == info.configInfo.original_price then
        self._ctrView2.selectedIndex = 1
        self._textGoldNum2.text = Tool.FormatNumberThousands(info.configInfo.price)
        self._iconGold2.icon = ShopModel:GetGoldIconByType(self.info.configInfo.price_type)
    else
        self._ctrView2.selectedIndex = 0
        self._textDiscountBefore.text = info.configInfo.original_price
        self._textGoldNum.text = Tool.FormatNumberThousands(info.configInfo.price)
        self._iconGold.icon = ShopModel:GetGoldIconByType(self.info.configInfo.price_type)
    end
end

function ItemTrade:GetData()
    return self.info
end

--刷新特效颜色
function ItemTrade:UpdateLightEffect(index)
    local function remove_pool()
        if self.color then
            NodePool.Set(NodePool.KeyType.ShopLightEffect .. self.color, self._light)
            self.color = nil
        end
    end
    if not index or index == 0 then
        remove_pool()
        return
    end
    if self.index and index == self.index then
        return
    end
    remove_pool()
    self.index = index
    self.color = CommonType.SHOP_EFFECT_COLOR[index]
    NodePool.Init(NodePool.KeyType.ShopLightEffect .. self.color, "Effect", "EffectNode")
    self._light = NodePool.Get(NodePool.KeyType.ShopLightEffect .. self.color)
    self._light.xy = Vector2(0, 0)
    self._effectNode:AddChild(self._light)
    self._light:PlayEffectSingle("effects/effect_shop_icon/prefab/effect_shop_icon_" .. self.color)
end

return ItemTrade
