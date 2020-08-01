--[[
    Author:zhangzhichao
    Function:主线任务列表项
]]
local ItemTaskMissionLiebiao = fgui.extension_class(GButton)
fgui.register_extension("ui://Task/itemTaskMissionLiebiao", ItemTaskMissionLiebiao)
local JumpMap = import("Model/JumpMap")
local TaskModel = import("Model/TaskModel")
local GlobalVars = GlobalVars

function ItemTaskMissionLiebiao:ctor()
    self._btnBg = self:GetChild("bg")
    self._icon = self:GetChild("icon")
    self._textName = self:GetChild("textName")
    self._textNameNum = self:GetChild("textNameNum")
    self._ProgressBarYellow = self:GetChild("ProgressBarYellow")
    self._btnGo = self:GetChild("btnGo")
    self._btnGet = self:GetChild("btnGet")
    self._controller = self:GetController("c1")
    self._boxBoxMask = self:GetChild("missonBoxMask")
    self._animMove = self:GetTransition("Move")
    self._ProgressBarYellow.max = 100
    self._ProgressBarYellow.value = 0
    self:AddListener(self._btnBg.onClick,
        function()
            if self._animMove.playing == true then
                return
            end
            UIMgr:Open("TaskMissionPopup", 2, self.conf)
        end
    )
    self:AddListener(self._btnGo.onClick,
        function()
            self:OnBtnClick(false)
        end
    )
    self:AddListener(self._btnGet.onClick,
        function()
            self:OnBtnClick(true)
        end
    )
    self:AddListener(self._boxBoxMask.onClick,
        function()
            if GlobalVars.IsTriggerStatus then
                return
            end
            if self._animMove.playing == true then
                return
            end
            UIMgr:Open("TaskMissionPopup", 2, self.conf)
        end
    )
    self:AddListener(self._icon.onClick,
        function()
            if GlobalVars.IsTriggerStatus then
                return
            end
            if self._animMove.playing == true then
                return
            end
            UIMgr:Open("TaskMissionPopup", 2, self.conf)
        end
    )
end

function ItemTaskMissionLiebiao:InitEvent(conf) --初始化
    self.conf = conf
    self._icon.url = UITool.GetIcon(conf.img)
    self._textName.text = TaskModel:GetTaskNameByType(conf)
    -- self._textNameNum.color = Color.gray
    self._textNameNum.color = Color(242 / 255, 241 / 255, 241 / 255)
    local isReceive
    if not conf.AwardTaken then
        isReceive = conf.AwardTaken
    end
    local percent
    if not conf.CurrentProcess then
        conf.CurrentProcess = 0
    end
    local finishProgress, curValue = TaskModel.SetProgressValue(conf, conf.CurrentProcess)
    if isReceive == false then
        self._textNameNum.text = finishProgress .. "/" .. finishProgress
        self._textNameNum.color = Color(242 / 255, 241 / 255, 241 / 255)
        percent = 1
        self._ProgressBarYellow.value = percent * 100
    else
        -- local curValue
        -- curValue = not conf.CurrentProcess and 0 or conf.CurrentProcess
        local maxValue = finishProgress
        self._textNameNum.text = curValue .. "/" .. maxValue
        percent = curValue / maxValue
        self._ProgressBarYellow.value = percent * 100
    end
    if percent < 1 then
        self._controller.selectedIndex = 0
        if conf.jump.jump == 0 then
            self._btnGo:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "FUND_VIEW_BUTTON")
        else
            self._btnGo:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
        end
    else
        self._controller.selectedIndex = 1
        self._btnGet:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
    end
end

function ItemTaskMissionLiebiao:GetAwardData()
    local awardId=self.conf.award
    Net.MainTask.GetMainTaskAward(
        self.conf.id,
        function(rsp)
            --播放领奖动画
            TaskModel:GetRemoveTaskInfo(rsp)
            self._animMove:Play(
                function()
                    UITool.GiftReward(awardId)
                    Event.Broadcast(EventDefines.UITaskMainRefresh)
                    Event.Broadcast(EventDefines.UITaskRefreshRed)
                end
            )
        end
    )
end

function ItemTaskMissionLiebiao:OnBtnClick(bool)
    if GlobalVars.IsTriggerStatus then
        return
    end
    if self._animMove.playing == true then
        return
    end
    if bool then
        self:GetAwardData()
    else
        if self.conf.jump.jump == 0 then
            UIMgr:Open("TaskMissionPopup", 2, self.conf)
        else
            Event.Broadcast(EventDefines.CloseUiTaskMain)

            if self.conf.jump.jump == 810500 then
                TurnModel.MapLockPiece(self.conf.jump.para)
            else
                JumpMap:JumpTo(self.conf.jump, self.conf.finish)
            end

            --首冲充值打点
            local strId = tostring(self.conf.id)
            if self.conf.id == 5208201 then
                Net.UserInfo.RecordLog(
                   4204, strId,
                    function(rsp)
                    end
                )
            end
        end
    end
end

return ItemTaskMissionLiebiao
