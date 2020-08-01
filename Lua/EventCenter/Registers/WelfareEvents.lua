--[[
    Author: songzeming
    Function: 福利中心 通知
]]
local WelfareEvents = {}

local WelfareCuePointModel = import("Model/CuePoint/WelfareCuePointModel")

function WelfareEvents.init()
    -- 成长之路
    Event.AddListener(
        EventDefines.UIWelfareRookieGrowth,
        function()
            WelfareCuePointModel:CheckRookieGrowthPoint()
        end
    )
    -- 日常任务(上面)
    Event.AddListener(
        EventDefines.UIWelfareDailyTaskUp,
        function(rsp)
            -- Event.Broadcast(EventDefines.UIDailyTaskRedDotEvent, rsp)
            if rsp.IsAwardTaken == false then
                Event.Broadcast(EventDefines.DailyTaskPopupUI, rsp.Id)
            end
            WelfareCuePointModel:CheckDailyTaskPoint()
        end
    )
    -- 日常任务(下面)
    Event.AddListener(
        EventDefines.UIWelfareDailyTaskDown,
        function(rsp)
            if rsp.Status == true then
                Event.Broadcast(EventDefines.DailyTaskRefreshAction)
            end
        end
    )
    -- 成长基金
    Event.AddListener(
        EventDefines.UIWelfareGrowthFund,
        function(rsp)
            WelfareCuePointModel:CheckGrowthFundPoint()
        end
    )
    --赌场集结
    Event.AddListener(
        EventDefines.UIWelfareCasionMass,
        function(rsp)
            WelfareCuePointModel:CheckCasionMassPoint()
        end
    )
    --侦查活动
    Event.AddListener(
        EventDefines.UIWelfareDetectActvity,
        function(rsp)
            WelfareCuePointModel:CheckDetectActvityPoint()
        end
    )
    Event.AddListener(
        EventDefines.UIMonthlyCardRed,
        function()
            WelfareCuePointModel:CheckMonthCardPoint()
        end
    )
    --猎鹰行动
    Event.AddListener(
        EventDefines.UIFalconDetectActvity,
        function()
            WelfareCuePointModel:CheckFalconActvityPoint()
        end
    )
    --长留基金
    Event.AddListener(
        EventDefines.UIWelfareGemFund,
        function()
            WelfareCuePointModel:CheckGemFundPoint()
        end
    )
    Event.AddListener(
        EventDefines.UIWelfareHuntingFox,
        function()
            WelfareCuePointModel:CheckHuntingDogPoint()
        end
    )
    Event.AddListener(
        EventDefines.RefreshSuperCheapRedData,
        function()
            WelfareCuePointModel:CheckSuperCheapActvityPoint()
        end
    )
    Event.AddListener(
        EventDefines.RefreshFlagDayRedData,
        function()
            WelfareCuePointModel:CheckMemerDayPoint()
        end
    )
end
return WelfareEvents
