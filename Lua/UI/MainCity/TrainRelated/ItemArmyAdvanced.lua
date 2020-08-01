--[[
    Author: xiaoze
    Function: 训练进阶 兵种信息
]]
local ItemArmyAdvanced = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/ItemArmyAdvanced", ItemArmyAdvanced)

local TrainModel = import("Model/TrainModel")

function ItemArmyAdvanced:ctor()
    self._textNumber = self._number:GetChild("number")
end

function ItemArmyAdvanced:SetArmyData(armyId)
    self._title.text = TrainModel.GetName(armyId)
    self._icon.icon = TrainModel.GetImageNormal(armyId)
    self._textNumber.text = TrainModel.GetArmAmount(armyId)
end

return ItemArmyAdvanced