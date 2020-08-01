Net.Logins = {}

-- 请求-心跳
function Net.Logins.Heartbeat(...)
    Network.RequestDynamic("HeartbeatParams", {}, ...)
end

-- 请求-登录
function Net.Logins.Login(...)
    local fields = {
        "UserId", -- string
        "AccountId", -- string
        "Country", -- string
        "Device", -- string
        "DeviceOS", -- string
        "DeviceId", -- string
        "DeviceAdId", -- string
        "AppVersion", -- string
        "UID", -- int32
        "Language", -- int32
        "DeviceLanguage", -- string
        "APKVersion", -- string
    }
    Network.RequestDynamic("LoginParams", fields, ...)
end

-- 请求-更新token
function Net.Logins.SetDeviceToken(...)
    local fields = {
        "Token", -- string
    }
    Network.RequestDynamic("SetDeviceTokenParams", fields, ...)
end

-- 请求-更新deviceAdId
function Net.Logins.SetDeviceAdId(...)
    local fields = {
        "DeviceAdId", -- string
    }
    Network.RequestDynamic("SetDeviceAdIdParams", fields, ...)
end

-- 请求-断线重连
function Net.Logins.Reconnect(...)
    local fields = {
        "PacketId", -- int32
    }
    Network.RequestDynamic("ReconnectParams", fields, ...)
end

-- 请求-设置引导步骤
function Net.Logins.SetGuideStep(...)
    local fields = {
        "Step", -- int32
        "Version", -- int32
        "Finished", -- bool
    }
    Network.RequestDynamic("SetGuideStepParams", fields, ...)
end

-- 请求-设置触发式引导步骤
function Net.Logins.SetTriggerGuideStep(...)
    local fields = {
        "Step", -- TriggerGuideInfo
    }
    Network.RequestDynamic("SetTriggerGuideStepParams", fields, ...)
end

-- 请求-同步时间
function Net.Logins.SyncTime(...)
    Network.RequestDynamic("SyncTimeParams", {}, ...)
end

return Net.Logins