--[[
    author:{Temmie}
    time:2020-05-18 15:11:08
    function:{物品使用动画}
]]
local ItemUseAnim = fgui.extension_class(GComponent)
fgui.register_extension("ui://Backpack/itemUseAnim", ItemUseAnim)

function ItemUseAnim:ctor()
    self._anim = self:GetTransition("iconAnim")
end

function ItemUseAnim:SetIcon(icon)
    self._icon.url = UITool.GetIcon(icon, self._icon)
end

function ItemUseAnim:PlayAnim(cb)
    self._anim:Play(cb)
end

return ItemUseAnim
