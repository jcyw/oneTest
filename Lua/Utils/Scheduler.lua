if Scheduler then
    return
end

local Scheduler = {}
local tasks = {}
local fastTasks = {}

local pendingAddTasks = {}
local pendingAddFastTasks = {}
local pendingDelTasks = {}
local pendingDelFastTasks = {}

function Scheduler.Start()
    GameUpdate.Inst():AddUpdate(Scheduler.UpdateFast)
    GameUpdate.Inst():AddSlowUpdate(Scheduler.Update)
end

function Scheduler.Update(dt)
    Scheduler.removeTasks(tasks, pendingDelTasks)
    Scheduler.appendTasks(tasks, pendingAddTasks)
    -- pendingAddTasks = {}
    -- pendingDelTasks = {}
    Scheduler.updateTasks(tasks, dt)
end

function Scheduler.UpdateFast(dt)
    Scheduler.removeTasks(fastTasks, pendingDelFastTasks)
    Scheduler.appendTasks(fastTasks, pendingAddFastTasks)
    -- pendingAddFastTasks = {}
    -- pendingDelFastTasks = {}
    Scheduler.updateTasks(fastTasks, dt)
end

function Scheduler.Schedule(cb, interval, isRepeat, delay)
    Scheduler.doSchedule(pendingAddTasks, cb, interval, delay, isRepeat)
end

function Scheduler.ScheduleOnce(cb, delay)
    Scheduler.Schedule(cb, 0, false, delay)
end

function Scheduler.ScheduleFast(cb, interval, delay, isRepeat)
    Scheduler.doSchedule(pendingAddFastTasks, cb, interval, delay, isRepeat)
end

function Scheduler.ScheduleOnceFast(cb, delay)
    Scheduler.ScheduleFast(cb, 0, delay, false)
end

function Scheduler.doSchedule(container, cb, interval, delay, isRepeat)
    if isRepeat == nil then
        isRepeat = true
    end
    delay = delay or 0
    if delay == 0 then
        cb(0)
    end
    container[cb] = {
        interval = interval,
        isRepeat = isRepeat,
        delay = delay,
        past = 0
    }
end

function Scheduler.UnSchedule(cb)
    if cb then
        pendingAddTasks[cb] = nil
        table.insert(pendingDelTasks, cb)
    end
end

function Scheduler.UnScheduleFast(cb)
    if cb then
        pendingAddFastTasks[cb] = nil
        table.insert(pendingDelFastTasks, cb)
    end
end

function Scheduler.updateTasks(tasks, dt)
    for func, v in pairs(tasks) do
        v.past = v.past + dt
        if v.past >= v.delay + v.interval then
            func(v.past)
            v.past = v.past - v.delay - v.interval
            v.delay = 0
            if not v.isRepeat then
                tasks[func] = nil
            end
        end
    end
end

function Scheduler.appendTasks(tasks, newTasks)
    for func, v in pairs(newTasks) do
        newTasks[func] = nil
        tasks[func] = v
    end
end

function Scheduler.removeTasks(tasks, delTasks)
    for key, func in ipairs(delTasks) do
        tasks[func] = nil
        delTasks[key] = nil
    end
end

_G.Scheduler = Scheduler
return Scheduler
