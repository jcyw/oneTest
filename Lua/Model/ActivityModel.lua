--author: 	Amu,maxiaolong
--time:		2019-12-03 15:11:25

if _G.ActivityModel then
    return _G.ActivityModel
end
local GD=_G.GD
local BuildModel = import("Model/BuildModel")
local WelfareModel = import("Model/WelfareModel")
local ActivityModel = {}

local RoyalBattleData
----------------日历管理----------------------
ActivityModel._SHOWDAY = 10
ActivityModel.EVENT_DAY_SCROLL = "EVENT_DAY_SCROLL"
----------------活动数据----------------------
ActivityModel.ActivityInfo = {} --活动列表缓存 只需要请求一次
ActivityModel.ActivityData = {{}, {}, {}, {}, {}}
ActivityModel.TypeModel = {Open = 1, Show = 2, Close = 3, All = 4, Calendar = 5}
----------------是否有活动变更----------------
ActivityModel.SingleActivityChange = nil
--断线重连
Event.AddListener(
    EventDefines.NetLoginFromReconnect,
    function()
        ActivityModel.GetNetActivityData()
    end
)
function ActivityModel.GetActivityAward(id)
    local items = {}
    local activityData = ActivityModel.GetActivityConfig(id)
    for _, v in pairs(activityData.show_reward) do
        local item = _G.ConfigMgr.GetItem("configItems", v)
        table.insert(items, item)
    end
    return items
end
--活动表数据
function ActivityModel.GetActivityConfig(id)
    local activityData = _G.ConfigMgr.GetItem("configActivitys", id)
    return activityData
end
--限时比赛表数据
function ActivityModel.GetActivityRaceTime(index)
    local activityData = _G.ConfigMgr.GetItem("configTimeRaces", index)
    return activityData
end
--礼包表数据
function ActivityModel.GetGiftModel(id)
    return _G.ConfigMgr.GetItem("configGifts", id)
end

--获得积分
function ActivityModel.GetActivityTimeRace(stageId)
    local stageData = ActivityModel.GetActivityRaceTime(stageId)
    local intergralData = ActivityModel.GetIntegralByType(stageData.type, stageData.para)
    return intergralData
end

--获得不同阶段奖励
function ActivityModel.GetStageAward(stageId)
    local tempStage = {}
    local timeRaces = ActivityModel.GetActivityRaceTime(stageId)
    local firstData = timeRaces.first_point
    local firstReward = timeRaces.first_reward
    local secondData = timeRaces.second_point
    local secondRward = timeRaces.second_reward
    local thirdData = timeRaces.third_point
    local thirdReward = timeRaces.third_reward
    local centerBuildLevel = BuildModel.GetCenterLevel()
    firstData = firstData[centerBuildLevel]
    firstReward = firstReward[centerBuildLevel]
    secondData = secondData[centerBuildLevel]
    secondRward = secondRward[centerBuildLevel]
    thirdData = thirdData[centerBuildLevel]
    thirdReward = thirdReward[centerBuildLevel]
    tempStage[1] = {point = firstData, reward = firstReward}
    tempStage[2] = {point = secondData, reward = secondRward}
    tempStage[3] = {point = thirdData, reward = thirdReward}
    return tempStage
end

--阶段排名奖励
function ActivityModel.GetRankAwards(stageId)
    local rankAwards = ActivityModel.GetActivityRaceTime(stageId).rank_reward
    local tempAwards = {}
    for _, v in pairs(rankAwards) do
        local giftData = ActivityModel.GetGiftModel(v)
        table.insert(tempAwards, giftData)
    end
    return tempAwards
end

function ActivityModel.GetMaxPowerRanks()
    local tempAwards = {}
    for _1, v1 in pairs(Global.LimitTimeRaceRankReward) do
        local giftData = ActivityModel.GetGiftModel(v1)
        table.insert(tempAwards, giftData)
    end
    return tempAwards
end

--获得不同类型对应积分
function ActivityModel.GetIntegralByType(type, para)
    local func = nil
    if type == 1 then
        func = function(tempId)
            local resCofig = _G.ConfigMgr.GetItem("configResourcess", tempId)
            local resName = _G.StringUtil.GetI18n(_G.I18nType.Commmon, resCofig.key)
            local newName = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "POINT_COLLECT_RES", {res_name = resName})
            return newName
        end
    end
    if type == 2 then ----提升战力 降低战力
        func = function(tempId)
            local str = tempId == 1 and "POINT_PROMOTE_POWER_1" or "POINT_PROMOTE_POWER_2"
            return _G.StringUtil.GetI18n(_G.I18nType.Commmon, str)
        end
    end
    if type == 3 then --造兵
        func = function(tempId)
            return _G.StringUtil.GetI18n(_G.I18nType.Commmon, "POINT_TRAIN_ARMY", {num = tempId})
        end
    end
    if type == 4 then --杀敌
        func = function(tempId)
            return _G.StringUtil.GetI18n(_G.I18nType.Commmon, "POINT_KILL_ENEMY", {num = tempId})
        end
    end
    if type == 5 then
        func = function(tempId) -- 1.建筑提示战力 2.科技提示战力 3.建筑拆除战力减弱
            local str = tempId == 1 and "POINT_BUILD_TECH_1" or (tempId == 2 and "POINT_BUILD_TECH_2" or "POINT_BUILD_TECH_3")
            return _G.StringUtil.GetI18n(_G.I18nType.Commmon, str)
        end
    end
    if type == 6 then
        func = function(tempId)
            local monsterConfig = _G.ConfigMgr.GetItem("configMonsters", tempId)
            return _G.StringUtil.GetI18n(_G.I18nType.Commmon, "POINT_UNION_ARMY", {num = monsterConfig.level})
        end
    end
    return ActivityModel.SetIntegralParams(para, func)
end

function ActivityModel.SetIntegralParams(para, func)
    local configData = {}
    local tempId = {}
    local tempValue = {}
    for _, v in pairs(para) do
        table.insert(tempId, v["x"])
        table.insert(tempValue, v["y"])
    end
    for i = 1, #tempId do
        local keyStr = func(tempId[i])
        local config = {key = keyStr, value = tempValue[i]}
        table.insert(configData, config)
    end
    return configData
end

function ActivityModel.GetActivityData(type)
    return ActivityModel.ActivityData[type]
end

-- 获取活动中心气泡信息
function ActivityModel.GetActivityCenterBubble()
    local result = nil
    local new = {}
    local open = ActivityModel.GetActivityData(ActivityModel.TypeModel.Open)
    for _, v in pairs(open) do
        if ActivityModel.GetActivityIsNew(v.Id) then
            table.insert(new, v)
        end
    end

    if #new > 0 then
        table.sort(
            new,
            function(a, b)
                return a.Config.order < b.Config.order
            end
        )
        result = new[1]
    end

    return result
end

function ActivityModel.SetActivityData()
    ActivityModel.ActivityData[ActivityModel.TypeModel.Open] = {}
    ActivityModel.ActivityData[ActivityModel.TypeModel.Show] = {}
    ActivityModel.ActivityData[ActivityModel.TypeModel.Close] = {}
    ActivityModel.ActivityData[ActivityModel.TypeModel.All] = {}
    ActivityModel.ActivityData[ActivityModel.TypeModel.Calendar] = {}
    local hasclosetype = {}
    for _, v in pairs(ActivityModel.ActivityInfo) do
        local itemConfig = ActivityModel.GetActivityConfig(v.Id)
        if itemConfig.open[1].x == 1 and Model.Player.Level < itemConfig.open[1].y then
            --查看条件是根据指挥中心等级的，不满足的需要过滤
            goto continue
        end
        if (v.EndAt > 0 and v.EndAt - _G.Tool.Time() <= 0) or itemConfig.activity_show ~= 1 then
            --活动结束的 需要过滤
            goto continue
        end
        if v.Open then
            v.Config = itemConfig
            table.insert(ActivityModel.ActivityData[ActivityModel.TypeModel.Open], v)
            table.insert(ActivityModel.ActivityData[ActivityModel.TypeModel.All], v)
            --是否在日历中显示
            if itemConfig.show_calendar then
                table.insert(ActivityModel.ActivityData[ActivityModel.TypeModel.Calendar], v)
            end
            if v.ShowInMain then
                table.insert(ActivityModel.ActivityData[ActivityModel.TypeModel.Show], v)
            end
        end
        local _time = _G.Tool.Time() - v.StartAt
        if not v.Open and not table.contains(hasclosetype, itemConfig.type) and _time < 0 then
            v.Config = itemConfig
            table.insert(hasclosetype, itemConfig.type)

            if math.abs(_time) < v.HideTime then
                table.insert(ActivityModel.ActivityData[ActivityModel.TypeModel.Close], v)
                table.insert(ActivityModel.ActivityData[ActivityModel.TypeModel.All], v)
            end
            if math.abs(_time) < Global.ActivityCalendarReadTime and itemConfig.show_calendar then
                table.insert(ActivityModel.ActivityData[ActivityModel.TypeModel.Calendar], v)
            end
        end
        ::continue::
    end

    --只在五级的时候判断
    if Model.Player.Level == 5 and ActivityModel.GetIsOpenActivity(1001001) then
        GD.SingleActivityAgent.GetSingleActivityInfo()
    end
    Event.Broadcast(EventDefines.RefreshActivityUI)
end

function ActivityModel.GetIsOpenActivity(activityID)
    local data =
        table.find(
        ActivityModel.ActivityData[ActivityModel.TypeModel.Open],
        function(item)
            return item.Id == activityID
        end
    )
    return table.contains(ActivityModel.ActivityData[ActivityModel.TypeModel.Open], data)
end
-- 获取活动的服务器信息
function ActivityModel.GetActivityInfo(activityID)
    for _,v in pairs(ActivityModel.ActivityData[ActivityModel.TypeModel.Open]) do
        if v.Id == activityID then
            return v
        end
    end
    return nil
end

function ActivityModel.GetNetActivityData(cb)
    if next(ActivityModel.ActivityInfo) then
        if cb then
            cb()
        end
    end
    Net.Activity.GetSysActivitiesInfo(
        function(msg)
            ActivityModel.ActivityInfo = msg.Infos
            table.sort(
                ActivityModel.ActivityInfo,
                function(a, b)
                    return a.StartAt < b.StartAt
                end
            )
            ActivityModel.SetActivityData()
            if cb then
                cb()
            end
        end
    )
end

function ActivityModel.GetActivityInfoById(id, callback)
    Net.Activity.GetSysActivitiyInfo(
        id,
        function(msg)
            local index = 0
            for i, v in pairs(ActivityModel.ActivityInfo) do
                if v.Id == msg.Info.Id then
                    index = i
                    ActivityModel.ActivityInfo[i] = msg.Info
                    break
                end
            end
            if index <= 0 then
                table.insert(ActivityModel.ActivityInfo, msg.Info)
                index = #ActivityModel.ActivityInfo
            end
            ActivityModel.SetActivityData()
            if callback then
                callback(index,msg.Info.Id)
            end
        end
    )
end

function ActivityModel.InitActivityData()
    local activityView = PlayerDataModel:GetData(PlayerDataEnum.ActivityView)
    if not activityView or activityView == JSON.null then
        activityView = {}
        activityView["openActivityId"] = {}
    else
        for i = #activityView["openActivityId"], 1, -1 do
            local isExist = false
            for _1, v1 in pairs(ActivityModel.ActivityData[ActivityModel.TypeModel.Open]) do
                if v1.Id == activityView["openActivityId"][i] then
                    isExist = true
                    break
                end
            end
            if not isExist then
                table.remove(activityView["openActivityId"], i)
            end
        end
    end
    PlayerDataModel:SetData(PlayerDataEnum.ActivityView, activityView)
end

--添加使用
function ActivityModel.AddUseActivityData(value)
    local activityView = PlayerDataModel:GetData(PlayerDataEnum.ActivityView)
    for i = #activityView["openActivityId"], 1, -1 do
        if activityView["openActivityId"][i] == value then
            return
        end
    end
    table.insert(activityView["openActivityId"], value)
    PlayerDataModel:SetData(PlayerDataEnum.ActivityView, activityView)
    Event.Broadcast(EventDefines.CloseIsNewTag)
    return ActivityModel.GetActivityIsNew(value)
end

function ActivityModel.GetActivityIsNew(id)
    local activityView = PlayerDataModel:GetData(PlayerDataEnum.ActivityView)
    if not activityView or not activityView.openActivityId then
        return true
    end
    for _, v in pairs(activityView.openActivityId) do
        if v == id then
            return false
        end
    end
    return true
end

function ActivityModel.GetItemConfigById(reward)
    local resData = {}
    local itemsData = {}
    local giftNum, items = nil
    if WelfareModel:GetGiftInfoById(reward, 1) then
        giftNum, items = WelfareModel:GetGiftInfoById(reward, 1)
        resData = {GiftNum = giftNum, Items = items}
    end
    if WelfareModel:GetGiftInfoById(reward, 2) then
        giftNum, items = WelfareModel:GetGiftInfoById(reward, 2)
        itemsData = {GiftNum = giftNum, Items = items}
    end
    return resData, itemsData
end

function ActivityModel.GetItemRewardConfig(rewardId)
    local resData, itemData = ActivityModel.GetItemConfigById(rewardId)
    local listNum = 0
    local itemConfig = {}
    if resData.Items then
        listNum = listNum + resData.GiftNum
        table.insert(itemConfig, {IsRes = true, Item = resData.Items})
    end
    if itemData.Items then
        listNum = listNum + itemData.GiftNum
        table.insert(itemConfig, {IsRes = false, Item = itemData.Items})
    end
    local itemData = {}
    for k, v in pairs(itemConfig) do
        local isRes = v.IsRes
        for k1, v1 in pairs(v.Item) do
            table.insert(itemData, {IsRes = isRes, Item = v1})
        end
    end
    return itemData, listNum
end

function ActivityModel.IsActivityById(activityId, from)
    local actityInfo = ActivityModel.GetActivityConfig(activityId)
    if actityInfo and actityInfo.activity_show == 1 then
        return true
    end
    if not actityInfo then
        Log.Error("not find activityconfig activityId:{0} from:{1}", activityId, from)
    end
    return false
end

--删除在主界面活动数据遍历所有数据不单独处理
function ActivityModel.RemoveActivityInShow()
    for i = #ActivityModel.ActivityData[ActivityModel.TypeModel.Show], 1, -1 do
        if ActivityModel.ActivityData[ActivityModel.TypeModel.Show][i].EndAt - _G.Tool.Time() <= 0 then
            table.remove(ActivityModel.ActivityData[ActivityModel.TypeModel.Show], i)
        end
    end
end
--活动开启 变更状态
function ActivityModel.SetActivityOpen(msg)
    local index = 0
    for i, v in pairs(ActivityModel.ActivityInfo) do
        if v.Id == msg.ActivityId then
            index = i

            local info = ActivityModel.ActivityInfo[i]
            info.Open = true
            info.EndAt = msg.OpenTill
            ActivityModel.ActivityInfo[i] = info
            ActivityModel.SetActivityData()
            Log.Warning("活动开启=========>>>>>ActivityModel.SetActivityOpen "..msg.ActivityId)
            return
        end
    end

    if index <= 0 then
        ActivityModel.GetActivityInfoById(msg.ActivityId,function(id,index)
            Log.Warning("活动开启 新添加的活动=========>>>>>ActivityModel.SetActivityOpen "..msg.ActivityId)
            if ActivityModel.SingleActivityChange and id == 1001001 then
                local info = ActivityModel.ActivityInfo[index]
                info.Stage = ActivityModel.SingleActivityChange.Stage
                info.Trigger = ActivityModel.SingleActivityChange.TriggerId
                info.EndAt = ActivityModel.SingleActivityChange.StageEndAt
                info.ReadyTill = ActivityModel.SingleActivityChange.ReadyTill
                ActivityModel.ActivityInfo[index] = info
                ActivityModel.SetActivityData()
                ActivityModel.SingleActivityChange = nil
            end
        end)
    end
end
--活动状态变更
function ActivityModel.SetActivityChange(msg)
    if not ActivityModel.SingleActivityChange and msg.ActivityId == 1001001 then
        ActivityModel.SingleActivityChange = msg
    end
    for i, v in pairs(ActivityModel.ActivityInfo) do
        if v.Id == msg.ActivityId then
            local info = ActivityModel.ActivityInfo[i]
            info.Stage = msg.Stage
            info.Trigger = msg.TriggerId
            info.EndAt = msg.StageEndAt
            info.ReadyTill = msg.ReadyTill
            ActivityModel.ActivityInfo[i] = info
            ActivityModel.SetActivityData()
            if msg.ActivityId == 1001001 then
                GD.SingleActivityAgent.GetSingleActivityInfo()
            end
            return
        end
    end
    Log.Warning("活动状态变更=========>>>>>ActivityModel.SetActivityChange 没有缓存的活动"..msg.ActivityId)
end
--活动关闭 变更状态
function ActivityModel.SetActivityClose(msg)
    for i, v in pairs(ActivityModel.ActivityInfo) do
        if v.Id == msg.ActivityId then
            ActivityModel.ActivityInfo[i] = nil
            ActivityModel.SetActivityData()
            Log.Warning("活动关闭=========>>>>>ActivityModel.SetActivityClose "..msg.ActivityId)
            return
        end
    end

    ActivityModel.GetNetActivityData()
end

--第三周活动次数跟新
function ActivityModel.RefreshMemoryTimesInfo(rsp)
    for _, v in pairs(_G.Model.MemorialDayInfos and _G.Model.MemorialDayInfos.Infos or {}) do
        if v.Category == rsp.Category then
            v.Times = v.Times - rsp.Amount
        end
    end
end

function ActivityModel.GetMemoryTimesInfo()
    return _G.Model.MemorialDayInfos and _G.Model.MemorialDayInfos.Infos or {}
end

--军备竞技
function ActivityModel.RefreshArmsRaceTimesInfo(rsp)
    for _, v in pairs(_G.Model.ArmsRaceInfos and _G.Model.ArmsRaceInfos.Infos or {}) do
        if v.Category == rsp.Category then
            v.Times = v.Times - rsp.Amount
        end
    end
end

function ActivityModel.GetArmsRaceTimesInfo()
    return _G.Model.ArmsRaceInfos and _G.Model.ArmsRaceInfos.Infos or {}
end

function ActivityModel.ReqRoyalBattle()
    Net.Activity.GetSysActivitiyInfo(
        1000501,
        function(rsp)
            RoyalBattleData = rsp.Info
        end
    )
end

function ActivityModel.IsRoyalBattleOpen()
    if not RoyalBattleData then
        return false
    end
    return RoyalBattleData.Open
end

function ActivityModel.SetRoyalBattleOpen(isOpen)
    if not RoyalBattleData then
        return 
    end
    RoyalBattleData.Open = isOpen
end

function ActivityModel.GetRoyalBattleInfo()
    return RoyalBattleData
end

----------------------王城战活动

_G.ActivityModel = ActivityModel
return ActivityModel
