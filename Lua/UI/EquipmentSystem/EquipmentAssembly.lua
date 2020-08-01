--[[
    function:{装备选择界面}
]]
local GD = _G.GD
local EventDefines = _G.EventDefines
local EquipModel = _G.EquipModel
local Model = _G.Model
local UITool = _G.UITool
local EaseType = _G.EaseType
local MathUtil = _G.MathUtil
local GTween = _G.GTween
local UIMgr = _G.UIMgr
local DynamicRes = _G.DynamicRes
local GoWrapper = _G.GoWrapper
local Quaternion = _G.Quaternion
local Vector3 = _G.Vector3
local Vector2 = _G.Vector2
local GameObject = _G.GameObject
local JumpMap = _G.JumpMap

local EquipmentAssembly = UIMgr:NewUI("EquipmentAssembly")

local noteTitle = {
    [1] = "equip_ui_2_1",
    [2] = "equip_ui_2_2",
    [3] = "equip_ui_2_3",
    [4] = "equip_ui_2_4",
    [5] = "equip_ui_2_5",
    [6] = "equip_ui_2_6",
    [7] = "equip_ui_2_7",
    [8] = "equip_ui_2_8"
}
function EquipmentAssembly:OnInit()
    --获取部件
    local view = self.Controller.contentPane
    self._icon = view:GetChild("icon")
    self._textPropName = view:GetChild("textPropName")
    self._textLevel = view:GetChild("textLevel")
    self._btnRemove = view:GetChild("btnRemove")
    self._list = view:GetChild("liebiao")
    self._btnReturn = view:GetChild("_btnReturn")
    self._ctr = view:GetController("c1")
    self._qualityCtr = view:GetController("quality")
    self._noteTitleText = view:GetChild("noteTitle")
    self._iconLock = view:GetChild("iconLock")
    self._btnEquip = view:GetChild("btnEquip")
    self._effect = view:GetChild("effect")self._banner = view:GetChild("_banner")

    

    --获取属性列表组件
    self.itemAttack = {}
    for i = 1,4 do
        self.itemAttack[i] = view:GetChild("itemAttack"..i)
    end

    --当前穿戴装备Uuid
    self.putonEquipUuid = nil
    --当前穿戴装备qualityID
    self.putonEquipqualityID= nil
    --当前穿戴装备材质
    self.putonEquipquality= nil
    --列表数据
    self._listInfos = {}

    --当前展示的卡槽id
    self._partID = 0
    --是否正在进行穿戴动画
    self.isAnim = false

    -- 换装动画中的装备信息
    self.animequipInfo = nil

    --移动动画的TweenMove
    self.moveEquipPart = nil
    self.moveCenter = nil

    --列表render
    self._list:SetVirtual()
    self._list.itemRenderer = function(index, item)
        item:SetData(self._listInfos[index + 1],self._list)
        item.itemInfo =  self._listInfos[index + 1]
        item:SetListener(item._btnEquipment.onClick,
        function()
            local itemInfo = item.itemInfo
            --选择查看
            if itemInfo.ctr == 0 then
                self.Check(self._partID)
            --点击装备
            else
                if self.isAnim then
                    return
                end
                local _pos = item._icon:LocalToGlobal(Vector2.zero)
                -- _pos.x = _pos.x * GlobalVars.ScreenStandard.width/Screen.width
                -- _pos.y = _pos.y * GlobalVars.ScreenStandard.height/Screen.height - self._list.y * (1-GlobalVars.ScreenStandard.height/Screen.height)
                _pos.x, _pos.y = MathUtil.ScreenRatio(_pos.x, _pos.y)
                self.animequipInfo = {
                    Uuid = itemInfo.Uuid,
                    IsPuton = itemInfo.IsPuton,
                    quality = itemInfo.quality,
                    icon = itemInfo.icon,
                    pos =  _pos
                }
                self:EquipOrRemoveCb()
            end
        end
    )
    end

    --事件
    self:AddListener(self._btnReturn.onClick,
        function()
            if self.moveEquipPart then
                GTween.Kill(self.moveEquipPart)
            end
            if self.moveCenter then
                GTween.Kill(self.moveCenter)
            end
            UIMgr:Open("PlayerDetails")
            UIMgr:Close("EquipmentAssembly")
        end
    )
    self:AddListener(self._btnRemove.onClick,
        function()
            local callback = function ()
                self.putonEquipUuid = nil
            end
            self:PutOffEuip(callback)
        end
    )
    self:AddEvent(
        EventDefines.RefreshEquipInfo,
        function()
            self:RefreshEquipList()
        end
    )
    self:AddListener(self._btnEquip.onClick,
        function ()
            self:EquipBtnClick()
        end
    )

    --控制器默认0
    self._ctr.selectedIndex = 0

    -- 加载_banner
    self._banner.icon = _G.UITool.GetIcon({"IconEquip","equipment_banner_02"})
end

--partID  equipID当前穿戴ID
function EquipmentAssembly:OnOpen(_partID)
    self._partID = _partID
    self._noteTitleText.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon,noteTitle[_partID] )
    self:RefreshEquipList()
end
--刷新列表
function EquipmentAssembly:RefreshEquipList()
    local equips = EquipModel.GetEquipBag()
    local partEquips = {}
    for _,v in pairs(equips) do
        local equipType = EquipModel.GetEquipTypeByEquipQualityID(v.Id)
        local equipQuality = EquipModel.GetEquipQualityById(v.Id)
        if equipType and equipQuality then
            if equipType.equip_part == self._partID and Model.Player.HeroLevel>= equipType.equip_level then
                table.insert(partEquips,{
                    Id = v.Id,
                    IsPuton = v.IsPuton,
                    name = equipType.name,
                    equip_level = equipType.equip_level,
                    quality = equipQuality.quality,
                    icon = equipType.icon,
                    buff_values = equipQuality.buff_values,
                    att_name  = equipQuality.att_name,
                    Uuid = v.Uuid,
                    IsLock = v.IsLock,
                    ctr = 1
                })
            end
        end
    end
    self._listInfos = nil
    self._listInfos = {}
    self:RefreshPutonEquip(nil)
    for _,v in ipairs(partEquips) do
        --如果穿戴了设备
        if v.IsPuton then
            self.putonEquipUuid = v.Uuid
            self.putonEquipqualityID = v.Id
            if v.Id then
                self._iconLock.visible = v.IsLock
                self:RefreshPutonEquip(v.Id)
            end
        --如果没穿戴设备
        else
            table.insert(self._listInfos,v)
        end
    end
    table.sort(
        self._listInfos,
        function(a, b)
            return a.equip_level == b.equip_level and a.quality > b.quality or a.equip_level > b.equip_level
        end
    )
    --最后一个，给用户点击查看跳转
    table.insert(self._listInfos,{ctr = 0 ,quality = 0})
    self._list.numItems = #self._listInfos
    self._list.scrollPane:ScrollTop()

end
--刷新穿戴装备
function EquipmentAssembly:RefreshPutonEquip(Id)
    if Id == nil then
        self._ctr.selectedIndex = 0
        self._qualityCtr.selectedIndex = 0
        self._icon.icon = nil
        return
    end
    local equipType =  EquipModel.GetEquipTypeByEquipQualityID(Id)
    local equipQuality =  EquipModel.GetEquipQualityById(Id)
    local image  = equipType.icon
    self._qualityCtr.selectedIndex = equipQuality.quality
    self.putonEquipquality = equipQuality.quality
    self._ctr.selectedIndex = 1
    self._textPropName.text = _G.StringUtil.GetI18n("configI18nEquips", equipType.name)
    self._textLevel.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_Level", {number = equipType.equip_level})
    self._icon.icon = _G.UITool.GetIcon(image, self._icon)
    for i = 1,#self.itemAttack do
        if equipQuality.att_name and equipQuality.att_name[i] then
            local buffvalue = ("+ %.2f"):format(equipQuality.buff_values[i]/100).."%"
            local name = equipQuality.att_name[i]
            self.itemAttack[i].visible = true
            self.itemAttack[i]:SetData(name,buffvalue,0)
        else
            self.itemAttack[i].visible = false
        end
    end
end
--戴上或者卸下装备
function EquipmentAssembly:EquipOrRemoveCb()
    local equipInfo = self.animequipInfo
    if not equipInfo then
        return
    end
    local item = UIMgr:CreateObject("EquipmentSystem", "ItemIcon")
    item.visible = true
    item:GetChild("iconbg").icon = GD.ItemAgent.GetItmeQualityByColor(equipInfo.quality - 1)
    item:GetChild("icon").icon = UITool.GetIcon(equipInfo.icon)
    self.Controller.contentPane:AddChild(item)
    item.sortingOrder = 1000
    local startPos = equipInfo.pos
    -- startPos.y = startPos.y * GlobalVars.ScreenStandard.height/Screen.height
    item.xy = startPos
    self.moveEquipPart = function()
        local partPos = self._icon.xy
        local secendTime = 0.5
        self:GtweenOnComplete(item:TweenMove(partPos, secendTime):SetEase(EaseType.CubicOut),
            function()
                self.isAnim = false
                item:Dispose()
                self.RequestEquipOrRemove(equipInfo)
                self:PlayEquipEffect()
                self.animequipInfo = nil
            end
        )
    end
    self.moveCenter = function()
        local centertPos = _G.Vector2(375-item.width*0.5,667-item.height*0.5)
        local firstTime = 0.5
        self.isAnim = true
        self:GtweenOnComplete(item:TweenMove(centertPos, firstTime):SetEase(EaseType.CubicOut),
            function()
                self.moveEquipPart()
            end
        )
    end
    self.moveCenter()
end
function EquipmentAssembly:PlayEquipEffect()
    if not GlobalVars.IsShowEffect() then
        --低端机不显示
        return
    end
    if not self.effectNode then
        self.effectNode = UIMgr:CreateObject("Effect", "EmptyNode")
        self.effectNode.xy = Vector2.zero
        self._effect:AddChild(self.effectNode)
    end
    --动态资源加载
    DynamicRes.GetBundle("effect_collect", function()
        DynamicRes.GetPrefab("effect_collect", "Effect_equipment", function(prefab)
            if not self.effectObj then
                self.effectObj =  GameObject.Instantiate(prefab)
                self.effectNode:GetGGraph():SetNativeObject( GoWrapper(self.effectObj))
                self.effectObj.transform.localRotation = Quaternion(0, 0, 0,0)
                self.effectObj.transform.localScale = Vector3.one*100
            end
            if self.effectObj then
                self.effectObj:SetActive(true)
            end
            self:ScheduleOnce(
                function()
                    if self.effectObj then
                        self.effectObj:SetActive(false)
                    end
                end
            , 1)
        end)
    end)
end
function EquipmentAssembly.RequestEquipOrRemove(equipInfo)
    if equipInfo.IsPuton and equipInfo.Uuid then
        _G.Net.Equip.PutoffEquip(
            equipInfo.Uuid,
            function()
                equipInfo = nil
            end
        )
    elseif equipInfo.Uuid then
        _G.Net.Equip.PutonEquip(
            equipInfo.Uuid,
            function()
                equipInfo = nil
            end
        )
    end
end
-- 卸下装备
function EquipmentAssembly:PutOffEuip(callback)
    if self.putonEquipUuid then
        _G.Net.Equip.PutoffEquip(
            self.putonEquipUuid,
            function()
                callback()
            end
        )
    end
end
--点击查看跳转到装备选择界面
function EquipmentAssembly.Check(partID)
    if EquipModel.IsEquipFactoryUpgrade() then
        local data = {
            content = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "equip_ui_11_1")
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
                UIMgr:Close("EquipmentAssembly")
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
        return
    end
    UIMgr:Open("EquipmentSelect",partID)
    UIMgr:Close("EquipmentAssembly")
end
function EquipmentAssembly:EquipBtnClick()
    if self.putonEquipquality >= EquipModel.EquipQuality.EquipQuialityMax then
        local data = {
            content = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "equip_tip_4")
        }
        UIMgr:Open("ConfirmPopupText", data)
        return
    end
    if self.isAnim then
        return
    end
    local CallDecomposition = function ()
        UIMgr:Open("EquipmentDecomposition", self.putonEquipUuid)
    end
    self:PutOffEuip(CallDecomposition)
end
function EquipmentAssembly:OnClose()
    self._listInfos = {}
    if self.effectNode then
        self.effectNode:Dispose()
        self.effectNode = nil
    end
    if self.effectObj then
        GameObject.Destroy(self.effectObj)
        self.effectObj = nil
    end
end
return EquipmentAssembly