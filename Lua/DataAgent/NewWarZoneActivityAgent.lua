--[[
    author:{laofu}
    time:2020-07-29 14:57:38
    function:{新城竞赛数据模块}
]]
local GD = _G.GD
local NewWarZoneActivityAgent = GD.LVar("NewWarZoneActivityAgent", {})
local AgentDefine = GD.AgentDefine

local Net = _G.Net
local Global = _G.Global
local I18nType = _G.I18nType
local ConfigMgr = _G.ConfigMgr
local StringUtil = _G.StringUtil

--------------------------function--------------------------

local GetActivityBanner
local GetTaskInfo  --请求-获取新城竞赛任务信息
local GetRankInfo  --请求-获取新城竞赛排名信息
local SortTaskInfo  --分类服务器请求的任务信息
local GetTaskType  --获得任务类型信息,configTaskTypes表
local GetPeakWayRankConifg  --获得configPeakWays表的分类数据
local GetRankStr  --获得排名字符串

--------------------------data--------------------------

local riseWay = {} --configReseWay表数据
local peakWay = {} --configPeakWay表数据
local taskType = {} --configTaskType表数据
local newWarZoneTaskInfo = {} --新城竞赛任务的服务端数据
local taskServerInfoClassified = {} --新城竞赛任务服务端分类信息

--[[
    **********************************
    -- 整理出新城竞赛的活动信息
    -- taskServerInfo包括了所有活动任务，使用Global表里的任务类型进行区分，新城竞赛类型是12
    **********************************
]]
local function SortServerTaskInfoByType(tasksServerInfo)
    --未完成任务
    local unlock = tasksServerInfo.Unlocked
    --已完成任务
    local accomplished = tasksServerInfo.Accomplished
    newWarZoneTaskInfo = {}
    for _, v in pairs(unlock) do
        if v.Type == Global.WarZoneTask then
            table.insert(newWarZoneTaskInfo, v)
        end
    end
    for _, v in pairs(accomplished) do
        if v.Type == Global.WarZoneTask then
            table.insert(newWarZoneTaskInfo, v)
        end
    end
    return newWarZoneTaskInfo
end

--获得configRiseWay表的分类数据
local function GetRiseWayTaskConfig(type)
    if riseWay[type] and next(riseWay[type]) then
        return riseWay[type]
    end

    riseWay[type] = {}
    local configRiseWar = ConfigMgr.GetList("configRiseWays")
    for _, v in pairs(configRiseWar) do
        if v.type == type then
            riseWay[type][v.id] = v
        end
    end

    return riseWay[type]
end

function GetActivityBanner()
    local config = ConfigMgr.GetItem("configActivitys", 1001101)
    return config.banner
end

-- 请求-获取新城竞赛任务信息
function GetTaskInfo(cb)
    Net.WarZone.WarZoneTaskInfo(
        function(msg)
            SortServerTaskInfoByType(msg)
            --当请求新数据时，清空数据，防止保存旧数据
            taskServerInfoClassified = {}
            if cb then
                cb(msg)
            end
        end
    )
end

-- 请求-获取新城竞赛排名信息
function GetRankInfo(cb)
    Net.WarZone.WarZoneRankInfo(
        function(msg)
            if cb then
                cb(msg)
            end
        end
    )
end

--[[
    **********************************
    -- 分类服务器请求的任务信息，并添加config表里数据
    -- 这里的type是三个不同任务的分类
    task = {
            id = riseWay表ID,
            taskType = 任务类型，对应configTaskType表,
            taskPara1 = 参数1，configTaskType表中的para1,
            process = 当前进度,
            maxProcess = 最大进度,
            rewardGift = 奖励礼包，configGift表,
            jumpId = 对应configGetmoreItem表，跳转AccessWay窗口
            finished = 任务是否已邮件发送奖励
        }
    **********************************
]]
function SortTaskInfo(type)
    if taskServerInfoClassified[type] and next(taskServerInfoClassified[type]) then
        return taskServerInfoClassified[type]
    end

    local riseWays = GetRiseWayTaskConfig(type)
    taskServerInfoClassified[type] = {}
    for _, v in pairs(riseWays) do
        local task
        task = {
            id = v.id,
            taskType = v.task.type,
            taskPara1 = v.task.para1,
            maxProcess = v.task.para2,
            rewardGift = v.reward,
            jumpId = v.jump[1].jump,
            jumpPara = v.jump[1].para,
            configType = v.type
        }
        local serverInfo =
            table.find(
            newWarZoneTaskInfo,
            function(data)
                return v.id == data.Id
            end
        )
        if serverInfo.Process then
            task.process = serverInfo.Process
            task.finished = false
        else
            task.process = task.maxProcess
            task.finished = true
        end
        table.insert(taskServerInfoClassified[type], task)
    end
    return taskServerInfoClassified[type]
end

--获得任务类型信息,configTaskTypes表
function GetTaskType(id)
    if next(taskType) then
        return taskType[id]
    end

    taskType = ConfigMgr.GetDictionary("configTaskTypes")
    return taskType[id]
end

--获得configPeakWays表的分类数据
function GetPeakWayRankConifg(type)
    if peakWay[type] and next(peakWay[type]) then
        return peakWay[type]
    end

    peakWay[type] = {}
    local configPeakWay = ConfigMgr.GetList("configPeakWays")
    for _, v in pairs(configPeakWay) do
        if v.type == type then
            table.insert(peakWay[type], v)
        end
    end

    return peakWay[type]
end

--获得排名字符串
function GetRankStr(rankInfo)
    local interval = rankInfo.rank
    if interval[2] then
        local str = StringUtil.GetI18n(I18nType.Commmon, "UI_RANK_NUMBER", {num = interval[1]}) .. "~" .. StringUtil.GetI18n(I18nType.Commmon, "UI_RANK_NUMBER", {num = interval[2]})
        return str
    else
        return StringUtil.GetI18n(I18nType.Commmon, "UI_RANK_NUMBER", {num = interval[1]})
    end
end

AgentDefine(NewWarZoneActivityAgent, "GetActivityBanner", GetActivityBanner)
AgentDefine(NewWarZoneActivityAgent, "GetTaskInfo", GetTaskInfo)
AgentDefine(NewWarZoneActivityAgent, "GetRankInfo", GetRankInfo)
AgentDefine(NewWarZoneActivityAgent, "SortTaskInfo", SortTaskInfo)
AgentDefine(NewWarZoneActivityAgent, "GetTaskType", GetTaskType)
AgentDefine(NewWarZoneActivityAgent, "GetPeakWayRankConifg", GetPeakWayRankConifg)
AgentDefine(NewWarZoneActivityAgent, "GetRankStr", GetRankStr)

return NewWarZoneActivityAgent
