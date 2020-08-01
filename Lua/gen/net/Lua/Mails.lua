Net.Mails = {}

-- 请求-同步邮件
function Net.Mails.Sync(...)
    local fields = {
        "Category", -- int32
        "FromMailNum", -- int32
        "ToMailNum", -- int32
    }
    Network.RequestDynamic("MailSyncParams", fields, ...)
end

-- 请求-领取附件
function Net.Mails.Claim(...)
    local fields = {
        "MailIds", -- array-string
    }
    Network.RequestDynamic("MailClaimParams", fields, ...)
end

-- 请求-标记邮件已读
function Net.Mails.MarkRead(...)
    local fields = {
        "Category", -- int32
        "MailIds", -- array-string
    }
    Network.RequestDynamic("MailMarkReadParams", fields, ...)
end

-- 请求-发送邮件
function Net.Mails.Send(...)
    local fields = {
        "Category", -- int32
        "ReceiverId", -- string
        "Content", -- string
        "AlliancePos", -- array-int32
    }
    Network.RequestDynamic("MailSendParams", fields, ...)
end

-- 请求-添加玩家至邮件组
function Net.Mails.AddToGroup(...)
    local fields = {
        "SessionId", -- string
        "ReceiverIds", -- array-string
    }
    Network.RequestDynamic("MailAddToGroupParams", fields, ...)
end

-- 请求-从邮件组移除玩家
function Net.Mails.DelFromGroup(...)
    local fields = {
        "SessionId", -- string
        "ReceiverIds", -- array-string
        "IsQuit", -- bool
    }
    Network.RequestDynamic("MailDelFromGroupParams", fields, ...)
end

-- 请求-删除邮件
function Net.Mails.Delete(...)
    local fields = {
        "Category", -- int32
        "MailIds", -- array-string
    }
    Network.RequestDynamic("MailDeleteParams", fields, ...)
end

-- 请求-收藏邮件
function Net.Mails.MarkFavorite(...)
    local fields = {
        "IsFavorite", -- bool
        "MailIds", -- array-string
    }
    Network.RequestDynamic("MailMarkFavoriteParams", fields, ...)
end

-- 请求一封邮件的数据
function Net.Mails.RequestMailData(...)
    local fields = {
        "UserId", -- string
        "MailId", -- string
    }
    Network.RequestDynamic("RequestMailDataParams", fields, ...)
end

-- 请求一改变邮件状态
function Net.Mails.SetStatus(...)
    local fields = {
        "MailId", -- string
        "Status", -- int32
    }
    Network.RequestDynamic("MailSetStatusParams", fields, ...)
end

-- 请求-同步会话
function Net.Mails.SyncSessions(...)
    local fields = {
        "Offset", -- int64
    }
    Network.RequestDynamic("MailSyncSessionsParams", fields, ...)
end

-- 请求-同步会话信息
function Net.Mails.SyncMessages(...)
    local fields = {
        "SessionId", -- string
        "FromMailNum", -- int32
        "ToMailNum", -- int32
    }
    Network.RequestDynamic("MailSyncMessagesParams", fields, ...)
end

-- 请求-邮件概况信息
function Net.Mails.Info(...)
    Network.RequestDynamic("MailInfoParams", {}, ...)
end

-- 请求-标记会话已读
function Net.Mails.MarkSessionReaded(...)
    local fields = {
        "SessionId", -- string
        "Number", -- int32
    }
    Network.RequestDynamic("MailMarkSessionReadedParams", fields, ...)
end

-- 请求-删除会话
function Net.Mails.DeleteSession(...)
    local fields = {
        "SessionIds", -- array-string
    }
    Network.RequestDynamic("MailDeleteSessionParams", fields, ...)
end

-- 请求-一键已读并领奖
function Net.Mails.MarkReadAndClaim(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("MailMarkReadAndClaimParams", fields, ...)
end

-- 请求-一键删除
function Net.Mails.DeleteAll(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("MailDeleteAllParams", fields, ...)
end

-- 请求-删除会话
function Net.Mails.DeleteAllSessions(...)
    Network.RequestDynamic("MailDeleteAllSessionsParams", {}, ...)
end

-- 请求-获取会话
function Net.Mails.GetSession(...)
    local fields = {
        "SessionId", -- string
    }
    Network.RequestDynamic("MailGetSessionParams", fields, ...)
end

-- 请求-删除并退出会话
function Net.Mails.DelAndQuitSession(...)
    local fields = {
        "SessionId", -- string
    }
    Network.RequestDynamic("MailDelAndQuitSessionParams", fields, ...)
end

-- 请求-修改会话名字
function Net.Mails.ChangeGroupName(...)
    local fields = {
        "SessionId", -- string
        "Name", -- string
    }
    Network.RequestDynamic("MailChangeGroupNameParams", fields, ...)
end

-- 请求-置顶会话
function Net.Mails.SetTop(...)
    local fields = {
        "SessionId", -- string
        "IsTop", -- bool
    }
    Network.RequestDynamic("MailSetTopParams", fields, ...)
end

-- 请求-标记所有会话已读
function Net.Mails.MarkAllSessionsRead(...)
    Network.RequestDynamic("MailMarkAllSessionsReadParams", {}, ...)
end

return Net.Mails