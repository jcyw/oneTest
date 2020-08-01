--[[
    Author: songzeming
    Function: 治疗伤兵 联盟和城建
]]
local GD = _G.GD
local CureArmy = UIMgr:NewUI("CureRelated/CureArmy")

local TrainModel = import("Model/TrainModel")
local BuildModel = import("Model/BuildModel")
local BuffModel = import("Model/BuffModel")
import("UI/MainCity/CureRelated/ItemCureArmy")
import("UI/City/ItemResourcesCure")
local GuidePanelModel = import("Model/GuideControllerModel")
local UIType = _G.GD.GameEnum.UIType
local CHECK_STATE = {
    Clear = 1,
    Recommend = 2,
    All = 3
}

function CureArmy:OnInit()
    local view = self.Controller.contentPane
    self._ctrFrom = view:GetController("CtrFrom")
    self._ctrCure = view:GetController("CtrCure")
    GuidePanelModel:SetParentUI(self, UIType.CureArmyUI)
    self:AddListener(self._btnALL.onClick,
        function()
            self:OnCheckAllClick()
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._btnCure.onClick,
        function()
            if self.from == BuildType.CUREARMY.Build then
                self:CheckCureBuildArmy(false)
            elseif self.from == BuildType.CUREARMY.Union then
                self:CureUnionArmy(false)
            end
        end
    )
    self._textGold = self._btnGoldCure:GetChild("text")
    self:AddListener(self._btnGoldCure.onClick,
        function()
            if self.from == BuildType.CUREARMY.Build then
                self:CheckCureBuildArmy(true)
            elseif self.from == BuildType.CUREARMY.Union then
                self:CureUnionArmy(true)
            end
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._btnDetail.onClick,
        function()
            self:OnBtnDetailClick()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("CureRelated/CureArmy")
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )

    self:AddEvent(
        EventDefines.UIInjuredArmyDel,
        function()
            Event.Broadcast(EventDefines.UIInjuredArmyAmountExg)
            self:OnOpen(self.from, self.building)
        end
    )
    self:AddEvent(
        EventDefines.UIBuffUpdate,
        function()
            self:OnOpen(self.from, self.building)
        end
    )
end

function CureArmy:OnOpen(from, building)
    self._ctrFrom.selectedPage = from
    self.from = from
    self.building = building

    self.injuredArmies = {}
    for _, v in pairs(Model.InjuredArmies) do
        if v.Amount > 0 then
            table.insert(self.injuredArmies, v)
        end
    end
    TrainModel.SortArmy(self.injuredArmies)

    local unlockTable = GD.ResAgent.GetResUnlock()
    self._listRes.numItems = #unlockTable

    self.checkState = CHECK_STATE.Clear
    self:SetViewEnable(false)

    self:UpdateData()
    local isGuideShow = GuidePanelModel:IsGuideState(self.building, _G.GD.GameEnum.JumpType.Cure)
    if isGuideShow == true then
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.CureArmyUI)
    end
end

function CureArmy:UpdateData()
    if self.from == BuildType.CUREARMY.Build then
        self:BuildHospital()
        self:OnCheckAllClick()
    elseif self.from == BuildType.CUREARMY.Union then
        self._list.numItems = 0
        TipUtil.TipById(50259)
    end
end

--按钮显示状态
function CureArmy:SetViewEnable(flag)
    self._ctrCure.selectedPage = flag and "Normal" or "Gray"
    if not flag then
        self._textTime.text = "00:00:00"
        self._textGold.text = 0
        self._textCredit.text = "0/" .. Model.Player.Honor
    end
end

--点击复选框按钮
function CureArmy:OnCheckAllClick()
    if self.checkState == CHECK_STATE.Clear then
        --推荐
        local res = {0, 0, 0, 0}
        for i = 1, self._list.numChildren do
            local item = self._list:GetChildAt(i - 1)
            local army = item:GetArmy()
            local conf = TrainModel.GetConf(army.ConfId)
            for _, v in pairs(conf.res_req) do
                local k = v.category
                if not res[k] then
                    res[k] = 0
                end
                local expendRes = res[k] + math.ceil(army.Amount * v.amount * conf.heal_res / 1000)
                if expendRes > Model.Resources[k].Amount then
                    --资源不足 逐一检查
                    local count = 0
                    local function check_func(n)
                        if res[k] + math.ceil(n * v.amount * conf.heal_res / 1000) <= Model.Resources[k].Amount then
                            count = n + 1
                            check_func(count)
                        end
                    end
                    check_func(1)
                    if count == 0 then
                        self.isCureZero = true --是否资源不足 治疗0个士兵
                    else
                        self.isCureZero = false
                        item:SetChooseAmount(count - 1)
                    end
                    self.checkState = CHECK_STATE.Recommend
                    self:BuildUpdateExpend()
                    return
                else
                    res[k] = expendRes
                end
            end
            item:SetChooseAmount(army.Amount)
        end
        self.checkState = CHECK_STATE.Recommend
        self:OnCheckAllClick()
    elseif self.checkState == CHECK_STATE.Recommend then
        --全选
        self.checkState = CHECK_STATE.All
        for i = 1, self._list.numChildren do
            local item = self._list:GetChildAt(i - 1)
            item:SetChooseAmount(item:GetArmy().Amount)
        end
        self:BuildUpdateExpend()
    elseif self.checkState == CHECK_STATE.All then
        --清空
        if self.isCureZero then
            self.checkState = CHECK_STATE.Recommend
        else
            self.checkState = CHECK_STATE.Clear
        end
        for i = 1, self._list.numChildren do
            local item = self._list:GetChildAt(i - 1)
            item:SetChooseAmount(0)
        end
        self:BuildUpdateExpend()
    end
end

--资源不足提示
function CureArmy:OnResPopup()
    local lackRes = {}
    local needResList = {}
    local canUseItemToFill = true
    for i = 1, self._listRes.numChildren do
        local item = self._listRes:GetChildAt(i - 1)
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
        local data = {
            textTip = StringUtil.GetI18n(I18nType.Commmon, "Tech_Res_Text5"),
            lackRes = lackRes,
            textBtnSure = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CURE"),
            cbBtnSure = function()
                self:CureBuildArmy(false)
            end
        }
        UIMgr:Open("ConfirmPopupDissatisfaction", data)
    else
        UIMgr:Open("ComfirmPopupUseRes", needResList,function()
                self:CureBuildArmy(false)
            end)
    end
end

---------------------------------------------------------------- 战区医院
--战区医院
function CureArmy:BuildHospital()
    local desc = StringUtil.GetI18n(I18nType.Commmon, "Ui_Wounded_Numer")

    local all = BuildModel.GetAll(self.building.ConfId)
    local limit = Global.HospitalBaseLimit
    for _, v in pairs(all) do
        if v.Level > 0 then
            local conf = ConfigMgr.GetItem("configHospitals", v.ConfId + v.Level)
            limit = limit + conf.limit
        end
    end
    limit = (limit + BuffModel.GetCureArmyLimit()) * BuffModel.GetCureArmyLimitPerc()

    self._list.numItems = #self.injuredArmies
    local injured = 0
    for k, v in pairs(self.injuredArmies) do
        injured = injured + v.Amount
        local item = self._list:GetChildAt(k - 1)
        item:Init(
            v,
            function()
                self:BuildUpdateExpend()
            end
        )
    end
    self._textInjured.text = desc .. Tool.FormatNumberThousands(injured) .. "/" .. Tool.FormatNumberThousands(limit)
    if self._list.numChildren > 0 then
        self:SetViewEnable(true)
    end
end

--战区医院更新消耗
function CureArmy:BuildUpdateExpend()
    local armies = {}
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local choose = item:GetChoose()
        if choose.Amount > 0 then
            table.insert(armies, choose)
        end
    end

    local res = {0, 0, 0, 0}
    local time = 0
    for _, v in pairs(armies) do
        local conf = TrainModel.GetConf(v.ConfId)
        time = time + v.Amount * conf.time * conf.heal_time / 1000
        for _, vv in pairs(conf.res_req) do
            local key = vv.category
            if not res[key] then
                res[key] = 0
            end
            res[key] = math.ceil(res[key] + v.Amount * vv.amount * conf.heal_res / 1000)
        end
    end

    local condRes = true
    local resGold = 0
    for k, v in pairs(res) do
        local index = CommonType.SORT_RESOURCES[k]
        if index <= self._listRes.numChildren then
            local item = self._listRes:GetChildAt(index - 1)
            item:Init(k, math.ceil(v * BuffModel.GetCureArmyResExpend()))
            item:InitCb(
                function()
                    self:BuildUpdateExpend()
                end
            )
            local diffAmount = Model.Resources[k].Amount - v
            if diffAmount < 0 then
                condRes = false
                resGold = resGold + Tool.ResTurnGold(k, -diffAmount)
            end
        end
    end
    self.resGold = resGold

    if time > 0 and Model.Player.Level <= GlobalMisc.BattleCare_level_limit then
        time = GlobalMisc.BattleCare_cure_time
    end
    time = math.ceil(time / BuffModel.GetCureArmySpeed())
    local timeGold = Tool.TimeTurnGold(time)
    self.goldNumber = timeGold + resGold
    self.condGold = self.goldNumber <= Model.Player.Gem
    self.condRes = condRes
    self._textTime.text = Tool.FormatTime(time)
    self._textGold.text = UITool.UBBTipGoldText(self.goldNumber)

    self.chooseArmies = armies
end

--治疗战区医院士兵 检查是否可治疗
function CureArmy:CheckCureBuildArmy(flag)
    if next(self.chooseArmies) == nil then
        TipUtil.TipById(50109)
        return
    end
    if not flag and not self.condRes then
        self:OnResPopup()
        return
    end
    if flag and not self.condGold then
        UITool.GoldLack()
        return
    end
    self:CureBuildArmy(flag)
end

--治疗战区医院士兵
function CureArmy:CureBuildArmy(flag)
    local function net_func()
        Net.Armies.Cure(
            self.chooseArmies,
            flag,
            function(rsp)
                local cureArmies = {}
                for _, v in pairs(self.chooseArmies) do
                    cureArmies[v.ConfId] = v
                end
                local army_func = function(armies)
                    for _, v in pairs(armies) do
                        --伤兵变化
                        local totalAmount = Model.InjuredArmies[v.ConfId].Amount
                        local cureAmount = cureArmies[v.ConfId].Amount
                        if totalAmount > cureAmount then
                            Model.Update(ModelType.InjuredArmies, v.ConfId, {Amount = totalAmount - cureAmount})
                        else
                            Model.Delete(ModelType.InjuredArmies, v.ConfId)
                        end
                        Event.Broadcast(EventDefines.UIInjuredArmyAmountExg)

                        if flag then
                            --士兵变化
                            Model.Create(ModelType.Armies, v.ConfId, v)
                        end
                    end
                end
                if rsp.Event then
                    if rsp.Event.Armies then
                        army_func(rsp.Event.Armies)
                    end
                    Model.Create(ModelType.CureEvents, rsp.Event.Uuid, rsp.Event)
                    BuildModel.CheckBuildHospital()
                end
                if rsp.Armies then
                    army_func(rsp.Armies)
                end
                if rsp.ResAmounts then
                    Event.Broadcast(EventDefines.UIResourcesAmount, rsp.ResAmounts)
                end
                if rsp.Gem then
                    Event.Broadcast(EventDefines.UIGemAmount, rsp.Gem)
                end
                UIMgr:Close("CureRelated/CureArmy")
                if flag then
                    TipUtil.TipById(30008)
                end
            end
        )
    end
    if flag then
        local data = {
            content = StringUtil.GetI18n("configI18nCommons", "Ui_CompleteNow_Treatment"),
            tipType = TipType.TYPE.ConditionCure,
            gold = self.goldNumber,
            sureCallback = function()
                net_func()
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        net_func()
    end
end

---------------------------------------------------------------- 联盟医院
--联盟医院
function CureArmy:UnionHospital()
    self._list.numItems = 0
    local desc = StringUtil.GetI18n(I18nType.Commmon, "Ui_Wounded_Numer")
    local limit = Global.AllianceHospitalLimit
    --联盟医院我的伤兵信息
    Net.AllianceHospital.MyInfo(
        Model.Player.AllianceId,
        function(rsp)
            if not rsp.InjuredAlly or not rsp.InjuredAlly.Armies then
                return
            end
            self.armies = rsp.InjuredAlly.Armies
            local injured = 0
            for k, v in pairs(self.armies) do
                self._list:AddItemFromPool()
                injured = injured + v.Amount
                local item = self._list:GetChildAt(k - 1)
                item:Init(
                    v,
                    function()
                        self:UnionUpdateExpend()
                    end
                )
            end
            self:SetViewEnable(true)

            if injured > limit then
                injured = limit
            end
            self._textInjured.text = desc .. injured .. "/" .. limit
        end
    )
end

--联盟医院更新消耗
function CureArmy:UnionUpdateExpend()
    local armies = {}
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local choose = item:GetChoose()
        if choose.Amount > 0 then
            table.insert(armies, choose)
        end
    end
    local honor = 0
    local time = 0
    for _, v in pairs(armies) do
        local conf = TrainModel.GetConf(v.ConfId)
        honor = honor + conf.alliance_heal * v.Amount
        time = time + conf.heal_time * v.Amount
    end
    local gold = Tool.TimeTurnGold(time)
    self.condHonor = honor <= Model.Player.Honor
    self.condGold = gold <= Model.Player.Gem
    self._textCredit.text = honor .. "/" .. Model.Player.Honor
    self._textTime.text = Tool.FormatTime(time)
    self._textGold.text = UITool.UBBTipGoldText(gold)

    self.chooseArmies = armies
end

--治疗联盟医院士兵
function CureArmy:CureUnionArmy(flag)
    if not flag and not self.condHonor then
        TipUtil.TipById(50110)
        return
    end
    if flag and not self.condGold then
        UITool.GoldLack()
    end
    Net.AllianceHospital.Cure(
        self.chooseArmies,
        flag,
        function()
            UIMgr:Close("CureRelated/CureArmy")
            UIMgr:Close("UnionHospital/UnionHospital")
        end
    )
end

--点击详情按钮
function CureArmy:OnBtnDetailClick()
    local info
    if self.from == BuildType.CUREARMY.Build then
        info = StringUtil.GetI18n(I18nType.Commmon, "Hospital_Explain")
    elseif self.from == BuildType.CUREARMY.Union then
        info = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CURE_Tips")
    end
    local data = {
        title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
        info = info
    }
    UIMgr:Open("ConfirmPopupTextList", data)
end

--得到治疗页面按钮
function CureArmy:GuildShow()
    return self._btnCure
end


return CureArmy
