--[[
    author:{maxiaolong}
    time:2019-10-21 19:44:47
    function:{疯狂兑换弹窗}
]]
local StoredValueExchangePopup = UIMgr:NewUI("StoredValueExchangePopup")
local WelfareModel = import("Model/WelfareModel")

function StoredValueExchangePopup:OnInit()
    self._view = self.Controller.contentPane
    self._bgMask = self._view:GetChild("bgMask")
    self._bgClose = self._view:GetChild("btnClose")
    self._title = self._view:GetChild("titleName")
    self._residual = self._view:GetChild("textResidual")
    self._residualNum = self._view:GetChild("textResidualNum")
    self._listView = self._view:GetChild("liebiao")
    self._residual.text = "剩余道具数量:"
    self._listView.itemRenderer = function(index, item)
        if self.convertData == nil then
            return
        end
        local itemData = self.convertData[index + 1]
        item:SetData(itemData)
    end
    self:AddListener(self._bgClose.onClick,
        function()
            self:OnClose()
        end
    )
    self:AddEvent(
        EventDefines.CarzyStore,
        function(param)
            local residualNums = param
            self._residualNum.text = residualNums
            local items = self._listView.numItems
            for i = 1, items do
                local item = self._listView:GetChildAt(i - 1)
                item:SetItemNum(residualNums)
            end
        end
    )
end

function StoredValueExchangePopup:OnOpen(caryParam)
    self.listData = caryParam.AwardInfo
    if self.listData == nil then
        return
    end
    self.convertData = {}
    local caryDataTable = {}
    for key, v in pairs(caryParam.AwardInfo) do
        local giftId, cost, limit = WelfareModel.EveryDayCrayInfo(v.Category)
        local giftNum, itemData = WelfareModel:GetGiftInfoById(giftId,2)
        caryDataTable.cost = cost
        caryDataTable.giftNum = giftNum
        caryDataTable.itemData = itemData
        caryDataTable.cateGory = v.Category
        caryDataTable.residualNum = caryParam.ItemAmount
        caryDataTable.restTimes = v.RestTimes
        table.insert(self.convertData, caryDataTable)
    end

    self._residualNum.text = tostring(caryParam.ItemAmount)
    self._listView.numItems = #self.listData
end

function StoredValueExchangePopup:OnClose()
    UIMgr:Close("StoredValueExchangePopup")
end
return StoredValueExchangePopup
