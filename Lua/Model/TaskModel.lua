--[[
    Function:任务配置
]]
local TaskModel = {}

local BuildModel = import("Model/BuildModel")
TaskModel.TaskInfos = {} --普通任务和宝箱任务信息
TaskModel.RecommendTask = nil --有且仅有一条推荐任务
------------------------
local QueueTasks = {}

--登陆时添加信息
function TaskModel.InitAddTaskInfo(modelTask)
    -----------------------主线任务相关-----------------------
    for _, v in pairs(modelTask.Unlocked) do
        TaskModel.AddTaskInfos(v)
    end
    for _, v in pairs(modelTask.Accomplished) do
        TaskModel.AddTaskInfos(v)
    end
    ---------------------------------------------------------

    -----------------------队列任务相关-----------------------
    local upgradeConfig = ConfigMgr.GetList("configBuildingUpgrades")
    for _, v in pairs(upgradeConfig) do
        if v.guide_order then
            table.insert(QueueTasks, v)
        end
    end
    table.sort(
        QueueTasks,
        function(a, b)
            return a.guide_order < b.guide_order
        end
    )
    ---------------------------------------------------------
end

--填充顺序表内容
function TaskModel.AddTaskInfos(des)
    local configData = TaskModel.SetConfigData(des.Id, des)
    if configData.recommend == 1 then
        TaskModel.RecommendTask = configData
        Event.Broadcast(EventDefines.MesTaskMainTipEvent, TaskModel.RecommendTask)
    else
        TaskModel.TaskInfos[des.Id] = configData
    end
end

--接收通知，只用于更新任务信息
function TaskModel:GetReplaceTaskData(resParams)
    --更新任务信息
    TaskModel.UpdateTaskInfos(resParams[1])
end

--只用于领取奖励后删除任务信息
function TaskModel:GetRemoveTaskInfo(rsp)
    TaskModel.RemoveTaskInfo(rsp.Task.Id)
end

--更新任务数据
function TaskModel.UpdateTaskInfos(taskInfo)
    local isExist = TaskModel.CheckTaskInfoExist(taskInfo.Id)
    if isExist then
        TaskModel.ReplaceTaskInfo(taskInfo)
    elseif not isExist and (not taskInfo.AwardTaken or taskInfo.AwardTaken == false) then
        TaskModel.AddTaskInfos(taskInfo)
    end
end

--更新相关任务
function TaskModel.ReplaceTaskInfo(des)
    local configData = TaskModel.SetConfigData(des.Id, des)
    if configData.recommend == 1 then
        TaskModel.RecommendTask = configData
        Event.Broadcast(EventDefines.MesTaskMainTipEvent, TaskModel.RecommendTask)
    else
        TaskModel.TaskInfos[des.Id] = configData
    end
end

--通过Id删除相关数据
function TaskModel.RemoveTaskInfo(id)
    if TaskModel.RecommendTask and TaskModel.RecommendTask.id == id then
        TaskModel.RecommendTask = nil
        return
    end
    local isExist = TaskModel.CheckTaskInfoExist(id)
    if not isExist then
        return
    end
    TaskModel.TaskInfos[id] = nil
end

--得到推荐任务信息
function TaskModel.GetRecommendTask()
    return TaskModel.RecommendTask
end

--清空推荐任务信息
function TaskModel.ClearRecommendTask()
    TaskModel.RecommendTask = nil
end

--根据任务ID判断是宝箱or推荐任务or普通任务
function TaskModel:GetTaskByType()
    local listBoxTask = {}
    local listComTask = {}
    for _, v in pairs(TaskModel.TaskInfos) do
        if v.recommend == 2 then
            table.insert(listComTask, v)
        elseif v.box == 1 then
            table.insert(listBoxTask, v)
        end
    end
    listBoxTask = self.SetListSort(listBoxTask)
    listComTask = self.SetComTaskSort(listComTask)
    return listBoxTask, TaskModel.RecommendTask, listComTask
end

--宝箱任务排序
function TaskModel.SetListSort(tableList)
    if tableList ~= nil then
        table.sort(
            tableList,
            function(a, b)
                if not a["id"] or not b["id"] then
                    return false
                end
                return a["id"] < b["id"]
            end
        )
    else
        return nil
    end
    return tableList
end

--普通任务排序
function TaskModel.SetComTaskSort(listData)
    table.sort(
        listData,
        function(a, b)
            local aNum = a.AwardTaken == false and 1 or 0
            local bNum = b.AwardTaken == false and 1 or 0
            if aNum == bNum then
                return a["order2"] < b["order2"]
            else
                return aNum > bNum
            end
        end
    )
    return listData
end

--未领取任务数量，用于计算红点
function TaskModel:GetNoticeReadAmount()
    local redNum = 0
    local boxs, recs, commons = self:GetTaskByType()
    if recs and recs.AwardTaken == false then
        redNum = redNum + 1
    end
    for _, v in pairs(commons) do
        if v.AwardTaken == false then
            redNum = redNum + 1
        end
    end
    for _, v in pairs(boxs) do
        if v.AwardTaken == false then
            redNum = redNum + 1
        end
    end
    return redNum
end

--设置配置信息相关数据
function TaskModel.SetConfigData(id, data)
    local configItem = {}
    --新号都走新任务表
    if not Model.MainTaskNewUser and (ABTest.Task_ABLogic() == 2001 or ABTest.Task_ABLogic() == 9999) then
        configItem = ConfigMgr.GetItem("configMainTasks", id)
    else
        configItem = ConfigMgr.GetItem("configNewMainTasks", id)
    end
    if not configItem then
        return
    end
    if data.AwardTaken == false then
        configItem.AwardTaken = data.AwardTaken
    end
    if data.CurrentProcess then
        configItem.CurrentProcess = data.CurrentProcess
    end
    --print("========================================TaskConfigItem>>>>>>", table.inspect(configItem))
    return configItem
end

--查找相关信息通过Id
function TaskModel.CheckTaskInfoExist(id)
    if TaskModel.TaskInfos[id] then
        return true
    else
        return false
    end
end

--设置进度条
function TaskModel.SetProgressValue(conf, cutValue)
    local progress = 0
    local cutProgress = not cutValue and 0 or cutValue
    if conf.finish.type == 152 then
        if conf.finish.para1 == 1 then
            progress = math.floor(conf.finish.para2 / 60)
            cutProgress = math.floor(cutValue / 60)
        elseif conf.finish.para1 == 2 then
            progress = math.floor(conf.finish.para2 / 3600)
            cutProgress = math.floor(cutValue / 3600)
        end
    else
        cutProgress = cutValue
        progress = conf.finish.para2
    end
    return progress, cutProgress
end

--根据ID获得奖励信息
function TaskModel:GetGiftConfById(id)
    local gift = ConfigMgr.GetItem("configGifts", id)
    if gift then
        return gift.res, gift.items
    end
end

--根据ID获得资源信息
function TaskModel:GetResConfById(id)
    local conf = ConfigMgr.GetItem("configResourcess", id)
    return conf.img
end

--根据配置信息读取任务名称和描述国际化表
function TaskModel:GetTaskNameByType(conf, needNum)
    local formatNum = Tool.FormatNumberThousands(conf.finish.para2)
    local params = {num = formatNum, num_x = needNum}
    for i, v in ipairs(conf.trans_key or {}) do
        params["key_" .. i] = StringUtil.GetI18n(conf.trans_I18n[i], v)
    end
    for i, v in ipairs(conf.trans_value or {}) do
        params["value_" .. i] = v
    end
    local typeData = ConfigMgr.GetItem("configTaskTypes", conf.finish.type)
    local name = StringUtil.GetI18n(I18nType.Tasks, typeData.name, params)
    local desc = StringUtil.GetI18n(I18nType.Tasks, typeData.desc, params)
    local info = StringUtil.GetI18n(I18nType.Tasks, typeData.info or "", params)
    return name, desc, info
end

------------------------------------------------------------剧情任务相关------------------------------------------------------------
local freeGuideData = {}
--免费引导缓存
function TaskModel.InitGuideFreeData()
    local freeGuideData = PlayerDataModel:GetData(PlayerDataEnum.FreeGuideData)
    if not freeGuideData or freeGuideData == JSON.null then
        freeGuideData = {}
        freeGuideData["UpgradeFreeGuide"] = 0
        freeGuideData["TrainFreeGuide"] = 0
        freeGuideData["TechFreeGuide"] = 0
        PlayerDataModel:SetData(PlayerDataEnum.FreeGuideData, freeGuideData)
    end
    local tempData = PlayerDataModel:GetData(PlayerDataEnum.FreeGuideData)
end

function TaskModel.GetGuideFreeStageByKey(key)
    freeGuideData = PlayerDataModel:GetData(PlayerDataEnum.FreeGuideData)
    if freeGuideData and freeGuideData[key] == 1 then
        return true
    else
        return false
    end
end

--设置免费引导缓存数据
function TaskModel.SetGuideFreeData(key)
    freeGuideData[key] = 1
    PlayerDataModel:SetData(PlayerDataEnum.FreeGuideData, freeGuideData)
end

--剧情任务
function TaskModel.TaskPlotReview(reviewId)
    return ConfigMgr.GetItem("configChapters", reviewId)
end

function TaskModel.GetRoleConf(roleId)
end

--得到下个剧情对话信息
function TaskModel.GetNextDialogConf(isStart, id, cutIndex)
    local dialogConf = ConfigMgr.GetItem("configChapters", id)
    local nextIndex = cutIndex + 1
    local dialogData = nil
    if isStart then
        dialogData = dialogConf.start_dialog
    else
        dialogData = dialogConf.finish_dialog
    end
    if dialogData and dialogData[nextIndex] then
        return dialogData[nextIndex]
    else
        return nil
    end
end

function TaskModel.GetRoleConf(roleId)
    return ConfigMgr.GetItem("configRoles", roleId)
end

------------------------------------------------------------队列任务相关------------------------------------------------------------
--获取队列相关信息
function TaskModel.GetQueueConfig()
    for i = #QueueTasks, 1, -1 do
        local buildCofigId = QueueTasks[i].id - QueueTasks[i].level
        buildCofigId = math.floor(QueueTasks[i].id / 100) * 100
        local isCity = BuildModel.IsInnerByConfigId(buildCofigId)
        if isCity then
            local building = BuildModel.FindByConfId(buildCofigId)
            if building and not TaskModel.CheckUpgradeLevel(QueueTasks[i], building) then
                table.remove(QueueTasks, i)
            end
        else --外城
            local building = BuildModel.FindMaxLevel(buildCofigId)
            if building and not TaskModel.CheckUpgradeLevel(QueueTasks[i], building) then
                table.remove(QueueTasks, i)
            end
        end
    end
    table.sort(
        QueueTasks,
        function(a, b)
            return a.id < b.id
        end
    )
    return QueueTasks[1]
end

function TaskModel.CheckUpgradeLevel(queueConfig, building)
    if building.Level >= queueConfig.level then
        return false
    end
    return true
end

------------------------------------------------------------章节任务相关------------------------------------------------------------
--根据章节信息获取章节的图标描述等信息
function TaskModel:GetPlotTaskMsg(msg)
    local chapterId = msg.CurrentChapter
    local chapterConfs = ConfigMgr.GetList("configPlotNums")
    local chapterConf = {}
    for _, v in pairs(chapterConfs) do
        if chapterId == v.id then
            chapterConf = v
        end
    end
    if not next(chapterConf) then
        return
    end
    local titlestr = string.format("PLOT_TASK_%d_TITLE", msg.CurrentChapter)
    local finishNum = #msg.AccomplishedPlotTasks
    local sumNum = #chapterConf.include
    local progress = "（" .. finishNum .. "/" .. sumNum .. "）"
    local desc = StringUtil.GetI18n(I18nType.Tasks, chapterConf.desc)
    local title = StringUtil.GetI18n(I18nType.Tasks, chapterConf.title)
    local titlekey = StringUtil.GetI18n(I18nType.Tasks, titlestr)
    local icon = UITool.GetIcon(chapterConf.icon)
    return icon, desc, title, titlekey, progress, finishNum, sumNum
end

--获取当前章节的基础配置信息
function TaskModel:GetBasePlotTasks(IdNum)
    local chapterConfs = ConfigMgr.GetItem("configPlotNums", IdNum)
    return chapterConfs
end

--根据任务Id获取该任务的配置信息
function TaskModel:GetPlotTaskConf(id)
    local allchapterConfs = {}
    if ABTest.Task_ABLogic() == 2001 then
        allchapterConfs = ConfigMgr.GetList("configNewPlotTasks")
    else
        allchapterConfs = ConfigMgr.GetList("configPlotTasks")
    end
    local plotTaskConf = {}
    for _, v in pairs(allchapterConfs) do
        if id == v.id then
            plotTaskConf = v
        end
    end
    return plotTaskConf
end

--及时刷新章节缓存，已完成任务的奖励信息
function TaskModel:UpdateAwardTakens(id)
    for _, v in pairs(Model[ModelType.ChapterTasksInfo].AccomplishedPlotTasks) do
        if id == v.Id then
            v.AwardTaken = true
        end
    end
end

return TaskModel
