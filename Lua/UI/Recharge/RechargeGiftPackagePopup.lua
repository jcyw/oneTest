--[[
    author:Temmie
    time:2019-12-24 15:52:57
    function:礼包详细界面弹窗
]]
local GD = _G.GD
local RechargeGiftPackagePopup = UIMgr:NewUI("RechargeGiftPackagePopup")

function RechargeGiftPackagePopup:OnInit()
    self.view = self.Controller.contentPane
    self._textCurPrice = self._btnBuy:GetChild("title")
    self._tipTitle = self._part:GetChild("_titleText")
    self._tipDesc = self._part:GetChild("_contentText")
    self._typeController = self.view:GetController("typeController")
    NodePool.Init(NodePool.KeyType.GiftPaySuccess, "Effect", "EffectNode")

    self:AddListener(self._list.scrollPane.onScroll,function()
        self._part.visible = false
    end)

    self:AddListener(self._bgMask.onClick,function()
        UIMgr:Close("RechargeGiftPackagePopup")
    end)

    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("RechargeGiftPackagePopup")
    end)

    self:AddListener(self._btnBuy.onClick,function()
        if self.isBuy then
            UIMgr:Close("RechargeGiftPackagePopup")
        else
            SdkModel.Rcharge37(PurchaseType.ITEM_TYPE_APP, RCHARGE.GiftPack, self.config.id, self.config.giftId)
            UIMgr:Close("RechargeGiftPackagePopup")
        end
    end)
    
    self:AddListener(self._btnSure.onClick,function()
        UIMgr:Close("RechargeGiftPackagePopup")
    end)
end

function RechargeGiftPackagePopup:OnOpen(config, isBuy)
    self.isBuy = isBuy
    self.config = config
    self.groupConfig = ConfigMgr.GetItem("configGiftGroups", self.config.group_id)
    self.diamond = 0
    self._part.visible = false
    self._typeController.selectedPage = isBuy and "get" or "detail"
    
    self:RefreshList()

    self._titleName.text = isBuy and ConfigMgr.GetI18n(I18nType.Commmon, "TITTLE_PAY_SUCCESS") or ConfigMgr.GetI18n(I18nType.Activitys, self.groupConfig.gift_name)
    self._textIcon.text = self.diamond
    self._textOne.text = self.diamond
    self._textCurPrice.text = isBuy and ConfigMgr.GetI18n(I18nType.Commmon, "BUTTON_YES") or ShopModel:GetCodeAndPriceByProductId(self.config.giftId)
    self._btnSure.text = ConfigMgr.GetI18n(I18nType.Commmon, "BUTTON_YES")

    if isBuy then
        if self.effect then
            NodePool.Set(NodePool.KeyType.GiftPaySuccess, self.effect)
            self.effect = nil
        end
        self.effect = NodePool.Get(NodePool.KeyType.GiftPaySuccess)
        self.view:AddChild(self.effect)
        self.effect:InitNormal()
        self.effect:PlayEffectSingle("effects/recharge/paysuccess/prefab/effect_pay_success")
    else
        if self.effect then
            NodePool.Set(NodePool.KeyType.GiftPaySuccess, self.effect)
            self.effect = nil
        end
    end
end

function RechargeGiftPackagePopup:RefreshList()
    local gifConfig = ConfigMgr.GetItem("configGifts", self.config.gift)
    self._list:RemoveChildrenToPool()
    if gifConfig.res then
        for _,v in pairs(gifConfig.res) do
            if v.category == Global.ResDiamond then
                self.diamond = self.diamond + v.amount
            else
                local resConfig = ConfigMgr.GetItem("configResourcess", v.category)
                local item = self._list:AddItemFromPool()
                local _itemProp = item:GetChild("_item")
                local mid = GD.ItemAgent.GetItemInnerContent(v.category)
                _itemProp:SetShowData(GD.ResAgent.GetIcon(v.category), GD.ResAgent.GetIconQuality(v.category),nil,nil,mid)
                item:GetChild("textName").text = StringUtil.GetI18n(I18nType.Commmon, resConfig.key)
                item:GetChild("textTagNumber").text = v.amount
            end
        end
    end

    if gifConfig.items then
        for _,v in pairs(gifConfig.items) do
            local itemConfig = ConfigMgr.GetItem("configItems", v.confId)
            local item = self._list:AddItemFromPool()
            local _itemProp = item:GetChild("_item")
            local mid = GD.ItemAgent.GetItemInnerContent(itemConfig.id)
            _itemProp:SetShowData(itemConfig.icon,itemConfig.color,nil,nil,mid)
            item:GetChild("textName").text = GD.ItemAgent.GetItemNameByConfId(itemConfig.id)
            item:GetChild("textTagNumber").text = v.amount

            self:ClearListener(item.onTouchBegin)
            self:AddListener(item.onTouchBegin,function()
                self._part.visible = true
                self._tipTitle.text = GD.ItemAgent.GetItemNameByConfId(itemConfig.id)
                self._tipDesc.text = GD.ItemAgent.GetItemDescByConfId(itemConfig.id)
                local pos = item:LocalToRoot(Vector2.zero)
                self._part:SetXY(pos.x + 15, pos.y + (item.height / 2))
            end)
            self:ClearListener(item.onTouchEnd)
            self:AddListener(item.onTouchEnd,function()
                self._part.visible = false
            end)
        end
    end
end

return RechargeGiftPackagePopup