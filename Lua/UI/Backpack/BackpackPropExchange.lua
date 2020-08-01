--[[
    author:{laofu}
    time:2020-05-11 17:51:32
]]
local GD = _G.GD
local BackpackPropExchange = UIMgr:NewUI("BackpackPropExchange")

function BackpackPropExchange:OnInit()
    local view = self.Controller.contentPane
    self._bgMask = view:GetChild("bgMask")
    self._titleName = view:GetChild("titleName")
    self._text = view:GetChild("text")
    self._list = view:GetChild("liebiao")

    self:InitEvent()
end

--@itemData:来自configItem的数据和道具数量
function BackpackPropExchange:OnOpen(itemData)
    GD.ItemAgent.RequireActivityExchangeInfo(itemData[1].id, function(rsp)
        self.exchangeItemInfos = {}
        for _,v in pairs(rsp.RestTimes) do
            self.exchangeItemInfos[v.Id] = v
        end
        self:RefreshShow(itemData)
    end)
end

function BackpackPropExchange:RefreshShow(itemData)
    self._exchangeIDs = itemData[1].exchange
    self.itemNum = itemData[2]

    self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TITTLE_ITEM_EXCHANGE")
    self._text.text = StringUtil.GetI18n(I18nType.Commmon, "UI_REST_ITEM_AMOUNT", {num = self.itemNum})

    self._list.numItems = #self._exchangeIDs
    if self._list.numItems < 6 then
        self._list:ResizeToFit(self._list.numItems)
    end
end

--[[
    @desc:事件注册
]]
function BackpackPropExchange:InitEvent()
    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("BackpackPropExchange")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("BackpackPropExchange")
        end
    )
    self._list.itemRenderer = function(index, item)
        local exchangeID = self._exchangeIDs[index + 1]
        --得到configExchanges表里的数据传递给ItemBackpackPropExchange
        local exchangeConfig = ConfigMgr.GetItem("configExchanges", exchangeID)
        item:SetData(exchangeConfig, self.itemNum, self.exchangeItemInfos[exchangeID].RestTimes)
    end

    self:AddEvent(
        EventDefines.ExchangeRefresh,
        function(itemData, id, num)
            self.exchangeItemInfos[id].RestTimes = self.exchangeItemInfos[id].RestTimes - num
            self:RefreshShow(itemData)
        end
    )
end

return BackpackPropExchange
