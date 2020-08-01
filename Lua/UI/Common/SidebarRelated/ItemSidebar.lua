--[[
    Author: songzeming
    Function: 侧边栏Item
]]
local ItemSidebar = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemSidebarQueue", ItemSidebar)
local MissionModel = import("Model/MissionEventModel")
local BuildModel = import("Model/BuildModel")
local UpgradeModel = import("Model/UpgradeModel")
local CommonModel = import("Model/CommonModel")
local EventModel = import("Model/EventModel")
local MissionEventModel = import("Model/MissionEventModel")
local WelfareModel = import("Model/WelfareModel")
local MonsterData = import("Model/MonsterModel")
local TechModel = import("Model/TechModel")
local EquipModel = _G.EquipModel
local CTR = {
    Normal = "Normal",
    Goto = "Goto", --前往 绿色按钮(建筑建造：已完成、训练队列：已完成(绿色))
    Free = "Free", --免费 黄色按钮(倒计时)
    Accelerate = "Accelerate", --加速 黄色按钮(倒计时)
    Train = "Train", --训练 绿色按钮(空闲中)
    Research = "Research", --研究 绿色按钮(空闲中)
    Cure = "Cure", --治疗
    Text = "Text", --文字 (已完成、制造中、冷却中、暂无美女)
    Lock = "Lock", --未启动 绿色按钮
    Progress = "ProgressText"
    --倒计时文字提示
    --进度文字说明
}
--状态描述
local STATEDESC = {
    Idel = "Queue_Text6",
    Finish = "Queue_Text15",
    NotCreate = "Ui_Unactivated"
}
local STATETEXT = {
    Finish = "Queue_Text15",
    Producing = "Queue_Text17",
    CDIng = "Queue_Text16",
    NoGirl = "Queue_Text19"
}
local CDTimeType = {
    Text = "Text",
    Prossbar = "Prossbar",
    ProssText = "ProssText"
}

function ItemSidebar:ctor()
    self._controller = self:GetController("Controller")

    self:AddListener(self._btnGoto.onClick,
        function()
            self.cb()
        end
    )
    self:AddListener(self._btnFree.onClick,
        function()
            self.cb()
        end
    )
    self:AddListener(self._btnAccelerate.onClick,
        function()
            self.cb()
        end
    )
    self:AddListener(self._btnTrain.onClick,
        function()
            self.cb()
        end
    )
    self:AddListener(self._btnResearch.onClick,
        function()
            self.cb()
        end
    )
    self:AddListener(self._btnCure.onClick,
        function()
            self.cb()
        end
    )
    self:AddListener(self._btnLock.onClick,
        function()
            self:OnBtnLockClick()
        end
    )

    self:SetLight(false)
end

function ItemSidebar:SetDesc(state,data)
    self._textDesc.text = StringUtil.GetI18n(I18nType.Commmon, state,data)
end

--设置光圈
function ItemSidebar:SetLight(flag, cacheLight)
    self._flag = flag
    if not flag then
        self._light:EffectDispose()
    else
        self._light:PlayEffectLoop("effects/queue_box/prefab/effect_queue_box")
        -- self._light:PlayDynamicEffectLoop("effect_collect", "effect_queue_box")
        self._light.visible = cacheLight
    end
end

function ItemSidebar:GetIsLight()
    return self._flag
end

--获取是否提示状态 前往、领取
function ItemSidebar:GetPointState()
    return Tool.Equal(self._controller.selectedPage, CTR.Goto, CTR.Train)
end

--建造
function ItemSidebar:InitBuild(index, event, cb)
    self.index = index
    self.event = event
    self.cb = cb

    if not event then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Queue_Text" .. index)
        self:SetController(CTR.Goto)
        self:SetDesc(STATEDESC.Idel)

        if index == BuildType.QUEUE.Charge then
            self._icon.icon = UIPackage.GetItemURL("Icon", "Base_Queue_02")
            local expire = Model.Builders[BuildType.QUEUE.Charge].ExpireAt
            local islock = expire > 0 and expire < Tool.Time()
            if islock then
                self:SetController(CTR.Lock)
            end
        else
            self._icon.icon = UIPackage.GetItemURL("Icon", "Base_Queue_01")
        end
    else
        local building = Model.Buildings[event.TargetId]
        self._icon.icon = UITool.GetIcon(UpgradeModel.GetIcon(building.ConfId, building.Level))
        self._title.text = BuildModel.GetName(building.ConfId)
        self:CDShow()
    end
end
--训练
function ItemSidebar:InitTrain(confId, cb, contentConfigIndex)
    self.event = nil
    self.cb = cb
    self._icon.icon = UITool.GetIcon(ConfigMgr.GetItem("configSidebarContents", contentConfigIndex).icon)
    self._title.text = BuildModel.GetName(confId)
    local building = BuildModel.FindByConfId(confId)
    --单独处理升级事件提示
    if building then
        local buildEvent = EventModel.GetUpgradeEvent(building.Id)
        if buildEvent then
            self.event = buildEvent
            self:CDShow()
            return
        end
    end
    local event = EventModel.GetTrainEvent(confId)
    self.event = event
    if not event then
        if not BuildModel.FindByConfId(confId) then
            self:SetController(CTR.Goto)
            self:SetDesc(STATEDESC.NotCreate)
        else
            self:SetController(CTR.Train)
            self:SetDesc(STATEDESC.Idel)
        end
    else
        self:CDShow()
    end
end
-- 装备制造
function ItemSidebar:InitEquip(confId, cb, contentConfigIndex)
    self.event = nil
    self.cb = cb
    self._icon.icon = UITool.GetIcon(ConfigMgr.GetItem("configSidebarContents", contentConfigIndex).icon)
    self._title.text = BuildModel.GetName(confId)
    local makeInfo = EquipModel.GetMaterialMakeInfo()
    local NumCount = makeInfo.MaxIndex + 1
    local NumCurrent =(makeInfo.RunEvent.JewelId ~= 0 and 1 or 0)+ #makeInfo.WaitList
    if NumCount > NumCurrent then
        self:SetController(CTR.Goto)
        self:SetDesc("Queue_Text20",{num = NumCurrent,limit = NumCount})
    else
        self:SetController(CTR.Text)
        self:SetDesc("Queue_Text20",{num = NumCurrent,limit = NumCount})
        self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Making_Material")
    end
end

--科研
function ItemSidebar:InitResearch(cb, index)
    local event = nil
    local confId = nil
    if index == 1 then
        event = EventModel.GetTechEvent(Global.BuildingScience)
        confId = Global.BuildingScience
        self._title.text = StringUtil.GetI18n(I18nType.Building, "403000_NAME")
        self._icon.icon = UIPackage.GetItemURL("Icon", "Base_Queue_08")
    elseif index == 2 then
        event = EventModel.GetTechEvent(Global.BuildingBeastScience)
        confId = Global.BuildingBeastScience
        self._title.text = StringUtil.GetI18n(I18nType.Building, "442000_NAME")
        self._icon.icon = UIPackage.GetItemURL("Icon", "Base_Queue_09")
    end
    self.event = event
    self.cb = cb
    local building = BuildModel.FindByConfId(confId)
    -- --单独处理升级事件提示
    if building then
        local buildEvent = EventModel.GetUpgradeEvent(building.Id)
        if buildEvent then
            self.event = buildEvent
            self:CDShow()
            return
        end
    end

    if not event then
        local buildNode = nil
        if index == 1 then
            buildNode = BuildModel.FindByConfId(Global.BuildingScience)
        elseif index == 2 then
            buildNode = BuildModel.FindByConfId(Global.BuildingBeastScience)
        end
        if not buildNode then
            self:SetController(CTR.Goto)
            self:SetDesc(STATEDESC.NotCreate)
        else
            self:SetController(CTR.Research)
            self:SetDesc(STATEDESC.Idel)
        end
    else
        local beastIcon = nil
        if ConfigMgr.GetItem("configBeastTechDisplays", event.TargetId) then
            beastIcon = ConfigMgr.GetItem("configBeastTechDisplays", event.TargetId).icon
        else
            beastIcon = ConfigMgr.GetItem("configTechDisplays", event.TargetId).icon
        end
        self._icon.icon = UITool.GetIcon(beastIcon)
        self._title.text = TechModel.GetTechName(event.TargetId)
        self:CDShow()
    end
end

--行动队列
function ItemSidebar:InitActionQueue(index, cb, missionData)
    local isPosText = false
    self:CancelSchudleQueue()
    self.cb = cb
    self.missionData = missionData
    self.missionIndex = index
    self.remainTime = 0
    self.countDownTime = 0
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Queue_Text" .. index)
    if not missionData then
        self._icon.icon = UIPackage.GetItemURL("Icon", "Base_Queue_10")
        self:SetController(CTR.Goto)
        self:SetDesc(STATEDESC.Idel)
        return
    else
        self.mTimeFunc = function()
            return missionData.FinishAt - Tool.Time()
        end
        self.remainTime = self.mTimeFunc()
        self.countDownTime = missionData.Duration
        local queueId = missionData.Category * 100 + missionData.Status + 10000
        local info = ConfigMgr.GetItem("configMapQueues", queueId)
        self._icon.icon = info.statusIcon and UIPackage.GetItemURL(info.statusIcon[1], info.statusIcon[2]) or ""
        local finishAt = missionData.FinishAt
        if info.statusText3 then
            local stateDes = StringUtil.GetI18n(I18nType.Commmon, info.statusText3)
            self._textState.text = stateDes
        end
        if missionData.Status == Global.MissionStatusMarch then --行军中
            if missionData.IsReturn then
                self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "Queue_Text8")
            else
                self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "Queue_Text9")
            end
            isPosText = false
        elseif missionData.Status == Global.MissionStatusMining then --采集中
            self.mTimeFunc = function()
                return missionData.MineFinishAt - Tool.Time()
            end
            self.remainTime = self.mTimeFunc()
            self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "Queue_Text7")
            self.countDownTime = missionData.MineFinishAt - missionData.FinishAt
            --采集状态按照自愿图标特殊处理
            if missionData.Category == 3 then
                local confId = tonumber(missionData.Params)
                if confId > 0 then
                    local mineInfo = ConfigMgr.GetItem("configMines", confId)
                    local icon = ConfigMgr.GetItem("configResourcess", mineInfo.category).img
                    self._icon.icon = UIPackage.GetItemURL(icon[1], icon[2])
                end
            end
            isPosText = false
        else
            isPosText = true
        end
        if isPosText then
            self:SetController(CTR.Text)
            self._textDesc.text = "(X:" .. missionData.StopX .. ", Y:" .. missionData.StopY .. ")"
        end
        if self.remainTime == 0 or isPosText then
            return
        end
        self:QueueCDShow(CDTimeType.Prossbar)
    end
end

--医疗
function ItemSidebar:InitMedical(name, cb)
    self.cb = cb
    --战区医院
    if name == "411000_NAME" then
        --巨兽医院
        local event = EventModel.GetCureEvent()
        if not event then
            if not BuildModel.FindByConfId(Global.BuildingHospital) then
                self:SetController(CTR.Goto)
                self:SetDesc(STATEDESC.NotCreate)
            else
                local count = 0
                for _, v in pairs(Model.InjuredArmies) do
                    count = count + v.Amount
                end
                if count == 0 then
                    self:SetController(CTR.Text)
                    self._textDesc.text = ""
                    self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RANK_NONE")
                else
                    self:SetController(CTR.Cure)
                    self._textDesc.text = count
                end
            end
            self._icon.icon = UIPackage.GetItemURL("Icon", "Base_Queue_11")
        else
            self.event = event
            self:CDShow()
        end
    elseif name == "441000_NAME" then
        local event = EventModel.GetBeastCureEvent()
        if not next(event) then
            if not BuildModel.FindByConfId(Global.BuildingBeastHospital) then
                self:SetController(CTR.Goto)
                self:SetDesc(STATEDESC.NotCreate)
            else
                local count = 0
                count = MonsterData.GetMonsterHurtNum()
                if count == 0 then
                    self:SetController(CTR.Text)
                    self._textDesc.text = ""
                    self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RANK_NONE")
                else
                    self:SetController(CTR.Cure)
                    self._textDesc.text = count
                end
            end
            self._icon.icon = UIPackage.GetItemURL("Icon", "Base_Queue_12")
        else
            self.event = event
            self:CDShow()
        end
    end
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, name)
end

--联盟事务
function ItemSidebar:InitAllianceAffairs(name, cb, allianceData, inAlliance)
    self.cb = cb
    if name == "UnionDonate" then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "ROAD_GROWTH_TAB_13")
        self._icon.icon = UIPackage.GetItemURL("Icon", "Base_Queue_13")
    elseif name == "ReceiveUnionTask" then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "ACCEPT_ALLIANCE_TASK")
        self._icon.icon = UIPackage.GetItemURL("Icon", "Base_Queue_14")
    elseif name == "HelpUnionTask" then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "HELP_ALLIANCE_TASK")
        self._icon.icon = UIPackage.GetItemURL("Icon", "Base_Queue_15")
    end
    if inAlliance then
        if allianceData.finishAt <= 0 then
            if allianceData.count <= 0 then
                self:SetController(CTR.Text)
                self._textDesc.text = ""
                self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "Queue_Text15")
                return
            end
            self:SetController(CTR.Goto)
            self._textDesc.text = allianceData.count
        else
            self.mTimeFunc = function()
                return allianceData.finishAt - Tool.Time()
            end
            self.remainTime = self.mTimeFunc()
            if name == "UnionDonate" then
                self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "Queue_Text16")
                self:QueueCDShow(CDTimeType.Text)
            else
                self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "Queue_Text16")
                if allianceData.confId ~= 0 then
                    local configTask = ConfigMgr.GetItem("configAllianceTasks", allianceData.confId)
                    self.countDownTime = configTask.time
                    self:QueueCDShow(CDTimeType.ProssText)
                end
            end
        end
    else
        self:SetController(CTR.Goto)
    end
end
--福利领取
function ItemSidebar:InitWelfareCollection(name, cb)
    self.cb = cb
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, name)
    if name == "Ui_Parking_Apron" then --在线领取
        self._icon.icon = UIPackage.GetItemURL("Icon", "Base_Queue_16")

        self.nextTime = Model.NextBonusTime
        self.mTimeFunc = function()
            return self.nextTime - Tool.Time()
        end
        local ctime = self.mTimeFunc()
        if ctime > 0 then
            self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "Queue_Text19")
        end
        self.remainTime = ctime
        self:QueueCDShow(CDTimeType.Text)
    elseif name == "UI_Free_Supply" then --免费补给
        self._icon.icon = UIPackage.GetItemURL("Icon", "Base_Queue_17")
        self.msInfos = Model.GetMap(ModelType.MSInfos)
        if self.msInfos.FreeTimes <= 0 then
            self:SetController(CTR.Text)
            self._textDesc.text = ""
            self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "Queue_Text15")
        else
            self._textDesc.text = self.msInfos.FreeTimes
            self:SetController(CTR.Goto)
        end
    elseif name == "Ui_Sign_In" then --签到
        self._icon.icon = UIPackage.GetItemURL("Icon", "Base_Queue_18")
        local isSigned = WelfareModel.CheckDailySigned()
        if isSigned then
            self:SetController(CTR.Text)
            self._textDesc.text = ""
            self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "Queue_Text15")
        else
            self:SetController(CTR.Goto)
        end
    elseif name == "UI_Meeting_Gift" then --见面礼
        self._icon.icon = UIPackage.GetItemURL("Icon", "Base_Queue_19")
        local isSigned = WelfareModel.CheckCumulativeSigned()
        if isSigned then
            self:SetController(CTR.Text)
            self._textDesc.text = ""
            self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "Queue_Text15")
        else
            self:SetController(CTR.Goto)
        end
    end
end

--设置控制器显示
function ItemSidebar:SetController(state)
    self._controller.selectedPage = state
end

--倒计时显示
function ItemSidebar:CDShow()
    local category = self.event.Category
    local function time_func()
        return self.event.FinishAt - Tool.Time()
    end
    --事件已完成 待收取
    local finish_func = function()
        if category == EventType.B_TRAIN then
            self:SetController(CTR.Goto)
            self:SetDesc(STATEDESC.Finish)
        else
            self:SetController(CTR.Goto)
            self:SetDesc(STATEDESC.Idel)
        end
    end
    if time_func() <= 0 then
        finish_func()
        return
    end

    --事件进行中
    self:SetController(CTR.Accelerate)
    local freeTime = CommonModel.FreeTime()
    local isCheck = false
    local bar_func = function()
        local t = time_func()
        self._bar.value = (1 - t / self.event.Duration) * 100
        self._barTime.text = Tool.FormatTime(t)
        --是否显示免费
        if not isCheck and BuildModel.FreeState(category) then
            if t <= freeTime then
                self:SetController(CTR.Free)
                isCheck = true
            end
        end
    end
    bar_func()

    --倒计时显示
    self.cd_func = function()
        if time_func() >= 0 then
            bar_func()
            return
        end
        self:CancelSchudle()
        finish_func()
    end
    self:Schedule(self.cd_func, 1)
end

--取消定时器
function ItemSidebar:CancelSchudle()
    self:CancelSchudleQueue()
    if not self.cd_func then
        return
    end
    self:UnSchedule(self.cd_func)
end

--队列计时器
function ItemSidebar:QueueCDShow(mCDType)
    self.CDType = mCDType
    local queueFinish_func = function()
        if self.CDType == CDTimeType.Text then
            self:SetController(CTR.Goto)
            self._textDesc.text = ""
        elseif self.CDType == CDTimeType.ProssText then
            self:SetController(CTR.Goto)
            self:SetDesc(STATEDESC.Finish)
        end
    end

    if self.CDType == CDTimeType.Text then
        self:SetController(CTR.Text)
    elseif self.CDType == CDTimeType.Prossbar then
        self:SetController(CTR.Progress)
    elseif self.CDType == CDTimeType.ProssText then
        self:SetController(CTR.Progress)
    end
    local bar_func = function(t)
        if self.CDType == CDTimeType.Text then
            self._textDesc.text = Tool.FormatTime(t)
        elseif self.CDType == CDTimeType.Prossbar or self.CDType == CDTimeType.ProssText then
            self._bar.value = (self.countDownTime - t) / self.countDownTime * 100
            self._barTime.text = Tool.FormatTime(t)
        end
    end
    bar_func(self.remainTime)
    self.cd_Queuefunc = function()
        self.remainTime = self.mTimeFunc()
        if self.remainTime >= 0 then
            bar_func(self.remainTime)
            return
        end
        self:CancelSchudleQueue()
        queueFinish_func()
    end
    self:Schedule(self.cd_Queuefunc, 1)
end

--取消队列计时
function ItemSidebar:CancelSchudleQueue()
    if not self.cd_Queuefunc then
        return
    end
    self:UnSchedule(self.cd_Queuefunc)
end

--点击购买建筑队列
function ItemSidebar:OnBtnLockClick()
    UIMgr:Open(
        "BuildRelated/QueuePopup",
        "Queue",
        nil,
        nil,
        function()
            self:SetController(CTR.Goto)
        end
    )
end

return ItemSidebar
