--author: 	Amu
--time:		2020-06-28 15:13:30

local ItemArmyRow2 = fgui.extension_class(GComponent)
fgui.register_extension("ui://Arena/itemArmyRow2", ItemArmyRow2)


function ItemArmyRow2:ctor()
    self._listView = self:GetChild("liebiao")

    self.armyList = {}
    for i = 1, 2 do
        local item = self._listView:AddItemFromPool()
        table.insert(self.armyList, item)
    end

    self:InitEvent()
end

function ItemArmyRow2:InitEvent(  )
end



function ItemArmyRow2:SetData(first, second, isBeast)
    if isBeast then
        self.armyList[1]:BeastInit(first)

        if second then
            self.armyList[2].visible = true
            self.armyList[2]:BeastInit(second)
        else
            self.armyList[2].visible = false
        end
    else
        self.armyList[1]:ArmieInit(first)

        if second then
            self.armyList[2].visible = true
            self.armyList[2]:ArmieInit(second)
        else
            self.armyList[2].visible = false
        end
    end
end

return ItemArmyRow2