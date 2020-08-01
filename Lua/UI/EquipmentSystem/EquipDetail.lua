--[[
    author:Temmie
    time:2020-06-20
    function:装备详情界面
]]
local EquipDetail = _G.UIMgr:NewUI("EquipDetail")
local UIMgr = _G.UIMgr
local EquipModel = _G.EquipModel
local StringUtil = _G.StringUtil
local I18nType = _G.I18nType

function EquipDetail:OnInit()
    self.view = self.Controller.contentPane
    self._wearController = self.view:GetController("wearController")
    self._lockController = self.view:GetController("lockController")
    self._typeController = self.view:GetController("typeController")

    self:AddListener(self._mask.onClick, function()
        UIMgr:Close("EquipDetail")
    end)

    self:AddListener(self._btnClose.onClick, function()
        UIMgr:Close("EquipDetail")
    end)

    self:AddListener(self._btnSure.onClick, function()
        UIMgr:Close("EquipDetail")
    end)

    self:AddListener(self._btnLock.onClick, function()
        self._btnLock.enabled = false
        if self.model.IsLock then
            Net.Equip.UnlockEquip(self.model.Uuid, function(rsp)
                self._btnLock.enabled = true
                self.model.IsLock = false
                self._lockController.selectedIndex = 0 
                self._itemMaterial:SetStyle(0)
                TipUtil.TipById(50328)
            end)
        else
            Net.Equip.LockEquip(self.model.Uuid, function(rsp)
                self._btnLock.enabled = true
                self.model.IsLock = true
                self._lockController.selectedIndex = 1
                self._itemMaterial:SetStyle(6)
                TipUtil.TipById(50329)
            end)
        end
    end)

    self:AddListener(self._btnSyn.onClick, function()
        if self.model.IsPuton then
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "equip_ui_18_1"),
                sureCallback = function()

                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        else
            if self.config.higher_quality_equip_id then
                UIMgr:Open("EquipmentDecomposition", self.model.Uuid, function()
                    UIMgr:Close("EquipDetail")
                end)
            else
                TipUtil.TipById(50327)
            end
        end
    end)

    self:AddListener(self._btnEquip.onClick, function()
        self._btnEquip.enabled = false

        -- 收取装备穿戴提示
        if self._typeController.selectedIndex == 1 then
            UIMgr:Close("EquipDetail")
            UIMgr:Open("EquipmentAssembly", self.typeConfig.equip_part)       
            if self.Callback then     
                self.Callback()
            end
            return
        end

        if self.model.IsPuton then
            Net.Equip.PutoffEquip(self.model.Uuid, function()
                self._btnEquip.enabled = true
                self.model.IsPuton = false
                self._wearController.selectedIndex = 0

                local color = StringUtil.GetI18n(I18nType.Commmon, "quality_color_"..(self.config.quality - 1))
                local name = StringUtil.GetI18n(I18nType.Equip, self.typeConfig.name)
                TipUtil.TipById(50340, {color = color, equip_name = name})
                self._btnEquip.text = self.SetPutonBtnTxt(self.model.IsPuton)
            end)
        else
            if Model.Player.HeroLevel < self.typeConfig.equip_level then
                TipUtil.TipById(50343, {level = self.typeConfig.equip_level})
                self._btnEquip.enabled = true
                return
            end

            Net.Equip.PutonEquip(self.model.Uuid, function()
                self._btnEquip.enabled = true
                self.model.IsPuton = true
                self._wearController.selectedIndex = 1

                local color = StringUtil.GetI18n(I18nType.Commmon, "quality_color_"..(self.config.quality - 1))
                local name = StringUtil.GetI18n(I18nType.Equip, self.typeConfig.name)
                TipUtil.TipById(50341, {color = color, equip_name = name})

                if self.isTip then
                    UIMgr:Close("EquipDetail")
                end
                self._btnEquip.text = self.SetPutonBtnTxt(self.model.IsPuton)
            end)
        end
    end)

    self:AddListener(self._btnDec.onClick, function()
        if self.model.IsLock then
            TipUtil.TipById(50330)
        else
            UIMgr:Open("EquipDetailPopup", self.model.Uuid, function()
                UIMgr:Close("EquipDetail")
            end)
        end
    end)
end

function EquipDetail:OnOpen(uuid, isTip,Callback)
    self.model = EquipModel.GetEquipModelByUuid(uuid)
    self.config = EquipModel.GetEquipQualityById(self.model.Id)
    self.typeConfig = EquipModel.GetEquipTypeById(math.modf(self.model.Id / 100) * 100)
    self._btnEquip.text = isTip and StringUtil.GetI18n(I18nType.Commmon, "UI_REPLACE_BUTTON") or self.SetPutonBtnTxt(self.model.IsPuton)
    self._typeController.selectedIndex = isTip and 1 or 0
    self.isTip = isTip
    self.Callback = Callback

    if isTip and Model.Player.HeroLevel < self.typeConfig.equip_level then
        self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "equip_dialog_10", {level = self.typeConfig.equip_level})
        self._typeController.selectedIndex = 2
    end

    self._btnEquip.enabled = true
    self._btnLock.enabled = true

    self._textName.text = ("[color=#%s]%s[/color]"):format(EquipModel.GetColorCodeByQuality(self.config.quality), StringUtil.GetI18n(I18nType.Equip, self.typeConfig.name))
    self._lockController.selectedIndex = self.model.IsLock and 1 or 0
    self._wearController.selectedIndex = self.model.IsPuton and 1 or 0

    local data = {
        icon = self.typeConfig.icon,
        quality = self.config.quality,
        ctr = self.model.IsLock and 6 or 0
    }
    self._itemMaterial:SetData(data)

    self._list:RemoveChildrenToPool()
    for k,v in pairs(self.config.att_name) do
        local item = self._list:AddItemFromPool()
        item:GetChild("textAttact1").text = StringUtil.GetI18n(I18nType.Equip, v)
        item:GetChild("textAttactNum1").text = ("+ %.2f"):format(self.config.buff_values[k]/100).."%"
    end
end
-- 设置中间按钮线显示穿戴或者卸下 isPuton是当前状态
function EquipDetail.SetPutonBtnTxt(isPuton)
    return isPuton and StringUtil.GetI18n(I18nType.Commmon, "UNDRESS_BUTTON")  or StringUtil.GetI18n(I18nType.Commmon, "DRESS_UP_BUTTON")
end

return EquipDetail