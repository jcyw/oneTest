--[[
    author:Temmie
    time:2020-06-21
    function:装备显示item
]]
local GD = _G.GD
local ItemEquipDecomposition = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://EquipmentSystem/itemEquipDecomposition", ItemEquipDecomposition)

function ItemEquipDecomposition:ctor()
    self._wearController = self:GetController("wearController")
    self:AddListener(self.onClick, function()
        if self.cb then
            self.cb()
        end
    end)
end

function ItemEquipDecomposition:Init(icon, quality, isPuton, cb)
    self._icon.url = UITool.GetIcon(icon, self._icon)
    self._iconBg.url = GD.ItemAgent.GetItmeQualityByColor(quality - 1)
    self._wearController.selectedIndex = isPuton and 1 or 0
    self.cb = cb
end

return ItemEquipDecomposition
