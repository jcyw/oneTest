local SevenDayActivitiesPopup = UIMgr:NewUI("SevenDayActivitiesPopup")

local WelfareModel = import("Model/WelfareModel")

function SevenDayActivitiesPopup:OnInit()
    self._view = self.Controller.contentPane
    self._list = self._view:GetChild("liebiao")
    self._btnClose = self._view:GetChild("btnClose")
    self._textTitle = self._view:GetChild("titleName")
    self._bgMask = self._view:GetChild("bgMask")
    self:InitEvent()
end

function SevenDayActivitiesPopup:InitEvent()
    self._list:SetVirtual()
    self._list.itemRenderer = function(index, item)
        item:SetData(self.items[index + 1])
    end

    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )

    self:AddListener(self._bgMask.onClick,
        function()
            self:Close()
        end
    )
end

function SevenDayActivitiesPopup:OnOpen(data)
    self.id = data.id
    self.hasGet = data.hasGet
    local text = self.hasGet and "ACTIVITY_REWARD_GETED" or "ACTIVITY_REWARD_GET"
    self._textTitle.text = StringUtil.GetI18n(I18nType.Commmon, text)
    self:ShowList()
end

function SevenDayActivitiesPopup:ShowList()
    local giftId = ConfigMgr.GetItem("configSevenDayPoints", self.id).gift
    -- local gift = ConfigMgr.GetItem("configGifts", giftId)
    self.items, self.itemCount = WelfareModel.GetResOrItemByGiftId(giftId)
	self._list.numItems = self.itemCount
end

function SevenDayActivitiesPopup:Close()
    UIMgr:Close("SevenDayActivitiesPopup")
end

function SevenDayActivitiesPopup:OnClose()
end
return SevenDayActivitiesPopup
