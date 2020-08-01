Net.CustomEvents = {}

-- 请求-创建自定义事件
function Net.CustomEvents.Create(...)
    local fields = {
        "Name", -- int32
    }
    Network.RequestDynamic("CustomEventCreateParams", fields, ...)
end

-- 请求-自定义事件信息
function Net.CustomEvents.Infos(...)
    Network.RequestDynamic("CustomEventInfosParams", {}, ...)
end

-- 请求-完成自定义事件
function Net.CustomEvents.Process(...)
    local fields = {
        "Name", -- int32
    }
    Network.RequestDynamic("CustomEventProcessParams", fields, ...)
end

return Net.CustomEvents