local GameUpdate = {
    _slowLast = 0,
    m_slowList = {},
    m_updateList = {},
    m_lateUpdateList = {},
    m_fixedUpdateList = {},
    isOpen = true,
}

local _ins

local GlobalVars = GlobalVars
local OnlineTime = 0

-- 每10帧更新一次
local _slowUpdateFrames = 10

function GameUpdate.Inst()
    return _ins
end

function GameUpdate.Create()
    LuaBehaviour.AddLuaComponent(KSGame.Instance.gameObject, "Behaviour/GameUpdate")
end

-- Behaviour creator
function GameUpdate.New(controller)
    _ins = new(GameUpdate)
    _ins.controller = controller
    return _ins
end

-- API
function GameUpdate:AddSlowUpdate(cb)
    self.m_slowList[cb] = true
end
function GameUpdate:DelSlowUpdate(cb)
    self.m_slowList[cb] = nil
end

function GameUpdate:AddUpdate(cb)
    self.m_updateList[cb] = true
end
function GameUpdate:DelUpdate(cb)
    self.m_updateList[cb] = nil
end

function GameUpdate:AddLateUpdate(cb)
    self.m_lateUpdateList[cb] = true
end
function GameUpdate:DelLateUpdate(cb)
    self.m_lateUpdateList[cb] = nil
end

function GameUpdate:AddFixedUpdate(cb)
    self.m_fixedUpdateList[cb] = true
end
function GameUpdate:DelFixedUpdate(cb)
    self.m_fixedUpdateList[cb] = nil
end

-- MonoBehaviour
local now, dt
function GameUpdate:Awake()
end

function GameUpdate:Start()
    self._slowLast = Time.fixedTime
end

function GameUpdate:Update()
    if not self.isOpen then
        return
    end
    dt = Time.deltaTime
    OnlineTime = OnlineTime + dt
    for k,v in pairs(self.m_updateList) do k(dt) end
    if Time.frameCount % _slowUpdateFrames == 0 then
        now = Time.fixedTime
        for s,v in pairs(self.m_slowList) do s(now - self._slowLast) end
        self._slowLast = now
    end
end

--前后台切换时调用
function GameUpdate:OnApplicationFocus(isFocused)
    if isFocused then
        Stage.inst.focus = nil
        Tool.SyncTime()
    end
end

--游戏后台暂停前调用
function GameUpdate:OnApplicationPause(pauseStatus)
    if pauseStatus then
        --后台(挂起)
        SdkModel.ReportEvent("online_time", "", math.floor(OnlineTime))
        --if GlobalVars.IsNoviceGuideStatus then
        --    Network.Stop()
        --end
        NotifyModel.StartNotify()
        CustomInput.Close()
        Event.Broadcast(EventDefines.GameOutFocus)
    else
        if GlobalVars.IsNoviceGuideStatus then
            Network.Relogin()
        end
        --前台(游戏)
        OnlineTime = 0
        Tool.SyncTime()
        Event.Broadcast(EventDefines.GameOnFocus)
        NotifyModel.ClearNotify()
    end
end

-- 返回回调
function GameUpdate:KeyEscape()
    print("==========KeyEscape===========")
    -- 新手引导和触发引导状态不允许使用返回键
    if Network.IsConnect() then     --重连是不能返回
        return
    end
    if GlobalVars.IsNoviceGuideStatus == true or GlobalVars.IsTriggerStatus == true then
        return
    end
    if ScrollModel.GetScaling() then
        return
    end
    if UIMgr:GetShowPanelCount() > 0 then
        UIMgr:CloseTop()
        UIMgr:CheckOpen(false)
    else
        local data = {
            textTitle = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
            textContent = StringUtil.GetI18n(I18nType.Commmon, "ALERT_QUIT_GAME"),
            textBtnLeft = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES"),
            textBtnRight = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_NO"),
            cbBtnLeft = function()
                FUIUtils.QuitGame()
            end
        }
        UIMgr:Open("ConfirmPopupDouble", data)
    end
end

function GameUpdate:LateUpdate()
    dt = Time.deltaTime
    for k,v in pairs(self.m_lateUpdateList) do k(dt) end
end

function GameUpdate:FixedUpdate()
    dt = Time.fixedDeltaTime
    for k,v in pairs(self.m_fixedUpdateList) do k(dt) end
end

function GameUpdate:OnDestroy()
    Log.Info("GameUpdate OnDestroy!")
end

return GameUpdate
