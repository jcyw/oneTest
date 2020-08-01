--[[
    Author: songzeming
    Function: 对话框
]]
local DialogModel = {}

local GameEnum = _G.GD.GameEnum
local DialogType = GameEnum.DialogType
local DialogTrainSort = GameEnum.DialogTrainSort
local ConfigMgr = _G.ConfigMgr
local I18nType = _G.I18nType
local Model = _G.Model
local Global = _G.Global
local EventDefines = _G.EventDefines
local WelfareModel = import("Model/WelfareModel")
local JumpMap = import("Model/JumpMap")
local BuildModel = import("Model/BuildModel")
local EventModel = import("Model/EventModel")
local FuncListModel = import("Model/FuncListModel")

local REFRESH_TIME = 40
local ConfigList = {}
local StartTime = os.time()
local DialogNode = nil
local DialogShowing = nil
local SoldierShowingSign = nil
local Jumping = nil

function DialogModel.ResetData()
    DialogShowing = nil
    SoldierShowingSign = nil
    Jumping = nil
end

function DialogModel.ShowDialog(soldier, dialogType, text, data)
    if not soldier or not DialogNode then
        return
    end

    if soldier["sign"] == SoldierShowingSign then
        return
    end

    if dialogType == DialogType.Soldier then
        if DialogShowing then
            DialogNode:SetVisible(false)
        end
        DialogModel.ResetData()
    end

    if DialogShowing then
        return
    end

    SoldierShowingSign = soldier["sign"]
    DialogShowing = true

    local time = nil
    if not text then
        text, time = DialogModel.GetContextAndTime(dialogType)
    end
    DialogNode:ShowSoldierDialog(text, time, soldier, DialogModel.ResetData)
    DialogNode:SetClickCb(function()
        DialogModel.Jump(dialogType, data)
    end)
    _G.Event.Broadcast(EventDefines.EventDialogScale)
end

local function RefreshCD()
    if os.time() - StartTime > REFRESH_TIME then
        StartTime = os.time()
        DialogModel.AutoTriggerDialog()
    end
end

function DialogModel.Check(dialogNode)
    DialogNode = dialogNode
    _G.GameUpdate.Inst():AddSlowUpdate(RefreshCD)
    DialogModel.InitDialogConfig()
end

function DialogModel.Clear()
    _G.GameUpdate.Inst():DelSlowUpdate(RefreshCD)

    if DialogNode then
        DialogNode = nil
    end
    DialogModel.ResetData()
end
----------------------------------------------------->>
function DialogModel.InitDialogConfig()
    local conf = ConfigMgr.GetList("configTriggerDialogs")
    for _, v in pairs(conf) do
        if not ConfigList[v.type] then
            ConfigList[v.type] = {}
        end
        table.insert(ConfigList[v.type], v)
    end
end

local JumpList = {
    [WelfareModel.WelfarePageType.DIAMOND_FUND_ACTIVITY] = {
        --钻石基金
        condition = function()
            return false
        end,
        cb = function()
            FuncListModel.DiamondsFundPrice()
        end
    },
    [WelfareModel.WelfarePageType.CUMULATIVE_ATTENDANCE] = {
        --见面礼
        condition = function()
            return false
        end,
        cb = function()
            FuncListModel.CumulativeAttendance()
        end
    },
    [WelfareModel.WelfarePageType.DAILY_ATTENDANCE] = {
        --签到
        condition = function()
            return false
        end,
        cb = function()
            FuncListModel.DailyAttendance()
        end
    },
    [WelfareModel.WelfarePageType.GROWTHCAPITALTYPE] = {
        --成长基金
        condition = function()
            return false
        end,
        cb = function()
            FuncListModel.GrowthFund()
        end
    },
    [WelfareModel.WelfarePageType.SPECIALGIFTTYPE] = {
        --月卡
        condition = function()
            return false
        end,
        cb = function()
            FuncListModel.MonthlyCard()
        end
    },
    [WelfareModel.WelfarePageType.FALCON_ACTIVITY] = {
        --猎鹰行动
        condition = function()
            return Model.isFalconOpen and Model.EagleHuntInfos.Fuel > 0
        end,
        cb = function()
            if Model.isFalconOpen and Model.EagleHuntInfos.Fuel > 0 then
                FuncListModel.FalconAction()
            end
        end
    }
}

function DialogModel.AutoTriggerDialog()
    _G.Event.Broadcast(EventDefines.EventDialogSoldier, function(soldier)
        if not soldier then
            Log.Info("not soldier in screen")
            return
        end

        --训练队列
        for _, v in ipairs(DialogTrainSort) do
            local building = BuildModel.FindByConfId(v)
            if building then
                if not EventModel.GetEvent(building) then
                    DialogModel.ShowDialog(soldier, DialogType.BuildArmy, nil, v)
                    return
                end
            end
        end

        --建筑队列
        if BuildModel.GetBuildQueueIdle() then
            DialogModel.ShowDialog(soldier, DialogType.BuildQueue)
            return
        end

        --科研队列
        local building = BuildModel.FindByConfId(Global.BuildingScience)
        if building then
            if not EventModel.GetEvent(building) then
                Log.Info("自动触发对话框 科研队列")
                DialogModel.ShowDialog(soldier, DialogType.BuildScience)
                return
            end
        end

        --活动推送
        local list = ConfigList[DialogType.Activity]
        if not list then
            Log.Error("not find activity dialog info")
            return
        end
        for _, v in ipairs(list) do
            if WelfareModel.IsActivityOpen(v.activityid) then
                if JumpList[v.activityid] and JumpList[v.activityid].condition() then
                    local text = ConfigMgr.GetI18n(I18nType.NoviceDialog, v.dialogid)
                    DialogModel.ShowDialog(soldier, DialogType.Activity, text, v.activityid)
                    return
                end
            end
        end

        Log.Info("跳过触发对话框")
    end)
end

function DialogModel.GetContextAndTime(dialogType)
    local list = ConfigList[dialogType]
    if not list then
        Log.Error("not find config by ConfigList. dialogType:{0}", dialogType)
        return
    end

    local weights = 0
    for _, v in pairs(list) do
        weights = weights + v.probability
    end
    local random = math.random(1, weights)
    local sum = 0
    local text = "Trigger_dialog_desc_5"
    local time = nil
    for _, v in pairs(list) do
        sum = sum + v.probability
        if random <= sum then
            text = v.dialogid
            time = v.time
            break
        end
    end

    return ConfigMgr.GetI18n(I18nType.NoviceDialog, text), time
end

function DialogModel.Jump(dialogType, data)
    if dialogType == DialogType.BuildArmy then
        JumpMap:JumpTo({ jump = 810200, para = data })
    elseif dialogType == DialogType.BuildQueue then
        for _, v in pairs(Model.Builders) do
            if not v.IsWorking then
                BuildModel.QueueGuideOrder()
                return
            end
        end
    elseif dialogType == DialogType.BuildScience then
        JumpMap:JumpTo({ jump = 810300, para = Global.BuildingScience })
    elseif dialogType == DialogType.Activity then
        if JumpList[data] then
            JumpList[data].cb()
        end
    end
end

return DialogModel
