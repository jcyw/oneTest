Net.Chat = {}

-- 发送聊天消息
function Net.Chat.SendChat(...)
    local fields = {
        "RoomId", -- string
        "SenderId", -- string
        "Content", -- string
        "MType", -- int32
        "Params", -- string
    }
    Network.RequestDynamic("ChatParams", fields, ...)
end

-- 请求聊天记录
function Net.Chat.GetChatHistory(...)
    local fields = {
        "RoomId", -- string
        "Index", -- int64
        "MessageNum", -- int32
    }
    Network.RequestDynamic("HistoryParams", fields, ...)
end

-- 请求联盟通知消息
function Net.Chat.GetAllianceNoticeHistory(...)
    local fields = {
        "RoomId", -- string
        "Index", -- int64
        "MessageNum", -- int32
    }
    Network.RequestDynamic("AllianceNoticeParams", fields, ...)
end

-- 请求最新一条聊天记录
function Net.Chat.RequestNewestChatInfo(...)
    Network.RequestDynamic("RequestNewestParams", {}, ...)
end

-- 请求-领取红包
function Net.Chat.GetLuckyMoney(...)
    local fields = {
        "Uuid", -- string
    }
    Network.RequestDynamic("GetLuckyMoneyParams", fields, ...)
end

-- 请求-红包详细信息
function Net.Chat.GetLuckyMoneyInfo(...)
    local fields = {
        "Uuid", -- string
    }
    Network.RequestDynamic("GetLuckyMoneyInfoParams", fields, ...)
end

-- 请求-加入黑名单
function Net.Chat.AddToBlockList(...)
    local fields = {
        "PlayerId", -- string
    }
    Network.RequestDynamic("AddToBlockListParams", fields, ...)
end

-- 请求-移出黑名单
function Net.Chat.RemoveFromBlockList(...)
    local fields = {
        "PlayerId", -- string
    }
    Network.RequestDynamic("RemoveFromBlockListParams", fields, ...)
end

-- 请求-黑名单列表
function Net.Chat.GetBlockList(...)
    Network.RequestDynamic("GetBlockListParams", {}, ...)
end

-- 请求-翻译
function Net.Chat.Translate(...)
    local fields = {
        "Category", -- int32
        "Id", -- string
        "Content", -- array-string
    }
    Network.RequestDynamic("TranslateParams", fields, ...)
end

-- 请求-系统通知广播信息
function Net.Chat.SystemNotify(...)
    local fields = {
        "Notify", -- NotifyInfo
    }
    Network.RequestDynamic("SystemNotifyParams", fields, ...)
end

-- 请求-玩家接收后台邮件
function Net.Chat.ReceiveBackStageMail(...)
    local fields = {
        "Mail", -- BackStageMail
    }
    Network.RequestDynamic("ReceiveBackStageMailParams", fields, ...)
end

return Net.Chat