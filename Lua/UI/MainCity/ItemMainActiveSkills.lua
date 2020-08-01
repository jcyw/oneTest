--[[    author:{maxiaolong}
    time:2019-11-01 11:10:32
    function:{主动技能列表}
]]
local ItemMainActiveSkills = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemMainActiveSkills", ItemMainActiveSkills)
local isOnclick = false
-- local cutActivitySkillType = ActivitySkillType.lOCK
function ItemMainActiveSkills:ctor()
    self._controller = self:GetController("c1")
    self._title = self:GetChild("title")
    self._icon = self:GetChild("icon")
    self._timeText = self:GetChild("text")
    self._timeBg = self:GetChild("textBg")
    self._selection = self:GetChild("Selection")
    self._selection.visible = false
    self:AddListener(self.onClick,
        function()
            if IsTriggerStatus and self.cutIndex ~= 1 then
                return
            end
            for i = 1, self._btnList.numChildren do
                local itembtn = self._btnList:GetChildAt(i - 1)
                itembtn:SetSelectedShow()
            end
            self._selection.visible = true
            self.mainPanel:OnPenStateSet(self.itemName, self.itemIcon, self.itemDes, self.skillId, self.cutActivitySkillType, self.CDTime, self.expireTime, self.CDSumTime)
            if self.skillId == self.mainPanel.cutClickId then
                self.mainPanel:RefreshMainActive(self._timeText.text)
            end
            if self.triggerFunc then
                self.triggerFunc()
                self.triggerFunc = nil
            end
        end
    )
    self.skillUseStr = StringUtil.GetI18n(I18nType.Commmon, "UI_SKILL_USEING")
    self.skillCDStr = StringUtil.GetI18n(I18nType.Commmon, "UI_SKILL_LAST")
    --初始化
    self._timeText.text = ""
    self._controller.selectedIndex = 0
    self._title.text = ""
end

function ItemMainActiveSkills:SetData(params, mainActivePanel, cutIndex)
    self.cutIndex = cutIndex
    self.cutActivitySkillType = nil
    self.mainPanel = mainActivePanel
    self._btnList = mainActivePanel._list
    self._viewController = mainActivePanel._controller
    local nameStr = tostring(params.id) .. "_NAME"
    local desStr = tostring(params.id) .. "_DESC"
    self.itemName = StringUtil.GetI18n(I18nType.Tech, nameStr)
    self.itemDes = StringUtil.GetI18n(I18nType.Tech, desStr)
    self.itemIcon = params.icon
    self._icon.icon = UITool.GetIcon(params.icon)
    self.skillId = params.id
    local cdTime = params.skill_cd * BuffModel.GetSkillCooling()
    self.CDSumTime = cdTime
    self.CDTime = tonumber(params.cookAt)
    local expireTime = tonumber(params.expireAt)
    self.expireTime = expireTime
    if expireTime > 0 then
        self.cutActivitySkillType = ActivitySkillType.EXPIRE
        self._controller.selectedIndex = 1
        self._title.text = self.skillUseStr
        self:RefreshTime(expireTime)
        if params.effect then
            self:PlayEffect()
        else
            self:StopEffect()
        end
        --开始作用计时
        return
    end
    if self.CDTime < 0 or not params.isActive then
        self._title.text = ""
        self.cutActivitySkillType = ActivitySkillType.lOCK
        self._controller.selectedIndex = 3
        self:StopEffect()
    elseif self.CDTime == 0 then
        self._title.text = ""
        self.cutActivitySkillType = ActivitySkillType.UNCD
        self._controller.selectedIndex = 2
        self:StopEffect()
    elseif self.CDTime > 0 then
        self.cutActivitySkillType = ActivitySkillType.CD
        self._controller.selectedIndex = 0
        self._title.text = self.skillCDStr
        self:RefreshTime(self.CDTime)
        self:StopEffect()
    end
end

function ItemMainActiveSkills:PlayEffect()
    if self.effect then
        self._graph.visible = true
        return
    end
    CSCoroutine.Start(
        function()
            local resPath = "effects/skill/weakenlight/prefab/effect_rouhua_gq"
            coroutine.yield(ResMgr.Instance:LoadPrefab(resPath))
            local prefab = ResMgr.Instance:GetPrefab(resPath)
            local object = GameObject.Instantiate(prefab)
            wrapper = GoWrapper(object)
            self._graph.asGraph:SetNativeObject(wrapper)
            self.effect = true
            self._graph.visible = true
        end
    )
end

function ItemMainActiveSkills:StopEffect()
    self._graph.visible = false
end

function ItemMainActiveSkills:SetTest()
    self.CDTime = 0
    self.cutActivitySkillType = ActivitySkillType.CD
    self:RefreshTime(self.CDTime)
end

function ItemMainActiveSkills:SetSelectedShow(isShow)
    -- self._selection.visible = false
    -- if isShow and isShow == true then
    --     self._selection.visible = true
    -- end
    self._selection.visible = isShow == true
end

function ItemMainActiveSkills:RefreshTime(cdTime)
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
    local function time_func()
        return cdTime - Tool.Time()
    end
    if time_func() > 0 then
        local timeTextFunc = function(t)
            local timeText = Tool.FormatTime(t)
            if self.skillId == self.mainPanel.cutClickId then
                self.mainPanel:RefreshMainActive(timeText)
            end
            self._timeText.visible = true
            self._timeText.text = timeText
            self._timeBg.visible = true
        end
        self.cd_func = function()
            local ctime = time_func()
            if ctime >= 0 then
                timeTextFunc(ctime)
            else
                self._timeText.text = ""
                self._timeBg.visible = false
                self:EndTimerFunc()
            end
        end
        self:Schedule(self.cd_func, 1)
    else --当时间等于当前时间
        --重新打开
        self:EndTimerFunc()
    end
end

function ItemMainActiveSkills:EndTimerFunc()
    if self.cutActivitySkillType == ActivitySkillType.EXPIRE then
        --重新开始计时
        self.cutActivitySkillType = ActivitySkillType.CD
        self._controller.selectedIndex = 0
        self.mainPanel.cutTimer = self.TimerType.CDTimer
        self:RefreshTime(self.CDTime)
    elseif self.cutActivitySkillType == ActivitySkillType.CD then
        self._timeText.visible = false
        self._timeBg.visible = false
        self._controller.selectedIndex = 2
        self.mainPanel:RefreshView(self.CDTime)
        self:UnSchedule(self.cd_func)
        self.cutActivitySkillType = ActivitySkillType.UNCD
        if self.mainPanel:GetSkillId() == self.skillId then
            self.mainPanel:OnPenStateSet(self.itemName, self.itemIcon, self.itemDes, self.skillId, self.cutActivitySkillType, self.CDTime, self.expireTime, self.CDSumTime)
        end
    end
end

function ItemMainActiveSkills:Closeschedule()
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
end

function ItemMainActiveSkills:TriggerOnclick(callback)
        self.triggerFunc = callback
end

return ItemMainActiveSkills
