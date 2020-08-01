--[[
    Author: songzeming
    Function: 道具加速界面 通用
]]
local GD = _G.GD
local BuildAcceleratePopup = UIMgr:NewUI("BuildAcceleratePopup")

local BuildModel = import("Model/BuildModel")
local CommonModel = import("Model/CommonModel")
local EventModel = import("Model/EventModel")
local PropModel = import("Model/PropModel")
local MonsterHospital = import("UI/Monster/MonsterHospital")
local UIType = _G.GD.GameEnum.UIType
local GuidePanelModel = import("Model/GuideControllerModel")
local BarMoveSpeed = 0.3
local EquipModel = _G.EquipModel
local isUseReconmd =false -- 是否使用推荐列表的道具计算
local CONTROLLER = {
    Normal = "Normal", -- 有道具
    No = "No" -- 没有道具
}

function BuildAcceleratePopup:OnInit()
    local view = self.Controller.contentPane
    self._controller = view:GetController("Controller")
    GuidePanelModel:SetParentUI(self, UIType.BuildAccelerateUI)
    self:AddListener(self._arrowLeft.onClick,
        function()
            self:ArrowFunc(-1)
        end
    )
    self:AddListener(self._arrowRight.onClick,
        function()
            self:ArrowFunc(1)
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            self:Close()
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._btnUse.onClick,
        function()
            self:ClickUse()
            Event.Broadcast(EventDefines.CloseGuide)
            if self.triggerFunc then
                self.triggerFunc()
            end
        end
    )
    self:AddListener(self._btnDirectUse.onClick,
        function()
            self:OnBtnDirUseClick()
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self._goldText = self._btnAccelerate:GetChild("text")
    self:AddListener(self._btnAccelerate.onClick,
        function()
            self:ClickAccelerate()
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._btnAccess.onClick,
        function()
            TipUtil.TipById(50259)
        end
    )
end

function BuildAcceleratePopup:OnOpen(building, callback, noItemCb)
    self.callback = callback
    self.noItemCb = noItemCb
    self.building = building
    self.event = EventModel.GetEvent(self.building)
    if self.event then
        self._btnAccelerate.touchable = true
        self._btnUse.touchable = true
        self._timeBar.value = (1 - (self.event.FinishAt - Tool.Time()) / self.event.Duration) * 100

        self.chooseIndex = nil
        self:ResetData(true)
        local isGuideShow = GuidePanelModel:IsGuideState(self.building, _G.GD.GameEnum.JumpType.Speed)
        if isGuideShow == true then
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BuildAccelerateUI)
        end
    else
        self:Close()
    end
end

function BuildAcceleratePopup:Close(flag)
    self.cbFlag = flag
    UIMgr:Close("BuildAcceleratePopup")
end

function BuildAcceleratePopup:OnClose()
    if self.count_down_func then
        self:UnSchedule(self.count_down_func)
    end
    if self.callback then
        self.callback(self.cbFlag)
    end
    if UIMgr:GetUIOpen("ConfirmPopup") then
        UIMgr:Close("ConfirmPopup")
    end
end

function BuildAcceleratePopup:GetFreetime()
    if BuildModel.FreeState(self.category) then
        return CommonModel.FreeTime()
    end
    return 0
end

function BuildAcceleratePopup:ResetData(isInit)
    if self.count_down_func then
        self:UnSchedule(self.count_down_func)
    end
    self.event = EventModel.GetEvent(self.building)
    if not self.event then
        return
    end
    self.category = self.event.Category
    self.goalItem = PropModel.GetAccItemsByCategory(self.category, self.building.ConfId)
    if self.category == EventType.B_BUILD then
        if self.building.Level == 0 then
            self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Title_Build_Building")
        else
            self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Title_Build_Upgrade")
        end
    elseif self.category == EventType.B_DESTROY then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Title_Build_Remove")
    elseif self.category == EventType.B_TRAIN then
        if self.building.ConfId == Global.BuildingSecurityFactory then
            self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Title_Build_Make")
        else
            self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Title_Build_Train")
        end
    elseif self.category == EventType.B_TECH then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Title_Build_Study")
    elseif self.category == EventType.B_CURE then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Title_Queue_Treatment")
    elseif self.category == EventType.B_BEASTTECH then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Title_Build_Study")
    elseif self.category == EventType.B_BEASTCURE then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Title_Queue_Treatment_Beast")
    elseif self.category == EventType.B_EQUIPTRAN then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "equip_ui_14_2")
    end

    self.comItem = PropModel.GetCommonAccItems()
    self:SortAmount()
    self.items = Tool.MergeTables(self.goalItem, self.comItem)

    local time = self.event.FinishAt - Tool.Time()
    self.leftTime = time
    self:CountDown(time)
    if not self.items or next(self.items) == nil then
        --没有道具 弹窗提示
        self:Close()
        if isInit then
            UIMgr:Open("AccessWay", Global.GetmoreItemAccelerate, self.noItemCb)
        end
        return
    end
    if isInit then
        AnimationLayer.PanelScaleOpenAnim(self)
    end
    self._controller.selectedPage = CONTROLLER.Normal
    self.items = PropModel.Resort(self.items)

    self._list.numItems = #self.items
    for k, v in ipairs(self.items) do
        local node = self._list:GetChildAt(k - 1)
        local confItem = ConfigMgr.GetItem("configItems", v.ConfId)
        local title = GD.ItemAgent.GetItemNameByConfId(v.ConfId)
        node:SetAmount(confItem.icon, confItem.color, v.Amount, title)
        node:SetChoose(k == 1)
        node:ClickCB(
            function()
                if node:GetChoose() then
                    return
                end
                isUseReconmd = false
                self:ChooseItem(k)
            end
        )
    end
    self:RecommendChoose()
end

--显示加速时间和免费时间
function BuildAcceleratePopup:ShowAccTime(accTime)
    local value1 = {
        speed_time = accTime
    }
    if self:GetFreetime() > 0 then
        local value2 = {
            free_time = math.floor(self:GetFreetime() / 60)
        }
        local desc1 = StringUtil.GetI18n(I18nType.Commmon, "UI_Speed_Time", value1)
        local desc2 = StringUtil.GetI18n(I18nType.Commmon, "UI_Free_Time", value2)
        self._accTime.text = desc1 .. desc2
    else
        self._accTime.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Speed_Time", value1)
    end
end

function BuildAcceleratePopup:SortAmount()
    table.sort(
        self.goalItem,
        function(a, b)
            return a.value < b.value
        end
    )
    table.sort(
        self.comItem,
        function(a, b)
            return a.value < b.value
        end
    )
end

function BuildAcceleratePopup:useDataHandle(items,RecommendTable)
    local tempObj
    local cdNum = 0
    local acount = 0
    for i, v in pairs(RecommendTable) do
        if(i > cdNum)then
            cdNum = i
            acount = v
        end
    end
    for k, v in pairs(items) do
        if(v.value == cdNum)then
            if(v.Amount >= acount)then
                return  {ConfId = v.ConfId, Amount = acount, value = v.value}
            else
                return {ConfId = v.ConfId, Amount = v.Amount, value = v.value}
            end
        end
    end
end

function BuildAcceleratePopup:RecommendChoose()
    --end
    local _accTime = self.event.FinishAt - Tool.Time()-self:GetFreetime()
    local choose_func = function(items)
        local use = self:useDataHandle(items,PropModel.OnPropDirUseRecommend(items,_accTime))
        isUseReconmd = true
        if(use)then
            self.max = use.Amount
            for k, v in ipairs(items) do
                if v.ConfId == use.ConfId then
                    self:SetScrollPanePercX(k)
                    self:ChooseItem(k)
                    return
                end
            end
            self:SetScrollPanePercX(#items)
            self:ChooseItem(#items)
        end
    end
    choose_func(self.items)
end


function BuildAcceleratePopup:ChooseItem(index)
    self.chooseIndex = index
    for i = 1, self._list.numChildren do
        local child = self._list:GetChildAt(i - 1)
        child:SetChoose(false)
    end
    self._list:GetChildAt(index - 1):SetChoose(true)
    self:AccTime()
end

function BuildAcceleratePopup:CountDown(time)
    if time < 0 then
        return
    end
    local bar_func = function(t)
        -- self._timeBar.value = (1 - t / self.event.Duration) * 100
        self._timeBar:TweenValue((1 - t / self.event.Duration) * 100, BarMoveSpeed)
        self._updateTime.text = Tool.FormatTime(t)
        self.goldSpend = Tool.TimeTurnGold(t, self:GetFreetime())
        self._goldText.text = UITool.UBBTipGoldText(self.goldSpend)
        self:AccTime()
    end
    bar_func(time)
    self.count_down_func = function()
        time = time - 1
        self.leftTime = time
        if time >= 0 then
            bar_func(time)
            return
        end
        self:Close()
    end
    self:Schedule(self.count_down_func, 1)
end

function BuildAcceleratePopup:AccTime()
    if not self.chooseIndex then
        return
    end
    local item = self.items[self.chooseIndex]
    if not item then
        return
    end
    local time = item.value
    local k
    local _accTime = self:GetAccTime()
    if _accTime <= 0 then
        self:UnSchedule(self.count_down_func)
        self.closeFunc = function()
            self:UnSchedule(self.closeFunc)
            self._btnAccelerate.touchable = false
            self._btnUse.touchable = false
            self:Close()
        end
        self:Schedule(self.closeFunc, 0, false, BarMoveSpeed)
        return
    end
    for i = 1, item.Amount do
        if time * i >= _accTime then
            k = i
            break
        end
    end
    
    if(not isUseReconmd)then
        if time == 60 then
            self.max = k and k or item.Amount
        elseif time == 5 * 60 then
            self.max = k and k or item.Amount
        else
            self.max = k and (k - 1 <= 1 and 1 or k - 1) or item.Amount
        end
    end
    local totalTime = time * self.max
    local currentTime = time
    if self.totalTime == totalTime and self.currentTime == currentTime then
        return
    end
    self.totalTime = totalTime
    self.currentTime = currentTime
    self._slide:Init(
        "Normal",
        1,
        self.max,
        function()
            self:SetAccPropTime()
        end
    )
    self._slide:SetNumber(self.max)
    self:SetAccPropTime()
end

function BuildAcceleratePopup:SetAccPropTime()
    local item = self.items[self.chooseIndex]
    local accTime = item.value * self._slide:GetNumber()
    self:ShowAccTime(Tool.FormatTime(accTime))
end

function BuildAcceleratePopup:ArrowFunc(dir)
    local mvIndex = self.chooseIndex + dir
    local num = self._list.numChildren
    mvIndex = mvIndex < 1 and 1 or (mvIndex > num and num or mvIndex)
    self:SetScrollPanePercX(mvIndex)
    self:ChooseItem(mvIndex)
end

-- 道具加速成功
function BuildAcceleratePopup:AccPropSuccess(rsp)
    local leftTime = rsp.FinishAt - Tool.Time()
    if self.category == EventType.B_BUILD or self.category == EventType.B_DESTROY or self.category == EventType.B_TECH or self.category == EventType.B_BEASTTECH then
        if leftTime <= 0 then
            Model.Delete(ModelType.UpgradeEvents, rsp.Uuid)
        else
            Model.Update(ModelType.UpgradeEvents, rsp.Uuid, rsp)
        end
    elseif self.category == EventType.B_TRAIN then
        Model.Update(ModelType.TrainEvents, rsp.Uuid, rsp)
    elseif self.category == EventType.B_CURE then
        Model.Update(ModelType.CureEvents, rsp.Uuid, rsp)
    elseif self.category == EventType.B_BEASTCURE then
        Model.Update(ModelType.BeastCureEvents, rsp.Uuid, rsp)
    elseif self.category == EventType.B_EQUIPTRAN then
        rsp.Category = self.category
        EquipModel.UpdateEquipEvent(rsp)
    end

    if leftTime > 0 then
        self:ResetData(false)
        if self.category == EventType.B_CURE then
            BuildModel.CheckBuildHospital()
        else
            BuildModel.GetObject(self.building.Id):ResetCD()
        end
        if self.callback then
            self.callback(true)
        end
    else
        self:UnSchedule(self.count_down_func)
        self._timeBar:TweenValue(100, BarMoveSpeed)
        self.closeFunc = function()
            self:UnSchedule(self.closeFunc)
            self._btnAccelerate.touchable = false
            self._btnUse.touchable = false
            self:Close()
            local buildObj = BuildModel.GetObject(self.building.Id)
            if buildObj then
                if self.category == EventType.B_BUILD then
                    buildObj:UpgradeEnd(rsp.UpgradeTo)
                elseif self.category == EventType.B_DESTROY then
                    buildObj:RemoveEnd()
                elseif self.category == EventType.B_TRAIN then
                    buildObj:TrainAnim(true)
                elseif self.category == EventType.B_TECH then
                    Model.Update(ModelType.Techs, rsp.TargetId, {Level = rsp.UpgradeTo})
                    buildObj:TechEnd(rsp.TargetId)
                elseif self.category == EventType.B_CURE then
                    --已在通知中处理
                elseif self.category == EventType.B_BEASTTECH then
                    Model.Update(ModelType.BeastTechs, rsp.TargetId, {Level = rsp.UpgradeTo})
                    buildObj:TechEnd(rsp.TargetId)
                elseif self.category == EventType.B_BEASTCURE then
                    MonsterHospital:Doclose()
                elseif self.category == EventType.B_EQUIPTRAN then
                    EquipModel.SetEquipEventEnd(rsp.EventId)
                    local typeConfig = EquipModel.GetEquipTypeById(EquipModel.QualityID2TypeID(rsp.EquipId))
                    buildObj:EquipMakeAnim(true, typeConfig.icon)
                    if self.callback then
                        self.callback(false)
                    end
                end
            end
        end
        self:Schedule(self.closeFunc, 0, false, BarMoveSpeed)
    end
end

-- 点击使用道具
function BuildAcceleratePopup:ClickUse()
    local num = self._slide:GetNumber()
    if num == 0 then
        return
    end
    local item = self.items[self.chooseIndex]
    if not item then
        return
    end
    local accTime = self:GetAccTime()
    local isFar = PropModel.CheckFarTime(item.value, accTime)
    local use_func = function()
        local data = {
            {
                ConfId = item.ConfId,
                Amount = num
            }
        }
        Net.Events.SpeedupByItem(
            self.category,
            self.event.Uuid,
            data,
            function(rsp)
                self:AccPropSuccess(rsp)
            end
        )
    end
    if isFar then
        local values = {
            minute = math.floor((item.value * num - accTime) / 60)
        }
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Ui_OverTime", values),
            sureCallback = use_func
        }
        UIMgr:Open("ConfirmPopupText", data)
        return
    end
    use_func()
end

-- 金币加速
function BuildAcceleratePopup:ClickAccelerate()
    if Model.Player.Gem < self.goldSpend then
        UITool.GoldLack()
        return
    end

    local buildObj = BuildModel.GetObject(self.building.Id)
    local contentText, over_func, tipType
    if self.category == EventType.B_BUILD then
        tipType = TipType.TYPE.ConditionUpgrade
        contentText = "Ui_CompleteNow_Up"
        over_func = function(rsp)
            Model.Delete(ModelType.UpgradeEvents, rsp.EventId)
            buildObj:UpgradeEnd(rsp.BuildingLevel)
        end
    elseif self.category == EventType.B_DESTROY then
        tipType = TipType.TYPE.ConditionDestroy
        contentText = "Ui_CompleteNow_dismantle"
        over_func = function(rsp)
            Model.Delete(ModelType.UpgradeEvents, rsp.EventId)
            buildObj:RemoveEnd()
        end
    elseif self.category == EventType.B_TRAIN then
        tipType = TipType.TYPE.ConditionTrain
        contentText = "Ui_CompleteNow_Train"
        over_func = function(rsp)
            buildObj:TrainAnim(true)
            EventModel.SetTrainEnd(rsp.EventId)
        end
    elseif self.category == EventType.B_TECH then
        tipType = TipType.TYPE.ConditionTech
        contentText = "Ui_CompleteNow_Tech"
        over_func = function(rsp)
            Model.Delete(ModelType.UpgradeEvents, rsp.EventId)
            Model.Update(ModelType.Techs, rsp.ConfId, {Level = rsp.TechLevel})

            -- 显示科技完成奖励气泡
            for _, v in pairs(Model.Buildings) do
                if v.ConfId == Global.BuildingScience then
                    BuildModel.GetObject(v.Id):ScienceAwardAnim(true)
                end
            end

            buildObj:TechEnd(rsp.ConfId)
        end
    elseif self.category == EventType.B_CURE then
        tipType = TipType.TYPE.ConditionCure
        contentText = "Ui_CompleteNow_Treatment"
        over_func = function(rsp)
            Model.Delete(ModelType.CureEvents, rsp.EventId)
            for _, v in pairs(rsp.Armies) do
                Model.Create(ModelType.Armies, v.ConfId, v)
            end
            for _, v in pairs(Model.Buildings) do
                if v.ConfId == Global.BuildingHospital then
                    BuildModel.GetObject(v.Id):CureEnd()
                end
            end
        end
    elseif self.category == EventType.B_BEASTTECH then
        tipType = TipType.TYPE.ConditionBeastTech
        contentText = "Ui_CompleteNow_Tech"
        over_func = function(rsp)
            Model.Delete(ModelType.UpgradeEvents, rsp.EventId)
            Model.Update(ModelType.BeastTechs, rsp.ConfId, {Level = rsp.TechLevel})

            -- 显示科技完成奖励气泡
            for _, v in pairs(Model.Buildings) do
                if v.ConfId == Global.BuildingBeastScience then
                    BuildModel.GetObject(v.Id):ScienceAwardAnim(true)
                end
            end

            buildObj:TechEnd(rsp.ConfId)
        end
    elseif self.category == EventType.B_BEASTCURE then
        tipType = TipType.TYPE.ConditionBeastCure
        contentText = "Ui_CompleteNow_Treatment"
        over_func = function(rsp)
            Model.Delete(ModelType.BeastCureEvents, rsp.EventId)
            -- EventModel.SetCureMonsterEnd()
            MonsterHospital:Doclose()
            for _, v in pairs(Model.Buildings) do
                if v.ConfId == Global.BuildingBeastHospital then
                    BuildModel.GetObject(v.Id):CureEnd(true)
                end
            end
        end
    elseif self.category == EventType.B_EQUIPTRAN then
        tipType = TipType.TYPE.ConditionBeastCure
        contentText = "equip_ui_29_1"
        over_func = function(rsp)
            EquipModel.SetEquipEventEnd(rsp.EventId)
            if self.callback then
                self.callback(false)
            end
        end
    end
    local data = {
        content = contentText,
        gold = self.goldSpend,
        tipType = tipType,
        event = self.event,
        sureCallback = function()
            Net.Events.Speedup(
                self.event.Category,
                self.event.Uuid,
                function(rsp)
                    over_func(rsp)
                    self:Close(true)
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

-- 获取需要加速的时间
function BuildAcceleratePopup:GetAccTime()
    return self.leftTime - self:GetFreetime()
end

function BuildAcceleratePopup:SetScrollPanePercX(index)
    local item = self._list:GetChildAt(index - 1)
    self._list.scrollPane:ScrollToView(item, true)
end

-- 点击一键使用道具
function BuildAcceleratePopup:OnBtnDirUseClick()
    local data = {
        from = "PropDirUse",
        event = self.event,
        confId = self.building.ConfId,
        callback = function(rsp)
            if rsp then
                self:AccPropSuccess(rsp)
            else
                self:Close()
            end
        end
    }
    UIMgr:Open("ConfirmPopup", data)
end

function BuildAcceleratePopup:GuildShow()
    local tempBtn = nil
    if self.goldSpend == 0 then
        tempBtn = self._btnAccelerate
    else
        tempBtn = self._btnUse
    end
    return tempBtn
end

function BuildAcceleratePopup:TriggerOnclick(callback)
        self.triggerFunc = callback
end

return BuildAcceleratePopup
