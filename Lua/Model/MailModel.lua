-- author:{Amu}
-- time:2019-05-27 16:04:18

--邮件缓存池
local Mails_Pool = {}

local _writeNum = 50    --一次写入数据库的量

Mails_Pool._list = {}
Mails_Pool._msglist = {}
Mails_Pool._favoritelist = {}

function Mails_Pool:Push(datas)
    if #self._list <=0 then
        self._list = datas
    else
        for _,v in ipairs(datas)do
            table.insert(self._list, v)
        end
    end
end

function Mails_Pool:Pop() -- pop writeNum 数量
    local list = {}
    local maxNum = (_writeNum<#self._list) and _writeNum or #self._list
    for i=1, _writeNum do
        table.insert(list, table.remove(self._list))
    end
    return list
end

function Mails_Pool:PushMsg(datas)
    if #self._msglist <=0 then
        self._msglist = datas
    else
        for _,v in ipairs(datas)do
            table.insert(self._msglist, v)
        end
    end
end

function Mails_Pool:PopMsg() -- pop writeNum 数量
    local list = {}
    local maxNum = (_writeNum<#self._msglist) and _writeNum or #self._msglist
    for i=1, _writeNum do
        table.insert(list, table.remove(self._msglist))
    end
    return list
end

function Mails_Pool:PushFavorite(datas)
    if #self._favoritelist <=0 then
        self._favoritelist = datas
    else
        for _,v in ipairs(datas)do
            table.insert(self._favoritelist, v)
        end
    end
end

function Mails_Pool:PopFavorite() -- pop writeNum 数量
    local list = {}
    local maxNum = (_writeNum<#self._favoritelist) and _writeNum or #self._favoritelist
    for i=1, _writeNum do
        table.insert(list, table.remove(self._favoritelist))
    end
    return list
end

if MailModel then 
    return MailModel 
end

local MailUpdateData = import("Helper/MailUpdateData")

MailModel = {}

MailModel.mailInfo  = {}
MailModel.briefMailInfo = {}

local briefGid = 0      --简要信息唯一id

local mailTable = {
    "type",             --邮件类型索引
    "subject",          --邮件标题（主要用于区分群组邮件）
    "gid",              --邮件自增唯一id
    "uid",              --邮件唯一id
    "isRead",           --邮件是否阅读
    "isFavorite",       --邮件是否收藏
    "isClaimed",        --邮件是否领取
    "expiredAt",        --邮件过期时间
    "data"              --邮件内容
}

local mailTableType = {
    type        = "INTEGER NOT NULL",
    subject     = "TEXT",
    gid         = "INTEGER NOT NULL",
    uid         = "TEXT NOT NULL UNIQUE",
    isRead      = "INTEGER NOT NULL",
    isFavorite  = "INTEGER NOT NULL",
    isClaimed   = "INTEGER NOT NULL",
    expiredAt   = "INTEGER DEFAULT 0",
    data        = "TEXT NOT NULL"
}

MailModel.mail_db_name      = "mail.db"                 --邮件数据 库名字

local mail_table_name   = "mailInfo"                    --邮件数据 表名字
local msg_mail_table_name = "msgmailInfo"               --消息邮件 表名字
local favorite_mail_table_name = "favoritemailInfo"     --收藏邮件 表名字

local _index = "index_name"                 --type 索引名字
local _sub_index = "sbuIndexc_name"         --Subject 
local _f_index = "f_index"                  --isFavorite 索引名字
local _gidIndex = "index_Gid"               --gid 索引名字
local _uid_index = "uid_index"              --uid 索引名字
local _c_index = "c_index"                  --isClaimed 索引名字
local _expiredAt_index = "expiredAt_index"  --expiredAt 索引名字

local msgMailTable = {
    "uid",
    "subType",
    "number",
    "sessionId",
    "data"
}

local msgMailTableType = {
    uid         = "TEXT NOT NULL UNIQUE",
    subType     = "INTEGER NOT NULL",
    number      = "INTEGER NOT NULL",
    sessionId   = "TEXT NOT NULL",
    data        = "TEXT NOT NULL"
}

local _uid_msgindex         = "uid_msgindex"
local _subType_msgindex    = "subType_index"
local _number_msgindex     = "number_index"
local _sessionId_msgindex        = "sessionId_index"

local _num = 10                 --一次取得的数据量

local _maxGid = 1               --当前储存的最近邮件的gid

local _msgOffset = 0            --msg读取偏移量

local _scheduler = false        --定时器是否开启

-- local JSON = require("CJson")

function MailModel:Init( )
    self:InitEvent()
    -- mail_table_name = UserModel.data.accountId
    -- Model.Player.Name
    self.mail_db_name = string.format( "mail_%s.db", UserModel.data.accountId)

    mail_table_name = string.format( "'mail_%s'", UserModel.data.accountId)
    msg_mail_table_name = string.format( "'msg_mail_%s'", UserModel.data.accountId)
    favorite_mail_table_name = string.format( "'favorite_mail_%s'", UserModel.data.accountId)

    --  SQLiteHelper
    --  打开数据库
    SqliteHelper:Open(self.mail_db_name)

    self:InitTable(mail_table_name)
    self:InitTable(favorite_mail_table_name)
    self:InitMsgTable(msg_mail_table_name)


    -- self:GetEveryTypeNum()
    -- self:RequestNewMails()
    -- self:InitData()
    --每个类型邮件取十个出来
    -- self:ReadTenEverType()
    MailUpdateData:Init()

    self:InitMailsData()
end

function MailModel:InitTable(tableName)
    _index = string.format( "'%s_%s'", UserModel.data.accountId, _index)
    _sub_index = string.format( "'%s_%s'", UserModel.data.accountId, _sub_index)
    _f_index = string.format( "'%s_%s'", UserModel.data.accountId, _f_index)
    _gidIndex = string.format( "'%s_%s'", UserModel.data.accountId, _gidIndex)
    _uid_index = string.format( "'%s_%s'", UserModel.data.accountId, _uid_index)
    _c_index = string.format( "'%s_%s'", UserModel.data.accountId, _c_index)
    _expiredAt_index = string.format( "'%s_%s'", UserModel.data.accountId, _expiredAt_index)

    local isTableExist = SqliteHelper:IsTableExist(tableName)

    --表存在 且表结构变化时删除表重新创建
    if isTableExist then
        for k,v in ipairs(mailTable) do
            local isExist = SqliteHelper:IsColumnExist(tableName, v)
            if not isExist then
                local query = string.format( "DROP TABLE %s", tableName)
                SqliteHelper:Exec(query)
                isTableExist = false
                --清除差异片段
                MailUpdateData:ClearData()
                break
            end
        end
    end
    
    --  创建表
    if not isTableExist then
        local query = "CREATE TABLE "..tableName.." ("
        for k,v in ipairs(mailTable) do
            local type = mailTableType[v]
            query = query..v.." "..type..", "
        end
        query = string.sub(query, 1, string.len(query)-2)
        query = query..")"
        SqliteHelper:AddExecutQuery(query)
        --添加索引
        query = string.format("CREATE INDEX %s ON %s (%s,%s)",_index, tableName, "type","isRead")
        SqliteHelper:AddExecutQuery(query)
        query = string.format("CREATE INDEX %s ON %s (%s)",_sub_index, tableName, "subject")
        SqliteHelper:AddExecutQuery(query) 
        query = string.format("CREATE INDEX %s ON %s (%s)",_f_index, tableName, "isFavorite")
        SqliteHelper:AddExecutQuery(query) 
        query = string.format("CREATE INDEX %s ON %s (%s)",_gidIndex, tableName, "gid")
        SqliteHelper:AddExecutQuery(query) 
        query = string.format("CREATE INDEX %s ON %s (%s)",_uid_index, tableName, "uid")
        SqliteHelper:AddExecutQuery(query) 
        query = string.format("CREATE INDEX %s ON %s (%s)",_c_index, tableName, "isClaimed")
        SqliteHelper:AddExecutQuery(query) 
        query = string.format("CREATE INDEX %s ON %s (%s)",_expiredAt_index, tableName, "expiredAt")
        SqliteHelper:AddExecutQuery(query) 
    end
end

function MailModel:InitMsgTable(tableName)
    _subType_msgindex = string.format( "'%s_%s'", UserModel.data.accountId, _subType_msgindex)
    _number_msgindex = string.format( "'%s_%s'", UserModel.data.accountId, _number_msgindex)
    _uid_msgindex = string.format( "'%s_%s'", UserModel.data.accountId, _uid_msgindex)

    local isTableExist = SqliteHelper:IsTableExist(tableName)

    --表存在 且表结构变化时删除表重新创建
    if isTableExist then
        for k,v in ipairs(msgMailTable) do
            local isExist = SqliteHelper:IsColumnExist(tableName, v)
            if not isExist then
                local query = string.format( "DROP TABLE %s", tableName)
                SqliteHelper:Exec(query)
                isTableExist = false
                break
            end
        end
    end

    --  创建表
    if not isTableExist then
        local query = "CREATE TABLE "..tableName.." ("
        for k,v in ipairs(msgMailTable) do
            local type = msgMailTableType[v]
            query = query..v.." "..type..", "
        end
        query = string.sub(query, 1, string.len(query)-2)
        query = query..")"
        SqliteHelper:AddExecutQuery(query)
        --添加索引
        query = string.format("CREATE INDEX %s ON %s (%s)",_subType_msgindex, tableName, "subType")
        SqliteHelper:AddExecutQuery(query) 
        query = string.format("CREATE INDEX %s ON %s (%s)",_number_msgindex, tableName, "number")
        SqliteHelper:AddExecutQuery(query) 
        query = string.format("CREATE INDEX %s ON %s (%s)",_sessionId_msgindex, tableName, "sessionId")
        SqliteHelper:AddExecutQuery(query) 
    end
end

function MailModel:InitEvent()
    local callback = function()
        local _writeData = Mails_Pool:Pop()
        local _writeMsg = Mails_Pool:PopMsg()
        local _writeFavorite= Mails_Pool:PopFavorite()
        if #_writeData > 0 then
            self:writeBatchData(_writeData)
        elseif #_writeMsg > 0 then
            self:writeBatchMsg(_writeMsg)
        elseif #_writeFavorite > 0 then
            self:writeBatchFavorite(_writeFavorite)
        else
            Event.Broadcast(MAILEVENTTYPE.MailWriteEndEvent)
        end
    end
    
    Event.AddListener(MAILEVENTTYPE.MailDBOpenEvent, function()
        SqliteHelper:Open(MailModel.mail_db_name)
        if SqliteHelper:IsDbExist(MailModel.mail_db_name) and not _scheduler then
            Scheduler.ScheduleFast(callback, 0.1)
            _scheduler = true
        end
    end)

    Event.AddListener(MAILEVENTTYPE.MAILDBCloseEvent, function()
        Scheduler.UnScheduleFast(callback)
        _scheduler = false
        SqliteHelper:Close(MailModel.mail_db_name)
    end)

    Event.AddListener(MAILEVENTTYPE.MailWriteEvent, function(type, mails)
        if #mails > 0 then
            if type == MAIL_TYPE.Msg then
                Mails_Pool:PushMsg(mails)
            elseif type == MAIL_TYPE.Favorite then
                Mails_Pool:PushFavorite(mails)
            else
                Mails_Pool:Push(mails)
            end
        end
        if SqliteHelper:IsDbExist(MailModel.mail_db_name) and not _scheduler then
            Scheduler.ScheduleFast(callback, 0.1)
            _scheduler = true
        end
    end)

    Event.AddListener(MAILEVENTTYPE.MailWriteEndEvent, function()
        Scheduler.UnScheduleFast(callback)
        _scheduler = false
    end)

    local callback1 = function()
    end
end

function MailModel:InitMailsData()
    -- if not self.mailInfo[MAIL_TYPE.Msg] then
    --     self.mailInfo[MAIL_TYPE.Msg] = {}
    --     self.mailInfo[MAIL_TYPE.Msg].type = MAIL_TYPE.Msg
    --     self.mailInfo[MAIL_TYPE.Msg].info = {}
    --     self.mailInfo[MAIL_TYPE.Msg].MsgsInfos = {}
    -- end

    for _,v in pairs(MAIL_TYPE) do
        self.mailInfo[v] = {}
        self.mailInfo[v].notReadAmount = 0
        self.mailInfo[v].notReceiveAmount = 0
        self.mailInfo[v]._maxNum = 0
        self.mailInfo[v].type = v
        self.mailInfo[v].info = {}
        self.mailInfo[v].isEnd = false
        if v == MAIL_TYPE.Msg then
            self.mailInfo[v].MsgsInfos = {}
            self.mailInfo[v].TopSessionIds = {}
        else
            self.mailInfo[v]._maxGid = 0
        end
    end

    Net.Mails.Info(function(msg)
        for _,v in pairs(msg.MailInfos)do
            self.mailInfo[v.Category]._maxGid = v.Max
            self.mailInfo[v.Category].s_maxGid = v.Max
            self.mailInfo[v.Category]._maxNum = v.Total
            self.mailInfo[v.Category].c_maxGid = self:getMaxGidByType(v.Category)
            if self.mailInfo[v.Category].s_maxGid > self.mailInfo[v.Category].c_maxGid then
                local data = {
                    _f = v.Max,
                    _e = self:getMaxGidByType(v.Category)
                }
                MailUpdateData:InsertData(v.Category, data)
            end
            self.mailInfo[v.Category].notReadAmount = v.Unread
            self.mailInfo[v.Category].notReceiveAmount = v.Reward
            self.mailInfo[v.Category].isFull = false
        end

        local notRead = 0
        for _,v in pairs(msg.UnreadSessionIds)do
            notRead = notRead + 1
            self.mailInfo[MAIL_TYPE.Msg].MsgsInfos[v] = {}
        end
        for _,v in pairs(msg.TopSessionIds)do
            self.mailInfo[MAIL_TYPE.Msg].TopSessionIds[v] = {}
        end
        self.mailInfo[MAIL_TYPE.Msg].notReadAmount = notRead

        -- self:ReadTenEverType()
        Event.Broadcast(EventDefines.UIMailsNumChange, {})
    end)

    -- self:ReadTenMsgGroup()
end

-- --登录拉取所有本地未储存的邮件
-- function MailModel:RequestNewMails()
-- end

--每种邮件取10个
function MailModel:ReadTenEverType()
    for _,v in pairs(MAIL_TYPE) do
        if v == MAIL_TYPE.Msg then
        elseif v == MAIL_TYPE.Favorite then
        else
            self:ReadTenDataByType(v)
        end
    end
end

function MailModel:ReInitMsgGroup()
    
end

function MailModel:ReadTenMsgGroup()
    if self.mailInfo[MAIL_TYPE.Msg].isEnd then
        return
    end
    local msgsLen = 0
    for _,v in pairs(self.mailInfo[MAIL_TYPE.Msg].info)do
        msgsLen = msgsLen + 1
    end
    Net.Mails.SyncSessions(msgsLen, function(msg)
        if #msg.MailSessions <= 0 then
            self.mailInfo[MAIL_TYPE.Msg].isEnd = true
        end
        for _,v in ipairs(msg.MailSessions)do
            if self.mailInfo[MAIL_TYPE.Msg].MsgsInfos[v.Uuid] then
                self.mailInfo[MAIL_TYPE.Msg].MsgsInfos[v.Uuid].Number = v.MsgNumber
                v.IsRead = true
            else
                v.IsRead = false
            end
            local maxNumber = self:getMsgMaxNumber(v.Uuid)
            if v.MsgNumber > maxNumber then
                local data = {
                    _f = v.MsgNumber,
                    _e =maxNumber
                }
                MailUpdateData:InsertData(v.Uuid, data)
            end
            v.msgs = {}
            self.mailInfo[MAIL_TYPE.Msg].info[v.Uuid] = v
        end
        Event.Broadcast(MAILEVENTTYPE.MailRefresh)
    end)
end
-- mailInfo:table: 0000000126734870
-- 1:table: 000000012CA259A0
-- MsgsInfos:table: 000000012CA25E20
-- notReadAmount:0
-- _maxNum:0
-- info:table: 0000000153BB4AA0
-- isEnd:false
-- notReceiveAmount:0
-- TopSessionIds:table: 000000012CA251A0
-- type:1

-- MsgNumber:2
-- Category:8
-- IsRead:false
-- LastMsg:table: 0000000153C10820
-- Members:table: 0000000153C101E0
-- msgs:table: 0000000153C10B60
-- Title:""
-- UpdatedAt:1595243256
-- UserId:"z5#21"
-- Uuid:"z5#18:z5#21"
function MailModel:UpdateMsgSessionInfo(sessionId, cb)
    Net.Mails.GetSession(sessionId, function(msg)
        local localInfo = self.mailInfo[MAIL_TYPE.Msg].info[sessionId]
        if localInfo then
            localInfo.Members = msg.Members
        end
        cb()
    end)
end

function MailModel:InsterMsgGroup(sessionId, msgGroup)
    msgGroup.msgs = {}
    self.mailInfo[MAIL_TYPE.Msg].info[sessionId] = msgGroup
end

local readMsgNum = 0

function MailModel:ReadTenMsg(sessionId, index)
    local msgsInfo = self.mailInfo[MAIL_TYPE.Msg].info[sessionId]
    if not msgsInfo then
        return
    end
    local members = msgsInfo.Members

    local msgLen = #msgsInfo.msgs
    local _maxGid
    if msgLen > 0 then
        _maxGid = msgsInfo.msgs[msgLen].Number - 1
    else
        _maxGid = msgsInfo.MsgNumber
    end
    local data = MailUpdateData:GetData(sessionId)
    local local_f = self:getMsgMaxNumber(sessionId)
    if data and data._f and (data._f > local_f or (data._f >= _maxGid and data._e < _maxGid)) then
        Net.Mails.SyncMessages(sessionId, msgsInfo.MsgNumber, 0, function(msg)
            local _msgs = {}
            for _,v in ipairs(msg.MailMessages)do
                v.sessionId = sessionId
                local _msg = {
                    Category = v.Category,
                    Uuid = v.Uuid,
                    Number = v.Number,
                    UserId = v.UserId,
                    Content = v.Content,
                    CreatedAt = v.SentAt,
                    IsGameManager = v.IsGameManager,
                    ChattingType = v.ChattingType,
                    sessionId = sessionId,
                }
                if v.UserId == "" then
                    _msg.msgType = MAIL_MSG_TYPE.System
                else
                    _msg.msgType = MAIL_MSG_TYPE.Normal
                    local memberInfo
                    for _,member in pairs(members)do
                        if member.UserId == v.UserId then
                            memberInfo = member
                            break
                        end
                    end
                    _msg.VipActive = memberInfo.VipActive
                    _msg.VipLevel = memberInfo.VipLevel
                    _msg.Alliance = memberInfo.Alliance
                    _msg.Sender = memberInfo.Name
                    _msg.Avatar = memberInfo.Avatar
                end

                MailUpdateData:Pop(sessionId)
                if (data._f-#msg.MailMessages) > data._e then
                    local data = {
                        _f = data._f-#msg.MailMessages,
                        _e = data._e
                    }
                    MailUpdateData:InsertData(sessionId, data)
                end
                v = _msg
                table.insert(msgsInfo.msgs, _msg)
                table.insert(_msgs, _msg)
            end
            Event.Broadcast(MAILEVENTTYPE.MailWriteEvent, MAIL_TYPE.Msg, _msgs)
            readMsgNum = readMsgNum + #msg.MailMessages
            if readMsgNum < 10 and #msg.MailMessages > 0 then
                self:ReadTenMsg(sessionId)
            else
                if readMsgNum > 0 then
                    Event.Broadcast(MAILEVENTTYPE.MailMsgReadEvent)
                end
                readMsgNum = 0
            end
        end)
    else
        local infos
        if data._f then
            infos = self:_getMsgFromDB(msgsInfo.msgs, sessionId, _maxGid, data._f)
        else
            infos = self:_getMsgFromDB(msgsInfo.msgs, sessionId, _maxGid, 0)
        end
        readMsgNum = readMsgNum + #infos
        if readMsgNum < 10 and #infos > 0 then
            self:ReadTenMsg(sessionId)
        else
            readMsgNum = 0
            Event.Broadcast(MAILEVENTTYPE.MailMsgReadEvent)
        end
    end
end

local readDataNum = 0

function MailModel:ReadTenDataByType(type, _readEnd)
    --如果本地最新不是服务器最新数据
    -- 根据未更新区间  从服务器拉取邮件 或者读取本地数据
    -- if self.mailInfo[type].isEnd then
    --     return
    -- end
    print("=========ReadTenDataByType===========")
    local _maxGid = self.mailInfo[type]._maxGid
    local data = MailUpdateData:GetData(type)
    local local_f = self:getMaxGidByType(type)
    if data and data._f and (data._f > local_f or (data._f >= _maxGid and data._e < _maxGid)) then
        Net.Mails.Sync(type, data._f, data._e, function(msg)
            print("=========Net.Mails.Sync=========== data._f : " .. data._f .. "  data._e:  ".. data._e)
            for i = #msg.Mails, 1, -1 do   -- 容错处理
                if type ~= msg.Mails[i].Category then
                    table.remove(msg.Mails, i)
                end
            end
            local _len = #msg.Mails
            if _len <= 0 then
                -- self.mailInfo[type].isEnd = true
                if not _readEnd then
                    self:ReadTenDataByType(type, true)
                end
            end
            if _len > 0 then
                self.mailInfo[type]._maxGid = msg.Mails[_len].Number - 1
            end
            for _,v in ipairs(msg.Mails)do
                table.insert(self.mailInfo[type].info, v)
            end
            MailUpdateData:Pop(type)
            if _len > 0 and (msg.Mails[_len].Number - 1) > data._e then
                local data = {
                    _f = msg.Mails[_len].Number - 1,
                    _e = data._e
                }
                MailUpdateData:InsertData(type, data)
            end
            Event.Broadcast(MAILEVENTTYPE.MailWriteEvent, type, msg.Mails)
            readDataNum = readDataNum + _len
            if readDataNum < 10 and _len > 0 then
                self:ReadTenDataByType(type)
            else
                Event.Broadcast(MAILEVENTTYPE.MailsReadEvent)
                if not _readEnd then
                    self:ReadTenDataByType(type, true)
                end
                readDataNum = 0
            end
        end)
    else
        local infos = {}
        if data._f then
            infos = self:_getDataFromDB(type, _maxGid, data._f)
            if #infos > 0 then
                self.mailInfo[type]._maxGid = infos[#infos].gid-1
            else
                self.mailInfo[type]._maxGid = data._f
            end
        else
            infos = self:_getDataFromDB(type, _maxGid, 0)
            if #infos > 0 then
                self.mailInfo[type]._maxGid = infos[#infos].gid-1
            end
        end
        readDataNum = readDataNum + #infos
        if readDataNum < 10 and #infos > 0 then
            self:ReadTenDataByType(type)
        else
            if readDataNum > 0 and (#infos > 0 or not _readEnd) then
                Event.Broadcast(MAILEVENTTYPE.MailsReadEvent)
                if not _readEnd then
                    self:ReadTenDataByType(type, true)
                end
            end
            readDataNum = 0
        end
    end
end

function MailModel:ReadStarMails()
    local infos = self.mailInfo[MAIL_TYPE.Favorite].info
    Net.Mails.Sync(MAIL_TYPE.Favorite, #infos, 0, function(msg)
        for _,v in ipairs(msg.Mails)do
            table.insert(self.mailInfo[MAIL_TYPE.Favorite].info, v)
        end
        Event.Broadcast(MAILEVENTTYPE.MailStarReadEvent, msg.Mails)
    end)
end

--  _f  起始Gid  
--  _e  结束Gid
function MailModel:_getDataFromDB(type, _f, _e)
    local query = string.format("SELECT * FROM %s WHERE type=%d AND gid>=%d and gid<=%d ORDER BY gid DESC LIMIT %d",
    mail_table_name, type, _e, _f, _num)

    local infos = SqliteHelper:Query(query)

    for _,v in pairs(infos) do
        local data = JSON.decode(v.data)
        data.IsRead =(v.isRead == 1) and true or false
        data.IsFavorite = (v.isFavorite == 1) and true or false
        data.IsClaimed = (v.isClaimed == 1) and true or false
        table.insert(self.mailInfo[type].info, data)
    end
    return infos
end

function MailModel:_getMsgFromDB(msgs, sessionId, _f, _e)
    local query = string.format("SELECT * FROM %s WHERE sessionId='%s' AND number>=%d and number<=%d ORDER BY number DESC LIMIT %d",
        msg_mail_table_name, sessionId, _e, _f, _num)

    local infos = SqliteHelper:Query(query)

    for _,v in pairs(infos) do
        table.insert(msgs, JSON.decode(v.data))
    end
    return infos
end

--初始化邮件数据
function MailModel:GetEveryTypeNum( )
    for _,type in pairs(MAIL_TYPE) do
        if not self.mailInfo[type] then
            self.mailInfo[type] = {}
            self.mailInfo[type].type = type
            self.mailInfo[type].info = {}
        end
        self.mailInfo[type].num = self:GetAmountByType(type)
        self.mailInfo[type].notReadAmount = self:GetNotReadAmountByType(type)
    end
end

--插入单个数据
function MailModel:InsertData(info)
    local type = info.Category
    if not self.mailInfo[type].info then
        self.mailInfo[type].info = {}
    end
    for _,v in ipairs(self.mailInfo[type].info)do       -- 查重
        if v.Uuid == info.Uuid then
            return false
        end
    end
    table.insert(self.mailInfo[type].info, 1, info)
    self.mailInfo[type].notReadAmount = self.mailInfo[type].notReadAmount+1
    Event.Broadcast(MAILEVENTTYPE.MailWriteEvent, info.Category, {info})
    return true
end

function MailModel:InsertMsg(msg)
    local msgInfo = self.mailInfo[MAIL_TYPE.Msg].info[msg.SessionId]
    local _msgsInfos = self.mailInfo[MAIL_TYPE.Msg].MsgsInfos
    msg.MailMessage.sessionId = msg.SessionId
    if msgInfo then     --已加载邮件到达
        local _msg = {
            Category = msg.MailMessage.Category,
            Uuid = msg.MailMessage.Uuid,
            Number = msg.MailMessage.Number,
            UserId = msg.MailMessage.UserId,
            Content = msg.MailMessage.Content,
            CreatedAt = msg.MailMessage.SentAt,
            IsGameManager = msg.MailMessage.IsGameManager,
            ChattingType = msg.MailMessage.ChattingType,
            sessionId = msg.SessionId,
        }
        if msg.MailMessage.UserId == "" then
            _msg.msgType = MAIL_MSG_TYPE.System
        else
            _msg.msgType = MAIL_MSG_TYPE.Normal
            local members = msgInfo.Members
            local memberInfo
            for _,member in pairs(members)do
                if member.UserId == msg.MailMessage.UserId then
                    memberInfo = member
                    break
                end
            end
            _msg.VipActive = memberInfo.VipActive
            _msg.VipLevel = memberInfo.VipLevel
            _msg.Alliance = memberInfo.Alliance
            _msg.Sender = memberInfo.Name
            _msg.Avatar = memberInfo.Avatar
        end

        msgInfo.LastMsg = msg.MailMessage
        msgInfo.MsgNumber = msg.MailMessage.Number
        table.insert(msgInfo.msgs, 1, _msg)

        self:Afternsert(msg.SessionId, msgInfo.MsgNumber)
        Event.Broadcast(MAILEVENTTYPE.MailWriteEvent, MAIL_TYPE.Msg, {_msg})
    else        --未加载的新邮件到达
        Net.Mails.GetSession(msg.SessionId, function(msgGroup)
            msgGroup.LastMsg = msg.MailMessage
            msgGroup.MsgNumber = msg.MailMessage.Number
            msgGroup.msgs = {}

            local _msg = {
                Category = msg.MailMessage.Category,
                Uuid = msg.MailMessage.Uuid,
                Number = msg.MailMessage.Number,
                UserId = msg.MailMessage.UserId,
                Content = msg.MailMessage.Content,
                CreatedAt = msg.MailMessage.SentAt,
                IsGameManager = msg.MailMessage.IsGameManager,
                ChattingType = msg.MailMessage.ChattingType,
                sessionId = msg.SessionId,
            }
            if msg.MailMessage.UserId == "" then
                _msg.msgType = MAIL_MSG_TYPE.System
            else
                _msg.msgType = MAIL_MSG_TYPE.Normal
                local memberInfo
                for _,member in pairs(msgGroup.Members)do
                    if member.UserId == msg.MailMessage.UserId then
                        memberInfo = member
                        break
                    end
                end
                _msg.VipActive = memberInfo.VipActive
                _msg.VipLevel = memberInfo.VipLevel
                _msg.Alliance = memberInfo.Alliance
                _msg.Sender = memberInfo.Name
                _msg.Avatar = memberInfo.Avatar
            end

            self:Afternsert(msg.SessionId, msgGroup.MsgNumber)

            table.insert(msgGroup.msgs, 1, _msg)
            self.mailInfo[MAIL_TYPE.Msg].info[msgGroup.Uuid] = msgGroup
            Event.Broadcast(MAILEVENTTYPE.MailWriteEvent, MAIL_TYPE.Msg, {_msg})
            Event.Broadcast(MAILEVENTTYPE.MailMsgReadEvent)

            Event.Broadcast(MAILEVENTTYPE.MailNewMsgGroup)
        end)
    end
    if not _msgsInfos[msg.SessionId] then
        _msgsInfos[msg.SessionId] = {}
        self.mailInfo[MAIL_TYPE.Msg].notReadAmount = self.mailInfo[MAIL_TYPE.Msg].notReadAmount + 1
    end
end

function MailModel:SessionInfoChange(type, info)
    local msgInfo = self.mailInfo[MAIL_TYPE.Msg].info[info.Uuid]
    if msgInfo then
        msgInfo.Members = info.Members
        msgInfo.MsgNumber = info.MsgNumber
        msgInfo.Title = info.Title
        msgInfo.UpdatedAt = info.UpdatedAt
    else
        local msgGroup = info
        msgGroup.msgs = {}
        self.mailInfo[MAIL_TYPE.Msg].info[msgGroup.Uuid] = msgGroup
    end
end

function MailModel:DeleteSessionInfo(type, sessionId)
    local msgInfo = self.mailInfo[MAIL_TYPE.Msg].info[sessionId]
    if msgInfo then
        self.mailInfo[MAIL_TYPE.Msg].info[sessionId] = nil
    end
    if self.mailInfo[MAIL_TYPE.Msg].MsgsInfos[sessionId] ~= nil then
        self.mailInfo[MAIL_TYPE.Msg].MsgsInfos[sessionId] = nil
        self.mailInfo[MAIL_TYPE.Msg].notReadAmount =  self.mailInfo[MAIL_TYPE.Msg].notReadAmount - 1
    end
end

--新邮件来时  根据  本地数据库最大number   和  新邮件number  判断是否产生新未储存区间（本地没有数据就没有未读区间）
function MailModel:Afternsert(sessionId, number)
    local local_f = self:getMsgMaxNumber(sessionId)
    if local_f+1 < number then
        local _data = {
            _f = number - 1,
            _e = local_f
        }
        MailUpdateData:InsertData(sessionId, _data)
    end
end

--根据邮件type获得最多_num个连续本地数据
function MailModel:readTenByType(id, type)
    local query
    if type == MAIL_TYPE.Favorite then
        query = string.format("SELECT * FROM %s WHERE isFavorite=%d AND gid<=%d ORDER BY gid DESC LIMIT %d",
                    mail_table_name,1,id,_num)
    elseif type == MAIL_TYPE.Msg then
        query = string.format("SELECT m1.* FROM %s m1 LEFT JOIN %s m2 ON (m1.subject = m2.subject AND m1.gid < m2.gid) WHERE m1.type=%d AND m2.gid IS NULL ORDER BY gid DESC LIMIT %d OffSET %d",
                    mail_table_name,mail_table_name,type,_num, _msgOffset)
    else
        query = string.format("SELECT * FROM %s WHERE type=%d AND gid<=%d ORDER BY gid DESC LIMIT %d",
                    mail_table_name,type,id,_num)
    end
    local infos = SqliteHelper:Query(query)

    if type == MAIL_TYPE.Msg then
    end

    if not self.mailInfo[type] then
        self.mailInfo[type] = {}
        self.mailInfo[type].type = type
        self.mailInfo[type].info = {}
    end
    for _,v in pairs(infos) do
        if type == MAIL_TYPE.Msg then
            local data = JSON.decode(v.data)
            data.IsRead =(v.isRead == 1) and true or false
            data.IsFavorite = (v.isFavorite == 1) and true or false
            data.IsClaimed = (v.isClaimed == 1) and true or false

            if not self.mailInfo[type].info[data.Subject] then
                self.mailInfo[type].info[data.Subject] = {}
                self.mailInfo[type].info[data.Subject].subject = data.Subject
                self.mailInfo[type].info[data.Subject].data = {}
            end
            table.insert(self.mailInfo[type].info[data.Subject].data, data)
        else
            local data = JSON.decode(v.data)
            data.IsRead =(v.isRead == 1) and true or false
            data.IsFavorite = (v.isFavorite == 1) and true or false
            data.IsClaimed = (v.isClaimed == 1) and true or false
            table.insert(self.mailInfo[type].info, data)
        end
    end

    return infos
end

--根据邮件gid 获得数据
function MailModel:readDataById(gid)
    local query = string.format( "SELECT * FROM %s WHERE gid=%d",mail_table_name, gid)
    return SqliteHelper:Query(query)
end

--批量写入邮件
function MailModel:writeBatchData(infos)
    local query = "BEGIN TRANSACTION"
    SqliteHelper:Exec(query)
    for _,v in pairs(infos) do
        local isRead = v.IsRead and 1 or 0
        local isFavorite = v.IsFavorite and 1 or 0
        local isClaimed = v.IsClaimed and 1 or 0
        query = string.format( "INSERT INTO %s VALUES(%d, '%s', %d, '%s', %d, %d, %d, %d, '%s')",
                        mail_table_name, v.Category, v.Subject, v.Number, v.Uuid, 
                        isRead, isFavorite, isClaimed,
                        v.RewardExpiredAt, JSON.encode(v))
        SqliteHelper:Exec(query)
    end
    query = "COMMIT TRANSACTION"
    SqliteHelper:Exec(query)
end

function MailModel:writeBatchMsg(infos)
    local query = "BEGIN TRANSACTION"
    SqliteHelper:Exec(query)
    for _,v in pairs(infos) do
        query = string.format( "INSERT INTO %s VALUES('%s', %d, %d, '%s', '%s')",
            msg_mail_table_name, v.Uuid, v.Category, v.Number, v.sessionId, JSON.encode(v))
        SqliteHelper:Exec(query)
    end
    query = "COMMIT TRANSACTION"
    SqliteHelper:Exec(query)
end

function MailModel:writeBatchFavorite(infos)
    local query = "BEGIN TRANSACTION"
    SqliteHelper:Exec(query)
    for _,v in pairs(infos) do
        local isRead = v.IsRead and 1 or 0
        local isFavorite = v.IsFavorite and 1 or 0
        local isClaimed = v.IsClaimed and 1 or 0
        query = string.format( "INSERT INTO %s VALUES(%d, '%s', %d,'%s', %d, %d, %d, %d, '%s')",
            favorite_mail_table_name, v.Category, v.Subject, v.Number, v.Uuid, 
            isRead, isFavorite, isClaimed, 
            v.RewardExpiredAt, JSON.encode(v))
        SqliteHelper:Exec(query)
    end
    query = "COMMIT TRANSACTION"
    SqliteHelper:Exec(query)
end

--批量取消收藏
function MailModel:updateIsFavoriteDatas(uids, IsFavorite)
    local isFavorite = IsFavorite and 1 or 0
    local _opp = IsFavorite and 0 or 1
    local info = {}
    local type = MAIL_TYPE.Favorite
    local index = 0
    local str = "("
    if IsFavorite then
        --TODO
        --批量添加收藏功能暂无需求
    else
        for _,v in ipairs(uids)do
            self:removeAndChangeFavorite(v, IsFavorite)
            str = str..string.format( "'%s'",v)..","
        end
    end
    str = string.sub(str, 1, string.len(str)-1)
    str = str..")"
    local query = string.format( "UPDATE %s SET isFavorite=%d WHERE uid IN %s AND isFavorite=%d",
                    mail_table_name, isFavorite, str, _opp)
    SqliteHelper:AddExecutQuery(query)
    self.mailInfo[type].notReadAmount = self:GetNotReadAmountByType(type)
end

--刷新邮件是否收藏
function MailModel:updateIsFavoriteData(type, gid, IsFavorite)
    local isFavorite = IsFavorite and 1 or 0
    local _opp = IsFavorite and 0 or 1
    local info = {}
    local type = math.floor(type)
    local index = 0
    for i,v in ipairs(self.mailInfo[type].info)do
        if v.Number == gid  then
            v.IsFavorite = IsFavorite
            info = v
            index = i
            break
        end
    end
    if info.IsFavorite then
        local data = self.mailInfo[type].info[index]
        table.insert(self.mailInfo[MAIL_TYPE.Favorite].info, 1, data)
    else
        for i,v in ipairs(self.mailInfo[MAIL_TYPE.Favorite].info)do
            if v.Number == gid  then
                index = i
                break
            end
        end
        table.remove(self.mailInfo[MAIL_TYPE.Favorite].info, index)
    end
    local query = string.format( "UPDATE %s SET isFavorite=%d WHERE gid=%d AND isFavorite=%d",
                        mail_table_name, isFavorite, gid, _opp)
    SqliteHelper:AddExecutQuery(query)
    self.mailInfo[type].notReadAmount = self:GetNotReadAmountByType(type)
    return info
end

--根据邮件type批量标记已读 和 标记领取
function MailModel:updateIsReadDatas(type, isRead)
    self.mailInfo[type].notReadAmount = 0
    self.mailInfo[type].notReceiveAmount = 0
    for _,v in ipairs(self.mailInfo[type].info)do
        v.IsRead = true
        if v.RewardExpiredAt <= 0 then
            v.IsClaimed = true
        end
    end
    local query1 = string.format( "UPDATE %s SET isRead=1 WHERE type=%d AND isRead=0", mail_table_name, type)
    local query2 = string.format( "UPDATE %s SET isClaimed=1 WHERE type=%d AND isClaimed=0 AND expiredAt == 0", mail_table_name, type)

    if SqliteHelper:IsDbExist(self.mail_db_name) then
        SqliteHelper:AddExecutQuery(query1)
        SqliteHelper:AddExecutQuery(query2)
    else
        SqliteHelper:Open(self.mail_db_name)
        SqliteHelper:AddExecutQuery(query1)
        SqliteHelper:AddExecutQuery(query2)
        SqliteHelper:Close(self.mail_db_name)
    end
    self.mailInfo[type].notReadAmount = self:GetNotReadAmountByType(type)
end

--标记邮件已读
function MailModel:updateIsReadData(type, gid, isRead)
    local notRead = false
    for _,v in ipairs(self.mailInfo[type].info)do
        if v.Number == gid  then
            v.IsRead = true
            notRead = true
            break
        end
    end
    local query = string.format( "UPDATE %s SET isRead=%d WHERE gid=%d AND isRead=0",mail_table_name, isRead, gid)
    SqliteHelper:AddExecutQuery(query)
    if notRead then
        self.mailInfo[type].notReadAmount = self.mailInfo[type].notReadAmount - 1
    end
end

function MailModel:GetMsgGroupIsRead(sessionId)
    local _msgsInfos = self.mailInfo[MAIL_TYPE.Msg].MsgsInfos
    if  _msgsInfos[sessionId] then
        return true
    end
    return false
end

--标记个人邮件已读
function MailModel:updateMsgIsReadDatas(sessionId, number)
    local msgInfo = self.mailInfo[MAIL_TYPE.Msg].info[sessionId]
    local _msgsInfos = self.mailInfo[MAIL_TYPE.Msg].MsgsInfos
    if msgInfo and msgInfo.MsgNumber ~= number then
        msgInfo.MsgNumber = number
    end
    if _msgsInfos[sessionId] then
        _msgsInfos[sessionId] = nil
        self.mailInfo[MAIL_TYPE.Msg].notReadAmount =  self.mailInfo[MAIL_TYPE.Msg].notReadAmount - 1
    end
end

--标记所有邮件已读
function MailModel:updateAllMsgIsRead()
    self.mailInfo[MAIL_TYPE.Msg].notReadAmount = 0
    self.mailInfo[MAIL_TYPE.Msg].MsgsInfos = {}
end

--根据uid 批量删除邮件(已领取  和 过期邮件)
function MailModel:deleteData(type, uids)
    local str = "("
    for _,v in ipairs(uids)do
        self:removeData(type, v)
        str = str..string.format( "'%s'",v)..","
    end
    str = string.sub(str, 1, string.len(str)-1)
    str = str..")"
    local query = string.format("DELETE FROM %s WHERE uid IN %s AND isFavorite=0 AND isClaimed=1 OR (expiredAt != 0 AND expiredAt < %d)",
                    mail_table_name, str, Tool.Time())
    SqliteHelper:AddExecutQuery(query)
    self.mailInfo[type].notReadAmount = self:GetNotReadAmountByType(type)
end

function MailModel:deleteAllNotReceive(type, Unread)
    self.mailInfo[type].notReadAmount = Unread
    local info = self.mailInfo[type].info
    for i = #info, 1, -1 do
        if (info[i].IsClaimed or (info[i].RewardExpiredAt ~= 0 and info[i].RewardExpiredAt < Tool.Time()))
                    and not info[i].IsFavorite then
            table.remove(info, i)
        end
    end
    local query = string.format("DELETE FROM %s WHERE type = %d AND isFavorite=0 AND isClaimed=1 OR (expiredAt != 0 AND expiredAt < %d)",
            mail_table_name, type, Tool.Time())
    SqliteHelper:AddExecutQuery(query)
end

function MailModel:deleteAll(type)
    local a = self.mailInfo[type].info
    self.mailInfo[type].info = {}
    local query = string.format( "DELETE FROM %s WHERE type=%d",
        mail_table_name, type)
    SqliteHelper:AddExecutQuery(query)
    self.mailInfo[type].notReadAmount = self:GetNotReadAmountByType(type)
end

function MailModel:deleteMsgGroup(sessionIds)
    local str = "("
    for _,v in ipairs(sessionIds)do
        self:removeMsgGroup(v)
        str = str..string.format( "'%s'",v)..","
    end
    str = string.sub(str, 1, string.len(str)-1)
    str = str..")"
    local query = string.format( "DELETE FROM %s WHERE sessionId IN %s",
        msg_mail_table_name, str)
    SqliteHelper:AddExecutQuery(query)
    self.mailInfo[MAIL_TYPE.Msg].notReadAmount = self:GetNotReadAmountByType(MAIL_TYPE.Msg)
end

--批量更新邮件
function MailModel:receiveMails(type, uids)
    local str = "("
    for _,uid in ipairs(uids)do
        for i,v in ipairs(self.mailInfo[type].info)do
            if v.Uuid == uid  then
                v.IsClaimed = true
                break
            end
        end
        str = str..string.format( "'%s'",uid)..","
    end
    str = string.sub(str, 1, string.len(str)-1)
    str = str..")"
    local query = string.format( "UPDATE %s SET isClaimed=1 WHERE uid IN %s",
                mail_table_name, str)
    SqliteHelper:AddExecutQuery(query)
    self.mailInfo[type].notReadAmount = self:GetNotReadAmountByType(type)
end

--插入单个数据
function MailModel:writeData(info)
    local isRead = info.IsRead and 1 or 0
    local isFavorite = info.IsFavorite and 1 or 0
    local isClaimed = info.IsClaimed and 1 or 0
    local query = string.format( "INSERT INTO %s VALUES(%d, '%s', %d, '%s', %d, %d, %d, %d, '%s')",
                                mail_table_name,info.Category, info.Subject, info.Number, info.Uuid, 
                                isRead, isFavorite, isClaimed, 
                                v.RewardExpiredAt, JSON.encode(info))
    SqliteHelper:AddExecutQuery(query)
end

--替换数据
function MailModel:replaceData(type, id, isRead, isFavorite, data)
    local query = string.format( "REPLACE INTO %s VALUES(%d,%d,'%s')",
                            mail_table_name, type, id, isRead, isFavorite, JSON.encode(data))
    SqliteHelper:AddExecutQuery(query)
end

--刷新数据
function MailModel:UpdateDataByGid(id, data)
    local query = string.format("UPDATE %s SET data='%s' WHERE gid=%d",
                    mail_table_name, data, id)
    SqliteHelper:AddExecutQuery(query)
end

function MailModel:UpdateStatus(type, gid, status)
    for i,v in ipairs(self.mailInfo[type].info)do
        if v.Number == gid  then
            v.Status = status
            break
        end
    end
end

--获得最大gid
function MailModel:getMaxGid()
    local query = string.format( "SELECT MAX(%s)FROM %s", "gid", mail_table_name)
    local info = SqliteHelper:Query(query)
    for _,v in pairs(info[1]) do
        return v
    end
    return 0
end

--获得最大gid
function MailModel:getMaxGidByType(type)
    local maxNumber = 0
    local info = {}
    local query = string.format( "SELECT MAX(gid)FROM %s WHERE type=%d", mail_table_name, type)
    if SqliteHelper:IsDbExist(self.mail_db_name) then
        info = SqliteHelper:Query(query)
    else
        SqliteHelper:Open(self.mail_db_name)
        info = SqliteHelper:Query(query)
        SqliteHelper:Close(self.mail_db_name)
    end
    for _,v in pairs(info[1]) do
        maxNumber = v
    end
    return maxNumber
end

function MailModel:getMsgMaxNumber(sessionId)
    local maxNumber = 0
    local info = {}
    local query = string.format( "SELECT MAX(number)FROM %s WHERE sessionId='%s'", msg_mail_table_name, sessionId)
    if SqliteHelper:IsDbExist(self.mail_db_name) then
        info = SqliteHelper:Query(query)
    else
        SqliteHelper:Open(self.mail_db_name)
        info = SqliteHelper:Query(query)
        SqliteHelper:Close(self.mail_db_name)
    end
    for _,v in pairs(info[1]) do
        maxNumber = v
    end
    return maxNumber
end

--获得type最大邮件数量
function MailModel:GetAmountByType(type)
    local query = string.format( "SELECT COUNT(*)FROM %s WHERE type=%d", mail_table_name, type)
    local info = SqliteHelper:Query(query)
    for _,v in pairs(info[1]) do
        return v
    end
    return 0
end

--获得未读数量
function MailModel:GetNotReadAmountByType(type)
    return self.mailInfo[type].notReadAmount
end

--根据subject获得个人邮件数量
function MailModel:GetNotReadMsgAmountBySubject(type, subject)
    local query = string.format( "SELECT COUNT(*)FROM %s WHERE type=%d AND subject='%s' AND isRead=%d", 
                mail_table_name, type, subject, 0)
    local infos = SqliteHelper:Query(query)
    for _,v in pairs(infos[1]) do
        return v
    end
    return 0
end

--获得所有邮件未读数量
function MailModel:GetNotReadAmount()
    local notReadAmount = 0
    for _,v in pairs(MAIL_TYPE) do
        notReadAmount = notReadAmount + self.mailInfo[v].notReadAmount
    end
    return notReadAmount
end

--获得未读邮件
function MailModel:GetNotReadByType(type)
    local query = string.format( "SELECT * FROM %s WHERE type=%d AND isRead=%d", mail_table_name, type, 0)
    local infos = SqliteHelper:Query(query)
    return infos
end

function MailModel:GetNewMsgByType(type, subject)
    local query = string.format( "SELECT MAX(gid) FROM %s WHERE type=%d AND subject='%s'", mail_table_name, type, subject)
    local query = string.format( "SELECT * FROM %s WHERE gid IN (SELECT MAX(gid) FROM %s WHERE type=%d AND subject='%s')", 
    mail_table_name, mail_table_name, type, subject)
    local infos = SqliteHelper:Query(query)
    return infos
end

function MailModel:GetNumByType(type)
    if self.mailInfo[type] then
        return self.mailInfo[type]._maxNum
    end
    return 0
end

--获得未读邮件uid 数组
function MailModel:GetNotReadIdAndInfosByType(type)
    local infos = self:GetNotReadByType(type)
    local ids = {}
    for i,v in pairs(infos) do
        table.insert(ids, infos[i].Uuid)
    end
    return ids
end

--获得所有收藏邮件uid数组
function MailModel:GetAllFavoriteUIds()
    local list = {}
    for _,v in ipairs(self.mailInfo[MAIL_TYPE.Favorite].info) do
        table.insert(list, v.Uuid)
    end
    return list
end

--根据type获得uid数组
function MailModel:GetUIdsByType(type)
    local list = {}
    for _,v in pairs(self.mailInfo[type].info) do
        table.insert(list, v.Uuid)
    end
    return list
end

--根据邮件type获得内存数据
function MailModel:GetInfoByType(type)
    return self.mailInfo[type]
end

--根据邮件type和index获得邮件内存数据，或者加载数据
function MailModel:GetInfoByTypeOrRaise(type, index)
    local list = self.mailInfo[type].info
    if not index or index >=#list then
        if type == MAIL_TYPE.Msg then
            self:ReadTenMsgGroup()
        else
            self:ReadTenDataByType(type)
        end
    end
    return self.mailInfo[type]
end

--根据邮件type和index获得个人邮件内存数据，或者加载数据(要保证本地加载了当前sessionId对应数据)
function MailModel:GetMsgInfoByTypeOrRaise(sessionId,index)
    local list = self.mailInfo[MAIL_TYPE.Msg].info[sessionId]
    if not list or not index or index > #list then
        self:ReadTenMsg(sessionId, index)
    end
    return self:GetMsgInfoMsgfByType(sessionId)
end

--获得个人邮件数据
function MailModel:GetMsgInfoByType(sessionId)
    local msgInfo = self.mailInfo[MAIL_TYPE.Msg].info[sessionId]
    if msgInfo then
        return msgInfo
    end
    return {}
end

--获得个人邮件数据
function MailModel:GetMsgInfoMsgfByType(sessionId)
    local msgInfo = self.mailInfo[MAIL_TYPE.Msg].info[sessionId]
    if msgInfo then
        return msgInfo.msgs
    end
    return {}
end

function MailModel:GetMsgMembers(sessionId)
    local msgInfo = self.mailInfo[MAIL_TYPE.Msg].info[sessionId]
    if msgInfo then
        return msgInfo.Members
    end
    return {}
end

function MailModel:GetMsgInfoBySessionId(sessionId)
    local msgInfo = self.mailInfo[MAIL_TYPE.Msg].info[sessionId]
    if msgInfo then
        return msgInfo
    end
    return {}
end

function MailModel:GetMsgBySessionId(sessionId)
    for _,v in ipairs(self.mailInfo[MAIL_TYPE.Msg].info)do
        if v.Uuid == sessionId then
            return v.msgs
        end
    end
    return {}
end

function MailModel:SetMsgGroupTop(sessionId)
    self.mailInfo[MAIL_TYPE.Msg].TopSessionIds[sessionId] = {}
end

function MailModel:RemoveMsgGroupTop(sessionId)
    self.mailInfo[MAIL_TYPE.Msg].TopSessionIds[sessionId] = nil
end

function MailModel:MsgGroupIsTop(sessionId)
    if self.mailInfo[MAIL_TYPE.Msg].TopSessionIds[sessionId] then
        return true
    else
        return false
    end
end

--根据type和index 数据（没有则加载）
function MailModel:getInfoByTypeAndIdex(type, index)
    if index > 0 then
        if index <= #self.mailInfo[type].info then
            return self.mailInfo[type].info[index]
        else
            MailModel:ReadTenDataByType(type)
            if index < #self.mailInfo[type].info then
                return self.mailInfo[type].info[index]
            end
            return nil
        end
    else
        return nil
    end
end

--删除内存数据(未领取不删除)
function MailModel:removeData(type, uid)
    for i,v in ipairs(self.mailInfo[type].info)do
        if v.Uuid == uid and not v.IsFavorite 
                        and(v.IsClaimed 
                        or (v.RewardExpiredAt ~= 0 
                        and v.RewardExpiredAt < Tool.Time() )) then
        -- if v.Uuid == uid and (v.IsClaimed or (v.RewardExpiredAt ~= 0 and v.RewardExpiredAt < Tool.Time())) then
            table.remove(self.mailInfo[type].info, i)
            if not v.IsRead then
                self.mailInfo[type].notReadAmount = self.mailInfo[type].notReadAmount - 1
            end
            return
        end
    end
end

function MailModel:removeMsgGroup(sessionId)
    for i,v in pairs(self.mailInfo[MAIL_TYPE.Msg].info)do
        if v.Uuid == sessionId then
            self.mailInfo[MAIL_TYPE.Msg].info[sessionId] = nil
            break
        end
    end
    if self.mailInfo[MAIL_TYPE.Msg].MsgsInfos[sessionId] ~= nil then
        self.mailInfo[MAIL_TYPE.Msg].MsgsInfos[sessionId] = nil
        self.mailInfo[MAIL_TYPE.Msg].notReadAmount =  self.mailInfo[MAIL_TYPE.Msg].notReadAmount - 1
    end
end

function MailModel:ClearMsgGroup()
    self.mailInfo[MAIL_TYPE.Msg].info = {}
    self.mailInfo[MAIL_TYPE.Msg].isEnd = false
end

--收藏类型删除邮件  和修改邮件是否收藏
function MailModel:removeAndChangeFavorite(uid, IsFavorite)
    local index
    local info
    local infos = self.mailInfo[MAIL_TYPE.Favorite].info
    for i,v in ipairs(infos)do
        if v.Uuid == uid  then
            index = i
            info = v
            break
        end
    end
    table.remove(infos, index)
    for i,v in ipairs(self.mailInfo[info.Category].info)do
        if v.Uuid == uid  then
            v.IsFavorite = IsFavorite
            break
        end
    end
end

function MailModel:SetMailIcon(_icon, _iconBg, id)
    local info = ConfigMgr.GetItem("configMailTypes", id)
    if info then
        local url = info.sub_icon
        local bgUrl = info.bg_icon
        if url then
            _icon.icon = UITool.GetIcon(url)
        else
            _icon.icon = nil
        end
        if bgUrl then
            _iconBg.icon = UITool.GetIcon(bgUrl)
        else
            _iconBg.icon = nil
        end
    else
        _icon.icon = nil
        _iconBg.icon = nil
    end
end

--切换邮件panel(通用)
function MailModel:ChangePanel(panel, info, index)
    if not info.IsRead then
        Net.Mails.MarkRead(info.Category, {info.Uuid},function(msg)
            MailModel:updateIsReadData(info.Category, info.Number, 1)
            Event.Broadcast(MAILEVENTTYPE.MailsReadEvent)
        end)
    end
    local type
    if panel.type == MAIL_TYPE.Favorite then
        type = panel._info.Category
    else
        type = panel.type
    end
    if type == info.Category and info.Category ~= MAIL_TYPE.Alliance 
                and info.Category ~= MAIL_TYPE.PVPReport 
                and info.Category ~= MAIL_TYPE.Activity then
        panel:_refreshData(info, index)
    elseif info.Category == MAIL_TYPE.PVPReport then --pvp邮件
        if panel.subType and panel.subType == info.SubCategory then
            panel:_refreshData(info, index)
        elseif (panel.subType == MAIL_SUBTYPE.subScoutReport or panel.subType == MAIL_SUBTYPE.subBeScoutReport) and 
            (info.SubCategory == MAIL_SUBTYPE.subScoutReport or info.SubCategory == MAIL_SUBTYPE.subBeScoutReport)then
            panel:_refreshData(info, index)
        elseif info.SubCategory == MAIL_SUBTYPE.subScoutFailReport then
            UIMgr:Open("MailUnion", panel.type, index, info, panel._panel)
            panel.Close()
        elseif info.SubCategory == MAIL_SUBTYPE.subexploreReport then
            UIMgr:Open("MailSecretBase", panel.type, index, info, panel._panel)
            panel.Close()
        elseif info.SubCategory == MAIL_SUBTYPE.subScoutReport or info.SubCategory == MAIL_SUBTYPE.subBeScoutReport then
            UIMgr:Open("MailScout", panel.type, index, info, panel._panel)
            panel.Close()
        elseif info.SubCategory == MAIL_SUBTYPE.subTypeAttackFailure then
            UIMgr:Open("MailUnion", panel.type, index, info, panel._panel)
            panel.Close()
        else
            UIMgr:Open("MailWarReport", panel.type, index, info, panel._panel)
            panel.Close()
        end
    elseif type == MAIL_TYPE.Sports then       --竞技场邮件
        if panel.subType and panel.subType == info.SubCategory then
            panel:_refreshData(info, index)
        end
    elseif info.Category == MAIL_TYPE.System or info.Category == MAIL_TYPE.Studio then  --系统和活动邮件
        if type == MAIL_TYPE.System or type == MAIL_TYPE.Activity or type == MAIL_TYPE.Studio then
            panel:_refreshData(info, index)
            return
        end
        UIMgr:Open("MailUnion", panel.type, index, info, panel._panel)
        panel.Close()
    elseif info.Category == MAIL_TYPE.Alliance then  --联盟邮件
        if panel.subType and panel.subType == info.SubCategory then
            panel:_refreshData(info, index)
        elseif info.SubCategory == MAIL_SUBTYPE.subOrderReport       --联盟指令
            or info.SubCategory == MAIL_SUBTYPE.subAllianceBuildRecovery --联盟建筑回收
            or info.SubCategory == MAIL_SUBTYPE.subAllianceBuildPlace then   --联盟建筑放置通知
            UIMgr:Open("MailAllianceSystemInformation", panel.type, index, info, panel._panel)
            panel.Close()
        elseif info.SubCategory == MAIL_SUBTYPE.subAllianceAssistRes then--援助资源
            UIMgr:Open("MailAllianceAssistance", panel.type, index, info, panel._panel)
            panel.Close()
        elseif info.SubCategory == MAIL_SUBTYPE.subAllianceAssistArmies then--援助士兵
            UIMgr:Open("MailAllianceTroopAssistance", panel.type, index, info, panel._panel)
            panel.Close()
        elseif info.SubCategory == MAIL_SUBTYPE.subAllianceInvite then--入盟邀请
            UIMgr:Open("MailAllianceInvitation", panel.type, index, info, panel._panel)
            panel.Close()
        elseif info.SubCategory == MAIL_SUBTYPE.subAlliance              --联盟通知
            or info.SubCategory == MAIL_SUBTYPE.subAllianceBuildcomplete then    --联盟建筑完工
            UIMgr:Open("MailUnion", panel.type, index, info, panel._panel)
            panel.Close()
        end
    elseif info.Category == MAIL_TYPE.Activity then
        if panel.subType and panel.subType == info.SubCategory then
            panel:_refreshData(info, index)
        elseif (panel.subType == 0 and info.SubCategory == MAIL_SUBTYPE.subMailSubTypeNewPlayer) or
                (panel.subType == MAIL_SUBTYPE.subMailSubTypeNewPlayer and info.SubCategory == 0) then    --跳转邮件 也是 MailUnion ui类型
            panel:_refreshData(info, index)
        elseif info.SubCategory == MAIL_SUBTYPE.subTypeActiveCombat then      --活动集结怪邮件
            UIMgr:Open("Mail_FieldEnemyActivityAggregation", panel.type, index, info, panel._panel)
            panel.Close()
        else
            UIMgr:Open("MailUnion", panel.type, index, info, panel._panel)
            panel.Close()
        end
    else
        panel:_refreshData(info, index)
    end
end

function MailModel:DeleteDBTable()
    local isTableExist = SqliteHelper:IsTableExist(mail_table_name)
    if isTableExist then
        local query = string.format( "DROP TABLE %s", mail_table_name)
        SqliteHelper:Exec(query)
    end
    isTableExist = SqliteHelper:IsTableExist(favorite_mail_table_name)
    if isTableExist then
        local query = string.format( "DROP TABLE %s", favorite_mail_table_name)
        SqliteHelper:Exec(query)
    end
    isTableExist = SqliteHelper:IsTableExist(msg_mail_table_name)
    if isTableExist then
        local query = string.format( "DROP TABLE %s", msg_mail_table_name)
        SqliteHelper:Exec(query)
    end
end

return MailModel