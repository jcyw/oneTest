if HotUpdate then
    return HotUpdate
end

function import(filename)
    return CS.KSFramework.LuaModule.Instance:Import(filename)
end

function new(cls, ...)
    assert(cls ~= nil)
    local ins = setmetatable({}, {__index = cls})
    if cls.ctor then
        ins:ctor(...)
    end
    return ins
end

import("Auth/Auth")
import("Model/ABTest")
import("Common/define")
import("ConfigFiles/LoadingTip")
import("ConfigFiles/ConfigMgr")
import("Utils/TimeUtil")
import("Utils/CSCoroutine")
import("Helper/Tool")
import("Model/SdkModel")
import("ConfigFiles/Language")
import("Model/PlayerDataModel")
require("Model/GmModel")

Global = import("gen/excels/Global")
JSON = require("CJson")
JSON.encode_sparse_array(true)

CSCoroutine = import("Utils/CSCoroutine")
HUpdator = import("HotUpdate/HUpdator")
HULoading = import("HotUpdate/HULoading")

-- EventCenter
import("EventCenter/EventDefines")
Event = import("EventCenter/events")

HotUpdate = {
    IsDev = KSUtil.IsEditor() or KSUtil.IsWin() or GateConfig.GetStage() == "Develop",
    updateType = Auth.UpdateType.UpdateTypeNoUpdate,
    SdkLoginSuccess = false,
}

function HotUpdate.New(behaviour)
    local ins = new(HotUpdate)
    ins.behaviour = behaviour
    ins.gameObject = behaviour.gameObject
    return ins
end

function HotUpdate:Start()
    CSCoroutine.Start(function()
        local w = UnityWebRequest.Get("http://checkip.amazonaws.com/")
        coroutine.yield(w:SendWebRequest())
        --dump("aaa--------", w.downloadHandler.text)
        CS.KSFramework.Main.Instance:SetData("PublicIP", w.downloadHandler.text)
        if Sdk.InitBuglyInfo then
            Sdk.InitBuglyInfo(Util.GetDeviceId(), GameVersion.GetLocalVersion().String)
        end
        --assert(io.read("*number"), "invalid input")
        if HotUpdate.IsDev then
            self:StartGame()
        else
            self:StartProd()
        end
    end)
end

local delayGm = 10
local _time = 0
local isShowGm = false

local retryDelay = 2
local retryAt = 0
local retryCb = nil
local now = nil
local maintainCb = nil
function HotUpdate:Update()
    if retryCb then        
        now = Time.fixedTime
        if now - retryAt >= retryDelay then
            cb = retryCb
            retryCb = nil
            cb()
        end
    end

    if maintainCb then
        maintainCb()
    end

    if _time < delayGm then
        _time = _time + Time.deltaTime
    elseif not isShowGm then
        GmModel.gmCallBcak()
        isShowGm = true
    end
    -- Log.Info("=========_time===========".._time)
end

--[[
开发启动流程:
 1.检测热更新
 2.打开登录界面
 3.登录37SDK
 4.登录World
 5.打开Loading，加载游戏资源
 6.建立TCP连接
 7.登录游戏服
 8.进入游戏
]]
function HotUpdate:StartGame()
    HULoading:LoadUI(CS.KSFramework.Main.Restarted())
    HULoading:ShowBG()
    CSCoroutine.Start(function()
        HUpdator:CheckMainVersion()
    end)
end

--[[
正式启动流程:
 1.登录37SDK
 2.登录World
 3.检测热更新
 4.加载游戏资源
 5.建立TCP连接
 6.登录游戏服
 7.进入游戏
]]
function HotUpdate:StartProd()
    HULoading:LoadUI(CS.KSFramework.Main.Restarted())
    HULoading:ShowBG()
    XLuaEvent.AddEvent("Login", function(loginInfo)
        self:OnSDkLogin(loginInfo)
    end)
    if CS.KSFramework.SdkModel.IsReLogin then
        local loginInfo = CS.KSFramework.SdkModel.LoginInfo
        self:OnSDkLogin(loginInfo)
    else
        self:SdkLogin()
    end
end

function HotUpdate:SdkLogin()
    if HotUpdate.SdkLoginSuccess then
        return
    end
    Sdk.AutoLogin()
    self:retry(4, function()
        Log.Info("Retry SdkLogin")
        self:SdkLogin()
    end)
end

function HotUpdate:OnSDkLogin(loginInfo)
    sdk_loginInfo = JSON.decode(loginInfo)
    if sdk_loginInfo.statusCode == "1" then
        HotUpdate.SdkLoginSuccess = true
        XLuaEvent.DelEvent("Login")
        local userId = sdk_loginInfo.userId
        HotUpdate.SdkLoginInfo = sdk_loginInfo
        CS.KSFramework.SdkModel.LoginInfo = loginInfo
        self:OnLogin(userId, sdk_loginInfo.timeStamp, sdk_loginInfo.sign, "loginby37")
    else
        HULoading:ShowBG()
        HULoading:SetLoadingTip(sdk_loginInfo.msg)
        self:SdkLogin()
    end
end

function HotUpdate:OnLogin(userId, timeStamp, sign, action)
    local url = GateConfig.GateUrl()
    local success = function(msg)
        Log.Info("HotUpdate:OnLogin: {0}->{1}", msg.isDown, msg.downTime)
        --如果服务器维护
        if msg.isDown then
            local leftCb = function()
                self:OnLogin(userId, timeStamp, sign, action)
            end
            local rightCb = function()
                FUIUtils.QuitGame()
            end
            self:ShowMaintainConfirm(msg.downTime, leftCb, rightCb)
        else
            --判断平台返回的更新类型
            if HotUpdate.updateType == Auth.UpdateType.UpdateTypeNoUpdate then
                --Log.Error("--------------没有更新")
                HUpdator:getRemoteVersion()
                HUpdator:gotoGame()
            elseif HotUpdate.updateType == Auth.UpdateType.UpdateTypeHotUpdate then
                --Log.Error("--------------正常热更新")
                HULoading:ShowBG()
                CSCoroutine.Start(function()
                    HUpdator:CheckMainVersion()
                end)
            elseif HotUpdate.updateType == Auth.UpdateType.UpdateTypeForceUpdate then
                --Log.Error("--------------强制更新App")
                HUpdator:gotoUpdateApp()
            elseif HotUpdate.updateType == Auth.UpdateType.UpdateTypePreHotUpdate then
                --Log.Error("--------------静默更新")
                HUpdator:gotoGame()
                CSCoroutine.Start(function()
                    HUpdator:PreUpdateCheckMainVersion()
                end)
            end
        end
    end
    local failed = function(errorCode)
        if errorCode.error_code and errorCode.error_code == "error_account_banned" then
            self:AleryBan(errorCode)
        else
            HULoading:ShowBG()
            HULoading:SetLoadingTip(errorCode.error_code)
            self:retry(2, function()
                Log.Info("Retry LoginWorld")
                self:OnLogin(userId, timeStamp, sign, action)
            end)
        end
    end

    Auth.LoginWorld(userId, timeStamp, sign, url, action, "", success, failed)
end

function HotUpdate:retry(delay, cb)
    retryCb = cb
    retryDelay = delay
    retryAt = Time.fixedTime
end

-- 封号弹窗
local aleryBanPanel
function HotUpdate:AleryBan(errorCode)
    ConfigMgr.Init()
    local tip
    local leftBtnTxt = StringUtil.GetI18n("configI18nCommons", "BUTTON_CONTACT_US")
    if errorCode.error_value and errorCode.error_value > 0 then
        tip = StringUtil.GetI18n("configI18nCommons", "Ui_Ban_Time_limit", {time = TimeUtil:StampTimeToYMDHMS(errorCode.error_value)})
    else
        tip = StringUtil.GetI18n("configI18nCommons", "Ui_Ban_Permanent")
    end

    if not aleryBanPanel then
        aleryBanPanel = UIPackage.CreateObject("Loading", "ConfirmDoublePopup")
        aleryBanPanel:SetSize(GRoot.inst.width, GRoot.inst.height)
        CS.FairyGUI.GRoot.inst:AddChild(aleryBanPanel)
        aleryBanPanel:GetChild("btnClose").visible = false
        aleryBanPanel:GetChild("titleName").text = ""
        local contentText = aleryBanPanel:GetChild("content")
        local leftBtn = aleryBanPanel:GetChild("btnCity")
        aleryBanPanel:GetController("c1").selectedIndex = 1
        leftBtn.SoundName = ""
        leftBtn.text = leftBtnTxt
        contentText.text = tip
    
        leftBtn.onClick:Add(function()
            GmModel.InitGmByDevice("BanPlayer")
            Sdk.AiHelpShowConversation(Util.GetDeviceId(), "BanPlayer")
        end)
    end
end

-- 服务器维护弹窗
local maintainWindow = nil
function HotUpdate:ShowMaintainConfirm(finishAt, leftCb, rightCb)
    ConfigMgr.Init()
    if maintainWindow then
        maintainWindow.visible = true
    else
        maintainWindow = UIPackage.CreateObject("Loading", "ConfirmDoublePopup")
        maintainWindow:SetSize(GRoot.inst.width, GRoot.inst.height)
        CS.FairyGUI.GRoot.inst:AddChild(maintainWindow)
    end
    maintainWindow:GetChild("btnClose").visible = false
    maintainWindow:GetChild("titleName").text = ""
    local contentText = maintainWindow:GetChild("content")
    local leftBtn = maintainWindow:GetChild("btnCity")
    local rightBtn = maintainWindow:GetChild("btnUnion")
    leftBtn.SoundName = ""
    rightBtn.SoundName = ""
    leftBtn.text = StringUtil.GetI18n("configI18nCommons", "BUTTON_RETRY")
    rightBtn.text = StringUtil.GetI18n("configI18nCommons", "BUTTON_QUIT")

    leftBtn.onClick:Clear()
    leftBtn.onClick:Add(function()
        maintainWindow.visible = false
        maintainCb = nil
        if leftCb then
            leftCb()
        end
    end)

    rightBtn.onClick:Clear()
    rightBtn.onClick:Add(function()
        maintainWindow.visible = false
        maintainCb = nil
        if rightCb then
            rightCb()
        end
    end)

    local time = finishAt - Tool.Time()
    if time > 0 then
        maintainCb = function()
            local curTime = finishAt - Tool.Time()
            if curTime > 0 then
                contentText.text = StringUtil.GetI18n("configI18nCommons", "TIPS_SERVER_MAINTENACE", {time = TimeUtil.SecondToDHMS(curTime)})
            else
                maintainWindow.visible = false
                maintainCb = nil
                if leftCb then
                    leftCb()
                end
            end
        end
    else
        contentText.text = StringUtil.GetI18n("configI18nCommons", "TIPS_SERVER_MAINTENACE", {time = "00:00:00"})
    end

end

function HotUpdate:SetUpdateType(updateType)
    --HotUpdate.updateType = updateType
    HotUpdate.updateType = Auth.UpdateType.UpdateTypeHotUpdate
end
return HotUpdate
