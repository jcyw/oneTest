--[[
    author:{maxiaolong}
    time:2019-11-30 16:14:05
    function:{活动日常任务}
]]
local TaskDaily = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/TaskDaily", TaskDaily)

function TaskDaily:ctor()
    self._dailyTasklogic = self:GetChild("TaskDaily")
end

function TaskDaily:OnOpen()
    self:SetShow(true)
    self._dailyTasklogic:OnOpen(true)
end

function TaskDaily:SetShow(isShow)
    self.visible = isShow
end
return TaskDaily
