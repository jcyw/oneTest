--[[
    Author:muyu
    Function:巨兽医院
]]
local GD = _G.GD
local MonsterHospital = UIMgr:NewUI("MonsterHospital")
local monsterlist, returnmonster = {}

local MonsterModel = import("Model/MonsterModel")
local DetailModel = import("Model/DetailModel")
local TrainModel = import("Model/TrainModel")
local EventModel = import("Model/EventModel")
local GuidePanelModel = import("Model/GuideControllerModel")
local AnimationMonster = import("Model/Animation/AnimationMonster")
import("UI/City/ItemResourcesAdd")
local UIType = _G.GD.GameEnum.UIType
local BLANK_HALF = 1 --占位

local StateCTR = {
    SelectTreatmentVolume = "SelectTreatmentVolume", --选择治疗量
    Returning = "Returning", --正在治疗
    NoTreatmentRequired = "NoTreatmentRequired" --无需治疗
}

function MonsterHospital:OnInit()
    local view = self.Controller.contentPane
    GuidePanelModel:SetParentUI(self, UIType.CureMonsterUI)
    self.monsterlist = MonsterModel.GetMonsterList()
    self._bloodctr = view:GetController("BloodCtr")
    self._statectr = view:GetController("StateCtr")
    --按钮
    self._btnReturn = view:GetChild("btnReturn")
    self._btnHelp = view:GetChild("btnHelp")
    --图片显示
    self._icon = view:GetChild("icon")
    --暂时没配置
    self._textLevel = view:GetChild("textLevel")
    --文字显示
    self._textWarn = view:GetChild("textWarn")
    self._titleName = view:GetChild("titleName")
    self._titleName2 = view:GetChild("titleName2")
    self._textTagName = view:GetChild("textTagName")
    -- self._textCureName = view:GetChild("textCureName")
    self._textTime = view:GetChild("textTime")
    -- self._textSelectiveTreatment = view:GetChild("textSelectiveTreatment")
    self._bthCureNowtext = self._btnCureNow:GetChild("text")
    self._bthCuretitle = self._btnCure:GetChild("title")
    self._bthCureNowtitle = self._btnCureNow:GetChild("title")
    --巨兽列表相关
    self._list = view:GetChild("liebiao")
    self._list.itemRenderer = function(index, item)
        if index < BLANK_HALF or index > #monsterlist + BLANK_HALF - 1 then
            item.visible = false
            item.width = self._list.width / 2 - item.width / 2 - self._list.columnGap
        else
            local monster = monsterlist[index - BLANK_HALF + 1]
            item.visible = true
            item.width = 128
            item:Init(
                index - BLANK_HALF,
                monster,
                function()
                    self._list.scrollPane:SetPosX(item.x - self._list.viewWidth / 2 + item.width / 2, true)
                end
            )
        end
    end
    self._list:SetVirtual()

    self:AddListener(self._btnLeft.onClick,function()
        self:OnBtnArrowClick(-1)
        self._btnRight.visible = true
    end)
    self:AddListener(self._btnRight.onClick,function()
        self:OnBtnArrowClick(1)
        self._btnLeft.visible = true
    end)

    --巨兽治疗资源显示
    self._resList = view:GetChild("resList")
    --巨兽选择治疗量的ItemSlide
    self._slideTrain = view:GetChild("slideBlood")

    --巨兽的血条进度条
    self._bloodtext = view:GetChild("textBlood")

    --巨兽的治疗进度条
    self._returnBlood = view:GetChild("slideTime")

    --巨兽治疗完成通知
    self:AddEvent(
        EventDefines.UIBeastFinishCureRsp,
        function()
            --治疗完成后应该收到通知
            if UIMgr:GetUIOpen("MonsterHospital") then
                self:RefreshMonster()
            end
        end
    )

    self.effectNodeL = UIMgr:CreateObject("Effect", "EffectNode")
    self.effectNodeL.xy = Vector2(self._btnLeft.width,self._btnLeft.height)*0.5
    self._btnLeft:AddChild(self.effectNodeL)
    self.effectNodeL:PlayEffectLoop("effects/arrow_guide/prefab/effect_arrow_guide_p",Vector3.one,0)

    self.effectNodeR = UIMgr:CreateObject("Effect", "EffectNode")
    self.effectNodeR.xy = Vector2(self._btnRight.width,self._btnRight.height)*0.5
    self._btnRight:AddChild(self.effectNodeR)
    self.effectNodeR:PlayEffectLoop("effects/arrow_guide/prefab/effect_arrow_guide_p",Vector3.one,0)
    --按钮事件的调用
    self:InitEvent()
	self._loadProgress.visible = false
end

function MonsterHospital:OnClose()
    AnimationMonster.Clear()
    if self.cb then
        self.cb()
    end
end

function MonsterHospital:OnOpen(id, cb)
    self.cb = cb
    monsterlist = MonsterModel.GetMonsterList()

    -- 提取已解锁巨兽
    for k,v in pairs(monsterlist) do
		if not MonsterModel.IsUnlock(v.Id) then
			table.remove(monsterlist, k)
		end
	end
    table.sort(monsterlist, function(a, b)
		return a.Id < b.Id
    end)

    local index = nil
    if id then
        index = 0
        for _,v in pairs(monsterlist) do
            index = index + 1
            if v.Id == id then
                break;
            end
        end
    end
    
    --治疗事件
    self.event = EventModel.GetBeastCureEvent()

    --获取building
    for _, v in pairs(Model.Buildings) do
        if v.ConfId == Global.BuildingBeastHospital then
            self.building = v
        end
    end

    if #monsterlist > 1 then
        self._btnLeft.visible = (index and index > 1)
        self._btnRight.visible = (not index or index <= #monsterlist)
    else
        self._btnLeft.visible = false
        self._btnRight.visible = false
    end

    --获取是否有巨兽正在治疗
    self.isreturn = MonsterModel.GetIsHealing()
    if self.isreturn then
        self._statectr.selectedPage = StateCTR.Returning
    end

    --页面文字显示国际化
    self._textWarn.text = StringUtil.GetI18n(I18nType.Commmon, "UI_BEAST_HEALTHY")
    -- self._textSelectiveTreatment.text = StringUtil.GetI18n(I18nType.Commmon, "UI_CHOOSE_HP")

    self._bthCureNowtitle.text = StringUtil.GetI18n(I18nType.Commmon, "Button_Cure_Now")
    self._list.numItems = #monsterlist + BLANK_HALF * 2
    self._list:EnsureBoundsCorrect()
    self.showIndex = nil
    self:RefreshList()

    -- self._textCureName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_CURE_REST_TIME")
    if self.isreturn then
        self._bthCuretitle.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_ITEM_SPEED")
    else
        self._bthCuretitle.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CURE")
    end

    --如果不是治疗状态则显示以下信息
    local unlockTable = GD.ResAgent.GetResUnlock()
    self._resList.numItems = #unlockTable

    --设置当前页面血条显示最大值 -- 要排除正在治疗的状态
    self.max = MonsterModel.GetBloodMaxNumber(1)
    local slide_func = function()
        self:UpdateData()
    end
    self._slideTrain:Init("Lookup", 1, self.max, slide_func)

    --下方血量选择恢复条的控制
    self:SlideControl()
    self:SetListener(self._list.scrollPane.onScroll,
        function()
            self:SlideControl()
        end
    )

    if index then
        self:OnBtnArrowClick(index - self.itemIndex + 1)
    end

    local isGuideShow = GuidePanelModel:IsGuideState(self.building, _G.GD.GameEnum.JumpType.BeastCure)
    if isGuideShow == true then
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.CureMonsterUI)
    end
end

function MonsterHospital:InitEvent()
    self:AddListener(self._btnReturn.onClick,
        function()
            self:Doclose()
        end
    )
    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                info = StringUtil.GetI18n(I18nType.Commmon, "UI_BEAST_CURE_EXPLAIN")
            }
            UIMgr:Open("ConfirmPopupTextCentered", data)
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._btnCureNow.onClick,
        function()
            if self._statectr.selectedPage == StateCTR.SelectTreatmentVolume then
                self:CureMonster(true)
            else
                self:CureAccClick()
            end
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._btnCure.onClick,
        function()
            if self._statectr.selectedPage == StateCTR.SelectTreatmentVolume then
                self:OnResPopup()
            else
                self:CurePropAccClick()
            end
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
end

--点击金币加速训练按钮
function MonsterHospital:CureAccClick()
    if self.goldNumber > Model.Player.Gem then
        UITool.GoldLack()
        return
    end
    local net_func = function(rsp)
        Model.Delete(ModelType.BeastCureEvents, rsp.EventId)
        -- EventModel.SetCureMonsterEnd()
        MonsterModel.RefreshMonsterHealth(rsp.BeastId, rsp.HealHealth, false)
        Event.Broadcast(EventDefines.UIBeastFinishCureRsp, rsp)
        self:Doclose()
        for _, v in pairs(Model.Buildings) do
            if v.ConfId == Global.BuildingBeastHospital then
                BuildModel.GetObject(v.Id):CureEnd(true)
            end
        end
    end
    Net.Events.Speedup(self.event.Category, self.event.Uuid, net_func)
end

--点击道具加速训练按钮
function MonsterHospital:CurePropAccClick()
    local acc_func = function(flag)
        if not flag then
            return
        end
        self.event = EventModel.GetBeastCureEvent()
        self:UpdateCureData()
    end
    UIMgr:Open("BuildAcceleratePopup", self.building, acc_func)
end

--滑动控制 缩放/光圈显示/选中
function MonsterHospital:SlideControl()
    local center = self._list.scrollPane.posX + self._list.viewWidth / 2
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local iCenter = item.x + item.width / 2
        local distance = math.abs(center - iCenter)
        if distance < item.width / 2 + self._list.columnGap / 2 then
            self.itemIndex = i
            -- local scale = 1 + (item.width / (item.width + distance) - 0.5) * 0.1
            -- item:SetScale(scale, scale)
            local index = item:GetIndex()
            if index ~= self.showIndex then
                self.showIndex = index
                self.item = item
                self:HideLight()
                item:SetLight(true)
                -- item.y = item.y - 15
                item:TweenMoveY(item.y - 15, 0.3)
                --要在此处加入哥斯拉页面的显示数据控制
                self:RefreshMonster()
            end
        else
            -- item:SetScale(1, 1)
        end
    end
end

--隐藏光圈
function MonsterHospital:HideLight()
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        item:SetLight(false)
        item.y = 0
    end
end

--点击箭头滑动
function MonsterHospital:OnBtnArrowClick(dir)
    local index = self.itemIndex + dir
    if index > BLANK_HALF and index <= self._list.numChildren - BLANK_HALF then
        local itemIndex = self.itemIndex + dir - 1
        local item = self._list:GetChildAt(itemIndex)
        local mvx = item.x + item.width / 2 - self._list.viewWidth / 2
        self._list.scrollPane:SetPosX(mvx, true)
    end
    
    if index <= BLANK_HALF + 1 then
        self._btnLeft.visible = false
    elseif index >= self._list.numChildren - BLANK_HALF then
        self._btnRight.visible = false
    end
end

--刷新巨兽在医院界面的显示
function MonsterHospital:RefreshMonster()
    local monsterId = self.item:GetMonsterId()
    if not monsterId then
        return
    end

    local typeId = MonsterModel.GetMonsterTypeId(monsterId)
    local typeConfig = ConfigMgr.GetItem("configArmyTypes", typeId)
    self._bgBox.icon = UITool.GetIcon(typeConfig.beast_hospital)
	self._iconMonster.icon = UITool.GetIcon(typeConfig.icon)

    --目前配置表还没配 显示不出来 先做了特殊处理
    --local MonsterType = ConfigMgr.GetItem("configArmyTypes", typeId)
    --self._icon.icon = UITool.GetIcon(MonsterType.icon)
    -- self._textLevel.text = MonsterModel.GetLevelLabel(monsterId)
    self._titleName.text = TrainModel.GetName(monsterId)
    self._titleName2.text = TrainModel.GetDesc(monsterId)
    local percent = math.floor(MonsterModel.GetBloodPercent((self.item:GetIndex() + 1), 0))
    self.isreturn = MonsterModel.GetIsHealing()
    if not self.isreturn then
        if self.time_func then
            self:UnSchedule(self.time_func)
        end
        --百分比血量显示
        self._bloodctr.selectedPage = MonsterModel.GetBloodColor(percent)
        self.Controller.contentPane:GetChild("Blood" .. MonsterModel.GetBloodColor(percent)).value = percent
        self._bloodtext.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Health") .. " " .. percent .. "%"
        if percent == 100 then
            self._statectr.selectedPage = StateCTR.NoTreatmentRequired
        else
            self._statectr.selectedPage = StateCTR.SelectTreatmentVolume
            --消耗资源初始化
            self.curRes = {}
            --推荐治疗消耗资源量
            local res = {0, 0, 0, 0}
            self.monsterConf = TrainModel.GetConf(monsterId)
            for _, v in pairs(self.monsterConf.res_req) do
                local index = CommonType.SORT_RESOURCES[v.category]
                if index <= self._resList.numChildren then
                    local resv = {}
                    resv.category = v.category
                    resv.amount = v.amount * (self.monsterConf.heal_res / 100) / 1000
                    table.insert(self.curRes, {config = resv, index = index})
                    local k = v.category
                    if not res[k] then
                        res[k] = 0
                    end
                    res[k] = Model.Resources[v.category].Amount / resv.amount
                end
            end
            --治疗量最大值设置
            self.max = MonsterModel.GetBloodMaxNumber(self.item:GetIndex() + 1)
            self._slideTrain:SetMaxNumber(self.max)

            --设置推荐的治疗量
            local recommendCurenum = self.max

            for _, v in pairs(res) do
                if recommendCurenum > v and v ~= 0 then
                    recommendCurenum = math.floor(v)
                end
            end

            --设置治疗量
            self._slideTrain:SetNumber(recommendCurenum)
            self:UpdateData()
        end
    else
        --显示控制
        local numTrain = self.event.HealHealth
        local curepercent = math.floor(MonsterModel.GetBloodPercent((self.item:GetIndex() + 1), numTrain))
        --正在治疗中需要播放血条显示动画 -1 为无限循环播放 无延迟 无回调函数
        self.Controller.contentPane:GetTransition("Return" .. MonsterModel.GetBloodColor(percent)):Play(-1, 0, nil)
        self.Controller.contentPane:GetChild("Blood" .. MonsterModel.GetBloodColor(percent) .. "Dark").value = curepercent
        --百分比血量显示
        self._bloodctr.selectedPage = MonsterModel.GetBloodColor(percent)
        self.Controller.contentPane:GetChild("Blood" .. MonsterModel.GetBloodColor(percent)).value = percent
        self._bloodtext.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Health") .. " " .. percent .. "%"
        --取得正在治疗的巨兽的名字（只取一次）
        local healing = MonsterModel.GetHealingId()
        if healing then
            local name = TrainModel.GetName(healing.Id + healing.Level - 1)
            -- local name = "[color=#f2c952]" .. TrainModel.GetName(self.item:GetMonsterId()) .. "[/color]"
            self._textTagName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Treating_Army", {amount = name})
        end
        self:UpdateCureData()
    end

    if UIMgr:GetUIOpen("MonsterHospital") then
        AnimationMonster.PlayMonsterAnim(self.Controller.contentPane, AnimationMonster.From.Hospital, monsterId, percent < 10, 1)
    end
end

--刷新治疗巨兽中进度 及血量动效控制 计时器
function MonsterHospital:UpdateCureData()
    if not self.event or not next(self.event) then
        self:Doclose()
        return
    end
    local ctime = self.event.FinishAt - Tool.Time()
    if ctime <= 0 then
        self:Doclose()
        return
    end
    --计算治疗量
    if self.time_func then
        self:UnSchedule(self.time_func)
    end
    local bar_func = function(t)
        self._returnBlood.value = (1 - t / self.event.Duration) * 100
        --计算出目前的巨兽血量变化值 并改变显示
        local monsterHealth = math.ceil((1 - t / self.event.Duration) * self.event.HealHealth)

        self._textTime.text = Tool.FormatTime(t)
        --消耗金币数量
        local gold = Tool.TimeTurnGold(t)
        if self.goldNumber ~= gold then
            self.goldNumber = gold
            self._bthCureNowtext.text = UITool.UBBTipGoldText(self.goldNumber)
        end
    end
    bar_func(ctime)
    self.time_func = function()
        ctime = ctime - 1
        if ctime >= 0 then
            bar_func(ctime)
            return
        end
        self:Doclose()
    end

    self:Schedule(self.time_func, 1)
end

--治疗完成后要关闭计时器
function MonsterHospital:Doclose()
    if self.time_func then
        self:UnSchedule(self.time_func)
    end
    UIMgr:Close("MonsterHospital")
    Event.Broadcast(EventDefines.CloseGuide)
end

--治疗巨兽
function MonsterHospital:CureMonster(flag)
    if flag and not self.condGold then
        UITool.GoldLack()
        return
    end

    local function net_func()
        self.HealHealth = self._slideTrain:GetNumber()
        Net.GiantBeast.CureGiantBeast(
            self.item:GetBaseMonsterId(),
            self.HealHealth,
            flag,
            function(rsp)
                if rsp.Gem then
                    Event.Broadcast(EventDefines.UIGemAmount, rsp.Gem)
                    MonsterModel.RefreshMonsterHealth(self.item:GetBaseMonsterId(), self.HealHealth, false)
                    Event.Broadcast(EventDefines.UIBeastFinishCureRsp, rsp.Event)
                end
                if rsp.ResAmounts then
                    Event.Broadcast(EventDefines.UIResourcesAmount, rsp.ResAmounts)
                end
                if rsp.Event then
                    Model.UpdateList(ModelType.BeastCureEvents, "Uuid", {rsp.Event})
                end
                UIMgr:Close("MonsterHospital")
                Event.Broadcast(EventDefines.UIMonsterCureEvent)
                Event.Broadcast(EventDefines.CloseGuide)
                Event.Broadcast(EventDefines.UIInjuredBeastExg)
            end
        )
    end
    if flag then
        local data = {
            content = StringUtil.GetI18n("configI18nCommons", "Ui_CompleteNow_Treatment"),
            tipType = TipType.TYPE.ConditionBeastCure,
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

function MonsterHospital:UpdateData()
    local numTrain = self._slideTrain:GetNumber()

    --设置治疗时候的血条显示
    local percent = math.floor(MonsterModel.GetBloodPercent((self.item:GetIndex() + 1), 0))
    local curepercent = math.floor(MonsterModel.GetBloodPercent((self.item:GetIndex() + 1), numTrain))
    --需要保证动效是停止的
    self.Controller.contentPane:GetTransition("Return" .. MonsterModel.GetBloodColor(percent)):Stop()
    self.Controller.contentPane:GetChild("Blood" .. MonsterModel.GetBloodColor(percent) .. "Dark").value = curepercent

    --获取相应巨兽医院等级的治疗基数cure
    local cure = 0
    local beastHospitalId = Global.BuildingBeastHospital + self.building.Level
    cure = DetailModel.GetBeastHospitalConf(beastHospitalId).beast_cure

    --治疗时间
    local trainTime = math.ceil(numTrain / cure * 3600)
    self._textCureTime.text = Tool.FormatTime(trainTime)

    --消耗资源数量
    local resGold = 0

    for _, v in pairs(self.curRes) do
        local item = self._resList:GetChildAt(v.index - 1)
        local num = math.ceil(v.config.amount * numTrain)

        item:Init(v.config.category, num)
        item:InitCb(
            function()
                self:RefreshMonster()
                --刷新巨兽显示
                AnimationMonster.Refresh()
            end
        )
        local diffAmount = Model.Resources[v.config.category].Amount - num
        if diffAmount < 0 then
            resGold = resGold + Tool.ResTurnGold(v.config.category, -diffAmount)
        end
    end

    self.resGold = resGold
    --消耗金币数量
    local timeGold = Tool.TimeTurnGold(trainTime)
    self.goldNumber = timeGold + resGold
    self.condGold = self.goldNumber <= Model.Player.Gem
    self._bthCureNowtext.text = UITool.UBBTipGoldText(self.goldNumber)
end

--判断资源是否不足并提示
function MonsterHospital:OnResPopup()
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

    if next(lackRes) or next(needResList) then
        if not canUseItemToFill then
            local data = {
                textTip = StringUtil.GetI18n(I18nType.Commmon, "Tech_Res_Text5"),
                lackRes = lackRes,
                textBtnSure = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CURE"),
                cbBtnSure = function()
                    self:CureMonster(false)
                end
            }
            UIMgr:Open("ConfirmPopupDissatisfaction", data)
        else
            UIMgr:Open("ComfirmPopupUseRes", needResList,function()
                    self:CureMonster(false)
                end)
        end
    else
        self:CureMonster(false)
    end
end

--刷新列表的位置
function MonsterHospital:RefreshList()
    self._list.scrollPane:SetPosX(0)
end

function MonsterHospital:GuildShow()
    return self._btnCure
end

return MonsterHospital
