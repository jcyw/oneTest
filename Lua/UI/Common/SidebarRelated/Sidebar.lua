--[[
    Author: songzeming
    Function: 侧边栏
]]
local Sidebar = UIMgr:NewUI("SidebarRelated/Sidebar")

local BuildModel = import("Model/BuildModel")
local EventModel = import("Model/EventModel")
local JumpMap = import("Model/JumpMap")
local MissionModel = import("Model/MissionEventModel")
local ArmiesModel = import("Model/ArmiesModel")
local WelfareModel = import("Model/WelfareModel")
local MonsterData = import("Model/MonsterModel")
local GlobalVars = GlobalVars
import("UI/Common/SidebarRelated/ItemSidebar")
local ItemLightList = {} --储存设置了发光特效的列表item
local CTR = {
    Show = "Show",
    Hide = "Hide"
}
--队列总览类型
local Type = {
    Build = "Build", --建造
    Train = "Train", --训练
    Tech = "Tech", --研究
    Welfare = "Welfare", --福利
    equip = "equip"
}
--训练类型
local TrainType = {
    Global.BuildingTankFactory, --坦克工厂(步) 423000
    Global.BuildingWarFactory, --战车工厂(骑) 424000
    Global.BuildingHelicopterFactory, --直升机工厂(弓) 425000
    Global.BuildingVehicleFactory, --重型载具工厂(车) 426000
    Global.BuildingSecurityFactory --安保工厂 416000
}
--训练建筑图标配置对应Index
local TrainTypeContentIndex = {
    21, --坦克工厂(步) 423000
    22, --战车工厂(骑) 424000
    23, --直升机工厂(弓) 425000
    24, --重型载具工厂(车) 426000
    25 --安保工厂 416000
}
-- 材料制造类型
local EquipType = {
    Global.BuildingEquipMaterialFactory, --材料工厂(步) 445000
}
--材料制造图标配置对应Index
local EquipTypeContentIndex = {
    74 --材料生产
}
--医疗类型
local MedicalType = {
    "411000_NAME", --战区医院
    "441000_NAME" --巨兽医院
}
--福利领取类型
local WelfareType = {
    "Ui_Parking_Apron", --停机坪
    "UI_Free_Supply", --免费补给
    "Ui_Sign_In", --签到
    "UI_Meeting_Gift" --见面礼
}
local UnionType = {
    "UnionDonate",
    --联盟捐献
    "ReceiveUnionTask",
    --接收联盟任务
    "HelpUnionTask"
    --帮助联盟任务
}

function Sidebar:OnInit()
    local view = self.Controller.contentPane
    self._ctr = view:GetController("Controller")
    self._ctr.selectedPage = CTR.Hide
    self.sortingOrder = 2

    self._animIn = view:GetTransition("In")
    self._animIn.timeScale = 3
    self._animOut = view:GetTransition("Out")
    self._animOut.timeScale = 3

    self._groupArrow = view:GetChild("groupArrow")
    self:MatchPos()
    self._mask.visible = false
    self._mask.width = GRoot.inst.width
    self:AddListener(self._mask.onClick,
        function()
            self:SetOpen(false)
        end
    )
    self:AddListener(self._btnArrow.onClick,
        function()
            if not self.isOpen then
                CityMapModel.GetCityFunction():SetFuncVisible(false)
                for _, _mask in pairs(GlobalVars.CommonMask) do
                    if _mask.visible then
                        return
                    end
                end
            end
            self:SetOpen(not self.isOpen)
            if self.triggerFunc then
                self.triggerFunc()
            end
        end
    )
    self:AddListener(self._list.scrollPane.onScroll,
        function()
            self:SetEffect()
        end
    )
    self:AddEvent(
        EventDefines.UISidebarOpen,
        function(flag)
            self:SetOpen(flag)
        end
    )
    self:AddEvent(
        EventDefines.UISidebarPoint,
        function()
            self:SetRedPointState()
        end
    )
    self:AddEvent(
        EventDefines.UIQueueRefresh,
        function()
            if self._ctr.selectedPage == CTR.Show then
                local itemData = ConfigMgr.GetItem("configSidebars", 4)
                self:ActionQueueList(3, itemData)
            end
        end
    )
    self:AddEvent(
        EventDefines.UIMainShow,
        function(flag)
            view.visible = flag
        end
    )
    --跨天刷新通知
    self:AddEvent(
        TIME_REFRESH_EVENT.Refresh,
        function()
            self:Init()
        end
    )

    self:Init()
end

function Sidebar:Init()
    self.checking = false
    self.lighting = false
    self:CheckCuePoint()
end

function Sidebar:OnOpen()
    self:SetRedPointState()
end

function Sidebar:SetCuePoint(number)
    CuePointModel:SetSingle(CuePointModel.Type.Red, number, self._btnArrow, CuePointModel.Pos.Sidebar)
end
function Sidebar:CheckCuePoint()
    if not PlayerDataModel:GetDayNotTip(PlayerDataEnum.SIDEBAR) then
        self.checking = true
        --建造
        local builder = Model.Builders[BuildType.QUEUE.Free]
        if not builder.IsWorking then
            self:SetCuePoint(1)
            return
        end
        builder = Model.Builders[BuildType.QUEUE.Charge]
        if not builder.IsWorking and builder.ExpireAt > Tool.Time() then
            self:SetCuePoint(1)
            return
        end
        --训练
        for _, v in pairs(TrainType) do
            local event = EventModel.GetTrainEvent(v)
            if not event then
                if BuildModel.FindByConfId(v) then
                    self:SetCuePoint(1)
                    return
                end
            end
        end
        --研究
        local event = EventModel.GetTechEvent(Global.BuildingScience)
        if not event then
            if BuildModel.FindByConfId(Global.BuildingScience) then
                self:SetCuePoint(1)
                return
            end
        end
        --福利
        for i = 1, self._list.numChildren do
            local item = self._list:GetChildAt(i - 1)
            if item.name == Type.Welfare then
                local _itemList = item:GetChild("liebiao")
                for j = 1, _itemList.numChildren do
                    local child = _itemList:GetChildAt(j - 1)
                    local t = child.name
                    if t == "Ui_Parking_Apron" then
                        --在线领奖
                        if Model.NextBonusTime - Tool.Time() <= 0 then
                            self:SetCuePoint(1)
                        end
                    elseif t == "UI_Free_Supply" then
                        --免费补给次数
                        if Model.GetMap(ModelType.MSInfos).FreeTimes > 0 then
                            self:SetCuePoint(1)
                        end
                    elseif t == "Ui_Sign_In" then
                        --签到
                        if not WelfareModel.CheckDailySigned() then
                            self:SetCuePoint(1)
                        end
                    elseif t == "UI_Meeting_Gift" then
                        --见面礼
                        if not WelfareModel.CheckCumulativeSigned() then
                            self:SetCuePoint(1)
                        end
                    end
                end
                break
            end
        end
        --没有奖励
        self.lighting = true
    else
        if self.checking and not self.lighting then
            self.lighting = true
            for i = 1, self._list.numChildren do
                local item = self._list:GetChildAt(i - 1)
                local _itemList = item:GetChild("liebiao")
                if item.name == Type.Build then
                    --建造
                    local builder = Model.Builders[BuildType.QUEUE.Free]
                    if not builder.IsWorking then
                        _itemList:GetChildAt(0):SetLight(true)
                        break
                    end
                    builder = Model.Builders[BuildType.QUEUE.Charge]
                    if not builder.IsWorking and builder.ExpireAt > Tool.Time() then
                        _itemList:GetChildAt(1):SetLight(true)
                        break
                    end
                elseif item.name == Type.Train then
                    --训练
                    for index, v in pairs(TrainType) do
                        local event = EventModel.GetTrainEvent(v)
                        if not event then
                            if BuildModel.FindByConfId(v) then
                                _itemList:GetChildAt(index - 1):SetLight(true)
                                break
                            end
                        end
                    end
                elseif item.name == Type.Tech then
                    --研究
                    local event = EventModel.GetTechEvent(Global.BuildingScience)
                    if not event then
                        if BuildModel.FindByConfId(Global.BuildingScience) then
                            _itemList:GetChildAt(0):SetLight(true)
                            break
                        end
                    end
                elseif item.name == Type.Welfare then
                    --福利领奖
                    for c = 1, _itemList.numChildren do
                        local child = _itemList:GetChildAt(c - 1)
                        local t = child.name
                        if t == "Ui_Parking_Apron" then
                            --在线领奖
                            if Model.NextBonusTime - Tool.Time() <= 0 then
                                child:SetLight(true)
                                break
                            end
                        end
                        if t == "UI_Free_Supply" then
                            --免费补给次数
                            if Model.GetMap(ModelType.MSInfos).FreeTimes > 0 then
                                child:SetLight(true)
                                break
                            end
                        end
                        if t == "Ui_Sign_In" then
                            --签到
                            if not WelfareModel.CheckDailySigned() then
                                child:SetLight(true)
                                break
                            end
                        end
                        if t == "UI_Meeting_Gift" then
                            --见面礼
                            if not WelfareModel.CheckCumulativeSigned() then
                                child:SetLight(true)
                                break
                            end
                        end
                    end
                end
            end
            self:SetCuePoint(0)
        end
    end
    self:ScheduleOnceFast(
        function ()
            self:SetEffect()
        end,
        0.2
    )
end

--因为周围是空白的，所以特效遮不住，通过暂时缓存特效的播放，如果不是在列表视口中间则不播放特效
--变量的命名都是按这个物体本身的名字命名
function Sidebar:SetEffect()
    for i = 0, self._list.numChildren - 1, 1 do
        local itemSidebar = self._list:GetChildAt(i)
        local itemSidebarLocalPos = self._list:GlobalToLocal(itemSidebar:LocalToGlobal(Vector2.zero))
        local itemSidebarList = itemSidebar:GetChild("liebiao")
        for j = 0, itemSidebarList.numChildren - 1, 1 do
            local itemSidebarQueue = itemSidebarList:GetChildAt(j)
            local itemSidebarQueueLocalpos = itemSidebar:GlobalToLocal(itemSidebarQueue:LocalToGlobal(Vector2.zero))
            local pos = itemSidebarLocalPos.y + itemSidebarQueueLocalpos.y
            local isLight = itemSidebarQueue:GetIsLight()
            if pos < (-itemSidebarQueue.height) or pos > (self._list.height - itemSidebarQueue.height) then
                itemSidebarQueue:SetLight(isLight,false)
            else
                itemSidebarQueue:SetLight(isLight,true)
            end
        end
    end
end

function Sidebar:SetRedPointState()
    --检测[建筑建造]是否显示红点
    local localData = PlayerDataModel:GetData(PlayerDataEnum.QUEUEOVERVIEW)
    if not localData then
        --没有红点 TODO
        return
    end
    local check_func = function(title)
        if title == "BUTTON_BUILD" then
            --建造
            local builder = Model.Builders[BuildType.QUEUE.Free]
            if not builder.IsWorking then
                return true
            end
            builder = Model.Builders[BuildType.QUEUE.Charge]
            if not builder.IsWorking and builder.ExpireAt > Tool.Time() then
                return true
            end
        elseif title == "BUTTON_TRAIN" then
            --训练
            for _, v in pairs(TrainType) do
                local event = EventModel.GetTrainEvent(v)
                if not event then
                    if BuildModel.FindByConfId(v) then
                        return true
                    end
                end
            end
        elseif title == "BUTTON_RESEARCH" then
            --科研
            local event = EventModel.GetTechEvent(Global.BuildingScience)
            if not event then
                if BuildModel.FindByConfId(Global.BuildingScience) then
                    return true
                end
            end
        elseif title == "BUTTON_CURE" then
            --医疗
            local event = EventModel.GetTechEvent(Global.BuildingHospital)
            if not event then
                if BuildModel.FindByConfId(Global.BuildingHospital) then
                    return true
                end
            end
        end
        return
    end
    for k, v in pairs(localData) do
        if math.floor(v) == TipType.QUEUEOVERVIEW.EveryDay then
            --每日提醒一次
            if not PlayerDataModel:GetDayNotTip(k) then
                if check_func(k) then
                    -- 有红点 TODO
                    PlayerDataModel:SetDayNotTip(k)
                    return
                end
            end
        elseif math.floor(v) == TipType.QUEUEOVERVIEW.Idel then
            --有空闲就提醒
            if check_func(k) then
                -- 有红点 TODO
                return
            end
        end
    end
    -- 没有红点 TODO
end

--设置侧边栏是否打开
function Sidebar:SetOpen(flag)
    GlobalVars.IsSidebarOpen = flag
    self.isOpen = flag
    self._mask.visible = flag
    if flag then
        PlayerDataModel:SetDayNotTip(PlayerDataEnum.SIDEBAR)
        self:ListShow()
        self._animIn:Play()
        return
    end
    self._animOut:Play(
        function()
            self._ctr.selectedPage = CTR.Hide
            for i = 1, self._list.numChildren do
                local node = self._list:GetChildAt(i - 1)
                local list = node:GetChild("liebiao")
                for j = 1, list.numChildren do
                    local item = list:GetChildAt(j - 1)
                    item:CancelSchudle()
                    item:SetLight(false)
                end
            end
        end
    )
end

--列表展示
function Sidebar:ListShow()
    local conf = ConfigMgr.GetList("configSidebars")
    local centerLv = BuildModel.GetCenterLevel()
    if not self.centerLv or centerLv ~= self.centerLv then
        self.centerLv = centerLv
        local count = 0
        for _, v in pairs(conf) do
            if centerLv >= v.level then
                count = count + 1
            end
        end
        self._list.numItems = count
    end
    table.sort(conf,function (a, b)
        return a.order < b.order
    end)
    local index = 0
    for _, v in pairs(conf) do
        if centerLv >= v.level then
            if v.i18n == "BUTTON_BUILD" then
                self:BuildList(index, v)
            elseif v.i18n == "BUTTON_TRAIN" then
                self:TrainList(index, v)
            elseif v.i18n == "BUTTON_RESEARCH" then
                self:ResearchList(index, v)
            elseif v.i18n == "Ui_Move_Queue" then
                self:ActionQueueList(index, v)
            elseif v.i18n == "BUTTON_CURE" then
                self:MedicalList(index, v)
            elseif v.i18n == "Queue_Title6" then
                self:GangAffairsList(index, v)
            elseif v.i18n == "Queue_Title7" then
                self:WelfareList(index, v)
            elseif v.i18n == "Queue_Title9" then
                self:EquipList(index, v)
            end
            index = index + 1
        end
    end
    self._ctr.selectedPage = CTR.Show
    self:SetRedPointState()
    self:CheckCuePoint()
end

--初始化列表 index
function Sidebar:InitList(index, number, title)
    local node = self._list:GetChildAt(index)
    if not self._bgHeight then
        self._bgHeight = node.height
    end
    node:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, title)
    local list = node:GetChild("liebiao")
    list.numItems = number
    list:ResizeToFit(number)
    node.height = self._bgHeight + list.height
    return list
end

--建造
function Sidebar:BuildList(index, data)
    self._list:GetChildAt(index).name = Type.Build
    local itemNum = data.total_num
    local list = self:InitList(index, itemNum, data.i18n)
    for i = 1, itemNum do
        local builder = Model.Builders[i]
        local bid = builder.EventId
        local event = builder.IsWorking and EventModel.GetUpgradeEvent(bid)
        local cb = function()
            self:SetOpen(false)
            BuildModel.OnBuilderClick(i)
        end
        list:GetChildAt(i - 1):InitBuild(i, event, cb)
    end
end

--训练
function Sidebar:TrainList(index, data)
    self._list:GetChildAt(index).name = Type.Train
    local itemNum = data.total_num
    local list = self:InitList(index, itemNum, data.i18n)
    for i = 1, itemNum do
        local confId = TrainType[i]
        local cb = function()
            self:SetOpen(false)
            JumpMap:JumpTo({jump = 810200, para = confId})
        end
        list:GetChildAt(i - 1):InitTrain(confId, cb, TrainTypeContentIndex[i])
    end
end

--科研
function Sidebar:ResearchList(index, data)
    self._list:GetChildAt(index).name = Type.Tech
    local itemNum = data.total_num
    local list = self:InitList(index, itemNum, data.i18n)
    for i = 1, itemNum do
        local cb = function()
            self:SetOpen(false)
            if i == 1 then
                JumpMap:JumpTo({jump = 810300, para = Global.BuildingScience})
            elseif i == 2 then
                JumpMap:JumpTo({jump = 810300, para = Global.BuildingBeastScience})
            end
        end
        list:GetChildAt(i - 1):InitResearch(cb, i)
    end
end

--行动队列
function Sidebar:ActionQueueList(index, data)
    local maxQueue = ArmiesModel.GetMarchQueueMax()
    local missionsData = MissionModel.GetList()
    local tempMission = {}
    for _, v in pairs(missionsData) do
        table.insert(tempMission, v)
    end
    local list = self:InitList(index, maxQueue, data.i18n)
    for i = 1, maxQueue do
        local cb = function()
            self:SetOpen(false)
            JumpMap:JumpSimple(812300)
        end
        list:GetChildAt(i - 1):InitActionQueue(i, cb, tempMission[i])
    end
end

--医疗
function Sidebar:MedicalList(index, data)
    local itemNum = data.total_num
    local list = self:InitList(index, itemNum, data.i18n)
    for i = 1, itemNum do
        local cb = function()
            self:SetOpen(false)
            if i == 1 then
                --战区医院
                local event = EventModel.GetCureEvent()
                if event then
                    local building = nil
                    local buildings = BuildModel.GetAll(Global.BuildingHospital)
                    for _, v in pairs(buildings) do
                        if EventModel.GetEvent(v) then
                            building = v
                            break
                        end
                    end
                    --升级
                    JumpMap:JumpTo({jump = 810100, para = building.ConfId, para1 = building})
                else
                    --治疗
                    JumpMap:JumpTo({jump = 810400, para = 0}, {type = 231, para1 = 0, para2 = 30})
                end
            elseif i == 2 then
                --巨兽医院
                local building = BuildModel.FindByConfId(Global.BuildingBeastHospital)
                if building then
                    if MonsterData.GetMonsterHurtNum() > 0 then
                        JumpMap:JumpTo({jump = 810401, para = Global.BuildingBeastHospital})
                        return
                    end
                    if EventModel.GetEvent(building) and EventModel.GetEvent(building).FinishAt then
                        JumpMap:JumpTo({jump = 810100, para = building.ConfId, para1 = building})
                    else
                        TipUtil.TipById(50039)
                    end
                else
                    JumpMap:JumpTo({jump = 810000, para = Global.BuildingBeastHospital})
                end
            end
        end
        list:GetChildAt(i - 1):InitMedical(MedicalType[i], cb)
    end
end

--联盟事务
function Sidebar:GangAffairsList(index, data)
    local itemNum = 0
    if Model.Player.Level >= 10 then
        itemNum = data.total_num
    else
        itemNum = 1
    end
    local list = self:InitList(index, itemNum, data.i18n)
    local AllianceData = {}
    local inAlliance = false
    Net.Events.EventPanelInfo(
        function(msg)
            table.insert(AllianceData, {finishAt = msg.AllianceContriCoolTime, count = msg.AllianceContriTimes})
            table.insert(AllianceData, {finishAt = msg.AllianceTaskFinishTime, count = msg.AllianceTaskTimes, confId = msg.AllianceTaskId})
            table.insert(AllianceData, {finishAt = msg.AllianceHelpTaskFinishTime, count = msg.AllianceHelpTaskTimes, confId = msg.AllianceHelpTaskId})
            inAlliance = msg.InAlliance
            for i = 1, itemNum do
                local cb = function()
                    self:SetOpen(false)
                    if not inAlliance then
                        JumpMap:JumpTo({jump = 811906, para = 0})
                        return
                    end
                    if i == 1 then
                        JumpMap:JumpSimple(811906)
                    elseif i == 2 then
                        JumpMap:JumpSimple(811904)
                    elseif i == 3 then
                        JumpMap:JumpSimple(811905)
                    end
                end
                list:GetChildAt(i - 1):InitAllianceAffairs(UnionType[i], cb, AllianceData[i], inAlliance)
            end
        end
    )
end

--福利领取
function Sidebar:WelfareList(index, data)
    self._list:GetChildAt(index).name = Type.Welfare
    local itemNum = data.total_num
    local allWelfare = {}
    local welfareList = {}
    for i = 1, itemNum do
        table.insert(allWelfare, WelfareType[i])
    end
    local isExist = BuildModel.CheckExist(Global.BuildingMilitarySupply)
    --是否存在军需处建筑
    if not isExist then
        table.insert(welfareList, WelfareType[2])
    end

    if WelfareModel.IsCumulativeAllGet() then
        table.insert(welfareList, WelfareType[4])
    end

    --删除多余元素
    for i = #allWelfare, 1, -1 do
        for _, v in ipairs(welfareList) do
            if v == allWelfare[i] then
                table.remove(allWelfare, i)
            end
        end
    end
    local mWelfareNum = #allWelfare
    local list = self:InitList(index, mWelfareNum, data.i18n)

    for i = 1, mWelfareNum do
        local cb = function()
            self:SetOpen(false)
            local t = allWelfare[i]
            if t == "Ui_Parking_Apron" then
                JumpMap:JumpSimple(811300, true)
            elseif t == "UI_Free_Supply" then
                JumpMap:JumpTo({jump = 811100, para = Global.BuildingMilitarySupply})
            elseif t == "Ui_Sign_In" then
                JumpMap:JumpSimple(811400)
            elseif t == "UI_Meeting_Gift" then
                TurnModel.Meeting_Gift()
            end
        end
        local title = allWelfare[i]
        local item = list:GetChildAt(i - 1)
        item.name = title
        item:InitWelfareCollection(title, cb)
    end
    self.allWelfare = allWelfare
end
-- 装备列表]
function Sidebar:EquipList(index, data)
    self._list:GetChildAt(index).name = Type.equip
    local itemNum = data.total_num
    local list = self:InitList(index, itemNum, data.i18n)
    for i = 1, itemNum do
        local confId = EquipType[i]
        local cb = function()
            self:SetOpen(false)
            JumpMap:JumpTo({jump = 820000, para1 = true})
            --UIMgr:Open("EquipmentMake")
        end
        list:GetChildAt(i - 1):InitEquip(confId, cb, EquipTypeContentIndex[i])
    end
end
--点击触发指引
function Sidebar:TriggerOnclick(callback)
        self.triggerFunc = callback
end

function Sidebar:MatchPos()
    if MathUtil.HaveMatch() then
        local mainUIPanel = UIMgr:GetUI("MainUIPanel")
        --self._arrow:AddRelation(self._btnArrow, RelationType.Center_Center)
        self._btnArrow:SetSize(self._btnArrow.width * 0.7, self._btnArrow.height * 0.7)
        self._arrow:SetScale(0.7, 0.7)
        self._groupArrow.y = mainUIPanel:GetBtnQueueLockPos()
    end
end

return Sidebar
