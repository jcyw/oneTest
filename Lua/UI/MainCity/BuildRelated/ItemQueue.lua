--[[
    Author: songzeming
    Function: 建筑队列Item
]]
local ItemQueue = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/btnBuild", ItemQueue)
local triggerLogic = import("Model/TriggerGuideLogic")
local BuildModel = import("Model/BuildModel")
local UpgradeModel = import("Model/UpgradeModel")
local CommonModel = import("Model/CommonModel")
local EventModel = import("Model/EventModel")
local JumpMapModel = import("Model/JumpMapModel")
local BuildQueueModel = import("Model/CityMap/BuildQueueModel")
--建筑队列控制器
local CTR = {
    FreeIdle = "FreeIdle", --免费队列空闲状态
    FreeFree = "FreeFree", --免费队列免费状态
    FreeBusy = "FreeBusy", --免费队列忙碌状态
    GoldIdle = "GoldIdle", --付费队列空闲状态
    GoldLock = "GoldLock", --付费队列未解锁状态
    GoldFree = "GoldFree", --付费队列免费状态
    GoldBusy = "GoldBusy" --付费队列忙碌状态
}
local ENDSHOWTIME = 2 --金币队列显示结束时间

function ItemQueue:ctor()
    self._ctr = self:GetController("Controller")
    self._freeAnim = self:GetTransition("freeAnim")
    self._goldEffect = self:GetChild("goldEffect")
    self.sortingOrder = 1

    self:AddListener(self.onClick,
        function()
            -- if ScrollModel.GetMoving() then
            --     return
            -- end
            if self.triggerClick and triggerLogic.guideIsBegin then
                self.triggerClick()
            else
                self:OnBtnClick()
            end
        end
    )

    -- self._barTime.visible = true
    self._groupEnd.visible = false
    NodePool.Init(NodePool.KeyType.LockBuildButton, "Effect", "EffectNode")
    NodePool.Init(NodePool.KeyType.BuildButtonFreeEffect, "Effect", "EffectNode")
end

function ItemQueue:Init(type, callback)
    self.type = type
    self.isFree = self.type == BuildType.QUEUE.Free --是否免费队列
    self.callback = callback

    self:SetIdle()
    self:Check()
end

function ItemQueue:PlayFreeEffect(flag)
    self.effectFreePlayFlag = flag
    if flag then
        if self.effectFreePlay then
            self._graph.visible = true
            self._graphTop.visible = true
        else
            self.effectFreePlay = true
            --动态资源加载
            self._graph.xy = Vector2(52, 52)
            self._graphTop.xy = Vector2(52, 55)
            DynamicRes.GetBundle("effect_collect", function()
                DynamicRes.GetPrefab("effect_collect", "effect_free_top", function(prefab)
                    local object = GameObject.Instantiate(prefab)
                    self._graph:SetNativeObject(GoWrapper(object))
                    object.transform.localScale = Vector3(100, 100, 100)
                    self._graph.visible = self.effectFreePlayFlag
                end)
                DynamicRes.GetPrefab("effect_collect", "effect_free_top_light", function(prefab)
                    local object = GameObject.Instantiate(prefab)
                    self._graphTop:SetNativeObject(GoWrapper(object))
                    object.transform.localScale = Vector3(100, 100, 100)
                    self._graphTop.visible = self.effectFreePlayFlag
                end)
            end)
        end
    else
        self._graph.visible = false
        self._graphTop.visible = false
    end
end

function ItemQueue:OnBtnClick()
    if self:GetLock() then
        UIMgr:Open("BuildRelated/QueuePopup", "Queue")
        return
    end
    self:ShowEnd(false)
    CommonType.MAIN_UI_CLICK_JUMP = true
    self.callback(self.type, self:GetBusy())
end

--设置控制器状态
function ItemQueue:SetController(state)
    self._ctr.selectedPage = state
    if state == CTR.FreeFree or state == CTR.GoldFree then
        self._freeAnim:Play(-1, 0, nil)
        self:PlayFreeEffect(true)
    else
        self._freeAnim:Stop()
        self:PlayFreeEffect(false)
    end

    if state == CTR.GoldLock then
        if not self.lockEffect then
            self.lockEffect = NodePool.Get(NodePool.KeyType.LockBuildButton)
            self._goldEffect:AddChildAt(self.lockEffect)
            self.lockEffect:InitNormal()
            self.lockEffect:PlayEffectLoop("effects/mainui/buildqueue/prefab/effect_building_queue",Vector3(200,200,200))
            self.lockEffect.visible = true
        end
    else
        if self.lockEffect then
            self.lockEffect:StopEffect()
            NodePool.Set(NodePool.KeyType.LockBuildButton, self.lockEffect)
            self.lockEffect = nil
        end
    end

    --金锤子特效
    -- if state == CTR.GoldLock or state == CTR.GoldIdle then
    --     self:HammerSweepEffect()
    -- end
end

function ItemQueue:ShowEnd(isInit)
    if self.isFree or self.isShowTip then
        return
    end
    self:HideTip()
    self._groupEnd.visible = not isInit
    --self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_End")
    local expire = Model.Builders[self.type].ExpireAt
    local function get_time()
        return expire - Tool.Time()
    end
    local bar_func = function()
        if not self.isShowTip then
            self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_End") .. "\n" .. Tool.FormatTime(get_time())
        --self._endTime.text = Tool.FormatTime(get_time())
        end
    end
    bar_func()
    local count = 0
    self.end_func = function()
        count = count + 1
        if get_time() >= 0 and count < ENDSHOWTIME then
            bar_func()
            return
        end
        if get_time() < 0 then
            self:HideTip()
            self:SetController(CTR.GoldLock)
        end
        if not self.isShowTip then
            self._groupEnd.visible = false
        end
    end
    self:Schedule(self.end_func, 1)
end
--关闭金锤子提示倒计时
function ItemQueue:HideTip()
    if self.end_func then
        self:UnSchedule(self.end_func)
    end
    self._groupEnd.visible = false
    self.isShowTip = false
end
--长时间未操作提示 每日提示一次
function ItemQueue:ShowTipOnce()
    self.isShowTip = true
    self._groupEnd.visible = true
    self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "TIPS_BUILDING_QUEUE_FREE")
    --self._endTime.text = ""
end

--空闲状态 flag是否空闲
function ItemQueue:SetIdle()
    self:SetController(self.isFree and CTR.FreeIdle or CTR.GoldIdle)
end

--检查
function ItemQueue:Check()
    self:ShowEnd(true)
    if self.time_func then
        self:UnSchedule(self.time_func)
    end
    BuildQueueModel.CheckIdle()
    self:SetLock()
    if self:GetLock() then
        return
    end
    if self:GetBusy() then
        self:SetBusy()
        return
    end
    self:SetIdle()
end

--设置解锁状态
function ItemQueue:SetLock()
    if self.isFree then
        return
    end
    local expire = Model.Builders[self.type].ExpireAt
    local function get_time()
        return expire - Tool.Time()
    end
    local islock = expire > 0 and get_time() <= 0
    if islock then
        self:SetController(CTR.GoldLock)
    else
        self.visible = true
        self:SetController(CTR.GoldIdle)
    end

    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
    if not islock then
        self.cd_func = function()
            if get_time() <= 0 then
                self:UnSchedule(self.cd_func)
                self:SetController(CTR.GoldLock)
            end
        end
        self:Schedule(self.cd_func, 1)
    end
end
--获取解锁状态
function ItemQueue:GetLock()
    return self._ctr.selectedPage == CTR.GoldLock
end

--设置忙碌状态
function ItemQueue:SetBusy()
    local bid = Model.Builders[self.type].EventId
    local event = EventModel.GetUpgradeEvent(bid)
    if not event then
        return
    end
    local building = Model.Find(ModelType.Buildings, bid)
    self._icon.icon = UITool.GetIcon(UpgradeModel.GetSmallIcon(building.ConfId, building.Level))
    self:SetController(self.isFree and CTR.FreeBusy or CTR.GoldBusy)

    local category = event.Category
    local freeTime = CommonModel.FreeTime()
    local function get_time()
        local ct = event.FinishAt - Tool.Time()
        return ct <= event.Duration and ct or event.Duration
    end
    local isCheck = false
    local bar_func = function()
        local t = get_time()
        self._cdTime.text = Tool.FormatTime(t)
        self._barTime.fillAmount = 1 - t / event.Duration
        --是否显示免费
        if not isCheck and BuildModel.FreeState(category) then
            if t <= freeTime then
                isCheck = true
                self:SetController(self.isFree and CTR.FreeFree or CTR.GoldFree)
            end
        end
    end
    bar_func()
    self.time_func = function()
        if get_time() >= 0 then
            bar_func()
            return
        end
        self:UnSchedule(self.time_func)
    end
    self:Schedule(self.time_func, 1)
end

--获取设置忙碌状态
function ItemQueue:GetBusy()
    return Model.Builders[self.type].IsWorking
end

function ItemQueue:TriggerOnclick(callback)
        self.triggerClick = callback
end

--金锤子流光特效
function ItemQueue:HammerSweepEffect()
    --self._goldEffect:PlayEffectLoop("effects/hammer_sweep/prefab/effect_hammer_sweep")
end

return ItemQueue
