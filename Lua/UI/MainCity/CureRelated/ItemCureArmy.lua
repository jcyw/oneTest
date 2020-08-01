--[[
    Author: songzeming
    Function: 伤兵Item
]]
local ItemCureArmy = fgui.extension_class(GComponent)
fgui.register_extension('ui://MainCity/firstAidItem', ItemCureArmy)

local TrainModel = import('Model/TrainModel')
import('UI/Common/ItemSlide')

function ItemCureArmy:ctor()
    self._iconTroop = self:GetChild("iconTroop")

    self:AddListener(self._btnRemove.onClick,
        function()
            UIMgr:Open("TroopsDetailsFirePopup", self.army.ConfId, self.army.Amount, nil, "InjuredArmy")
        end
    )
end

function ItemCureArmy:Init(army, cb)
    self._name.text = TrainModel.GetName(army.ConfId)
    self._icon.icon = TrainModel.GetImageAvatar(army.ConfId)
    self._text.text = ArmiesModel.GetLevelText(TrainModel.GetConf(army.ConfId).level)

    self.cb = cb
    self.army = army
    self._slide:Init("CureArmy", 0, army.Amount, cb)

    local armyConf = ConfigMgr.GetItem("configArmys", army.ConfId)
    local armyTypeConf = ConfigMgr.GetItem("configArmyTypes", armyConf.arm)
    self._iconTroop.icon = UITool.GetIcon(armyTypeConf.icon)
end

function ItemCureArmy:GetChoose()
    local army = {
        ConfId = self.army.ConfId,
        Amount = self._slide:GetNumber()
    }
    return army
end

function ItemCureArmy:GetArmy()
    return self.army
end

function ItemCureArmy:SetChooseAmount(number)
    self._slide:SetNumber(number)
end

return ItemCureArmy
