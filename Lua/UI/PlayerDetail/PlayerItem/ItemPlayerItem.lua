--[[
    Author: songzeming
    Function: 玩家道具使用item
]]
local GD = _G.GD
local ItemPlayerItem = fgui.extension_class(GComponent)
fgui.register_extension("ui://PlayerDetail/itemPlayerItem", ItemPlayerItem)

import("UI/Common/ItemProp")
local FROM = {
    Exp = "Exp",
    Hp = "Hp"
}

function ItemPlayerItem:ctor()
    self:AddListener(self._btnUse.onClick,
        function()
            if self.from == FROM.Exp then
                self:OnBtnUseExpClick()
            elseif self.from == FROM.Hp then
                self:OnBtnUseHpClick()
            end
        end
    )
    self._gold = self._btnBuy:GetChild("text")
    self:AddListener(self._btnBuy.onClick,
        function()
            if self.from == FROM.Hp then
                self:OnBtnBuyHpClick()
            end
        end
    )
end

function ItemPlayerItem:Init(from, item, cb)
    self.from = from
    self.item = item
    self.cb = cb

    if Model.Items[item.id] then
        self._btnUse.visible = true
        self._btnBuy.visible = false
        self._itemProp:SetShowData(item.icon, item.color, Model.Items[item.id].Amount, nil, GD.ItemAgent.GetItemInnerContent(item.id))
    else
        self._btnUse.visible = false
        self._btnBuy.visible = true
        self._gold.text = UITool.UBBTipGoldText(item.price)
        self._itemProp:SetShowData(item.icon, item.color, nil, nil, GD.ItemAgent.GetItemInnerContent(item.id))
    end
    self._title.text = GD.ItemAgent.GetItemNameByConfId(item.id)
    self._desc.text = GD.ItemAgent.GetItemDescByConfId(item.id)
end

--点击使用经验等级道具
function ItemPlayerItem:OnBtnUseExpClick()
    local upConf = ConfigMgr.GetItem("configPlayerUpgrades", Model.Player.HeroLevel + 1)
    local itemAmount = Model.Items[self.item.id].Amount
    local useAmount = itemAmount

    --根据道具数量获取经验回调
    local chooseAmount = nil
    local get_content_func = function(cAmount)
        if chooseAmount == cAmount then
            return
        end
        chooseAmount = cAmount
        useAmount = cAmount
        local upLevel = Model.Player.HeroLevel
        local upPercent = "0%"
        local remain = cAmount * self.item.value + Model.Player.HeroExp
        local function up_func()
            if upLevel < Global.MaxPlayerLevel then
                local cf = ConfigMgr.GetItem("configPlayerUpgrades", upLevel + 1)
                if remain >= cf.exp then
                    upLevel = upLevel + 1
                    remain = remain - cf.exp
                    up_func()
                else
                    upPercent = math.floor(remain / cf.exp * 100)
                end
            else
                upPercent = 100
            end
        end
        up_func()
        --使用道具描述内容
        local values = {
            item_name = self._title.text,
            get_exp = Tool.FormatNumberThousands(cAmount * self.item.value),
            old_level = Model.Player.HeroLevel,
            old_percent = math.floor(Model.Player.HeroExp / upConf.exp * 100),
            up_level = upLevel,
            up_percent = upPercent
        }
        return StringUtil.GetI18n(I18nType.Commmon, "UI_USEITEM_TIPS", values)
    end

    local use_func = function()
        local net_func = function()
            --使用道具成功
            local v = {
                exp = useAmount * self.item.value
            }
            TipUtil.TipById(50132, v)
            self.cb()
        end
        Net.Items.Use(self.item.id, useAmount, nil, net_func)
    end
    local data = {
        max = itemAmount,
        initMax = itemAmount,
        content = get_content_func(itemAmount),
        ctrType = "Text",
        slideCallback = get_content_func,
        sureCallback = use_func
    }
    UIMgr:Open("ConfirmPopupSlide", data)
end

--点击使用体力道具
function ItemPlayerItem:OnBtnUseHpClick()
    local itemAmount = Model.Items[self.item.id].Amount
    local useAmount = itemAmount

    --根据道具数量获取体力回调
    local chooseAmount = nil
    local get_content_func = function(cAmount)
        if chooseAmount == cAmount then
            return
        end
        chooseAmount = cAmount
        useAmount = cAmount
        --使用道具描述内容
        local values = {
            item_name = self._title.text,
            up_hp = cAmount * self.item.value,
            old_hp = GD.ResAgent.GetEnergy()
        }
        return StringUtil.GetI18n(I18nType.Commmon, "Ui_player_Energy", values)
    end

    local use_func = function()
        local sure_func = function()
            local net_func = function()
                --使用道具成功
                local v = {
                    hp = useAmount * self.item.value
                }
                TipUtil.TipById(50133, v)
                self.cb()
            end
            Net.Items.Use(self.item.id, useAmount, nil, net_func)
        end
        if useAmount * self.item.value + GD.ResAgent.GetEnergy() >= 100 then
            --使用道具后体力超限提示
            local v = {
                item_name = self._title.text
            }
            local d = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Ui_player_EnergyBeyond", v),
                sureCallback = sure_func
            }
            UIMgr:Open("ConfirmPopupText", d)
        else
            sure_func()
        end
    end
    local data = {
        max = itemAmount,
        initMax = 1,
        content = get_content_func(1),
        ctrType = "Text",
        slideCallback = get_content_func,
        sureCallback = use_func
    }
    UIMgr:Open("ConfirmPopupSlide", data)
end

--点击购买体力道具
function ItemPlayerItem:OnBtnBuyHpClick()
    local chooseAmount = 1
    local slide_func = function(amount)
        chooseAmount = amount
        return nil, chooseAmount * self.item.price 
    end
    local buy_func = function()
        local sure_func = function()
            --购买体力
            if chooseAmount * self.item.price > Model.Player.Gem then
                --金币不足提示
                UITool.GoldLack()
                return
            end
            local net_func = function()
                local v = {
                    hp = chooseAmount * self.item.value
                }
                TipUtil.TipById(50133, v)
                self.cb()
            end
            Net.Items.BuyAndUse(self.item.id, chooseAmount, net_func)
        end

        if chooseAmount * self.item.value + GD.ResAgent.GetEnergy() >= 100 then
            --使用道具后体力超限提示
            local v = {
                item_name = self._title.text
            }
            local d = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Ui_player_EnergyBeyond", v),
                sureCallback = sure_func
            }
            UIMgr:Open("ConfirmPopupText", d)
        else
            sure_func()
        end
    end
    local max = math.floor(Model.Player.Gem / self.item.price)
    if max == 0 then
        --金币不足
        UITool.GoldLack()
        return
    end
    local data = {
        max = max,
        content = StringUtil.GetI18n(I18nType.Commmon, "Onsale_Tips2"),
        gold = chooseAmount * self.item.price,
        ctrType = "Icon",
        item = self.item,
        iconContent = self._desc.text,
        initMax = 1,
        slideCallback = slide_func,
        sureCallback = buy_func
    }
    UIMgr:Open("ConfirmPopupSlide", data)
end

return ItemPlayerItem
