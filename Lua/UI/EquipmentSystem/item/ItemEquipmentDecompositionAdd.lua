--[[
    author:Temmie
    time:2020-06-20 
    function:装备合成界面提示面板
]]
local ItemEquipmentDecompositionAdd = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://EquipmentSystem/itemEquipmentDecompositionAdd", ItemEquipmentDecompositionAdd)

local UIMgr = _G.UIMgr

function ItemEquipmentDecompositionAdd:ctor()
    self._typeController = self:GetController("typeController")
    self._arrowController = self:GetController("arrowController")

    self:AddListener(self._btnForge.onClick, function()
        UIMgr:ClosePopAndTopPanel()
        UIMgr:Open("EquipmentSelect",1)
    end)
end

function ItemEquipmentDecompositionAdd:Init(quality, lv, index, ignores, cb)
    self._arrowController.selectedIndex = index - 1
    self.ignores = ignores
    self.cb = cb

    local color = EquipModel.GetColorCodeByQuality(quality)
    local text1 = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Level")..lv
    local text2 = ("[color=#%s]%s%s[/color]"):format(color, StringUtil.GetI18n(I18nType.Commmon, "quality_color_"..(quality - 1)), StringUtil.GetI18n(I18nType.Commmon, "equip_ui_9_3"))
    self._textPutin.text = StringUtil.GetI18n(I18nType.Commmon, "equip_ui_15_1", { color = text1, equip = text2})

    self.equips = EquipModel.GetEquipsByQulityLevel(quality, lv)
    self:FilterIgnore(self.equips)
    if #self.equips > 0 then
        self._typeController.selectedIndex = 1
        self:RefreshList()
    else
        self._typeController.selectedIndex = 0
    end
end

function ItemEquipmentDecompositionAdd:RefreshList()
    self._list:RemoveChildrenToPool()
    for _,v in pairs(self.equips) do
        if not v.IsLock then
            local item = self._list:AddItemFromPool()
            local config = EquipModel.GetEquipQualityById(v.Id)
            local typeConfig = EquipModel.GetEquipTypeById(EquipModel.QualityID2TypeID(v.Id))
            item:Init(typeConfig.icon, config.quality, v.IsPuton, function()
                if v.IsPuton then
                    local data = {
                        content = StringUtil.GetI18n(I18nType.Commmon, "equip_ui_18_1"),
                        sureCallback = function()
                            Net.Equip.PutoffEquip(v.Uuid, function()
                                if self.cb then
                                    self.cb(config.id, v.Uuid)
                                end
                            end)
                        end
                    }
                    UIMgr:Open("ConfirmPopupText", data)
                else
                    if self.cb then
                        self.cb(config.id, v.Uuid)
                    end
                end
            end)
        end
    end
end

function ItemEquipmentDecompositionAdd:FilterIgnore(equips)
    local temp = {}
    for i=#equips,1,-1 do
        if self.ignores[equips[i].Uuid] then 
            table.remove(equips, i)
        end
    end
end

return ItemEquipmentDecompositionAdd
