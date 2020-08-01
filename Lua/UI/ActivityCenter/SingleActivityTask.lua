--[[
    author:{laofu}
    time:2020-06-01 11:14:34
    function:{单人活动任务详情}
]]
local SingleActivityTask = UIMgr:NewUI("SingleActivityTask")

function SingleActivityTask:OnInit()
    local view = self.Controller.contentPane
    self._titleText = view:GetChild("title")
    self._descText = view:GetChild("desc")
    self._taskList = view:GetChild("list")

    self._btnExit = view:GetChild("btnClose")
    self._btntouch = view:GetChild("touch")

    self._titleText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Single_GetGrade")
    self._descText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Single_GetGradeTxt")

    self:AddListener(self._btnExit.onClick,
        function()
            UIMgr:Close("SingleActivityTask")
        end
    )
    self:AddListener(self._btntouch.onClick,
        function()
            UIMgr:Close("SingleActivityTask")
        end
    )

    self._taskList.itemRenderer = function(index, item)
        local task = self.taskDatas[index + 1]

        local title = item:GetChild("title")
        local scoreText = item:GetChild("score")

        title.text = StringUtil.GetI18n(I18nType.Commmon, task.name)
        scoreText.text = task.points
    end
end

--单人活动类型|configSingleType表筛选后的数据
function SingleActivityTask:OnOpen(taskDatas)
    self.taskDatas = taskDatas
    local task =
        table.find(
        self.taskDatas,
        function(item)
            return item.points < 0
        end
    )
    if task then
        table.removeItem(self.taskDatas, task)
    end
    self._taskList.numItems = #self.taskDatas
    --列表大小
    self._taskList:ResizeToFit(self._taskList.numItems)
end

function SingleActivityTask:OnClose()
end

return SingleActivityTask
