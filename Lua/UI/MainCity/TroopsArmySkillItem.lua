local TroopsArmySkillItem = fgui.extension_class(GButton)
fgui.register_extension("ui://MainCity/itemTroopsDetails_Popup", TroopsArmySkillItem)

function TroopsArmySkillItem:ctor()
    self._icon = self:GetChild("icon"):GetChild("_icon")
    self._title = self:GetChild("title")
    self._desc = self:GetChild("desc")

    self._iconCom = self:GetChild("icon")
    
    if self._iconCom:GetChild("_amountMid").text == "" then
        self._iconCom:GetChild("_numBg").visible = false
    else
        self._iconCom:GetChild("_numBg").visible = true
    end
end

function TroopsArmySkillItem:Init(icon, title, desc)
    self._iconCom:SetShowData(icon)
    self._title.text = title
    self._desc.text = desc
end

return TroopsArmySkillItem
