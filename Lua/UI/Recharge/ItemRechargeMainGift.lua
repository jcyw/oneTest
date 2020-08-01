--[[
    author:Temmie
    time:2019-12-06 16:02:46
    function:礼包item
]]
local GD = _G.GD
local ItemRechargeMainGift = fgui.extension_class(GComponent)
fgui.register_extension("ui://Recharge/itemRechargeMainGift", ItemRechargeMainGift)

local GiftModel = import("Model/GiftModel")

local itemOriginalWidth = 690

function ItemRechargeMainGift:ctor()
    self._textTitle = self._btnImage:GetChild("title")
    self._textTime = self._btnImage:GetChild("textTime")
    self._textDesc = self._btnImage:GetChild("textExplain")
    self._giftImage = self._btnImage:GetChild("image")
    self._textOrignPrice = self._btnbuy:GetChild("textDiscountBefore")
    self._textCurPrice = self._btnbuy:GetChild("title")
    self.bannerFont = {}
    self.effects = {}
    self.effectItems = {}
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
    
    self.timer_func = function()
        local time = GiftModel.GetRefreshTime(self.config.id) - Tool.Time()
        if time <= 0 then
            self._textTime.text = "00:00:00"
            self:UnSchedule(self.timer_func)
        else
            self._textTime.text = Tool.FormatTime(time)
        end
    end

    self:AddListener(self._btnImage.onClick,function()
        UIMgr:Open("RechargeGiftPackagePopup", self.config, false)
    end)

    EffectTool.AddBtnLightEffect(self._btnbuy, {x = -5, y = -9}, {x = 1.3, y = 1, z = 0.9})
    self:AddListener(self._btnbuy.onClick,function()
        -- self._btnbuy.enabled = false
        SdkModel.Rcharge37(PurchaseType.ITEM_TYPE_APP, RCHARGE.GiftPack, self.config.id, self.config.giftId)

    end)

    self:AddListener(self._list.scrollPane.onScroll,function()
        if self.scrollcb then
            self.scrollcb()
        end

        for _,v in pairs(self.effectItems) do
            v.effect.visible = CommonModel.CheckListItemEffectVisible(v.item, self._list)
        end
    end)
end

function ItemRechargeMainGift:Init(config, isOnlyGift, playAnimm, scrollCb)
    self.config = config
    self.scrollcb = scrollCb
    self.groupConfig = ConfigMgr.GetItem("configGiftGroups", self.config.group_id)
    self.diamond = 0
    self.curPrice = ShopModel:GetPriceByProductId(self.config.giftId)
    -- self._btnbuy.enabled = true
    if type(self.curPrice) == "number" and self.curPrice > 0 then
        self.originPrice = math.floor(self.config.value_ratio * 0.0001 * self.curPrice * 100) * 0.01
    else
        self.originPrice = 0
    end

    -- if isOnlyGift then
    --     self._textTitle.visible = false
    --     self._textTime.visible = false
    -- else
    --     self._textTitle.visible = true
    --     self._textTime.visible = true
    -- end

    self:RefreshList()
    self:PlayAnim(playAnim)
    self:InitBannerFont()

    self._textTitle.text = StringUtil.GetI18n(I18nType.Activitys, self.groupConfig.gift_name)
    self._textDesc.text = StringUtil.GetI18n(I18nType.Activitys, self.groupConfig.gift_desc)
    self._giftImage.url = UITool.GetIcon(self.groupConfig.banner)
    self._textGold.text = self.diamond
    self._textOrignPrice.text = ShopModel:GetCodeByProductId(self.config.giftId)..self.originPrice
    self._textCurPrice.text = ShopModel:GetCodeAndPriceByProductId(self.config.giftId)
    self._textHot.text = math.floor(self.config.value_ratio / 100).."%"
    self:UnSchedule(self.timer_func)
    self:Schedule(self.timer_func, 1)
end

function ItemRechargeMainGift:InitBannerFont()
    for _,v in pairs(self.bannerFont) do
        v.visible = false
    end

    local language = ConfigMgr:GetLocale()
    -- local font = self.groupConfig["art_name_"..language]
    local wordartId = ConfigMgr.GetItem("configGiftGroups", self.config.group_id).wordart
    local font
    if wordartId then
        font  = StringUtil.GetI18n(I18nType.WordArt, tostring(wordartId))
    end
    if font and next(font) then
        local fontPanel = self.bannerFont[self.groupConfig.id]
        if fontPanel then
            fontPanel.visible = true
        else
            fontPanel = UIMgr:CreateObject("Recharge", tostring(self.groupConfig.id))
            self.bannerFont[self.groupConfig.id] = fontPanel
        end

        if fontPanel then
            fontPanel:GetChild("_image").url = UITool.GetIcon(font)
            fontPanel.xy = Vector2(0, 0)
            fontPanel.width = self._giftImage.width
            fontPanel.height = self._giftImage.height
            self._btnImage:AddChildAt(fontPanel, 3)
        end
    end
end

function ItemRechargeMainGift:RefreshList()
    self.effectItems = {}

    for _,v in pairs(self.effects) do
        if v then
            v:StopEffect()
            NodePool.Set(NodePool.KeyType.GiftItemEffect, v)
        end
    end
    self.effects = {}

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
                item:GetChild("textName").text = StringUtil.GetI18n(I18nType.Activitys, resConfig.key)
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
            self:ClearListener(item.onTouchEnd)
            self:ClearListener(item.onRollOut)
            self:AddListener(item.onTouchBegin,function()
                self.detailPop:InitLabel(GD.ItemAgent.GetItemNameByConfId(itemConfig.id), GD.ItemAgent.GetItemDescByConfId(itemConfig.id))
                UIMgr:ShowPopup("Common", "LongPressPopupLabel", item, false)
            end)
            self:AddListener(item.onTouchEnd,function()
                self.detailPop:OnHidePopup()
            end)
            self:AddListener(item.onRollOut,function()
                self.detailPop:OnHidePopup()
            end)

            -- 特殊物品显示特效
            if self:CheckSpecialItem(self.config.special, v.confId) then
                NodePool.Init(NodePool.KeyType.GiftItemEffect, "Effect", "EffectNode")
                local effect = NodePool.Get(NodePool.KeyType.GiftItemEffect)
                effect.xy = Vector2(0, 18)
                effect.scale = Vector2(item.width / itemOriginalWidth, 1)
                item:AddChild(effect)
                effect:InitNormal()
                effect:PlayEffectLoop("effects/recharge/giftbackground/prefab/effect_gift_background")
                table.insert(self.effects, effect)
                table.insert(self.effectItems, {item = item, effect = effect})
            end
        end
    end

    self._list.scrollPane:ScrollTop()
end

--播放动画
function ItemRechargeMainGift:PlayAnim(isAnim)
    if not isAnim then
        GTween.Kill(self)
        self.y = 0
        for i = 1, self._list.numChildren do
            local item = self._list:GetChildAt(i - 1)
            GTween.Kill(item)
            item.y = (i - 1) * (self._list.lineGap + item.height)
            item.alpha = 1
        end
        return
    end
    self.y = 200
    self:TweenMoveY(0, 0.5):SetEase(EaseType.CubicOut)

    local mvDistance = 300
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        GTween.Kill(item)
        item.y = (i - 1) * (self._list.lineGap + item.height) + mvDistance
        local t = 0.15 * i
        item:TweenMoveY(item.y - mvDistance, t)
        if i > 2 then
            item.alpha = 0
            item:TweenFade(1, t):SetEase(EaseType.CubicIn)
        else
            item.alpha = 1
        end
    end
end

function ItemRechargeMainGift:CheckSpecialItem(specials, id)
    if specials then
        for _,v in pairs(specials) do
            if v == id then
                return true
            end
        end
    end

    return false
end

return ItemRechargeMainGift
