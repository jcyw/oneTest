--[[
    Author: songzeming
    Function: 特效道具 Item
]]
local GD = _G.GD
local ItemPropEffect = fgui.extension_class(GComponent)
fgui.register_extension("ui://Effect/itemPropEffect", ItemPropEffect)

local CTR = {
    Normal = "Normal",
    Icon = "Icon",
    IconMiddle = "IconMiddle"
}

function ItemPropEffect:ctor()
    self._ctr = self:GetController("Ctr")
end

function ItemPropEffect:InitNormal()
    self._ctr.selectedPage = CTR.Normal
    self._numBg.visible = false
end

function ItemPropEffect:InitIcon(icon, amount)
    self._ctr.selectedPage = CTR.Icon
    self._icon.icon = icon
    self._amount.text = amount and "+" .. amount or ""
    self._numBg.visible = false
end

function ItemPropEffect:IconMiddle(icon, amount, amountMid, color)
    self._ctr.selectedPage = CTR.IconMiddle
    self._icon.icon = icon
    self._amount.text = amount and "+" .. amount or ""
    self._amountMid.text = amountMid or ""
    if amountMid then
        self._numBg.visible = true
        GD.ItemAgent.SetMiddleBg(self._numBg, color)
    else
        self._numBg.visible = false
    end
end

function ItemPropEffect:GetIconLoader()
    return self._cion
end

return ItemPropEffect
