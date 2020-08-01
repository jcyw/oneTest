--[[
    Author:maxiaolong
    Funtion:日常任务UI控制器
]]
local ItemDailyTask = fgui.extension_class(GButton)
fgui.register_extension("ui://Welfare/itemTaskDailyLiebiao", ItemDailyTask)

local TaskModel = import("Model/TaskModel")

function ItemDailyTask:ctor()
    --名称
    self._title = self:GetChild("title")
    --时间
    self._titleTime = self:GetChild("titleTime")
    --积分数量
    self._textValue = self:GetChild("textValue")
    --百分比
    self._textProgress = self:GetChild("textProgresBar")
    --进度值
    self._progressBar = self:GetChild("progressBar")
    self._itemIcon = self:GetChild("icon")
    self._controller = self:GetController("c1")
end

function ItemDailyTask:SetData(config)
    self.config = config
    local name, desc, info = TaskModel:GetTaskNameByType(config)
    self._title.text = info
    local sumActiveValue = config.times * config.activity
    if config.img ~= nil then
        self._itemIcon.icon = UITool.GetIcon(config.img)
    end
    self._textValue.text = tostring("+" .. sumActiveValue)
    local curProgress = config.finished
    local maxProgress = config.times
    self._textProgress.text = tostring(curProgress) .. "/" .. tostring(maxProgress)
    local progressValue = (curProgress / maxProgress)
    self._progressBar.value = progressValue * 100

    if config.StateType == 1 then
        self._controller.selectedIndex = 0
    elseif config.StateType == 2 then
        self._controller.selectedIndex = 1
    elseif config.StateType == 3 then
        self._controller.selectedIndex = 2
    end
end

function ItemDailyTask:GetData()
    return self.config
end

return ItemDailyTask
