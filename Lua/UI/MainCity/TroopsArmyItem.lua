local TroopsArmyItem = fgui.extension_class(GButton)
fgui.register_extension("ui://MainCity/itemTroopsDetails", TroopsArmyItem)

local ArmiesModel = import("Model/ArmiesModel")

function TroopsArmyItem:ctor()
    self._txtTitle = self:GetChild("title")
    self._list = self:GetChild("liebiao")
    self._titleControl = self:GetController("titleControl")
    self._originHeight = self.height

    local item = self._list:AddItemFromPool()
    self._itemWidth = item.width
    self._list:RemoveChildrenToPool()
end

--[[
    --@title:
	--@armies:
	--@isHide:
	--@isMarch: 是否行军队列
	--@isBigIcon: 是否使用大号item
]]
function TroopsArmyItem:Init(title, armies, isHide, isMarch)
    self._txtTitle.text = title
    self.title = title
    self.armies = armies
    self.type = "army"
    self._titleControl.selectedPage = isHide and "hide" or "show"

    self._list.align = AlignType.Left
    self._list:RemoveChildrenToPool()
    for _,v in pairs(armies) do
        local armyPanel = self._list:AddItemFromPool()
        armyPanel.width = self._itemWidth
        local config = ConfigMgr.GetItem("configArmys", v.ConfId)
        armyPanel:Init(v, self, function(item)
            if config.army_type == Global.SecurityArmyType then
                UIMgr:Open("TrainRelated/CityDefenseAttribute", v.ConfId)
            else
                UIMgr:Open("TroopsDetailsPopup", {v.ConfId}, 1, item, false, isMarch)
            end
        end)
    end

    self._list:ResizeToFit(#armies)
end

-- 巨兽信息专用
function TroopsArmyItem:BeastInit(title, beasts, isHide)
    self._txtTitle.text = title
    self.title = title
    self.armies = beasts
    self.type = "beast"
    self._titleControl.selectedPage = isHide and "hide" or "show"

    self._list.align = AlignType.Center

    local index = 0
    self._list:RemoveChildrenToPool()
    for _,v in pairs(beasts) do
        local armyPanel = self._list:AddItemFromPool()
        armyPanel.width = self._itemWidth
        armyPanel:BeastInit(v, self, function()
            UIMgr:Open("MonsterClassPreview", v)
        end)
        index = index + 1
    end

    self._list:ResizeToFit(index)
end

-- 同时有巨兽和士兵信息
function TroopsArmyItem:MixInit(title, mission, isHide, isMarch)
    self._txtTitle.text = title
    self.title = title
    self.armies = mission
    self.type = "mix"
    self._titleControl.selectedPage = isHide and "hide" or "show"

    self._list.align = AlignType.Left

    local index = 0
    self._list:RemoveChildrenToPool()
    if next(self.armies.beasts) then
        -- 巨兽放在一行的中间
        local empty = self._list:AddItemFromPool()
        empty.width = self._itemWidth * 2 + self._list.columnGap
        empty.visible = false
        
        local armyPanel = self._list:AddItemFromPool()
        armyPanel.width = self._itemWidth
        armyPanel:BeastInit(self.armies.beasts[1], self, function()
            UIMgr:Open("MonsterClassPreview", self.armies.beasts[1])
        end)
        
        empty = self._list:AddItemFromPool()
        empty.width = self._itemWidth * 2 + self._list.columnGap
        empty.visible = false

        index = index + 5
    end

    for _,v in pairs(self.armies.armies) do
        local armyPanel = self._list:AddItemFromPool()
        armyPanel.width = self._itemWidth
        local config = ConfigMgr.GetItem("configArmys", v.ConfId)
        armyPanel:Init(v, self, function(item)
            if config.army_type == Global.SecurityArmyType then
                UIMgr:Open("TrainRelated/CityDefenseAttribute", v.ConfId)
            else
                UIMgr:Open("TroopsDetailsPopup", {v.ConfId}, 1, item, false, isMarch)
            end
        end)
    end

    self._list:ResizeToFit(index + #self.armies.armies)
end

function TroopsArmyItem:Refresh(confId)
    if self.type == "army" then
        for k,v in pairs(self.armies) do
            if v.ConfId == confId then
                table.remove(self.armies, k)
                break
            end
        end
        self:Init(self.title, self.armies)
    elseif self.type == "beast" then
        for k,v in pairs(self.armies) do
            if v.Id == confId then
                table.remove(self.armies, k)
                break
            end
        end
        self:BeastInit(self.title, self.armies)
    elseif self.type == "mix" then

    end
end

return TroopsArmyItem