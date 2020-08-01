local itemEquipmentAssemblyAttack =  _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://EquipmentSystem/itemEquipmentAssemblyAttack", itemEquipmentAssemblyAttack)

function itemEquipmentAssemblyAttack:ctor()
    --获取部件
    self._textAttact1 = self:GetChild("textAttact1")
    self._textAttactNum1 = self:GetChild("textAttactNum1")
    self._ctr = self:GetController("c1")
    self._bg = self:GetChild("bg")
end
function itemEquipmentAssemblyAttack:SetData(buffName,value,ctr)
    self._textAttact1.text = _G.StringUtil.GetI18n("configI18nEquips", buffName)
    self._textAttactNum1.text = value
    self._ctr.selectedIndex = ctr
end
-- 设置背景透明度a
function itemEquipmentAssemblyAttack:SetBgA(alphaValue)
    self._bg.alpha = alphaValue
end
-- 设置背景透明度a
function itemEquipmentAssemblyAttack:SetHight(hValue)
    self.height = hValue
end
return itemEquipmentAssemblyAttack