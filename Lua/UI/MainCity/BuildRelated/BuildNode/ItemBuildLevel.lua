--[[
    Author: songzeming
    Function: 建筑 等级
]]
local ItemBuildLevel = fgui.extension_class(GComponent)
fgui.register_extension("ui://Build/itemBuildLevel", ItemBuildLevel)

local BuildModel = import("Model/BuildModel")
local CTR = {
    Normal = "Normal",
    Upgrade = "Upgrade"
}
local CTR_NUM = {
    Single = "Single",
    Double = "Double"
}

function ItemBuildLevel:ctor()
    self.ctr = self:GetController("Ctr")
    self.ctrNum = self:GetController("CtrNum")
    self:SetUpgrade(false)
end

function ItemBuildLevel:Init(building)
    self.building = building
    self:SetBuildLevel(building.Level)
    self:SetBuildPos()
end

function ItemBuildLevel:SetBuildLevel(level)
    self._level.text = level
    self._level2.text = level
    self.ctrNum.selectedPage = level < 10 and CTR_NUM.Single or CTR_NUM.Double
end

function ItemBuildLevel:SetUpgrade(flag)
    self.ctr.selectedPage = flag and CTR.Upgrade or CTR.Normal
end

function ItemBuildLevel:GetUpgrade()
    return self.ctr.selectedPage == CTR.Upgrade
end

function ItemBuildLevel:SetBuildPos()
    local obj = BuildModel.GetObject(self.building.Id)
    if self.building.ConfId == Global.BuildingCenter then
        self.xy = Vector2(obj.x + 525, obj.y - 325)
    elseif self.building.ConfId == Global.BuildingWall then
        self.xy = Vector2(obj.x + 38, obj.y - 200)
    elseif BuildModel.IsInnerOrBeast(self.building.ConfId) then
        self.xy = Vector2(obj.x + 145, obj.y - 135)
    elseif self.building.ConfId == Global.BuildingGodzilla then
        self.xy = Vector2(obj.x + 210, obj.y - 240)
    elseif self.building.ConfId == Global.BuildingKingkong then
        self.xy = Vector2(obj.x + 165, obj.y - 160)
    else
        self.xy = Vector2(obj.x + 65, obj.y - 90)
    end
end

return ItemBuildLevel
