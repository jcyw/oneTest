local math = _G.math
local ItemAirraftPrice = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://AircraftSystem/itemAirraftPrice", ItemAirraftPrice)
local priceNumStatus = {
    Bronze = "Bronze",
    Silver = "Silver",
    Gold = "Gold"
}
function ItemAirraftPrice:ctor()
    self._goldNum1 = self:GetChild("goldNum1")
    self._goldNum2 = self:GetChild("goldNum2")
    self._goldNum3 = self:GetChild("goldNum3")
    self._goldIcon1 = self:GetChild("goldIcon1")
    self._goldIcon2 = self:GetChild("goldIcon2")
    self._goldIcon3 = self:GetChild("goldIcon3")

    self.status = priceNumStatus.Bronze
end
function ItemAirraftPrice:SetCost(cost)
    cost = cost < 0  and 0 or cost
    self._goldNum1.text = 0
    self._goldNum2.text = 0
    self._goldNum3.text = 0
    local goldNum =  math.modf(cost/ 10000)
    self.status = priceNumStatus.Bronze 
    cost = math.fmod(cost,10000)
    local silverNum = math.modf(cost/ 100)
    if silverNum > 0 then
        self._goldNum2.text = silverNum
        self.status = priceNumStatus.Silver
    end
    if goldNum > 0 then
        self._goldNum1.text = goldNum
        self.status = priceNumStatus.Gold
    end
    self._goldNum3.text = math.fmod(cost,100)
    self:PosiAdj()
end
-- 位置调整
function ItemAirraftPrice:PosiAdj()
    local posiFunc = {}
    self._goldNum1.visible = self.status == priceNumStatus.Gold
    self._goldIcon1.visible = self.status == priceNumStatus.Gold
    self._goldNum2.visible = (self.status ~= priceNumStatus.Bronze)
    self._goldIcon2.visible = (self.status ~= priceNumStatus.Bronze)
    self._goldNum3.visible = true
    self._goldIcon3.visible = true
    posiFunc[priceNumStatus.Gold] = function()
        self._goldNum1.x = 0
        self._goldIcon1.x = self._goldNum1.x + self._goldNum1.textWidth
        self._goldNum2.x = self._goldIcon1.x + self._goldIcon1.width
        self._goldIcon2.x = self._goldNum2.x + self._goldNum2.textWidth
        self._goldNum3.x = self._goldIcon2.x + self._goldIcon2.width
        self._goldIcon3.x = self._goldNum3.x + self._goldNum3.textWidth
    end
    posiFunc[priceNumStatus.Silver] = function()
        self._goldNum2.x = 0
        self._goldIcon2.x = self._goldNum2.x + self._goldNum2.textWidth
        self._goldNum3.x = self._goldIcon2.x + self._goldIcon2.width
        self._goldIcon3.x = self._goldNum3.x + self._goldNum3.textWidth
    end
    posiFunc[priceNumStatus.Bronze] = function()
        self._goldNum3.x = 0
        self._goldIcon3.x = self._goldNum3.x + self._goldNum3.textWidth
    end
    posiFunc[self.status]()
end
return ItemAirraftPrice