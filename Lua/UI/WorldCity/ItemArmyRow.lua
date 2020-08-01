--[[
    author:{zhanzhang}
    time:2019-11-26 10:03:04
    function:{兵力详情行列,巨兽也包含}
]]
local ItemArmyRow = fgui.extension_class(GComponent)
fgui.register_extension("ui://WorldCity/itemArmyRow", ItemArmyRow)


function ItemArmyRow:ctor()
    self.contentList = self:GetChild("liebiao")
    self.armyList = {}
    for i = 1, 2 do
        local item = self.contentList:AddItemFromPool()
        table.insert(self.armyList, item)
    end
end

function ItemArmyRow:Init(first, second, isBeast)
    if isBeast then
        self.armyList[1]:BeastInit(first)

        if second then
            self.armyList[2].visible = true
            self.armyList[2]:BeastInit(second)
        else
            self.armyList[2].visible = false
        end
    else
        self.armyList[1]:Init(first)

        if second then
            self.armyList[2].visible = true
            self.armyList[2]:Init(second)
        else
            self.armyList[2].visible = false
        end
    end
end

return ItemArmyRow
