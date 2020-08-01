--author: 	Amu
--time:		2019-07-09 11:56:12

local Login = UIMgr:NewUI("Login")
local ServerList = {}
local GlobalVars = GlobalVars

local LoadingEffect = import("UI/Loading/LoadingEffect")

function Login:OnInit()
    self._comboBox:GetChild("btnArrow").title = "˯"
    self:AddListener(self._btnLogin.onClick,
        function()
            self:OnBtnLoginClick()
        end
    )
    if KSUtil.IsEditor() then
        self:SetOpenGuide()
    end

    --播放Loading特效
    LoadingEffect.LoadEffect(self._loadingEffect)
end

function Login:PlayEffect()
    -- UIMgr:Open("LoginEffect")
end

function Login:OnOpen(info)
    self:PlayEffect()
    SystemSetModel.InitLoginAudioVolume()
    AudioModel.Play(10005)
    self.info = info
    self._textInput.text = ""
    self._textRoleId.text = ""
    self._textVersion.text = StringUtil.GetI18n(I18nType.Commmon, "UI_VERSION_TEXT")..":"..GameVersion.localV
    self._pkgVersion.text = StringUtil.GetI18n(I18nType.Commmon, "PKG_VERSION_TEXT")..":"..GameVersion.GetInAppVersion().String 
    local baseUrl = GateConfig.GateUrl()
    local uid = KSUtil.GetUdid()
    local platform
    local platformName = KSUtil.GetPlayformStr()
    if platformName == PlayformEnum.ANDROID or
        platformName == PlayformEnum.IPHONE then
        platform = 1001 -- 37平台
    else
        platform = 1000 -- guest
    end
    local data = JSON.encode({
        uid = uid,
        platform = platform,
    })
    NetworkManager.Instance:PostJson(
        baseUrl.."/auth/servers",
        data,
        function(error, rsp)
            if error ~= "" then
                Log.Error(error)
                return
            end
            local info = JSON.decode(rsp)
            dump(info)
            --Log.Info("ServerList: {0}", table.inspect(info.servers))
            local names = {}
            local values = {}
            local lastId = self:GetLastLoginServerId()
            if info.serverId ~= "" then
                lastId = info.serverId
            end
            local choosedIdx = 0
            ServerList = info.servers
            for i,server in ipairs(info.servers) do
                if lastId ~= "" and server.uuid == lastId then
                    choosedIdx = i - 1
                end
                table.insert(names, server.name)
                local gateUrl = server.gate_url
                if gateUrl == "" then
                    gateUrl = baseUrl
                end
                table.insert(values, gateUrl)
            end
            self._comboBox.items = names
            self._comboBox.values = values
            self._comboBox.selectedIndex = tonumber(choosedIdx)
            self._textInput.text = Login:GetLastLoginName()
        end
    )
end

function Login:GetLastLoginServerId()
    local data = Util.GetPlayerData("LoginRecord")
    if string.len(data) ~= 0 then
        local loginInfo = JSON.decode(data)
        return loginInfo.serverId
    end
    return ""
end

function Login:GetLastLoginName()
    local data = Util.GetPlayerData("LoginRecord")
    if string.len(data) ~= 0 then
        local loginInfo = JSON.decode(data)
        return loginInfo.name
    end
    return ""
end

function Login:SetLastLoginServerId(name, serverId)
    local loginInfo = {name = name ,serverId = serverId}
    Util.SetPlayerData("LoginRecord", JSON.encode(loginInfo))
end

function Login:OnClose()
    UIMgr:DisposeWindow("Loading", "Login")
end

function Login:OnBtnLoginClick()
    if LoginModel.clickLogin then
        return
    end
    LoginModel.clickLogin = true
    local uuid = ServerList[self._comboBox.selectedIndex+1].uuid
    local name = self._textInput.text
    local _fun = function()
        LoginModel.clickLogin = false
    end
    self:ScheduleOnce(_fun, 2)
    if self._textRoleId.text ~= "" then
        CS.KSFramework.SdkModel.IsReLogin = false
        LoginModel.Login(self._textRoleId.text, "", "", self._comboBox.value, "loginbygm", "")
        return
    end
    if KSUtil.IsEditor() or KSUtil.IsWin() then
        if self._textInput.text == "" then
            name = KSUtil.GetUdid()
            Login:SetLastLoginServerId("", uuid)
        else
            Login:SetLastLoginServerId(name, uuid)
        end
        LoginModel.Login(name, "", "", self._comboBox.value, "loginbyguest", uuid)
    else 
        KSUtil.IsAndroid()
        SdkModel.SetServer(self._comboBox.value, uuid)
        SdkModel.SetName(name)
        if CS.KSFramework.SdkModel.IsReLogin and CS.KSFramework.SdkModel.LoginInfo then
            SdkModel.Login(CS.KSFramework.SdkModel.LoginInfo)
        else
            Sdk.AutoLogin()
            SdkModel.TrackBreakPoint(10020)
        end
    end
end

--设置是否开启新手引导
function Login:SetOpenGuide()
    self:AddListener(self._checkNoviceGuide.onChanged,function()
        GlobalVars.IsOpenNoviceGuide = self._checkNoviceGuide.selected
        PlayerDataModel.SetLocalData("NOVICE_GUIDE_OPEN", GlobalVars.IsOpenNoviceGuide)
    end)

    
    self._checkNoviceGuide.visible = true
    self._textNoviceGuide.visible = true
    self._textNoviceGuide.text = "新手引导"
    self._checkNoviceGuide.selected = PlayerDataModel.GetLocalData("NOVICE_GUIDE_OPEN") == "true"
    GlobalVars.IsOpenNoviceGuide = self._checkNoviceGuide.selected
    PlayerDataModel.SetLocalData("NOVICE_GUIDE_OPEN", GlobalVars.IsOpenNoviceGuide)
    self:AddListener(self._checkGuide.onChanged,function()
        GlobalVars.IsOpenTriggerGuide = self._checkGuide.selected
        PlayerDataModel.SetLocalData("GUIDE_OPEN", GlobalVars.IsOpenTriggerGuide)
    end)
    self._checkGuide.visible = true
    self._textGuide.visible = true
    self._textGuide.text = "触发引导"
    self._checkGuide.selected = PlayerDataModel.GetLocalData("GUIDE_OPEN") == "true"
    GlobalVars.IsOpenTriggerGuide = self._checkGuide.selected
    PlayerDataModel.SetLocalData("GUIDE_OPEN", GlobalVars.IsOpenTriggerGuide)
end

return Login
