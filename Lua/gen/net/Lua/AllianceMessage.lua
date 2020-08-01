Net.AllianceMessage = {}

-- 请求留言列表
function Net.AllianceMessage.RequestMessageList(...)
    local fields = {
        "AllianceId", -- string
        "Index", -- int64
    }
    Network.RequestDynamic("AllianceRequestMessageListParams", fields, ...)
end

-- 请求留言
function Net.AllianceMessage.RequestSendMessage(...)
    local fields = {
        "Message", -- MessageItem
    }
    Network.RequestDynamic("AllianceRequestSendMessageParams", fields, ...)
end

-- 删除留言
function Net.AllianceMessage.RequestDeleteMessage(...)
    local fields = {
        "Uuid", -- string
    }
    Network.RequestDynamic("AllianceRequestDeleteMessageParams", fields, ...)
end

-- 请求屏蔽列表
function Net.AllianceMessage.RequestBanList(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceRequestBanListParams", fields, ...)
end

-- 请求屏蔽
function Net.AllianceMessage.RequestBanPlayer(...)
    local fields = {
        "PlayerId", -- string
    }
    Network.RequestDynamic("AllianceRequestBanPlayerParams", fields, ...)
end

-- 请求删除屏蔽
function Net.AllianceMessage.RequestReleasePlayer(...)
    local fields = {
        "PlayerId", -- string
    }
    Network.RequestDynamic("AllianceRquestReleasePlayerParams", fields, ...)
end

-- 请求屏蔽联盟
function Net.AllianceMessage.RequestBanAlliance(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("RequestBanAllianceParams", fields, ...)
end

-- 请求删除屏蔽
function Net.AllianceMessage.RequestReleaseAlliance(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("RquestReleaseAllianceParams", fields, ...)
end

-- 请求-标记已读
function Net.AllianceMessage.MarkRead(...)
    local fields = {
        "MessageId", -- int64
    }
    Network.RequestDynamic("AllianceMessageMarkReadParams", fields, ...)
end

return Net.AllianceMessage