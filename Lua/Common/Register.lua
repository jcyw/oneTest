local Register = {}

function Register:InitRegister(name)
    self.__regName = name
    self:initVars()
end

function Register:initVars()
    self.__regEvents = {}
    self.__regSchedules = {}
    self.__regScheduleOnces = {}
    self.__regScheduleFasts = {}
    self.__regScheduleOnceFasts = {}
    self.__regEventListeners = {}
    self.__regGTweenListeners = {}
end

function Register:AddEvent(name, func)
    self.__regEvents[name] = func
    Event.AddListener(name, func)
end

function Register:Schedule(cb, interval, isRepeat, delay)
    self.__regSchedules[cb] = true
    Scheduler.Schedule(cb, interval, isRepeat, delay)
end

function Register:ScheduleOnce(cb, delay)
    self.__regSchedules[cb] = true
    Scheduler.ScheduleOnce(cb, delay)
end

function Register:ScheduleFast(cb, interval, delay, onlyOnce)
    self.__regScheduleFasts[cb] = true
    Scheduler.ScheduleFast(cb, interval, delay, onlyOnce)
end

function Register:ScheduleOnceFast(cb, delay)
    self.__regScheduleOnceFasts[cb] = true
    Scheduler.ScheduleOnceFast(cb, delay)
end

function Register:UnSchedule(cb)
    if type(cb) ~= "function" then
        return
    end
    self.__regSchedules[cb] = nil
    self.__regScheduleOnces[cb] = nil
    Scheduler.UnSchedule(cb)
end

function Register:UnScheduleFast(cb)
    if type(cb) ~= "function" then
        return
    end
    self.__regScheduleFasts[cb] = nil
    self.__regScheduleOnceFasts[cb] = nil
    Scheduler.UnScheduleFast(cb)
end

-- 添加FairyGUI监听事件
function Register:AddListener(listener, handler)
    local handlers = self.__regEventListeners[listener]
    if not handlers then
        handlers = {}
        self.__regEventListeners[listener] = handlers
    end
    table.insert(handlers, handler)
    listener:Add(handler)
end

-- 移除FairyGUI监听事件
function Register:RemoveListener(listener, handler)
    listener:Remove(handler)
end

-- 删除并添加FairyGUI监听事件
function Register:SetListener(listener, handler)
    self:ClearListener(listener)
    self:AddListener(listener, handler)
end

-- 清理FairyGUI监听事件
function Register:ClearListener(listener)
    local handlers = self.__regEventListeners[listener]
    if not handlers then return end
    for _, handler in ipairs(handlers) do
        listener:Remove(handler)
    end
end

-- 注册FairyGuiOnUpdate
function Register:GtweenOnUpdate(gTween,handler)
    local listeners = self.__regGTweenListeners[gTween]
    if not listeners then
        listeners = {}
        self.__regGTweenListeners[gTween] = listeners
    end
    if listeners[GlobalVars.GtweenOnUpdate] and gTween.RemoveOnUpdate then
        gTween:RemoveOnUpdate(listeners[GlobalVars.GtweenOnUpdate])
    end
    listeners[GlobalVars.GtweenOnUpdate] = handler
    gTween:OnUpdate(handler)
    return gTween
end

-- 注册FairyGuiOnComplete
function Register:GtweenOnComplete(gTween,handler)
    local listeners = self.__regGTweenListeners[gTween]
    if not listeners then
        listeners = {}
        self.__regGTweenListeners[gTween] = listeners
    end
    if listeners[GlobalVars.GtweenOnComplete]  and gTween.GtweenOnComplete then
        gTween:RemoveOnComplete(listeners[GlobalVars.GtweenOnComplete])
    end
    listeners[GlobalVars.GtweenOnComplete] = handler
    gTween:OnComplete(handler)
    return gTween
end

-- 注册FairyGuiOnStart
function Register:GtweenOnStart(gTween,handler)
    local listeners = self.__regGTweenListeners[gTween]
    if not listeners then
        listeners = {}
        self.__regGTweenListeners[gTween] = listeners
    end
    if listeners[GlobalVars.GtweenOnStart]  and gTween.RemoveOnStart then
        gTween:RemoveOnStart(GlobalVars.GtweenOnStart)
    end
    listeners[GlobalVars.GtweenOnStart] = handler
    gTween:OnStart(handler)
    return gTween
end


function Register:DisposeRegister()
    -- 特殊处理 以后处理touchMove 和touchEnd
    if self.__regName == "" then
        Log.Error("DisposeRegister failed: {0}", self)
        self:initVars()
        return
    end

    if(self.__regGTweenListeners and type(self.__regGTweenListeners) == "table")then
        for gTween,listeners in pairs(self.__regGTweenListeners) do
            if listeners[GlobalVars.GtweenOnStart] and gTween.RemoveOnStart then
                gTween:RemoveOnStart(GlobalVars.GtweenOnStart)
            end
            if listeners[GlobalVars.GtweenOnComplete] and gTween.RemoveOnComplete then
                gTween:RemoveOnComplete(listeners[GlobalVars.GtweenOnComplete])
            end
            if listeners[GlobalVars.GtweenOnUpdate] and gTween.RemoveOnUpdate then
                gTween:RemoveOnUpdate(listeners[GlobalVars.GtweenOnUpdate])
            end
        end
    end
    for name, func in pairs(self.__regEvents) do
        Event.RemoveListener(name, func)
    end
    for cb, _ in pairs(self.__regSchedules) do
        Scheduler.UnSchedule(cb)
    end
    for cb, _ in pairs(self.__regScheduleOnces) do
        Scheduler.UnSchedule(cb)
    end
    for cb, _ in pairs(self.__regScheduleFasts) do
        Scheduler.UnScheduleFast(cb)
    end
    for cb, _ in pairs(self.__regScheduleOnceFasts) do
        Scheduler.UnScheduleFast(cb)
    end
    local disposedEventHandlers = 0
    for listener, handlers in pairs(self.__regEventListeners) do
        disposedEventHandlers = disposedEventHandlers + #handlers
        for _, handler in ipairs(handlers) do
            listener:Remove(handler)
        end
    end
    Log.Debug("DisposeRegister: {0}, DisposeHanders: {1}", self.__regName, disposedEventHandlers)
    self:initVars()
end

return Register