--[[
    Author: Baggio-Wang
    Function: UI管理器
    Date: 2019-12-26 20:45:36
]]
local UIMgr = {}
local CreateUIs = {}
local OpenUIs = {}
local MutexUIs = {}
local WindowCount = 0

local loaded = {} -- map

local popPanels = {} -- list
local showPopupMaps = {} -- map

local showPanelMaps = {}
local showPanelList = {} -- list

local _isPlayAudio = true
local showMapName = ""

local delayDisposeBundle = {}

local delayDisposeRes = {}
local GlobalVars = GlobalVars

FUIType = {
    Panel_Map = 0, -- 底层（地图层）
    Panel_Fix = 1, -- 固定UI
    Panel_Pop = 2, -- 弹出UI面板
    Panel_Top = 3, -- 顶层UI面板
    Panel_Tip = 4 -- 顶层UI面板
}

local BaseUI = import("Common/BaseUI")
local BuildQueueModel = import("Model/CityMap/BuildQueueModel")
local GD = _G.GD

function UIMgr.Init()
     Scheduler.Schedule(UIMgr.DisposeBundle, 60, true, 1)
end

local SkipPkgs = {
    Loading = true,
    MainCity = true,
    WorldCity = true,
    City = true,
    CityBg = true,
    Chat = true,
    Build = true,
    Common = true,
    Icon = true,
    Number = true,
    IconQueue = true,
    IconCharacter = true,
    Effect = true,
    IconArm = true,
    IconMap = true,
    Novice = true,
    NoviceImage = true,
    IconActivity = true,
    IconFactory = true
}
local SkipUIs = {
    GuideCanvas = true,
    City = true,
    Mask = true,
    WorldCity = true,
    MainUIPanel = true,
    ToolTip = true,
    MainUICloud = true
}
local ExpireDuration = 60 -- 秒

function UIMgr.DelayCollect(delayTime)
    for k, v in pairs(delayDisposeRes) do
        local openAt = delayDisposeRes[k] + delayTime
        if openAt > os.time() then
            openAt = os.time()
        end
        delayDisposeRes[k] = openAt
    end
end

function UIMgr.AddDelayDisposeBundle(name)
    delayDisposeBundle[name] = os.time()
    --Log.Warning("AddDelayDisposeBundle: {0} ,  {1} ", name,delayDisposeBundle[name])
end

function UIMgr.removeDelayDisposeBundle(name)
    delayDisposeBundle[name] = nil
    --Log.Warning("AddDelayDisposeBundle: {0} ,  {1} ", name,delayDisposeBundle[name])
end

function UIMgr.DisposeBundle()
    for k, v in pairs(delayDisposeBundle) do
        local startAt = delayDisposeBundle[k]
        if startAt and os.time() - startAt >= ExpireDuration then
            --Log.Warning("DisposeBundle: {0} ,  {1} ", k,delayDisposeBundle[k])
            ResMgr.Instance:UnLoadCacheBundles(DynamicRes.GetRealDicKeyName(k))
            delayDisposeBundle[k] = nil
        end
    end
end

function UIMgr.Collect()
    local expires = {}
    local inUsePkgs = {}
    for k, v in pairs(OpenUIs) do
        local uiInfo = ConfigMgr.GetItem("configUIs", k)
        if v or SkipUIs[k] then
            delayDisposeRes[k] = nil
            inUsePkgs[uiInfo.pkg] = k
        else
            local openAt = delayDisposeRes[k]
            if openAt and os.time() - openAt >= ExpireDuration then
                expires[k] = uiInfo.pkg
            else
                inUsePkgs[uiInfo.pkg] = k
            end
        end
    end
    for k, pkg in pairs(expires) do
        UIMgr:Dispose(k)
        if not inUsePkgs[pkg] and not SkipPkgs[pkg] and loaded[string.lower(pkg)] then
            UIMgr:RemovePackage(pkg)
        end
        delayDisposeRes[k] = nil
    end
end
local NotLoadPack = {
    ["backpack"]         = true,
    ["casino"]           = true,
    ["chat"]             = true,
    ["effect"]           = true,
    ["iconactivity"]     = true,
    ["iconbeautysystem"] = true,
    ["iconflag"]         = true,
    ["iconqueue"]        = true,
    ["iconresearch"]     = true,
    ["vip"]              = true,
    ["setup"]            = true,
    ["iconmail"]         = true,
    ["iconmap"]          = true,
    ["number"]           = true,
    ["playerdetail"]     = true,
    ["mail"]             = true,
    ["confirmpopup"]     = true,
    ["gm"]               = true,
    ["monster"]          = true,
}

function UIMgr:AddPackage(pkg)
    local pkgName = string.lower(pkg)
    if loaded[pkgName] then
        return
    end
    if ResMgr.IsReadDirect() then
        UIPackage.AddPackage("Assets/BundleResources/UI/" .. pkg)
    else
        local descBundleName = ("ui/%s_fui"):format(pkgName)
        local resBundleName = ("ui/%s_atlas"):format(pkgName)
        local descBundle = ResMgr.Instance:LoadBundleSync(descBundleName)
        -- 下面的包的纹理不需要加载
        if NotLoadPack[pkgName] then
            UIPackage.AddPackage(descBundle)
        else
            local resBundle = ResMgr.Instance:LoadBundleSync(resBundleName)
            UIPackage.AddPackage(descBundle, resBundle)
        end
    end
    loaded[pkgName] = true
end

function UIMgr:ReOpen(name, args)
    self:Close(name)
    self:Open(name, args)
end

--检查是否有Pop界面打开
function UIMgr:CheckOpen(flag, name)
    if flag then
        if UIMgr:GetShowPopPanelCount() == 0 then
            if self.check_func then
                Scheduler.UnSchedule(self.check_func)
            end
            self.check_func = function()
                if UIMgr:GetShowPopPanelCount() > 0 then
                    Event.Broadcast(EventDefines.UIMainShow, false)
                    Scheduler.UnSchedule(self.check_func)
                end
            end
            Scheduler.Schedule(self.check_func, 1)
        else
            Event.Broadcast(EventDefines.UIMainShow, false)
        end
    else
        if UIMgr:GetShowPopPanelCount() == 0 and name ~= "ToolTip" and name ~= "MainUICloud" then
            Event.Broadcast(EventDefines.UIMainShow, true)
            if GlobalVars.IsInCity then
                ScrollModel.Scale(nil, true)
            else --特殊处理避免大地图打开遮罩
                Event.Broadcast(EventDefines.CityMask, false)
            end
            --检测是否可以弹窗
            PopupWindowQueue:CheckPop()
        end
    end
    --建筑队列是否空闲检测
    BuildQueueModel.CheckIdle()
end

--检查是否播放界面动画
function UIMgr:CheckAnim(isOpen, uiInfo, name, cb)
    local anim = uiInfo.anim
    if isOpen then
        --打开界面
        if anim == 0 then
            return
        end
        local ctx = self:GetUI(name)
        if ctx then
            if anim == 1 then
                --缩放动画
                AnimationLayer.PanelScaleOpenAnim(ctx)
            elseif anim == 2 then
                --左右切换
                local panel = UIMgr:GetPreviousPanel()
                if panel then
                    local uiName = UIMgr:GetUIName(panel.key)
                    local panelCtx = self:GetUI(uiName)
                    if panelCtx then
                        AnimationLayer.PanelAnim(AnimationType.PanelMovePreLeft, panelCtx)
                    end
                    AnimationLayer.PanelAnim(AnimationType.PanelMoveLeft, ctx)
                end
            end
        end
    else
        --关闭界面
        local function close_func()
            UIMgr:CloseWindow(uiInfo.pkg, name)
            if cb then
                cb()
            end
            self:CheckOpen(false, name)
        end
        if anim == 0 then
            close_func()
            return
        end
        local ctx = self:GetUI(name)
        if ctx and ctx.visible and ctx.Controller.contentPane.visible then
            if anim == 1 then
                --缩放动画
                AnimationLayer.PanelScaleCloseAnim(ctx, close_func)
            elseif anim == 2 then
                --左右切换
                local panel = UIMgr:GetPreviousPanel()
                if panel then
                    local uiName = UIMgr:GetUIName(panel.key)
                    local panelCtx = self:GetUI(uiName)
                    if panelCtx then
                        AnimationLayer.PanelAnim(AnimationType.PanelMovePreRight, panelCtx)
                    end
                    AnimationLayer.PanelAnim(
                        AnimationType.PanelMoveRight,
                        ctx,
                        false,
                        function()
                            close_func()
                        end
                    )
                else
                    close_func()
                end
            end
        else
            close_func()
        end
    end
end

--检查互斥界面
function UIMgr:CheckMutex(isOpen, name, uiInfo)
    local mutex = uiInfo.mutex
    if not mutex then
        return
    end
    if isOpen then
        --打开界面
        if MutexUIs[mutex] then
            return true
        end
        MutexUIs[mutex] = name
        Scheduler.ScheduleOnce(
            function()
                MutexUIs[mutex] = nil
            end,
            1
        )
        return
    else
        --关闭界面
        if MutexUIs[mutex] == name then
            MutexUIs[mutex] = nil
        end
    end
end

-- 打开界面 自定义弹窗 自定义是否播放音效 自定义是否全屏显示 自定义隐藏上一个界面
function UIMgr:OpenWindow(uiType, isPlayAudio, isFullScreen, isHideLast, pkg, uiName, ...)
    _isPlayAudio = isPlayAudio
    local pkgName = string.lower(pkg)
    if loaded[pkgName] == nil then
        UIMgr:LoadRes(uiType, isFullScreen, isHideLast, pkg, uiName, ...)
    else
        UIMgr:ShowPanel(uiType, isFullScreen, isHideLast, pkg, uiName, ...)
    end
end

function UIMgr:LoadRes(uiType, isFullScreen, isHideLast, pkg, uiName, ...)
    UIMgr:AddPackage(pkg)
    UIMgr:ShowPanel(uiType, isFullScreen, isHideLast, pkg, uiName, ...)
end

function UIMgr:ShowPanel(uiType, isFullScreen, isHideLast, pkg, uiName, ...)
    local key = UIMgr:uiKey(pkg, uiName)
    if uiType == FUIType.Panel_Pop and #popPanels > 0 and popPanels[#popPanels].key == key then
        return
    end

    local windows = UIMgr:GetPanelMap(uiType)
    local win
    if windows[key] then
        win = windows[key]
        win:SetArgs(...)
    else
        if uiType == FUIType.Panel_Top then
            local bg = UIMgr:CreateObject("Loading", "PopPanelBg")
            bg:MakeFullScreen()
            -- bg.SetHome(GRoot.inst);
            GRoot.inst:AddChild(bg)
            win = FUIController(isFullScreen, pkg, uiName, ...)
            win.BgUI = bg
        else
            win = FUIController(isFullScreen, pkg, uiName, ...)
        end

        win.uiType = uiType
        win.key = key
        windows[key] = win
        GRoot.inst:InvalidateBatchingState(true)
    end

    if uiType == FUIType.Panel_Top then
        -- win.BgUI.visible = true;
        GRoot.inst:AddChild(win.BgUI)
        win.BgUI.sortingOrder = uiType
    end

    if uiType == FUIType.Panel_Top or uiType == FUIType.Panel_Pop then
        table.insert(showPanelList, win)
    end

    if uiType == FUIType.Panel_Pop then
        if #popPanels > 0 and isHideLast then
            if CreateUIs[popPanels[#popPanels]._uiName] and CreateUIs[popPanels[#popPanels]._uiName].OnHide then
                CreateUIs[popPanels[#popPanels]._uiName]:OnHide()
            end
            popPanels[#popPanels].visible = false
        end
        win.visible = true
        table.insert(popPanels, win)
    end

    win:Show()
    if _isPlayAudio then
        AudioManager:PlayClip("common_ui_open", 1000, false)
    end
end

-- 获取上一个面板
function UIMgr:GetPreviousPanel()
    if #popPanels > 1 then
        return popPanels[#popPanels - 1]
    end
end

function UIMgr:Open(name, ...)
    Log.Debug("UIMgr:Open ui: {0}", name)
    local uiInfo = ConfigMgr.GetItem("configUIs", name)
    if not uiInfo then
        Log.Warning("ui not exist: {0}", name)
        return
    end
    --检测如果开启过改界面直接return不再开启
    if OpenUIs[name] then
        Log.Warning("连续打开两次界面，直接return")
        return
    end
    -----------

    if name ~= "ToolTip" then
        Event.Broadcast(EventDefines.UICloseMapDetail)
    end

    if self:CheckMutex(true, name, uiInfo) then
        return
    end
    OpenUIs[name] = true
    delayDisposeRes[name] = nil
    if Tool.Equal(uiInfo.type, FUIType.Panel_Pop, FUIType.Panel_Top) then
        WindowCount = WindowCount + 1
    end
    UIMgr:OpenWindow(uiInfo.type, uiInfo.isPlayAudio, uiInfo.isFull or false, uiInfo.isHideLast, uiInfo.pkg, name, ...)
    self:CheckOpen(true, name)
    self:CheckAnim(true, uiInfo, name)
end

function UIMgr:OpenWithPkg(pkg, name, ...)
    local uiInfo = ConfigMgr.GetItem("configUIs", name)
    if not uiInfo then
        Log.Warning("ui not exist: {0}->{1}", pkg, name)
        return
    end
    OpenUIs[name] = true
    delayDisposeRes[name] = nil
    if Tool.Equal(uiInfo.type, FUIType.Panel_Pop, FUIType.Panel_Top) then
        WindowCount = WindowCount + 1
    end
    UIMgr:OpenWindow(uiInfo.type, uiInfo.isPlayAudio, uiInfo.isFull or false, false, pkg, name, ...)
    self:CheckAnim(true, uiInfo, name)
end

function UIMgr:OpenHideLastFalse(name, ...)
    local uiInfo = ConfigMgr.GetItem("configUIs", name)
    if not uiInfo then
        Log.Warning("ui not exist: {0}", name)
        return
    end
    OpenUIs[name] = true
    delayDisposeRes[name] = nil
    if Tool.Equal(uiInfo.type, FUIType.Panel_Pop, FUIType.Panel_Top) then
        WindowCount = WindowCount + 1
    end
    UIMgr:OpenWindow(uiInfo.type, uiInfo.isPlayAudio, uiInfo.isFull or false, false, uiInfo.pkg, name, ...)
    self:CheckAnim(true, uiInfo, name)
end

local allPanelCloseWaitTime = 1
local willDoTrigger = false
local function PanelCloseFunc()
    -- 判断有没有打开 2，3级界面，没有打开的话则触发引导，如果打开了其他界面，那么引导暂存
    if willDoTrigger == true then
        willDoTrigger = false
        if GlobalVars.NowTriggerId == 0 then
            Event.Broadcast(EventDefines.GuideMask, false)
            if UIMgr:GetShowPopPanelCount() == 0 and WindowCount == 0 then
                Event.Broadcast(EventDefines.TriggerAllPanelClose)
            end
        end
    else
        GlobalVars.IsAllowPopWindow = true
        Event.Broadcast(EventDefines.GuideMask, false)
        --当页面只有MainUIPanel的时候，且玩家等级<=4级，且MainUIPanel处于第一页面，播放在线奖励特效
        if Model.Player and UIMgr:GetShowPopPanelCount() == 0 and WindowCount == 0 and Model.Player.Level <= Global.UnlockLevelBase4 then
            Event.Broadcast(EventDefines.PlayOnlineEffect)
        end
        if UIMgr:GetShowPopPanelCount() == 0 and WindowCount == 0 and GlobalVars.IsOpenSingleScoreTips then
            UIMgr:Open("SingleActivityGetRewardTips")
        end
        --建筑队列是否空闲检测
        BuildQueueModel.CheckIdle()
    end
end

function UIMgr:Close(name, cb)
    Log.Debug("UIMgr:Close ui: {0}", name)
    local uiInfo = ConfigMgr.GetItem("configUIs", name)
    if not uiInfo then
        return
    end
    if OpenUIs[name] == true then
        OpenUIs[name] = false
        delayDisposeRes[name] = os.time()
        if Tool.Equal(uiInfo.type, FUIType.Panel_Pop, FUIType.Panel_Top) then
            WindowCount = WindowCount - 1
        end
        self:CheckAnim(false, uiInfo, name, cb)
        self:CheckMutex(false, name, uiInfo)
        if GlobalVars.NowTriggerId == 0 then --当前没有正在触发的引导并且判断有存储还未触发完毕的引导，如果存在，那么开启遮罩，屏蔽弹窗，进入触发引导流程
            if GlobalVars.IsInCityTrigger == true and GD.TriggerGuideAgent.CityHaveStashTriggerJudge() == true then
                GlobalVars.IsAllowPopWindow = false
                willDoTrigger = true
                Event.Broadcast(EventDefines.GuideMask, true)
            elseif GlobalVars.IsInCityTrigger == false and GD.TriggerGuideAgent.WorldHaveStashTriggerJudge() == true then
                GlobalVars.IsAllowPopWindow = false
                willDoTrigger = true
                Event.Broadcast(EventDefines.GuideMask, true)
            end
        else
            GlobalVars.IsAllowPopWindow = false
            willDoTrigger = true
        end
        Scheduler.UnScheduleFast(PanelCloseFunc)
        Scheduler.ScheduleOnceFast(PanelCloseFunc, allPanelCloseWaitTime)
    end
end

function UIMgr:GetWindowCount()
    return WindowCount
end

--关闭Pop和Top层的UI ------------------------------------
function UIMgr:ClosePopAndTopPanel()
    UIMgr:ClosePanelsByFUIType(FUIType.Panel_Pop)
    UIMgr:ClosePanelsByFUIType(FUIType.Panel_Top)
    MutexUIs = {}
    self:CheckOpen(false)

    if CityType.BUILD_MOVE_TIP then
        Event.Broadcast(EventDefines.UICityBuildMove, BuildType.MOVE.Reset)
    end
end

function UIMgr:ClosePanelsByFUIType(uiType)
    local windows = showPanelMaps[uiType]
    if not windows then
        return
    end
    if uiType == FUIType.Panel_Pop then
        UIMgr:CloseAllPopPanel()
        return
    end
    for _, win in pairs(windows) do
        for j, panel in ipairs(showPanelList) do
            if win.key == panel.key then
                UIMgr:Close(UIMgr:GetUIName(showPanelList[j].key))
            end
        end
        win:Hide()
    end
end

----------------手势相关-----------------

local LongPressGestureList = {}

function UIMgr:GetLongPressGesture(obj)
    local gesture = LongPressGesture(obj)
    table.insert(LongPressGestureList, gesture)
    return gesture
end

-----------------------------------------

--- 释放资源处理
function UIMgr:Dispose(name)
    local uiInfo = ConfigMgr.GetItem("configUIs", name)
    if not uiInfo then
        return
    end
    CreateUIs[name] = nil
    UIMgr:DisposeWindow(uiInfo.pkg, name)
end

function UIMgr:DisposeWindow(pkg, uiName)
    local key = UIMgr:uiKey(pkg, uiName)
    for _, uiType in pairs(FUIType) do
        local windows = showPanelMaps[uiType]
        if windows and windows[key] then
            if uiType == FUIType.Panel_Pop then -- 弹出面板先在链表中找到再关闭
                UIMgr:ClosePopPanel(windows[key])
            else
                windows[key]:Hide()
            end
            if windows[key] then
                windows[key]:Dispose()
            end
            windows[key] = nil
            break
        end
    end
end

function UIMgr:DisposeAll()
    local needDispose = {}
    for _, uiType in pairs(FUIType) do
        local windows = showPanelMaps[uiType]
        if windows then
            for _, win in pairs(windows) do
                win:Hide()
                table.insert(needDispose, win)
            end
        end
    end
    for _, obj in pairs(showPopupMaps) do
        GRoot.inst:HidePopup(obj)
        table.insert(needDispose, obj)
    end
    for _, obj in ipairs(needDispose) do
        if obj then
            obj:Dispose()
        end
    end
    showPanelMaps = {}
    popPanels = {}
    showPopupMaps = {}
    _isPlayAudio = true

    for _, v in ipairs(LongPressGestureList) do
        v:Dispose()
    end
end

function UIMgr:CloseAllPopPanel()
    for i = #popPanels, 1, -1 do
        UIMgr:Close(UIMgr:GetUIName(popPanels[i].key))
    end
end

function UIMgr:GetPanelMap(uiType)
    if showPanelMaps[uiType] == nil then
        showPanelMaps[uiType] = {}
    end
    return showPanelMaps[uiType]
end

function UIMgr:RemovePanel(panels, key)
    for i, v in ipairs(panels) do
        if v.key == key then
            table.remove(panels, i)
            break
        end
    end
end

--如果要取UI界面的实体对象，用这个方法
function UIMgr:GetUI(name)
    return CreateUIs[name]
end

--如果只是单纯想判断UI界面的开启关闭状态，用这个方法
function UIMgr:GetUIOpen(name)
    return OpenUIs[name]
end

function UIMgr:uiKey(pkg, uiName)
    local pkgName = string.lower(pkg)
    return pkgName .. ":" .. uiName
end

function UIMgr:GetUIName(key)
    return UIMgr:Split(key, ":")[2]
end

function UIMgr:RemovePackage(pkg)
    local pkgName = string.lower(pkg)
    if loaded[pkgName] then
        UIPackage.RemovePackage(pkg)
        loaded[pkgName] = nil
    else
        Log.Warning("===== NOT Package =========== " .. pkgName)
    end
end

function UIMgr:ShowPopup(pkg, uiName, ctr, downward)
    local key = UIMgr:uiKey(pkg, uiName)
    local obj
    if showPopupMaps[key] == nil then
        obj = UIMgr:CreateObject(pkg, uiName)
        showPopupMaps[key] = obj
    else
        obj = showPopupMaps[key]
    end
    GRoot.inst:ShowPopup(obj, ctr, downward)
    return obj
end

function UIMgr:HidePopup(pkg, uiName)
    local key = UIMgr:uiKey(pkg, uiName)
    local obj = showPopupMaps[key]
    if obj then
        GRoot.inst:HidePopup(obj)
    end
end

function UIMgr:CreatePopup(pkg, uiName)
    local key = UIMgr:uiKey(pkg, uiName)
    local obj
    if showPopupMaps[key] == nil then
        obj = UIMgr:CreateObject(pkg, uiName)
        showPopupMaps[key] = obj
    else
        obj = showPopupMaps[key]
    end
    return obj
end

function UIMgr:GetPopupUIByKey(pkg, uiName)
    local key = UIMgr:uiKey(pkg, uiName)
    if showPopupMaps[key] then
        return showPopupMaps[key]
    else
        return nil
    end
end

-- 关闭界面
function UIMgr:CloseWindow(pkg, uiName)
    if uiName == nil then
        UIMgr:DoClose(pkg)
        return
    end

    local key = UIMgr:uiKey(pkg, uiName)
    for i, panel in ipairs(showPanelList) do
        if key == panel.key then
            table.remove(showPanelList, i)
            break
        end
    end
    UIMgr:DoClose(key)
end

function UIMgr:CloseTop()
    -- close pop first
    for k, v in pairs(showPopupMaps or {}) do
        GRoot.inst:HidePopup(v)
    end
    if #showPanelList > 0 then
        local key = showPanelList[#showPanelList].key
        local name = UIMgr:GetUIName(key)
        local panel = UIMgr:GetUI(name)
        if panel then
            if panel.IgnoreClose then
                return
            end
        end

        table.remove(showPanelList, #showPanelList)
        Event.Broadcast(EventDefines.UIClosingSoon)
        UIMgr:Close(name)
    else
        Log.Error("======= showPanelList Count is null ==============")
    end
end

function UIMgr:GetShowPanelCount()
    return #showPanelList
end

function UIMgr:GetShowPopPanelCount()
    return #popPanels
end

function UIMgr:GetShowMapName()
    return showMapName
end

function UIMgr:GetTopPanel()
    return showPanelList[#showPanelList]
end

function UIMgr:CanDropMap()
    for _, uiType in pairs(FUIType) do
        if uiType < FUIType.Panel_Pop or uiType > FUIType.Panel_Top then
            goto next
        end
        if showPanelMaps[uiType] == nil then
            goto next
        end
        local windows = showPanelMaps[uiType]
        for _, win in pairs(windows) do
            if win.isShowing then
                return false
            end
        end
        ::next::
    end
    return true
end

function UIMgr:DoClose(key)
    for _, uiType in pairs(FUIType) do
        local windows = showPanelMaps[uiType]
        if windows and windows[key] then
            if uiType == FUIType.Panel_Pop then -- 弹出面板先在链表中找到再关闭
                UIMgr:ClosePopPanel(windows[key])
            else
                windows[key]:Hide()
                if uiType == FUIType.Panel_Top then
                    AudioManager:PlayClip("common_sencondui_quit", 1000, false)
                end
            end
            break
        end
    end
end

--Pop界面释放处理
function UIMgr:DisposePopPanel(win)
    local contain, idx = UIMgr:ContainPanel(popPanels, win.key)
    if not contain then
        return
    end

    win:Hide()
    if win then
        win:Dispose()
    end
    UIMgr:RemovePanel(popPanels, win.key)
    if #popPanels > 0 then
        popPanels[#popPanels].visible = true
    end
end

function UIMgr:ClosePopPanel(win)
    local contain, idx = UIMgr:ContainPanel(popPanels, win.key)
    if contain then
        table.remove(popPanels, idx)
        if #popPanels > 0 then
            popPanels[#popPanels].visible = true
        end
        win:Hide()
        AudioManager:PlayClip("common_mainui_quit", 1000, false)
    end
end

function UIMgr:ContainPanel(panels, key)
    local contain = false
    local idx = 0
    for i, v in ipairs(panels) do
        if v.key == key then
            idx = i
            contain = true
            break
        end
    end
    return contain, idx
end

local _objectList = {}
local index = 1
function UIMgr:CreateObject(pkg, name)
    local key = pkg .. name .. index
    index = index + 1
    local obj = UIPackage.CreateObject(pkg, name)
    _objectList[key] = obj
    return obj
end

function UIMgr:DisposeObject()
    for k, obj in pairs(_objectList) do
        obj:Dispose()
        _objectList[k] = nil
    end
end

function UIMgr:Split(str, reps)
    local resultStrList = {}
    string.gsub(
        str,
        "[^" .. reps .. "]+",
        function(w)
            table.insert(resultStrList, w)
        end
    )
    return resultStrList
end

function UIMgr:IsOtherUIOpen(oterUINames)
    for _, v in pairs(oterUINames) do
        if OpenUIs[v] then
            return true
        end
    end
    return false
end

function UIMgr:NewUI(name)
    local ui = class(BaseUI)
    ui.name = name
    ui.New = function(controller)
        local ins = new(ui)
        ins.Controller = controller
        CreateUIs[name] = ins
        return ins
    end
    return ui
end

return UIMgr
