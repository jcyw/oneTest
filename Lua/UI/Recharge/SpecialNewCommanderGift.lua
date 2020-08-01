--[[
    author:Temmie
    time:2020-05-13 15:58:44
    function:新手礼包推荐界面
]]
local GD = _G.GD
local SpecialNewCommanderGift = UIMgr:NewUI("SpecialNewCommanderGift")

local SpineCharacter = import("Model/Animation/SpineCharacter")
local GiftModel = import("Model/GiftModel")
local maxCount = 8

function SpecialNewCommanderGift:OnInit()
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
    
    self:AddListener(self._btnBuy.onClick,function()
        SdkModel.Rcharge37(PurchaseType.ITEM_TYPE_APP, RCHARGE.GiftPack, self.config.id, self.config.giftId)
        UIMgr:Close("SpecialNewComma nderGift")
    end)

    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("SpecialNewCommanderGift")
    end)

    self.purchaseHandle = function(confId)
        if confId == GiftEnum.NewCommonderGiftOne then
            local config = GiftModel.GetGiftConfig(confId)
            UIMgr:Open("RechargeGiftPackagePopup", config, true)
            UIMgr:Close("SpecialNewCommanderGift")
        end
    end

    EffectTool.AddBtnLightEffect(self._btnBuy, {x = 0, y = -9}, {x = 0.9, y = 0.9, z = 0.9})
end

function SpecialNewCommanderGift:DoOpenAnim(...)
    self:OnOpen(...)
    --AnimationLayer.PanelAnim(AnimationType.PanelMoveLeft, self)
end

function SpecialNewCommanderGift:OnOpen()
    self:AddEvent(EventDefines.PurchaseGiftSuccess, self.purchaseHandle)
    self.config = GiftModel.GetGiftConfig(GiftEnum.NewCommonderGiftOne)
    self.groupConfig = GiftModel.GetGiftGroupConfig(self.config.group_id)
    self.gifConfig = ConfigMgr.GetItem("configGifts", self.config.gift)
    self._textTitle.text = StringUtil.GetI18n(I18nType.Activitys, self.groupConfig.gift_name)
    self._textDiamond.text = self:GetDiamond()
    self._btnBuy.text = ShopModel:GetCodeAndPriceByProductId(self.config.giftId)
    SpineCharacter.Show(self._bust, "prefabs/spine/character/adjutant/nvfuguan_anim", Vector3(130, 130, 130))

    local wordartId = self.config.wordart
    if wordartId then
        local font = StringUtil.GetI18n(I18nType.WordArt, tostring(wordartId))
        if font and next(font) then
            self._banner.url = UITool.GetIcon(font)
        end
    end

    self:InitList()
    self._list.scrollPane:ScrollTop()
end

function SpecialNewCommanderGift:OnClose()
    Event.RemoveListener(EventDefines.PurchaseGiftSuccess, self.purchaseHandle)
end

function SpecialNewCommanderGift:InitList()
    self._list:RemoveChildrenToPool()
    if self.gifConfig.res then
        for _,v in pairs(self.gifConfig.res) do
            if v.category ~= Global.ResDiamond then
                local resConfig = ConfigMgr.GetItem("configResourcess", v.category)
                local item = self._list:AddItemFromPool()
                local icon = GD.ResAgent.GetIcon(v.category)
                local title = StringUtil.GetI18n(I18nType.Activitys, resConfig.key)
                local amount = v.amount
                item:SetAmount(icon, nil, amount, title)
                --item:GetChild("_title").color = Color(0.89, 0.77, 0.65)
            end
        end
    end

    if self.gifConfig.items then
        for _,v in pairs(self.gifConfig.items) do
            local itemConfig = ConfigMgr.GetItem("configItems", v.confId)
            local item = self._list:AddItemFromPool()
            local icon = itemConfig.icon
            local title = GD.ItemAgent.GetItemNameByConfId(itemConfig.id)
            local amount = v.amount
            local quality = itemConfig.color
            local mid = GD.ItemAgent.GetItemInnerContent(v.confId)
            item:SetAmount(icon, quality, amount, title, mid)
            --item:GetChild("_title").color = Color(0.89, 0.77, 0.65)

            self:ClearListener(item.onTouchBegin)
            self:ClearListener(item.onTouchEnd)
            self:ClearListener(item.onRollOut)
            self:AddListener(item.onTouchBegin,function()
                self.detailPop:InitLabel(GD.ItemAgent.GetItemNameByConfId(itemConfig.id), GD.ItemAgent.GetItemDescByConfId(itemConfig.id), item, false)
            end)
            self:AddListener(item.onTouchEnd,function()
                self.detailPop:OnHidePopup()
            end)
            self:AddListener(item.onRollOut,function()
                self.detailPop:OnHidePopup()
            end)
        end
    end
end

function SpecialNewCommanderGift:GetDiamond()
    local diamond = 0
    if self.gifConfig.res then
        for _,v in pairs(self.gifConfig.res) do
            if v.category == Global.ResDiamond then
                diamond = diamond + v.amount
            end
        end
    end

    return diamond
end

return SpecialNewCommanderGift