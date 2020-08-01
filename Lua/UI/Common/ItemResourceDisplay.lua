--[[
    author:Temmie
    time:
    function:仓库界面列表项
]]
local GD = _G.GD
local ItemResourceDisplay = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://Common/itemResourceDisplay", ItemResourceDisplay)

local StringUtil = _G.StringUtil
local I18nType = _G.I18nType
local TipUtil = _G.TipUtil
local UIMgr = _G.UIMgr
local UITool = _G.UITool
local Tool = _G.Tool
local Net = _G.Net
local Model = _G.Model
local ConfigMgr = _G.ConfigMgr

function ItemResourceDisplay:ctor()
    -- self._txtResNum = self:GetChild("textNumber")
   --[[self._icon = self:GetChild("itemIcon"):GetChild("_icon")
    self._iconBg = self:GetChild("itemIcon"):GetChild("_bg")
    self._txtCount = self:GetChild("itemIcon"):GetChild("_amount")
    self._txtMid = self:GetChild("itemIcon"):GetChild("_amountMid")
    self._groupMid = self:GetChild("itemIcon"):GetChild("_groupMid")
    self._numBg = self:GetChild("itemIcon"):GetChild("_numBg")]]
    self._txtName = self:GetChild("titleName")
    self._txtDetail = self:GetChild("text")
    self._btnBuy = self:GetChild("btnYellow")
    self._btnUse = self:GetChild("btnGreen")
    self._txtPrice = self._btnBuy:GetChild("text")
    self._buttonControl = self:GetController("c1")
    -- self._iconPrice = self._btnBuy:GetChild("iconGold")

    self:AddListener(self._btnUse.onClick,function()
        if self.model.Amount > 1 then
            local data = {
                config = self.config,
                amount = self.model.Amount,
                initAmount = self:GetInitAmount(),
                title = GD.ItemAgent.GetItemNameByConfId(self.config.id),
                context = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_USE_TIPS", {item_name = GD.ItemAgent.GetItemNameByConfId(self.config.id)}),
                useCallBack = function(amount)
                    TipUtil.TipById(50078, {res_amount = amount * self.config.value, res_name = StringUtil.GetI18n(I18nType.Commmon, ConfigMgr.GetItem("configResourcess", self.config.type2).key)})

                    if self.floor and self.floor.needAmount and self.floor.needAmount > 0 then
                        local left = self.floor.needAmount - amount * self.config.value
                        self.floor.needAmount = left > 0 and left or 0
                    end

                    if self.callback ~= nil then
                        self.callback()
                    end
                end
            }
            UIMgr:Open("ResourceDisplayUse", data)
        else
            local data = {
                icon =  UITool.GetIcon(self.config.icon),
                content = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_USE_TIPS", {item_name = GD.ItemAgent.GetItemNameByConfId(self.config.id)}),
                amount = Tool.FormatAmountUnit(self.config.value),
                sureCallback = function()
                    Net.Items.Use(self.config.id, self.model.Amount, nil, function(rsp)
                        if rsp.Fail then
                            return
                        end

                        TipUtil.TipById(50078, {res_amount = self.config.value, res_name = StringUtil.GetI18n(I18nType.Commmon, ConfigMgr.GetItem("configResourcess", self.config.type2).key)})

                        if self.callback ~= nil then
                            self.callback()
                        end
                    end)
                end
            }
            UIMgr:Open("ResourceDisplayTips", data)
        end
    end)

    self:AddListener(self._btnBuy.onClick,function()
        if Model.Player.Gem < self.config.price then
            UITool.GoldLack()
            return
        end

        local curAmount = math.floor(Model.Player.Gem / self.config.price)
        local data = {
            id = self.config.id,
            amount = curAmount,
            price = self.config.price,
            itemCount = self.config.value,
            mainContent = GD.ItemAgent.GetItemDescByConfId(self.config.id),
            btnTitle = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_USE_GOLD"),
            icon = self.config.icon,
            bg = self.config.color,
            title = ConfigMgr.GetI18n(I18nType.Commmon, "Tips_TITLE"),
            useCallBack = function(amount)
                if self.floor and self.floor.needAmount and self.floor.needAmount > 0 then
                    local left = self.floor.needAmount - amount * self.config.value
                    self.floor.needAmount = left > 0 and left or 0
                end

                TipUtil.TipById(50079, {res_amount = amount * self.config.value, res_name = StringUtil.GetI18n(I18nType.Commmon, ConfigMgr.GetItem("configResourcess", self.config.type2).key)})

                if self.callback ~= nil then
                    self.callback()
                end
            end
        }
        UIMgr:Open("ResourceDisplayGoldBuy", data)
    end)
end

function ItemResourceDisplay:Init(config, model, parent, callback)
    self.model = model
    self.config = config
    self.floor = parent
    self.callback = callback
    --self._icon.url = UITool.GetIcon(self.config.icon)
    --self._iconBg.url = GD.ItemAgent.GetItmeQualityByColor(self.config.color)
    self._txtName.text = GD.ItemAgent.GetItemNameByConfId(self.config.id)
    self._txtDetail.text = GD.ItemAgent.GetItemDescByConfId(self.config.id)
    local mid = GD.ItemAgent.GetItemInnerContent(self.config.id)
    --[[if mid then
        self._groupMid.visible = true
        self._txtMid.text = mid
        GD.ItemAgent.SetMiddleBg(self._numBg, self.config.color)
    else
        self._groupMid.visible = false
    end]]
    -- self._txtResNum.text = Tool.FormatAmountUnit(self.config.value)
    local amount
    if self.model == nil or self.model.Amount <= 0 then
        amount = "x"..0
        self._txtPrice.text = self.config.price
        self._buttonControl.selectedIndex = 0
    else
        amount = "x"..self.model.Amount
        self._buttonControl.selectedIndex = 1
    end
    self._item:SetShowData(self.config.icon,self.config.color,amount,nil,mid)
end

function ItemResourceDisplay:GetInitAmount()
    if self.floor.needType == self.config.type2 and self.floor.needAmount and self.floor.needAmount > 0 then
        local need = math.ceil(self.floor.needAmount / self.config.value)
        need = need > self.model.Amount and self.model.Amount or need
        return (need <= 0 and self.model.Amount or need)
    else
        return self.model.Amount
    end
end

return ItemResourceDisplay