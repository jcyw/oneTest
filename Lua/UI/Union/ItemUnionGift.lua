--author: 	Amu
--time:		2019-07-08 16:08:32


local ItemUnionGift = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionGift", ItemUnionGift)

ItemUnionGift.tempList = {}

function ItemUnionGift:ctor()
    self._icon = self:GetChild("icon")

    self._itemNum = self:GetChild("iconNum")
    self._textName = self:GetChild("textName")
    self._textCountDownNum = self:GetChild("textCountDownNum")
    self._textTime = self:GetChild("textTime")

    self._btnGet = self:GetChild("btnGet")

    self:InitEvent()
end

function ItemUnionGift:InitEvent()
    self:AddListener(self._btnGet.onClick,function()--领取
        Event.Broadcast(UNIONGIFTEVENT.Get, self.info.ItemId, self.info.ConfId)
    end)

    local callback
    callback = function()
        if not self._endTime then
            return
        end
        local time = self._endTime - Tool.Time()
        if time <= 0 then
            self:UnSchedule(callback)
            self._scheduler = false
            return
        end
        self._textCountDownNum.text = TimeUtil.SecondToHMS(time)
    end
    local dt = 0.5
    self:AddEvent(UNIONGIFTCOUNTDOWNEVENT.Start, function()
        if not self._scheduler then
            self:Schedule(callback, dt)
            self._scheduler = true
        end
    end)

    self:AddEvent(UNIONGIFTCOUNTDOWNEVENT.End, function()
        self:UnSchedule(callback)
        self._scheduler = false
    end)
end

function ItemUnionGift:SetData(info, isClick)
    self.info = info
    self._scheduler = false
    local giftInfo = ConfigMgr.GetItem("configAllianceGifts", info.ConfId)
    self._endTime = info.Start+giftInfo.time


    self._itemNum.text = info.Amount
    self._textName.text = ConfigMgr.GetI18n("configI18nCommons", giftInfo.name)
end

function ItemUnionGift:getData(  )
    return self.info
end

return ItemUnionGift