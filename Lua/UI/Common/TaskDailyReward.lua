local TaskDailyReward = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/TaskDailyReward", TaskDailyReward)
local WelfareModel = import("Model/WelfareModel")
TaskDailyReward.dailyRewardPopup = import("UI/Task/TaskDailyBoxRewardPopup")
local dailyTaskModel = import("Model/DailyTaskModel")
local progressMax = 1000
local boxNum = 8
local ProgressBreakPercent = {8, 20, 33, 45, 57, 70, 82, 95, 100}
local effectDic = {}
function TaskDailyReward:ctor()
    self._progress = self:GetChild("progressBar")
    self.boxArray = {}
    self.pointArray = {}
    for i = 1, boxNum do
        local tempBox = self:GetChild("box" .. tostring(i))
        local tempBoxPoint = self:GetChild("point" .. tostring(i))
        local point = tempBoxPoint:GetController("c1")
        point.selectedIndex = 1
        tempBox:GetController("C1").selectedIndex = 0
        table.insert(self.pointArray, tempBoxPoint)
        table.insert(self.boxArray, tempBox)
        local effect = {front = nil, behind = nil}
        effectDic[i] = effect
    end
    for i = 1, #self.boxArray do
        self:AddListener(
            self.boxArray[i].onClick,
            function(content)
                self.dailyRewardPopup.selectIndex = i
                local boxC1 = self.boxArray[i]:GetController("C1").selectedIndex
                UIMgr:Open("TaskDailyBoxRewardPopup", self.config, self.level, self, self.dailyTask, boxC1)
            end
        )
    end
    self._progress.max = progressMax
end

function TaskDailyReward:SetDailyData(config, progressValue, baseLevel, dailyTask)
    self.config = config
    self.dailyRewardPopup.rewardConfig = self.config
    self.level = baseLevel
    self.dailyTask = dailyTask
    local maxIntergralNum = 0
    local newProgressValue = 0
    self.finishTable = {}
    for i = 1, #config do
        local item = config[i]
        local intergralNum = config[i].finish.para2
        if intergralNum > maxIntergralNum then
            maxIntergralNum = intergralNum
        end
        local btn = self.boxArray[i]
        local controller = btn:GetController("C1")
        local point = self.pointArray[i]
        local pointC1 = point:GetController("c1")
        self.boxArray[i]:GetChild("title").text = tostring(intergralNum)
        table.insert(self.finishTable, intergralNum)
        if item.isOpenBox and not item.isAward then
            controller.selectedIndex = 1
            pointC1.selectedIndex = 1
        elseif item.isAward then
            controller.selectedIndex = 2
            pointC1.selectedIndex = 1
        else
            controller.selectedIndex = 0
            pointC1.selectedIndex = 0
        end
        self:PlayBoxEffect(btn, i)
    end
    local maxIntergral = GlobalMisc.DailyTaskMaxPoint
    --添加最大奖励值
    table.insert(self.finishTable, maxIntergral)

    if progressValue > 0 then
        newProgressValue = self:SetProgress(progressValue)
    elseif progressValue == 0 then
        for key, v in pairs(self.boxArray) do
            v:GetController("C1").selectedIndex = 0
            self:PlayBoxEffect(v, key)
        end
        for point, value in pairs(self.pointArray) do
            value:GetController("c1").selectedIndex = 0
        end
    end
    self._progress.value = newProgressValue
    self:SetRewardPos()
end

function TaskDailyReward:SetProgress(value)
    local lastPoint = 0
    local progressValue = 100
    for i, amount in ipairs(self.finishTable) do
        if value < amount then
            progressValue = (value - lastPoint) / (amount - lastPoint)
            local lastPercent = ProgressBreakPercent[i - 1] or 0
            progressValue = progressValue * ProgressBreakPercent[i] + (1 - progressValue) * lastPercent
            break
        end
        lastPoint = amount
    end
    return progressValue * 10
end

function TaskDailyReward:SetBoxView(itemData)
    local index = 0
    local datas = dailyTaskModel:GetBoxList()
    if not datas then
        return
    end
    for i = 1, #datas do
        if datas[i].id == itemData.id then
            index = i
            break
        end
    end
    local boxBtn = self.boxArray[index]
    if boxBtn ~= nil then
        local c1Controller = boxBtn:GetController("C1")
        c1Controller.selectedIndex = 2
        self:PlayBoxEffect(boxBtn, index)
    end
end

--设置日常任务列表位置
function TaskDailyReward:SetRewardPos()
    local boxAwardId = 0
    for i = 1, 8 do
        local selectedIndex = self.boxArray[i]:GetController("C1").selectedIndex
        if selectedIndex == 1 then
            boxAwardId = i
            break
        end
    end
    if (boxAwardId ~= 0) then
        self.scrollPane.percX = boxAwardId / 8
    else
        self.scrollPane.percX = self._progress.value / self._progress.max
    end
end

function TaskDailyReward:TaskDailyRewardClear()
    self.dailyRewardPopup.selectIndex = 0
    self.dailyRewardPopup.rewardConfig = {}
    self.dailyRewardPopup:Close()
end

function TaskDailyReward:GetData()
    return self.config
end

--播放宝箱特效
function TaskDailyReward:PlayBoxEffect(tempBox, index)
    self:ScheduleOnceFast(
        function()
            local c1Controller = tempBox:GetController("C1")
            local effects = effectDic[index]
            if c1Controller.selectedIndex == 1 then
                effects.front, effects.behind = AnimationModel.GiftEffect(tempBox, nil, Vector3(0.6, 0.6, 1), "TaskDailyReward" .. index, effects.front, effects.behind)
            else
                AnimationModel.DisPoseGiftEffect("TaskDailyReward" .. index, effects.front, effects.behind)
            end
        end,
        0.2
    )
end

return TaskDailyReward
