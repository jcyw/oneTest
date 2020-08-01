--[[
    Author:maxiaolong
    Function:推荐奖励界面
]]
local TaskMissionBoxRewardPopup = UIMgr:NewUI("TaskMissionBoxRewardPopup")

local TaskModel = import("Model/TaskModel")
local WelfareModel = import("Model/WelfareModel")

function TaskMissionBoxRewardPopup:OnInit()
    self._view = self.Controller.contentPane
    self._bgMask = self._view:GetChild("bgMask")
    self._view:GetChild("titleName").text = StringUtil.GetI18n(I18nType.Commmon, "AWARD_TITLE")
    self._btnClose = self._view:GetChild("btnClose")
    self._liebiao = self._view:GetChild("liebiao")
    self._btnConfirm = self._view:GetChild("btnConfirm")
    self._btnConfirm:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
    self._btnReceive = self._view:GetChild("btnReceive")
    self._btnReceive:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")

    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("TaskMissionBoxRewardPopup")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("TaskMissionBoxRewardPopup")
        end
    )
    self:AddListener(self._btnConfirm.onClick,
        function()
            UIMgr:Close("TaskMissionBoxRewardPopup")
        end
    )
    self:AddListener(self._btnReceive.onClick,
        function()
            local awardId=self.conf.award
            Net.MainTask.GetMainTaskAward(
                self.conf.id,
                function(rsp)
                    --播放领奖动画
                    UITool.GiftReward(awardId)
                    TaskModel:GetRemoveTaskInfo(rsp)
                    --self.conf是宝箱任务
                    Event.Broadcast(EventDefines.UITaskMainRefresh)
                end
            )
            UIMgr:Close("TaskMissionBoxRewardPopup")
        end
    )
    self._liebiao.itemRenderer = function(index, item)
        item:SetParams(self.itemsInfo[index + 1])
    end
end

function TaskMissionBoxRewardPopup:OnOpen(conf)
    self.conf = conf
    local isReceive
    if not conf.AwardTaken then
        isReceive = conf.AwardTaken
    end
    local process
    if isReceive == false then
        process = conf.finish.para2
    else
        if not conf.CurrentProcess then
            process = 0
        else
            process = conf.CurrentProcess
        end
    end
    local needNum = conf.finish.para2 - process
    if needNum <= 0 then
        self._view:GetChild("textRewardDescribe").text = StringUtil.GetI18n(I18nType.Commmon, "UI_ALLREADY_FINISH")
        self._btnReceive.visible = true
        self._btnConfirm.visible = false
    else
        self._view:GetChild("textRewardDescribe").text = StringUtil.GetI18n(I18nType.Tasks, "TASK_371_DESC", {num_x = needNum})
        self._btnReceive.visible = false
        self._btnConfirm.visible = true
    end

    --获得奖励信息
    self:InitEvent(conf.award)
end

function TaskMissionBoxRewardPopup:InitEvent(awardConf)
    self.itemsInfo, self.itemNum = WelfareModel.GetResOrItemByGiftId(awardConf)
    self._liebiao.numItems = self.itemNum
end

return TaskMissionBoxRewardPopup
