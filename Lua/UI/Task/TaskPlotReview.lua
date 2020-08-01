--[[
    Author:maxiaolong
    Function: 剧情任务提示
]]
local TaskPlotReview = UIMgr:NewUI("TaskPlotReview")
local TaskModel = import("Model/TaskModel")

function TaskPlotReview:OnInit()
    local view = self.Controller.contentPane
    self._textName = view:GetChild("textPlotName")
    self._textInfo = view:GetChild("textName")
    self.inAnim = view:GetTransition("in")
    self.outAnim = view:GetTransition("out")
    self._bg = view:GetChild("bg")
    self._bg:SetIcon({"falcon","com_task_bg"})
end
local taskStr = "PLOT_TASK_"
local taskNameStr = "_NAME"
local taskTitleStr = "_TITLE"

function TaskPlotReview:OnOpen(charpterIndex, endCb)
    local index = tostring(charpterIndex)
    self._textName.text = StringUtil.GetI18n(I18nType.Tasks, taskStr .. index .. taskTitleStr)
    self._textInfo.text = StringUtil.GetI18n(I18nType.Tasks, taskStr .. index .. taskNameStr)
    local charptherInfo = TaskModel.TaskPlotReview(charpterIndex)
    self._banner.icon = UITool.GetIcon(charptherInfo.banner)
    --播放完毕后内容
    Event.Broadcast(EventDefines.DelayMask, true)
    local function outCb()
        UIMgr:Close("TaskPlotReview")
        if endCb then
            Event.Broadcast(EventDefines.DelayMask, false)
            endCb()
        end
    end
    local function cb()
        self:ScheduleOnceFast(
            function()
                self.outAnim:Play(1, 0, 0, 2, outCb)
            end,
            0.5
        )
    end
    self.inAnim:Play(1, 0, 0, 2, cb)
end

return TaskPlotReview
