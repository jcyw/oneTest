--[[
    author:{日常奖励弹窗}
    time:2020-01-06 11:53:42
    function:{maxiaolong}
]]
local GD = _G.GD
local TaskMissionAutomaticPopup = UIMgr:NewUI("TaskMissionAutomaticPopup")
local DailyTaskModel = import("Model/DailyTaskModel")
local WelfareModel = import("Model/WelfareModel")
function TaskMissionAutomaticPopup:OnInit()
    self._view = self.Controller.contentPane
    self._title = self._view:GetChild("title")
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_DAILY_TASK_BOX")
    self._text.text = StringUtil.GetI18n(I18nType.Commmon, "UI_DAILY_TASK_POP")
    self._textBtn.text = StringUtil.GetI18n(I18nType.Commmon, "UI_DAILY_TASK_TIP")
    self._btnSureSingle:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
    self._bgMask = self._view:GetChild("bg")
    local getAwardFunc = function()
        local giftAward=self.awardId
        Net.DailyTask.GetDailyTaskAward(
            self.taskId,
            function(rsp)
                if (rsp.OK == true) then
                 
                    --播放领奖动画
                    UITool.GiftReward(giftAward)
                    DailyTaskModel.RemoveRedData()
                    Event.Broadcast(EventDefines.RefreshDailyRed)
                    Event.Broadcast(EventDefines.UITaskRefreshRed) 
                    Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.DailyTask.Id, -1)
                    self:OnClose()
                end
            end
        )
    end
    self:AddListener(self._btnClose.onClick,
        function()
            getAwardFunc()
        end
    )
    self:AddListener(self._btnSureSingle.onClick,
        function()
            self:OnClose()
            Event.Broadcast(EventDefines.UIOpenTaskPanel, true)
        end
    )

    self:AddListener(self._view:GetChild("bgMask").onClick,
        function()
            getAwardFunc()
        end
    )
    self._list.itemRenderer = function(index, item)
        local data = self.items[index + 1]
        -- local title = StringUtil.GetI18n(I18nType.Commmon, data[1].key)
        -- local amount = WelfareModel.DicKeyByIndex(index + 1, self.items, false)

        item:SetAmount(data.image, data.color, data.amount, data.title)
    end
end

function TaskMissionAutomaticPopup:OnOpen(id)
    local itemData = DailyTaskModel:GetDailyTaskItemById(id)
    self.taskId = id
    DailyTaskModel.GetBaseLevel(
        function(baseLevel)
            local award = DailyTaskModel.GetBoxAwardConfid(baseLevel, itemData.award)
            self.awardId = award
            local items, num = WelfareModel.GetResOrItemByGiftId(award)
            self.items = items
            self._list.numItems = num
        end
    )
end

function TaskMissionAutomaticPopup:OnClose()
    UIMgr:Close("TaskMissionAutomaticPopup")
end

return TaskMissionAutomaticPopup
