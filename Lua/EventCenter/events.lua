local Event = {}
local events = {}

function Event.AddListener(event, handler)
    if not event or type(event) ~= "string" then
        error("event parameter in addlistener function has to be string, " .. type(event) .. " not right.")
    end
    if not handler or type(handler) ~= "function" then
        error("handler parameter in addlistener function has to be function, " .. type(handler) .. " not right")
    end

    if not events[event] then
        --create the Event with name
        events[event] = {}
    end

    --conn this handler
    events[event][handler] = true
end

function Event.Broadcast(event, ...)
    if not events[event] then
        Log.Debug("Event.Broadcast failed, event not registered: {0}", event)
        return false
    else
        for handler, _ in pairs(events[event]) do
            handler(...)
        end
        return true
    end
end

function Event.RemoveListener(event, handler)
    if not events[event] then
        Log.Warning("Event.RemoveListener failed, event not registered: {0}", event)
    else
        events[event][handler] = nil
    end
end

function Event.CheckExistEvent(events)
    if not events[events] then
        return false
    else
        return true
    end
end


function Event.GetEvents()
    return events
end

return Event
