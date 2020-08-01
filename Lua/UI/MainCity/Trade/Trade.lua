--author: 	Amu
--time:		2019-08-12 10:53:19
local GD = _G.GD
local ShopModel = import("Model/ShopModel")
local WelfareModel = import("Model/WelfareModel")

local Trade = UIMgr:NewUI("Trade")

function Trade:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._btnReturn = self._view:GetChild("btnReturn")
    self._btnHelp = self._view:GetChild("btnHelp")
    self._btnOpen = self._view:GetChild("btnOpen")
    self._btnApplyAll = self._view:GetChild("btnApplyAll")
    self._btnCtrView = self._btnApplyAll:GetController("c1")
    self._textApplyAll = self._btnApplyAll:GetChild("text")
    self._iconGoldApplyAll = self._btnApplyAll:GetChild("icon")
    self._textTitleApplyAll = self._btnApplyAll:GetChild("title")
    self._textTitle2ApplyAll = self._btnApplyAll:GetChild("title2")

    self._textRefreshTime = self._view:GetChild("textRefreshTime")
    --self._icon = self._view:GetChild("icon")
    --self._iconBg = self._view:GetChild("bg")
    --self._iconAmount = self._view:GetChild("bgAmount")
    self._textIconName = self._view:GetChild("textIconName")

    self._iconGold = self._view:GetChild("iconGold")
    self._textDiscountAfter = self._view:GetChild("textDiscountAfter")
    self._textDiscountBefore = self._view:GetChild("textDiscountBefore")

    self._listView = self._view:GetChild("liebiao")
    self.dt = 0.5
    -- self.shopConfig = ConfigMgr.GetList("configSpecialShops", v.ConfId)
    self:InitEvent()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.Trade)
end

function Trade:OnOpen(shopInfo)
    SdkModel.TrackBreakPoint(10036) --打点
    -- Net.SpecialShop.GetGoodsList(0, function(msg)
    --     self.GoodsList = msg.GoodsList
    --     self.RefreshNeed = msg.RefreshNeed
    -- end)
    self.GoodsList = shopInfo.GoodsList
    self.RefreshNeed = shopInfo.RefreshNeed.Gem
    self._endTime = shopInfo.NextRefreshAt
    self:RefreshPanel()
end

function Trade:RefreshPanel()
    self.superIteminfo = {}
    self.itemsInfo = {}

    if self.RefreshNeed > 0 then
        Model.SpecialShopRefreshFreeTimes = 0
        self._btnApplyAll.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_REFRESH_ONSALE")
        -- self._textTitleApplyAll:SetXY(self._textTitleApplyAll.x, -1)
        self._iconGoldApplyAll.visible = true
        self._textApplyAll.visible = true
        self._textApplyAll.text = self.RefreshNeed
        self._btnCtrView.selectedIndex = 0
    else
        self._textTitle2ApplyAll.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_TaskRefresh_Free")
        -- self._textTitleApplyAll:SetXY(self._textTitleApplyAll.x, 9)
        self._iconGoldApplyAll.visible = false
        self._textApplyAll.visible = false
        self._btnCtrView.selectedIndex = 1
    end

    for k, v in ipairs(self.GoodsList) do
        v.configInfo = ConfigMgr.GetItem("configSpecialShops", v.GoodsId)
        if k == 1 then
            self.superIteminfo = v
        else
            table.insert(self.itemsInfo, v)
        end
    end
    local giftId = self.superIteminfo.configInfo.item
    local itemConf, itemCount = WelfareModel.GetResOrItemByGiftId(giftId)
    --self._icon.icon = UITool.GetIcon(itemConf[1].image)
    --self._iconBg.icon = GD.ItemAgent.GetItmeQualityByColor(itemConf[1].color)
    local bgItemId = tonumber(itemConf[1].confId)
    local midNum = GD.ItemAgent.GetItemInnerContent(itemConf[1].confId)
    --[[if midNum then
        self._groupMid.visible = true
        self._amountMid.text = midNum
        GD.ItemAgent.SetMiddleBg(self._numBg, itemConf[1].color)
    else
        self._groupMid.visible = false
    end]]
    local amount = "X" .. itemConf[1].amount
    self._item:SetShowData(itemConf[1].image,itemConf[1].color,amount,nil,midNum)
    self._textIconName.text = GD.ItemAgent.GetItemNameByConfId(bgItemId)
    --self._iconAmount.text = "X" .. itemConf[1].amount
    self:UpdateLightEffect(self.superIteminfo.configInfo.effect)
    self._iconGold.icon = ShopModel:GetGoldIconByType(self.superIteminfo.configInfo.price_type)
    self._textDiscountAfter.text = self.superIteminfo.configInfo.price
    self._textDiscountBefore.text = self.superIteminfo.configInfo.original_price

    self:RefresshListView()

    if not self._scheduler then
        self:Schedule(self.callback, self.dt)
        self._scheduler = true
    end
end

function Trade:InitEvent()
    self:AddListener(self._btnReturn.onClick,
        function()
            self:Close()
        end
    )

    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                info = StringUtil.GetI18n(I18nType.Commmon, "Onsale_Tips1")
            }
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )

    self:AddListener(self._btnOpen.onClick,
        function()
            UIMgr:Open("Backpack")
        end
    )

    self:AddListener(self._btnApplyAll.onClick,
        function()
            self:OnBtnApplyAllClick()
        end
    )

    self._listView.itemRenderer = function(index, item)
        if not index then
            return
        end
        item:SetData(self.itemsInfo[index + 1])
    end

    self:AddListener(self._listView.onClickItem,
        function(context)
            local item = context.data
            local data = item:GetData()
        end
    )

    self._listView:SetVirtual()

    self.callback = function()
        if not self._endTime then
            return
        end
        local time = self._endTime - Tool.Time()
        if time <= 0 then
            self:UnSchedule(self.callback)
            self._scheduler = false
            Net.SpecialShop.GetGoodsList(
                function(msg)
                    self.GoodsList = msg.GoodsList
                    self.RefreshNeed = msg.RefreshNeed.Gem
                    self._endTime = msg.NextRefreshAt
                    self:RefreshPanel()
                end
            )
            return
        end
        self._textRefreshTime.text = TimeUtil.SecondToHMS(time)
    end

    self:AddEvent(
        SPECIAL_SHOP_EVENT.Buy,
        function(msg)
            for k, v in ipairs(self.GoodsList) do
                if v.Category == msg.Category then
                    v.GoodsId = msg.GoodsId
                    v.configInfo = ConfigMgr.GetItem("configSpecialShops", v.GoodsId)
                    break
                end
            end
            self:RefresshListView()
        end
    )

    self:AddEvent(
        TIME_REFRESH_EVENT.Refresh,
        function()
            Net.SpecialShop.GetGoodsList(
                function(shopInfo)
                    self.GoodsList = shopInfo.GoodsList
                    self.RefreshNeed = shopInfo.RefreshNeed.Gem
                    self._endTime = shopInfo.NextRefreshAt
                    self:RefreshPanel()
                end
            )
        end
    )
end

function Trade:RefreshItems()
    Net.SpecialShop.RefreshGoods(
        function(msg)
            table.insert(msg.GoodsList, 1, self.GoodsList[1])
            self.GoodsList = msg.GoodsList
            self.RefreshNeed = msg.RefreshNeed.Gem
            -- self._endTime = msg.NextRefreshAt
            self:RefreshPanel()
        end
    )
end

function Trade:OnBtnApplyAllClick()
    for _, v in pairs(self.itemsInfo) do
        if self.superIteminfo.GoodsId == v.GoodsId then
            --有超值商品
            local data = {
                content = StringUtil.GetI18n("configI18nCommons", "Onsale_Tips3"),
                sureCallback = function()
                    if ShopModel:GetGoldNumByGoldType(RES_TYPE.Diamond) < self.RefreshNeed then
                        local data = ShopModel:GoldNotEnoughTipByType(RES_TYPE.Diamond)
                        UIMgr:Open("ConfirmPopupText", data)
                        return
                    end
                    self:RefreshItems()
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
            return
        end
    end
    if ShopModel:GetGoldNumByGoldType(RES_TYPE.Diamond) < self.RefreshNeed then
        local data = ShopModel:GoldNotEnoughTipByType(RES_TYPE.Diamond)
        UIMgr:Open("ConfirmPopupText", data)
        return
    end
    if self.RefreshNeed > 0 then
        local data = {
            content = StringUtil.GetI18n("configI18nCommons", "Refresh_Shop_Item_Diamond"),
            tipType = TipType.TYPE.OnlineSpecialShop,
            sureCallback = function()
                self:RefreshItems()
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        self:RefreshItems()
    end
end

function Trade:RefresshListView()
    self._listView.numItems = #self.itemsInfo
end

--刷新特效颜色
function Trade:UpdateLightEffect(index)
    local function remove_pool()
        if self.color then
            NodePool.Set(NodePool.KeyType.ShopLightEffect .. self.color, self._light)
            self.color = nil
            self.index = nil
        end
    end
    if not index then
        remove_pool()
        return
    end
    if self.index and index == self.index then
        return
    end
    remove_pool()
    self.index = index
    self.color = CommonType.SHOP_EFFECT_COLOR[index]
    NodePool.Init(NodePool.KeyType.ShopLightEffect .. self.color, "Effect", "EffectNode")
    self._light = NodePool.Get(NodePool.KeyType.ShopLightEffect .. self.color)
    self._light.xy = Vector2(0, 0)
    self._effectNode:AddChild(self._light)
    self._light:PlayEffectSingle("effects/effect_shop_icon/prefab/effect_shop_icon_" .. self.color)
end

function Trade:Close()
    UIMgr:Close("Trade/Trade")
end

function Trade:OnClose()
    self:UnSchedule(self.callback)
    self._scheduler = false
    self:UpdateLightEffect()
end

return Trade
