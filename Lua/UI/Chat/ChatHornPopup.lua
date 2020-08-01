--author: 	Amu
--time:		2019-07-18 14:20:56
local GD = _G.GD
local PropType = import("Enum/PropType")

local ChatHornPopup = UIMgr:NewUI("ChatHornPopup")
ChatHornPopup.selectItem = nil

function ChatHornPopup:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._btnClose = self._view:GetChild("btnClose")
    self._bgMask = self._view:GetChild("bgMask")

    self._listView = self._view:GetChild("liebiao")

    self._btnUse = self._view:GetChild("btnUse")
    self._btnGold = self._view:GetChild("btnGold")
    self._textIconNum = self._btnGold:GetChild("text")

    self._ctrView = self._view:GetController("c1")

    self.itemList = GD.ItemAgent.GetItemsBysubType(PropType.ALL.Sundries, PropType.SUBTYPE.Horn)

    self:InitEvent()
end

function ChatHornPopup:OnOpen()
    self._textIconNum.visible = false
    self._amout = 0
    for _,v in ipairs(self.itemList)do
        self.myItemInfo = GD.ItemAgent.GetItemModelById(v.id)
        if self.myItemInfo then
            self._amout = self._amout + self.myItemInfo.Amount
        end
    end
    self:RefreshView()
    self._listView.scrollPane:ScrollTop()
end

function ChatHornPopup:InitEvent( )
    self:AddListener(self._btnClose.onClick,function()
        self:Close()
    end)

    self:AddListener(self._bgMask.onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnUse.onClick,function()
        if not self.selectItem then
            TipUtil.TipById(50214)
            return
        end
        local data = self.selectItem:GetData()
        Event.Broadcast(WORLD_CHAT_EVENT.Radio,self.selectItem:GetData().id)
        self:Close()
    end)

    self:AddListener(self._btnGold.onClick,function()
        if not self.selectItem then
            TipUtil.TipById(50214)
            return
        end
        local data = self.selectItem:GetData()
        self:Close()
        UIMgr:Open("Trade/TradeTips", SHOP_TYPE.ItemShop, data)
    end)

    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        if self.selectItem then
            self.selectItem:SetChoose(false)
        end
        self.selectItem = item
        self.selectItem:SetChoose(true)
        self:RefreshBtnText()
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self.itemList[index+1])
        if self._amout <= 0 and index == 0 then
            self.selectItem = item
            self.selectItem:SetChoose(true)
        end
        if not self.selectItem and item:GetAmount()>0 then
            self.selectItem = item
            self.selectItem:SetChoose(true)
        end
    end


    self:AddEvent(HORN_SHOP_EVENT.Buy, function(id)
        -- self:RefreshView()
        Event.Broadcast(WORLD_CHAT_EVENT.Radio, id)
        self:Close()
    end)
end


function ChatHornPopup:RefreshView()
    if self.selectItem then
        self.selectItem:SetChoose(false)
    end
    self._listView.numItems = #self.itemList
    self:RefreshBtnText()
end

function ChatHornPopup:RefreshBtnText( )
    local data = self.selectItem:GetData()
    if data.Amount <= 0 then
        -- self._btnUse.text = StringUtil.GetI18n("configI18nCommons", "Ui_Buy")
        self._textIconNum.text = data.price
        self._textIconNum.visible = true
        self._ctrView.selectedIndex = 1
    else
        -- self._btnUse.text = StringUtil.GetI18n("configI18nCommons", "BUTTON_USE_ITEM")
        self._textIconNum.visible = false
        self._ctrView.selectedIndex = 0
    end
end

function ChatHornPopup:Close( )
    -- if self.selectItem then
    --     self.selectItem:SetChoose(false)
    --     self.selectItem = nil
    -- end
    UIMgr:Close("ChatHornPopup")
end

function ChatHornPopup:OnClose( )
    if self.selectItem then
        self.selectItem:SetChoose(false)
        self.selectItem = nil
    end
end

return ChatHornPopup