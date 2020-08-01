--[[
    Author: songzeming
    Function: 建筑队列
]]
local BuildQueueModel = {}

local GlobalVars = GlobalVars
local FreeQueue = nil --免费队列
local GoldQueue = nil --付费队列
local StayTime = 2 --最少停留时间
local Staying = false
BuildQueueModel.IsShowQueTip = false

--关闭定时器
local function CloseQueueCheck()
    Scheduler.UnSchedule(ShowQueueTip)
end
--显示队列提示
local function ShowQueueTip()
    if FreeQueue:GetBusy() then
        if GoldQueue:GetLock() or GoldQueue:GetBusy() then
            CloseQueueCheck()
            return
        end
        GoldQueue:ShowTipOnce()
    else
        FreeQueue:ShowTipOnce()
    end
    GlobalVars.IsCheckQueueIdle = false
    BuildQueueModel.IsShowQueTip = true
    CloseQueueCheck()
    --最少停留时间
    Staying = true
    Scheduler.ScheduleOnce(
        function()
            Staying = false
        end,
        StayTime
    )
end

function BuildQueueModel.GetChargeCanUse()
    if not GoldQueue:GetLock() and GoldQueue:GetBusy() == false then
        return true
    end
    return false
end

--获取付费队列是否解锁
function BuildQueueModel.GetChargeLock()
    if GoldQueue:GetLock() then
        return true
    else
        return false
    end
end

--初始化队列
function BuildQueueModel.InitQueue(freeQueue, goldQueue)
    FreeQueue = freeQueue
    GoldQueue = goldQueue
end
--隐藏队列提示
function BuildQueueModel.HideQueueTip()
    if Staying then
        return
    end
    Staying = true
    FreeQueue:HideTip()
    GoldQueue:HideTip()
end
--检测长时间未操作提示 每次提示一次
function BuildQueueModel.CheckIdle()
    if not GlobalVars.IsCheckQueueIdle then
        CloseQueueCheck()
        return
    end
    if GlobalVars.IsTriggerStatus then
        CloseQueueCheck()
        return
    end
    if GlobalVars.IsNoviceGuideStatus then
        CloseQueueCheck()
        return
    end
    if not GlobalVars.IsAllowPopWindow then
        CloseQueueCheck()
        return
    end
    if not FreeQueue or not GoldQueue then
        return
    end
    if FreeQueue:GetBusy() then
        return
    end
    if GoldQueue:GetLock() or GoldQueue:GetBusy() then
        return
    end
    if UIMgr:GetShowPanelCount() == 0 then
        Scheduler.ScheduleOnce(ShowQueueTip, Global.BuildingQueue_Free)
    else
        CloseQueueCheck()
    end
end

return BuildQueueModel
