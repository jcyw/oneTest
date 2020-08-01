--[[
    Author:maxiaolong
    Funtion:日常任务UI控制器
]]
local ItemTaskDailyLiebiao = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/itemTaskDailyLiebiao", ItemTaskDailyLiebiao)

local TaskModel = import("Model/TaskModel")
local DailyTaskModel=import("Model/DailyTaskModel")
function ItemTaskDailyLiebiao:ctor()
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

function ItemTaskDailyLiebiao:SetData(config)
    self.config = config
    local name, desc, info = TaskModel:GetTaskNameByType(config)
    self._title.text = info
    local sumActiveValue = config.times * config.activity
    if config.img ~= nil then
        self._itemIcon.icon = UITool.GetIcon(config.img)
    end
    local curProgress = config.finished
    local maxProgress = config.times
    local decimalNum = Tool.GetPreciseDecimal(curProgress / maxProgress, 2)
    local progressNum = decimalNum * 100
    progressNum = Tool.FormatFloat(progressNum)
    self._textProgress.text = progressNum .. "%"
    local progressValue = (curProgress / maxProgress)
    self._progressBar.value = progressValue * 100
    local itemData=DailyTaskModel:GetDailyTaskItemById(self.config.id) 
    self._textValue.text="+"..itemData.activity
    if config.StateType == 1 then
        self._controller.selectedIndex = 0
    elseif config.StateType == 2 then
        self._controller.selectedIndex = 1
    elseif config.StateType == 3 then
        self._controller.selectedIndex = 2
    end
end

function ItemTaskDailyLiebiao:GetData()
    return self.config
end

return ItemTaskDailyLiebiao
