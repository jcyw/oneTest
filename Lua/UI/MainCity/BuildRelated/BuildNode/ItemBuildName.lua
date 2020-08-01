--[[
    Author: songzeming
    Function: 建筑 名称
]]
local ItemBuildName = fgui.extension_class(GComponent)
fgui.register_extension("ui://Build/itemBuildName", ItemBuildName)

local BuildModel = import("Model/BuildModel")

function ItemBuildName:ctor()
    self:SetBuildVisible(false)
end

function ItemBuildName:Init(building)
    self.building = building
    self.confId = building.ConfId
    self:SetBuildName(BuildModel.GetName(self.confId))
    self:SetBuildPos()
end

function ItemBuildName:SetBuildName(name)
    self._name.text = name
end

function ItemBuildName:SetBuildVisible(flag)
    self.visible = flag
end

function ItemBuildName:SetBuildPos()
    local obj = BuildModel.GetObject(self.building.Id)
    if self.confId == Global.BuildingCenter then
        --指挥中心
        self.xy = Vector2(obj.x + 170, obj.y - 630)
    elseif self.confId == Global.BuildingWall then
        ---城墙
        self.xy = Vector2(obj.x - 25, obj.y - 210)
    elseif self.confId == Global.BuildingRank then
        --战争雕像
        self.xy = Vector2(obj.x, obj.y - 100)
    elseif self.confId == Global.BuildingParadeSquare then
        --阅兵广场
        self.xy = Vector2(obj.x - 140, obj.y - 100)
    elseif self.confId == Global.BuildingSpecialMall then
        --特价商城
        self.xy = Vector2(obj.x + 100, obj.y - 150)
    elseif BuildModel.IsInnerOrBeast(self.confId) then
        --城内建筑或巨兽建筑
        self.xy = Vector2(obj.x, obj.y - 200)
    end
end

return ItemBuildName
