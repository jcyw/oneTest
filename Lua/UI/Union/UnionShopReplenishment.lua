--author: 	Amu
--time:		2019-07-01 15:41:46
local GD = _G.GD
local ShopModel = import("Model/ShopModel")

local UnionShopReplenishment = UIMgr:NewUI("UnionShopReplenishment")
UnionShopReplenishment.selectItem = nil

function UnionShopReplenishment:OnInit()
    -- body
    self._view = self.Controller.contentPane

    self._btnClose = self._view:GetChild("btnClose")

    self._titleName = self._view:GetChild("titleName")
    self._item = self._view:GetChild("itemProp")
    self._itemText = self._view:GetChild("text")

    self._wantNum = self._view:GetChild("textDec")

    self._slider = self._view:GetChild("_slide")
    self._addBtn = self._view:GetChild("_btnAdd")
    self._reduceBtn = self._view:GetChild("_btnDel")

    self._textInput = self._view:GetChild("_text")

    self._btnBuy = self._view:GetChild("btnUse")

    self._iconHonor = self._btnBuy:GetChild("icon")
    -- self._textHonor = self._btnBuy:GetChild("textHonor")
    self._textHonorNum = self._btnBuy:GetChild("text")
    self._textDescribe = self._view:GetChild("textDescribe")
    self.keyboard = UIMgr:CreatePopup("Common", "itemKeyboard")
    self.choiceNum = 0
    self:InitEvent()
end

--itemInfo {
--  ConfId  --物品Id
--  Id      --商品Id
--  Amount  --商品数量
--}
--gold  {
--  Amount  --价格
--  type    --金币类型
--}
function UnionShopReplenishment:OnOpen(shopType, itemInfo, gold)
    self.shopType = shopType
    self.confId = itemInfo.ConfId
    self.itemNum = itemInfo.Amount
    self.goldType = gold.type
    self.allGold = ShopModel:GetGoldNumByGoldType(gold.type)
    self._titleName.text = GD.ItemAgent.GetItemNameByConfId(self.confId)
    self._itemText.text = GD.ItemAgent.GetItemDescByConfId(self.confId)
    if gold then
        self._gold = gold.Amount
    else
        self._gold = 100
    end
    if self.shopType == SHOP_TYPE.UnionAddShop then
        self.maxNum = math.floor(self.allGold / self._gold)
        self._wantNum.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceShop_Need", {number = itemInfo.Mark})
    else
        self.maxNum = math.min(math.floor(self.allGold / self._gold), itemInfo.Amount)
        self._wantNum.text = ""
    end
    self.choiceNum = 1
    self:RefreshData()

    self._iconHonor.icon = ShopModel:GetGoldIconByType(gold.type)
    -- self._textHonor.text = ShopModel:GetGoldNameByType(gold.type)

    self.Id = itemInfo.Id

    local itemConfig = ConfigMgr.GetItem("configItems", itemInfo.ConfId)
    local midNum = GD.ItemAgent.GetItemInnerContent(itemInfo.ConfId)
    self._item:SetAmount(itemConfig.icon, itemConfig.color, nil, nil, midNum)

    local text = ""
    if shopType == SHOP_TYPE.VipShop then
        text = "Onsale_Tips2"
    elseif self.shopType == SHOP_TYPE.UnionAddShop then
        text = "Ui_Alliance_ShopTipsa"
    else
        text = "Ui_AllianceShop_Supplement"
    end
    self._textDescribe.text = StringUtil.GetI18n(I18nType.Commmon, text)
end

function UnionShopReplenishment:InitEvent()
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )

    self:AddListener(self._mask.onClick,
        function()
            self:Close()
        end
    )

    self:AddListener(self._btnInput.onClick,
        function()
            local cb = function(num)
                if tonumber(num) > self.maxNum then
                    self._textInput.text = self.maxNum
                else
                    self._textInput.text = num
                end
                self.choiceNum = tonumber(self._textInput.text)
                self:RefreshData()
            end
            local localPos = self._textInput:LocalToGlobal(CS.UnityEngine.Vector2.zero)
            self.keyboard:Init(
                self.maxNum,
                function(num)
                    if self.shopType == SHOP_TYPE.VipShop then
                        if num <= 0 then
                            num = 1
                        end
                    end
                    cb(num)
                end
            )
            UIMgr:ShowPopup("Common", "itemKeyboard", self._textInput)
        end
    )

    -- self:AddListener(self._textInput.onChanged,function()
    --     if tonumber(self._textInput.text) > self.maxNum then
    --         self._textInput.text = self.maxNum
    --     end
    --     self.choiceNum = tonumber(self._textInput.text)
    --     self:RefreshData(self.choiceNum)
    -- end)

    self:AddListener(self._btnBuy.onClick,
        function()
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Onsale_Tips2"),
                buttonType = "Single",
                sureCallback = function()
                    if self.choiceNum <= 0 then
                        return
                    end
                    if self.choiceNum * self._gold > self.allGold then
                        ShopModel:GoldNotEnoughTipByType(self.goldType)
                        self:Close()
                        return
                    end
                    if self.choiceNum > self.itemNum then
                        TipUtil.TipById(50247)
                        return
                    end
                    if self.shopType == SHOP_TYPE.UnionShop then
                        Net.AllianceShop.Buy(
                            self.Id,
                            self.choiceNum,
                            function()
                                TipUtil.TipById(50199)
                                Event.Broadcast(SHOPEVENT.BuyEvent, self.Id, self.choiceNum)
                                self:Close()
                            end
                        )
                    elseif self.shopType == SHOP_TYPE.UnionAddShop then
                        Net.AllianceShop.Stock(
                            self.Id,
                            self.choiceNum,
                            function()
                                TipUtil.TipById(50249)
                                Event.Broadcast(SHOPEVENT.AddEvent, self.Id, self.choiceNum)
                                self:Close()
                            end
                        )
                    elseif self.shopType == SHOP_TYPE.VipShop then
                        Net.VipShop.BuyGoods(
                            self.Id,
                            self.choiceNum,
                            function()
                                TipUtil.TipById(50199)
                                Event.Broadcast(SHOPEVENT.VipBuyEvent, self.Id, self.choiceNum)
                                self:Close()
                            end
                        )
                    end
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    )

    self:AddListener(self._slider.onChanged,
        function()
            self.choiceNum = math.modf(self.maxNum * self._slider.value / self._slider.max)
            if self.shopType == SHOP_TYPE.VipShop then
                if self.choiceNum <= 0 then
                    self.choiceNum = 1
                end
            end
            self._textInput.text = self.choiceNum
            if self.choiceNum > self.maxNum then
                self._textHonorNum.textFormat.color = Color.red
            else
                self._textHonorNum.textFormat.color = Color.white
            end
            self._textHonorNum.text = Tool.FormatNumberThousands(self.choiceNum * self._gold)
        end
    )

    self:AddListener(self._slider.onGripTouchEnd,
        function()
            if self.maxNum <= 0 then
                if self.choiceNum > self.maxNum then
                    self._slider.value = 100
                else
                    self._slider.value = 0
                end
            else
                self._slider.value = self._slider.max * self.choiceNum / self.maxNum
            end
        end
    )

    self:AddListener(self._addBtn.onClick,
        function()
            if self.choiceNum >= self.maxNum then
                if self.shopType == SHOP_TYPE.UnionAddShop then
                    local data = ShopModel:GoldNotEnoughTipByType(self.goldType)
                    self:Close()
                    -- UIMgr:Open("ConfirmPopupText", data)
                    return
                end
                if self.itemNum >= (self.choiceNum + 1) and self.itemNum > 0 then
                    TipUtil.TipById(50250)
                else
                    TipUtil.TipById(50247)
                end
                return
            end
            self.choiceNum = self.choiceNum + 1
            self:RefreshData()
        end
    )

    self:AddListener(self._reduceBtn.onClick,
        function()
            if self.shopType == SHOP_TYPE.VipShop then
                if self.choiceNum <= 1 then
                    return
                end
            else
                if self.choiceNum <= 0 then
                    return
                end
            end
            self.choiceNum = self.choiceNum - 1
            self:RefreshData()
        end
    )
end

function UnionShopReplenishment:RefreshData()
    if self.maxNum <= 0 then
        if self.choiceNum > self.maxNum then
            self._slider.value = 100
        else
            self._slider.value = 0
        end
    else
        self._slider.value = self._slider.max * self.choiceNum / self.maxNum
    end
    self._textInput.text = self.choiceNum
    if self.choiceNum > self.maxNum then
        self._textHonorNum.textFormat.color = Color.red
    else
        self._textHonorNum.textFormat.color = Color.white
    end
    self._textHonorNum.text = Tool.FormatNumberThousands(self.choiceNum * self._gold)
end

function UnionShopReplenishment:Close()
    UIMgr:Close("UnionShopReplenishment")
end

return UnionShopReplenishment
