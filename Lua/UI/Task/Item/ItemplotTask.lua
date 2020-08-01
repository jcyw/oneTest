--[[
    Author:muyu
    function:章节任务Item
]]
local ItemplotTask = fgui.extension_class(GComponent)
fgui.register_extension("ui://Task/plotTask", ItemplotTask)
local JumpMap = import("Model/JumpMap")
local TaskModel = import("Model/TaskModel")
local TaskPlotModel = import("Model/TaskPlotModel")
local State = {
    Jump = "Jump", --可跳转
    Receive = "Receive", --领取
    Received = "Received" --已领取
}

function ItemplotTask:ctor()
    self._statectr = self:GetController("State")
    self._checkbox = self:GetChild("check_box")
    self._textDistance = self:GetChild("textDistance")
    self._textDistanceNum = self:GetChild("textDistanceNum")
    self._textEXPNum = self:GetChild("textEXPNum")
    self._btnGo = self:GetChild("btnGo")
    self._btnReceive = self:GetChild("btnReceive")
    self._btnGotitle = self._btnGo:GetChild("title")
    self._btnReceivetitle = self._btnReceive:GetChild("title")

    --按钮国际化文本显示
    self._btnGotitle.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")

    self:AddListener(self._btnGo.onClick,
        function()
            self:OnBtnClick(false)
        end
    )
    self:AddListener(self._btnReceive.onClick,
        function()
            self:OnBtnClick(true)
        end
    )
end

function ItemplotTask:Init(index, plottask, flag, cb)
    self.index = index
    self.cb = cb
    self.plottask = plottask
    self.flag = flag
    --print("selfPlotTaskId--------------:",table.inspect(self.plottask.Id))
    self.conf = TaskModel:GetPlotTaskConf(self.plottask.Id)
    local desc = TaskModel:GetTaskNameByType(self.conf)
    local expnumres = TaskModel:GetGiftConfById(self.conf.rewardid)
    self.expnumres = expnumres
    local num = self.conf.finish.para2
    self._textDistance.text = desc
    self._textEXPNum.text = expnumres[1].amount

    if self.flag then
        self._checkbox.asButton.selected = true
        self._textDistanceNum.text = "[" .. num .. "/" .. num .. "]"
        if not self.plottask.AwardTaken then
            self._statectr.selectedPage = State.Receive
            self._btnReceivetitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
        else
            self._statectr.selectedPage = State.Received
            self._btnReceivetitle.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_39")
        end
    else
        self._checkbox.asButton.selected = false
        self._statectr.selectedPage = State.Jump
        self._textDistanceNum.text = "[" .. self.plottask.CurrentProcess .. "/" .. num .. "]"
    end
end

function ItemplotTask:OnBtnClick(flag)
    if flag then
        Net.Chapter.GetPlotTaskAward(
            self.plottask.Id,
            function()
                --播放领奖动画
                local rewards = {}
                for _, v in ipairs(self.expnumres) do
                    local reward = {
                        Category = Global.RewardTypeRes,
                        ConfId = v.category,
                        Amount = v.amount
                    }
                    table.insert(rewards, reward)
                end
                UITool.ShowReward(rewards)
                Event.Broadcast(EventDefines.RefreshTaskPlotGuide)
                self._statectr.selectedPage = State.Received
                self._btnReceivetitle.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_39")
                TaskModel:UpdateAwardTakens(self.plottask.Id)
                Event.Broadcast(EventDefines.UIChapterSort)
                Event.Broadcast(EventDefines.TaskPlotCloseGuide)
            end
        )
    else
        self.cb()
        --训练任务个数特殊处理（有现有进程影响跳转选择数量）
        local finish = {}
        if self.conf.finish.type == 121 then
            finish = {
                para1 = self.conf.finish.para1,
                para2 = self.conf.finish.para2 - self.plottask.CurrentProcess,
                type = self.conf.finish.type
            }
        else
            finish = self.conf.finish
        end
        JumpMap:JumpTo(self.conf.jump, finish)
        local strId = tostring(self.conf.id)
        Net.UserInfo.RecordLog(
            4201,
            strId,
            function(rsp)
            end
        )
    end
end

return ItemplotTask
