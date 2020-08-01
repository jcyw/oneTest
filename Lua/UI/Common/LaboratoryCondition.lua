--[[
    author:Temmie
    time:2019-08-30 17:37:24
    function:科技研究界面条件列表子项
]]
local LaboratoryCondition = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/upgradeLaboratory", LaboratoryCondition)

local CONTROLLER = {
    Satisfy = 'Satisfy', --满足条件
    Dissatisfy = 'Dissatisfy' --不满足条件
}

function LaboratoryCondition:ctor()
    self._controllerBtn = self:GetController('ControllerBtn')

    self:AddListener(self._btnTurn.onClick,
        function()
            self:OnBtnClick()
        end
    )
    self:AddListener(self._btnAccelerate.onClick,
        function()
            self:OnBtnClick()
        end
    )
    self:AddListener(self._btnFree.onClick,
        function()
            self:OnBtnClick()
        end
    )
    self:AddListener(self._btnObtain.onClick,
        function()
            self:OnBtnClick()
        end
    )
end

function LaboratoryCondition:OnBtnClick()
    if self.cb then
        self.cb()
    end
end

--[[
    data = {
        Type = 按钮类型 跳转、加速、免费、获取 BuildType.CONDITION.Turn
        Icon
        Title
        Condition = 条件
        IsSatisfy = 是否满足条件
        Callback = 按钮点击回调
    }
]]
function LaboratoryCondition:Init(data)
    self:RemoveUpgrateTime()
    self.data = data
    self.cb = data.Callback

    self._icon.icon = data.Icon
    self._title.text = data.Title
    if data.TitleColor then
        self._title.color = data.TitleColor
    else
        self._title.color = Color(0.55, 0.56, 0.58)
    end

    if data.IsSatisfy then
        self._controllerBtn.selectedPage = 'Normal'
    else
        if data.Type then
            self._controllerBtn.selectedPage = data.Type
        end
    end
    self._light.visible = false
end

function LaboratoryCondition:SetUpgrateTime(upgrade)
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

function LaboratoryCondition:RemoveUpgrateTime()
    if self.schedule_funtion then
        self:UnSchedule(self.schedule_funtion)
    end
end

return LaboratoryCondition
