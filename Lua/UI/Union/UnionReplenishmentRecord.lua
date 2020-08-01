--author: 	Amu
--time:		2019-07-01 15:42:40
local GD = _G.GD
local ShopModel = import("Model/ShopModel")

local UnionReplenishmentRecord = UIMgr:NewUI("UnionReplenishmentRecord")
UnionReplenishmentRecord.selectItem = nil
UnionReplenishmentRecord.history = {}

function UnionReplenishmentRecord:OnInit()
    -- body
    self._view = self.Controller.contentPane

    self._btnInventory = self._view:GetChild("btnInventory")
    self._btnStore = self._view:GetChild("btnStore")
    self._btnClose = self._view:GetChild("btnClose")
    self._bgMask = self._view:GetChild("bgMask")

    self._listView = self._view:GetChild("liebiao")
    self._NoRecoredName = self._view:GetChild("NoRecoredName")
    self._ctrView = self._view:GetController("c1")

    self:InitEvent()
end

function UnionReplenishmentRecord:OnOpen()
    self.chose = ALLIANCE_SHOP_LOG_TYPE.AllianceShopLogTypeBuy
    self._ctrView.selectedIndex = 0
    self:RefreshListView()
end

function UnionReplenishmentRecord:InitEvent( )
    self:AddListener(self._btnClose.onClick,function()
        self:Close()
    end)

    self:AddListener(self._bgMask.onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnInventory.onClick,function()
        self.chose = ALLIANCE_SHOP_LOG_TYPE.AllianceShopLogTypeBuy
        self:RefreshListView()
    end)

    self:AddListener(self._btnStore.onClick,function()
        self.chose = ALLIANCE_SHOP_LOG_TYPE.AllianceShopLogTypeStock
        self:RefreshListView()
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        local data =  self.history[self.chose]
        local info =data[#data - index]
        -- item:SetData(self._itemList[index+1])
        local data = {
            play_name = info.UserName,
            number = info.Amount,
            item_name = GD.ItemAgent.GetItemNameByConfId(ShopModel:GetConfigById(SHOP_TYPE.UnionShop, info.ConfId).item_id),
        }
        if self.chose == ALLIANCE_SHOP_LOG_TYPE.AllianceShopLogTypeStock then
            item:GetChild("title").text = StringUtil.GetI18n("configI18nCommons", "Ui_Alliance_BuyHistory", data)
        elseif self.chose == ALLIANCE_SHOP_LOG_TYPE.AllianceShopLogTypeBuy then
            item:GetChild("title").text = StringUtil.GetI18n("configI18nCommons", "Ui_Alliance_PurchaseHistory", data)
        end
        item:GetChild("text").text = TimeUtil:GetTimesAgo(info.CreatedAt)
    end
    self._listView:SetVirtual()
    self._NoRecoredName.text = StringUtil.GetI18n("configI18nCommons", "Ui_Shop_Nohistory")
end

function UnionReplenishmentRecord:RefreshListView()
    if not self.history[self.chose] then
        Net.AllianceShop.Log(self.chose, function(msg)
            table.sort(msg.Logs, function(a, b)
                return b.CreatedAt > a.CreatedAt
            end)
            self.history[self.chose] = msg.Logs
            self._listView.numItems = #self.history[self.chose]
            if(#self.history[self.chose]>0)then
                self._NoRecoredName.visible = false
            else
                self._NoRecoredName.visible = true
            end
        end)
        return
    end
    self._listView.numItems = #self.history[self.chose]
    if(#self.history[self.chose]>0)then
        self._NoRecoredName.visible = false
    else
        self._NoRecoredName.visible = true
    end
end

function UnionReplenishmentRecord:Close( )
    UIMgr:Close("UnionReplenishmentRecord")
end

function UnionReplenishmentRecord:OnClose()
    self.history = {}
end

return UnionReplenishmentRecord