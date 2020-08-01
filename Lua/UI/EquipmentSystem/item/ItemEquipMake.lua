--[[
    author:Temmie
    time:2020-06-12
    function:装备材料拖动item
]]
local ItemEquipMake = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://EquipmentSystem/itemEquipMake", ItemEquipMake)

function ItemEquipMake:ctor()
    self.onClickFunc = function()
        if self.onClickCB then
            self.onClickCB()
        end
    end
end

function ItemEquipMake:Init(config)
    self.config = config
    self._icon.url = UITool.GetIcon(config.icon)
    self._selected.visible = false
    self:RemoveListener(self.onClick, self.onClickFunc)
end

function ItemEquipMake:HideIcon(hide)
    self._icon.visible = not hide
end

function ItemEquipMake:HideBg(hide)
    self._bg.visible = not hide
end

function ItemEquipMake:SetSelected(selected)
    self._selected.visible = selected
end

function ItemEquipMake:SetOnClick(cb)
    self.onClickCB = cb
    self:AddListener(self.onClick, self.onClickFunc)
end

return ItemEquipMake
