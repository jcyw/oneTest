--author: 	Amu
--time:		2019-07-01 10:54:52

local ShopModel = import("Model/ShopModel")
local UnionInfoModel = import("Model/Union/UnionInfoModel")

local UnionShop = UIMgr:NewUI("UnionShop")
UnionShop.selectItem = nil

function UnionShop:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._btnReturn = self._view:GetChild("btnReturn")
    self._btnHistory = self._view:GetChild("btnHistory")

    self._iconHonor = self._view:GetChild("iconHonor")
    self._textHonor = self._view:GetChild("textHonor")
    self._textHonorNum = self._view:GetChild("textHonorNum")

    self._iconCredit = self._view:GetChild("iconCredit")
    self._textCredit = self._view:GetChild("textCredit")
    self._textCreditNum = self._view:GetChild("textCreditNum")

    self._btnAddHonor = self._view:GetChild("btnAddHonor")
    self._btnAddCredit = self._view:GetChild("btnAddCredit")
    self._btnHelp = self._view:GetChild("btnHelp")

    self._iconHonor.icon = ShopModel:GetGoldIconByType(RES_TYPE.UnionHonor)
    --self._textHonor.text = ShopModel:GetGoldNameByType(RES_TYPE.UnionHonor)

    self._iconCredit.icon = ShopModel:GetGoldIconByType(RES_TYPE.UnionCredit)
    --self._textCredit.text = ShopModel:GetGoldNameByType(RES_TYPE.UnionCredit)

    self._listView = self._view:GetChild("liebiao")

    -- self._bgMask = self._view:GetChild("bgMask")
    -- self._bgMask.visible = false


    self:InitEvent()
end

function UnionShop:OnOpen(shopInfo, itemId)
    if self.selectItem then
        self.selectItem:SetChoose(false)
        self.selectItem = nil
    end
    self.shopInfo = shopInfo.Items
    for _,v in ipairs(self.shopInfo)do
        v.itemInfo = ShopModel:GetConfigById(SHOP_TYPE.UnionShop, v.ConfId) 
    end
    self:RefreshPanel()
    self._listView.scrollPane:ScrollTop()
    if itemId then
        self.itemId = itemId
        self._listView:SetBoundsChangedFlag()
        self._listView:EnsureBoundsCorrect()
        self._listView.numItems = #self.shopInfo
        if self.selectItem then
            self._listView.scrollPane.posY = self.selectItem.y
        end
    end
end

function UnionShop:Close()
    UIMgr:Close("UnionShop")
end

function UnionShop:RefreshPanel()
    self._honor = Model.Find(ModelType.Resources, RES_TYPE.UnionHonor).Amount
    self._textHonorNum.text = Tool.FormatNumberThousands(self._honor)
    self._credit = ShopModel:GetGoldNumByGoldType(RES_TYPE.UnionCredit)
    self._textCreditNum.text = Tool.FormatNumberThousands(self._credit)
    self:InitListView() 
end

function UnionShop:InitEvent( )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnHistory.onClick,function()
        UIMgr:Open("UnionReplenishmentRecord")
    end)

    self:AddListener(self._btnAddHonor.onClick,function()
        UIMgr:OpenHideLastFalse("UnionScienceDonate")
    end)

    self:AddListener(self._btnAddCredit.onClick,function()
        UIMgr:OpenHideLastFalse("UnionScienceDonate")
    end)

    self:AddListener(self._btnHelp.onClick,
        function()
            Sdk.AiHelpShowSingleFAQ(ConfigMgr.GetItem("configWindowhelps", 1003).article_id)
        end
    )

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        if self.itemId and math.ceil(self.itemId) == self.shopInfo[index+1].itemInfo.item_id then
            self.selectItem = item
            self.selectItem:SetChoose(true)
            self.itemId = nil
        end
        item:SetData(self.shopInfo[index+1], self._honor, self._credit)
    end

    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        local data = item:GetData()
        if self.selectItem then
            self.selectItem:SetChoose(false)
        end
        self.selectItem = item
        self.selectItem:SetChoose(true)
    end)

    self:AddEvent(SHOPEVENT.MarkEvent, function(id)
        for _,v in ipairs(self.shopInfo)do
            if v.ConfId == id then
                v.Mark = v.Mark + 1
                break
            end
        end
        self:RefreshPanel() 
    end)

    self:AddEvent(SHOPEVENT.BuyEvent, function(id, num)
        for _,v in ipairs(self.shopInfo)do
            if v.ConfId == id then
                v.Amount = v.Amount - num
                break
            end
        end
        self:RefreshPanel() 
    end)
    self:AddEvent(SHOPEVENT.AddEvent, function(id, num)
        for _,v in ipairs(self.shopInfo)do
            if v.ConfId == id then
                v.Amount = v.Amount + num
                v.Mark = v.Mark - num
                if v.Mark < 0 then
                    v.Mark = 0
                end
                break
            end
        end
        self:RefreshPanel() 
    end)

    self:AddEvent(SHOPEVENT.Refresh, function()
        Net.AllianceShop.Info(Model.Player.AllianceId,function(msg)
            self.shopInfo = msg.Items
            for _,v in ipairs(self.shopInfo)do
                v.itemInfo = ShopModel:GetConfigById(SHOP_TYPE.UnionShop, v.ConfId) 
            end
            self:RefreshPanel()
        end)
    end)

    self:AddEvent(EventDefines.HonorChange, function()
        self:RefreshPanel() 
    end)

    self:AddEvent(EventDefines.UIUnionDonateHonorRefresh, function(honor)
        self:RefreshPanel() 
    end)
end


function UnionShop:InitListView()
    self._listView.numItems = #self.shopInfo
end

return UnionShop
