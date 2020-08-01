--[[
    function:{保险库}
]]
local EquipModel = _G.EquipModel
local EquipmentGemVault = _G.UIMgr:NewUI("EquipmentGemVault")
local UIMgr = _G.UIMgr
local EventDefines = _G.EventDefines
local JumpMap =_G.JumpMap

function EquipmentGemVault:OnInit()
    --获取部件
    local view = self.Controller.contentPane
    self._btnReturn = view:GetChild("btnReturn")
    self._btnInventory = view:GetChild("btnInventory")
    self._btnStore = view:GetChild("btnStore")
    self._btnSwitch = view:GetChild("btnSwitch")
    self._list = view:GetChild("liebiao")
    self._ctr = view:GetController("c1")
    self._btnHelp = view:GetChild("btnHelp")
    self._banner = view:GetChild("_banner")


    --列表数据
    self._listInfos = {}
    --当前的所在分页，0表示宝石，1表示装备
    self._curStoreTag = 0
    --事件
    self:AddListener(self._btnReturn.onClick,
        function()
            self.Close()
        end
    )
    self:AddListener(self._btnInventory.onClick,
        function()
            self:RefreshData(0,true)
        end
    )
    self:AddListener(self._btnStore.onClick,
        function()
            self:RefreshData(1,true)
        end
    )
    self:AddListener(self._btnHelp.onClick,
        function()
            Sdk.AiHelpShowSingleFAQ(ConfigMgr.GetItem("configWindowhelps", 2096).article_id)
        end
    )
    self:AddListener(self._btnSwitch.onClick,
        function()
            local isBuildUp = EquipModel.IsEquipFactoryUpgrade()
            if isBuildUp then
                local data = {
                    content = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_ui_11_1")
                }
                UIMgr:Open("ConfirmPopupText", data)
                return
            end
            if not EquipModel.GetEquipFactory() then
                local data = {
                    content = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "equip_tip_10"),
                    sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO"),
                    sureCallback = function()
                        JumpMap:JumpTo({jump = 810000, para = 444000})
                        UIMgr:Close("EquipmentGemVault")
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
                return
            end
            _G.UIMgr:Open("EquipmentSelect",1)
            _G.UIMgr:Close("EquipmentGemVault")
        end
    )
    self:AddEvent(
        EventDefines.RefreshEquipInfo,
        function()
            self:RefreshData(self._curStoreTag,false)
        end
    )
    --列表render
    self._list:SetVirtual()
    self._list.itemRenderer = function(index, item)
        local info = self._listInfos[index + 1]
        if self._curStoreTag == 0 then
            item:SetData(info.icon,info.quality,info.num)
            item:SetUpgrade(info.isCanUp)
            item:SetLock1(false)
        else
            item:SetData(info.icon,info.quality,info.num)
            item:SetPick(info.isPuton)
            item:SetLock1(info.isLock)
        end
        item:SetIdData(info.cbData)
    end
    self:AddListener(self._list.onClickItem,function(context)
        local item = context.data
        self.OnItemClick(item:GetIdData())
    end)

    -- 加载_banner
    self._banner.icon = _G.UITool.GetIcon({"IconEquip","equipment_banner_01"})
end
function EquipmentGemVault:OnOpen()
    self._btnSwitch.selected = false
    self:RefreshData(0,true)
end

function EquipmentGemVault:RefreshJewel()
    local Jewels = EquipModel.GetJewelBag()
    for _,v in pairs(Jewels) do
        if v.Amount > 0 then
            local materialQuality = EquipModel.GetQualityMaterialById(v.ConfId)
            local materialType = EquipModel.GetMaterialByQualityId(v.ConfId)
            local isCanUp = false
            if v.Amount >= 4 and materialQuality.quality < EquipModel.EquipQuality.EquipQuialityMax then
                isCanUp = true
            end
            if materialQuality and materialType then
                table.insert(self._listInfos,{
                    cbData = {StoreTag = self._curStoreTag,id = v.ConfId},
                    quality = materialQuality.quality-1,
                    icon = materialType.icon,
                    isCanUp = isCanUp,
                    num = ("x%d"):format(v.Amount),
                    matType = materialQuality.type
                })
            end
        end
    end
    if #self._listInfos > 2 then
        table.sort(self._listInfos,
            function(a, b)
                return a.matType == b.matType and a.quality > b.quality or a.matType > b.matType
            end
        )
    end

end
function EquipmentGemVault:RefreshEquip()
    local equip = EquipModel.GetEquipBag()
    for _,v in pairs(equip) do
        local equipType = EquipModel.GetEquipTypeByEquipQualityID(v.Id)
        local equipQuality = EquipModel.GetEquipQualityById(v.Id)

        if equipType and equipQuality then
            table.insert(self._listInfos,{
                cbData = {StoreTag = self._curStoreTag,id = v.Id,uuid = v.Uuid},
                quality = equipQuality.quality-1,
                icon = equipType.icon,
                isPuton = v.IsPuton,
                isLock = v.IsLock,
                equip_level = equipType.equip_level,
                num = ("Lv.%d"):format(equipType.equip_level)
            })
            end
        end
        table.sort(self._listInfos,
        function(a, b)
            return a.equip_level == b.equip_level and a.quality > b.quality or a.equip_level > b.equip_level
        end
        )
end

--刷新列表信息，curStoreTag：当前分页，isScrollTop是否滑动到顶部
function EquipmentGemVault:RefreshData(curStoreTag,isScrollTop)
    self._curStoreTag = curStoreTag
    self._ctr.selectedIndex = self._curStoreTag
    self._listInfos = nil
    self._listInfos = {}
    if self._curStoreTag == 0 then
        self:RefreshJewel()
    else
        self:RefreshEquip()
    end
    self._list.numItems = #self._listInfos
    if isScrollTop then
        self._list.scrollPane:ScrollTop()
    end
end
--列表栏物品点击
function EquipmentGemVault.OnItemClick(cbData)
    if cbData.StoreTag == 0 then
        --装备材料
        UIMgr:Open("EquipmentDecompositionSynthesis", cbData.id)
    else
        -- 装备
        UIMgr:Open("EquipDetail", cbData.uuid)
    end
end
function EquipmentGemVault.Close()
    _G.UIMgr:Close("EquipmentGemVault")
end

return EquipmentGemVault