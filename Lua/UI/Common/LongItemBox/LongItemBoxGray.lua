--[[
    Author: songzeming
    Function: 通用组件 道具使用或购买 灰色版
]]
local GD = _G.GD
local LongItemBoxGray = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/LongItemBoxGray", LongItemBoxGray)

import("UI/Common/ItemProp")

function LongItemBoxGray:ctor()
    self:AddListener(self._btnUse.onClick,function()
        self:OnBtnUseClick()
    end)
    self._gold = self._btnBuy:GetChild("text")
    self:AddListener(self._btnBuy.onClick,function()
        self:OnBtnBuyClick()
    end)
end

function LongItemBoxGray:Init(from, item, cb)
    self.from = from
    self.item = item
    self.cb = cb

    self:UpdateData()
end

--刷新数据
function LongItemBoxGray:UpdateData()
    local mid = GD.ItemAgent.GetItemInnerContent(self.item.id)
    if Model.Items[self.item.id] then
        --有道具
        self._btnUse.visible = true
        self._btnBuy.visible = false
        self._itemProp:SetShowData(self.item.icon, self.item.color, Model.Items[self.item.id].Amount,nil,mid)
    else
        --没有道具
        self._btnUse.visible = false
        self._btnBuy.visible = true
        self._gold.text = UITool.UBBTipGoldText(self.item.price)
        self._itemProp:SetShowData(self.item.icon, self.item.color,nil,nil,mid)
    end

    --显示名称和描述
    self._title.text = GD.ItemAgent.GetItemNameByConfId(self.item.id)
    self._desc.text = GD.ItemAgent.GetItemDescByConfId(self.item.id)
end

--点击购买并使用道具
function LongItemBoxGray:OnBtnBuyClick()
    local chooseAmount = 1
    local slide_func = function(amount)
        chooseAmount = amount
        return nil, chooseAmount * self.item.price 
    end
    local buy_func = function()
        if chooseAmount * self.item.price > Model.Player.Gem then
            --金币不足提示
            UITool.GoldLack()
            return
        end
        if self.from == CommonType.LONG_ITEM_BOX_DISPLAY.JointCommandUpgrade then
            --联合指挥部升级 购买并用道具
            local net_func = function()
                TipUtil.TipById(50199)
                if self.cb then
                    self.cb()
                end
            end
            Net.Items.BuyAndUse(self.item.id, chooseAmount, net_func)
        else
            --购买道具
            local net_func = function()
                self:UpdateData()
            end
            Net.Items.Buy(self.item.id, chooseAmount, net_func)
        end
    end
    local max = math.floor(Model.Player.Gem / self.item.price)
    if max == 0 then
        --金币不足
        UITool.GoldLack()
        return
    end

    local textContext = StringUtil.GetI18n(I18nType.Commmon, "Onsale_Tips2") --指挥官，您确定购买此物品吗？
    local data = {
        max = max,
        content = textContext,
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

--点击使用
function LongItemBoxGray:OnBtnUseClick()
    local itemAmount = Model.Items[self.item.id].Amount
    local chooseAmount = itemAmount
    local choose_func = function(cAmount)
        chooseAmount = cAmount
    end
    local use_func = function()
        local net_func = function()
            --使用道具成功
            --[[local v = {
                item_name = self._title.text,
            }]] --发现回调没有使用参数且参数有误暂时屏蔽有需要的时候重构
            TipUtil.TipById(20037, {item_name = GD.ItemAgent.GetItemNameByConfId(self.item.id)}, self.item.icon)
            --self.cb(v.item_num)
            if self.cb then
                self.cb()
            end
        end
        Net.Items.Use(self.item.id, chooseAmount, nil, net_func)
    end
    local data = {
        max = itemAmount,
        content = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_USE_TIPS", {item_name = self._title.text}),
        ctrType = "Text",
        slideCallback = choose_func,
        sureCallback = use_func
    }
    UIMgr:Open("ConfirmPopupSlide", data)
end

return LongItemBoxGray
