--[[
    author:{zhanzhang}
    time:2020-05-19 20:47:46
    function:{自定义事件管理器}
]]
local CustomEventManager = {}

local CustomEventName = {
    CE_NPC_ATTACK = 1001,
    CE_NPC_RALLY = 1002,
    CE_NPC_KINGKONG = 1003,
    CE_NPC_CARE = 1004
}
local CustomEventFuncList = {}
local RadarModel = import("Model/RadarModel")
local MarchLineModel = import("Model/MarchLineModel")
local MarchAnimModel = import("Model/MarchAnimModel")
local WorldMap = import("UI/WorldMap/WorldMap")

local CustomEventInfos = {}
local GuidePoint = 0

local IsGMQuick = false
local IsKingKongGuide = false
---------------------局部方法----------
local function CustomEventRefresh(callback)
    --请求事件信息
    _G.Net.CustomEvents.Infos(
        function(rsp)
            for _, v in pairs(rsp.CustomEvents) do
                if v.Name == CustomEventName.CE_NPC_KINGKONG then
                    IsKingKongGuide = true
                end

                CustomEventManager.RefreshCustomEvent(v)
            end

            if callback then
                callback()
            end
            IsGMQuick = false

            if not IsKingKongGuide then
                CustomEventManager.CheckKingKongGuide()
            end
        end
    )
    Event.Broadcast(EventDefines.CareSystemMarchAnim)
end
local FinishDefend = function()
    _G.Net.CustomEvents.Process(CustomEventName.CE_NPC_ATTACK)
    CustomEventManager.DelCustomEvent(CustomEventName.CE_NPC_ATTACK)
end
local FinishAssit = function()
    CustomEventManager.DelCustomEvent(CustomEventName.CE_NPC_RALLY)
    -- _G.Log.Error("引导结束，发送消息")
    _G.Net.CustomEvents.Process(CustomEventName.CE_NPC_RALLY)
    _G.Event.Broadcast(_G.EventDefines.TwelveHourTriggerFinish)
end
local FinishKingKong = function()
    CustomEventManager.DelCustomEvent(CustomEventName.CE_NPC_KINGKONG)
    _G.Net.CustomEvents.Process(
        CustomEventName.CE_NPC_KINGKONG,
        function()
            Log.Info("金刚消息收到")
        end
    )
    _G.Event.Broadcast(_G.EventDefines.KingkongTriggerFinish)
end
local FinishCareSystem = function()
    CustomEventManager.DelCustomEvent(CustomEventName.CE_NPC_CARE)
end

--创建防御引导 ----------------------------------------------------------------------------------------------
local function CreateDefenceTrigger(data)
    if data.FinishAt < _G.Tool.Time() then
        _G.Log.Debug("该行军事件已经结束")
        _G.Net.CustomEvents.Process(
            CustomEventName.CE_NPC_ATTACK,
            function()
                CustomEventManager.DelCustomEvent(CustomEventName.CE_NPC_ATTACK)
            end
        )
        return
    end
    GuidePoint = _G.MathUtil.GetPosNum(_G.Model.Player.X, _G.Model.Player.Y)
    local guideStopX = _G.Model.Player.X + 100
    if guideStopX > 1200 - _G.mapOffset then
        guideStopX = guideStopX - 200
    end
    local data = {
        AllianceBattleId = "",
        ArmyTotal = 100,
        ArmyTypes = {107100},
        Category = _G.Global.MissionAttack,
        CreatedAt = data.CreatedAt,
        Duration = data.FinishAt - data.CreatedAt,
        IsCancel = false,
        IsRally = false,
        IsReturn = false,
        OwnerId = "",
        FinishAt = IsGMQuick and (_G.Tool.Time() + 10) or data.FinishAt,
        SpeedChangeAt = data.CreatedAt,
        SpeedChangeDistance = 0,
        StartPointSize = 1,
        StartX = guideStopX,
        StartY = _G.Model.Player.Y,
        StopPointSize = 2,
        StopX = _G.Model.Player.X,
        StopY = _G.Model.Player.Y,
        TargetAllianceId = "",
        TargetMapType = 4,
        TargetName = _G.Model.Player.Name,
        TargetOwnerId = _G.Model.Account.accountId,
        Uuid = CustomEventName.CE_NPC_ATTACK,
        IsCustomEvent = CustomEventName.CE_NPC_ATTACK
    }
    local list = {data}
    local tempArmies = {}
    tempArmies[1] = {
        ConfId = 107100,
        Amount = 100
    }
    local radar = {
        Alliance = "",
        Armies = tempArmies,
        ArriveAt = IsGMQuick and (_G.Tool.Time() + 10) or data.FinishAt,
        AskedHelp = false,
        Avatar = {"IconArm", "map_pic_wild_01"},
        Beasts = {},
        Category = _G.Global.MissionAttack,
        CreatedAt = data.CreatedAt,
        Flag = 238,
        Ignore = false,
        Level = 1,
        Missions = {},
        Name = StringUtil.GetI18n(I18nType.Commmon, "MAP_SEARCH_TEXT_1"),
        RallyTill = 0,
        StartX = guideStopX,
        StartY = _G.Model.Player.Y,
        StopX = _G.Model.Player.X,
        StopY = _G.Model.Player.Y,
        UserId = "DefenceCenterTrigger",
        Uuid = CustomEventName.CE_NPC_ATTACK,
        IsCustomEvent = CustomEventName.CE_NPC_ATTACK
    }
    local RefreshMarchLine = function()
        if not CustomEventInfos[CustomEventName.CE_NPC_ATTACK] then
            return
        end
        MarchLineModel.OnRefresh(list)
        MarchAnimModel.OnRefresh(list)
    end
    RadarModel.AddItem(radar)
    if GlobalVars.IsInCity then
        WorldMap.AddEventAfterMap(RefreshMarchLine)
    else
        RefreshMarchLine()
    end
    _G.Scheduler.UnSchedule(FinishDefend)
    _G.Scheduler.ScheduleOnce(FinishDefend, data.FinishAt - _G.Tool.Time())
end
--创建援兵引导
local function CreateRallyTrigger(data)
    if data.FinishAt < _G.Tool.Time() then
        _G.Log.Debug("该行军事件已经结束")
        _G.Net.CustomEvents.Process(
            CustomEventName.CE_NPC_RALLY,
            function(rsp)
                CustomEventManager.DelCustomEvent(CustomEventName.CE_NPC_RALLY)
            end
        )
        return
    end
    GuidePoint = _G.MathUtil.GetPosNum(_G.Model.Player.X, _G.Model.Player.Y)

    local data = {
        AllianceBattleId = "",
        ArmyTotal = 1000,
        ArmyTypes = {107301},
        Category = _G.Global.MissionAssit,
        CreatedAt = data.CreatedAt,
        Duration = data.FinishAt - data.CreatedAt,
        IsCancel = false,
        IsRally = false,
        IsReturn = false,
        OwnerId = "",
        FinishAt = IsGMQuick and (_G.Tool.Time() + 10) or data.FinishAt,
        SpeedChangeAt = data.CreatedAt,
        SpeedChangeDistance = 0,
        StartPointSize = 1,
        StartX = 600,
        StartY = 600,
        StopPointSize = 1,
        StopX = _G.Model.Player.X - 0.5,
        StopY = _G.Model.Player.Y - 0.5,
        TargetAllianceId = "",
        TargetMapType = 4,
        TargetName = _G.Model.Player.Name,
        TargetOwnerId = _G.Model.Account.accountId,
        Uuid = CustomEventName.CE_NPC_RALLY,
        IsCustomEvent = CustomEventName.CE_NPC_RALLY
    }
    local list = {data}
    local radar = {
        Alliance = "",
        Armies = {
            [1] = {
                ConfId = 107301,
                Amount = 1000
            }
        },
        ArriveAt = IsGMQuick and (_G.Tool.Time() + 10) or data.FinishAt,
        AskedHelp = false,
        Avatar = {"IconArm", "army107301_port"},
        Beasts = {},
        Category = _G.Global.MissionAssit,
        CreatedAt = data.CreatedAt,
        Flag = 238,
        Ignore = false,
        Level = 1,
        Missions = {},
        Name = StringUtil.GetI18n(I18nType.Commmon, "Ui_Assistance_Alpha"),
        RallyTill = 0,
        StartX = 600,
        StartY = 600,
        StopX = _G.Model.Player.X,
        StopY = _G.Model.Player.Y,
        UserId = "DefenceCenterTrigger",
        Uuid = CustomEventName.CE_NPC_RALLY,
        IsCustomEvent = CustomEventName.CE_NPC_RALLY,
        progressText = "Ui_Assistance_Txt"
    }

    RadarModel.AddItem(radar)
    -- _G.MapModel.SetMarchLine(data)
    local RefreshMarchLine = function()
        if not CustomEventInfos[CustomEventName.CE_NPC_RALLY] then
            return
        end
        MarchLineModel.OnRefresh(list)
        MarchAnimModel.OnRefresh(list)
    end
    if GlobalVars.IsInCity then
        WorldMap.AddEventAfterMap(RefreshMarchLine)
    else
        RefreshMarchLine()
    end
    _G.Scheduler.UnSchedule(FinishAssit)
    _G.Scheduler.ScheduleOnce(FinishAssit, data.FinishAt - _G.Tool.Time())
end

local function CreateKingKongTrigger(data)
    if data.FinishAt < _G.Tool.Time() then
        _G.Log.Debug("KingKong事件已经结束")
        _G.Net.CustomEvents.Process(
            CustomEventName.CE_NPC_KINGKONG,
            function()
                CustomEventManager.DelCustomEvent(CustomEventName.CE_NPC_KINGKONG)
            end
        )
        FinishKingKong()
        return
    end
    Event.Broadcast(EventDefines.KingKongBackCD, data)
    
    GuidePoint = _G.MathUtil.GetPosNum(_G.Model.Player.X, _G.Model.Player.Y)
    local guideStopX = math.abs(_G.mapOffset - _G.Model.Player.X) > 300 and _G.mapOffset or (1200 - _G.mapOffset)
    local guideStopY = math.abs(_G.mapOffset - _G.Model.Player.Y) > 300 and _G.mapOffset or (1200 - _G.mapOffset)
    local data = {
        AllianceBattleId = "",
        ArmyTotal = 1,
        ArmyTypes = {621},
        Category = _G.Global.MissionAssit,
        CreatedAt = data.CreatedAt,
        Duration = data.FinishAt - data.CreatedAt,
        IsCancel = false,
        IsRally = false,
        IsReturn = false,
        OwnerId = "",
        FinishAt = IsGMQuick and (_G.Tool.Time() + 10) or data.FinishAt,
        SpeedChangeAt = data.CreatedAt,
        SpeedChangeDistance = 0,
        StartPointSize = 1,
        StartX = guideStopX,
        StartY = guideStopY,
        StopPointSize = 2,
        StopX = _G.Model.Player.X,
        StopY = _G.Model.Player.Y,
        TargetAllianceId = "",
        TargetMapType = 4,
        TargetName = _G.Model.Player.Name,
        TargetOwnerId = _G.Model.Account.accountId,
        Uuid = CustomEventName.CE_NPC_KINGKONG,
        IsCustomEvent = CustomEventName.CE_NPC_KINGKONG
    }
    local list = {data}
    local radar = {
        Alliance = Model.Player.AllianceId,
        Armies = {},
        ArriveAt = IsGMQuick and (_G.Tool.Time() + 10) or data.FinishAt,
        AskedHelp = false,
        Avatar = {"IconArm", "kong_T01"},
        Beasts = {
            {
                Id = 108100,
                DisplayHealth = 100,
                Level = 1,
                Health = 100,
                MaxHealth = 100
                -- ConfId = 108100,
            }
        },
        Category = _G.Global.MissionAssit,
        CreatedAt = data.CreatedAt,
        Flag = 238,
        Ignore = false,
        Level = 1,
        Missions = {},
        Name = StringUtil.GetI18n(I18nType.Army, "ARMY_TYPE_21_NAME"),
        RallyTill = 0,
        StartX = guideStopX,
        StartY = guideStopY,
        StopX = _G.Model.Player.X,
        StopY = _G.Model.Player.Y,
        UserId = "KingkongTrigger",
        Uuid = CustomEventName.CE_NPC_KINGKONG,
        IsCustomEvent = CustomEventName.CE_NPC_KINGKONG
    }
    local RefreshMarchLine = function()
        if not CustomEventInfos[CustomEventName.CE_NPC_KINGKONG] then
            return
        end
        MarchLineModel.OnRefresh(list)
        MarchAnimModel.OnRefresh(list)
    end
    RadarModel.AddItem(radar)
    if GlobalVars.IsInCity then
        WorldMap.AddEventAfterMap(RefreshMarchLine)
    else
        RefreshMarchLine()
    end
    _G.Scheduler.UnSchedule(FinishKingKong)
    _G.Scheduler.ScheduleOnce(FinishKingKong, data.FinishAt - _G.Tool.Time())
end
local function CreateCareSystremTrigger(_data)
    if _data.FinishAt < _G.Tool.Time() then
        FinishCareSystem()
        return
    end
    GuidePoint = _G.MathUtil.GetPosNum(_G.Model.Player.X, _G.Model.Player.Y)
    local data = {
        AllianceBattleId = "",
        ArmyTotal = 1,
        ArmyTypes = {107301},
        Category = _G.Global.MissionAssit,
        CreatedAt = _data.CreatedAt,
        Duration = _data.FinishAt - _data.CreatedAt,
        IsCancel = false,
        IsRally = false,
        IsReturn = false,
        OwnerId = "",
        FinishAt = _data.FinishAt,
        SpeedChangeAt = _data.CreatedAt,
        SpeedChangeDistance = 0,
        StartPointSize = 1,
        StartX = _data.FromX,
        StartY = _data.FromY,
        StopPointSize = 2,
        StopX = _G.Model.Player.X,
        StopY = _G.Model.Player.Y,
        TargetAllianceId = "",
        TargetMapType = 4,
        TargetName = _G.Model.Player.Name,
        TargetOwnerId = _G.Model.Account.accountId,
        Uuid = CustomEventName.CE_NPC_CARE,
        IsCustomEvent = CustomEventName.CE_NPC_CARE
    }
    local list = {data}
    local radar = {
        Alliance = Model.Player.AllianceId,
        Armies = {},
        ArriveAt = IsGMQuick and (_G.Tool.Time() + 10) or data.FinishAt,
        AskedHelp = false,
        Avatar = _data.Avatar,
        Category = _G.Global.MissionAssit,
        CreatedAt = _data.CreatedAt,
        Flag = 238,
        Ignore = false,
        Level = 1,
        Missions = {},
        Name = StringUtil.GetI18n(I18nType.Army, "ARMY_TYPE_Care"),
        RallyTill = 0,
        StartX = _data.FromX,
        StartY = _data.FromY,
        StopX = _G.Model.Player.X,
        StopY = _G.Model.Player.Y,
        UserId = _data.UserId,
        Uuid = CustomEventName.CE_NPC_CARE,
        IsCustomEvent = CustomEventName.CE_NPC_CARE
    }
    local RefreshMarchLine = function()
        if not CustomEventInfos[CustomEventName.CE_NPC_CARE] then
            return
        end
        MarchLineModel.OnRefresh(list)
        MarchAnimModel.OnRefresh(list)
    end
    RadarModel.AddItem(radar)
    if GlobalVars.IsInCity then
        WorldMap.AddEventAfterMap(RefreshMarchLine)
    else
        RefreshMarchLine()
    end
    _G.Scheduler.UnSchedule(FinishCareSystem)
    _G.Scheduler.ScheduleOnce(FinishCareSystem, data.FinishAt - _G.Tool.Time())
end

----------------------------------------------------------------------------------
local CreateAssitGuide = function()
    _G.Net.CustomEvents.Create(
        CustomEventName.CE_NPC_RALLY,
        function(rsp)
            CustomEventInfos[CustomEventName.CE_NPC_RALLY] = rsp
            CustomEventManager.RefreshCustomEvent(rsp)
        end
    )
end
local CreateDefendGuide = function()
    _G.Net.CustomEvents.Create(
        CustomEventName.CE_NPC_ATTACK,
        function(rsp)
            CustomEventInfos[CustomEventName.CE_NPC_ATTACK] = rsp
            CustomEventManager.RefreshCustomEvent(rsp)
        end
    )
end
local CreateKingKongGuide = function()
    _G.Net.CustomEvents.Create(
        CustomEventName.CE_NPC_KINGKONG,
        function(rsp)
            CustomEventInfos[CustomEventName.CE_NPC_KINGKONG] = rsp
            CustomEventManager.RefreshCustomEvent(rsp)
        end
    )
end
local CareSystemGuide = function()
    local info = _G.Model.GetMap(ModelType.BattleCareInfo)
    info.Name = CustomEventName.CE_NPC_CARE
    CustomEventInfos[CustomEventName.CE_NPC_CARE] = info
    CustomEventManager.RefreshCustomEvent(info)
end
function CustomEventManager.Init()
    CustomEventManager.InitEvent()
    CustomEventRefresh()
end

function CustomEventManager.InitEvent()
    CustomEventFuncList[CustomEventName.CE_NPC_ATTACK] = CreateDefenceTrigger
    CustomEventFuncList[CustomEventName.CE_NPC_RALLY] = CreateRallyTrigger
    CustomEventFuncList[CustomEventName.CE_NPC_KINGKONG] = CreateKingKongTrigger
    CustomEventFuncList[CustomEventName.CE_NPC_CARE] = CreateCareSystremTrigger
    --请求开始援助引导
    --_G.Event.AddListener(_G.EventDefines.TwelveHourTrigger, CreateAssitGuide)

    --请求开始金刚引导
    _G.Event.AddListener(_G.EventDefines.KingkongTrigger, CreateKingKongGuide)

    --请求开始防御引导
    _G.Event.AddListener(_G.EventDefines.DefenceCenterTrigger, CreateDefendGuide)

    --请求开始关怀系统
    _G.Event.AddListener(_G.EventDefines.CareSystemMarchAnim, CareSystemGuide)

    _G.Event.AddListener(
        _G.EventDefines.CustomEventRefresh,
        function(callback)
            CustomEventManager.ClearEvent()
            CustomEventRefresh(callback)
        end
    )
    _G.Event.AddListener(
        _G.EventDefines.UIOnMoveCity,
        function()
            CustomEventManager.CheckMyCity()
        end
    )
end
--检测是否迁城，迁城后需要重新创建
function CustomEventManager.CheckMyCity()
    local pos = _G.MathUtil.GetPosNum(_G.Model.Player.X, _G.Model.Player.Y)
    if GuidePoint == pos then
        return
    end
    for _, v in pairs(CustomEventName) do
        CustomEventManager.DelCustomEvent(v)
    end
    --   (CustomEventName.CE_NPC_ATTACK)
    -- CustomEventManager.DelCustomEvent(CustomEventName.CE_NPC_RALLY)
    CustomEventRefresh()
end

function CustomEventManager.RefreshCustomEvent(info)
    --事件完成
    if info.ClientProcessed then
        _G.Log.Warning("自定义事件已经结束")
        if info.Name == CustomEventName.CE_NPC_KINGKONG then
            FinishKingKong()
        end
        return
    end
    local point = _G.MathUtil.GetPosNum(_G.Model.Player.X, _G.Model.Player.Y)
    CustomEventInfos[info.Name] = point

    if CustomEventFuncList[info.Name] then
        CustomEventFuncList[info.Name](info)
    else
        _G.Log.Debug("尚未监听其他自定义事件")
    end
end

function CustomEventManager.ClearEvent()
    -- CustomEventManager.DelCustomEvent(CustomEventName.CE_NPC_ATTACK)
    -- CustomEventManager.DelCustomEvent(CustomEventName.CE_NPC_RALLY)
    -- CustomEventManager.DelCustomEvent(CustomEventName.CE_NPC_KINGKONG)
    for k, v in pairs(CustomEventName) do
        CustomEventManager.DelCustomEvent(v)
        CustomEventInfos[v] = nil
    end
end

function CustomEventManager.DelCustomEvent(key)
    CustomEventInfos[key] = nil
    RadarModel.DeleteItem(key)
    MarchLineModel.DelMarchLine(key)
    MarchAnimModel.DelMarchAnim(key, true)
end

function CustomEventManager.GMToFinishGuide()
    CustomEventManager.DelCustomEvent(CustomEventName.CE_NPC_ATTACK)
    CustomEventManager.DelCustomEvent(CustomEventName.CE_NPC_RALLY)
    CustomEventManager.DelCustomEvent(CustomEventName.CE_NPC_KINGKONG)
    IsGMQuick = true
    CustomEventRefresh()
end
--检测金刚是否触发
function CustomEventManager.CheckKingKongGuide()
    --判断基地已经达到5级，同时已经触发的引导，没有金刚就主动再请求一次
    local list = Model.Player.TriggerGuides
    if BuildModel.GetCenterLevel() > 4 then
        for _, v in pairs(list) do
            if v.Id == 14600 and v.Finish then
                CreateKingKongGuide()
            end
        end
    end
end

return CustomEventManager
