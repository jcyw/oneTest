--[[
    author:zuoyou
    time:2020-06-15
    function:装备选择界面
]]
local EquipModel = _G.EquipModel
local EventDefines = _G.EventDefines
local UIMgr = _G.UIMgr
local EquipmentSelect = UIMgr:NewUI("EquipmentSelect")
function EquipmentSelect:OnInit()
    local view = self.Controller.contentPane
    --获取部件
    self._btnSwitch = view:GetChild("btnSwitch")
    self._btnReturn = view:GetChild("btnReturn")
    self._list = view:GetChild("liebiao")
    self._btnSwitch = view:GetChild("btnSwitch")
    self._ctr = view:GetController("c1")

    --列表数据
    self._listInfos = nil

    --当前展示的卡槽id
    self._partID = 0

    --当前显示装备的品质
    self._quality = 6

    --获取装备选择列表组件
    self.btnTag = {}
    for i = 1,6 do
        self.btnTag[i] = view:GetChild("btnTag"..i)
    end

    --列表render
    self._list:SetVirtual()
    self._list.itemRenderer = function(index, item)
        item:SetData(self._listInfos[index + 1])
    end

    --事件
    self:AddListener(self._btnReturn.onClick,
        function()
            if self.triggerFunc then
                self.triggerFunc()
            end
            UIMgr:Close("EquipmentSelect")
        end
    )
    self:AddListener(self._btnSwitch.onClick,
        function()
            UIMgr:Open("EquipmentGemVault")
            UIMgr:Close("EquipmentSelect")
        end
    )
    self:AddEvent(
        EventDefines.RefreshEquipEvent,
        function()
            if self.isViewWnd then
                self:RefreshList()
            end
        end
    )
    self:AddEvent(
        EventDefines.EquipEventFinish,
        function()
            if self.isViewWnd then
                self:RefreshList()
            end
        end
    )
    for i = 1,6 do
        self:AddListener(
            self.btnTag[i].onClick,
            function()
                self:SwitchPart(i)
            end
        )
    end
end
function EquipmentSelect:OnOpen(partID,quality)
    self._btnSwitch.selected = true
    self.isViewWnd = true
    -- 默认品质6
    self._quality = quality and quality or 6
    self._ctr.selectedIndex = partID
    self._partID = partID
    self:RefreshList()
end
--刷新装备列表
function EquipmentSelect:RefreshList()
    local equips = EquipModel.GetEquipTypes()
    self._listInfos = nil
    self._listInfos = {}
    EquipmentSelect.JudgeAndTakeEquip()
    for _,v in pairs(equips) do
        local equipType = v
        local equipID = v.id+self._quality
        local equipQuality = EquipModel.GetEquipQualityById(equipID)
        if equipQuality then
            if equipType.equip_part == self._partID and _G.Model.Player.HeroLevel >= equipType.min_visible_commander_level then
                local _duration = 0
                local _FinishAt
                local _isObtaining = false
                local _Uuid = nil
                local EquipEvent = EquipModel.IsAlikeIDTransaction(equipID)
                if EquipEvent then
                    if not EquipModel.IsEquipEventEnd() then
                        _duration = EquipEvent.Duration
                        _FinishAt = EquipEvent.FinishAt
                        _Uuid = EquipEvent.Uuid
                        _isObtaining = true
                    end
                end
                table.insert(self._listInfos,{
                    callbackData = equipID,
                    Uuid = _Uuid,
                    callback = self.SeeWeapon,
                    quality = equipQuality.quality,
                    icon = equipType.icon,
                    name = equipType.name,
                    level = equipType.equip_level,
                    buff = {att_name = equipQuality.att_name,buff_values = equipQuality.buff_values},
                    obtainAble = EquipModel.IsMaterialAdequate(equipType.pre_equip_serial_ids,equipType.need_material_Serial_ids),
                    isObtaining = _isObtaining,
                    Duration = _duration,
                    FinishAt = _FinishAt
                })
                table.sort(
                    self._listInfos,
                    function(a, b)
                        return a.level > b.level
                    end
                )
            end
        else
            Log.Error("=======================》》》》》装备属性表缺少配置",v.id)
        end
    end
    self._list.numItems = #self._listInfos
    self._list.scrollPane:ScrollTop()
end
function EquipmentSelect.SeeWeapon(qualityID,isLowMaterial)
    UIMgr:Open("EquipmentTransaction",qualityID,isLowMaterial)
end
function EquipmentSelect:SwitchPart(partID)
    self._partID = partID
    self:RefreshList()
end
function EquipmentSelect.JudgeAndTakeEquip()
    local EquipEvent = EquipModel.GetEquipEvents()
    if not EquipEvent then
        return
    end
    if EquipEvent.FinishAt - Tool.Time() > 0 then
       return
    end
    EquipModel.Taketequip(EquipEvent.Uuid,nil,function ()
        UIMgr:Close("EquipmentSelect")
        UIMgr:Close("EquipmentTransaction")
    end)
end
--获得可制造的列表序号
function EquipmentSelect:GetCanMakeIndex()
    for key, value in pairs(self._listInfos) do
        if value.obtainAble==true then
            self._list:ScrollToView(key-1)
            return key-1
        end
    end
end
function EquipmentSelect:TriggerOnclick(callback)
    self.triggerFunc = callback
end
function EquipmentSelect:OnClose()
    self.isViewWnd = false
end
return EquipmentSelect