--[[
    Author: songzeming
    Function: 城建 创建建筑 滑动列表Item
]]
local ItemListBuildSlide = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/sliderBuildItem", ItemListBuildSlide)

local BuildModel = import("Model/BuildModel")
local UpgradeModel = import("Model/UpgradeModel")
local BLANK_HALF = 2 --占位

function ItemListBuildSlide:ctor()
    self._icon = self:GetChild("icon"):GetChild("_icon")
    self:AddListener(self.onClick,function()
        self.cb()
    end)
end

function ItemListBuildSlide:Init(index, posType, cb)
    self.index = index
    self.cb = cb
    if index < BLANK_HALF or index >= self.parent.numChildren - BLANK_HALF then
        --占位item隐藏
        for i = 1, self.numChildren do
            self:GetChildAt(i - 1).visible = false
        end
        return
    end
    for i = 1, self.numChildren do
        self:GetChildAt(i - 1).visible = true
    end
    if posType == Global.BuildingZoneInnter then
        --内城
        self.building = BuildModel.InnerCreateConf()[index - BLANK_HALF + 1]
    elseif posType == Global.BuildingZoneWild then
        --城外
        self.building = BuildModel.OuterConf()[index - BLANK_HALF + 1]
    elseif posType == Global.BuildingZoneBeast then
        --巨兽
        self.building = BuildModel.BeastCreateConf()[index - BLANK_HALF + 1]
    end
    self._icon.icon = UITool.GetIcon(UpgradeModel.GetSmallIcon(self.building.id, 1))

    self:SetBuildUnlock()
end

function ItemListBuildSlide:SetLight(flag)
    self._light.visible = flag
end

function ItemListBuildSlide:SetBuildUnlock()
    local isLock = self.building.unlock_level > Model.Player.Level
    self._lock.visible = isLock
    self._icon.grayed = isLock
    self._icon.alpha = isLock and 0.4 or 1
    -- self._mask.visible = isLock
end

function ItemListBuildSlide:GetBuildUnlock()
    return not self._lock.visible
end

function ItemListBuildSlide:GetConfId()
    return self.building.id
end

function ItemListBuildSlide:GetBuilding()
    return self.building
end

function ItemListBuildSlide:GetIndex()
    return self.index
end

return ItemListBuildSlide
