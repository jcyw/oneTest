--author: 	Amu
--time:		2020-06-13 14:44:11
local GD = _G.GD
local ItemTurntable = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemTurntable", ItemTurntable)

function ItemTurntable:ctor()
    self._textName = self:GetChild("textName")

    self._oldPriceText = self._btnbuy:GetChild("textDiscountBefore")
    self._newPriceText = self._btnbuy:GetChild("title")

    self._listView = self:GetChild("liebiao")

    self:InitEvent()
end

function ItemTurntable:InitEvent(  )
    self:AddListener(self._btnbuy.onClick,function()
        if self.curGiftpackId == self.giftPackConfig.id and self.CanBuy then
            SdkModel.Rcharge37(PurchaseType.ITEM_TYPE_APP, RCHARGE.GiftPack, self.giftPackConfig.id, self.giftPackConfig.giftId)
        else
            if self.CanBuy then
                TipUtil.TipById(50320)
            else
                TipUtil.TipById(50324)
            end
        end
    end)


    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end

        local info = self.itemInfos[index+1]
       

        -- if info.category then
        --     local resConfig = ConfigMgr.GetItem("configResourcess", info.category)
        --     item:GetChild("icon").icon = UITool.GetIcon(resConfig.img)
        --     item:GetChild("iconBg").icon = GD.ItemAgent.GetItmeQualityByColor(resConfig.color)
        --     item:GetChild("textName").text = ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_" .. info.category)
        --     item:GetChild("textTagNumber").text = info.amount
        -- elseif info.confId then
        --     local itemConfig = ConfigMgr.GetItem("configItems", info.confId)
        --     item:GetChild("icon").icon = UITool.GetIcon(itemConfig.icon)
        --     item:GetChild("iconBg").icon = GD.ItemAgent.GetItmeQualityByColor(itemConfig.color)
        --     item:GetChild("textName").text = GD.ItemAgent.GetItemNameByConfId(info.confId)
        --     item:GetChild("textTagNumber").text = string.format("x%d", info.amount)
        -- end

        item:SetData(info)
    end
end

function ItemTurntable:SetData(info, index, curGiftpackId, CanBuy)
    self.curGiftpackId = curGiftpackId
    self.CanBuy = CanBuy
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_LuckyDraw_Package", {number = index})

    local giftConfig = ConfigMgr.GetItem("configGifts", info.giftid)

    self.itemInfos = {} 
    if giftConfig.res then
        for _,res in ipairs(giftConfig.res)do
            table.insert(self.itemInfos, res)
        end
    end
    if giftConfig.items then
        for _,item in ipairs(giftConfig.items)do
            table.insert(self.itemInfos, item)
        end
    end

    self.giftPackConfig = ConfigMgr.GetItem("configGiftPacks", info.purchaseid)
    self.giftPackId = self.giftPackConfig.giftId

    self.curPrice = ShopModel:GetPriceByProductId(self.giftPackConfig.giftId)
    -- self._btnbuy.enabled = true
    if type(self.curPrice) == "number" and self.curPrice > 0 then
        self.originPrice = math.floor(self.giftPackConfig.value_ratio * 0.0001 * self.curPrice * 100) * 0.01
    else
        self.originPrice = 0
    end

    self._oldPriceText.text = ShopModel:GetCodeByProductId(self.giftPackConfig.giftId)..self.originPrice
    self._newPriceText.text = ShopModel:GetCodeAndPriceByProductId(self.giftPackConfig.giftId)

    if self.curGiftpackId == self.giftPackConfig.id and self.CanBuy then
        self._btnbuy.grayed = false
    else
        self._btnbuy.grayed = true
    end

    self:InitListView()
end

function ItemTurntable:InitListView(  )
    self._listView.numItems = #self.itemInfos
end


return ItemTurntable