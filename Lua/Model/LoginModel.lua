--author: 	Amu
--time:		2019-10-19 15:48:15
import("Model/ABTest")
local MissionEventModel = import("Model/MissionEventModel")
local GlobalVars = GlobalVars
if LoginModel then
    return LoginModel
end
local LoginModel
LOGIN_TYPE = {
    UidLogin = 1,    --第一次登陆
    Success = 2,     --登陆成功
}

LOGIN_EVENT_TYPE = {
    LogInSuccess = "LogInSuccess",
}

LoginModel = {
    isLogin = false,
    clickLogin = false,
    LoginType = LOGIN_TYPE.UidLogin,
}

function LoginModel.InitEvent()
    Event.AddListener(EventDefines.NetOnConnected, LoginModel.OnNetConnected)
    Event.AddListener(EventDefines.NetReConnected, LoginModel.OnNetReConnected)
    Event.AddListener(EventDefines.OpenNetLoading, function()
        UIMgr:Open("NetLoading")
    end)
end

function LoginModel.OnNetConnected()
    Log.Info("LoginModel.OnNetConnected")
    Loading.SetLoadingTip("auth_game")
    if not CommonType.RECONNECT then
        return
    end
    if LoginModel.isLogin then
        return
    end
    local authSuccess = function()
        Network.MarkAuthed()
        UserModel.Login(function()
            if LoginModel.LoginType == LOGIN_TYPE.UidLogin then
                LoginModel.isLogin = true
                LoginModel.LoginGame()
            end
        end)
    end
    local authFailed = function()
        Network.ReloginAlert("ALERT_CONNECT_NET_ERROR")
    end
    local authParams = UserModel.AuthParams()
    local timeOutCb = function()
        LoginModel.AlertRetry(function()
            Network.RawSend(ApiMap.protos.PT_SessionAuthParams, authParams, 
                authSuccess, authFailed, timeOutCb)
        end)
    end
    Network.RawSend(ApiMap.protos.PT_SessionAuthParams, authParams, 
        authSuccess, authFailed, timeOutCb)
end

function LoginModel.OnNetReConnected()
    Log.Info("LoginModel.OnNetReConnected")
    if not CommonType.RECONNECT then
        return
    end
    local failCb = function()
        Network.ReloginAlert("ALERT_CONNECT_NET_ERROR")
    end
    local timeOutCb = function()
        Network.ReloginAlert("ALERT_CONNECT_NET_ERROR")
    end
    local authSuccess = function(msg)
        Network.MarkAuthed()
        local packetId = Network.GetPacketId()
        Net.Logins.Reconnect(packetId, LoginModel.OnReconnectSuccess, failCb, timeOutCb)
    end
    local pt = ApiMap.protos.PT_SessionAuthParams
    local authParams = UserModel.AuthParams()
    Network.RawSend(pt, authParams, authSuccess, failCb, timeOutCb)
end

function LoginModel.LoginGame()
    LoginModel.LoginType = LOGIN_TYPE.Success
    UnionModel:Init()
    MissionEventModel.Init()
    CommonType.LOGIN = true
    Event.Broadcast(EventDefines.LoginSuccess)
    SdkModel.TrackBreakPoint(10073)
    if KSUtil.IsAndroid() then
        local serverId = Auth.WorldData.sceneId
        local reportCode = string.match(serverId, "%d+")
        Sdk.ReportServerCode(reportCode, UserModel.data.accountId, Model.Player.Name)
    end
    Util.GetDeviceAdId()
end

function LoginModel.OnReconnectSuccess(msg)
    if not msg.Success then
        Network.ReloginAlert("ALERT_CONNECT_NET_ERROR")
        return
    end
    Network.MarkLogin()
    Event.Broadcast(EventDefines.ReLoginSuccess)
end

function LoginModel.Login(uid, timeStamp, sign, url, port, serverId)
    local success = function() 
        UIMgr:Open("Loading", LoginModel.StartGame)
        UIMgr:Close("Login")
    end
    local failed = function(errorCode) 
        if errorCode.error_code and errorCode.error_code == "error_account_banned" then
            LoginModel.AleryBan(errorCode)
        else
            LoginModel.AlertRetry(function()
                LoginModel.Login(uid, timeStamp, sign, url, port)
            end, errorCode)
        end
    end
    Auth.LoginWorld(uid, timeStamp, sign, url, port, serverId, success, failed)
end

function LoginModel.StartGame()
    Loading.SetLoadingTip("connect_game")
    import("Requires")
    local NetEvents = import("EventCenter/Registers/NetEvents")
    NetEvents.Regist()
    local server = UserModel.ConnectParams()
    Log.Info("Connectting server: {0}:{1}", server.Host, server.Port)
    Network.Start(server.Host, server.Port)
    --获取商品项信息
    SdkModel.GetSkuDetail()
end

local CitySoldier = import("Model/CityCharacter/CitySoldier")
local CityWorker = import("Model/CityCharacter/CityWorker")
function LoginModel.ExitLogin()
    if CS.KSFramework.Main.NewRestart then
        -- 新版本硬包
        CS.KSFramework.Main.Instance:Restart()
    else
        -- 老版本硬包
        LoginModel.DisposeAll()
        CS.KSFramework.Main.Instance:Restart()
    end
end

function LoginModel.DisposeAll()
    UserModel._init = false
    NotifyModel.ClearNotify()
    GlobalVars.IsRestar = true
    Event.Broadcast(EventDefines.GameReStart)
    CSCoroutine.Clear()
    if GameUpdate and GameUpdate.Inst() then
        GameUpdate.Inst().isOpen = false
    end
    if Network then
        Network.ForceDisconnect()
    end
    DynamicRes.StopSync()

    --遮罩
    if MaskModel then
        MaskModel.Clear()
    end

    --大兵
    CitySoldier.Clear()
    CityWorker.Clear()

    --天气特效
    if WeatherModel then
        WeatherModel.Clear()
    end

    --世界地图
    if WorldMap then
        WorldMap.Dispose()
    end

    UIMgr:DisposeAll()
    UIMgr:DisposeObject()

    --对象池
    if NodePool then
        NodePool.Clear()
    end

    GlobalVars.IsRestar = false
end

function LoginModel.AleryBan(errorCode)
    local tip
    local leftBtnTxt = StringUtil.GetI18n("configI18nCommons", "BUTTON_CONTACT_US")
    local cb = function()
        GmModel.InitGmByDevice("BanPlayer")
        Sdk.AiHelpShowConversation(Util.GetDeviceId(), "BanPlayer")
    end
    if errorCode.error_value and errorCode.error_value > 0 then
        tip = StringUtil.GetI18n("configI18nCommons", "Ui_Ban_Time_limit", {time = TimeUtil:StampTimeToYMDHMS(errorCode.error_value)})
    else
        tip = StringUtil.GetI18n("configI18nCommons", "Ui_Ban_Permanent")
    end
    LoginModel.Error(tip, cb, leftBtnTxt, 1)
end

function LoginModel.AlertRetry(cb, errorCode)
    local tip = StringUtil.GetI18n("configI18nCommons", "TIPS_UNCONNECT_SERVER")
    -- if errorCode ~= nil and errorCode ~= "" then
    --     tip = tip .."["..errorCode.."]"
    -- end
    local leftBtnTxt = StringUtil.GetI18n("configI18nCommons", "BUTTON_RETRY")
    LoginModel.Error(tip, cb, leftBtnTxt, 1)
end

function LoginModel.AlertRelogin(cb, errorCode, contactUs)
    local tip = StringUtil.GetI18n("configI18nCommons", "ALERT_CONNECT_NET_ERROR")
    -- if errorCode ~= nil and errorCode ~= "" then
    --     tip = tip .."["..errorCode.."]"
    -- end
    local leftBtnTxt = StringUtil.GetI18n("configI18nCommons", "BUTTON_RELOGIN")
    if contactUs then
        LoginModel.Error(tip, cb, leftBtnTxt, 0)
    else
        LoginModel.Error(tip, cb, leftBtnTxt, 1)
    end
end

--[[
    ALERT_LOGIN_NET_ERROR	当前网络不稳定，请检查网络或点击重新登录
    ALERT_LOGIN_OTHER_ERROR	当前登录出现异常，请尝试重新登录或联系我们
    ALERT_CONNECT_NET_ERROR	当前网络连接异常，请尝试重新登录
    TIPS_UNCONNECT_SERVER	无法连接到服务器，请稍后再试
]]
function LoginModel.Error(error, cb, leftBtnTxt, index)
    if leftBtnTxt == "" then
        leftBtnTxt = StringUtil.GetI18n("configI18nCommons", "BUTTON_RELOGIN")
    end
    local rightBtnTxt = StringUtil.GetI18n("configI18nCommons", "BUTTON_CONTACT_US")
    local data = {
        content = error,
        leftBtn = leftBtnTxt,
        rightBtn = rightBtnTxt,
        leftEvent = cb,
        rightEvent = function()
            -- 屏蔽权限提示
            -- if not Sdk.CanAccessGM() then
            --     local data = {
            --         content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Gm_Upload_Permission"),
            --         buttonType= "double",
            --         sureCallback = function()
            --             Sdk.RequestGM()
            --         end
            --     }
            --     UIMgr:Open("ConfirmPopupText", data)
            -- else
            local serverId = ""
            local accountId = "" 
            if Auth and Auth.WorldData then
                serverId = Auth.WorldData.sceneId
                accountId = string.gsub(Auth.WorldData.accountId, "#", "-")
            end
            Sdk.AiHelpShowConversation(accountId, serverId)
            SdkModel.GmNotRead = 0
            Event.Broadcast(GM_MSG_EVENT.MsgIsRead, SdkModel.GmNotRead)
            -- end
        end,
        closeEvent = function()
            LoginModel.clickLogin = false
        end
    }
    index = index and index or 0
    UIMgr:Open("ConfirmDoublePopup", index, data)
    local panel = UIMgr:GetUI("ConfirmDoublePopup")
    if panel then
        panel.Controller.contentPane.sortingOrder = 10
    end
end

_G.LoginModel = LoginModel
return LoginModel
