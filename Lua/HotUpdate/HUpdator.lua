if HUpdator then
    return HUpdator
end

HUpdator = {}

GameVersion = import("HotUpdate/GameVersion")
GameVersionList = import("HotUpdate/GameVersionList")

function HUpdator:CheckMainVersion()
    HULoading.SetLoadingTip("check_version")
    
    -- 检测是否需要转移资源
    if not ResMgr.IsReadDirect() then
        if Util.DeleteDir then
            GameVersion.CheckDelOldRes()
        else
            if GameVersion.NeedTransfer() then
                Sdk.TrackGameEvent("custom_loss", "resource_decompression1_begin", "1")
                CSCoroutine.Start(function()
                    self:transferResProgress()
                end)
                GameVersionList.TransferFiles()
                Sdk.TrackGameEvent("custom_loss", "resource_decompression1_end", "1")
            end
        end
    end

    -- 检测是否需要热更新
    Sdk.TrackGameEvent("custom_loss", "check_update_begin", "1") -- 打点
    local localVersion = GameVersion.GetLocalVersion()
    local pkgVersion = GameVersion.GetInAppVersion()
    Sdk.LocalVersion = localVersion.String
    if Sdk.PkgVersion == "" then
        Sdk.PkgVersion = pkgVersion.String
    end
    local req = UnityWebRequest.Get(GameVersion.VersionFileUrl())
    coroutine.yield(req:SendWebRequest())

    if req.isNetworkError or req.isHttpError then
        Log.Error("Get remote version failed: {0} {1}", GameVersion.VersionFileUrl(), req.error);
        coroutine.yield(UnityEngine.WaitForSeconds(1))
        coroutine.yield(self:CheckMainVersion())
        return
    end

    local version = req.downloadHandler.text
    local remoteVersion = GameVersion.New(version)

    GameVersion.localV = localVersion.String
    GameVersion.remote = remoteVersion.String
    CS.KSFramework.Main.Instance:SetData("remote", remoteVersion.String)

    Log.Info("remoteVersion: {0}, localVersion: {1}", remoteVersion.String, localVersion.String)
    Sdk.TrackGameEvent("custom_loss", "check_update_end", "1")

    -- 编辑器不热更
    if ResMgr.IsReadDirect() then
        Log.Info("ReadDirect skip hotupdate!")
        self:gotoGame()
        return
    end

    local result = localVersion:Compare(remoteVersion)
    Log.Info("HotUpdate compare: {0}", result)
    if result == "UpdateApp" then
        self:gotoUpdateApp()
    elseif result == "UpdateRes" then
        HULoading.SetLoadingTip("start_hotupdate")
        CSCoroutine.Start(function()
            self:gotoUpdateRes()
        end)
    elseif result == "Past" then
        self:gotoGame()
    end
end

function HUpdator:getRemoteVersion()
    local req = UnityWebRequest.Get(GameVersion.VersionFileUrl())
    coroutine.yield(req:SendWebRequest())

    if req.isNetworkError or req.isHttpError then
        Log.Error("Get remote version failed: {0} {1}", GameVersion.VersionFileUrl(), req.error);
        coroutine.yield(UnityEngine.WaitForSeconds(1))
        coroutine.yield(self:getRemoteVersion())
        return
    end

    local version = req.downloadHandler.text
    local remoteVersion = GameVersion.New(version)

    GameVersion.localV = localVersion.String
    GameVersion.remote = remoteVersion.String
    CS.KSFramework.Main.Instance:SetData("remote", remoteVersion.String)
end

-- 更新APP
function HUpdator:gotoUpdateApp()
    Log.Info("CheckUpdate: UpdateApp")
    local func = function()
        local playformStr = KSUtil.GetPlayformStr()
        if playformStr == PlayformEnum.IPHONE then
            -- TODO 跳转IOS网页
            -- local url = GateConfig.GetValue("iOSStore")
        elseif playformStr == PlayformEnum.ANDROID then
            -- Sdk.OpenAppStore()
            Sdk.OpenBrowser("https://play.google.com/store/apps/details?id=com.global.neocrisis2")
        end
    end
    self:OpenTipPopupPanel(func)
end

local popupPanel
function HUpdator:OpenTipPopupPanel(cb)
    if not popupPanel then
       popupPanel = UIPackage.CreateObject("Loading", "ConfirmDoublePopup") 
       popupPanel:SetSize(GRoot.inst.width, GRoot.inst.height)
       CS.FairyGUI.GRoot.inst:AddChild(popupPanel)
    else
        popupPanel.visible = true
    end

    local titleText = popupPanel:GetChild("titleName")
    local contentText = popupPanel:GetChild("content")
    local leftBtn = popupPanel:GetChild("btnCity")
    local rightBtn = popupPanel:GetChild("btnUnion")
    local closeBtn = popupPanel:GetChild("btnClose")
    popupPanel:GetController("c1").selectedIndex = 0
    leftBtn.SoundName = ""
    rightBtn.SoundName = ""
    closeBtn.SoundName = ""
    titleText.text = StringUtil.GetI18n("configI18nCommons", "Tips_TITLE")
    contentText.text = StringUtil.GetI18n("configI18nCommons", "ALERT_UPDATE_APP_TIPS")
    leftBtn.text = StringUtil.GetI18n("configI18nCommons", "BUTTON_CONFIRM")
    rightBtn.text = StringUtil.GetI18n("configI18nCommons", "BUTTON_CONTACT_GM")

    leftBtn.onClick:Clear()
    leftBtn.onClick:Add(function()
        if cb then
            cb()
        end
    end)

    rightBtn.onClick:Clear()
    rightBtn.onClick:Add(function()
        GmModel.InitGmByDevice("Final Order")
        Sdk.AiHelpShowConversation(Util.GetDeviceId(), "Final Order")
    end)

    closeBtn.onClick:Clear()
    closeBtn.onClick:Add(function()
        FUIUtils.QuitGame()
    end)
end

-- 更新资源
function HUpdator:gotoUpdateRes()
    Log.Info("CheckUpdate: UpdateRes")
    HULoading.SetLoadingTip("download_versionlist")
    Sdk.TrackGameEvent("custom_loss", "download_version_list", "1")
    local req = UnityWebRequest.Get(GameVersion.VersionListUrl())
    coroutine.yield(req:SendWebRequest())
    if req.isHttpError or req.isNetworkError then
        Log.Error("Get remote version list failed: {0} {1}", GameVersion.VersionListUrl(), req.error);
        coroutine.yield(UnityEngine.WaitForSeconds(1))
        coroutine.yield(self:gotoUpdateRes())
        return
    end
    Sdk.TrackGameEvent("custom_loss", "parse_version_list", "1")
    local content = Util.Unzip(req.downloadHandler.data)
    HULoading.SetLoadingTip("gen_versionlist")
    local remoteVersionList = GameVersionList.New(content)
    local localVersionList = GameVersionList.GetLocalVersionList()
    HULoading.SetLoadingTip("download_files")
    Sdk.TrackGameEvent("custom_loss", "resource_update_begin", "1")
    CSCoroutine.Start(function()
        GameVersionList.StartUpdate(localVersionList, remoteVersionList)
    end)
    CSCoroutine.Start(function()
        self:updateResProgress()
    end)
end

function HUpdator:updateResProgress()
    local progress = 0
    local progress1 = 0
    local progress2 = 0
    local tip = LoadingTip.Get("updating")
    HULoading:setProgress(0)
    HULoading.updateTip.text = tip.." 1%"
    HULoading.updateTip.visible = true
    local show
    local isWhiteDevice = Auth.IsWhiteDevice()
    local reported = {}
    while true do
        if GameVersionList.totalCount > 0 then
            progress1 = GameVersionList.finishedSize / GameVersionList.totalSize
            progress2 = GameVersionList.finishedCount / GameVersionList.totalCount
            HULoading:setProgress(math.min(math.max(progress1, progress2), 1.0))
            progress = progress2
            if isWhiteDevice then
                show = HUpdator:formatSize(GameVersionList.finishedSize, GameVersionList.totalSize)
            else
                show = math.floor(progress*100).."%"
            end
            HULoading.updateTip.text = string.format("%s %s", tip, show)
            self:reportProgress(reported, progress1)
            if progress >= 1 then
                self:finishHotUpdate()
                break
            end
        elseif GameVersionList.totalCount == 0 then
            self:gotoGame()
            break
        end
        coroutine.yield(UnityEngine.WaitForSeconds(0.1))
    end
end

-- 每百分之十汇报一次
function HUpdator:reportProgress(reported, progress)
    local percent = math.floor(progress * 10) * 10
    if percent > 100 then
        return
    end
    if reported[percent] then
        return
    end
    if percent % 10 ~= 0 then
        return
    end
    reported[percent] = true
    local event = string.format("resource_update_%dper", percent)
    Sdk.TrackGameEvent("custom_loss", event, "1")
end

function HUpdator:formatSize(download, total)
    local value -- 大小
    local unit -- 单位
    if total > 1024 * 1024 then
        total = total / (1024 * 1024)
        download = download / (1024 * 1024)
        unit = "M"
    elseif total > 1024 then
        total = total / 1024
        download = download / 1024
        unit = "K"
    else
        unit = "B"
    end
    return string.format("%.2f%s/%.2f%s", download, unit, total, unit)
end

function HUpdator:transferResProgress()
    Log.Error("HUpdator.transferResProgress")
    local progress
    HULoading:setProgress(0)
    --print("-11111111111")
    --HULoading.updateTip.text = "1%"
    --print("-222222222222")
    --HULoading.updateTip.visible = true
    print("-11111111111333", PlayerDataModel.GetLocalData("PRE_UPDATE_COUNT"))
    print("-11111111111444", JSON.decode(PlayerDataModel.GetLocalData("PRE_UPDATE_COUNT")))
    GameVersionList.VersionListSize = tonumber(JSON.decode(PlayerDataModel.GetLocalData("PRE_UPDATE_COUNT")))
    print("GameVersionList.VersionListSize", GameVersionList.VersionListSize)
    local reported = 0
    while true do
        progress = GameVersionList.Transfered / GameVersionList.VersionListSize
        --HULoading.updateTip.text = ""..math.floor(progress*100).."%"
        HULoading:setProgress(progress)
        if progress >= 0.3 and reported == 0 then
            reported = 1
            Sdk.TrackGameEvent("custom_loss", "resource_decompression1_30per", "1")
        elseif progress >= 0.6 and reported == 1 then
            Sdk.TrackGameEvent("custom_loss", "resource_decompression1_60per", "1")
            reported = 2
        elseif progress >= 1.0 then
            self:finishHotUpdate()
            break
        end
        coroutine.yield(UnityEngine.WaitForSeconds(0.1))
    end
end

-- 进入游戏
function HUpdator:gotoGame()
    HULoading.SetLoadingTip("init_game")
    -- 设置文件搜索策略
    ResMgr.SetFileSearchStrategy()
    -- 进入游戏
    Sdk.TrackGameEvent("custom_loss", "prepare_first_launch_begin", "1") -- 打点
    HULoading:setProgress(1)
    CS.KSFramework.Main.Instance:GotoGame()
    Sdk.TrackGameEvent("custom_loss", "prepare_first_launch_end", "1") -- 打点
    GRoot.inst:RemoveChild(self.loadingUI)
    HULoading.loadingUI:Dispose()
    HULoading.loadingUI = nil
end

function HUpdator:finishHotUpdate()
    GmModel.EndGm()
    HULoading:setProgress(1)
    CS.KSFramework.SdkModel.IsReLogin = true
    CS.KSFramework.Main.Instance:FinishHotUpdate()
end

function HUpdator:PreUpdateCheckMainVersion()
    -- 检测是否需要转移资源
    if not ResMgr.IsReadDirect() then
        if Util.DeleteDir then
            Log.Error("GameVersion.CheckDelOldRes")
            GameVersion.CheckDelOldRes()
        end
        --print("PRE_UPDATE_FINISHED-------", PlayerDataModel.GetLocalData("PRE_UPDATE_FINISHED"))
        if PlayerDataModel.GetLocalData("PRE_UPDATE_FINISHED") ~= "" then
            local finished = JSON.decode(PlayerDataModel.GetLocalData("PRE_UPDATE_FINISHED"))
            if finished == "true" then
                Log.Error("GameVersion.NeedTransfer")
                --if GameVersion.NeedTransfer() then
                Sdk.TrackGameEvent("custom_loss", "pre_resource_decompression1_begin", "1")
                CSCoroutine.Start(function()
                    self:transferResProgress()
                end)
                GameVersionList.TransferPreHotUpdateFiles()
                Sdk.TrackGameEvent("custom_loss", "pre_resource_decompression1_end", "1")
                --end
            end
        end
    end

    -- 检测是否需要热更新
    Sdk.TrackGameEvent("custom_loss", "pre_check_update_begin", "1") -- 打点
    local localVersion = GameVersion.GetLocalVersion()
    local pkgVersion = GameVersion.GetInAppVersion()
    Sdk.LocalVersion = localVersion.String
    if Sdk.PkgVersion == "" then
        Sdk.PkgVersion = pkgVersion.String
    end
    local req = UnityWebRequest.Get(GameVersion.VersionFileUrl())
    coroutine.yield(req:SendWebRequest())

    if req.isNetworkError or req.isHttpError then
        Log.Error("Get remote version failed: {0} {1}", GameVersion.VersionFileUrl(), req.error);
        coroutine.yield(UnityEngine.WaitForSeconds(1))
        coroutine.yield(self:PreUpdateCheckMainVersion())
        return
    end

    local version = req.downloadHandler.text
    local remoteVersion = GameVersion.New(version)

    GameVersion.localV = localVersion.String
    GameVersion.remote = remoteVersion.String
    CS.KSFramework.Main.Instance:SetData("remote", remoteVersion.String)

    Log.Info("remoteVersion: {0}, localVersion: {1}", remoteVersion.String, localVersion.String)
    Sdk.TrackGameEvent("custom_loss", "pre_check_update_end", "1")

    local result = localVersion:Compare(remoteVersion)
    Log.Info("HotUpdate compare: {0}", result)
    if result == "UpdateApp" then
    elseif result == "UpdateRes" then
        CSCoroutine.Start(function()
            self:gotoDownPreUpdateRes()
        end)
    elseif result == "Past" then
    end
end

-- 更新资源
function HUpdator:gotoDownPreUpdateRes()
    Log.Error("CheckUpdate: gotoDownPreUpdateRes")
    Sdk.TrackGameEvent("custom_loss", "pre_download_version_list", "1")
    local req = UnityWebRequest.Get(GameVersion.VersionListUrl())
    coroutine.yield(req:SendWebRequest())
    if req.isHttpError or req.isNetworkError then
        Log.Error("Get remote version list failed: {0} {1}", GameVersion.VersionListUrl(), req.error);
        coroutine.yield(UnityEngine.WaitForSeconds(1))
        coroutine.yield(self:gotoDownPreUpdateRes())
        return
    end
    Sdk.TrackGameEvent("custom_loss", "pre_parse_version_list", "1")
    local content = Util.Unzip(req.downloadHandler.data)
    local remoteVersionList = GameVersionList.New(content)
    local localVersionList = GameVersionList.GetLocalVersionList()
    Sdk.TrackGameEvent("custom_loss", "pre_resource_update_begin", "1")
    GameVersionList.StartDownPreUpdate(localVersionList, remoteVersionList)
end

return HUpdator