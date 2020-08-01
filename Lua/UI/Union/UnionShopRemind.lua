--author: 	Amu
--time:		2019-07-01 15:42:23

local GD = _G.GD
local UnionShopRemind = UIMgr:NewUI("UnionShopRemind")
UnionShopRemind.selectItem = nil

function UnionShopRemind:OnInit()
    -- body
    self._view = self.Controller.contentPane

    self._btnClose = self._view:GetChild("btnClose")
    self._btnUse = self._view:GetChild("btnUse")
    self._item = self._view:GetChild("itemProp")
    self._titleName = self._view:GetChild("titleName")
    self._itemText = self._view:GetChild("text")
    self._mask = self._view:GetChild("_mask")

    self:InitEvent()
end

function UnionShopRemind:OnOpen(itemInfo)
    self.confId = itemInfo.Id
    local itemConfig = ConfigMgr.GetItem("configItems", itemInfo.ConfId)
    self._item:SetAmount(itemConfig.icon, itemConfig.color)
    self._titleName.text = GD.ItemAgent.GetItemNameByConfId(itemInfo.ConfId)
    self._itemText.text = GD.ItemAgent.GetItemDescByConfId(itemInfo.ConfId)
end

function UnionShopRemind:InitEvent( )
    self:AddListener(self._btnClose.onClick,function()
        self:Close()
    end)
    self:AddListener(self._mask.onClick,function()
        self:Close()
    end)
    self:AddListener(self._btnUse.onClick,function()
        Net.AllianceShop.Mark(self.confId, function()
            Event.Broadcast(SHOPEVENT.MarkEvent, self.confId)
            self:Close()
        end)
    end)
end

function UnionShopRemind:Close( )
    UIMgr:Close("UnionShopRemind")
end

return UnionShopRemind