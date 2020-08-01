--[[
    Author: songzeming
    Function: 资源加载界面
]]
if Loading then
    return Loading
end

Loading = UIMgr:NewUI("Loading")
import("Utils/StringUtil")
import("Enum/I18nType")
local LoadingEffect = import("UI/Loading/LoadingEffect")
local GoWrapper = CS.FairyGUI.GoWrapper
local GameObject = CS.UnityEngine.GameObject

local preloadPkgs = {
    "City",
    "CityBg",
    "Build",
    "Common",
    "Icon",
    "IconCharacter",
    "ActivityCenter",
    "IconArm",
    "Novice",
    "NoviceImage",
    "IconFactory",
    "BeautySystem",
    "KingkongBg",
    "Welfare",
    "Recharge",
    "Effect",
}

local deferLoadPkgs = {
    "WorldCity",
    "Union",
    "IconUnion",
    "Mail",
    "Laboratory",
    "Chat",
    "Number",
    "IconQueue",
    "IconMap",
    "IconActivity",
    "IconFlag",
    "IconResearch",
    "IconBeautySystem",
    "IconUnion",
    "Setup",
}

function Loading:OnInit()
    Loading.Instance = self
    self._text.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Res_Loading")
    self._text.visible = true
    self._bar.visible = true
    self._effectNode = self._bar:GetChild("_effectNode")
    self._effectNode2 = self._bar:GetChild("_effectNode2")
    self._bg.icon = ABTest.Loading()
    self:AddEvent(LOGIN_EVENT_TYPE.LogInSuccess, function()
        self:LoadRes()
    end)

    --播放Loading特效
    LoadingEffect.LoadEffect(self._loadingEffect)
end

function Loading:OnOpen(cb)
    Log.Info("Loading:OnOpen 1")
    self._bar.value = 0
    -- 开发流程
    if HotUpdate.IsDev then
        self:LoadRes()
        cb()
        return
    end
    -- 重新登录
    local baseUrl = GateConfig.GateUrl()
    SdkModel.SetServer(baseUrl)
    if CS.KSFramework.SdkModel.IsReLogin then
        local info = JSON.decode(CS.KSFramework.SdkModel.LoginInfo)
        local userId = info.userId
        local timestamp = info.timeStamp
        local sign = info.sign
        local success = function()
            HotUpdate.SdkLoginInfo = info
            self:StartGame()
        end
        local failed = function(errorCode)
            LoginModel.AlertRetry(function()
                Auth.LoginWorld(userId, timestamp, sign, baseUrl, "loginby37", "", success, failed)
            end, errorCode)
        end
        Auth.LoginWorld(userId, timestamp, sign, baseUrl, "loginby37", "", success, failed)
        return
    end
    -- 常规登录
    if HotUpdate.SdkLoginInfo then
        self:StartGame()
    end
end

function Loading:StartGame()
    SdkModel.SetLoginInfo(HotUpdate.SdkLoginInfo)
    SdkModel.TrackBreakPoint(10020)
    self:LoadRes()
    LoginModel.StartGame()
end

function Loading:OnClose()
    UIMgr:Close("LoginEffect")
end

function Loading:LoadRes()
    Loading.SetLoadingTip("start_loading_res")
    CSCoroutine.Start(function()
        --启动时 加载动态资源
        local len = #preloadPkgs
        for k, v in pairs(preloadPkgs) do
            coroutine.yield(UIMgr:AddPackage(v))
            if k == len then
                self._bar.value = 100
                if self.jinduEffect then
                    self.jinduEffect.transform.localScale = self.jinduEffect_ogScale
                end
            else
                self._bar.value = self._bar.value + 100 / len
                if self.jinduEffect then
                    self.jinduEffect.transform.localScale =  Vector3(self.jinduEffect_ogScale.x * self._bar.value * 0.01, self.jinduEffect_ogScale.y, self.jinduEffect_ogScale.z)
                end
            end
        end
        if CommonType.LOGIN then
            Loading.EnterCity()
        else
            self:AddEvent(EventDefines.LoginSuccess, Loading.EnterCity)
        end
    end)
end

function Loading.EnterCity()
    Loading.SetLoadingTip("enter_city")
    Sdk.GetToken()
    Event.RemoveListener(EventDefines.LoginSuccess, Loading.EnterCity)
    GmModel.EndGm()
    UIMgr:Close("Loading")
    UIMgr:Open("City")
    CSCoroutine.Start(function()
        for _, v in pairs(deferLoadPkgs) do
            coroutine.yield(UIMgr:AddPackage(v))
            Log.Info("async load: {0}", v)
        end
    end)
end

function Loading.SetLoadingTip(tip)
    local ins = Loading.Instance
    if not ins then
        return
    end
    if ins._text then
        ins._text.text = LoadingTip.Get(tip)
    end
end

return Loading
