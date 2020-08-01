-- 升级条件子项
local ItemCondition = fgui.extension_class(GComponent)
fgui.register_extension('ui://Common/upgradeRequirement', ItemCondition)
local GuidePanelModel = import("Model/GuideControllerModel")
local CTR = {
    Satisfy = 'Satisfy', --满足条件
    Dissatisfy = 'Dissatisfy' --不满足条件
}

function ItemCondition:ctor()
    self._ctrBtn = self:GetController('CtrBtn')
    self._ctrCondition = self:GetController('CtrCondition')

    self:AddListener(self._btnTurn.onClick,
        function()
            Event.Broadcast(EventDefines.CloseGuide)
            self:OnBtnClick()
        end
    )
    self:AddListener(self._btnAccelerate.onClick,
        function()
            Event.Broadcast(EventDefines.CloseGuide)
            self:OnBtnClick()
        end
    )
    self:AddListener(self._btnFree.onClick,
        function()
            Event.Broadcast(EventDefines.CloseGuide)
            self:OnBtnClick()
        end
    )
    self:AddListener(self._btnObtain.onClick,
        function()
            Event.Broadcast(EventDefines.CloseGuide)
            self:OnBtnClick()
        end
    )
end

function ItemCondition:OnBtnClick()
    if self.cb then
        self.cb(self.data.Type)
    end
    --AudioModel.StopSpeech()
end

--[[
    data = {
        Type = 按钮类型 跳转、加速、免费、获取 BuildType.CONDITION.Turn
        Icon
        Title
        Condition = 条件
        IsSatisfy = 是否满足条件
        IsQueue = 是否是建筑队列
        Callback = 按钮点击回调
    }
]]
function ItemCondition:Init(data)
    self:RemoveUpgrateTime()
    self.data = data
    self.cb = data.Callback

    self._icon.icon = data.Icon
    self._title.text = data.Title
    if data.IsSatisfy then
        self._ctrCondition.selectedPage = CTR.Satisfy
        self._ctrBtn.selectedPage = 'Normal'
    else
        self._ctrCondition.selectedPage = CTR.Dissatisfy
        if data.Type then
            self._ctrBtn.selectedPage = data.Type
        end
    end
    self._light.visible = false
    self:SetEvent()
    self:SetBgColor()
end

function ItemCondition:SetBgColor()
    -- local single = false
    -- if self.data.index then
    --     single =  self.data.index % 2 == 1
    -- end
    -- self._barBgLight.visible = single
    -- self._barBgDark.visible = not single
    self._barBgLight.visible = false
    self._barBgDark.visible = true
end

function ItemCondition:GetCondition()
    return self.data
end

function ItemCondition:GetCategory()
    return self.data.Category
end

function ItemCondition:GetAmount()
    return self.data.Amount
end

--条件不满足动画
function ItemCondition:PlayAnim()
    self._light.visible = true
    local _anim = self:GetTransition('Anim_Twinkle')
    _anim:Stop()
    _anim:Play()
end

function ItemCondition:SetEvent()
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
    if not self.data.Event then
        return
    end
    if self.data.IsInCondition then
        local values = {
            building_name = self.data.Title,
            building_level = self.data.LevelCondition,
        }
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Building_Lock_Level", values)
        return
    end
    local function time_func()
        return self.data.Event.FinishAt - Tool.Time()
    end
    local values = {
        building_name = self.data.Title,
        rest_time = Tool.FormatTime(time_func())
    }
    local i18n = "Building_UPGRADE_Now" --默认建筑升级
    if self.data.Event.Category == EventType.B_BUILD then
        if self.data.Level == 0 then
            i18n = "Building_Build_Now" --建筑建造中
        else
            i18n = "Building_UPGRADE_Now" --建筑升级中
        end
    elseif self.data.Event.Category == EventType.B_DESTROY then
        i18n = "Building_REMOVE_Now" --建筑拆除中
    end
    local function text_func()
        local t = time_func()
        values.rest_time = Tool.FormatTime(t)
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, i18n, values)
        if self._ctrBtn.selectedPage == BuildType.CONDITION.Accelerate and t < CommonModel.FreeTime() then
            self.data.Type = BuildType.CONDITION.Free
            self._ctrBtn.selectedPage = BuildType.CONDITION.Free
        end
    end
    text_func()
    self.cd_func = function()
        if time_func() >= 0 then
            text_func()
            return
        end
        self:UnSchedule(self.cd_func)
    end
    self:Schedule(self.cd_func, 1)
end

function ItemCondition:SetUpgrateTime(upgrade)
    local function time_func()
        return upgrade.FinishAt - Tool.Time()
    end
    self.schedule_funtion = function()
        if time_func() >= 0 then
            self._title.text = self.data.Title .. '：' .. Tool.FormatTime(time_func())
        else
            self:UnSchedule(self.schedule_funtion)
        end
    end
    self.schedule_funtion()
    self:Schedule(self.schedule_funtion, 1)
end

function ItemCondition:RemoveUpgrateTime()
    if self.schedule_funtion then
        self:UnSchedule(self.schedule_funtion)
    end
end

return ItemCondition
