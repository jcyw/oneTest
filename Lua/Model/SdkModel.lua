--author: 	Amu
--time:		2019-10-17 19:20:57

SDK_BIND_TYPE = {}
SDK_BIND_TYPE.FACEBOOK_TYPE = "FACEBOOK"
SDK_BIND_TYPE.GOOGLE_TYPE = "GOOGLE"
SDK_BIND_TYPE.TWITTER_TYPE = "TWITTER"

SDK_BIND_EVNET = {}
SDK_BIND_EVNET.BindEvnet = "SDK_BIND_EVNETBindEvnet"

SDK_BIND_POS = {}
SDK_BIND_POS.ALL = 1-- FACEBOOK  GOOGLE
SDK_BIND_POS.IOS = 2-- gamecenter
SDK_BIND_POS.RU  = 3-- 俄    VK
SDK_BIND_POS.JP  = 4-- 日本  TWITTER

PurchaseType = {}
PurchaseType.ITEM_TYPE_APP = 1  -- 应用内购买
PurchaseType.ITEM_TYPE_SUBS = 2 --订阅类购买

if SdkModel then
    return SdkModel
end

--  登录成功返回的json   字段
local SDK_LOGIN_INFO_TYPE = {
    MSG = "msg",
    USERTYPE = "userType" ,
    USERID = "userId" ,
    SIGN = "sign" ,
    SID = "SID" ,
    TIMESTAMP = "timeStamp" ,
    GAMECODE = "gameCode" ,
    CHANNELID = "channelId" ,
    PRODUCTID = "productId" ,
    PACKAGENAME = "packageName" ,
    GID = "gid" ,
    PID = "pid" ,
    PTCODE = "ptCode" ,
    DEV = "device" ,
    IS_GP_BIND = "is_gp_bind" ,
    IS_FB_BIND = "is_fb_bind" ,
    IS_TW_BIND = "is_tw_bind" ,
    IS_LINE_BIND = "is_line_bind" ,
    IS_NAVER_BIND = "is_naver_bind" ,
    GP_NAME = "gp_name" ,
    FB_NAME = "fb_name" ,
    TW_NAME = "tw_name" ,
    LINE_NAME = "naver_name" ,
    NAVER_NAME = "naver_name" ,
    IS_LOGOUT = "isLogout" ,
    FB_FRIENDS_INFO = "friendsInfo" ,
    FB_ID = "fbid" ,
    FB_TOKEN = "accessToken" ,
    FB_PICTURE = "picture" ,
    FB_FRIENDSID = "friendsId" ,
    POSTID = "postId" ,
}

local CoinType = {
    CNY = "¥",
    USD = "$",
    TWD = "NT$",
    EUR = "€",
    GBP = "£",
    HKD = "HK$",
    MOP = "MOP$",
    JPY = "￥",
    RUB = "руб",
    PHP = "₱",
    VND = "₫",
    THB = "฿",
    MYR = "RM",
    KRW = "₩",
    BRL = "R$",
    INR = "₹",
    IDR = "Rp",
}

SdkModel = {}

local sdk_loginInfo = {}
local _bindList = {}
local _loginList = {}

local server = nil
local serverId = nil
local input_name = ""
SdkModel.getSkuDetailState = false

function SdkModel.Init()
    XLuaEvent.AddEvent("Login", SdkModel.Login)
    XLuaEvent.AddEvent("ReLogin", SdkModel.ReLogin)
    XLuaEvent.AddEvent("Exit", SdkModel.Exit)
    XLuaEvent.AddEvent("GoogleRcharge", SdkModel.GoogleRcharge)
    XLuaEvent.AddEvent("SkuDetail", SdkModel.SkuDetail)
    XLuaEvent.AddEvent("Bind", SdkModel.Bind)
    XLuaEvent.AddEvent("Unbind", SdkModel.Unbind)
    XLuaEvent.AddEvent("UploadHead", SdkModel.UploadHead)
    XLuaEvent.AddEvent("SetAdVertisingID", SdkModel.SetAdVertisingID)
    XLuaEvent.AddEvent("PermissionDeniedHandle", SdkModel.PermissionDeniedHandle)
    XLuaEvent.AddEvent("AIhelpInited", SdkModel.AIhelpInited)
    XLuaEvent.AddEvent("GMOnMessage", SdkModel.GMOnMessage)
    XLuaEvent.AddEvent("PermissionGrantedHandle", SdkModel.PermissionGrantedHandle)
end

function SdkModel.SetServer(_server, _serverId)
    server = _server
    serverId = _serverId
end

function SdkModel.SetName(_name)
    input_name = _name
end

function SdkModel.SqSDKLogin(type)
    Sdk.SqSDKLogin(type)
end

-- 汇报configBreakpoint表的事件
function SdkModel.TrackBreakPoint(id, value)
    local configInfo = ConfigMgr.GetItem("configBreakpoints", id)
    if configInfo then
        value = value and value or configInfo.value
        SdkModel.ReportEvent(configInfo.eventName, configInfo.key, tostring(value))
    end
end

-- 汇报自定义事件
function SdkModel.ReportEvent(category, key, value)
    if type(key) ~= "string" then
        key = tostring(key)
    end
    if not value then
        value = ""
    end
    if type(value) ~= "string" then
        value = tostring(value)
    end
    Sdk.TrackGameEvent(category, key, value, UserModel.data.accountId, UserModel.data.sceneId)
end

--purchaseType 商品类型 PurchaseType
--type 商品类型 RCHARGE
--configId 配置id，
--productId 商品id
function SdkModel.Rcharge37(purchaseType, type, configId, giftId)
    local productId = giftId[1]
    --请求订单
    Net.Purchase.CreateOrder(productId, configId, type, function(msg)
        --请求购买
        local serverId = Auth.WorldData.sceneId
        local reportCode = string.match(serverId, "%d+")
        Log.Info("=====  RequestSDKRcharge  ======== roleId :"..UserModel.data.accountId.."  roleName : "..Model.Player.Name.." roleLevel: "..Model.Player.Level.." serverId : ".."999".."  productId :"..
        productId.." orderId :"..msg.OrderId.."  expand : "..UserModel.data.accountId.."  PurchaseType : "..purchaseType)
        Sdk.RequestSDKRcharge(UserModel.data.accountId, Model.Player.Name, Model.Player.Level, reportCode, 
                productId, msg.OrderId, tostring(configId), purchaseType)
    end)
end

--获取商品项信息
function SdkModel.GetSkuDetail()
    if KSUtil.IsEditor() or KSUtil.IsWin() then
        return
    end
    local productIdList = {}
    local list = ConfigMgr.GetList("configIapLists")
    for _,v in ipairs(list)do
        table.insert(productIdList, v.googleIap)
    end
    local jsonStr = JSON.encode({productIdList = productIdList})
    Sdk.GetSkuDetail(PurchaseType.ITEM_TYPE_APP, jsonStr)
end

function SdkModel.GetUserId()
    return sdk_loginInfo.userId and sdk_loginInfo.userId or nil
end

--登录回调
function SdkModel.Login(loginInfo)
    sdk_loginInfo = JSON.decode(loginInfo)
    Log.Info("SdkModel.Login: " .. sdk_loginInfo.statusCode)
    if sdk_loginInfo.statusCode == "1" then
        local userId = sdk_loginInfo.userId
        if not userId or userId == "" then
            Log.Error("========= userId is false =======")
            return
        end
        SdkModel.SetLoginInfo(sdk_loginInfo)
        LoginModel.Login(userId, sdk_loginInfo.timeStamp, sdk_loginInfo.sign, server, "loginby37", serverId)
    else
        TipUtil.TipById(50204, "("..sdk_loginInfo.msg..")")
        Log.Error("====== Login  error ======"..sdk_loginInfo.statusCode)
    end
end

function SdkModel.SetLoginInfo(loginInfo)
    sdk_loginInfo = loginInfo
    CS.KSFramework.SdkModel.LoginInfo = JSON.encode(loginInfo)
    SdkModel.RefreshBindList()
end

--切换账号回调
function SdkModel.ReLogin(loginInfo)
    sdk_loginInfo = JSON.decode(loginInfo)
    if sdk_loginInfo.statusCode == "1" then
        local userId = sdk_loginInfo.userId
        if not userId or userId == "" then
            Log.Error("========= userId is false =======")
            return
        end
    
        CS.KSFramework.SdkModel.LoginInfo = loginInfo
        CS.KSFramework.SdkModel.IsReLogin = true
        Scheduler.ScheduleOnce(function()
            LoginModel.ExitLogin()
        end, 0.1)
    else
        -- TipUtil.TipById(50205, "("..sdk_loginInfo.msg..")")
        TipUtil.TipById(50205, "")
        CS.KSFramework.SdkModel.IsReLogin = false
    end
end

--退出账号回调
function SdkModel.Exit(info)
    local exitInfo = JSON.decode(info)

    if exitInfo.statusCode == "1" then
        TipUtil.TipById(50206)
    else
        TipUtil.TipById(50207, "("..exitInfo.msg..")")
    end
end

--Google 内购回调
function SdkModel.GoogleRcharge(info)
    local rchargeInfo = JSON.decode(info)
    if rchargeInfo.statusCode == "1" then
        local productId = rchargeInfo.productId
        Log.Debug("===rchargeInfo=== {0}", table.inspect(rchargeInfo))
    else
        Log.Warning("Sync GoogleRcharge failed: {0}", rchargeInfo.msg)
    end
end

--获取商品项信息回调
--  detailInfo
-- "country": "",
-- "currencyCode": "PHP",
-- "description": "monthlycard1",
-- "itemType": "inapp",
-- "jsonData": "{\"skuDetailsToken\":\"AEuhp4KxZMj3D8RWqlKAY9pJFrVrwPYONGtjOuSalaQWIu8iEsmjosQWdIzHkmGZP2X_\",\"productId\":\"neo.app.monthlycard1\",\"type\":\"inapp\",\"price\":\"PHP 1,300.00\",\"price_amount_micros\":1300000000,\"price_currency_code\":\"PHP\",\"title\":\"monthlycard1 (Final Order)\",\"description\":\"monthlycard1\"}",
-- "platform": "GOOGLEPLAY",
-- "price": "PHP 1,300.00",
-- "priceMicros": "1300000000",
-- "productId": "neo.app.monthlycard1",
-- "title": "monthlycard1 (Final Order)",
-- "type": "inapp"

-- jsonData
-- {
-- -- description = "pack1\n",
-- -- price = "PHP 53.00",  当前币种价格
-- -- price_amount_micros = 53000000.0,   要除以100万 就是当前的价格
-- -- price_currency_code = "PHP",    皮重
-- -- productId = "neo.app.pack1",   商品项
-- -- skuDetailsToken = "AEuhp4IXpJXWWgMiqFKxSg9iYqZLvVLB0dcGL8jS69kEvBSgS158cV8-SkbgQGDzV0E=",
-- -- title = "pack1 (Neo Crisis)",  标题
-- -- type = "inapp"   商品项类型
-- }

function SdkModel.SkuDetail(info)
    local skuDetailInfo = JSON.decode(info)
    if skuDetailInfo.statusCode == "1" then
        local detailInfo = {}
        for k,v in pairs(skuDetailInfo)do
            if k ~= "luaFun" and k ~= "statusCode" then
                detailInfo[k] = JSON.decode(v)
                detailInfo[k].JsonData = JSON.decode(detailInfo[k].jsonData)
            end
        end
        for k,v in pairs(detailInfo)do
            v.price_code = CoinType[v.currencyCode] and CoinType[v.currencyCode] or v.currencyCode
            v.price_amount = tonumber(v.priceMicros)/1000000
        end
        ShopModel:InitSkuDetail(detailInfo)
        SdkModel.getSkuDetailState = true
    else
        Log.Warning("Get SkuDetail failed: {0}", skuDetailInfo.msg)
        SdkModel.getSkuDetailState = false
    end
end

--绑定第三方回调
--  {"msg":"success","is_fb_bind":"0","is_gp_bind":"1","fb_name":"",
--  "userId":"1008242807","luaFun":"Bind","gp_name":"qiao wei","bingType":"GOOGLE","tw_name":"","gameCode":"neo",
--  "userType":"GOOGLE_TYPE","device":"android","is_tw_bind":"0","channelId":"googlePlay","statusCode":"1"}

-- {"msg":"success","is_fb_bind":"0","naver_name":"","pid":"","fb_name":"","remark":"",
-- "luaFun":"Login","gp_name":"qiao wei","tw_name":"","is_line_bind":"0","line_name":"","is_tw_bind":"0",
-- "channelId":"googlePlay","is_gp_bind":"1","userId":"1008242807","afid":"1585918390643-5517822541877248071","SID":"",
-- "timeStamp":"1585924000","is_naver_bind":"0","gameCode":"neo","userType":"ANYNOMOUS_TYPE","device":"android","uniqueId":
-- "48b694fd-095e-4397-828b-278e0ecb38d6","statusCode":"1"}
function SdkModel.Bind(info)
    local bindInfo = JSON.decode(info)
    local bingType = bindInfo.bingType
    if bindInfo.statusCode == "1" then
        for bindInfo_k,bindInfo_v in pairs(bindInfo)do
            for sdk_loginInfo_k,sdk_loginInfo_v in pairs(sdk_loginInfo)do
                if bindInfo_k == sdk_loginInfo_k then
                    sdk_loginInfo[sdk_loginInfo_k] = bindInfo_v and bindInfo_v or ""
                    break
                end
            end
        end
        SdkModel.RefreshBindList()
        Event.Broadcast(SDK_BIND_EVNET.BindEvnet)
        TipUtil.TipById(50210)
    else
        TipUtil.TipById(50211, "("..bindInfo.msg..")")
    end
end

--解绑第三方回调
function SdkModel.Unbind(info)
    local unbindInfo = JSON.decode(info)
    local bingType = unbindInfo.bingType
    if unbindInfo.statusCode == "1" then
        for unbindInfo_k,unbindInfo_v in pairs(unbindInfo)do
            for sdk_loginInfo_k,sdk_loginInfo_v in pairs(sdk_loginInfo)do
                if unbindInfo_k == sdk_loginInfo_k then
                    sdk_loginInfo[sdk_loginInfo_k] = unbindInfo_v and unbindInfo_v or ""
                    break
                end
            end
        end
        SdkModel.RefreshBindList()
        Event.Broadcast(SDK_BIND_EVNET.BindEvnet)
        TipUtil.TipById(50212)
    else
        TipUtil.TipById(50213, "("..unbindInfo.msg..")")
    end
end

-- AIhelp初始化成功回调
function SdkModel.AIhelpInited(str)
    Log.Info("=========AIhelpInited====== " .. str)
end

-- GM回复回调
SdkModel.GmNotRead = 0
function SdkModel.GMOnMessage(jsonStr)
    local gmMsgInfo = JSON.decode(jsonStr)
    -- gmMsgInfo.data.cs_message_count
    Log.Info("=========GMOnMessage====== " .. gmMsgInfo.data.cs_message_count)

    SdkModel.GmNotRead = tonumber(gmMsgInfo.data.cs_message_count)
    if SdkModel.GmNotRead > 0 then
        Event.Broadcast(GM_MSG_EVENT.NewMsgNotRead, SdkModel.GmNotRead)
    else
        Event.Broadcast(GM_MSG_EVENT.MsgIsRead, SdkModel.GmNotRead)
    end
end

--上传并设置头像
function SdkModel.UploadHead(info)
    local headInfo = JSON.decode(info)
    local url = Model.Account.gate.."/avatar/uploadavatar"
    CSCoroutine.Start(function()
        local uploadCb = function(error, rsp)
            if error ~= "" then
                TipUtil.TipById(50265)
                return
            end
            if rsp == "" then
                TipUtil.TipById(50264)
                return
            end
            local response = JSON.decode(rsp)
            -- 成功
            if response.code == 20000 then 
                -- 请求更新头像
                local name = Model.Account.accountId.."_"..tostring(math.floor(response.data))
                Net.UserInfo.UploadUserAvatar(name, function(rsp)
                    if rsp.Fail then
                        return
                    end
                    -- 保存头像更新数据
                    local data = {}
                    local json = Util.GetPlayerData("AvatarChangeTime")
                    if json ~= "" then
                        data = JSON.decode(json)
                    end
                    data[Model.Account.accountId] = tostring(math.floor(response.data))
                    json = JSON.encode(data)
                    Util.SetPlayerData("AvatarChangeTime", json)
                    Model.Player.Avatar = name
                    Event.Broadcast(EventDefines.UIPlayerInfoExchange)
                    Event.Broadcast(EventDefines.UIPlayerUpdateHead)
                end)
            else
            end
        end
        -- 上传头像图片
        local req = ResMgr.Instance:UploadHead(headInfo.name, url, Model.Account.accountId, uploadCb)
        coroutine.yield(req)
    end)
end

--获取广告Id
function SdkModel.SetAdVertisingID(adId)
    Log.Info("=============SetAdVertisingID============  " .. adId)
    Net.Logins.SetDeviceAdId(adId)
end

--用户拒绝权限后处理
function SdkModel.PermissionDeniedHandle(info)
    local type = JSON.decode(info).type
    if type == "camera" then
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Tips_Jurisdiction_Camera"),
            sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
        }
        UIMgr:Open("ConfirmPopupText", data)
    elseif type == "gallery" then
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Tips_Jurisdiction_Image"),
            sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
        }
        UIMgr:Open("ConfirmPopupText", data)
    elseif type == "GM" then
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Gm_NoUpload_Permission"),
            sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
        }
        UIMgr:Open("ConfirmPopupText", data)
    end
end

--用户同意权限后处理
function SdkModel.PermissionGrantedHandle(info)
    local type = JSON.decode(info).type
    if type == "GM" then
        local serverId = ""
        local accountId = "" 
        if Auth and Auth.WorldData then
            serverId = Auth.WorldData.sceneId
            accountId = string.gsub(Auth.WorldData.accountId, "#", "-")
        end
        Sdk.AiHelpShowConversation(accountId, serverId)
        SdkModel.GmNotRead = 0
        Event.Broadcast(GM_MSG_EVENT.MsgIsRead, SdkModel.GmNotRead)
    end
end

function SdkModel.RefreshBindList( )
    _bindList = {}

    local faceBook = {
        type = SDK_BIND_TYPE.FACEBOOK_TYPE,
        isBind = sdk_loginInfo.is_fb_bind,
        name = sdk_loginInfo.fb_name
    }

    local google = {
        type = SDK_BIND_TYPE.GOOGLE_TYPE,
        isBind = sdk_loginInfo.is_gp_bind,
        name = sdk_loginInfo.gp_name
    }

    table.insert(_bindList, faceBook)
    table.insert(_bindList, google)
end

function SdkModel.GetBindList()
    --[[  --------------test--------------------
        _bindList = {}

        local faceBook = {
            type = SDK_BIND_TYPE.FACEBOOK_TYPE,
            isBind = "0",
            name = "faceBook"
        }

        local google = {
            type = SDK_BIND_TYPE.GOOGLE_TYPE,
            isBind = "0",
            name = "google"
        }

        table.insert(_bindList, faceBook)
        table.insert(_bindList, google)
    --]]
    return _bindList
end

function SdkModel.IsBind()
    if sdk_loginInfo.is_fb_bind == "1" or sdk_loginInfo.is_gp_bind == "1" 
        or sdk_loginInfo.is_tw_bind == "1" or sdk_loginInfo.is_line_bind == "1" or sdk_loginInfo.is_naver_bind == "1" then
            return true
    end
    return false
end

return SdkModel