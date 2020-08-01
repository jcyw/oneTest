--[[
    author:Temmie
    time:2020-06-19
    function:装备材料合成分解
]]
local EquipmentDecompositionSynthesis = _G.UIMgr:NewUI("EquipmentDecompositionSynthesis")
local UIMgr = _G.UIMgr
local UITool = _G.UITool
local EquipModel = _G.EquipModel
local StringUtil = _G.StringUtil
local I18nType = _G.I18nType
local QualityCount = 6 --一共有多少种品质
local synMax = 4 --合成需要数量

function EquipmentDecompositionSynthesis:OnInit()
    self.view = self.Controller.contentPane
    self._typeController = self.view:GetController("typeController")
    self._btnController = self.view:GetController("btnController")
    self._textQuality =  self.view:GetChild("textQuality")

    self:AddListener(self._btnClose.onClick, function()
        UIMgr:Close("EquipmentDecompositionSynthesis")
    end)

    self:AddListener(self._mask.onClick, function()
        UIMgr:Close("EquipmentDecompositionSynthesis")
    end)

    self:AddListener(self._btnSyn.onClick, function()
        self._typeController.selectedIndex = 0
        if self.curQuality == QualityCount then
            self:RefreshTable(self.curQuality - 1)
        else
            self:RefreshTable(self.curQuality)
        end
    end)

    self:AddListener(self._btnDec.onClick, function()
        self._typeController.selectedIndex = 1
        if self.curQuality == 1 then
            self:RefreshTable(self.curQuality + 1)
        else
            self:RefreshTable(self.curQuality)
        end
    end)

    self:AddListener(self._btnSure.onClick, function()
        if self._typeController.selectedIndex == 0 then
            local maxNum = self:GetMaxSynNum()
            if maxNum > 0 then
                self.curNum = 1
                local data = {
                    max = maxNum,
                    content = StringUtil.GetI18n(I18nType.Commmon, "equip_dialog_1", {quality = self.curQuality + 1, mat_name = StringUtil.GetI18n(I18nType.Equip, self.config.name)}),
                    initMax = self.curNum,
                    sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES"),
                    slideCallback = function(num)
                        self.curNum = num
                    end,
                    sureCallback = function()
                        local id = self.config.id + self.curQuality
                        Net.Equip.CompoundJewel(id, self.curNum * synMax, function(rsp)
                            -- EquipModel.UpdateJewelBag(rsp.CompoundJewel.ConfId, rsp.CompoundJewel)
                            self:RefreshList()
                            self:RefreshTable(self.curQuality)

                            TipUtil.TipById(20009)
                        end)
                    end
                }
                UIMgr:Open("ConfirmPopupSlide", data)
            end
        else
            local maxNum = self:GetMaxDecNum()
            if maxNum > 0 then
                self.curNum = 1
                local data = {
                    max = maxNum,
                    content = StringUtil.GetI18n(I18nType.Commmon, "equip_dialog_4", {quality = self.curQuality, mat_name = StringUtil.GetI18n(I18nType.Equip, self.config.name)}),
                    initMax = self.curNum,
                    sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES"),
                    slideCallback = function(num)
                        self.curNum = num
                    end,
                    sureCallback = function()
                        local id = self.config.id + self.curQuality
                        Net.Equip.ResolveJewel(id, self.curNum, function(rsp)
                            -- EquipModel.UpdateJewelBag(rsp.GetJewel.ConfId, rsp.GetJewel)
                            self:RefreshList()
                            self:RefreshTable(self.curQuality)

                            Event.Broadcast(EventDefines.RefreshEquipInfo)

                            TipUtil.TipById(50342)
                        end)
                    end
                }
                UIMgr:Open("ConfirmPopupSlide", data)
            end
        end
    end)
end

-- 进入默认为合成，传作为合成材料的id
function EquipmentDecompositionSynthesis:OnOpen(confId)
    local typeConfId = math.modf(confId / 100) * 100
    local quality = confId - typeConfId
    if quality + 1 > QualityCount then
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "equip_tip_4")
        }
        UIMgr:Open("ConfirmPopupText", data)
        UIMgr:Close("EquipmentDecompositionSynthesis")
        return
    end

    self._typeController.selectedIndex = 0
    self.config = EquipModel.GetMaterialById(typeConfId)
    self:RefreshList()
    self:RefreshTable(quality)
end

--刷新材料栏
function EquipmentDecompositionSynthesis:RefreshList()
    self._list:RemoveChildrenToPool()
    for i=1, QualityCount do
        local item = self._list:AddItemFromPool()
        local curConfig = EquipModel.GetQualityMaterialById(self.config.id + i)
        local model = EquipModel.GetMaterialAmountById(curConfig.id)
        local num = 0
        if model then
            num = model.Amount
        end
        item:SetData(self.config.icon,i - 1,num)
        -- item:SetTextScale(1.5)
        -- item:SetTextScale(1.5)
        item:SetClickItem(function()
            if self._typeController.selectedIndex == 0 and i == QualityCount then
                TipUtil.TipById(50327)
            elseif self._typeController.selectedIndex == 1 and i == 1 then
                TipUtil.TipById(50326)
            else
                self:RefreshTable(i)
            end
        end)
    end
end

--刷新合成、分解栏
function EquipmentDecompositionSynthesis:RefreshTable(quality)
    if self.curQuality then
        self._list:GetChildAt(self.curQuality-1):SetGoldenBox(false)
    end
    self._list:GetChildAt(quality-1):SetGoldenBox(true)
    self.curQuality = quality
    self._btnController.selectedIndex = 0
    local tableQuality = self._typeController.selectedIndex == 0 and quality + 1 or quality
    self._textQuality.text =
        ("[color=#%s]%s[/color]"):format(EquipModel.GetColorCodeByQuality(tableQuality),_G.StringUtil.GetI18n("configI18nEquips", self.config.name))
    local tableModel = EquipModel.GetMaterialAmountById(self.config.id + tableQuality)
    self._itemMaterial:SetData(self.config.icon,tableQuality-1,nil)
    if self._typeController.selectedIndex == 1 and (tableModel == nil or tableModel.Amount < 1) then
       self._btnController.selectedIndex = 1 
    end

    if self._typeController.selectedIndex == 0 then
        self:SetSynTableMaterial()
    else
        self:SetDecTableMaterial()
    end
end

--刷新合成界面的下面四个材料
function EquipmentDecompositionSynthesis:SetSynTableMaterial()
    -- local quality = self.curQuality
    local useQuality = self.curQuality
    local model = EquipModel.GetMaterialAmountById(self.config.id + useQuality)
    if model then
        for i=1, synMax do
            local data = {}
            if i > model.Amount then
                --合成材料不够4个
                self["_itemMaterial"..i]:SetData(nil,6,nil)
                self["_itemMaterial"..i]:SetAdd(true)
                self._btnController.selectedIndex = 1
                -- end
            else
                self["_itemMaterial"..i]:SetData(self.config.icon,useQuality-1,nil)
                self["_itemMaterial"..i]:SetAdd(false)
            end
        end
    else
        --没有材料
        for i=1, synMax do
            self["_itemMaterial"..i]:SetData(nil,6,nil)
            self["_itemMaterial"..i]:SetAdd(true)
        end
        -- if self._typeController.selectedIndex == 0 then
        self._btnController.selectedIndex = 1
        -- end
    end
end

--刷新分解界面的下面四个材料
function EquipmentDecompositionSynthesis:SetDecTableMaterial()
    local useQuality = self.curQuality - 1
    for i=1, synMax do
        self["_itemMaterial"..i]:SetData(self.config.icon,useQuality-1,nil)
    end
end

function EquipmentDecompositionSynthesis:GetMaxSynNum()
    local model = EquipModel.GetMaterialAmountById(self.config.id + self.curQuality)
    if model then
        return math.modf(model.Amount / synMax)
    else
        return 0
    end
end

function EquipmentDecompositionSynthesis:GetMaxDecNum()
    local model = EquipModel.GetMaterialAmountById(self.config.id + self.curQuality)
    if model then
        return model.Amount
    else
        return 0
    end
end

return EquipmentDecompositionSynthesis