local GD = _G.GD
local UITool = _G.UITool
local math = _G.math

local ItemAircraftAccessStore = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://AircraftSystem/itemAircraftAccessStore", ItemAircraftAccessStore)
function ItemAircraftAccessStore:ctor()
    self._status = self:GetController("status")
    self._item = self:GetChild("item")
    self._textName = self:GetChild("_textName")
    self._price = self:GetChild("price")
    self.status = nil
    self.index = 1
end
--[[
    data.quality 零件品质
    data.icon 零件icon
    data.name 零件名字
    data.cost 零件价值
    data.index 列表中的索引
]]
function ItemAircraftAccessStore:SetData(data)
    self._item:SetShowData(data.icon, data.quality)
    self._textName.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, data.name)
    self._price:SetCost(data.cost)
    self.index = data.index
end
function ItemAircraftAccessStore:GetIndex()
    return self.index
end
return ItemAircraftAccessStore
