--author: 	Amu
--time:		2020-06-28 16:27:41

local GD = _G.GD
local EquipModel = _G.EquipModel

local ItemArenaViewEquip = fgui.extension_class(GComponent)
fgui.register_extension("ui://Arena/itemArenaViewEquip", ItemArenaViewEquip)


function ItemArenaViewEquip:ctor()

    self._iconRank = self:GetChild("iconRank")

    self._icon = self:GetChild("icon")
    self._iconBg = self:GetChild("iconBg")
    self._name = self:GetChild("textName")
    self._level = self:GetChild("_amount")
    self._textBg = self:GetChild("textBg")


    self._ctrView = self:GetController("c1")

    self:InitEvent()
end

function ItemArenaViewEquip:InitEvent(  )
end

function ItemArenaViewEquip:SetData(equipId, Pos)
    if equipId <= 0 then
        local equipInfo = ConfigMgr.GetItem("configEquipParts", Pos)
        self._icon.icon = UITool.GetIcon(equipInfo.icon)
        self._iconBg.url = GD.ItemAgent.GetItmeQualityByColor(0)
        self._name.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS32")
        -- self._level.text = "Lv."..equipInfo.equip_level
        self._level.visible = false
        self._textBg.visible = false
    else
        local quality = EquipModel.GetEquipQualityById(equipId).quality
        local color = EquipModel.GetColorCodeByQuality(quality)
        local id = EquipModel.QualityID2TypeID(equipId)
        local equipInfo = ConfigMgr.GetItem("configEquipTypes", id)
        self._icon.icon = UITool.GetIcon(equipInfo.icon)
        self._iconBg.url = GD.ItemAgent.GetItmeQualityByColor(quality - 1)
        self._name.text = ("[color=#%s]%s[/color]"):format(color, StringUtil.GetI18n(I18nType.Equip, equipInfo.name))
        self._level.text = "Lv."..equipInfo.equip_level
        self._level.visible = true
        self._textBg.visible = true
    end
end

return ItemArenaViewEquip