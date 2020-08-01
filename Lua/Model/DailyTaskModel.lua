if DailyTaskModel then
    return DailyTaskModel
end
local DailyTaskModel = {}
local DailyRedAmount = 0
--完成新任务列表
local newFinishTask = {}
local TaskStateType = {
    normal = 1,
    accomp = 2,
    lock = 3
}

function DailyTaskModel:GetNewFinishList()
    return newFinishTask
end

function DailyTaskModel:DailyTaskInit()
    self.dailyTasks = {}
    self.TaskState = TaskStateType
    self.dailyTasks = ConfigMgr.GetList("configDailyTasks")
    for i = #self.dailyTasks, 1 - 1 do
        self.dailyTasks.StateType = self.TaskState.normal
    end
    return self.dailyTasks
end

function DailyTaskModel.GetUnlockLevel(unlockId)
    local upgradeConfig = GameUtil.Clone(ConfigMgr.GetItem("configBuildingUpgrades", unlockId))
    return upgradeConfig.level
end

function DailyTaskModel:GetDailyTaskItemById(dailyId)
    local item = {}
    item = ConfigMgr.GetItem("configDailyTasks", dailyId)
    return item
end

function DailyTaskModel:GetConfTaskByRsp(dailyTasksRsp, accompTaskRsp, accomplishedAward)
    if not dailyTasksRsp then
        return
    end
    self.TaskDataList = {}
    self.TaskBoxList = {}
    for _, listValue in pairs(accomplishedAward) do
        local boxItem = self:GetDailyTaskItemById(listValue.Id)
        if listValue.IsAwardTaken then
            boxItem.isAward = listValue.IsAwardTaken
        end
        boxItem.isOpenBox = true
        table.insert(self.TaskBoxList, boxItem)
    end
    for _, v in pairs(dailyTasksRsp) do
        local taskData = v
        local itemData = self:GetDailyTaskItemById(taskData.Id)
        itemData.finished = v.Finished
        itemData.StateType = self.TaskState.normal
        if not itemData.delete then
            table.insert(self.TaskDataList, itemData)
        end
    end

    for _, value in pairs(accompTaskRsp) do
        local accompTask = value
        local accompItem = self:GetDailyTaskItemById(accompTask.Id)
        accompItem.StateType = self.TaskState.accomp
        accompItem.finished = accompItem.times
        --完成
        if not accompItem.delete then
            table.insert(self.TaskDataList, accompItem)
        end
    end

    for i = #self.dailyTasks, 1, -1 do
        if tonumber(self.dailyTasks[i].box) == 1 and self:IsSame(self.dailyTasks[i], self.TaskBoxList) == false then
            self.dailyTasks[i].StateType = self.TaskState.normal
            local dailyBoxTask = self.dailyTasks[i]
            dailyBoxTask.isOpenBox = false
            dailyBoxTask.isAward = false
            table.insert(self.TaskBoxList, self.dailyTasks[i])
        elseif self.dailyTasks[i].box == nil and self:IsSame(self.dailyTasks[i], self.TaskDataList) == false then
            self.dailyTasks[i].StateType = self.TaskState.lock
            self.dailyTasks[i].finished = 0
            if not self.dailyTasks[i].delete then
                table.insert(self.TaskDataList, self.dailyTasks[i])
            end
        end
    end

    table.sort(
        self.TaskDataList,
        function(a, b)
            local a0 = a.StateType
            local b0 = b.StateType
            local a1 = tonumber(a.order)
            local b1 = tonumber(b.order)
            if a0 ~= b0 then
                return a0 < b0
            else
                local decimalNum = Tool.GetPreciseDecimal(a.finished / a.times, 2)
                local progressNum = decimalNum * 100
                local decimalNum1 = Tool.GetPreciseDecimal(b.finished / b.times, 2)
                local progressNum1 = decimalNum1 * 100
                if progressNum == progressNum1 then
                    if a1 == b1 then
                        return a.id < a.id
                    else
                        return a1 < b1
                    end
                else
                    return progressNum > progressNum1
                end
            end
        end
    )
    table.sort(
        self.TaskBoxList,
        function(a, b)
            return a.id < b.id
        end
    )
    return self.TaskDataList, self.TaskBoxList
end

function DailyTaskModel:IsSame(item, list)
    local isSame = nil

    if #list == 0 then
        return false
    end

    for i, value in pairs(list) do
        if item.id == value.id then
            isSame = true
            break
        else
            isSame = false
        end
    end
    return isSame
end

function DailyTaskModel:ContainList(value, isBox)
    local list = {}
    if (isBox == true) then
        list = self.TaskBoxList
    else
        list = self.TaskDataList
    end
    if not list or #list == 0 then
        return nil
    end
    for i, v in pairs(list) do
        if v == value then
            return value
        else
            return nil
        end
    end
end

function DailyTaskModel:GetBoxList()
    return self.TaskBoxList
end


function DailyTaskModel.GetDailyRedData(cb)
    DailyRedAmount = 0
    Net.DailyTask.GetDailyTaskInfo(
        function(rsp)
            DailyRedAmount = 0
            for _, v in pairs(rsp.AccomplishedAward) do
                if v.IsAwardTaken == false then
                    DailyRedAmount = DailyRedAmount + 1
                end
            end
            if cb then
                cb(DailyRedAmount)
            end
        end
    )
end

--返回所用红点数量
function DailyTaskModel.GetRedAmount()
    return DailyRedAmount
end
--添加红点数通过通知
function DailyTaskModel.AddRedAmount(amount)
    DailyRedAmount = DailyRedAmount + amount
end

--红点数减1
function DailyTaskModel.RemoveRedData()
    DailyRedAmount = DailyRedAmount - 1
    print("dailyRedAmount:-----------:", DailyRedAmount)
end

function DailyTaskModel.GetBoxAwardConfid(baseLevel, award)
    if baseLevel > 30 then
        return
    end
    local awardId = baseLevel + award
    return tonumber(awardId)
end

function DailyTaskModel.GetBaseLevel(func)
    Net.DailyTask.GetDailyTaskInfo(
        function(rsp)
            local baseLevel = rsp.BaseLevel
            func(baseLevel)
        end
    )
end

return DailyTaskModel
