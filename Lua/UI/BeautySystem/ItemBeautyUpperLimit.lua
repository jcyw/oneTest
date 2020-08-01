--author: 	Amu
--time:		2020-03-12 16:30:47

local BuildModel = import("Model/BuildModel")

local ItemBeautyUpperLimit = fgui.extension_class(GComponent)
fgui.register_extension("ui://BeautySystem/itemBeautyUpperLimit", ItemBeautyUpperLimit)

function ItemBeautyUpperLimit:ctor()
    self._level = self:GetChild("text1")
    self._power = self:GetChild("text2")
    self._flower = self:GetChild("text3")

    self._ctrView = self:GetController("c1")

    self:InitEvent()
end

function ItemBeautyUpperLimit:InitEvent()

end

function ItemBeautyUpperLimit:SetData(level, power, addFlower)
    self._level.text = level
    self._power.text = power
    self._flower.text = addFlower
    if level == BuildModel.GetCenterLevel() then
        self._ctrView.selectedIndex = 1
    else
        self._ctrView.selectedIndex = 0
    end
end

return ItemBeautyUpperLimit