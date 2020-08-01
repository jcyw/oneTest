--[[    Author: songzeming
    Function: 建筑 训练士兵
]]
local GD = _G.GD
local BuildTrain = UIMgr:NewUI("BuildRelated/BuildTrain")

local TrainModel = import("Model/TrainModel")
local BuildModel = import("Model/BuildModel")
local BuffModel = import("Model/BuffModel")
local EventModel = import("Model/EventModel")
local DetailModel = import("Model/DetailModel")
local UIType = _G.GD.GameEnum.UIType
local CommonModel = import("Model/CommonModel")
local AnimationArmyQueue = import("Model/Animation/AnimationArmyQueue")
import("UI/Common/ItemSlide")
import("UI/Common/LongPressPopupLabel")
import("UI/Common/LongPressPopupIcon")
import("UI/MainCity/TrainRelated/ItemTrainArmyDetail")
import("UI/MainCity/TrainRelated/ItemTrainArmySlide")
import("UI/MainCity/TrainRelated/ItemTrainAttribute")
import("UI/City/ItemResourcesAdd")
local GuidePanelModel = import("Model/GuideControllerModel")
local JumpMapModel = import("Model/JumpMapModel")
local CTR = {
    ArmyNormal = "ArmyNormal", --士兵等待训练
    ArmyTrain = "ArmyTrain", --士兵训练中
    ArmyLock = "ArmyLock", --士兵兵种未解锁
    SecurityNormal = "SecurityNormal", --安保工厂等待训练
    SecurityTrain = "SecurityTrain", --安保工厂训练中
    SecurityLock = "SecurityLock" --安保工厂兵种未解锁
}

function BuildTrain:OnInit()
    local view = self.Controller.contentPane
    self._ctr = view:GetController("Ctr")
    self._uibg = self._bg:GetChild("_icon")

    self._btnIncrease.visible = false
    GuidePanelModel:SetParentUI(self, UIType.BuildTrainUI)
    self:AddListener(self._btnIncrease.onClick,
        function()
            self:OnBtnIncreateTrainClick()
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._btnDetail.onClick,
        function()
            self:OnBtnDetailClick()
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._iconHistory.onClick,
        function()
            UIMgr:Open("TrainRelated/TrainHistory", self.armyId, self.building.ConfId)
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self._textGold = self._btnL:GetChild("text")
    self:AddListener(self._btnL.onClick,
        function()
            self:OnBtnArrowLeftClick()
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self._touchMask = self._btnR:GetChild("_touchMask")
    self:AddListener(self._btnR.onClick,
        function()
            self:OnBtnArrowRigthClick()
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._btnU.onClick,
        function()
            self:Close()
            UIMgr:Open("BuildRelated/BuildUpgrade", self.building.Pos)
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._btnExplain.onClick,
        function()
            self:OnBtnExplainClick()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._btnAdvanced.onClick, function()
        UIMgr:Open("TrainRelated/TrainAdvanced", self.armyId, self.advancedArmyId)
    end)

    local show_func = function()
        return UIMgr:GetUIOpen("BuildRelated/BuildTrain")
    end
    self:AddEvent(
        EventDefines.UIArmiesRefresh,
        function()
            self:UpdateArmy(self.armyId)
        end
    )
    self:AddEvent(
        EventDefines.UIBuffUpdate,
        function()
            if show_func() then
                self:UpdateBaseData(self.building)
            end
        end
    )
    self:AddEvent(
        EventDefines.UIResourcesDisplayClose,
        function()
            if show_func() then
                self:UpdateBaseData(self.building)
            end
        end
    )

    self._textRestraint.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Restrain") .. "："
    self:LongPressShow()
end

function BuildTrain:ShowBg(confId)
    if confId == Global.BuildingSecurityFactory then
        UITool.GetIcon({"falcon", "buildtrain_03"},self._uibg)
    elseif confId == Global.BuildingHelicopterFactory then
        UITool.GetIcon({"falcon", "buildtrain_02"},self._uibg)
    else
        UITool.GetIcon({"falcon", "buildtrain_01"},self._uibg)
    end
end

function BuildTrain:OnOpen(building, args)
    self.IsVisible=true
    self.building = building
    self.args = args
    self:ShowBg(self.building.ConfId)
    self:UpdateBaseData()
    local isGuideShow = GuidePanelModel:IsGuideState(self.building, _G.GD.GameEnum.JumpType.Train)
    self._touchMask.visible = isGuideShow or GlobalVars.IsTriggerStatus
    if isGuideShow then
        if self.building.ConfId == Global.BuildingSecurityFactory then
            local finishParams = JumpMapModel:GetFinishiParams()
            if finishParams then
                self.args = {ConfId = self.building.ConfId, Amount = finishParams.para2}
            else
                self.args = {ConfId = self.building.ConfId}
            end
        else
            local guideArmyId = JumpMapModel:GetJumpArmyId()
            local guildArmyNum = 0
            if not JumpMapModel:GetFinishiParams() then
                guildArmyNum = self.max
            else
                local finishParams = JumpMapModel:GetFinishiParams()
                guildArmyNum = tonumber(finishParams.para2)
            end
            self.args = {ConfId = self.building.ConfId, ArmyId = guideArmyId, Amount = guildArmyNum}
        end
        self:OnTrainArmyAmount()
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BuildTrainUI)
    else
        self:OnTrainArmyAmount()
    end
end

function BuildTrain:Close()
    UIMgr:Close("BuildRelated/BuildTrain")
end

function BuildTrain:OnClose()
    self.IsVisible=false
    self._slideArmy:ClearArmyAnim()
    if self.time_func then
        self:UnSchedule(self.time_func)
    end
end

function BuildTrain:UpdateBaseData()
    self.armyId = nil
    self.goldNumber = 0

    self._resList.numItems = #GD.ResAgent.GetResUnlock()

    --是否为安保工厂
    self.isSecurityFactory = self.building.ConfId == Global.BuildingSecurityFactory
    local confId = self.building.ConfId
    --建筑名称
    self.buildName = BuildModel.GetName(self.building.ConfId)
    --训练事件
    self.event = EventModel.GetTrainEvent(confId)
    --最大训练数量
    local trainNum = BuildModel.GetTrainMaxNumber(confId)
    local buffNum = 0
    if not self.isSecurityFactory then
        buffNum = BuffModel.GetArmyAmount()
    end
    self.max = trainNum + buffNum
    local slide_func = function()
        self:UpdateData()
    end
    self._slideTrain:Init("Army", 1, self.max, slide_func)
    --单个士兵训练速度
    self.trainSpeed = BuildModel.GetTrainSpeed(confId)
    --士兵基础Id
    self.armBaseId = TrainModel.GetBaseArmId(confId)

    --训练记录
    self.record = PlayerDataModel:GetData(PlayerDataEnum.TRAIN_RECORD)
    if not self.record then
        self.record = {}
    end
    local recordIndex = math.floor(self.record[tostring(confId)] or 0)
    --训练解锁记录
    local conf = BuildModel.GetConf(confId)
    local unlockI = conf.army.amount
    for i = 1, conf.army.amount do
        local aid = self.armBaseId + i - 1
        if not TrainModel.GetArmUnlock(aid) then
            unlockI = i - 1
            break
        end
    end
    self.unlockI = unlockI
    self.unlock = PlayerDataModel:GetData(PlayerDataEnum.TRAIN_UNLOCK)
    if not self.unlock then
        self.unlock = {}
    end
    local unlockIndex = math.floor(self.unlock[tostring(confId)] or 0)
    if unlockI > unlockIndex then
        recordIndex = unlockI + 1
    end

    --刷新士兵训练中进度
    self:UpdateTrain()
    self._slideArmy:Init(
        confId,
        recordIndex,
        function(armyId, isLock)
            self:SetController(isLock)
            self:UpdateArmy(armyId)
        end
    )
end

--设置控制器状态
function BuildTrain:SetController(isLock)
    if self.isSecurityFactory then
        if self.event then
            self._ctr.selectedPage = CTR.SecurityTrain
        else
            if isLock then
                self._ctr.selectedPage = CTR.SecurityLock
            else
                self._ctr.selectedPage = CTR.SecurityNormal
            end
        end
    else
        if self.event then
            self._ctr.selectedPage = CTR.ArmyTrain
        else
            if isLock then
                self._ctr.selectedPage = CTR.ArmyLock
            else
                self._ctr.selectedPage = CTR.ArmyNormal
            end
        end
    end
end

--训练兵种刷新
function BuildTrain:UpdateArmy(armyId)
    self.armyId = armyId
    self._btnAdvanced.visible = false
    
    local armyConf = TrainModel.GetConf(armyId)
    self.armyConf = armyConf
    local armyType = ConfigMgr.GetItem("configArmyTypes", armyConf.arm)
    self._iconDetail.icon = UITool.GetIcon(armyType.icon)
    --未解锁提示
    local values = {
        base_name = self.buildName,
        base_level = TrainModel.GetLevelById(armyId)
    }
    self._textUnlock.text = StringUtil.GetI18n(I18nType.Commmon, "Locked_Lock", values)

    local power = TrainModel.GetArmPower(armyId)
    self._textForce.text = power
    self._textForeSecurity.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Power") .. ": " .. power
    if self.isSecurityFactory then
        --[安保工厂 显示]
        self._armyTitle.text = TrainModel.GetName(armyId)
        local damage = armyConf.damage
        if damage then
            self._listRestraint.numItems = #damage
            for k, v in pairs(damage) do
                local typeConf = ConfigMgr.GetItem("configArmyTypes", v.A)
                local item = self._listRestraint:GetChildAt(k - 1)
                item.icon = UITool.GetIcon(typeConf.icon)
                item.title = TrainModel.GetArmyI18n(typeConf.i18n_name)
            end
        end
        --士兵数量
        local building = BuildModel.FindByConfId(Global.BuildingWall)
        local confWall = DetailModel.GetWallConf(building.ConfId + building.Level)
        local valuesNum = {
            num = TrainModel.GetArmAmount(armyId)
        }
        self._text.text = StringUtil.GetI18n(I18nType.Commmon, "UI_BASE_HAVE_VOLUME", valuesNum)
        local valuesTotal = {
            have_amount = Tool.FormatNumberThousands(TrainModel.GetArmyNumberByConfId(self.building.ConfId)),
            volume_amount = Tool.FormatNumberThousands(confWall.defense_limit + BuffModel.GetTrapLimit())
        }
        self._textTotal.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Have_Volume", valuesTotal)
    else
        --[士兵训练 显示]
        --兵种属性
        self._armyTitle.text = TrainModel.GetName(armyId)
        for i = 1, self._listAttributes.numChildren do
            local item = self._listAttributes:GetChildAt(i - 1)
            item:Init(i, armyId)
        end
        --技能图标
        local skillConf = armyType.skill_id
        for k, v in pairs(skillConf) do
            local item = self._listSkill:GetChildAt(k - 1)
            local conf = ConfigMgr.GetItem("configskills", v)
            item.icon = UITool.GetIcon(conf.icon)
            self["itemSkillId" .. k] = v
        end
        --士兵数量
        local valuesNum = {
            base_amount = TrainModel.GetArmAmount(armyId),
            have_amount = TrainModel.GetArmTotal(armyId)
        }
        self._text.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Base_Have", valuesNum)
        
        --兵种进阶按钮刷新
        self._btnAdvanced.visible, self.advancedArmyId = TrainModel.CheckAdvanced(self.armyId)
    end

    if self._ctr.selectedPage == CTR.ArmyTrain or self._ctr.selectedPage == CTR.SecurityTrain then
        return
    end

    --消耗资源初始化
    self.curRes = {}
    for _, v in pairs(self.armyConf.res_req) do
        local index = CommonType.SORT_RESOURCES[v.category]
        v.showAmount = v.amount
        if index <= self._resList.numChildren then
            if self.isSecurityFactory then
                v.showAmount = v.amount * BuffModel.GetTrapResExpend()
            end
            table.insert(self.curRes, {config = v, index = index})
        end
    end
    local isGuideShow = GuidePanelModel:IsGuideState(self.building, _G.GD.GameEnum.JumpType.Train)
    --训练数量
    if not isGuideShow then
        self._slideTrain:SetNumber(self.max)
    end
    self:UpdateData()
end

--训练数量刷新
function BuildTrain:UpdateData()
    if not self.armyId then
        return
    end
    local numTrain = self._slideTrain:GetNumber()
    --训练时间
    local buff = 1
    if self.isSecurityFactory then
        buff = BuffModel.GetTrapSpeed()
    else
        buff = BuffModel.GetArmySpeed(self.armyId)
    end
    local buffPreTime = self.armyConf.time * numTrain / (1 + self.trainSpeed)
    local trainTime = buffPreTime / buff
    trainTime = math.ceil(trainTime)
    self._textTrainTime.text = Tool.FormatTime(trainTime)
    --消耗资源数量
    local resGold = 0
    self.isResCond = true
    for _, v in pairs(self.curRes) do
        local item = self._resList:GetChildAt(v.index - 1)
        local num = v.config.amount * numTrain
        item:Init(v.config.category, num)
        item:SetBg(false)
        item:InitCb(
            function()
                self:UpdateArmy(self.armyId)
            end
        )
        local diffAmount = Model.Resources[v.config.category].Amount - num
        if diffAmount < 0 then
            self.isResCond = false
            resGold = resGold + Tool.ResTurnGold(v.config.category, -diffAmount)
        end
    end
    self.resGold = resGold
    --消耗金币数量
    local timeGold = Tool.TimeTurnGold(trainTime)
    self.goldNumber = timeGold + resGold
    self._textGold.text = UITool.UBBTipGoldText(self.goldNumber)
end

--刷新士兵训练中进度
function BuildTrain:UpdateTrain()
    if not self.event then
        return
    end
    local function get_time()
        return self.event.FinishAt - Tool.Time()
    end
    if get_time() <= 0 then
        BuildModel.GetObject(self.building.Id):TrainAnim(true)
        self:Close()
        return
    end
    if self.time_func then
        self:UnSchedule(self.time_func)
    end
    local values = {
        name = TrainModel.GetName(self.event.ConfId)
    }
    local i18n = self.isSecurityFactory and "Ui_Making_Army" or "Ui_Training_Army"
    self._textAccIng.text = StringUtil.GetI18n(I18nType.Commmon, i18n, values)
    local bar_func = function()
        local t = get_time()
        self._slideAccTime.value = (1 - t / self.event.Duration) * 100
        self._textAccTime.text = Tool.FormatTime(t)
        --消耗金币数量
        local gold = Tool.TimeTurnGold(t)
        if self.goldNumber ~= gold then
            self.goldNumber = gold
            self._textGold.text = UITool.UBBTipGoldText(self.goldNumber)
        end
    end
    bar_func()
    self.time_func = function()
        if get_time() >= 0 then
            bar_func()
            return
        end
        BuildModel.GetObject(self.building.Id):TrainAnim(true)
        self:Close()
    end
    self:Schedule(self.time_func, 1)
end

--长按提示框显示
function BuildTrain:LongPressShow()
    self._longPressLabel:SetVisible(false)
    self._longPressIcon:SetVisible(false)
    --技能描述
    for i = 1, self._listSkill.numChildren do
        local item = self._listSkill:GetChildAt(i - 1)
        self:AddListener(item.onTouchBegin,
            function()
                local conf = ConfigMgr.GetItem("configskills", self["itemSkillId" .. i])
                local title = TrainModel.GetSkillI18n(conf.i18n_name)
                local content = TrainModel.GetSkillI18n(conf.i18n_desc)
                self._longPressIcon:InitIcon(item.icon, title, content)
                self._longPressIcon:SetVisible(true)
                local arrowX = 80 + (i - 1) * (item.width + 25)
                self._longPressIcon:SetArrowPosX(arrowX)
            end
        )
        self:AddListener(item.onTouchEnd,
            function()
                self._longPressIcon:SetVisible(false)
            end
        )
    end
    --兵种描述
    self:AddListener(self._iconDetail.onTouchBegin,
        function()
            local armyConf = TrainModel.GetConf(self.armyId)
            local armyType = ConfigMgr.GetItem("configArmyTypes", armyConf.arm)
            local title = TrainModel.GetArmyI18n(armyType.i18n_name)
            local content = TrainModel.GetArmyI18n(armyType.i18n_desc)
            self._longPressLabel:InitLabel(title, content)
            self._longPressLabel:SetVisible(true)
        end
    )
    self:AddListener(self._iconDetail.onTouchEnd,
        function()
            self._longPressLabel:SetVisible(false)
        end
    )
end

--训练士兵
function BuildTrain:OnTrain(isNow)
    if not self.armyId or self.armyId == 0 then
        Log.Warning("训练兵种的id有误 self.armyId: {0}", self.armyId)
        return
    end
    local numTrain = self._slideTrain:GetNumber()
    if numTrain == 0 then
        return
    end
    local net_func = function(rsp)
        if rsp.ResAmounts then
            Event.Broadcast(EventDefines.UIResourcesAmount, rsp.ResAmounts)
        end
        if rsp.Event then
            Model.Create(ModelType.TrainEvents, rsp.Event.Uuid, rsp.Event)
        end
        if rsp.Army then
            Model.Create(ModelType.Armies, rsp.Army.ConfId, rsp.Army)
        end
        if rsp.Gem then
            Event.Broadcast(EventDefines.UIGemAmount, rsp.Gem)
        end
        local node = BuildModel.GetObject(self.building.Id)
        node:ResetCD()

        --保存训练记录 下次打开界面显示上次训练兵种
        self.record[tostring(self.building.ConfId)] = self._slideArmy:GetSlideIndex()
        PlayerDataModel:SetData(PlayerDataEnum.TRAIN_RECORD, self.record)
        self.unlock[tostring(self.building.ConfId)] = self.unlockI
        PlayerDataModel:SetData(PlayerDataEnum.TRAIN_UNLOCK, self.unlock)

        SdkModel.TrackBreakPoint(10058)      --打点

        if isNow then
            local values = {
                army_level = TrainModel.GetConf(rsp.Army.ConfId).level,
                army_name = TrainModel.GetName(rsp.Army.ConfId)
            }
            local icon = TrainModel.GetConf(rsp.Army.ConfId).army_model
            TipUtil.TipById(self.isSecurityFactory and 30106 or 30104, values, icon)
            self:UpdateBaseData(self.building)
            if CommonModel.IsTrainFactory(self.building.ConfId) then
                local args = {
                    building = self.building,
                    amount = numTrain,
                    confId = rsp.Army.ConfId
                }
                AnimationArmyQueue:Push(args)
            end
        else
            self:Close()
            node:TrainArmyStartAnim()
        end
    end
    Net.Armies.Train(self.armyId, numTrain, isNow, net_func)
end
--点击金币训练按钮
function BuildTrain:OnBtnGoldTrainClick()
    if self.goldNumber > Model.Player.Gem then
        UITool.GoldLack()
        return
    end
    local values = {
        diamond_num = self.goldNumber
    }
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "Ui_CompleteNow_Train", values),
        tipType = TipType.TYPE.ConditionTrain,
        gold = self.goldNumber,
        sureCallback = function()
            self:UpdateData()
            self:OnTrain(true)
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end
--资源不足提示
function BuildTrain:OnResPopup()
    local lackRes = {}
    local needResList = {}
    local canUseItemToFill = true
    for i = 1, self._resList.numChildren do
        local item = self._resList:GetChildAt(i - 1)
        local category = item:GetCategory()
        local diffAmount = item:GetAmount() - Model.Resources[category].Amount
        if diffAmount > 0 then
            if not GD.ItemAgent.CanBackPackItemFillResNeed(category,diffAmount) then
                canUseItemToFill = false
            end
            table.insert(lackRes, {Category = category, Amount = diffAmount})
            table.insert(needResList, {resType = category, needCount = diffAmount})
        end
    end
    if not canUseItemToFill then
        local i18n = self.isSecurityFactory and "BUTTON_PRODUCE" or "BUTTON_TRAIN"
        local data = {
            textTip = StringUtil.GetI18n(I18nType.Commmon, "Tech_Res_Text6"),
            lackRes = lackRes,
            textBtnSure = StringUtil.GetI18n(I18nType.Commmon, i18n),
            cbBtnSure = function()
                self:OnTrain(false)
            end
        }
        UIMgr:Open("ConfirmPopupDissatisfaction", data)
    else
        UIMgr:Open("ComfirmPopupUseRes", needResList,function()
                self:OnTrain(false)
            end)
    end
end
--点击时间训练按钮
function BuildTrain:OnBtnTimeTrainClick()
    if not self.isResCond then
        self:OnResPopup()
    else
        self:OnTrain(false)
    end
end
--点击金币加速训练按钮
function BuildTrain:OnBtnGoldAccClick()
    if self.goldNumber > Model.Player.Gem then
        UITool.GoldLack()
        return
    end
    local net_func = function(rsp)
        EventModel.SetTrainEnd(rsp.EventId)
        BuildModel.GetObject(self.building.Id):TrainAnim(true)
        self:Close()
    end
    Net.Events.Speedup(self.event.Category, self.event.Uuid, net_func)
end
--点击道具加速训练按钮
function BuildTrain:OnBtnPropAccClick()
    local acc_func = function(flag)
        if not flag then
            return
        end
        self.event = EventModel.GetTrainEvent(self.building.ConfId)
        self:UpdateTrain()
    end
    UIMgr:Open("BuildAcceleratePopup", self.building, acc_func)
end
--点击[训练工厂增加训练上限/安保工厂显示防御武器介绍]
function BuildTrain:OnBtnIncreateTrainClick()
    if self.isSecurityFactory then
        local data = {
            title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
            info = StringUtil.GetI18n(I18nType.Commmon, "Defense_Weapon_Explain")
        }
        UIMgr:Open("ConfirmPopupTextList", data)
    end
end

--点击左箭头
function BuildTrain:OnBtnArrowLeftClick()
    if self._ctr.selectedPage == CTR.ArmyNormal or self._ctr.selectedPage == CTR.SecurityNormal then
        self:OnBtnGoldTrainClick()
    elseif self._ctr.selectedPage == CTR.ArmyTrain or self._ctr.selectedPage == CTR.SecurityTrain then
        self:OnBtnGoldAccClick()
    end
end
--点击右箭头
function BuildTrain:OnBtnArrowRigthClick()
    if self.building.ConfId == 423000 then --坦克工厂(步)
        AudioModel.Play(50001)
    elseif self.building.ConfId == 424000 then --战车工厂(步)
        AudioModel.Play(50002)
    elseif self.building.ConfId == 425000 then --直升机工厂 (步)
        AudioModel.Play(50003)
    elseif self.building.ConfId == 426000 then --重型载具工厂(步)
        AudioModel.Play(50004)
    end
    if self._ctr.selectedPage == CTR.ArmyNormal or self._ctr.selectedPage == CTR.SecurityNormal then
        self:OnBtnTimeTrainClick()
    elseif self._ctr.selectedPage == CTR.ArmyTrain or self._ctr.selectedPage == CTR.SecurityTrain then
        self:OnBtnPropAccClick()
    end
end

--点击兵种详情按钮
function BuildTrain:OnBtnDetailClick()
    if self.isSecurityFactory then
        --安保工厂
        UIMgr:Open("TrainRelated/CityDefenseAttribute", self.armyId)
    else
        --训练工厂
        local armIds = {}
        local index = 1
        local arm = TrainModel.GetArm(self.building.ConfId)
        for i = 1, arm.amount do
            local confId = arm.base_level + i - 1
            table.insert(armIds, confId)
            if confId == self.armyId then
                index = i
            end
        end
        UIMgr:Open("TroopsDetailsPopup", armIds, index)
    end
end

--点击安保工厂详情解释
function BuildTrain:OnBtnExplainClick()
    local data = {
        title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
        info = StringUtil.GetI18n(I18nType.Commmon, "Defense_Weapon_Explain")
    }
    UIMgr:Open("ConfirmPopupTextList", data)
end

function BuildTrain:GuildShow()
    local tempBtn = nil
    if self._ctr.selectedPage == CTR.ArmyNormal or self._ctr.selectedPage == CTR.SecurityNormal then
        tempBtn = self.goldNumber == 0 and self._btnL or self._btnR
    elseif self._ctr.selectedPage == CTR.ArmyTrain or self._ctr.selectedPage == CTR.SecurityTrain then
        tempBtn = self.goldNumber == 0 and self._btnL or self._btnR
    elseif self._ctr.selectedPage == CTR.ArmyLock or self._ctr.selectedPage == CTR.SecurityLock then
        tempBtn = self._btnU
    else
        tempBtn = self._btnClose
    end
    return tempBtn
end

--指定训练兵种和数量
function BuildTrain:OnTrainArmyAmount()
    if not self.args then
        return
    end
    if self.args.ConfId ~= self.building.ConfId then
        return
    end

    if self.isSecurityFactory then
        --安保工厂
        self._slideArmy:SetSecurityFactoryUnlock()
        local amount = self.max
        if self.args.Amount then
            amount = self.args.Amount < self.max and self.args.Amount or self.max
        end
        self._slideTrain:SetNumber(amount)
    else
        --训练工厂
        if not self.args.ArmyId then
            self._slideArmy:SetSecurityFactoryUnlock()

            self._slideTrain:SetNumber(self.max)
        else
            local amount = self.args.Amount < self.max and self.args.Amount or self.max
            self._slideArmy:SetArmyAmount(self.args.ArmyId)
            self._slideTrain:SetNumber(amount)
        end
    end
    self:UpdateData()
end

return BuildTrain
