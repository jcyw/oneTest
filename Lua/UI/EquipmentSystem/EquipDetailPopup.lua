--[[
    author:Temmie
    time:2020-06-20 
    function:装备分解弹窗
]]
local GD = _G.GD
local EquipDetailPopup = _G.UIMgr:NewUI("EquipDetailPopup")
local UIMgr = _G.UIMgr
local EquipModel = _G.EquipModel
local StringUtil = _G.StringUtil

function EquipDetailPopup:OnInit()
    self:AddListener(self._mask.onClick, function()
        UIMgr:Close("EquipDetailPopup")
    end)

    self:AddListener(self._btnClose.onClick, function()
        UIMgr:Close("EquipDetailPopup")
    end)

    self:AddListener(self._btnEquip.onClick, function()
        self._btnEquip.enabled = false
        Net.Equip.ResolveEquip(self.model.Uuid, function(rsp)
            self._btnEquip.enabled = true
            UIMgr:Close("EquipDetailPopup")
            UIMgr:Open("GetMaterialPopup", rsp.JewelList)

            Event.Broadcast(EventDefines.RefreshEquipInfo)

            if self.sureCB then
                self.sureCB()
            end
        end)
    end)
end

function EquipDetailPopup:OnOpen(uuid, sureCallback)
    self.model = EquipModel.GetEquipModelByUuid(uuid)
    self.config = EquipModel.GetEquipQualityById(self.model.Id)
    self.typeConfig = EquipModel.GetEquipTypeById(math.modf(self.model.Id / 100) * 100)
    self.sureCB = sureCallback

    self._btnEquip.enabled = true

    local name = StringUtil.GetI18n(I18nType.Commmon, "quality_color_"..(self.config.quality - 1))
    local suffix = StringUtil.GetI18n(I18nType.Commmon, "equip_ui_9_2") 
    local color = EquipModel.GetColorCodeByQuality(self.config.quality)
    self._textLevel.text = ("%s[color=#%s][%s%sx%d][/color]"):format(StringUtil.GetI18n(I18nType.Commmon, "equip_ui_21_1"), color, name, suffix, self.config.break_numb)
    self._textNum.text = "X"..self.config.break_numb
    self._itemMaterial.url = GD.ItemAgent.GetItmeQualityByColor(self.config.quality - 1)
end

return EquipDetailPopup