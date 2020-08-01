--author: 	Amu
--time:		2019-07-08 15:08:36


local UnionGift = UIMgr:NewUI("UnionGift")

function UnionGift:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._btnReturn = self._view:GetChild("btnReturn")

    self._btnHelp = self._view:GetChild("btnHelp")
    
    self._iconGiftLevel = self._view:GetChild("iconGift1")
    self._levelGiftLevel = self._view:GetChild("textLevel")
    self._proTextGiftLevel = self._view:GetChild("progressBarNum1")
    self._proGiftLevel = self._view:GetChild("progressBar1")

    self._iconGift = self._view:GetChild("iconGift2")
    self._nameGift = self._view:GetChild("textGiftName")
    self._proTextGift = self._view:GetChild("progressBarNum2")
    self._proGift = self._view:GetChild("progressBar2")

    self._listView = self._view:GetChild("liebiao")

    self._btnGetAll = self._view:GetChild("btnGetAll")

    self:InitEvent()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.UnionGift)
end

function UnionGift:OnOpen(info)
    self.info = info
    self:RefreshPanel()
end

function UnionGift:Close()
    UIMgr:Close("UnionGift")
end

function UnionGift:OnClose()
    Event.Broadcast(UNIONGIFTCOUNTDOWNEVENT.End)
end

function UnionGift:InitEvent( )
    self:AddListener(self._btnReturn.onClick,function()--返回
        self:Close()
    end)

    self:AddListener(self._btnHelp.onClick,function()--帮助
        local data = {
            title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
            info = StringUtil.GetI18n(I18nType.Commmon, "Uii_Alliance_GiftTipsTap")
        }
        UIMgr:Open("ConfirmPopupTextList", data)
    end)

    self:AddListener(self._btnGetAll.onClick,function()--领取所有
        for _,v in pairs(self.gifts)do
            if not v.isGet then
                self:ReceiveGift(v.ItemId)
            end
        end
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self.gifts[index+1])
    end
    self._listView:SetVirtual()

    self:AddEvent(UNIONGIFTEVENT.Get,function(itemId)
        self:ReceiveGift(itemId)
    end)

    self:AddEvent(UNIONGIFTEVENT.GetAll,function(rsp)

    end)
end

function UnionGift:RefreahListView( )
    self._listView.numItems = #self.gifts
end

function UnionGift:RefreshPanel( )
    Net.AllianceGift.RequestGiftInfo(Model.Player.AllianceId, function(msg)
        self.giftInfo = msg.GiftInfo
        self.gifts = msg.Gifts

        for _,v in pairs(self.gifts)do
            v.isGet = false
            for _,uid in pairs(v.GetList)do
                if uid == Model.Player.AllianceId then
                    v.isGet = true
                    break
                end
            end
        end

        self:RefreshData()
        self:RefreahListView()
        Event.Broadcast(UNIONGIFTCOUNTDOWNEVENT.Start)
    end)
end

function UnionGift:RefreshData( )
    -- local levelGiftInfo = ConfigMgr.GetItem("configAllianceGiftLevels", self.giftInfo.TLevel)
    self._levelGiftLevel.text = string.format("Lv.%d", self.giftInfo.TLevel)
    if self.giftInfo.TLevel+1 >= #ConfigMgr.GetList("configAllianceGiftLevels") then
        self._proTextGiftLevel.text = string.format("%d/%d", 0, 0)
        self._proGiftLevel.value = 100
    else
        local nextLevelGiftInfo = ConfigMgr.GetItem("configAllianceGiftLevels", (self.giftInfo.TLevel+1))
        self._proTextGiftLevel.text = string.format("%d/%d", self.giftInfo.TExp, nextLevelGiftInfo.exp)
        self._proGiftLevel.value = self.giftInfo.TExp/nextLevelGiftInfo.exp*100
    end
    local ranGiftInfo = ConfigMgr.GetItem("configAllianceGifts", self.giftInfo.ConfId)
    self._nameGift.text = ConfigMgr.GetI18n("configI18nCommons", ranGiftInfo.name)
    self._proTextGift.text =string.format("%d/%d", self.giftInfo.Exp, ranGiftInfo.exp)
    self._proGift.value = self.giftInfo.Exp/ranGiftInfo.exp*100
end

function UnionGift:ReceiveGift(itemId)
    Net.AllianceGift.RequestGetGift(Model.Player.AllianceId, itemId, function()
        for k,v in pairs(self.gifts)do
            if v.ItemId == itemId then
                table.remove(self.gifts, k)
                self:RefreahListView()
                break
            end
        end
    end)
end

return UnionGift