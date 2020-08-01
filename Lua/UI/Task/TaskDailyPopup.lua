local TaskDailyPopup = UIMgr:NewUI("TaskDailyPopup")
local TaskModel = import("Model/TaskModel")
local JumpMap = import("Model/JumpMap")
TaskDailyPopup.selectItem = nil

function TaskDailyPopup:OnInit()
    self._view = self.Controller.contentPane
    self._tilteName = self._view:GetChild("titleName")
    self.taskPopupIcon = self._view:GetChild("image")
    self._textDesText = self._view:GetChild("textDescribe")
    self._awardDesText = self._view:GetChild("textName")
    self._completeNumber = self._view:GetChild("textCompleteNumber")
    self._completeText = self._view:GetChild("textComplete")
    self._textGetNumber = self._view:GetChild("textGetNumber")
    self._textGet = self._view:GetChild("textGet")
    self._goToBtn = self._view:GetChild("btnGo")
    self._closeBtn = self._view:GetChild("btnClose")
    self._gotoBtnText = self._goToBtn:GetChild("title")
    self._bgMask = self._view:GetChild("bgMask")
    self:AddListener(self._bgMask.onClick,
        function()
            self.Close()
        end
    )
    self:AddListener(self._goToBtn.onClick,
        function()
            UIMgr:Close("TaskDailyPopup")
            local jump = self.selectItem:GetData().jump
            local finish = self.selectItem:GetData().finish
            Event.Broadcast(EventDefines.WelareCenterClose)
            Event.Broadcast(EventDefines.CloseUiTaskMain)
            JumpMap:JumpTo(jump, finish)
        end
    )
    self:AddListener(self._closeBtn.onClick,
        function()
            self:Close()
        end
    )

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.WordPrisonExplain)
end

function TaskDailyPopup:OnOpen()
    self:RefreshView()
end

function TaskDailyPopup:Close()
    UIMgr:Close("TaskDailyPopup")
end

function TaskDailyPopup:RefreshView()
    local data = self.selectItem:GetData()
    local name, desc, info = TaskModel:GetTaskNameByType(data)

    self._tilteName.text = info
    -- RESOURE_TYPE_1
    local resStr = "RESOURE_TYPE_" .. data.finish.para1
    resStr = StringUtil.GetI18n(I18nType.Commmon, resStr)
    self._textDesText.text = name
    self._gotoBtnText.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")

    self._awardDesText.text = StringUtil.GetI18n(I18nType.Tasks, data.trans_desc)
    self._completeText.text = StringUtil.GetI18n(I18nType.Commmon, "Queue_Text15") .. ":"
    local finishStr = tostring(data.finished) .. "/" .. tostring(data.times)
    self._completeNumber.text = finishStr
    self._textGet.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ALLREADY_GET") .. ":"
    local curActiviy = data.finished * data.activity
    local sumActivity = (data.activity) * data.times
    self._textGetNumber.text = tostring(curActiviy) .. "/" .. tostring(sumActivity)
end

return TaskDailyPopup
