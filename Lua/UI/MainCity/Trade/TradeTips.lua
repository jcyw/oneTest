--author: 	Amu
--time:		2019-08-12 16:55:10
local GD = _G.GD
local ShopModel = import("Model/ShopModel")
local WelfareModel = import("Model/WelfareModel")
local TradeTips = UIMgr:NewUI("Trade/TradeTips")

function TradeTips:OnInit()
    -- body
    self._view = self.Controller.contentPane

    self._bgMask = self._view:GetChild("_btnMask")

    --self._icon = self._view:GetChild("icon")
    --self._iconBg = self._view:GetChild("iconBg")
    self._titleName = self._view:GetChild("titleName")
    self._textCurrent = self._view:GetChild("textCurrent")

    self._centerText = self._view:GetChild("textCurrent2")

    self._btnUse = self._view:GetChild("btnUse")
    self._iconGold = self._btnUse:GetChild("icon")
    self._textGoldNum = self._btnUse:GetChild("text")

    self._ctrView = self._view:GetController("c1")

    self:InitEvent()

    --这个面板都是买一个
    self.buyNum = 1
end

function TradeTips:OnOpen(shopType, itemInfo)
    self.shopType = shopType
    local isRes = false
    local shop_color = 0
    if shopType == SHOP_TYPE.SpecialShop then
        self.Category = itemInfo.Category
        local num, items = WelfareModel:GetGiftInfoById(itemInfo.configInfo.item, 2)
        if not items then
            num, items = WelfareModel:GetGiftInfoById(itemInfo.configInfo.item, 1)
            isRes = true
        end
        self.configInfo = items[1][1]
        self.amount = items[1][2]
        self.price_type = itemInfo.configInfo.price_type
        self.price = itemInfo.configInfo.price
        self._ctrView.selectedIndex = 0
    elseif shopType == SHOP_TYPE.ItemShop then
        self.price_type = RES_TYPE.Diamond
        self.price = itemInfo.price
        self.configInfo = itemInfo
        self._ctrView.selectedIndex = 1
        self._centerText.text = ConfigMgr.GetI18n("configI18nCommons", "Onsale_Tips2")
    end

    if self.price > ShopModel:GetGoldNumByGoldType(self.price_type) then
        self._textGoldNum.color = Color.red
    else
        self._textGoldNum.color = Color.white
    end

    self._iconGold.icon = ShopModel:GetGoldIconByType(self.price_type)
    self._textGoldNum.text = self.price
    local icon = self.configInfo.img128
    if isRes then
        local resName = StringUtil.GetI18n(I18nType.Commmon, self.configInfo.key)
        self._titleName.text = resName
        self._textCurrent.text = resName .. "x"..self.amount
        shop_color = self.configInfo.shop_color
    else
        self._titleName.text = GD.ItemAgent.GetItemNameByConfId(self.configInfo.id)
        self._textCurrent.text = GD.ItemAgent.GetItemDescByConfId(self.configInfo.id)
        icon = self.configInfo.icon
        shop_color = self.configInfo.color
    end

    local mid = GD.ItemAgent.GetItemInnerContent(self.configInfo.id)
    self._item:SetShowData(icon,shop_color,nil,nil,mid)
end

function TradeTips:InitEvent()
    self:AddListener(self._bgMask.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )

    self:AddListener(self._btnUse.onClick,
        function()
            if self.price > ShopModel:GetGoldNumByGoldType(self.price_type) then
                ShopModel:GoldNotEnoughTipByType(self.price_type)
                self:Close()
                return
            end
            if self.shopType == SHOP_TYPE.SpecialShop then
                Net.SpecialShop.BuyGoods(
                    self.Category,
                    function(msg)
                        Event.Broadcast(SPECIAL_SHOP_EVENT.Buy, msg)
                        TipUtil.TipById(50199)
                        self:Close()
                    end
                )
            elseif self.shopType == SHOP_TYPE.ItemShop then
                Net.Items.Buy(
                    self.configInfo.id,
                    self.buyNum,
                    function()
                        Event.Broadcast(HORN_SHOP_EVENT.Buy, self.configInfo.id)
                        TipUtil.TipById(50199)
                        self:Close()
                    end
                )
            end
        end
    )
end

function TradeTips:Close()
    UIMgr:Close("Trade/TradeTips")
end

return TradeTips
