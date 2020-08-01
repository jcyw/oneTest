local GD = _G.GD
local EquipModel = _G.EquipModel
local UITool = _G.UITool
local Tool = _G.Tool
local Model = _G.Model
local UIMgr = _G.UIMgr
local  EventDefines = _G.EventDefines
local StringUtil = _G.StringUtil
local BuildModel = _G.BuildModel
local Global = _G.Global
local TipUtil = _G.TipUtil
local JumpMap = _G.JumpMap
local CHIP_COST = _G.ConfigMgr.GetVar("Res4Equip")
local SpecialBuildModel = import("Model/SpecialBuildModel")
local JumpMapModel = import("Model/JumpMapModel")
local StatusEnum = {
    ontransaction = 1,--交易中
    readytransaction = 2,--可以交易
    lackMaterials = 3,--材料没选完
    finishTransaction = 4 --交易结束等待领取
}

local EquipmentTransaction =  _G.UIMgr:NewUI("EquipmentTransaction")
function EquipmentTransaction:OnInit()
    --获取部件
    local view = self.Controller.contentPane
    self._icon = view:GetChild("icon")
    self._equipName = view:GetChild("equipName")
    self._listattribute = view:GetChild("liebiaoProbability")
    self._listMaterial = view:GetChild("liebiaoMaterial")
    self._targetquality =  view:GetController("targetquality")
    self._bgTop=view:GetChild("bgBoxDownTag")
    self._bgDown=view:GetChild("bgDown")
    self._groupEquip = view:GetChild("groupEquip")
    self._Maskcancel = view:GetChild("Maskcancel")
    self._iconRes = view:GetChild("iconRes")
    self._iconTime = view:GetChild("iconTime")
    self._textResNum = view:GetChild("textResNum")
    self._textTime = view:GetChild("textTime")
    self._btnL = view:GetChild("_btnL")
    self._btnReturn = view:GetChild("btnReturn")
    self._btnSwitch = view:GetChild("btnSwitch")
    self._textNoWeapon = view:GetChild("textNoWeapon")
    self._btnR = view:GetChild("_btnR")
    self._noteTitleText = view:GetChild("noteTitle")
    self._noteTitleBg = view:GetChild("noteTitleBg")
    self._btnAdd = view:GetChild("_btnAdd")
    self._textNeed = view:GetChild("textNeed")
    self._boxArrowMaterial = view:GetChild("boxArrowMaterial")
    self._boxArrowProbability = view:GetChild("boxArrowProbability")
    self._textMaterial = view:GetChild("textMaterial")
    self._btnHelp = view:GetChild("btnHelp")
    self._TransTime = view:GetChild("TransTime")
    self._transationPro = view:GetChild("transationPro")
    self._textProbability = view:GetChild("textProbability")
    local uibg = self._bg:GetChild("_icon")
    UITool.GetIcon({"falcon", "equipment_bg_01"},uibg)
    self._itemMaterial = {}
    for i = 1, 5 do
        self._itemMaterial[i] = view:GetChild("itemMaterial"..i)
    end
    self._btnProbability = {}
    for i = 1, 6 do
        self._btnProbability[i] = view:GetChild("btnProbability"..i)
    end
    --列表render
    self._listMaterial:SetVirtual()
    self._listMaterial.itemRenderer = function(index, item)
        local info = self.listMaterialInfos[index + 1]
        if info.isequip then
            self:SetMaterialListItem(item,info.data)
        else
            self:SetEquipListItem(item,info.data)
        end
    end

    --事件监听
    self:AddListener(self._btnAdd.onClick,
        function()
            self.GetChip()
        end
    )
    self:AddListener(self._Maskcancel.onClick,
        function()
            self._groupEquip.visible = false
        end
    )
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("EquipmentTransaction")
        end
    )
    self:AddListener(self._btnSwitch.onClick,
        function()
            UIMgr:Open("EquipmentSelect",1)
            UIMgr:Close("EquipmentTransaction")
        end
    )
    self:AddListener(self._btnR.onClick,
        function()
            if self.triggerFunc then
                self.triggerFunc()
            end
            if self.currentstatus == StatusEnum.lackMaterials then
                JumpMap:JumpTo({jump = 821000})
                return
            end
            self:OnBtnTimeTransClick()
        end
    )
    self:AddListener(self._btnL.onClick,
        function()
            if self.currentstatus == StatusEnum.lackMaterials then
                JumpMap:JumpTo({jump = 821000})
                return
            end
            self:OnBtnGoldTrainClick()
        end
    )
    self:AddEvent(
        EventDefines.RefreshEquipEvent,
        function(Uuid)
           if self.isViewWnd and self._isInTransaction then
                self:RefreshView()
            end
        end
    )
    self:AddEvent(
        EventDefines.RefreshEquipInfo,
        function()
            self:RefreshListMaterial(self._equipType.pre_equip_serial_ids,true,nil,true)
        end
    )
    self:AddListener(self._btnHelp.onClick,
        function()
            Sdk.AiHelpShowSingleFAQ(ConfigMgr.GetItem("configWindowhelps", 2096).article_id)
        end
    )
    for i = 1, #self._btnProbability do
        self:AddListener(self._btnProbability[i].onClick,
            function()
                if self._isInTransaction then
                    return
                end
                self:SetViewQuality(i)
            end
        )
    end
    for i = 1, #self._itemMaterial do
        self:AddListener(self._itemMaterial[i].onClick,
            function()
                if self._isInTransaction then
                    return
                end
                if i == 5 then
                    if self._equipType and self.isNeedEquipMaterial then
                        self._groupEquip.visible = not self._groupEquip.visible
                        self:RefreshListMaterial(self._equipType.pre_equip_serial_ids,true,nil,true)
                    else
                        self._groupEquip.visible = false
                    end
                else
                    if self._itemMaterial[i].triggerFunc then
                        self._itemMaterial[i].triggerFunc()
                    end
                    if self._equipType and self._equipType.need_material_Serial_ids[i] then
                        self._groupEquip.visible = not self._groupEquip.visible
                        self:RefreshListMaterial(self._equipType.need_material_Serial_ids[i].material_id,false,i,true)
                    else
                        self._groupEquip.visible = false
                    end
                end
                self._boxArrowMaterial.x =
                    self._itemMaterial[i].x + self._itemMaterial[i].width*0.5- self._boxArrowMaterial.width*0.5
            end
        )
    end
    --将要生产装备typeID
    self._equipTypeId = nil
    -- 将要生产装备的type信息
    self._equipType = nil
    --当前要当作材料的装备ID
    self._materualEquipId = nil
    --当前要当作材料的装备的UUid
    self._materualEquipUuId = nil
    --选择的材料信息
    self.materials = {}
    --是否需要装备作为祭品
    self.isNeedEquipMaterial = true
    --钻石加速需要的钻石
    self.goldNumber = 0
    --当前装备是否正在交易
    self._isInTransaction = false
    --是否能收取装备
    self.isTakeEquip = false
    --如果有装备交易 表示装备交易事件的UuID
    self.Uuid = nil
    --装备交易需要的支票
    self.equipCost = nil
    --生产装备各材质的概率
    self.qualitysRatio = nil
    --按钮状态
    self.currentstatus = StatusEnum.lackMaterials
    --选择祭品材料时 列表要info
    self.listMaterialInfos = nil
    -- 当前页面是否打开
    self.isViewWnd = false

    --初始化
    self._iconRes.icon = GD.ResAgent.GetIconUrl(CHIP_COST)
    self._btnR.text = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_btn_1")
    self._textProbability.text = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_ui_24_1")
    self._textMaterial.text = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_ui_22_2")
end
function EquipmentTransaction:OnOpen(equipQualityID,isLowMaterial)
    self.isViewWnd = true
    self:RefreshView(equipQualityID,isLowMaterial)
end
-- 显示装备交易信息
function EquipmentTransaction:ViewTransactionInfo()
    --判断当前装备是否在交易
    local equipEvent = EquipModel.IsAlikeIDTransaction(self._equipTypeId)
    if equipEvent then
        self._materualEquipId = equipEvent.UseEquipId
        self.isNeedEquipMaterial = equipEvent.UseEquipId ~= 0
        local typeId = EquipModel.QualityID2TypeID(equipEvent.EquipId)
        local targetJewels = EquipModel.GetMaterialConsumeByTypeID(typeId, equipEvent.JewelIds)
        for i = 1, 4 do
            local targetJewel =  targetJewels[i]
            if targetJewel then
                self:SetMaterialPart(true, i, targetJewel, targetJewel.Amount)
            else
                self:SetMaterialPart( false, i, nil, nil)
            end
        end
        if self.isNeedEquipMaterial then
            self:EquipSelect({id = equipEvent.UseEquipId,Uuid = nil})
        end
        self:SetStatus(StatusEnum.ontransaction)
        self._transationPro.max = equipEvent.Duration
    end
    self:SetTransaction(equipEvent)
end
--刷新界面信息
function EquipmentTransaction:RefreshView(equipQualityID,isLowMaterial)
    -- 初始化变量
    self.isTakeEquip = false
    self._isInTransaction = false
    self._materualEquipId = nil
    self._materualEquipUuId = nil
    self.materials = {}
    if equipQualityID then
        self._equipType = EquipModel.GetEquipTypeByEquipQualityID(equipQualityID)
    end

    -- 判断玩家等级是否足够穿戴装备
    if self._equipType.equip_level >  Model.Player.HeroLevel then
        self._noteTitleText.visible = true
        self._noteTitleBg.visible = true
        self._noteTitleText.text =
            StringUtil.GetI18n(_G.I18nType.Commmon, "equip_ui_23_2", {level = Model.Player.HeroLevel})
    else
        self._noteTitleText.visible = false
        self._noteTitleBg.visible = false
    end

    self._equipTypeId = self._equipType.id
    local factoryBuff =  EquipModel.GetEquipFactoryConfig()
    self.equipCost  = math.ceil(self._equipType.cost/(factoryBuff.resource_cost+100)*100)
    local chipColor = GD.ResAgent.Amount(CHIP_COST, false) >= self.equipCost and "D5E0E0" or "E55D41"
    self._textResNum.text = string.format("[color=#%s]%s[/color]/%s",chipColor,GD.ResAgent.Amount(CHIP_COST, true),self.equipCost)
    local needTime = math.ceil(self._equipType.need_time*(100-factoryBuff.equip_speed)/100)
    self._textTime.text = Tool.FormatTime(needTime)
    self._TransTime.text = Tool.FormatTime(needTime)
    --消耗金币数量
    local timeGold = Tool.TimeTurnGold(needTime)
    self.goldNumber = timeGold
    self._btnL:GetChild("text").text = UITool.UBBTipGoldText(timeGold)
    self._icon.icon = UITool.GetIcon(self._equipType.icon, self._icon)
    self._equipName.text = StringUtil.GetI18n("configI18nEquips", self._equipType.name)

    local consumematerials,maxQuality = EquipModel.GetMatchMaterialByTypeID(self._equipType.need_material_Serial_ids,isLowMaterial)
    for i = 1, 4 do
        if self._equipType.need_material_Serial_ids[i] then
            local materialamount = self._equipType.need_material_Serial_ids[i].amount
            self:SetMaterialPart(
                true,
                i,
                consumematerials[i],
                materialamount)
        else
            self:SetMaterialPart(
                false,
                i,
                nil,
                nil)
        end
    end
    self._itemMaterial[5]:SetData({
        cbData = nil,
        cb = nil,
        quality = 1,
        icon = nil,
        ctr = 0,
        num = nil
    })
    self.isNeedEquipMaterial = true
    if self._equipType.pre_equip_serial_ids == nil then
        self._itemMaterial[5]:SetStyle(4)
        self.isNeedEquipMaterial = false
    end
    self:OnMaterialChange()
    self._groupEquip.visible = false

    self:ViewTransactionInfo()
end
-- 当选为祭品的材料发生改变时
function EquipmentTransaction:OnMaterialChange()
    local isMaterialAdequate = self:IsMaterialAdequate()
    if isMaterialAdequate then
        self:RefreshQualitysRatio()
        self:SetStatus(StatusEnum.readytransaction)
    else
        self:SetStatus(StatusEnum.lackMaterials)
        self:SetEquipRatioView()
    end
end
-- 设置页面状态
function EquipmentTransaction:SetStatus(status)
    self.currentstatus = status
    self:SetButtonStatus()
    local isshowTransPro = self.currentstatus == StatusEnum.ontransaction or self.currentstatus == StatusEnum.finishTransaction
    self._TransTime.visible = isshowTransPro
    self._transationPro.visible = isshowTransPro
    self._iconRes.visible = not isshowTransPro
    self._textResNum.visible = not isshowTransPro
    self._textTime.visible = not isshowTransPro
    self._iconTime.visible = not isshowTransPro
    self._btnAdd.visible = not isshowTransPro
end
--设置按钮状态
function EquipmentTransaction:SetButtonStatus()
    if self.currentstatus == StatusEnum.lackMaterials then
        self._btnR.grayed = true
        self._btnL.grayed = true
        self._btnL.text = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_btn_2")
        self._btnR.text = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_btn_1")
    elseif self.currentstatus == StatusEnum.readytransaction then
        self._btnR.enabled = true
        self._btnL.enabled = true
        self._btnL.text = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_btn_2")
        self._btnR.text = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_btn_1")
    elseif self.currentstatus == StatusEnum.ontransaction then
        self._btnR.enabled = true
        self._btnL.enabled = true
        self._btnL.text = StringUtil.GetI18n(_G.I18nType.Commmon, "BUTTON_GOLD_SPEED")
        self._btnR.text = StringUtil.GetI18n(_G.I18nType.Commmon, "BUTTON_ITEM_SPEED")
    elseif self.currentstatus == StatusEnum.finishTransaction then
        self._btnR.enabled = true
        self._btnL.enabled = false
        self._btnL.text = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_btn_2")
        self._btnR.text = StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_Get")
    end
end
--刷新单个卡槽信息 item:卡槽 materialID：卡槽材料 num：卡槽所需数量
function EquipmentTransaction:SetMaterialPart(flag,part,targetJewelInfo,num)
    local item = self._itemMaterial[part]
    item._icon.enabled = true
    item._iconBg.enabled = true
    if flag then
        local MaterialType = EquipModel.GetMaterialByQualityId(targetJewelInfo.ConfId)
        item:SetQuality(targetJewelInfo.quality-1)
        if targetJewelInfo.Amount < num then
            item:SetType(3)
            item._icon.enabled = false
            item._iconBg.enabled = false
        else
            item:SetType(2)
        end
        item:SetTitle(_G.string.format("%d/%d",targetJewelInfo.Amount,num))
        item:SetIcon(MaterialType.icon)
        self.materials[part] = targetJewelInfo
    else
        item:SetType(4)
        item:SetQuality(0)
        self.materials[part] = nil
    end
end
--设置交易状态
function EquipmentTransaction:SetTransaction(equipevent)
    --时间刷新
    if self.schedule_time then
        self:UnSchedule(self.schedule_time)
    end

    if not equipevent then
        self._isInTransaction = false
        return
    end

    self.Uuid = equipevent.Uuid
    self._isInTransaction = true
    local function time_func()
        return equipevent.FinishAt - Tool.Time()
    end
    self.schedule_time = function()
        local t = time_func()
        if t >= 0 then
            local timeGold = Tool.TimeTurnGold(t)
            self.goldNumber = timeGold
            self._btnL:GetChild("text").text = UITool.UBBTipGoldText(timeGold)
            self._TransTime.text = Tool.FormatTime(t)
            self._transationPro.value =  equipevent.Duration - t
            return
        end
        self:UnSchedule(self.schedule_time)
    end
    self:Schedule(self.schedule_time, 1)
end
-- 刷新装备属性信息列表
function EquipmentTransaction:RefreshAttributeList(qualityID)
    local equipQuality = EquipModel.GetEquipQualityById(qualityID)
    local buffNames = equipQuality.att_name
    local values = equipQuality.buff_values
    local qualitycolor = EquipModel.GetColorCodeByQuality(equipQuality.quality)
    self._listattribute.numItems = #buffNames
    for i = 1, #buffNames do
        local item = self._listattribute:GetChildAt(i-1)
        -- item:SetData(buffNames[i],("+%.2f"):format(values[i]/100).."%",1)
        item:SetData(buffNames[i],string.format("[color=#%s]+%.2f%%[/color]",qualitycolor,values[i]/100),0)
        if math.fmod( i, 2 ) == 1 then
            item:SetBgA(0.2)
        else
            item:SetBgA(0.4)
        end
        item:SetHight(35)
    end
end
-- typeID 装备或者材料的typeID      flag = true and 装备 or 材料
function EquipmentTransaction:RefreshListMaterial(typesID,flag,part,isToTop)
    if not typesID then
        return
    end
    if flag then
        local equips = EquipModel.GetEquipBagByTypeId(typesID)
        local lowLevel = ("Lv.").format(self._equipType.pre_equip_levels[1])
        local highLevel = ("Lv.").format(self._equipType.pre_equip_levels[2])
        self._textNeed.text = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_ui_22_3",{level_1 = lowLevel,level_2 = highLevel})
        if not next(equips or {}) then
            self._listMaterial.visible = false
            self._textNoWeapon.visible = true
            return
        end

        self._listMaterial.visible = true
        self._textNoWeapon.visible = false
        self.listMaterialInfos = {}
        for i = 1, #equips do
            local info = {
                isequip = flag,
                data = equips[i]
            }
            table.insert(self.listMaterialInfos,info)
        end
        self._listMaterial.numItems = #self.listMaterialInfos
        if isToTop then
            self._listMaterial.scrollPane:ScrollTop()
        end
        return
    end
    self._listMaterial.visible = true
    self._textNoWeapon.visible = false
    local jewels = EquipModel.GetJewelBag()
    local materialType = EquipModel.GetMaterialById(typesID )
    self._textNeed.text = string.format("%s%s",StringUtil.GetI18n(_G.I18nType.Commmon, "equip_ui_23_1"),StringUtil.GetI18n("configI18nEquips", materialType.name))
    self.listMaterialInfos = {}
    for i = 1, 6 do
        local info = {
            isequip = flag,
            data = {
                id = typesID + i,
                icon = materialType.icon,
                jewel = jewels[typesID + i],
                part  =  part
            }
        }
        table.insert(self.listMaterialInfos,info)
    end
    self._listMaterial.numItems = #self.listMaterialInfos
    if isToTop then
        self._listMaterial.scrollPane:ScrollTop()
    end
end
--[[
    jewel 单条装备信息
]]
function EquipmentTransaction:SetMaterialListItem(item,data)
    local euipBg = data
    local id = data.Id
    local equipType = EquipModel.GetEquipTypeByEquipQualityID(id)
    local equipQuality = EquipModel.GetEquipQualityById(id)
    if equipType and equipQuality then
        item:SetIcon(equipType.icon)
        item:SetQuality(equipQuality.quality-1)
        item:SetType(8)
        item:SetNum(string.format("LV.%d",equipType.equip_level))
        item:SetOnClick(self.EquipSelectBtnClick,{_self = self,equip = euipBg})
        item:SetLockAndPut(euipBg.IsPuton,euipBg.IsLock)
        item:SetBtnGetOnClick(nil,nil)
    end
end
--[[
    id  材料ID
    icon 图标
    jewel 单条宝石信息
    part 位置槽
]]
function EquipmentTransaction:SetEquipListItem(item,data)
        local materialconfigId = data.id
        local materialQuality = EquipModel.GetQualityMaterialById(materialconfigId)
        item:SetIcon(data.icon)
        item:SetQuality(materialQuality.quality-1)
        item:SetType(1)
        item:SetBtnGetOnClick(self.BtnGetMaterialOnClick,{quality = materialQuality.quality,typeID = EquipModel.QualityID2TypeID(materialconfigId)})
        local jewel = data.jewel
        if not jewel then
            jewel = {Amount = 0}
        end
        local delNum = 0 --材料  被选中时 要减开选中的数目
        for _,v in pairs(self.materials) do
            if v.ConfId == materialconfigId then
                delNum = delNum + v.Amount
            end
        end
        local viewNumMaterial = jewel.Amount-delNum
        item:SetNum(viewNumMaterial)
        if viewNumMaterial > 0 then
            item:SetOnClick(self.MaterialSelect,{_self = self,id = materialconfigId,part = data.part})
        else
            item:SetOnClick(nil,nil)
        end
        item:SetLockAndPut(false,false)
end
function EquipmentTransaction.BtnGetMaterialOnClick(data)
    local centents = {}
    local jumpMaterialFactory = {
        icon = {"Icon","Building_445000_small"},
        name  = _G.StringUtil.GetI18n("configI18nBuildings","445000_NAME"),
        click = function()
            UIMgr:ClosePopAndTopPanel()
            local config = EquipModel.GetMaterialById(data.typeID)
            local building = BuildModel.FindByConfId(Global.BuildingEquipMaterialFactory)
            if building then
                JumpMap:JumpTo({jump = 820000, para = {type=config.type,id=config.id},para1=false})
            else
                JumpMapModel.BuildCreate(Global.BuildingEquipMaterialFactory, false)
            end
            UIMgr:Close("AcquisitionPopup")
        end
    }
    table.insert(centents,jumpMaterialFactory)
    if data.quality > EquipModel.EquipQuality.EquipQuialityMin then
        local jumpMaterialMake = {
            icon = {"Icon","icon_material_18"},
            name  = _G.StringUtil.GetI18n(_G.I18nType.Commmon,"equip_ui_12_2"),
            click = function()
                UIMgr:Open("EquipmentDecompositionSynthesis",EquipModel.TypeID2QualityID(data.quality-1,data.typeID))
                UIMgr:Close("AcquisitionPopup")
            end
        }
        table.insert(centents,jumpMaterialMake)
    end
    UIMgr:Open("AcquisitionPopup",_G.StringUtil.GetI18n(_G.I18nType.Commmon,"Ui_ForcesUp_HowGet") ,centents)
end
function EquipmentTransaction.EquipSelectBtnClick(data)
    -- 最后确认选择装备
    local select = function ()
        local _clickself = data._self
        local _id = data.equip.Id
        local _Uuid = data.equip.Uuid
        _clickself:EquipSelect({_self = _clickself,id = _id,Uuid = _Uuid})
    end
    -- 装备是否锁定
    local LockCheck = function ()
        if data.equip.IsLock then
            local dataui = {
                content = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_dialog_9"),
                sureBtnText = StringUtil.GetI18n(_G.I18nType.Commmon, "BUTTON_YES"),
                sureCallback = function()
                    _G.Net.Equip.UnlockEquip(data.equip.Uuid, function()
                        TipUtil.TipById(50328)
                        select()
                    end)
                end
            }
            UIMgr:Open("ConfirmPopupText", dataui)
        else
            select()
        end
    end
    -- 装备是否穿戴
    local PutCheck = function ()
        if data.equip.IsPuton then
            local dataui = {
                content = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_dialog_7"),
                sureBtnText = StringUtil.GetI18n(_G.I18nType.Commmon, "BUTTON_YES"),
                sureCallback = function()
                    _G.Net.Equip.PutoffEquip(
                        data.equip.Uuid,
                        function()
                            LockCheck()
                        end
                    )
                end
            }
            UIMgr:Open("ConfirmPopupText", dataui)
        else
            LockCheck()
        end
    end
    PutCheck()
end
-- 选择装备
function EquipmentTransaction:EquipSelect(data)
    local qualityid = data.id
    local equipQuality = EquipModel.GetEquipQualityById(qualityid)
    local equipType = EquipModel.GetEquipTypeByEquipQualityID(qualityid)
    self._itemMaterial[5]:SetData({
        cbData = nil,
        cb = nil,
        quality = equipQuality.quality,
        icon = equipType.icon,
        ctr = 0,
        num = nil
    })
    self._materualEquipId = qualityid
    self._materualEquipUuId = data.Uuid
    self:OnMaterialChange()
    self._groupEquip.visible = false
end
--材料选择
function EquipmentTransaction.MaterialSelect(data)
    local _self = data._self
    local item = _self._itemMaterial[data.part]
    local targetJewelInfo = EquipModel.GetJewelBag()[data.id]
    if not targetJewelInfo then
        return
    end
    local MaterialType = EquipModel.GetMaterialByQualityId(targetJewelInfo.ConfId)
    local MaterialQuality = EquipModel.GetQualityMaterialById(targetJewelInfo.ConfId)
    item:SetQuality(MaterialQuality.quality-1)
    item._icon.enabled = true
    item._iconBg.enabled = true
    local addmaterialNum = 0
    local lastMaterialNum = EquipModel.GetLastMaterialafterPart(_self.materials,targetJewelInfo.ConfId)
    if lastMaterialNum < _self._equipType.need_material_Serial_ids[data.part].amount then
        item:SetType(3)
        item._icon.enabled = false
        item._iconBg.enabled = false
        addmaterialNum = lastMaterialNum
    else
        item:SetType(2)
        addmaterialNum = _self._equipType.need_material_Serial_ids[data.part].amount
    end
    item:SetTitle(
        _G.string.format("%d/%d",addmaterialNum,_self._equipType.need_material_Serial_ids[data.part].amount)
    )
    item:SetIcon(MaterialType.icon)
    _self.materials[data.part] =
        {ConfId=targetJewelInfo.ConfId,Amount=addmaterialNum,quality = MaterialQuality.quality}
    if (not _self.isNeedEquipMaterial) or _self._materualEquipId then
        _self:OnMaterialChange()
    end
    _self._groupEquip.visible = false
end
-- 刷新各品质武器生成概率
function EquipmentTransaction:RefreshQualitysRatio()
    local min =1
    local equipweight = 0
    local max = 1
    local equipQuality = 1
    local jewels = {}
    if self._materualEquipId then
        local equipType = EquipModel.GetEquipTypeByEquipQualityID(self._materualEquipId)
        if equipType then
            equipQuality = EquipModel.QualityID2Quality(self._materualEquipId)
            equipweight = equipType.continue_mat_numb
            min = equipQuality
            max = min
        end
    end
    for i = EquipModel.EquipQuality.EquipQuialityMin, EquipModel.EquipQuality.EquipQuialityMax do
        jewels[i] =0
    end
    for _,v in pairs(self.materials) do
        min = v.quality < min and v.quality or min
        max = v.quality > max and v.quality or max
        jewels[v.quality] = v.Amount + jewels[v.quality]
    end
    self.qualitysRatio = EquipModel.CalcQualitysRatio(min,max,equipQuality,equipweight,jewels)
    self:SetEquipRatioView(self.qualitysRatio)
end
function EquipmentTransaction:OnBtnTimeTransClick()
    if self.isTakeEquip then
        return
    end
    if self.currentstatus == StatusEnum.ontransaction then
        local acc_func = function(flag)
            if flag ~= nil and not flag then
                EquipModel.EquipFactoryAnim(false)
            end
            self:RefreshView()
        end
        local building = EquipModel.GetEquipFactory()
        UIMgr:Open("BuildAcceleratePopup", building,acc_func)
        return
    end
    
    self:TransactionReminder(false)
end
function EquipmentTransaction:OnBtnGoldTrainClick()
    if self.goldNumber > Model.Player.Gem then
        UITool.GoldLack()
        return
    end
    local values = {
        diamond_num = self.goldNumber
    }
    local data = {
        content = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_ui_29_1", values),
        tipType = _G.TipType.TYPE.ConditionTrain,
        gold = self.goldNumber,
        sureCallback = function()
            if self._isInTransaction then
                local event = EquipModel.GetEquipEvents()
                EquipModel.EquipSpeed(event.Uuid,event.EquipId)
            else
                self:TransactionReminder(true)
            end
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end
-- 交易的弹框提醒 flag:是否立即交易
function EquipmentTransaction:TransactionReminder(flag)
    local EquipEvent = EquipModel.GetEquipEvents()
    if EquipEvent then
        UIMgr:Open("EquipPayAccelerationPopup", function()
        end,true)
        return
    end
    --如果要钻石补充芯片 判断钻石是否足够
    local goldCheck = function (goldneed)
        if goldneed > Model.Player.Gem then
            UITool.GoldLack()
            return
        end
        self:OnTransaction(flag)
    end
    -- 检查芯片是否充足
    local chipCheck = function ()
        local selfChip = GD.ResAgent.Amount(CHIP_COST, false)
        if selfChip >= self.equipCost  then
            self:OnTransaction(flag)
            return
        end
        local goldneed = EquipModel.ConsumeSupplementChip(self.equipCost - selfChip)
        local data = {
            content = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_dialog_5"),
            gold = goldneed,
            sureCallback = function()
                goldCheck(goldneed)
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end
    -- 弹出概率窗口
    local qualitySure = function()
        local data = {
            qualitysRatio = self.qualitysRatio,
            sureCallback = function()
                chipCheck()
            end
        }
        UIMgr:Open("EquipTransactionQualityPopup", data)
    end
    -- 弹出材料消耗窗口
    if self.isNeedEquipMaterial then
        local consumeEquip = EquipModel.GetEquipTypeByEquipQualityID(self._materualEquipId)
        local quality = EquipModel.QualityID2Quality(self._materualEquipId)
        local colorName =  StringUtil.GetI18n(_G.I18nType.Commmon, EquipModel.GetColorNameByQuality(quality))
        local consumeEquipName = ("[color=#%s]%s[/color]"):format(EquipModel.GetColorCodeByQuality(quality), StringUtil.GetI18n("configI18nEquips", consumeEquip.name))
        local data = {
            content = StringUtil.GetI18n(_G.I18nType.Commmon, "equip_ui_30_1", {color=colorName,equip_name = consumeEquipName}),
            sureBtnText = StringUtil.GetI18n(_G.I18nType.Commmon, "BUTTON_YES"),
            sureCallback = function()
                qualitySure()
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        qualitySure()
    end
end
--交易
function EquipmentTransaction:OnTransaction(isNow)
    local JewelIds = {}
    for _,v in pairs(self.materials) do
        table.insert(
            JewelIds,
            v.ConfId
        )
    end
    local net_func = function(rsp)
        if not rsp then
            return
        end
        if not rsp.Instant then
            EquipModel.UpdateEquipEvent(rsp.Event)
            self:SetTransaction(rsp.Event)

            local buildId = BuildModel.GetObjectByConfid(Global.BuildingEquipFactory)
            local node = _G.BuildModel.GetObject(buildId)
            if node then
                --刷新建筑倒计时条
                node:ResetCD()
            end
            self:ViewTransactionInfo()
            return
        end
        if rsp.EquipUuid then
            _G.UIMgr:Open("EquipDetail", rsp.EquipUuid, true,function()
                UIMgr:Close("EquipmentTransaction")
                UIMgr:Close("EquipmentSelect")
            end)
        end
        self:RefreshView()
    end
    _G.Net.Equip.ExchangeEquip(
        self._equipTypeId,
        self._materualEquipUuId,
        JewelIds,
        isNow,
        function(rsp)
            net_func(rsp)
        end
    )
end
-- 获取支票
function EquipmentTransaction.GetChip()
    UIMgr:Open("EquipGetChip")
end
function EquipmentTransaction:SetEquipRatioView(qualitysRatio)
    local maxShowQualaity = 0
    for i = 1, #self._btnProbability do
        local item = self._btnProbability[i]
        local ratio = (qualitysRatio and qualitysRatio[i]) and qualitysRatio[i] or 0
        maxShowQualaity = ratio > 0 and i or maxShowQualaity
        item:GetChild("title").text = ("%.2f%%"):format((ratio*100))
    end
    maxShowQualaity = maxShowQualaity == 0 and EquipModel.EquipQuality.EquipQuialityMax or maxShowQualaity
    self:SetViewQuality(maxShowQualaity)
end
-- 当前放入的材料是否充足
function EquipmentTransaction:IsMaterialAdequate()
    if self.isNeedEquipMaterial and not self._materualEquipId then
        return false
    end
    if not self.materials then
        return false
    end
    for i = 1 ,#self._equipType.need_material_Serial_ids do
        if self.materials[i].Amount < self._equipType.need_material_Serial_ids[i].amount then
            return false
        end
    end
    return true
end
-- 设置当前界面的quality
function EquipmentTransaction:SetViewQuality(quality)
    if not quality or quality > EquipModel.EquipQuality.EquipQuialityMax or quality < EquipModel.EquipQuality.EquipQuialityMin then
        quality = EquipModel.EquipQuality.EquipQuialityMax
    end
    self._boxArrowProbability.x =
        self._btnProbability[quality].x + self._btnProbability[quality].width*0.5- self._boxArrowProbability.width*0.5
    self._targetquality.selectedIndex = quality
    for i = 1, #self._btnProbability do
        self._btnProbability[i]:GetChild("icon").alpha = i == quality and 1 or 0.5
    end
    self:RefreshAttributeList(EquipModel.TypeID2QualityID(self._equipTypeId,quality))
end
function EquipmentTransaction:OnClose()
    self._materualEquipId = nil
    self._materualEquipUuId = nil
    self.materials = {}
    self.qualitysRatio = nil
    self.isViewWnd = false

    if self.schedule_time then
        self:UnSchedule(self.schedule_time)
    end
end
--得到装备材料不足的item下标
function EquipmentTransaction:GetDefectIndex()
    if self.isNeedEquipMaterial and not self._materualEquipUuId then
        TipUtil.TipById(50345)
        return 5
    else
        for i = 1, 4, 1 do
            local item = self._itemMaterial[i]
            local typeNum = item:GetType()
            if typeNum == 3 then
                return i
            end
        end
    end
end

function EquipmentTransaction:TriggerOnclick(callback)
    self.triggerFunc = callback
end

return EquipmentTransaction