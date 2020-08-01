--[[
    Author:maxiaolong
    Function:日常任务弹窗
]]
local TaskModel = import("Model/TaskModel")
local DailyTaskModel = import("Model/DailyTaskModel")
local TaskDailyBoxRewardPopup = UIMgr:NewUI("TaskDailyBoxRewardPopup")
TaskDailyBoxRewardPopup.selectIndex = 0
TaskDailyBoxRewardPopup.rewardConfig = {}

function TaskDailyBoxRewardPopup:OnInit()
    self.view = self.Controller.contentPane
    self._btnClose = self.view:GetChild("btnClose")
    self._listView = self.view:GetChild("liebiao")
    self._receiveBtn = self.view:GetChild("btnReceive")
    self._receiveBg = self.view:GetChild("bgTagDownBig")
    self._c1Controller = self.view:GetController("c1")
    self._receiveTitle = self._receiveBtn:GetChild("title")
    self._title = self.view:GetChild("titleName")
    self._bgMask = self.view:GetChild("bgMask")
    self._textReceive = self.view:GetChild("textHaveReceived")
    self._textReceive.text = StringUtil.GetI18n(I18nType.Commmon, "UI_DAILY_GIFT_GET")
    self:AddListener(
        self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(
        self._bgMask.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(
        self._receiveBtn.onClick,
        function()
            if self.selectItem ~= nil then
                if self.selectItem.isAward == true then
                    return
                end
                local rewardData = self.award
                Net.DailyTask.GetDailyTaskAward(
                    self.selectItem.id,
                    function(rsp)
                        if (rsp.OK == true) then
                            --播放领奖动画
                            UITool.GiftReward(rewardData)
                            self.selectItem.isAward = true
                            self.TaskReward:SetBoxView(self.selectItem)
                            if self.dailytask ~= nil then
                                --设置红点
                            end
                            DailyTaskModel.RemoveRedData()
                            Event.Broadcast(EventDefines.UITaskRefreshRed)
                            --刷新红点
                            Event.Broadcast(EventDefines.RefreshDailyRed)
                            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.DailyTask.Id, -1)
                        end
                    end
                )
            end
            self:Close()
        end
    )
end

function TaskDailyBoxRewardPopup:OnOpen(config, baseLevel, TaskReward, dailytask, c1)
    self.TaskReward = TaskReward
    self.dailytask = dailytask
    self.rewardConfig = config
    self.selectItem = self.rewardConfig[self.selectIndex]
    local itemData = self.selectItem
    if not itemData then
        return
    end
    self._receiveTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "AWARD_TITLE")
    self.award = DailyTaskModel.GetBoxAwardConfid(baseLevel, itemData.award)
    local giftConfig = ConfigMgr.GetItem("configGifts", self.award)
    if not giftConfig then
        return
    end
    local giftList = {}
    local giftconfigRes = giftConfig.res
    local giftconfigItem = giftConfig.items
    if giftconfigRes ~= nil then
        for k, v in pairs(giftconfigRes) do
            table.insert(giftList, v)
        end
    end
    if giftconfigItem ~= nil then
        for i, value in pairs(giftconfigItem) do
            table.insert(giftList, value)
        end
    end
    self._listView.numItems = #giftList
    for i, giftValue in pairs(giftList) do
        local item = self._listView:GetChildAt(i - 1)
        item:SetData(ITEM_TYPE.Gift, giftValue)
    end
    if c1 == 0 then
        self._c1Controller.selectedIndex = 1
    elseif c1 == 1 then
        self._c1Controller.selectedIndex = 0
    elseif c1 == 2 then
        self._c1Controller.selectedIndex = 2
    end
end

function TaskDailyBoxRewardPopup:Close()
    UIMgr:Close("TaskDailyBoxRewardPopup")
end

return TaskDailyBoxRewardPopup
