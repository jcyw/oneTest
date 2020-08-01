-- 资源援助界面
local GD = _G.GD
local UnionWarehouseAccessResources = UIMgr:NewUI("UnionWarehouseAccessResources")

UnionResType = {
    ResAssist = 1,    -- 联盟成员资源援助
    ResStoreIn = 2,   -- 联盟仓库资源存储
    ResStoreOut = 3,  -- 联盟仓库资源取出
}

import("UI/Common/ItemKeyboard")
local UnionModel = import("Model/UnionModel")
local BuildModel = import("Model/BuildModel")
local CommonModel = import("Model/CommonModel")
local ArmiesModel = import("Model/ArmiesModel")
local GlobalVars = GlobalVars

function UnionWarehouseAccessResources:OnInit()
    local view = self.Controller.contentPane
    self._btnAssist = view:GetChild("btnStore")
    self._txtTitle = view:GetChild("textName")
    self._iconFromHead = view:GetChild("iconMy")
    self._iconToHead = view:GetChild("iconUnion")
    self._txtToName = view:GetChild("textUnion")
    self._txtFromName = view:GetChild("textMy")
    self._txtTaxTitle = view:GetChild("textToday")
    self._txtTax = view:GetChild("textTodayNum")
    self._txtLoadTitle = view:GetChild("textTotal")
    self._txtLoad = view:GetChild("textTotalNum")
    self._txtTime = self._btnAssist:GetChild("text")
    self.myResTexts = {}
    self.myResTexts[Global.ResWood] = view:GetChild("numberWoodMy")
    self.myResTexts[Global.ResFood] = view:GetChild("numberFoodMy")
    self.myResTexts[Global.ResIron] = view:GetChild("numberIronMy")
    self.myResTexts[Global.ResStone] = view:GetChild("numberStoneMy")
    self.assitResTexts = {}
    self.assitResTexts[Global.ResWood] = view:GetChild("numberWoodUnion")
    self.assitResTexts[Global.ResFood] = view:GetChild("numberFoodUnion")
    self.assitResTexts[Global.ResIron] = view:GetChild("numberIronUnion")
    self.assitResTexts[Global.ResStone] = view:GetChild("numberStoneUnion")
    self._woodItem = view:GetChild("itemResources1")
    self._woodItemSlider = self._woodItem:GetChild("slide")
    self._woodItemInput = self._woodItem:GetChild("textInput")
    self._woodItem:GetChild("textName").text = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_1")
    self._foodItem = view:GetChild("itemResources2")
    self._foodItemSlider = self._foodItem:GetChild("slide")
    self._foodItemInput = self._foodItem:GetChild("textInput")
    self._foodItem:GetChild("textName").text = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_4")
    self._ironItem = view:GetChild("itemResources3")
    self._ironItemSlider = self._ironItem:GetChild("slide")
    self._ironItemInput = self._ironItem:GetChild("textInput")
    self._ironItem:GetChild("textName").text = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_3")
    self._stoneItem = view:GetChild("itemResources4")
    self._stoneItemSlider = self._stoneItem:GetChild("slide")
    self._stoneItemInput = self._stoneItem:GetChild("textInput")
    self._stoneItem:GetChild("textName").text = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_2")
    self._controlResource = view:GetController("resControl")
    self.keyboard = UIMgr:CreatePopup("Common", "itemKeyboard")

    self.config = ConfigMgr.GetListBySearchKeyValue("configAllianceFortresss", "building_type", Global.AllianceStore)
    if #self.config > 0 then
        self.config = self.config[1]
    end
    self.maxLoad = 0
    
    self:InitResItem(self._woodItem, Global.ResWood)
    self:InitResItem(self._foodItem, Global.ResFood)
    self:InitResItem(self._ironItem, Global.ResIron)
    self:InitResItem(self._stoneItem, Global.ResStone)

    self.ratios = {}
    self.ratios[Global.ResWood] = ConfigMgr.GetItem("configResourcess", Global.ResWood).ratio
    self.ratios[Global.ResFood] = ConfigMgr.GetItem("configResourcess", Global.ResFood).ratio
    self.ratios[Global.ResIron] = ConfigMgr.GetItem("configResourcess", Global.ResIron).ratio
    self.ratios[Global.ResStone] = ConfigMgr.GetItem("configResourcess", Global.ResStone).ratio

    self:AddListener(self._btnAssist.onClick,function()
        self.cb()
    end)

    local btnReturn = view:GetChild("btnReturn")
    self:AddListener(btnReturn.onClick,function()
        UIMgr:Close("UnionWarehouseAccessResources")
    end)
end

function UnionWarehouseAccessResources:OnOpen(type, info,posNum)
    if ArmiesModel.CheckMissionLimit() then
        UIMgr:Close("UnionWarehouseAccessResources")
        return
    end
    self.posNum = posNum
    self.type = type
    self.assistRes = {
        [1] = {Category = 1, Amount = 0}, 
        [4] = {Category = 4, Amount = 0}, 
        [3] = {Category = 3, Amount = 0},
        [2] = {Category = 2, Amount = 0}
    }

    
    if type == UnionResType.ResAssist then
        self:InitResAssist(info)
    elseif type == UnionResType.ResStoreIn then
        self:InitResStoreIn(info)
    elseif type == UnionResType.ResStoreOut then
        self:InitResStoreOut(info)
    end
    
    self:RefreshLoadShow()
end

function UnionWarehouseAccessResources:ResetMidTextColor()
    self._txtTaxTitle.color = Color(229/255, 93/255, 65/255)
    self._txtTax.color = self._txtTaxTitle.color
    self._txtLoadTitle.color = Color(240/255, 226/255, 201/255)
    self._txtLoad.color = self._txtLoadTitle.color
end

function UnionWarehouseAccessResources:RefreshMidTextColor(todayFull,totalFull)
    self._txtTaxTitle.color = todayFull and Color(229/255, 93/255, 65/255) or Color(240/255, 226/255, 201/255) 
    self._txtTax.color = self._txtTaxTitle.color
    self._txtLoadTitle.color = totalFull and Color(229/255, 93/255, 65/255) or Color(240/255, 226/255, 201/255) 
    self._txtLoad.color = self._txtLoadTitle.color
end

-- 资源援助界面，info结构为 AllianceResAssistInfoRsp协议
function UnionWarehouseAccessResources:InitResAssist(info)
    self:ResetMidTextColor()
    self:BuildResInfo(info.SelfResource, {})

    self.info = info
    self._txtTitle.text = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_Resource_Help")
    self._txtTaxTitle.visible = true
    self._txtLoadTitle.visible = true
    self._txtTax.visible = true
    self._txtLoad.visible = true
    self._txtTaxTitle.text = ConfigMgr.GetI18n(I18nType.Commmon, "UI_Details_Tax")
    self._txtLoadTitle.text = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_LoadCap")
    self._txtTax.text = info.Tax.."%"
    self._txtLoad.text = "0/"..Tool.FormatNumberThousands(info.Load)
    self._txtTime.text = Tool.FormatTimeOfSecond(info.Duration)
    self._txtFromName.text = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_Resource_My")
    self._txtToName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AidRecipients_Name", {play_name = info.PlayerInfo.Name})
    self._btnAssist.text = ConfigMgr.GetI18n(I18nType.Commmon, "BUTTON_AIDRESOURCES")
    self.maxLoad = info.Load
    CommonModel.SetUserAvatar(self._iconFromHead)
    CommonModel.SetUserAvatar(self._iconToHead, info.PlayerInfo.Avatar, info.PlayerInfo.UserId)

    self:InitCommonUI()
    self:RefreshResItem()

    -- 设置显示资源
    local minLv = info.PlayerInfo.Level < BuildModel.GetCenterLevel() and info.PlayerInfo.Level or BuildModel.GetCenterLevel()
    local unlock = 0
    for _,v in pairs(Global.ResUnlockLevel) do
        if minLv >= v.level then
            unlock = v.category
        end
    end
    self._controlResource.selectedPage = unlock

    -- 设置确认按钮
    self.cb = function()
        if not self:HasChoosenRes() then
            TipUtil.TipById(50373)
            return
        end
        local res = {}
        for k,v in pairs(self.assistRes) do
            table.insert(res, v)
        end

        Net.AllianceAssist.Assist(self.info.PlayerInfo.UserId, res, function(rsp)
            if rsp.Fail then
                return
            end

            if (rsp.Armies) then
                ArmiesModel.RefreshArmies(rsp.Armies)
            end
            if (rsp.Event) then
                Event.Broadcast(EventDefines.UIOnMissionInfo, rsp.Event)
            end

            UIMgr:ClosePopAndTopPanel()
            if GlobalVars.IsInCity then
                Event.Broadcast(EventDefines.OpenWorldMap)
            end
        end)
    end
end

-- 联盟仓库存入初始化，info结构为 AllianceStorehouseInitRsp协议
function UnionWarehouseAccessResources:InitResStoreIn(info)
    self:BuildResInfo(info.SelfResource, info.StoredResource)

    self.info = info
    self._txtTitle.text = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouse")
    self._txtTaxTitle.visible = true
    self._txtLoadTitle.visible = true
    self._txtTax.visible = true
    self._txtLoad.visible = true
    self._txtTaxTitle.text = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouse_ToplimitDay")
    self._txtLoadTitle.text = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouse_ToplimitTotal")
    self._txtTax.text = Tool.FormatAmountUnit(info.TodayStore).."/"..Tool.FormatAmountUnit(info.TodayMax)
    self._txtLoad.text = Tool.FormatAmountUnit(info.TotalStore).."/"..Tool.FormatAmountUnit(info.TotalMax)
    local startp = Vector2(Model.Player.X, Model.Player.Y)
    local endp = Vector2(math.floor(self.posNum / 10000), math.floor(self.posNum % 10000))
    local speed = ArmiesModel:GetSpeedByExpedition(Global.MissionResStore,Global.ResHelpSpeed)
    self._txtTime.text = Tool.FormatTimeOfSecond(MapModel.GetMarchTime(startp,endp,speed))--Tool.FormatTimeOfSecond(info.Duration)
    self._txtFromName.text = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_Resource_My")
    self._txtToName.text = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouse")
    local todayLimit = info.TodayMax - info.TodayStore
    local totalLimit = info.TotalMax - info.TotalStore
    self.maxLoad = todayLimit > totalLimit and totalLimit or todayLimit
    self._iconToHead.icon = UITool.GetIcon({"IconArm","alliancestore"})
    self._btnAssist.text = ConfigMgr.GetI18n(I18nType.Commmon, "Button_AllianceWarehouse_State")
    CommonModel.SetUserAvatar(self._iconFromHead)

    self:InitCommonUI()
    self:RefreshResItem()

    -- 设置显示资源
    local minLv = BuildModel.GetCenterLevel()
    local unlock = 0
    for _,v in pairs(Global.ResUnlockLevel) do
        if minLv >= v.level then
            unlock = v.category
        end
    end
    self._controlResource.selectedPage = unlock

    -- 设置确认按钮
    self.cb = function()
        if info.TotalStore == info.TotalMax then
            TipUtil.TipById(50371)
            return
        elseif info.TodayStore == info.TodayMax then
            TipUtil.TipById(50370)
            return
        elseif not self:HasChoosenRes() then
            TipUtil.TipById(50373)
            return
        end
        local res = {}
        for k,v in pairs(self.assistRes) do
            if v.Amount > 0 then
                table.insert(res, v)
            end
        end

        Net.AllianceStorehouse.StoreRes(self.config.id, res, function(rsp)
            if rsp.Fail then
                return
            end
            Event.Broadcast(EventDefines.UIOnMissionInfo, rsp.Event)
            UIMgr:Close("UnionWarehouseAccessResources")
        end)
    end
end

-- 联盟仓库取出初始化，info结构为 AllianceStorehouseInitRsp协议
function UnionWarehouseAccessResources:InitResStoreOut(info)
    self:BuildResInfo(info.StoredResource, info.SelfResource)

    self.info = info
    self._txtTitle.text = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouse")
    self._txtTaxTitle.visible = false
    self._txtLoadTitle.visible = false
    self._txtTax.visible = false
    self._txtLoad.visible = false
    local endp = Vector2(Model.Player.X, Model.Player.Y)
    local startp = Vector2(math.floor(self.posNum / 10000), math.floor(self.posNum % 10000))
    local speed = ArmiesModel:GetSpeedByExpedition(Global.MissionResStore,Global.ResHelpSpeed)
    self._txtTime.text = Tool.FormatTimeOfSecond(MapModel.GetMarchTime(startp,endp,speed))--Tool.FormatTimeOfSecond(info.Duration)
    self._txtFromName.text = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouse")
    self._txtToName.text = ConfigMgr.GetI18n(I18nType.Commmon, "MAP_RESOURCERETRIEVE_BUTTON")
    self.maxLoad = -1
    CommonModel.SetUserAvatar(self._iconFromHead)
    self._btnAssist.text = ConfigMgr.GetI18n(I18nType.Commmon, "Button_AllianceWarehouse_Retrieve")
    self._iconToHead.icon = UITool.GetIcon({"Union","icon_alliance_57"})
    --CommonModel.SetUserAvatar(self._iconToHead)

    self:InitCommonUI()
    self:RefreshResItem()

    -- 设置显示资源
    local minLv = BuildModel.GetCenterLevel()
    local unlock = 0
    for _,v in pairs(Global.ResUnlockLevel) do
        if minLv >= v.level then
            unlock = v.category
        end
    end
    self._controlResource.selectedPage = unlock

    -- 设置确认按钮
    self.cb = function()
        if not self:HasChoosenRes() then
            TipUtil.TipById(50373)
            return
        end
        local res = {}
        for k,v in pairs(self.assistRes) do
            if v.Amount > 0 then
                table.insert(res, v)
            end
        end

        Net.AllianceStorehouse.FetchRes(self.config.id, res, function(rsp)
            if rsp.Fail then
                return
            end
            Event.Broadcast(EventDefines.UIOnMissionInfo, rsp.Event)
            UIMgr:Close("UnionWarehouseAccessResources")
        end)
    end
end

function UnionWarehouseAccessResources:InitCommonUI()
    self.myResTexts[Global.ResWood].text = Tool.FormatAmountUnit(self.myResources[Global.ResWood])
    self.myResTexts[Global.ResFood].text = Tool.FormatAmountUnit(self.myResources[Global.ResFood])
    self.myResTexts[Global.ResIron].text = Tool.FormatAmountUnit(self.myResources[Global.ResIron])
    self.myResTexts[Global.ResStone].text = Tool.FormatAmountUnit(self.myResources[Global.ResStone])
    self.assitResTexts[Global.ResWood].text = self.storeResources[Global.ResWood] == nil and 0 or Tool.FormatAmountUnit(self.storeResources[Global.ResWood])
    self.assitResTexts[Global.ResFood].text = self.storeResources[Global.ResFood] == nil and 0 or Tool.FormatAmountUnit(self.storeResources[Global.ResFood])
    self.assitResTexts[Global.ResIron].text = self.storeResources[Global.ResIron] == nil and 0 or Tool.FormatAmountUnit(self.storeResources[Global.ResIron])
    self.assitResTexts[Global.ResStone].text = self.storeResources[Global.ResStone] == nil and 0 or Tool.FormatAmountUnit(self.storeResources[Global.ResStone])
end

function UnionWarehouseAccessResources:InitResItem(item, category)
    local btnReduce = item:GetChild("btnReduce")
    local btnAdd = item:GetChild("btnAdd")
    local txtInput = item:GetChild("textInput")
    local bgInputBox = item:GetChild("btnInputBox")
    local slider = item:GetChild("slide")
    slider.changeOnClick = false

    item:GetChild("iconWood").url = GD.ResAgent.GetIconUrl(category)--UIPackage.GetItemURL("Common", ConfigMgr.GetItem("configResourcess", category).img)

    self:AddListener(btnReduce.onClick,function()
        if self.assistRes[category].Amount - 1 < 0 then
            self.assistRes[category].Amount = 0
        else
            self.assistRes[category].Amount = self.assistRes[category].Amount - 1
        end

        local pass, amount = self:CheckLoad(category)
        if not pass then
            self.assistRes[category].Amount = amount
        end

        txtInput.text = Tool.FormatNumberThousands(self.assistRes[category].Amount)
        slider.value = self.assistRes[category].Amount
        self:RefreshLoadShow()
        self.myResTexts[category].text = Tool.FormatAmountUnit(self.myResources[category] - self.assistRes[category].Amount)

        local curAmount = self.storeResources[category] + self.assistRes[category].Amount
        if self.type == UnionResType.ResAssist then
            self.assitResTexts[category].text = Tool.FormatAmountUnit(math.ceil(curAmount * (1 - self.info.Tax * 0.01)))
        else
            self.assitResTexts[category].text = Tool.FormatAmountUnit(curAmount)
        end
        self:RefreshResItem()
    end)

    self:AddListener(btnAdd.onClick,function()
        if self.assistRes[category].Amount == slider.max then
            return
        end
        if self.assistRes[category].Amount + 1 > self.myResources[category] then
            self.assistRes[category].Amount = self.myResources[category]
        else
            self.assistRes[category].Amount = self.assistRes[category].Amount + 1
        end

        local pass, amount = self:CheckLoad(category)
        if not pass then
            self.assistRes[category].Amount = amount
        end

        txtInput.text = Tool.FormatNumberThousands(self.assistRes[category].Amount)
        slider.value = self.assistRes[category].Amount
        self:RefreshLoadShow()
        self.myResTexts[category].text = Tool.FormatAmountUnit(self.myResources[category] - self.assistRes[category].Amount)

        local curAmount = self.storeResources[category] + self.assistRes[category].Amount
        if self.type == UnionResType.ResAssist then
            self.assitResTexts[category].text = Tool.FormatAmountUnit(math.ceil(curAmount * (1 - self.info.Tax * 0.01)))
        else
            self.assitResTexts[category].text = Tool.FormatAmountUnit(curAmount)
        end
        self:RefreshResItem()
    end)

    -- self:AddListener(txtInput.onFocusOut,function()
    --     local value = txtInput.text
    --     value = tonumber(value)
    --     if value ~= nil then
    --         value = math.floor(value + 0.5)
    --         if value > self.myResources[category] then
    --             value = self.myResources[category]
    --         elseif value < 0 then
    --             value = 0
    --         end
    --         self.assistRes[category].Amount = value

    --         local pass, amount = self:CheckLoad(category)
    --         if not pass then
    --             self.assistRes[category].Amount = amount
    --         end
        
    --         txtInput.text = self.assistRes[category].Amount
    --         slider.value = self.assistRes[category].Amount
    --         self:RefreshLoadShow()
    --         self.myResTexts[category].text = Tool.FormatAmountUnit(self.myResources[category] - self.assistRes[category].Amount)

    --         local curAmount = self.storeResources[category] + self.assistRes[category].Amount
    --         if self.type == UnionResType.ResAssist then
    --             self.assitResTexts[category].text = Tool.FormatAmountUnit(math.ceil(curAmount * (1 - self.info.Tax * 0.01)))
    --         else
    --             self.assitResTexts[category].text = Tool.FormatAmountUnit(curAmount)
    --         end
    --     end
    -- end)

    self:AddListener(bgInputBox.onClick,function()
        self.keyboard:Init(math.floor(math.min(slider.max,self.myResources[category])), function(value)
            local value = math.min(slider.max,value)
            self.assistRes[category].Amount = value

            local pass, amount = self:CheckLoad(category)
            if not pass then
                self.assistRes[category].Amount = amount
            end
        
            txtInput.text = Tool.FormatNumberThousands(self.assistRes[category].Amount)
            slider.value = self.assistRes[category].Amount
            self:RefreshLoadShow()
            self.myResTexts[category].text = Tool.FormatAmountUnit(self.myResources[category] - self.assistRes[category].Amount)

            local curAmount = self.storeResources[category] + self.assistRes[category].Amount
            if self.type == UnionResType.ResAssist then
                self.assitResTexts[category].text = Tool.FormatAmountUnit(math.ceil(curAmount * (1 - self.info.Tax * 0.01)))
            else
                self.assitResTexts[category].text = Tool.FormatAmountUnit(curAmount)
            end
            self:RefreshResItem()
        end)
		UIMgr:ShowPopup("Common", "itemKeyboard", txtInput)
    end)

    self:AddListener(slider.onChanged,function()
        if slider.max == 0 then
            return
        end

        local value = math.floor(slider.value + 0.5)
        self.assistRes[category].Amount = value < 0 and 0 or value

        local pass, amount = self:CheckLoad(category)
        if not pass then
            slider.value = amount
            self.assistRes[category].Amount = amount
        end
        
        txtInput.text = Tool.FormatNumberThousands(self.assistRes[category].Amount)
        self:RefreshLoadShow()
        self.myResTexts[category].text = Tool.FormatAmountUnit(self.myResources[category] - self.assistRes[category].Amount)

        local curAmount = self.storeResources[category] + self.assistRes[category].Amount
        if self.type == UnionResType.ResAssist then
            self.assitResTexts[category].text = Tool.FormatAmountUnit(math.ceil(curAmount * (1 - self.info.Tax * 0.01)))
        else
            self.assitResTexts[category].text = Tool.FormatAmountUnit(curAmount)
        end
        self:RefreshResItem()
    end)

    self:AddListener(slider.onGripTouchEnd,function()
        slider.value = self.assistRes[category].Amount
        self:RefreshResItem()
    end)
end

function UnionWarehouseAccessResources:GetResInMaxNum(resType,restResNum)
    local otherRes = 0
    for k,v in pairs(self.assistRes) do
        if k ~= resType then
            otherRes = v.Amount * self.ratios[k] + otherRes
        end
    end
    local MaxNum = math.floor((restResNum - otherRes) / self.ratios[resType])
    return MaxNum
end

function UnionWarehouseAccessResources:GetNowResInNum()
    local num = 0
    for k,v in pairs(self.assistRes) do
        num = v.Amount * self.ratios[k] + num
    end
    return math.floor(num)
end

function UnionWarehouseAccessResources:RefreshResItem()
    
    if self.type == UnionResType.ResStoreIn then
        local todayRest = self.info.TodayMax - self.info.TodayStore
        local totalRest = self.info.TotalMax - self.info.TotalStore
        local todayResNumWithOut_Wood = self:GetResInMaxNum(Global.ResWood,todayRest)
        local totalResNumWithOut_Wood = self:GetResInMaxNum(Global.ResWood,totalRest)
        self._woodItemSlider.max = math.min(self.myResources[Global.ResWood],todayResNumWithOut_Wood,totalResNumWithOut_Wood)
        self._woodItemSlider.value = self.assistRes[Global.ResWood].Amount
        self._woodItemInput.text = Tool.FormatNumberThousands(self.assistRes[Global.ResWood].Amount)
        local todayResNumWithOut_Food = self:GetResInMaxNum(Global.ResFood,todayRest)
        local totalResNumWithOut_Food = self:GetResInMaxNum(Global.ResFood,totalRest)
        self._foodItemSlider.max = math.min(self.myResources[Global.ResFood],todayResNumWithOut_Food,totalResNumWithOut_Food)
        self._foodItemSlider.value = self.assistRes[Global.ResFood].Amount
        self._foodItemInput.text = Tool.FormatNumberThousands(self.assistRes[Global.ResFood].Amount)
        local todayResNumWithOut_Iron = self:GetResInMaxNum(Global.ResIron,todayRest)
        local totalResNumWithOut_Iron = self:GetResInMaxNum(Global.ResIron,totalRest)
        self._ironItemSlider.max = math.min(self.myResources[Global.ResIron],todayResNumWithOut_Iron,totalResNumWithOut_Iron)
        self._ironItemSlider.value = self.assistRes[Global.ResIron].Amount
        self._ironItemInput.text = Tool.FormatNumberThousands(self.assistRes[Global.ResIron].Amount)
        local todayResNumWithOut_Stone = self:GetResInMaxNum(Global.ResStone,todayRest)
        local totalResNumWithOut_Stone = self:GetResInMaxNum(Global.ResStone,totalRest)
        self._stoneItemSlider.max = math.min(self.myResources[Global.ResStone],todayResNumWithOut_Stone,totalResNumWithOut_Stone)
        self._stoneItemSlider.value = self.assistRes[Global.ResStone].Amount
        self._stoneItemInput.text = Tool.FormatNumberThousands(self.assistRes[Global.ResStone].Amount)
        self._txtTax.text = Tool.FormatAmountUnit(self.info.TodayStore + self:GetNowResInNum()).."/"..Tool.FormatAmountUnit(self.info.TodayMax)
        self._txtLoad.text = Tool.FormatAmountUnit(self.info.TotalStore + self:GetNowResInNum()).."/"..Tool.FormatAmountUnit(self.info.TotalMax)
        self:RefreshMidTextColor(self.info.TodayStore + self:GetNowResInNum() >= self.info.TodayMax,self.info.TotalStore + self:GetNowResInNum() >= self.info.TotalMax)
    else
        self._woodItemSlider.max = self.myResources[Global.ResWood]
        self._woodItemSlider.value = self.assistRes[Global.ResWood].Amount
        self._woodItemInput.text = Tool.FormatNumberThousands(self.assistRes[Global.ResWood].Amount)
        self._foodItemSlider.max = self.myResources[Global.ResFood]
        self._foodItemSlider.value = self.assistRes[Global.ResFood].Amount
        self._foodItemInput.text = Tool.FormatNumberThousands(self.assistRes[Global.ResFood].Amount)
        self._ironItemSlider.max = self.myResources[Global.ResIron]
        self._ironItemSlider.value = self.assistRes[Global.ResIron].Amount
        self._ironItemInput.text = Tool.FormatNumberThousands(self.assistRes[Global.ResIron].Amount)
        self._stoneItemSlider.max = self.myResources[Global.ResStone]
        self._stoneItemSlider.value = self.assistRes[Global.ResStone].Amount
        self._stoneItemInput.text = Tool.FormatNumberThousands(self.assistRes[Global.ResStone].Amount)
    end
end

-- 检查是否超重，如果超重返回矫正后的资源数量
function UnionWarehouseAccessResources:CheckLoad(category)
    if self.maxLoad < 0 then
        return true
    end

    local ratios = {}
    ratios[Global.ResWood] = ConfigMgr.GetItem("configResourcess", Global.ResWood).ratio
    ratios[Global.ResFood] = ConfigMgr.GetItem("configResourcess", Global.ResFood).ratio
    ratios[Global.ResIron] = ConfigMgr.GetItem("configResourcess", Global.ResIron).ratio
    ratios[Global.ResStone] = ConfigMgr.GetItem("configResourcess", Global.ResStone).ratio

    local total = 0
    local other = 0
    for k,v in pairs(self.assistRes) do
        local value = v.Amount * ratios[k]
        total = total + value
        if k ~= category then
            other = other + value 
        end
    end

    if total > self.maxLoad then
        local max = self.maxLoad - other
        if max < 0 then
            return false, 0
        else
            local amount = math.floor(max / ratios[category])
            return false, amount
        end
    end

    return true
end

function UnionWarehouseAccessResources:HasChoosenRes()
    for k,v in pairs(self.assistRes) do
        if v.Amount > 0 then
            return true
        end
    end
    return false
end

function UnionWarehouseAccessResources:RefreshLoadShow()
    if self.type == UnionResType.ResAssist then
        self._txtLoad.text = Tool.FormatNumberThousands(self:GetTotalLoad()).."/"..Tool.FormatNumberThousands(self.info.Load)
    elseif self.type == UnionResType.ResStore then
        local curLoad = self:GetTotalLoad()
        self._txtLoad.text = Tool.FormatAmountUnit((self.info.TotalStore + curLoad)).."/"..Tool.FormatAmountUnit(self.info.TotalMax)
        self._txtTax.text = Tool.FormatAmountUnit((self.info.TodayStore + curLoad)).."/"..Tool.FormatAmountUnit(self.info.TodayMax)
    end
end

-- 获取当前总负重
function UnionWarehouseAccessResources:GetTotalLoad()    
    local total = 0
    for k,v in pairs(self.assistRes) do
        total = total + v.Amount * self.ratios[k]
    end

    return total
end

-- 构建拥有资源和运送资源的结构
function UnionWarehouseAccessResources:BuildResInfo(my, store)
    self.myResources = {}
    for _,v in pairs(my) do
        self.myResources[v.Category] = v.Amount
    end
    self.myResources[Global.ResWood] = self.myResources[Global.ResWood] ~= nil and self.myResources[Global.ResWood] or 0
    self.myResources[Global.ResFood] = self.myResources[Global.ResFood] ~= nil and self.myResources[Global.ResFood] or 0
    self.myResources[Global.ResIron] = self.myResources[Global.ResIron] ~= nil and self.myResources[Global.ResIron] or 0
    self.myResources[Global.ResStone] = self.myResources[Global.ResStone] ~= nil and self.myResources[Global.ResStone] or 0

    self.storeResources = {}
    for _,v in pairs(store) do
        self.storeResources[v.Category] = v.Amount
    end
    self.storeResources[Global.ResWood] = self.storeResources[Global.ResWood] ~= nil and self.storeResources[Global.ResWood] or 0
    self.storeResources[Global.ResFood] = self.storeResources[Global.ResFood] ~= nil and self.storeResources[Global.ResFood] or 0
    self.storeResources[Global.ResIron] = self.storeResources[Global.ResIron] ~= nil and self.storeResources[Global.ResIron] or 0
    self.storeResources[Global.ResStone] = self.storeResources[Global.ResStone] ~= nil and self.storeResources[Global.ResStone] or 0
end

return UnionWarehouseAccessResources