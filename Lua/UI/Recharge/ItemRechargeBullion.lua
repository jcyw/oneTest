--[[
    author:{maxiaolong}
    time:2019-09-26 14:48:12
    function:{充值钻石}
]]
local ItemRechargeBullion = fgui.extension_class(GComponent)
fgui.register_extension("ui://Recharge/itemRechargeBullion", ItemRechargeBullion)
local RechargeModel = import("Model/RechargeModel")
function ItemRechargeBullion:ctor()
    self._textName = self:GetChild("textOne")
    self._textNumber = self:GetChild("textNumber")
    self._textNumber2 = self:GetChild("textNumber2")
    self._textNumberAdd = self:GetChild("textNumberAdd")
    self._btnBuy = self:GetChild("btnBUyYellow")
    self._btnBlueBuy = self:GetChild("btnBUyBlue")
    self._buyTitle = self._btnBuy:GetChild("title")
    self._buyTitle2 = self._btnBlueBuy:GetChild("title")
    self._hotBg = self:GetChild("bgHot")
    self._textHot = self:GetChild("textHot")
    --self._icon = self:GetChild("icon")
    --self._iconBg = self:GetChild("iconBg")
    self._ctr = self:GetController("c1")
    self:AddListener(self._btnBuy.onClick,
        function()
            SdkModel.Rcharge37(PurchaseType.ITEM_TYPE_APP, RCHARGE.Diamond, self.param.id, self.param.giftId)
        end
    )
    self:AddListener(self._btnBlueBuy.onClick,
        function()
            SdkModel.Rcharge37(PurchaseType.ITEM_TYPE_APP, RCHARGE.Diamond, self.param.id, self.param.giftId)
        end
    )

    self._btnBuy:AddChild(self._hotBg)
    self._btnBuy:AddChild(self._textHot)
    self._hotBg.xy = Vector2(0, -5)
    self._textHot.xy = Vector2(-6, 26)
end

function ItemRechargeBullion:SetData(param)
    if not param then
        return
    end
    self.param = param
    local payData = RechargeModel.GetGoldDataById(param.id)
    local hotNum = param.isHot
    if hotNum == true then
        self._hotBg.visible = true
        self._textHot.visible = true
        self._textHot.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_Store_Hot")
    elseif hotNum == false then
        self._textHot.text = ""
        self._hotBg.visible = false
        self._textHot.visible = false
    end
    --是否已经充值过
    if payData.isPayed == true then
        self._textName.visible = false
        self._textNumberAdd.visible = false
        self._hotBg.visible = false
        self._textHot.visible = false
    else
        self._textName.visible = true
        self._textNumberAdd.visible = true
    end
    --self._icon.icon = UITool.GetIcon(param.icon)
    --self._iconBg.icon = GD.ItemAgent.GetItmeQualityByColor(param.color)
    self._item:SetShowData(param.icon,param.color)
    if param.isOnce == true then
        self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Restriction_One")
    elseif param.isDaily == true then
        self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_EVERYDAY_LIMIT_BUY")
    else
        self._textName.text = ""
    end

    if param.button == 1 then
        self._ctr.selectedIndex = 1
        self._textNumber2.text = param.diamond
    else
        self._ctr.selectedIndex = 0
        self._textNumber.text = param.diamond
    end

    local extraGold = tonumber(param.extraGift)
    if extraGold > 0 then
        local extraStr = tostring(param.extraGift)
        self._textNumberAdd.text = "+" .. extraStr
    end

    local price = ShopModel:GetCodeAndPriceByProductId(self.param.giftId)
    self._buyTitle.text = price
    self._buyTitle2.text = price
end

return ItemRechargeBullion
