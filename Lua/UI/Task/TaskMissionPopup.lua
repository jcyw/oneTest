--[[
    Author:zhangzhichao
    Function:推荐任务、普通任务提示
]]
local TaskMissionPopup = UIMgr:NewUI("TaskMissionPopup")

local TaskModel = import("Model/TaskModel")
local WelfareModel=import("Model/WelfareModel")
function TaskMissionPopup:OnInit()
    self._view = self.Controller.contentPane
    self._bgMask = self._view:GetChild("bgMask")
    self._titleName = self._view:GetChild("titleName")
    self._btnClose = self._view:GetChild("btnClose")
    self._iconBg = self._view:GetChild("iconBg")
    self._icon = self._view:GetChild("icon")
    self._textLevel = self._view:GetChild("textLevel")
    self._textLevelNum = self._view:GetChild("textLevelNum")
    self._textCheck = self._view:GetChild("textCheck")
    self._ProgressBarYellow = self._view:GetChild("ProgressBarYellow")
    self._view:GetChild("textName").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_REWARD")
    self._liebiao = self._view:GetChild("liebiao")
    self._btnReward = self._view:GetChild("btnReward")
    self._btnReward:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_REWARD")
    self._c1Controller = self._view:GetController("c1")
    self._c1Controller.selectedIndex = 1
    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("TaskMissionPopup")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("TaskMissionPopup")
        end
    )
    self:AddListener(self._btnReward.onClick,
        function()
            if self._c1Controller.selectedIndex == 0 then
                UIMgr:Close("TaskMissionPopup")
                local awardId=self.conf.award
                Net.MainTask.GetMainTaskAward(
                    self.conf.id,
                    function(rsp)
                        --播放领奖动画
                        UITool.GiftReward(awardId)
                        TaskModel:GetRemoveTaskInfo(rsp)
                        Event.Broadcast(EventDefines.UITaskMainRefresh)
                        if self.cb then
                            self.cb()
                        end
                    end
                )
            end
        end
    )
end

function TaskMissionPopup:OnOpen(index, conf, cb)
    self.conf = conf
    if not self.conf then
        return
    end
    self.cb = cb
    if index == 1 then
        self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RECOMMEND_TASK")
    elseif index == 2 then
        self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_COMMON_TASK")
    end
    self._icon.url = UITool.GetIcon(conf.img)
    local isReceive
    if not conf.AwardTaken then
        isReceive = conf.AwardTaken
    end
    local maxValue, curValue = TaskModel.SetProgressValue(conf, conf.CurrentProcess)
    if isReceive == false then
        curValue = maxValue
    else
        curValue = curValue
    end
    self._textLevelNum.text = curValue .. "/" .. maxValue
    local name, desc = TaskModel:GetTaskNameByType(conf, maxValue - curValue)
    self._textLevel.text = name
    self._textCheck.text = desc
    local percent = curValue / maxValue
    self._ProgressBarYellow.value = percent * 100
    if percent == 1 then
        self._c1Controller.selectedIndex = 0
    else
        self._c1Controller.selectedIndex = 1
    end
    --获得奖励信息
    self:InitEvent(conf.award)
end

function TaskMissionPopup:InitEvent(awardConf)
    self.itemsData, self.itemCount = WelfareModel.GetResOrItemByGiftId(awardConf)
    self._liebiao.numItems = self.itemCount
    for i = 1, #self.itemsData do
        local item = self._liebiao:GetChildAt(i - 1)
        item:SetData(self.itemsData[i])
    end
end

return TaskMissionPopup
