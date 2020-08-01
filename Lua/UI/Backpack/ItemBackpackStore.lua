-- 背包列表项，装具体物品的容器
local GD = _G.GD
local ItemBackpackStore = _G.fgui.extension_class(_G.GButton)
_G.fgui.register_extension("ui://Backpack/itemShop", ItemBackpackStore)

local UIMgr = _G.UIMgr
local Model = _G.Model
local StringUtil = _G.StringUtil
local I18nType = _G.I18nType
local ConfigMgr = _G.ConfigMgr
local Tool = _G.Tool

function ItemBackpackStore:ctor()
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
    self:InitEvent()

    self:InitI18n()
end

function ItemBackpackStore:InitEvent()
    self:AddListener(self._btnBuy.onClick, function()
        local maxAmount = math.floor(Model.Player.Gem / self.data.price)
        maxAmount = maxAmount <= 0 and 1 or maxAmount
        local params = {
            id = self.itemId,
            amount = maxAmount,
            price = self.data.price,
            itemCount = self.data.value,
            mainContent = GD.ItemAgent.GetItemDescByConfId(self.itemId),
            btnTitle = StringUtil.GetI18n(I18nType.Commmon, "Ui_Buy"),
            icon = self.data.icon,
            bg = self.data.color,
            title = ConfigMgr.GetI18n(I18nType.Commmon, "Tips_TITLE"),
            notUse = true,
        }
        UIMgr:Open("ResourceDisplayGoldBuy", params)
    end)

    self:AddListener(self._iconTouch.onTouchBegin,function()
        self.detailPop:OnShowUI(GD.ItemAgent.GetItemNameByConfId(self.itemId), GD.ItemAgent.GetItemDescByConfId(self.itemId), self._itemProp, false)
    end)

    self:AddListener(self._iconTouch.onTouchEnd,function()
        self.detailPop:OnHidePopup()
    end)

    self:AddListener(self._iconTouch.onRollOut,function()
        self.detailPop:OnHidePopup()
    end)
end

function ItemBackpackStore:InitI18n()
    self._btnBuy.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Buy")
end

function ItemBackpackStore:SetData(data, window)
    self.data = data
    self._par = window
    self.itemId = data.item_id
    --self._icon.url = UITool.GetIcon(data.icon, self._icon)
    --self._bgIcon.url = GD.ItemAgent.GetItmeQualityByColor(data.color)
    self._btnBuy.text = Tool.FormatNumberThousands(data.price or data.price_hot)
    self._titleName.text = GD.ItemAgent.GetItemNameByConfId(self.itemId)
    --self._iconHot.visible = (data.store_hot and data.store_hot > 0)
    local midNum = GD.ItemAgent.GetItemInnerContent(data.item_id)
    --[[if midNum then
        self._groupMid.visible = true
        self._amountMid.text = midNum
        GD.ItemAgent.SetMiddleBg(self._numBg, data.color)
    else
        self._groupMid.visible = false
    end]]
    self._itemProp:SetShowData(data.icon,data.color,nil,nil,midNum)
    self._itemProp:SetHotActive(data.store_hot and data.store_hot > 0)
end

return ItemBackpackStore