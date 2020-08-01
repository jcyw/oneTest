--[[
    author:{maxiaolong}
    time:2019-10-21 20:40:05
    function:{兑换奖励组件}
]]
local ItemStoredValueExchangePopup = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemStoredValueExchangePopup", ItemStoredValueExchangePopup)
-- local ExchangePopup = import("UI/Welfare/StoredValueExchangePopup")
function ItemStoredValueExchangePopup:ctor()
    self._icon1 = self:GetChild("n11")
    self._c1 = self:GetController("c1")
    self._icon1Icon = self._icon1:GetChild("_icon")
    self._iconNum1 = self._icon1:GetChild("_amount")
    self._icon2 = self:GetChild("n13")
    self._icon2Icon = self._icon2:GetChild("_icon")
    self._iconNum2 = self._icon2:GetChild("_amount")
    self._textTime = self:GetChild("textTime")
    self._textNum = self:GetChild("textNum")
    self._getBtn = self:GetChild("btnGet")
    self._grayBtn = self:GetChild("btnGray")
    self._getBtn:GetChild("title").text = "兑换"
    self._grayBtn:GetChild("title").text = "兑换"
    self:AddListener(self._getBtn.onClick,
        function()
            if self.cateGory == nil then
                return
            end
            if self.residualNum < self.cost then
                -- TipUtil.Tip("疯狂兑换卷够")
                return
            elseif self.restTimes == 0 then
                TipUtil.TipById(50257)
                return
            end

            Net.Activity.GetCrazyExchangeAward(
                self.cateGory,
                function(param)
                    Event.Broadcast(EventDefines.CarzyStore, param.RestItems)
                    self._textNum.text = param.RestTimes
                end
            )
        end
    )
end

function ItemStoredValueExchangePopup:SetData(infoTable)
    self.cost = infoTable.cost
    self.restTimes = infoTable.restTimes
    self.residualNum = infoTable.residualNum
    self._iconNum1.text = tostring(infoTable.residualNum) .. "/" .. tostring(infoTable.cost)
    local crazyIcon = ConfigMgr.GetItem("configItems", Global.CrazyExchangeItemID).icon
    self.cateGory = infoTable.cateGory
    local icon2Data = infoTable.itemData[1][1].icon
    self._iconNum2.text = tostring(infoTable.itemData[1][2])
    self._icon1Icon.icon = UITool.GetIcon(crazyIcon)
    self._icon2Icon.icon = UITool.GetIcon(icon2Data)
    self._textTime.text = "剩余次数"
    self._textNum.text = self.restTimes
    if infoTable.residualNum >= infoTable.cost then
        self._c1.selectedIndex = 0
    else
        self._c1.selectedIndex = 1
    end
end

function ItemStoredValueExchangePopup:SetItemNum(residualNums)
    self._iconNum1.text = tostring(residualNums) .. "/" .. tostring(self.cost)
end
return ItemStoredValueExchangePopup
