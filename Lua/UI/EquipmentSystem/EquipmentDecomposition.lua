--[[
    author:Temmie
    time:2020-06-20
    function:装备合成界面
]]
local EquipmentDecomposition = _G.UIMgr:NewUI("EquipmentDecomposition")
local UIMgr = _G.UIMgr
local EquipModel = _G.EquipModel

function EquipmentDecomposition:OnInit()
    self.view = self.Controller.contentPane
    self._tipController = self.view:GetController("tipController")

    self:AddListener(self._btnClose.onClick, function()
        UIMgr:Close("EquipmentDecomposition")
    end)

    self:AddListener(self._mask.onClick, function()
        UIMgr:Close("EquipmentDecomposition")
    end)

    self:AddListener(self._addMask.onClick, function()
        self._tipController.selectedIndex = 1
    end)

    self:AddListener(self._btnSyn.onClick, function()
        local func = function()
            self._btnSyn.enabled = false
            local temp = {}
            for _,v in pairs(self.selected) do
                if v then
                    table.insert(temp, v)
                end
            end
            Net.Equip.CompoundEquip(temp, self.config.id, function(rsp)
                self._btnSyn.enabled = true
                Event.Broadcast(EventDefines.RefreshEquipInfo)
                TipUtil.TipById(20009)

                if self.sureCB then
                    self.sureCB()
                end

                UIMgr:Close("EquipmentDecomposition")
            end)
        end

        local color = StringUtil.GetI18n(I18nType.Commmon, "quality_color_"..(self.upConfig.quality - 1))
        local name = StringUtil.GetI18n(I18nType.Equip, self.upTypeConfig.name)
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "equip_dialog_8", {color = color, equip_name = name}),
            sureCallback = func
        }
        UIMgr:Open("ConfirmPopupText", data)
    end)
end

function EquipmentDecomposition:OnOpen(uuid, sureCallback)
    self.sureCB = sureCallback
    self.model = EquipModel.GetEquipModelByUuid(uuid)
    self.config = EquipModel.GetEquipQualityById(self.model.Id)
    self.typeConfig = EquipModel.GetEquipTypeById(EquipModel.QualityID2TypeID(self.model.Id))
    self.upConfig = EquipModel.GetEquipQualityById(self.config.higher_quality_equip_id)
    self.upTypeConfig = EquipModel.GetEquipTypeById(EquipModel.QualityID2TypeID(self.upConfig.id))
    self.materials = EquipModel.GetEquipsByQulityLevel(self.config.quality, self.typeConfig.equip_level)
    self.selected = {}

    self._tipController.selectedIndex = 1
    self._textLevel.text =
        ("[color=#%s]%s[/color]"):format(EquipModel.GetColorCodeByQuality(self.upConfig.quality),StringUtil.GetI18n(I18nType.Equip, self.upTypeConfig.name))


    self._btnSyn.enabled = #self.materials >= 4 and true or false

    local data = {
        quality = self.upConfig.quality,
        icon = self.upTypeConfig.icon
    }
    self._itemGet:SetData(data)

    local list = self:GetEquipDetail(self.upConfig)
    local tipData = {
        title = StringUtil.GetI18n(I18nType.Equip, self.upTypeConfig.name),
        datas = list
    }
    self._itemGet:SetTipData(tipData)

    local data = {
        quality = self.config.quality,
        icon = self.typeConfig.icon
    }
    self._itemMain:SetData(data)
    -- table.insert(self.selected, uuid)
    self.selected[uuid] = uuid

    local list = self:GetEquipDetail(self.config)
    local tipMainData = {
        title = StringUtil.GetI18n(I18nType.Equip, self.typeConfig.name),
        datas = list
    }
    self._itemMain:SetTipData(tipMainData)

    --默认放上相同品质和等级的装备作为材料
    local index = 0
    for k,v in pairs(self.materials) do
        local model = v--self.materials[i]
        if index < 3 and model.Uuid ~= uuid and not model.IsPuton then
            index = index + 1
            local curIndex = index
            local config = EquipModel.GetEquipQualityById(model.Id)
            local typeConfig = EquipModel.GetEquipTypeById(EquipModel.QualityID2TypeID(model.Id))
            local data = {
                quality = config.quality,
                icon = typeConfig.icon,
                cb = function()
                    self._tipController.selectedIndex = 0
                    self._itemAdd:Init(self.config.quality, self.typeConfig.equip_level, curIndex, self.selected, function(id, uuid)
                        --换上新材料
                        self._tipController.selectedIndex = 1
                        local config = EquipModel.GetEquipQualityById(id)
                        local typeConfig = EquipModel.GetEquipTypeById(EquipModel.QualityID2TypeID(id))
                        self["_item"..curIndex]:RefeshIcon(typeConfig.icon)
                        self["_item"..curIndex]:RefreshQuality(config.quality)
                        -- table.remove(self.selected, model.Uuid)
                        self.selected[model.Uuid] = nil
                        -- table.insert(self.selected, uuid)
                        self.selected[uuid] = uuid
                    end)
                end
            }
            self["_item"..index]:SetData(data)
            -- table.insert(self.selected, model.Uuid)
            self.selected[model.Uuid] = model.Uuid
        elseif index >= 3 then
            break;
        end   
    end

    --如果没放满材料
    local num = 3-index
    for i=1, num do
        index = index + 1
        local curIndex = index
        local data = {
            cb = function()
                self._tipController.selectedIndex = 0
                self._itemAdd:Init(self.config.quality, self.typeConfig.equip_level, curIndex, self.selected, function(id, uuid)
                    --换上新材料
                    self._tipController.selectedIndex = 1
                    local config = EquipModel.GetEquipQualityById(id)
                    local typeConfig = EquipModel.GetEquipTypeById(EquipModel.QualityID2TypeID(id))
                    self["_item"..curIndex]:RefeshIcon(typeConfig.icon)
                    self["_item"..curIndex]:RefreshQuality(config.quality)
                    -- table.insert(self.selected, uuid)
                    self.selected[uuid] = uuid
                end)
            end
        }
        self["_item"..index]:SetData(data)
    end
end

function EquipmentDecomposition:RefreshSelected(uuid)
    for _,v in pairs(self.selected) do
        
    end
end

function EquipmentDecomposition:GetEquipDetail(config)
    local list = {}
    for k,v in pairs(config.att_name) do
        -- detail = ("%s\n%s      %.2f%%"):format(detail, StringUtil.GetI18n(I18nType.Equip, v), config.buff_values[k]/100)
        local detailL = StringUtil.GetI18n(I18nType.Equip, v)
        local detailR = ("%.2f%%"):format(config.buff_values[k]/100)
        table.insert(list, {contentL = detailL, contentR = detailR})
    end
    return list
end

return EquipmentDecomposition