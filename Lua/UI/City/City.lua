--[[
    Author: songzeming
    Function: 城建相关 主界面
]]
local GD = _G.GD
local City = UIMgr:NewUI("City")

local GlobalVars = GlobalVars
local Emojies = import("Utils/Emojies")
local BuildModel = import("Model/BuildModel")
local EventModel = import("Model/EventModel")
local CommonModel = import("Model/CommonModel")
local FuncListModel = import("Model/FuncListModel")
local GuidePanelModel = import("Model/GuideControllerModel")
local SpecialBuildModel = import("Model/SpecialBuildModel")
local NoviceModel = import("Model/NoviceModel")
local GiftModel = import("Model/GiftModel")
local JumpMap = import("Model/JumpMap")
local TriggerGuide = import("Model/TriggerGuideLogic")
import("UI/City/MapRelated/CityMap")
import("UI/City/FunctionList/ItemCityFunction")
import("UI/City/ItemBuildImage")
import("UI/Loading/ToolTip")
import("UI/MainCity/BuildRelated/BuildNode/ItemBuild")
import("UI/MainCity/TroopsDetails")
import("UI/MainCity/ArchitecturalTree")
import("UI/Common/BtnCloseAll")
import("UI/Common/CuePoint")
local TaskModel = import("Model/TaskModel")
local WaterModel = import("Model/CityMap/WaterModel")
local MarchAnimModel = import("Model/MarchAnimModel")
local MarchLineModel = import("Model/MarchLineModel")
local UIType = _G.GD.GameEnum.UIType
local DailyTaskModel = import("Model/DailyTaskModel")
local WorldMapModel = import("Model/WorldMapModel")
local CustomEventManager = import("GameLogic/CustomEventManager")
local BuildNest = import("UI/MainCity/BuildRelated/BuildAnim/BuildNest")
local WelfareModel = import("Model/WelfareModel")
local Global = _G.Global
local UIMgr = _G.UIMgr
local Model = _G.Model
local Tool = _G.Tool
local BuildType = _G.BuildType
local PopupWindowQueue = _G.PopupWindowQueue

function City:OnInit()
    local view = self.Controller.contentPane
    CityMapModel.SetCityContext(self)
    self._middle = view:GetChild("Middle")
    self._middle:MakeFullScreen()
    self._map = self._middle:GetChild("Map")
    self._map:Init()
    ScrollModel.Init(self._middle)
    SystemSetModel.InitAudioVolume()
    Emojies.Init()
    TriggerGuide:Init()
    -- 点击详情显示界面
    self._itemDetail = UIMgr:CreateObject("Build", "CityComplete")
    self._map:AddChild(self._itemDetail)
    CityMapModel:SetComplete(self._itemDetail)
    GuidePanelModel:SetParentUI(self._itemDetail, UIType.CityCompleteUI)
    -- 主界面
    UIMgr:Open("MainUIPanel", self)
    SystemSetModel.InitSystemSetting()
    -- 滑动地图区域
    self:AddListener(
        self._middle.scrollPane.onScroll,
        function()
            if self.isClickItemFunc then
                --点击功能按钮 非滑动
                self.isClickItemFunc = false
                return
            end
            self:OnScrollMap(true)
        end
    )

    self:AddListener(
        self._middle.scrollPane.onScrollEnd,
        function()
            self:OnScrollMap(false)
        end
    )

    self:AddListener(
        self._middle.onTouchEnd,
        function()
            self:OnScrollMap(false)
        end
    )

    self:InitBuildings() -- 初始化建筑
    TurnModel.BuildCenter(false, true) --镜头移动到指挥中心
    self:InitCreateButtons() -- 初始化创建按钮
    --初始化在线奖励
    self.InitOnLineAward()
    --初始化科技研究完成奖励
    self.InitScienceAward()
    --初始化巨兽科技科技研究完成奖励
    self.InitBeastScienceAward()
    --日常任务红点
    self:InitDailyTaskRed()
    --事件监听
    self:OnEvent()
    --播放背景音乐
    AudioModel.Play(10001)
    WorldMapModel.MapBuildUIInit()
    MarchAnimModel.InitMarchPool()
    MarchLineModel.InitPool()
    --初始化天气特效
    WeatherModel.InitWeather()
    --河流特效
    WaterModel.ShowWater()
    --水坝特效
    WaterModel.ShowMatch()
    --喷泉特效
    WaterModel.ShowSpring()

    --检测是否跨天
    TimeUtil.CheckSecondDay()

    self.isReLogin = false
    TaskModel.InitGuideFreeData()

    CustomEventManager.Init()

    GlobalVars.CurrentKeyStep = Model.Player.GuideStep
    -- 启动动态资源下载
    DynamicRes.Sync()
    local isActivityOpen = WelfareModel.IsActivityOpen(WelfareModel.WelfarePageType.DAILY_ATTENDANCE)
    local isOpenOk = (GlobalVars.IsInCity or GlobalVars.IsInCityTrigger) and UIMgr:GetShowPanelCount() == 0 and not GlobalVars.IsNoviceGuideStatus
    if isActivityOpen and isOpenOk then
        WelfareModel.GetDailySignInfos(function(rsp)
            if Model.Player.Level >= Global.SignEverydayLevel and WelfareModel.IsActivityOpen(WelfareModel.WelfarePageType.DAILY_ATTENDANCE) then
                if not rsp.Signed then
                    self:ScheduleOnce(function()
                        PopupWindowQueue:Push("DailyAttendancePopup")
                    end, 1)
                end
            end
        end)
    end
    
    self:AddListener(Stage.inst.onTouchEnd,
        function(context)
            local target = context.sender.touchTarget
            Event.Broadcast(EventDefines.EndTouchGuide, target)
        end
    )
end

function City:OnEvent()
    self:AddEvent(
        EventDefines.UICityBuildTurn,
        function(confId, building, isAnime)
            self:BuildTurn(confId, building, isAnime)
        end
    )
    self:AddEvent(
        EventDefines.UICitySpecialBuildTurn,
        function(confId)
            self:OnSpecialBuildClick(confId)
        end
    )
    self:AddEvent(
        EventDefines.UICityTurnBuildCreate,
        function(pos, confId, isGuide)
            self:TurnBuildCreate(pos, confId, isGuide)
        end
    )
    self:AddEvent(
        EventDefines.NetOnDisconnected,
        function()
            self.isReLogin = false
        end
    )
    self:AddEvent(
        EventDefines.CloseNetLoading,
        function()
            UIMgr:Close("NetLoading")
        end
    )
    self:AddEvent(
        EventDefines.UICityBuildImage,
        function(img)
            self.image:SetImage(img)
        end
    )
    self:AddEvent(
        EventDefines.UICityAddBuild,
        function(building)
            self:AddBuilding(building)
        end
    )
    self:AddEvent(
        EventDefines.ReLoginSuccess,
        function()
            self.isReLogin = true
            self:RefreshCity()
        end
    )
    self:AddEvent(
        EventDefines.NoviceGuide,
        function(step, version)
            self:DoNoviceGuide(step, version)
        end
    )
    self:AddEvent( --设置新手引导下一步
        EventDefines.NoviceNextStep,
        function(step)
            local net_func = function()
                Model.Player.GuideStep = Model.Player.GuideStep + 1
                Event.Broadcast(EventDefines.NoviceGuide, Model.Player.GuideStep, Model.Player.GuideVersion)
            end
            local nextStep = step + 1
            local conf = NoviceModel.GetNoviceGuideByConfId(nextStep, Model.Player.GuideVersion)
            if conf then
                local isKey = conf.isKey
                local turnId = conf.turnId
                if isKey == 1 then
                    if turnId ~= nil and turnId.type == 3 then
                        GlobalVars.CurrentKeyStep = nextStep + 1
                        Net.Logins.SetGuideStep(nextStep + 1, Model.Player.GuideVersion, false, net_func)
                    elseif nextStep == 10039 and (Model.Player.GuideVersion == 0 or Model.Player.GuideVersion == 1) then
                        GlobalVars.CurrentKeyStep = 10038
                        Net.Logins.SetGuideStep(GlobalVars.CurrentKeyStep, Model.Player.GuideVersion, false, net_func)
                    elseif Model.Player.GuideVersion == 1 and nextStep == 10049 then
                        GlobalVars.CurrentKeyStep = 10051
                        Net.Logins.SetGuideStep(GlobalVars.CurrentKeyStep, Model.Player.GuideVersion, false, net_func)
                    else
                        GlobalVars.CurrentKeyStep = nextStep
                        if conf.type == _G.GD.GameEnum.NoviceType.End then
                            Net.Logins.SetGuideStep(GlobalVars.CurrentKeyStep, Model.Player.GuideVersion, true, net_func)
                        else
                            Net.Logins.SetGuideStep(GlobalVars.CurrentKeyStep, Model.Player.GuideVersion, false, net_func)
                        end
                    end
                else
                    if Model.Player.GuideStep >= 10014 then
                        Net.Logins.SetGuideStep(GlobalVars.CurrentKeyStep, Model.Player.GuideVersion, Model.Player.GuideFinished, net_func)
                    else
                        Model.Player.GuideStep = Model.Player.GuideStep + 1
                        Event.Broadcast(EventDefines.NoviceGuide, Model.Player.GuideStep, Model.Player.GuideVersion)
                    end
                end
            end
        end
    )
    self:AddEvent(
        EventDefines.ClosePanelAndBuilding,
        function()
            UIMgr:Close("MainUIPanel")
            Event.Broadcast(EventDefines.UIMainShow, false)
        end
    )
    self:AddEvent(
        EventDefines.OpenPanelAndBuilding,
        function()
            UIMgr:Open("MainUIPanel", self)
            Event.Broadcast(EventDefines.UIMainShow, true)
        end
    )
    --Boot steps触发引导入口
    self:AddEvent(
        EventDefines.TriggerGuideJudge,
        function(type, para1, para2)
            if not GlobalVars.IsOpenTriggerGuide then
                return
            end
            local triggerId = GD.TriggerGuideAgent.GetTriggerId(type, para1, para2)
            if #triggerId ~= 0 then
                for i = #triggerId, 1, -1 do
                    --判断是否已经触发过了，如果已经出发了就不再出发
                    local bActive = function()
                        for j = 1, #Model.Player.TriggerGuides do
                            if triggerId[i].Id == Model.Player.TriggerGuides[j].Id then
                                table.remove(triggerId, i)
                                return true
                            end
                        end
                        return false
                    end
                    if bActive() == false then
                        Net.Logins.SetTriggerGuideStep({Step = triggerId[i].Step, Id = triggerId[i].Id, Finish = false})
                        table.insert(Model.Player.TriggerGuides, {Step = triggerId[i].Step, Id = triggerId[i].Id, Finish = false})
                    else
                        if triggerId[i] then
                            Log.Warning("============>>>>{0}该引导已经触发过了,Step:{1}",triggerId[i].Id,triggerId[i].Step)
                        end
                    end
                end
                for i = #Model.Player.TriggerGuides, 1, -1 do
                    local triggerInfo = GD.TriggerGuideAgent.GetTriggerGuideByConfId(Model.Player.TriggerGuides[i].Id)
                    if not triggerInfo then
                        table.remove(Model.Player.TriggerGuides, i)
                    end
                end
                table.sort(
                    Model.Player.TriggerGuides,
                    function(a, b)
                        return a.Id < b.Id
                    end
                )
                Log.Warning("==============>>>>TriggerGuides{0}:",table.inspect(Model.Player.TriggerGuides))
                --开启了触发引导并且不在触发引导状态并且不在新手引导状态并且有引导可以触发
                if GlobalVars.IsTriggerStatus == false and GlobalVars.IsNoviceGuideStatus == false and #triggerId ~= 0 then
                    Event.Broadcast(EventDefines.TriggerAllPanelClose)
                end
            end
        end
    )
    self:AddEvent(
        EventDefines.TriggerAllPanelClose,
        function()
            if GlobalVars.IsInCityTrigger == true and GlobalVars.IsNoviceGuideStatus == false and not GlobalVars.IsSidebarOpen and not GlobalVars.IsTaskPlotAnim then
                Event.Broadcast(EventDefines.GuideMask, true)
                self:RemainTriggerGuideJudge()
            end
        end
    )
    self:AddEvent( --设置触发引导下一步
        EventDefines.TriggerGuideNextStep,
        function(id, step)
            if GlobalVars.IsInCityTrigger == true then
                Event.Broadcast(EventDefines.GuideMask, true)
                local net_func = function()
                    GD.TriggerGuideAgent.SetLocalTriggerData(id, step)
                    Event.Broadcast(EventDefines.TriggerGuideDo, id, step)
                end
                step = step + 1
                local conf = NoviceModel.GetNoviceGuideByConfId(id + step)
                if conf then
                    local isKey = conf.isKey
                    if isKey == 1 then
                        Net.Logins.SetTriggerGuideStep({Step = step, Id = id, Finish = false}, net_func)
                    elseif isKey == 2 then
                        Net.Logins.SetTriggerGuideStep({Step = step, Id = id, Finish = true}, net_func)
                    else
                        Log.Warning("=========>>>city:EventDefines.TriggerGuideNextStep:{0}", (id + step))
                        Event.Broadcast(EventDefines.TriggerGuideDo, id, step)
                    end
                end
            end
        end
    )

    --开始执行触发引导
    self:AddEvent(
        EventDefines.TriggerGuideDo,
        function(id, step)
            if GlobalVars.IsInCityTrigger == true then
                Log.Warning("================>>>>City:EventDefines.TriggerGuideDo:{0}",(id+step))
                self:DoTriggerGuide(id, step)
            end
        end
    )
    self:AddEvent(
        EventDefines.GuideCompGuideFunc,
        function(callBack)
            if callBack then
                self.completeFunc = callBack
            end
        end
    )

    --self:AddEvent(
    --    EventDefines.TwelveHourTriggerFinish,
    --    function()
    --        Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.SendSoldierEnd, 14300, 0)
    --    end
    --)

    self:AddEvent(
        EventDefines.KingkongTriggerFinish,
        function()
            local building = BuildModel.FindByConfId(Global.BuildingBeastBase)
            if not building then
                return
            end
            for _, v in pairs(Model.Player.TriggerGuides) do
                if v.Finish == true and v.Id == 14700 then
                    Model.Player.isUnlockKingkong = true
                    local itemBuild = BuildModel.GetObject(building.Id)
                    itemBuild:InitShowData()
                    BuildNest.CheckNestUnlock(Global.BuildingKingkong)
                    break
                end
            end
            Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.SendSoldierEnd, 14700, 0)
        end
    )
    
    self:AddEvent(
        EventDefines.SkipNoviceGuide, 
        function()
            City.errorDealFunc()
        end    
    )

    self:AddEvent(
        EventDefines.NoviceGuideBuildUpgrade,
        function(buildConfId)
            if GlobalVars.IsNoviceGuideStatus == true then
                --Log.Error("新手引导建造成功。。。")
                local NoviceInfo = NoviceModel.GetNoviceGuideByConfId(Model.Player.GuideStep, Model.Player.GuideVersion)
                if NoviceInfo.turnId == nil then
                    --Log.Error("步驟少了。。。拉回正確的步驟")
                    if Model.Player.GuideStep < 10018 then
                        Model.Player.GuideStep = 10018
                    elseif Model.Player.GuideStep > 10018 and Model.Player.GuideStep < 10023 then
                        Model.Player.GuideStep = 10023
                    elseif Model.Player.GuideStep > 10023 and Model.Player.GuideStep < 10028 then
                        Model.Player.GuideStep = 10028
                    elseif Model.Player.GuideStep > 10028 and Model.Player.GuideStep < 10037 and Model.Player.GuideVersion < 2 then
                        Model.Player.GuideStep = 10037
                    elseif Model.Player.GuideStep > 10028 and Model.Player.GuideStep < 10036 and Model.Player.GuideVersion == 3 then
                        Model.Player.GuideStep = 10036
                    elseif Model.Player.GuideStep > 10037 and Model.Player.GuideStep < 10049 and Model.Player.GuideVersion == 0 then
                        Model.Player.GuideStep = 10049
                    elseif Model.Player.GuideStep > 10037 and Model.Player.GuideStep < 10057 and Model.Player.GuideVersion == 1 then
                        Model.Player.GuideStep = 10057
                    end
                end
                Log.Warning("buildend nextStep--------------------------{0}", Model.Player.GuideStep)
                if (Model.Player.GuideVersion == 1 or Model.Player.GuideVersion == 2 or Model.Player.GuideVersion == 3) and buildConfId == 400000 then
                    Event.Broadcast(EventDefines.BuildingCenterUpgradeNovice)
                    Event.Broadcast(EventDefines.NextNoviceStep,1009)
                else
                    NoviceModel:NextStep()
                end
            end
        end
    )
end

function City:OnOpen()
    Event.Broadcast(EventDefines.IsInCity)
    self.uploadStep = 0
    self:RefreshCity()
    
    self._middle:ResetCharacterState()

    --GM
    if GlobalVars.IsDevelop then
        UIMgr:Open("GM")
    end
    --检测是否打开侧边栏
    UnlockModel:UnlockWall(UnlockModel.Wall.Sidebar)
    Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.NoTrigger, 400000, Model.Player.Level)
    --加入帮会提示
    -- if Model.Player.AllianceJoinRecommend then
    --     UnionModel.CheckJoinPush(nil, nil, nil, true)
    -- end
    GiftModel:CheckGiftPush()

    self:ScheduleOnceFast(
        function()
            self._middle:OnScrollMap()
        end,
        0.5
    )
end

function City:OnClose()
    UIMgr:Close("SidebarRelated/Sidebar")
end

function City:RefreshCity()
    UIMgr:Open("MainUIPanel", self)

    self._middle:InitMap()
    BuildModel.UpgradePrompt()
    
    if ABTest.Task_ABLogic() == 2001 then
        Model.Player.GuideVersion = 2
    elseif ABTest.Task_ABLogic() == 2002 then
        Model.Player.GuideVersion = 3
    else
        if ABTest.NoviceGuideDiffVersion() == true then
            Model.Player.GuideVersion = 1        
        else
            Model.Player.GuideVersion = 0
        end
    end
    -- Model.Player.GuideVersion = 2
    if Model.Player.GuideVersion == 1 and (Model.Player.GuideStep >= 10045 and Model.Player.GuideStep < 10051) then
        local item = GD.ItemAgent.GetItemModelById(200512)
        if not item then
            Model.Player.GuideStep = 10051
        else
            Model.Player.GuideStep = 10045
        end
    elseif Model.Player.GuideVersion == 2 and (Model.Player.GuideStep >= 10038 and Model.Player.GuideStep < 10044) then
        local item = GD.ItemAgent.GetItemModelById(200512)
        if not item then
            Model.Player.GuideStep = 10044
        else
            Model.Player.GuideStep = 10038
        end
    elseif Model.Player.GuideVersion == 3 and (Model.Player.GuideStep >= 10037 and Model.Player.GuideStep < 10043) then
        local item = GD.ItemAgent.GetItemModelById(200512)
        if not item then
            Model.Player.GuideStep = 10043
        else
            Model.Player.GuideStep = 10037
        end
    end
    if Model.Player.GuideVersion == 1 and Model.Player.GuideStep == 10044 and Model.Player.Level == 2 then
        Model.Player.GuideStep = 10045
    elseif Model.Player.GuideVersion == 2 and Model.Player.GuideStep == 10037 and Model.Player.Level == 2 then
        Model.Player.GuideStep = 10038
    elseif Model.Player.GuideVersion == 3 and Model.Player.GuideStep == 10036 and Model.Player.Level == 2 then
        Model.Player.GuideStep = 10037
    end
    local noviceInfo = NoviceModel.GetNoviceGuideByConfId(Model.Player.GuideStep, Model.Player.GuideVersion)
    if GlobalVars.IsOpenNoviceGuide and noviceInfo and noviceInfo.type ~= _G.GD.GameEnum.NoviceType.End then
        self:DoNoviceGuide(Model.Player.GuideStep, Model.Player.GuideVersion)
    else
        --初始化弹窗
        self:InitPopupWindow()
    end

    --巨兽巢穴升级梯级提升弹窗
    BuildModel.CheckMonsterUpgradingPopup()
    
    GD.TriggerGuideAgent.OnInitTriggerData()

    self:RemainTriggerGuideJudge()
end

--Boot steps判断有没有没有完成的触发式引导
function City:RemainTriggerGuideJudge()
    -- triggerGuide
    if #Model.Player.TriggerGuides == 0 or GlobalVars.NowTriggerId ~= 0 or GD.TriggerGuideAgent.CityHaveStashTriggerJudge() == false then
        Log.Warning("=======================>>>>没有缓存的触发引导{0}：",table.inspect(Model.Player.TriggerGuides))
        Event.Broadcast(EventDefines.GuideMask, false)
        return
    end
    Log.Warning("=======================>>>>有缓存的触发引导{0}：",table.inspect(Model.Player.TriggerGuides))
    for _, v in pairs(Model.Player.TriggerGuides) do
        local triggerInfo = GD.TriggerGuideAgent.GetTriggerGuideByConfId(v.Id)
        if triggerInfo and v.Finish == false and v.Id ~= GlobalVars.NowTriggerId and (triggerInfo.inCity == 1 or triggerInfo.inCity == 2) and GlobalVars.IsInCityTrigger == true then
            if triggerInfo.isCloseWindow == 1 then
                --特殊处理章节任务弹窗
                if UIMgr:GetUIOpen("TaskPlot") then
                    UIMgr:Close("TaskPlot")
                end
                GlobalVars.NowTriggerId = v.Id
                --关闭移动建筑的相关功能
                if CityType.BUILD_MOVE_TIP then
                    Event.Broadcast(EventDefines.UICityBuildMove, BuildType.MOVE.Reset)
                end
                UIMgr:ClosePopAndTopPanel()
                Event.Broadcast(EventDefines.TriggerGuideDo, v.Id, v.Step)
                break
            else
                GlobalVars.NowTriggerId = v.Id
                Event.Broadcast(EventDefines.TriggerGuideDo, v.Id, v.Step)
                break
            end
        end
    end
end

function City.errorDealTriggerFunc()
    Log.Error("10秒无操作退出引导")
    Event.Broadcast(EventDefines.ClearTrigger)
end

--Boot steps开始执行触发引导
function City:DoTriggerGuide(id, step)
    Log.Warning("=================>>>City:DoTriggerGuide:{0}",(id + step))
    local noviceInfo = NoviceModel.GetNoviceGuideByConfId(id + step)
    local triggerInfo = GD.TriggerGuideAgent.GetTriggerGuideByConfId(id)
    if not noviceInfo or not triggerInfo then
        return
    end
    if ABTest.GuideSkipAB_Logic() == 5002 then
        if City.errorDealTriggerFunc then
            self:UnScheduleFast(City.errorDealTriggerFunc)
            self:ScheduleOnceFast(City.errorDealTriggerFunc, 10)
        else
            self:ScheduleOnceFast(City.errorDealTriggerFunc, 10)
        end
    end
    --触发引导不是结束类型的且是在内城触发类型的
    if noviceInfo.type ~= _G.GD.GameEnum.NoviceType.TriggerEnd and (triggerInfo.inCity == 1 or triggerInfo.inCity == 2) and GlobalVars.IsInCityTrigger == true then
        GlobalVars.IsTriggerStatus = true
        GlobalVars.IsAllowPopWindow = false
        local noviceVisible = UIMgr:GetUIOpen("Novice")
        local uiNovice = UIMgr:GetUI("Novice")
        if noviceInfo.type == _G.GD.GameEnum.NoviceType.TriggerStart then
            --金刚到达触发巨兽基地引导特殊处理
            if id == 15700 then
                if BuildModel.GetBuildLock(Global.BuildingBeastBase) then
                    Event.Broadcast(EventDefines.TriggerGuideNextStep, id, step)
                else
                    Event.Broadcast(EventDefines.ClearTrigger)
                    Net.Logins.SetTriggerGuideStep({Step = step, Id = id, Finish = true})
                end
            else
                Event.Broadcast(EventDefines.TriggerGuideNextStep, id, step)
            end
        else
            if noviceInfo.type == _G.GD.GameEnum.NoviceType.TriggerDialog then
                Event.Broadcast(EventDefines.CloseClipGuideRender)
            end

            if noviceVisible == true then
                --金刚引导AB特殊处理
                if (id == 14500 and step == 9) or (id == 14600 and step == 9) then
                    local marchInfo = MarchAnimModel.GetMarchInfo(id)
                    if marchInfo then 
                        local pos = marchInfo.unit.transform.localPostion
                        WorldMap.Instance():GotoPoint(pos.x,pos.z)
                    end
                    WorldMap.AddEventAfterMap(
                        function()
                            WorldMap.Instance():ClickMarchUnit(1003)
                            uiNovice:TriggerGuideShowMessage(id, step)
                        end
                    )
                else --其它触发类型若是novice页面打开都通过novice页面
                    uiNovice:TriggerGuideShowMessage(id, step)
                end
            else
                --主动技能说明引导特殊处理
                if id == 11700 and step == 5 then
                    self:ScheduleOnce(
                        function()
                            NoviceModel.CloseUI()
                            UIMgr:Open("Novice", id, step)
                        end,
                        1
                    )
                --金刚AB引导特殊处理
                elseif (id == 14500 and step == 1) or (id == 14600 and step == 1) then
                    --屏幕泛红
                    Event.Broadcast(EventDefines.KingkongTrigger, true)
                    UIMgr:Open("Novice", id, step)
                --防御武器引导特殊处理
                elseif id == 12500 and step == 1 then
                    --屏幕泛红
                    Event.Broadcast(EventDefines.DefenceCenterTrigger, true)
                    UIMgr:Open("Novice", id, step)
                else
                    local doTriggerId = id + step
                    --特殊处理大地图跳转对话
                    if doTriggerId == 14205 then
                        WorldMap.AddEventAfterMap(
                            function()
                                UIMgr:Open("Novice", id, step)
                                local marchInfo = MarchAnimModel.GetMarchInfo(id)
                                if marchInfo then 
                                    local pos = marchInfo.unit.transform.localPostion
                                    WorldMap.Instance():GotoPoint(pos.x,pos.z)
                                end
                                WorldMap.Instance():ClickMarchUnit(1002)
                            end
                        )
                    else
                        UIMgr:Open("Novice", id, step)
                    end
                end
            end
        end
    else  --触发引导结束类型走一下方法
        if (id == 14500 and step == 10) or (id == 14600 and step == 10) then
            UIMgr:RemovePackage("KingKongBg")
        end
        if id == 15000 or id == 15100 then
            JumpMap:JumpSimple(816000)
        end
        if id == 15000 and step == 10 then
            Event.Broadcast(EventDefines.ClearTrigger)
        end
        if City.errorDealTriggerFunc then
            self:UnScheduleFast(City.errorDealTriggerFunc)
        end
        GlobalVars.IsTriggerStatus = false
        GlobalVars.IsAllowPopWindow = true
        NoviceModel.CloseUI()
        GlobalVars.NowTriggerId = 0
        for i = 1, #Model.Player.TriggerGuides do
            if Model.Player.TriggerGuides[i].Finish == false then
                if Model.Player.TriggerGuides[i].Id == id then
                    Model.Player.TriggerGuides[i].Finish = true
                    break
                end
            end
        end
        if GD.TriggerGuideAgent.CityHaveStashTriggerJudge() == false then
            Event.Broadcast(EventDefines.GuideMask, false)
        end
        if id == 14700 and ABTest.Task_ABLogic() == 2002 and ABTest.GodzilaGuideAB_Logic() == 6002 then
            if BuildModel.GetBuildLock(Global.BuildingBeastBase) then
                local building = BuildModel.FindByConfId(Global.BuildingBeastBase)
                local itemBuild = BuildModel.GetObject(building.Id)
                itemBuild._btnIcon:ChangeLockStatus()
                Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.OpenUI, 15700, 0)
            end
        end
    end
    SdkModel.ReportEvent("trigger_guide", id + step)
end

function City.errorDealFunc()
    local uiNovice = UIMgr:GetUI("Novice")
    if uiNovice then
        uiNovice:RemoveCharacter()
    end
    if ABTest.Task_ABLogic() == 2002 then
        Event.Broadcast(SYSTEM_SETTING_EVENT.HideTaskLable, true)
    end
    if Model.Player.GuideVersion == 0 then
        Model.Player.GuideStep = 10049
    elseif Model.Player.GuideVersion == 1 then
        Model.Player.GuideStep = 10059
    elseif Model.Player.GuideVersion == 2 then
        Model.Player.GuideStep = 10043
    elseif Model.Player.GuideVersion == 3 then
        Model.Player.GuideStep = 10049
    end
    NoviceModel.SetIsSkip(true)
    NoviceModel:NextStep()
end
function City:DoNoviceGuide(step, version)
    --Log.Error("novicestep--------------{0}", Model.Player.GuideStep)
    if Model.Player.GuideFinished == true then
        -- Log.Error("GuideFinished--------------")
        return
    end
    local noviceInfo = NoviceModel.GetNoviceGuideByConfId(step, version)

    if Model.Player.GuideStep > 10013 and ABTest.GuideSkipAB_Logic() == 5002 then
        if City.errorDealFunc then
            -- Log.Error("---------------------------------")
            self:UnScheduleFast(City.errorDealFunc)
            self:ScheduleOnceFast(City.errorDealFunc, 10)
        else
            self:ScheduleOnceFast(City.errorDealFunc, 10)
        end
    end

    if self.isReLogin == true and noviceInfo.isKey == 0 then
        self.isReLogin = false
        return
    end

    self.isReLogin = false
    if noviceInfo.type ~= _G.GD.GameEnum.NoviceType.End then
        GlobalVars.IsNoviceGuideStatus = true
        GlobalVars.IsAllowPopWindow = false
        local uiNovice = UIMgr:GetUI("Novice")
        if uiNovice then
            uiNovice:UpdateShowMessage()
        else
            UIMgr:Open("Novice")
        end
        if noviceInfo.type == _G.GD.GameEnum.NoviceType.Start then
            local step = Model.Player.GuideStep
            Model.Player.GuideStep = step + 10000
            SdkModel.ReportEvent("novice", step, Model.Player.GuideVersion)
            Event.Broadcast(EventDefines.NoviceNextStep, Model.Player.GuideStep, Model.Player.GuideVersion)
        else
            if Model.Player.GuideStep < self.uploadStep then
                assert(Model.Player.GuideStep < self.uploadStep, "本次上报步骤比上次小，错了错了")
            end
            SdkModel.ReportEvent("novice", Model.Player.GuideStep, Model.Player.GuideVersion)
        end
        if Model.Player.GuideStep < 10013 and AudioModel.MusicId ~= 10004 then
            AudioModel.Play(10004)
        end
        if Model.Player.GuideStep >= 10013 and AudioModel.MusicId ~= 10001 then
            AudioModel.Play(10001)
        end
        if ABTest.Task_ABLogic() == 2002 then
            if Model.Player.GuideStep < 10032 then
                Event.Broadcast(SYSTEM_SETTING_EVENT.HideTaskLable, false)
            else
                Event.Broadcast(SYSTEM_SETTING_EVENT.HideTaskLable, true)
            end
        end
    else
        if City.errorDealFunc then
            self:UnScheduleFast(City.errorDealFunc)
        end
        Model.Player.GuideFinished = true
        AudioModel.Play(10001)
        UIMgr:RemovePackage("NoviceImage")
        UIMgr:Close("GuideLayer")
        UIMgr:Close("UIMaskManager")
        Event.Broadcast(EventDefines.Mask, false)
        Event.Broadcast(EventDefines.GuideMask, false)
        Event.Broadcast(EventDefines.TriggerAllPanelClose)
        GlobalVars.IsNoviceGuideStatus = false
        GlobalVars.IsAllowPopWindow = true
        if Model.Player.GuideStep < self.uploadStep then
            assert(Model.Player.GuideStep < self.uploadStep, "本次上报步骤比上次小，错了错了")
        end
        SdkModel.ReportEvent("novice", Model.Player.GuideStep, Model.Player.GuideVersion)
    end
    self.uploadStep = Model.Player.GuideStep 
end

-- 初始化在线奖励
function City.InitOnLineAward()
    if not Model.NextBonusTime then
        return
    end
    local bonusTime = Model.NextBonusTime

    local level = Model.Player.Level
    if level < Global.UnlockLevelBase4 then
        Event.Broadcast(EventDefines.UIGiftFinish, false)
    elseif level >= Global.UnlockLevelBase4 then
        if bonusTime > Tool.Time() then
            Event.Broadcast(EventDefines.UIGiftFinishing, bonusTime)
        else
            Event.Broadcast(EventDefines.UIGiftFinish, true)
        end
    end
end

-- 初始化弹窗
function City:InitPopupWindow()
    --指挥中心升级弹窗
    if next(Model.CenterUpgradeGifts) ~= nil then
        table.sort(
            Model.CenterUpgradeGifts,
            function(a, b)
                return a < b
            end
        )
        for k, v in ipairs(Model.CenterUpgradeGifts) do
            PopupWindowQueue:Push("BuildCenterUpgrade", v)
        end
        Model.CenterUpgradeGifts = {}
    end
end

-- 初始化科技研究完成奖励
function City.InitScienceAward()
    if Model.ResearchGift then
        -- 显示科技完成奖励气泡
        for _, v in pairs(Model.Buildings) do
            if v.ConfId == Global.BuildingScience then
                BuildModel.GetObject(v.Id):ScienceAwardAnim(true)
            end
        end
    end
end

-- 初始化巨兽科技研究完成奖励
function City.InitBeastScienceAward()
    if Model.BeastResearchGift then
        -- 显示巨兽科技完成奖励气泡
        for _, v in pairs(Model.Buildings) do
            if v.ConfId == Global.BuildingBeastScience then
                BuildModel.GetObject(v.Id):ScienceAwardAnim(true)
            end
        end
    end
end

-- --日常红点提示数据赋值
function City:InitDailyTaskRed()
    DailyTaskModel.GetDailyRedData(function()
    Event.Broadcast(EventDefines.UITaskRefreshRed)
    end)
end

-- 初始化创建按钮
function City:InitCreateButtons()
    self.image = UIMgr:CreateObject("Common", "itemBuildImage")
    self.image.sortingOrder = CityType.CITY_MAP_NODE_TYPE.Build.sortingOrder
    self._map:AddChild(self.image)
    local btn_func = function(pos)
        local piece = self._map:GetMapPiece(pos)
        if not piece then
            return
        end
        CityMapModel.SetMapPiece(pos, piece)
        local click_func = function()
            local lastPiece = ScrollModel.GetLastScalePiece()
            if lastPiece then
                if pos == lastPiece:GetPiecePos() then
                    GlobalVars.ClickBuildFunction = true
                end
            else
                GlobalVars.ClickBuildFunction = true
            end

            self._itemDetail:OffAnim(true)
            self:BuildCreate(pos, piece)
        end
        piece:InitPiece(pos, click_func)
    end
    --内城
    local innerPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneInnter)
    for i = innerPosConf.start_pos + 1, innerPosConf.stop_pos do
        btn_func(i)
    end
    --外城
    local outerPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneWild)
    for i = outerPosConf.start_pos + 1, outerPosConf.stop_pos do
        btn_func(i)
    end
    --巨兽
    local beastPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneBeast)
    for i = beastPosConf.start_pos + 1, beastPosConf.stop_pos do
        btn_func(i)
    end
    --巢穴
    local nestPosConf = ConfigMgr.GetItem("configBuildingPoss", Global.BuildingZoneNest)
    for i = nestPosConf.start_pos + 1, nestPosConf.stop_pos do
        btn_func(i)
    end
    --初始化未解锁地块区域
    self._map:InitUnlockArea()
end

-- 初始化建筑
function City:InitBuildings()
    local center
    for _, v in pairs(Model.Buildings) do
        if v.ConfId == Global.BuildingCenter then
            center = v
        else
            self:AddBuilding(v)
        end
    end
    self:AddBuilding(center)
end

-- 添加建筑对象
function City:AddBuilding(building)
    local node = UIMgr:CreateObject("Build", "itemBuild")
    BuildModel.AddObject(building.Id, node)
    local parentNode = self._map[CityType.CITY_MAP_NODE_TYPE.Build.name]
    parentNode:AddChild(node)
    local piece = self._map:GetMapPiece(building.Pos)
    if not piece then
        return
    end
    piece:SetPieceBuild(true)
    node:SetXY(piece.x, piece.y)
    node:InitBuild(building)
end

local isOnceClick = false
-- 点击建筑展示(或者地图导航)功能列表
function City:ShowFuncList(building, isJump)
    self.building = building
    local node = BuildModel.GetObject(building.Id)
    if not node then
        return
    end
    local piece = self._map:GetMapPiece(building.Pos)
    if not piece then
        return
    end
    local dataDetai = {
        building = building,
        x = node.x,
        y = node.y - piece.height / 3
    }
    local click_func = function(t)
        GlobalVars.ClickBuildFunction = true
        GuidePanelModel:CheackCompleteBtn(t)
        self.isClickItemFunc = true
        if t == "Detail" then
            UIMgr:Open("BuildRelated/BuildDetail", building)
        elseif t == "Upgrade" then
            UIMgr:Open("BuildRelated/BuildUpgrade", building.Pos)
        elseif Tool.Equal(t, "TrainTank", "TrainChariot", "TrainHelicopter", "TrainVehicle", "Produce") then
            TurnModel.TrainArmy(building)
        elseif Tool.Equal(t, "BuildingItemSpeedup", "TrainItemSpeedup", "ProduceItemSpeedup", "ResearchItemSpeedup") then
            FuncListModel.ItemSpeedup(building)
        else
            FuncListModel[t](building)
        end
    end

    if isJump and GuidePanelModel:GetBid() == self.building.Id then
        Event.Broadcast(EventDefines.JumpTipEvent, self.building, -1, UIType.CityCompleteUI, self.building.Id)
        local delayTime = GuidePanelModel.GetBuildDealyTime()
        isOnceClick = true
        node:SetCutChooseAnim(false)
        local onceFrameTime = Global.GuideClickShieldTime
        --时间变快2.5倍
        self._itemDetail._animIn.timeScale = 2.5
        --延迟3秒可以点击
        self:ScheduleOnceFast(
            function()
                isOnceClick = false
            end,
            onceFrameTime
        )
        self:ScheduleOnce(
            function()
                self._itemDetail:CityInit(dataDetai, click_func, self.completeFunc)
                UIMgr:Close("BuildRelated/BuildCreate")
            end,
            delayTime - 0.3
        )
    else
        if isOnceClick and GuidePanelModel.isBeginGuide and GuidePanelModel.uiType == UIType.CityCompleteUI then
            node:SetCutChooseAnim(true)
            node:SetPlayChooseAnim()
            return
        elseif GuidePanelModel.isBeginGuide and GuidePanelModel.uiType == UIType.CityCompleteUI then
            node:SetCutChooseAnim(true)
        else
            isOnceClick = false
            node:SetCutChooseAnim(false)
            self._itemDetail._animIn.timeScale = 1
        end
        self._itemDetail:CityInit(dataDetai, click_func)
        UIMgr:Close("BuildRelated/BuildCreate")
    end
end

-- 建造建筑
function City:BuildCreate(pos, btn, confId)
    local posType = BuildModel.GetBuildPosTypeByPos(pos)
    if posType == Global.BuildingZoneInnter then
        if next(BuildModel.InnerCreateConf(true, pos)) == nil then
            --城内建筑 没有可创建建筑
            TipUtil.TipById(50066)
            return
        end
    end
    if posType == Global.BuildingZoneWild then
        self.image:SetXY(btn.x, btn.y - 24)
    else
        self.image:SetXY(btn.x, btn.y)
    end
    if not UIMgr:GetUIOpen("TaskPlot") then
        UIMgr:Open("BuildRelated/BuildCreate", pos, confId)
    end
end

-- 建筑跳转
function City:BuildTurn(goalConfId, building, isAnime)
    if not building then
        building = BuildModel.FindByConfId(goalConfId)
    end
    if not building then
        --没有建筑 走推荐跳转建造
        self:TurnBuildCreate(nil, goalConfId)
        return
    end
    --已建造该建筑 跳转该建筑
    --获取地图块
    local piece = self._map:GetMapPiece(building.Pos)
    if not piece then
        return
    end
    ScrollModel.MoveScale(piece, building.ConfId, nil, isAnime)

    local event = EventModel.GetEvent(building)
    if event then
        local time = event.FinishAt - Tool.Time()
        local category = event.Category
        if BuildModel.FreeState(category) then
            -- 建筑建造、升级、移除 [免费]时直接完成事件
            local freeTime = CommonModel.FreeTime()
            if time <= freeTime then
                BuildModel.GetObject(building.Id):BuildClick()
                return
            end
        elseif category == EventType.B_TRAIN or category == EventType.B_EQUIPTRAN then
            -- 建筑训练 [训练完成]时不弹功能列表窗
            if time <= 0 then
                BuildModel.GetObject(building.Id):BuildClick()
                return
            end
        end
    end
    local funcs = BuildModel.GetConf(building.ConfId).funcs
    if funcs then
        self:ScheduleOnceFast(
            function()
                local buildObj = BuildModel.GetObject(building.Id)
                buildObj:ShowBuildFuncList(true)
            end,
            GlobalVars.ScrollDelayTime
        )
    else
        self:OnSpecialBuildClick(building.ConfId)
    end
end

-- 滑动地图区域
function City:OnScrollMap(flag)
    if GlobalVars.IsRestar then
        return
    end

    if Tool.EqualBool(flag, self.scrollingMap) then
        return
    end
    self.scrollingMap = flag
    
    
    if self.hide_func then
        self:UnSchedule(self.hide_func)
        self.hide_func = nil
    end
    
    if flag then
        if self.nameVisible then
            return
        end
        self.nameVisible = true
        
        local confId
        if self._itemDetail:GetFuncVisible() then
            confId = self._itemDetail:GetConfId()
        end
        for _, v in pairs(BuildModel.GetAllObject()) do
            v:ShowName(confId ~= v:GetBuilding().ConfId)
        end
    else
        self.hide_func = function()
            self.nameVisible = false
            for _, v in pairs(BuildModel.GetAllObject()) do
                v:ShowName(false)
            end
        end
        self:ScheduleOnce(self.hide_func, BuildType.NAME_SHOW_TIME)
    end
end

--跳转建筑创建
function City:TurnBuildCreate(pos, confId, isGuide)
    local posType
    if not pos then
        pos = BuildModel.GetCreatPos(confId)
        posType = BuildModel.GetBuildPosType(confId)
    else
        posType = BuildModel.GetBuildPosTypeByPos(pos)
    end
    local piece = self._map:GetMapPiece(pos)
    if not piece then
        return
    end
    if posType == Global.BuildingZoneInnter then
        --城内
        self:BuildCreate(pos, piece, confId, isGuide)
    elseif posType == Global.BuildingZoneWild then
        --城外
        if piece:GetPieceUnlock() then
            self:BuildCreate(pos, piece, confId, isGuide)
        else
            TurnModel.MapLockPiece()
        end
    elseif posType == Global.BuildingZoneBeast then
        --巨兽
        self:BuildCreate(pos, piece, confId, isGuide)
    end
end

--点击特殊建筑
function City:OnSpecialBuildClick(confId)
    self._itemDetail:SetFuncVisible(false)
    SpecialBuildModel.OnBuildClick(confId)
end

return City
