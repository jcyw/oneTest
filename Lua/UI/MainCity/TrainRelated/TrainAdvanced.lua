--[[
    Author: xiaoze
    Function: 训练进阶
]]
local TrainAdvanced = UIMgr:NewUI("TrainRelated/TrainAdvanced")

local GD = _G.GD
local I18nType = _G.I18nType
local StringUtil = _G.StringUtil
local TipUtil = _G.TipUtil
local Tool = _G.Tool
local Model = _G.Model
local UITool = _G.UITool
local TipType = _G.TipType
local Event = _G.Event
local EventDefines = _G.EventDefines
local ModelType = _G.ModelType
local BuildModel = import("Model/BuildModel")
local TrainModel = import("Model/TrainModel")
local EventModel = import("Model/EventModel")
local BuffModel = import("Model/BuffModel")

function TrainAdvanced:OnInit()
    self._textTime = self._time:GetChild("time")
    self._textGold = self._btnUpgradeGold:GetChild("text")
    self._armyAttribute.touchable = false
    self._advancedArmyAttribute.touchable = false
    self._bg:GetChild("_icon").icon = UITool.GetIcon({ "falcon", "army_advanced_bg" })

    self:AddListener(self._btnReturn.onClick, function()
        self:Close()
    end)
    self:AddListener(self._btnUpgradeTime.onClick, function()
        self:OnBtnUpgradeTimeClick()
    end)
    self:AddListener(self._btnUpgradeGold.onClick, function()
        self:OnBtnUpgradeGoldClick()
    end)
    self:AddListener(self._btnDetail.onClick, function()
        self:OnBtnHelpClick()
    end)
end

function TrainAdvanced:OnOpen(armyId, advancedArmyId)
    self.armyId = armyId
    self.advancedArmyId = advancedArmyId

    if not armyId or not advancedArmyId then
        self:Close()
        Log.Error("兵种进阶数据传参错误 armyId:{0}, advancedArmyId:{1}", armyId, advancedArmyId)
        return
    end

    self._armyBox:SetArmyData(armyId)
    self._advancedArmyBox:SetArmyData(advancedArmyId)

    self._armyAttribute:SetArmyAttribute(armyId)
    self._advancedArmyAttribute:SetArmyAttribute(armyId)
    self._advancedArmyAttribute:SetArmyAttributeOver(advancedArmyId)

    self:RefreshAdvanced()
    self:RefreshRes()
end

local function GetArmyTrainTime(armyId, number)
    local conf = TrainModel.GetConf(armyId)
    local trainSpeed = BuildModel.GetTrainSpeed(armyId)
    local buffPreTime = conf.time * number / (1 + trainSpeed)
    local buff = BuffModel.GetArmySpeed(armyId)
    return buffPreTime / buff
end

function TrainAdvanced:RefreshRes()
    local resUnlock = GD.ResAgent.GetResUnlock()
    self._resList.numItems = #resUnlock

    self.resEnough = true
    self.canUseItemToFill = true
    self.resLack = {}
    self.resLackRe = {}
    local resGold = 0
    local resDiff = TrainModel.GetResDifferent(self.armyId, self.advancedArmyId)
    for k, category in pairs(resUnlock) do
        for _, vv in pairs(resDiff) do
            if vv.category == category then
                local item = self._resList:GetChildAt(k - 1)
                local amount = vv.amount * self._slideAdvanced:GetNumber()
                item:Init(category, amount)
                item:SetBg(false)
                item:InitCb(function()
                    self:RefreshRes()
                end)

                local amountDiff = Model.Resources[category].Amount - amount
                if amountDiff < 0 then
                    resGold = resGold + Tool.ResTurnGold(category, -amountDiff)
                    self.resEnough = false

                    if not GD.ItemAgent.CanBackPackItemFillResNeed(category, -amountDiff) then
                        self.canUseItemToFill = false
                    end
                    table.insert(self.resLack, { Category = category, Amount = -amountDiff })
                    table.insert(self.resLackRe, { resType = category, needCount = -amountDiff })
                end
            end
        end
    end

    --刷新资源消耗
    local trainNumber = self._slideAdvanced:GetNumber()
    local armyTime = GetArmyTrainTime(self.armyId, trainNumber)
    local advancedArmyTime = GetArmyTrainTime(self.advancedArmyId, trainNumber)
    local diffTime = math.ceil(advancedArmyTime - armyTime)
    self._textTime.text = Tool.FormatTime(diffTime)

    --刷新钻石消耗
    self.goldNumber = Tool.TimeTurnGold(diffTime) + resGold
    self._textGold.text = UITool.UBBTipGoldText(self.goldNumber)
end

function TrainAdvanced:RefreshAdvanced()
    local confId = TrainModel.GetBuildingConfIdByArmyId(self.armyId)
    local max = (BuildModel.GetTrainMaxNumber(confId) + BuffModel.GetArmyAmount()) * 2
    local armyAmount = TrainModel.GetArmAmount(self.armyId)
    if armyAmount <= 0 then
        self:Close()
        return
    end
    
    max = max < armyAmount and max or armyAmount
    local slide_func = function()
        self:RefreshRes()
    end
    self._slideAdvanced:Init("Army", 1, max, slide_func)
    self._slideAdvanced:SetNumber(max)
end

function TrainAdvanced:OnBtnUpgradeTimeClick()
    self:RefreshRes()
    local confId = TrainModel.GetBuildingConfIdByArmyId(self.armyId)
    if EventModel.GetTrainEvent(confId) then
        --训练队列不足
        TipUtil.TipById(50375)
        return
    end

    if not self.resEnough then
        --资源不足
        self:ResLackPopup()
        return
    end

    self:OnAdvanced(false)
end

function TrainAdvanced:OnBtnUpgradeGoldClick()
    self:RefreshRes()
    if self.goldNumber > Model.Player.Gem then
        --金币不足
        UITool.GoldLack()
        return
    end

    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "Ui_CompleteNow_Train", { diamond_num = self.goldNumber }),
        tipType = TipType.TYPE.ConditionAdvance,
        gold = self.goldNumber,
        sureCallback = function()
            self:OnAdvanced(true)
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

function TrainAdvanced:OnAdvanced(instant)
    _G.Net.Armies.Upgrade(self.armyId, self.advancedArmyId, self._slideAdvanced:GetNumber(), instant, function(rsp)
        Log.Info("士兵进阶成功: instant:{0}, rsp:{1}", instant, table.inspect(rsp))
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

        if instant then
            self:OnOpen(self.armyId, self.advancedArmyId)
        else
            self:Close()
            UIMgr:Close("BuildRelated/BuildTrain")
            BuildModel.GetObject(rsp.Event.BuildingId):ResetCD()
        end
    end)
end

--资源不足提示
function TrainAdvanced:ResLackPopup()
    if self.canUseItemToFill then
        UIMgr:Open("ComfirmPopupUseRes", self.resLackRe, function()
            self:OnBtnUpgradeTimeClick()
        end)
        return
    end

    local data = {
        textTip = StringUtil.GetI18n(I18nType.Commmon, "Tech_Res_Text6"),
        lackRes = self.resLack,
        textBtnSure = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_UPGRADE"),
        cbBtnSure = function()
            self:OnBtnUpgradeTimeClick()
        end
    }
    UIMgr:Open("ConfirmPopupDissatisfaction", data)
end

function TrainAdvanced:OnBtnHelpClick()
    local data = {
        title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
        info = StringUtil.GetI18n(I18nType.Commmon, "Meeting_Gift_EXPLAIN")
    }
    UIMgr:Open("ConfirmPopupTextCentered", data)
end

function TrainAdvanced:Close()
    UIMgr:Close("TrainRelated/TrainAdvanced")
end

function TrainAdvanced:OnClose()
end

return TrainAdvanced