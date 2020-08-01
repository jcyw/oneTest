if Network then
    return NetworkG
end

local NetStatus = {
    WaitingConfirm = -1, -- 弹窗确认
    Disconnected = 0, -- 进行连接
    Connecting = 1, -- 等待连接，超时重连
    Connected = 2, -- 等待验证
    Authed = 3, -- 验证完成
    Login = 4 -- 登录完成
}

local NetTimeouts = {
    [NetStatus.Disconnected] = 2,
    [NetStatus.Connecting] = 8,
    [NetStatus.Connected] = 8,
    [NetStatus.Authed] = 8
}

local __netStatus = NetStatus.Disconnected
local __netStatusChangeAt = 0
local requestTimeout = 8 -- 请求超时（秒）
local requestShowLoading = 1 -- Loading显示延迟（秒）
local heartbeatTime = 20 -- 心跳间隔（秒）
local showReconnectTipDelay = 3 -- 重连超过多久才显示：重连成功提示（秒）

local connetTimes = 1 --手动重连限制
local autoReConnectTime = 0 --自动重连计数
local reConnectTime = 0 --手动重连次数
local reconnectAt = 0 -- 重连开始时间
local maxRequestQueueLen = 5 -- 请求队列最大长度

local pb = require("pb")

local Network = {}

local requestCallbacks = {}
local __lastPacketId = 0 -- 服务器消息序号
local __requestId = 0 -- 客户端消息序号
local __packetLostTime = 0 -- 累计丢包次数

-- 5秒内连续重连2次直接提示重新登录
local __reconnectRecs = {}
local __fastReconnectLimit = 3
local __fastReconnectDuration = 5

local function HeartbeatFunc()
    if __netStatus == NetStatus.Login then
        local params = {
            Alive = true
        }
        Network.DirectSend(ApiMap.protos.PT_HeartbeatParams, params)
    end
end

local isLoading = false
function Network.ShowLoading()
    if isLoading or __netStatus == NetStatus.WaitingConfirm then
        return
    end
    isLoading = true
    Event.Broadcast(EventDefines.OpenNetLoading)
    -- 超时后关闭Loading
    -- Scheduler.ScheduleOnce(Network.HideLoading, 3)
end

function Network.HideLoading()
    if not isLoading then
        return
    end
    isLoading = false
    -- Scheduler.UnSchedule(Network.HideLoading)
    Event.Broadcast(EventDefines.CloseNetLoading)
end

function Network.IsConnect()
    if __netStatus == NetStatus.WaitingConfirm then
        return true
    end
    return isLoading
end

function Network.Start(host, port)
    Log.Info("Network.Start!!")
    -- 加载协议
    local bytes = ResMgr.GetLuaFile("gen/net/protocol.pb")
    pb.load(bytes)
    -- 连接服务器
    Scheduler.Schedule(Network.netcheck, 1, true, 1)
    Network.ChangeStatus(NetStatus.Connecting)
    NetworkManager.Instance:ConnectServer(host, port)
    -- 从后台切入前台
    Event.AddListener(
        EventDefines.GameOnFocus,
        function()
            -- 未联网时
            if not Network.HaveNetwork() then
                Network.ManualReconnect()
                return
            end
            -- 延迟检测
            Scheduler.ScheduleOnceFast(function()
                reconnectAt = Network.Now()
                -- 连接断开时，直接尝试连接
                if __netStatus == NetStatus.Disconnected then
                    Network.Reconnect("EnterForeground")
                    return
                end
                -- 连接关闭时
                if not NetworkManager.Instance:IsConnected() then
                    Network.Reconnect("EnterForeground")
                    return
                end
                if __netStatus == NetStatus.Login then
                    Network.AliveCheck("EnterForeground")
                end
            end, 0.3)
        end
    )
end

function Network.AliveCheck(reason)
    local params = {
        Alive = true
    }
    local timeoutcheck = 1
    Network.RawSend(
        ApiMap.protos.PT_HeartbeatParams,
        params,
        nil,
        nil,
        function()
            if __netStatus == NetStatus.Login then
                Network.Reconnect("EnterForeground")
            end
        end,
        timeoutcheck
    )
end

--当连接建立时--
function Network:OnConnect()
    if __netStatus == NetStatus.WaitingConfirm then
        Log.Info("return from OnConnect")
        return
    end

    Network.ChangeStatus(NetStatus.Connected)
    Log.Info("Game Server connected!!")

    --  SQLiteHelper
    --  打开数据库
    SqliteHelper:Open(MailModel.mail_db_name)

    if LoginModel.LoginType == LOGIN_TYPE.UidLogin then
        Event.Broadcast(EventDefines.NetOnConnected)
    else
        table.insert(__reconnectRecs, os.time())
        Event.Broadcast(EventDefines.NetReConnected)
    end
end

--连接中断，或者被踢掉--
function Network:OnDisconnect()
    Log.Info("OnDisconnect")
    if __netStatus < NetStatus.Connected then
        Log.Info("OnDisconnect skip __netStatus: {0}", __netStatus)
        return
    end
    Event.Broadcast(EventDefines.NetOnDisconnected)
    __netStatus = NetStatus.Disconnected
    Network.Reconnect("OnDisconnect")
    SqliteHelper:Close(MailModel.mail_db_name)
end

--[[
消息流程：
    Auth -> AuthRsp
    Login -> LoginRsp | Reconnect -> ReconnectRsp
]]
--Socket消息--
function Network:OnSocket(packetId, msgName, reqId, data)
    local response = pb.decode(msgName, data)
    -- 同步消息时
    if __netStatus == NetStatus.Authed then
        if packetId ~= __lastPacketId + 1 and packetId ~= __lastPacketId then
            Log.Info("Relogin from sync 1 packetId: {0}, __lastPacketId: {1}", packetId, __lastPacketId)
            Network.ReloginAlert()
            return
        end
    end
    -- 正常游戏中
    if __netStatus == NetStatus.Login then
        if packetId ~= __lastPacketId + 1 and packetId ~= __lastPacketId then
            Log.Info("Relogin from sync 2 packetId: {0}, __lastPacketId: {1}", packetId, __lastPacketId)
            __packetLostTime = __packetLostTime + 1
            if __packetLostTime > 1 then
                Network.ReloginAlert()
            else
                Network.Reconnect("packet_lost")
            end
            return
        end
    end
    -- 更新协议号
    if __netStatus >= NetStatus.Authed then
        __lastPacketId = packetId
        Network.HideLoading()
    end
    -- 消息处理
    Network.handleResponse(msgName, reqId, response)
end

local isForceDisconnect = false
function Network.ForceDisconnect()
    isForceDisconnect = true
    Network.ChangeStatus(NetStatus.WaitingConfirm)
    Network.Close()
    Network.HideLoading()
end

function Network.Stop()
    Network.ChangeStatus(NetStatus.Disconnected)
    Network.Close()
    Network.HideLoading()
end

--卸载网络监听--
function Network.Unload()
end

function Network.MarkAuthed()
    Network.ChangeStatus(NetStatus.Authed)
    Network.ScheduleHeartbeat()
end

function Network.MarkLogin()
    reConnectTime = 0
    autoReConnectTime = 0
    Network.ChangeStatus(NetStatus.Login)
    Network.FlushRequestQueue()
    if LoginModel.LoginType ~= LOGIN_TYPE.UidLogin then
        Event.Broadcast(EventDefines.NetLoginFromReconnect)
    end
end

function Network.Request(msgName, msg, cb, failCb, timeOutCb)
    if __netStatus >= NetStatus.Authed then
        Network.RawSend(msgName, msg, cb, failCb, timeOutCb)
    end
end

function Network.RequestDynamic(msgName, fields, ...)
    local msg = {}
    local args = {...}
    local cb
    local failCb
    local timeOutCb
    for i = 1, #args do
        if type(args[i]) ~= "function" then
            msg[fields[i]] = args[i]
        elseif type(args[i]) == "function" then
            if not cb then
                cb = args[i]
            elseif not failCb then
                failCb = args[i]
            elseif not timeOutCb then
                timeOutCb = args[i]
            end
        end
    end
    Network.Request(msgName, msg, cb, failCb, timeOutCb)
end

function Network.RawSend(msgName, msg, cb, failCb, timeOutCb, timeout)
    __requestId = __requestId + 1
    if PlayerDataModel.GetLocalData("LOG_SERVER") == "true" then
        Log.Info("RawSend: {0}, msgName: {1}, msg: {2}", __requestId, msgName, table.inspect(msg))
    end
    local buffer = pb.encode(msgName, msg)
    local request = {
        requestId = __requestId,
        msgName = msgName,
        cb = cb,
        failCb = failCb,
        timeOutCb = timeOutCb,
        buffer = buffer,
        sentAt = Network.Now()
    }
    if timeout then
        request.timeout = timeout
    else
        request.timeout = requestTimeout
    end
    if cb or failCb or timeOutCb then
        request.haveCallback = true
    end
    requestCallbacks[request.requestId] = request
    if __netStatus >= NetStatus.Connected then
        NetworkManager.Instance:SendMessage(buffer, msgName, request.requestId)
    end
end

function Network.DirectSend(msgName, msg)
    __requestId = __requestId + 1
    local buffer = pb.encode(msgName, msg)
    NetworkManager.Instance:SendMessage(buffer, msgName, __requestId)
end

function Network.ScheduleHeartbeat()
    Scheduler.UnSchedule(HeartbeatFunc)
    Scheduler.Schedule(HeartbeatFunc, heartbeatTime)
end

function Network.Reconnect(reason)
    Log.Info("Reconnect: {0}", reason)
    if Network.IsShowReconnectPopup() then
        return
    end
    Network.ShowLoading()
    Network.ChangeStatus(NetStatus.Connecting)
    Network.doReconnect()
end

function Network.IsSkipReconnect(reason, isForce)
    Log.Info("Reconnect: {0}", reason)
    local delay = Network.Now() - __netStatusChangeAt
    if not isForce and not Network.IsReconnectTimeout() then
        Log.Info("Skip Reconnect reason: {0} delay: {1} currentNetStatus: {2}", reason, delay, __netStatus)
        return true
    end
    Log.Info("Execute Reconnect: {0}", reason)
    return false
end

function Network.IsShowReconnectPopup()
    -- 未联网时
    if not Network.HaveNetwork() then
        Network.ManualReconnect()
        return
    end
    if #__reconnectRecs >= __fastReconnectLimit then
        if os.time() - __reconnectRecs[#__reconnectRecs - 1] <= __fastReconnectDuration then
            __reconnectRecs = {}
            Log.Info("Relogin from fastReconnectLimit")
            Network.ReloginAlert()
        end
    end
    if isForceDisconnect or autoReConnectTime > 2 then
        if reConnectTime < connetTimes then
            Network.ManualReconnect()
        else
            Log.Info("Relogin from autoReConnectTime exceed")
            Network.ReloginAlert()
        end
        return true
    end
    return false
end

function Network.ManualReconnect()
    if __netStatus == NetStatus.WaitingConfirm then
        return
    end
    Network.ForceDisconnect()
    LoginModel.AlertRetry(
        function()
            isForceDisconnect = false
            reConnectTime = reConnectTime + 1
            Network.ShowLoading()
            Network.ChangeStatus(NetStatus.Connecting)
            NetworkManager.Instance:ReConnect()
        end
    )
end

function Network.doReconnect()
    Log.Info("doReconnect")
    autoReConnectTime = autoReConnectTime + 1
    NetworkManager.Instance:ReConnect()
end

function Network.FlushRequestQueue()
    local requests = {}
    for _, req in pairs(requestCallbacks) do
        table.insert(requests, req)
    end
    table.sort(
        requests,
        function(a, b)
            return a.requestId < b.requestId
        end
    )
    for _, req in ipairs(requests) do
        if req.msgName ~= ApiMap.protos.PT_ReconnectParams and req.msgName ~= ApiMap.protos.PT_HeartbeatParams then
            req.sentAt = Network.Now()
            NetworkManager.Instance:SendMessage(req.buffer, req.msgName, req.requestId)
        else
            requestCallbacks[req.requestId] = nil
        end
    end
end

--关闭tcp连接
function Network.Close()
    NetworkManager.Instance:Close()
end

function Network.ResetPacketId()
    __lastPacketId = 0
end

function Network.GetPacketId()
    return __lastPacketId
end

function Network.ChangeStatus(status)
    Log.Info("__netStatus: {0} status: {1}", __netStatus, status)
    __netStatus = status
    __netStatusChangeAt = Network.Now()
end

function Network.netcheck()
    if Network.IsReconnectTimeout() then
        Network.Reconnect("connect_timeout")
        return
    end
    Network.CheckRequestTimeout()
end

function Network.IsReconnectTimeout()
    if __netStatus == NetStatus.Disconnected or __netStatus == NetStatus.Connecting or __netStatus == NetStatus.Connected or __netStatus == NetStatus.Authed then
        -- 重连超时
        local timeout = NetTimeouts[__netStatus]
        local now = Network.Now()
        if now - __netStatusChangeAt >= timeout then
            return true
        end
    end
    return false
end

local isTimeout = false
function Network.CheckRequestTimeout()
    if __netStatus == NetStatus.Login then
        -- 请求超时检测
        local timeout = false
        local showLoading = false
        local now = Network.Now()
        for _, request in pairs(requestCallbacks) do
            if request.msgName ~= ApiMap.protos.PT_ReconnectParams and request.haveCallback then
                if now - request.sentAt > request.timeout then
                    if request.timeOutCb then
                        request.timeOutCb()
                    elseif request.failCb then
                        request.failCb("timeout")
                    end
                    Log.Info("request_timeout: {0}", request.msgName)
                    if request.msgName ~= ApiMap.protos.PT_HeartbeatParams then
                        timeout = true
                    end
                end
                if now - request.sentAt > requestShowLoading then
                    showLoading = true
                end
            end
        end
        if timeout then
            if #requestCallbacks > maxRequestQueueLen then
                Network.Relogin()
            else
                Network.ManualReconnect()
            end
        elseif showLoading then
            Network.ShowLoading()
        end
    end
end

function Network.handleResponse(msgName, reqId, response)
    local request = requestCallbacks[reqId]
    requestCallbacks[reqId] = nil
    --if PlayerDataModel.GetLocalData("LOG_SERVER") == "true" then
    --    Log.Info("Response: msgName: {0} response: {1}", msgName, table.inspect(response))
    --end
    if (response.Fail) then
        if response.Fail == "error_monster_not_searched" then
        --搜索野怪失败
        Event.Broadcast(EventDefines.DelayMask,false)
        end
        if response.Fail == "error_alliance_cannot_free_join" then
            --加入联盟失败不显示
        else
            local tip = ConfigMgr.GetI18n("configErrorCodes", response.Fail)
            TipUtil.TipById(99999, {error_code = tip})
        end
        if request and request.failCb then
            request.failCb(response.Fail)
        end
    elseif request and request.cb then
        request.cb(response)
    elseif reqId == 0 then
        if not CommonType.LOGIN then
            return
        end
        if not Event.Broadcast(msgName, response) then
            Log.Debug("Unhandle msg: " .. msgName)
        end
    else
        Log.Debug("Unhandle msg: " .. msgName)
    end
end

function Network.Now()
    return Time.fixedTime
end

function Network.ReloginAlert(errorCode, contactUs)
    if __netStatus == NetStatus.WaitingConfirm then
        return
    end
    Network.ForceDisconnect()
    LoginModel.AlertRelogin(Network.Relogin, errorCode, contactUs)
end

function Network.Relogin()
    if HotUpdate.IsDev then
        LoginModel.ExitLogin()
    else
        SdkModel.ReLogin(CS.KSFramework.SdkModel.LoginInfo)
    end
end

function Network.HaveNetwork()
    return NetworkManager.HaveNetwork()
end

_G.Network = Network
return Network
