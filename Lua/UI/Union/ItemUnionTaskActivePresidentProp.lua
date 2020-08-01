--author: 	Amu
--time:		2019-07-02 14:27:30
local GD = _G.GD
local ItemUnionTaskActivePresidentProp = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionTaskActivePresidentProp", ItemUnionTaskActivePresidentProp)

ItemUnionTaskActivePresidentProp.tempList = {}

function ItemUnionTaskActivePresidentProp:ctor()
    self._icon = self:GetChild("icon")
    self._amount = self:GetChild("amount")
    self._title = self:GetChild("title")

    self:InitEvent()
end

function ItemUnionTaskActivePresidentProp:InitEvent()
end

function ItemUnionTaskActivePresidentProp:SetData(info)
    self._info = info
end

return ItemUnionTaskActivePresidentProp