--[[
    Author:maxiaolong
    Time:2019/09/28 10:56
    Function:福利中心数据
]]
local GD = _G.GD
import("Common/luaJson")
local WelfareModel = {}
local WelFarePageSwitch = {}
local MonthCardData = {}
local activieTable = {}
local JsonTable = {}
local curentType
local ActivitiesInfos = {}
local ActiveActivities = {}

WelfareModel.WelfarePageType = {
    NOTYPE = 0,
    --理财基金
    FUNTYPE = 1900101,
    --超值好礼
    SPECIALGIFTTYPE = 1900201,
    --豪华特权
    PRIVILEGETYPE = 1900202,
    --成长基金
    GROWTHCAPITALTYPE = 1900203,
    -- --新手储
    NEWBIESTORE = 1900301,
    --连储
    CONTINUESTORE = 19004016,
    --每储
    EVERYTIMESTORE = 1900402,
    --累加储
    ADDUPSTORE = 1900403,
    --无限储值
    INFINITYSTORE = 1900404,
    --单次储值
    SINGLESTORE = 1900405,
    --长期签到
    DAILY_ATTENDANCE = 1900001,
    --新手签到
    CUMULATIVE_ATTENDANCE = 1900502,
    --七日活动
    SEVEN_DAY_ACTIVITY = 1900601,
    --赌场集结
    GAMBLING_ACTIVITY = 1900701,
    --日常任务
    DAILYTASK_ACTIVITY = 1900002,
    --侦查活动
    DETECT_ACTIVITY = 1900801,
    --猎鹰行动
    FALCON_ACTIVITY = 1900901,
    --长留基金
    GEMFUND_ACTIVITY = 1900902,
    --猎狐犬行动
    HUNTINGDOG_GEMFUND_ACTIVITY = 1901001,
    --国旗纪念日
    MEMORIALDAY_ACTIVITY = 1900802,
    --钻石基金
    DIAMOND_FUND_ACTIVITY = 1900903,
    --幸运转盘
    LUCKYTURNTABLE_ACTIVITY = 1900406,
}

WelfareModel.ActivityID = {
    EVERYDAT = 1, --每日
    CONTIUNE = 2, --连续
    ADDUP = 3, --累加
    INFINITY = 4, --无限
    SINGLE = 5, --单个
    NOOB = 6 --新手
}

--共用模板赌场集结类型
WelfareModel.TemplateType = {
    BaseType = 1,
    --侦查活动
    Detect = 2,
    --猎狐犬活动
    HuntingDog = 3,
    --纪念日
    MemorialDay = 4
}
local toActivity = {}

function WelfareModel:GetToActivityById(id)
    local index = 0
    for i, v in pairs(toActivity) do
        index = index + 1
        if v.activityId == id then
            return v, index
        end
    end
    return nil
end

function WelfareModel:SetToActivity(params)
    local isSame = false
    --判断有没有相同活动Id
    for i, v in pairs(toActivity) do
        if v.activityId == params.activityId then
            v.amount = params.amount
            isSame = true
        end
    end
    if isSame == false then
        table.insert(toActivity, params)
    end
end

function WelfareModel:AwardFinishToAct(params)
    for i, v in pairs(params) do
        local activityId = tonumber(v.ActivityId)
        local amount = tonumber(v.Amount)
        local tempTable = {
            activityId = activityId,
            amount = amount
        }
        self:SetToActivity(tempTable)
    end
end

--得到活动
function WelfareModel:GetToActivity()
    return toActivity
end

--返回所有红点提示信息数量
function WelfareModel:GetRedAmount()
    local sumNums = 0
    for i, v in pairs(toActivity) do
        sumNums = sumNums + v.amount
    end
    return sumNums
end

--通过活动ID得到索引
function WelfareModel:GetPageActByIndexId(index)
    local index = tonumber(index)
    local actId = -1
    if index == self.WelfarePageType.FUNTYPE then --理财基金
        actId = 0
    elseif index == self.WelfarePageType.EVERYTIMESTORE then
        actId = self.ActivityID.EVERYDAT
    elseif index == self.WelfarePageType.CONTINUESTORE then
        actId = self.ActivityID.CONTIUNE
    elseif index == self.WelfarePageType.ADDUPSTORE then
        actId = self.ActivityID.ADDUP
    elseif index == self.WelfarePageType.INFINITYSTORE then
        actId = self.ActivityID.INFINITY
    elseif index == self.WelfarePageType.SINGLESTORE then
        actId = self.ActivityID.SINGLE
    elseif index == self.WelfarePageType.NEWBIESTORE then
        actId = self.ActivityID.NOOB
    end
    return actId
end

--检查福利活动是否开启
function WelfareModel.CheckActiviyExist(id)
    local activitys = WelfareModel.GetActiveActivityId()
    for _, v in pairs(activitys) do
        if v == id then
            return true
        end
    end
    return false
end

function WelfareModel:IsRedWelfare(activityId)
    local reValue = self:GetToActivityById(activityId)
    if reValue == nil then
        return false
    else
        return true
    end
end

--设置红点状态
function WelfareModel:SetRedStatus(activityId)
    local data, index = self:GetToActivityById(activityId)
    if #toActivity == 0 and data == nil then
        return
    end
    local actData, index = self:GetToActivityById(activityId)
    actData.amount = actData.amount - 1
    self:SetToActivity(actData)
    if actData.amount <= 0 then
        table.remove(toActivity, index)
        return true
    end
    return false
end

function WelfareModel.GetCurentActivity()
    return curentType
end

function WelfareModel.SetCurentActivity(type)
    curentType = type
end

function WelfareModel.SetWelfarePage(key, value)
    WelFarePageSwitch[key] = value
end
function WelfareModel:GetWelfarePageTable(key)
    local fSwitch = WelFarePageSwitch[key]
    if fSwitch then
        local result = fSwitch
    else
        Log.Info("No Found Function")
    end
    return fSwitch
end

function WelfareModel:GetWelfareAllPage()
    if not WelFarePageSwitch then
        return
    end
    return WelFarePageSwitch
end

function WelfareModel.GetActivieList()
    if #activieTable > 0 then
        return activieTable
    end
    local activitylist = ConfigMgr.GetList("configActivitys")
    for _,v in ipairs(activitylist) do
        if v.activity_show~=1 then
            table.insert(activieTable,v)
        end
    end
    --根据Order排序
    table.sort(
        activieTable,
        function(a, b)
            return a.order < b.order
        end
    )
    return activieTable
end

--得到月卡信息
function WelfareModel:GetMonthCardAllData()
    MonthCardData = ConfigMgr.GetList("configMonthlyPacks")
    return MonthCardData
end

function WelfareModel:GetMonthCard(id)
    MonthCardData = ConfigMgr.GetItem("configMonthlyPacks", id)
    return MonthCardData
end

local MonthCardMsgInfo = {}

--设置月卡信息
function WelfareModel.SetMonthCardData(msg)
    MonthCardMsgInfo = {}
    MonthCardMsgInfo = msg
end

--更新月卡信息
function WelfareModel.UpdateMonthCardData(cardInfo)
    local info, index = WelfareModel.GetMonthCardInfoById(cardInfo.Id)
    MonthCardMsgInfo[index].Id = cardInfo.Id or MonthCardMsgInfo[index].Id
    MonthCardMsgInfo[index].IsActivated = cardInfo.IsActivated or MonthCardMsgInfo[index].IsActivated
    MonthCardMsgInfo[index].NextTime = cardInfo.NextTime or MonthCardMsgInfo[index].NextTime
    MonthCardMsgInfo[index].RestTimes = cardInfo.RestTimes or MonthCardMsgInfo[index].RestTimes
    MonthCardMsgInfo[index].ExpiryTime = cardInfo.ExpiryTime or MonthCardMsgInfo[index].ExpiryTime
    --MonthCardMsgInfo[index] = cardInfo--{Id = cardInfo.Id, IsActivated = cardInfo.IsActivated, RestTimes = cardInfo.RestTimes,NextTime = cardInfo.NextTime}
end

function WelfareModel.GetMonthCardInfoById(id)
    local info = nil
    local index = 0
    local temIndex = 0
    for _, v in ipairs(MonthCardMsgInfo) do
        index = index + 1
        if MonthCardMsgInfo[index].Id == id then
            info = MonthCardMsgInfo[index]
            temIndex = index
            break
        end
    end
    return info, temIndex
end

--获取月卡信息
function WelfareModel.GetMonthCardMsg()
    return MonthCardMsgInfo
end

local function GetArrayValue(array, index)
    local tempIndex = 0
    for key, v in pairs(array) do
        tempIndex = tempIndex + 1
        if tempIndex == index then
            return v
        end
    end
end

function WelfareModel.DicKeyByIndex(index, dic, isFirst)
    local dicIndex = 0
    for key, value in pairs(dic) do
        dicIndex = dicIndex + 1
        if index == dicIndex then
            local tempParam = isFirst == true and GetArrayValue(value, 1) or GetArrayValue(value, 2)
            return tempParam
        end
    end
end

--获得每日存储奖品列表
function WelfareModel:GetGiftInfoById(giftId, type)
    local giftItems = nil
    local giftNum = 0
    if type == 1 then
        giftItems = ConfigMgr.GetItem("configGifts", tonumber(giftId)).res
    elseif type == 2 then
        giftItems = ConfigMgr.GetItem("configGifts", tonumber(giftId)).items
    end
    if not giftItems then
        return
    end
    giftNum = #giftItems
    local items = {}
    for key, v in pairs(giftItems) do
        local tempItemData = nil
        if type == 2 then
            tempItemData = ConfigMgr.GetItem("configItems", tonumber(v.confId))
        elseif type == 1 then
            tempItemData = ConfigMgr.GetItem("configResourcess", tonumber(v.category))
        end

        local itemData = {tempItemData, v.amount}
        table.insert(items, itemData)
    end
    return giftNum, items
end

--每日存储兑换信息
function WelfareModel.EveryDayCrayInfo(activityId)
    local carzyInfo = ConfigMgr.GetItem("configCrazyExchanges", activityId)
    return carzyInfo.gift, carzyInfo.cost, carzyInfo.limit
end

--获得连续存续信息
function WelfareModel:GetContiuneActive()
end

function WelfareModel:JsonActiveTable(str)
    local tableStr = string.gsub(str, "/'", "")
    return luaJson.JsonStrToLuaTable(tableStr)
end

--二分查找最接近索引
function WelfareModel:Get_near_index(value, array)
    local ret_index = 0
    local left_index = 1
    local right_index = #array
    local mid_index = 0
    local left_abs = 0
    local right_abs = 0
    while (left_index ~= right_index) do
        mid_index = (right_index + left_index) / 2
        mid_index = math.floor(mid_index + 0.5)
        local tempValue = array[mid_index]
        if value <= tempValue then
            right_index = mid_index
        else
            left_index = mid_index
        end
        if right_index - left_index < 2 then
            break
        end
    end
    local left_abs = math.abs(array[left_index] - value)
    local right_abs = math.abs(array[right_index] - value)
    ret_index = right_abs <= left_abs and right_index or left_index
    return ret_index
end

function WelfareModel:AddWelfareValue(progressNum, finishTable, baseProgess, baseIndex, reallyCell)
    local baseNum = finishTable[baseIndex]
    if baseNum >= finishTable[#finishTable] then
        return baseNum
    end
    local nextNum = finishTable[baseIndex + 1]
    local radioValue = math.abs(baseNum - nextNum)
    local baseReally = reallyCell * (baseIndex - 1)
    local tempNum = math.abs(progressNum - baseProgess)
    local addTempNume = tempNum > 0 and (tempNum / radioValue) * reallyCell or 0
    progressNum = baseReally + addTempNume
    return progressNum
end

--得到上个值
function WelfareModel:GetProgressValue(mValue, array, reallyCell)
    local retIndex = self:Get_near_index(mValue, array)
    local tempIndex = 0
    if mValue >= array[retIndex] then
        tempIndex = retIndex
    else
        tempIndex = retIndex - 1
    end
    return self:AddWelfareValue(mValue, array, array[tempIndex], tempIndex, reallyCell), tempIndex
end

-- 每个活动数据的前段缓存
function WelfareModel.GetActivitiesInfo()
    return ActivitiesInfos
end

function WelfareModel.GetActivityInfoByID(id)
    return ActivitiesInfos[id]
end

-- 福利中心开启的活动id,游戏启动时缓存,数据由后端推送来做修改
function WelfareModel.SetActiveActivityId(ids)
    table.sort(
        ids,
        function(a, b)
            return a < b
        end
    )
    ActiveActivities = ids
    -- 判定猎鹰行动是否开启
    Model.isFalconOpen = false
    for i = 1, #ids do
        if (WelfareModel.WelfarePageType.FALCON_ACTIVITY == ActiveActivities[i]) then
            Model.isFalconOpen = true
            return
        end
    end
end

function WelfareModel.SetTestActivityId(id)
    table.insert(ActiveActivities, id)
end

function WelfareModel.GetActiveActivityId()
    return ActiveActivities
end

function WelfareModel.GetActivityShowPag(activityId)
    local showSet = 2 -- 默认福利中心分页
    local cfg = ConfigMgr.GetItem("configActivitys", activityId)
    if cfg then
        showSet = cfg.show_set
    end
    local activity = {}
    for _, id in ipairs(ActiveActivities) do
        local activityCfg = ConfigMgr.GetItem("configActivitys", id)
        if activityCfg and activityCfg.show_set == showSet then
            table.insert(activity,id)
        end
    end

    return showSet,activity
end


function WelfareModel.IsActivityOpen(type)
    for _, id in ipairs(ActiveActivities) do
        if id == type then
            return true
        end
    end
    return false
end

function WelfareModel.ActivityOpen(value)
    local index = 1
    for i, v in ipairs(ActiveActivities) do
        if value == v then
            index = -1
            break
        elseif value < v then
            index = i
            break
        end
    end
    if index > 0 then
        table.insert(ActiveActivities, index, value)
    end
end

function WelfareModel.ActivityClose(value)
    local index = -1
    for i, v in ipairs(ActiveActivities) do
        if value == v then
            index = i
            break
        end
    end
    if index > 0 then
        -- print("CloseActivity----------------------")
        table.remove(ActiveActivities, index)
    end
end

-- 从后端请求数据更改前段缓存的数据
function WelfareModel.GetRookieSignInfos(callback)
    Net.Sign.GetRookieSignInfos(
        function(rsp)
            ActivitiesInfos[WelfareModel.WelfarePageType.CUMULATIVE_ATTENDANCE] = rsp
            if callback then
                callback(rsp)
            end
        end
    )
end

function WelfareModel.RookieSign(callback)
    Net.Sign.RookieSign(
        function()
            local datas = ActivitiesInfos[WelfareModel.WelfarePageType.CUMULATIVE_ATTENDANCE]
            local infos = datas.Infos
            datas.CanSign = false
            for i, v in ipairs(infos) do
                if not v.Signed then
                    infos[i].Signed = true
                    break
                end
            end
            if callback then
                callback(datas)
            end
        end
    )
end

function WelfareModel.GetDailySignInfos(callback)
    Net.Sign.GetDailySignInfos(
        function(rsp)
            ActivitiesInfos[WelfareModel.WelfarePageType.DAILY_ATTENDANCE] = rsp
            if callback then
                callback(rsp)
            end
        end
    )
end

function WelfareModel.CheckDailySigned()
    if ActivitiesInfos[WelfareModel.WelfarePageType.DAILY_ATTENDANCE] then
        return ActivitiesInfos[WelfareModel.WelfarePageType.DAILY_ATTENDANCE].Signed
    end
end

function WelfareModel.CheckCumulativeSigned()
    if ActivitiesInfos[WelfareModel.WelfarePageType.CUMULATIVE_ATTENDANCE] then
        return not ActivitiesInfos[WelfareModel.WelfarePageType.CUMULATIVE_ATTENDANCE].CanSign
    end
end

function WelfareModel.IsCumulativeAllGet()
    if ActivitiesInfos[WelfareModel.WelfarePageType.CUMULATIVE_ATTENDANCE] then
        local infos = ActivitiesInfos[WelfareModel.WelfarePageType.CUMULATIVE_ATTENDANCE].Infos
        for i, v in ipairs(infos) do
            if not v.Signed then
                return false
            end
        end
        return true
    end
    return true
end

function WelfareModel.DailySign(callback)
    Net.Sign.DailySign(
        function(rsp)
            local data = ActivitiesInfos[WelfareModel.WelfarePageType.DAILY_ATTENDANCE]
            data.Signed = true
            for _, info in ipairs(data.Infos) do
                if info.Signed == false then
                    info.Signed = true
                    break
                end
            end
            if callback then
                callback(data)
            end
        end
    )
end

function WelfareModel.SevenDaysActivityInfo(callback)
    Net.SevenDaysActivity.SevenDaysActivityInfo(
        function(rsp)
            ActivitiesInfos[WelfareModel.WelfarePageType.SEVEN_DAY_ACTIVITY] = rsp
            if callback then
                callback(rsp)
            end
        end
    )
end

function WelfareModel.GetSevenDaysTaskReward(taskId, callback)
    Net.SevenDaysActivity.GetSevenDaysTaskReward(
        taskId,
        function(rsp)
            if callback then
                callback(rsp)
            end
        end
    )
end

function WelfareModel.GetSevenDaysTaskBonus(bonusId, callback)
    Net.SevenDaysActivity.GetSevenDaysTaskBonus(
        bonusId,
        function(rsp)
            if callback then
                callback(rsp)
            end
        end
    )
end

function WelfareModel.GetGiftInfo(giftId)
    local giftData = ConfigMgr.GetItem("configGifts", giftId)
    return giftData
end

function WelfareModel.GetGrowFundInfo()
    local growthFundData = ConfigMgr.GetList("configGrowthFunds")
    return growthFundData
end

function WelfareModel.GetGrowItemInfo(id)
    return ConfigMgr.GetItem("configGrowthFunds", id)
end

function WelfareModel.SetGrowList(id, list)
    if list[id] then
        list[id].isAwarded = true
    end
end

function WelfareModel.GetNetFundInfo(callback)
    Net.Purchase.GetGrowthFundInfo(
        function(rsp)
            if callback then
                callback(rsp)
            end
        end
    )
end

function WelfareModel.GetNetRewardFundInfo(category, callback)
    Net.Purchase.GetGrowthFundAward(
        category,
        function(rsp)
            if callback then
                callback(rsp)
            end
        end
    )
end

function WelfareModel.GetCasinoInfo(rsp)
    local tempList = {}
    for k, v in pairs(rsp.Accomplished) do
        local itemData = ConfigMgr.GetItem("configCasinoRewards", v.Id)
        --已经完成
        itemData.isAccomplished = true
        itemData.CurrentProcess = v.CurrentProcess
        itemData.AwardTaken = v.AwardTaken
        table.insert(tempList, itemData)
    end
    for k1, v1 in pairs(rsp.Unlocked) do
        local unLockItem = ConfigMgr.GetItem("configCasinoRewards", v1.Id)
        unLockItem.isAccomplished = false
        unLockItem.CurrentProcess = v1.CurrentProcess
        unLockItem.AwardTaken = false
        table.insert(tempList, unLockItem)
    end
    table.sort(
        tempList,
        function(a, b)
            return a.id < b.id
        end
    )
    return tempList
end

function WelfareModel.GetHuntingDogInfo(rsp)
    local tempList = {}
    for k, v in pairs(rsp.Accomplished) do
        local itemData = ConfigMgr.GetItem("configFoxHounds", v.Id)
        --已经完成
        itemData.isAccomplished = true
        itemData.CurrentProcess = v.CurrentProcess
        itemData.AwardTaken = v.AwardTaken
        table.insert(tempList, itemData)
    end
    for k1, v1 in pairs(rsp.Unlocked) do
        local unLockItem = ConfigMgr.GetItem("configFoxHounds", v1.Id)
        unLockItem.isAccomplished = false
        unLockItem.CurrentProcess = v1.CurrentProcess
        unLockItem.AwardTaken = false
        table.insert(tempList, unLockItem)
    end
    table.sort(
        tempList,
        function(a, b)
            return a.id < b.id
        end
    )
    return tempList
end

--得到个人或者联盟相关数据，通过isUnion
function WelfareModel.GetDetectConfig(rsp)
    local personTable = {}
    local unionTable = {}
    for _, v in pairs(rsp.Accomplished) do
        local itemData = ConfigMgr.GetItem("configInvestigations", v.Id)
        --已经完成
        itemData.isAccomplished = true
        itemData.CurrentProcess = v.Process
        itemData.AwardTaken = v.AwardTaken
        if itemData.alliance then
            table.insert(unionTable, itemData)
        else
            table.insert(personTable, itemData)
        end
    end
    for _, v1 in pairs(rsp.Unlocked) do
        local unLockItem = ConfigMgr.GetItem("configInvestigations", v1.Id)
        unLockItem.isAccomplished = false
        unLockItem.CurrentProcess = v1.Process
        unLockItem.AwardTaken = false
        if unLockItem.alliance then
            table.insert(unionTable, unLockItem)
        else
            table.insert(personTable, unLockItem)
        end
    end

    local function funcSort(params)
        table.sort(
            params,
            function(a, b)
                return a.id < b.id
            end
        )
    end
    funcSort(personTable)
    funcSort(unionTable)
    return personTable, unionTable
end

function WelfareModel.ConfigFund()
    return ConfigMgr.GetList("configFunds")
end

--得到红点优先页
function WelfareModel.GetRedPage(show_set)
    local redWelfarePages = {}
    for _, v in pairs(CuePointModel.SubType.Welfare) do
        local cfg = ConfigMgr.GetItem("configActivitys", v.Id)
        if v.Number > 0 and cfg.show_set == show_set then
            local data = {id = v.Id, order = cfg.order}
            table.insert(redWelfarePages, data)
        end
    end
    table.sort(
        redWelfarePages,
        function(a, b)
            return a.order < b.order
        end
    )
    if next(redWelfarePages) then
        return redWelfarePages[1].id
    else
        return nil
    end
end

--根据礼品Id得到物品
function WelfareModel.GetResOrItemByGiftId(giftId)
    local items = ConfigMgr.GetItem("configGifts", giftId).items
    local resItems = ConfigMgr.GetItem("configGifts", giftId).res
    local itemCount = 0
    if not resItems then
        itemCount = #items
    elseif not items then
        itemCount = #resItems
    else
        itemCount = #items + #resItems
    end
    local itemDatas = {}
    if items then
        for _, v in pairs(items) do
            local itemInfo = ConfigMgr.GetItem("configItems", v.confId)
            local midStr = GD.ItemAgent.GetItemInnerContent(v.confId)
            local desc = GD.ItemAgent.GetItemDescByConfId(v.confId)
            local title = GD.ItemAgent.GetItemNameByConfId(v.confId)
            local titleWithoutCount = GD.ItemAgent.GetItemNameByConfId(v.confId)
            table.insert(
                itemDatas,
                {isRes = false, confId = v.confId, image = itemInfo.icon, color = itemInfo.color, amount = v.amount, midStr = midStr, title = title, desc = desc, titleWithoutCount = titleWithoutCount}
            )
        end
    end
    if resItems then
        for _1, v1 in pairs(resItems) do
            local itemInfo = ConfigMgr.GetItem("configResourcess", v1.category)
            local midStr = GD.ItemAgent.GetItemInnerContent(v1.category)
            local title = StringUtil.GetI18n(I18nType.Commmon, itemInfo.key)
            local desc = title .. "X" .. v1.amount
            table.insert(itemDatas, {isRes = true, confId = v1.category, image = itemInfo.img, color = itemInfo.color, amount = v1.amount, midStr = midStr, title = title, desc = desc})
        end
    end
    return itemDatas, itemCount
end

local openSelectedIndex = -1
function WelfareModel.SetSelectedIndex(cutSelectIndex)
    openSelectedIndex = cutSelectIndex
end

function WelfareModel.GetSelectedIndex()
    return openSelectedIndex
end


function WelfareModel.getFalconRestoreFillTimer()
    --if(not  Model.isFalconOpen)then
    --    return  -1
    --end
    
    local maxCount = Global.FuelOil[1]
    local restoreCD = Global.FuelOil[2]
    local fullTimer = 0
    if(Model.EagleHuntInfos.Fuel >= 3) then
        return -1
    else
        fullTimer = (maxCount-1 - Model.EagleHuntInfos.Fuel) * restoreCD + Model.EagleHuntInfos.FuelAddAt - Tool.Time()
    end
    if(fullTimer > TimeUtil.ToDayRemianSecond())  then
        return TimeUtil.ToDayRemianSecond()
    else
        return fullTimer
    end
end

WelfareModel.lotterySendWait = 0
WelfareModel.lotteryMsg = nil
function WelfareModel.GetLotteryInfo(cb)
    if WelfareModel.lotterySendWait>_G.Tool.Time() and WelfareModel.lotteryMsg then
        return WelfareModel.lotteryMsg
    end
    Net.ChargeActivity.GetLotteryInfo(
        function(msg)
            WelfareModel.lotterySendWait = _G.Tool.Time()+1
            WelfareModel.lotteryMsg = msg
            cb(msg)
        end
    )
end

return WelfareModel
