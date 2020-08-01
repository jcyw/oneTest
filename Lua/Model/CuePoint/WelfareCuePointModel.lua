--[[
    Author: songzeming
    Function: 公用模板 福利中心提示红点
]]
local WelfareCuePointModel = {}

local WelfareModel = import("Model/WelfareModel")
local BuildBubbleModel = import("Model/Common/BuildBubbleModel")

--福利中心初始化
function WelfareCuePointModel:InitWelfare()
    if self.init then
        return
    end
    self.init = true

    --跨天刷新通知
    Event.AddListener(
        TIME_REFRESH_EVENT.Refresh,
        function()
            self:CheckWelfarePoint()
        end
    )

    Event.AddListener(
        EventDefines.RefreshTurntableredpoint,
        function()
            self:CheckTurnTable()
        end
    )

    self:CheckWelfarePoint()
end

--检测已开启活动提示点
function WelfareCuePointModel:CheckWelfarePoint()
    local activeIds = WelfareModel.GetActiveActivityId()
    for _, v in pairs(WelfareModel.GetActiveActivityId()) do
        if v == WelfareModel.WelfarePageType.DAILY_ATTENDANCE then
            --每日签到
            self:CheckDailySignPoint()
        elseif v == WelfareModel.WelfarePageType.DAILYTASK_ACTIVITY then
            --日常任务
            self:CheckDailyTaskPoint()
        elseif v == WelfareModel.WelfarePageType.FUNTYPE then
            --理财基金
            self:CheckFinancialFundPoint()
        elseif v == WelfareModel.WelfarePageType.SPECIALGIFTTYPE then
            --超值好礼（月卡）
            self:CheckMonthCardPoint()
        elseif v == WelfareModel.WelfarePageType.PRIVILEGETYPE then
            --豪华特权
            self:CheckPrivilegePoint()
        elseif v == WelfareModel.WelfarePageType.GROWTHCAPITALTYPE then
            --成长基金
            self:CheckGrowthFundPoint()
        elseif v == WelfareModel.WelfarePageType.NEWBIESTORE then
            --新手礼包
            self:CheckRookiePoint()
        elseif v == 1900401 then
            --连续储值
            self:CheckContinuousChargePoint()
        elseif v == WelfareModel.WelfarePageType.EVERYTIMESTORE then
            --每日储值
            self:CheckDailyChargePoint()
        elseif v == WelfareModel.WelfarePageType.ADDUPSTORE then
            --累计储值
            self:CheckCumulativeChargePoint()
        elseif v == WelfareModel.WelfarePageType.INFINITYSTORE then
            --无限储值
            self:CheckInfiniteChargePoint()
        elseif v == WelfareModel.WelfarePageType.SINGLESTORE then
            --单次储值
            self:CheckSingleChargePoint()
        elseif v == WelfareModel.WelfarePageType.CUMULATIVE_ATTENDANCE then
            --新手累计签到
            self:CheckRookieSignPoint()
        elseif v == WelfareModel.WelfarePageType.SEVEN_DAY_ACTIVITY then
            --新手成长之路
            self:CheckRookieGrowthPoint()
        elseif v == WelfareModel.WelfarePageType.GAMBLING_ACTIVITY then
            --赌场集结
            self:CheckCasionMassPoint()
        elseif v == WelfareModel.WelfarePageType.DETECT_ACTIVITY then
            --侦查行动
            self:CheckDetectActvityPoint()
        elseif v == WelfareModel.WelfarePageType.FALCON_ACTIVITY then
            --猎鹰行动
            self:CheckFalconActvityPoint()
        elseif v == WelfareModel.WelfarePageType.GEMFUND_ACTIVITY then
            --长留基金
            self:CheckGemFundPoint()
        elseif v == WelfareModel.WelfarePageType.HUNTINGDOG_GEMFUND_ACTIVITY then
            --猎狐犬行动
            self:CheckHuntingDogPoint()
        elseif v == WelfareModel.WelfarePageType.DIAMOND_FUND_ACTIVITY then
            -- 钻石基金
            self:CheckSuperCheapActvityPoint()
        elseif v == WelfareModel.WelfarePageType.MEMORIALDAY_ACTIVITY then
            -- 国旗日
            self:CheckMemerDayPoint()
        elseif v == WelfareModel.WelfarePageType.LUCKYTURNTABLE_ACTIVITY then
            --转盘
            self:CheckTurnTable()
        end
    end
end

--转盘
function WelfareCuePointModel:CheckTurnTable()
    Net.ChargeActivity.GetLotteryInfo(
        function(msg)
            if msg.Times > 0 or msg.RewardId ~= 0 or msg.CanGetDailyBonus then
                CuePointModel.SubType.Welfare.Turntable.Number = 1
            else
                CuePointModel.SubType.Welfare.Turntable.Number = 0
            end
            CuePointModel:CheckWelfare()
            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.Turntable.Id)
            BuildBubbleModel.CheckShip()
        end
    )
end

--每日签到
function WelfareCuePointModel:CheckDailySignPoint()
    Net.Sign.GetDailySignInfos(
        function(rsp)
            CuePointModel.SubType.Welfare.DailySign.Number = rsp.Signed and 0 or 1
            CuePointModel:CheckWelfare()
            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.DailySign.Id)
            BuildBubbleModel.CheckRank()
        end
    )
end
--日常任务
function WelfareCuePointModel:CheckDailyTaskPoint()
    Net.DailyTask.GetDailyTaskInfo(
        function(rsp)
            local amount = 0
            for _, v in pairs(rsp.AccomplishedAward) do
                if v.IsAwardTaken == false then
                    amount = amount + 1
                end
            end
            CuePointModel.SubType.Welfare.DailyTask.Number = amount
            CuePointModel:CheckWelfare()
            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.DailyTask.Id)
        end
    )
end
--理财基金
function WelfareCuePointModel:CheckFinancialFundPoint()
    -- Net.ChargeActivity.GetInvestStatus(
    --     function(rsp)
    --         print("===--- 理财基金 rsp: ", table.inspect(rsp))
    --     end
    -- )
end
--超值好礼（月卡）
function WelfareCuePointModel:CheckMonthCardPoint()
    Net.Purchase.GetCardStatus(
        1,
        function(rsp)
            -- print("===--- 超值好礼（月卡） rsp: ", table.inspect(rsp.Info))
            local amount = 0
            local isBuyMonthCard = false
            for _, v in pairs(rsp.Info) do
                if v.IsActivated then
                    isBuyMonthCard = true
                    if v.RestTimes > 0 then
                        amount = amount + 1
                    end
                end
            end
            CuePointModel.SubType.Welfare.MonthCard.Number = amount
            CuePointModel:CheckWelfare()
            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.MonthCard.Id)
            GlobalVars.IsBuyMonthCard = isBuyMonthCard
            BuildBubbleModel.CheckShip()
        end
    )
end
--豪华特权
function WelfareCuePointModel:CheckPrivilegePoint()
end
--新手礼包
function WelfareCuePointModel:CheckRookiePoint()
end
--连续储值
function WelfareCuePointModel:CheckContinuousChargePoint()
end
--每日储值
function WelfareCuePointModel:CheckDailyChargePoint()
end
--累计储值
function WelfareCuePointModel:CheckCumulativeChargePoint()
end
--无限储值
function WelfareCuePointModel:CheckInfiniteChargePoint()
end
--单次储值
function WelfareCuePointModel:CheckSingleChargePoint()
end
--新手累计签到
function WelfareCuePointModel:CheckRookieSignPoint()
    Net.Sign.GetRookieSignInfos(
        function(rsp)
            -- print("===--- 新手累计签到 rsp: ", table.inspect(rsp))
            CuePointModel.SubType.Welfare.RookieSign.Number = rsp.CanSign and 1 or 0
            CuePointModel:CheckWelfare()
            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.RookieSign.Id)
            BuildBubbleModel.CheckRank()
        end
    )
end
--新手成长之路
function WelfareCuePointModel:CheckRookieGrowthPoint(respone)
    local function refresh_func(rsp)
        --上面
        local giftCount = 0
        local cutScore = rsp.Score
        for _, v in pairs(rsp.Awards) do
            local dayPoint = ConfigMgr.GetItem("configSevenDayPoints", v.Id).taskAmount
            if v.Status == false and dayPoint <= cutScore then
                giftCount = giftCount + 1
            end
        end
        -- print("giftCount:-------------", giftCount)
        --下面
        local awardCount = 0
        for _, info in pairs(rsp.Finished) do
            if info.Day <= rsp.Today then
                for _, v in pairs(info.Tasks) do
                    if v.Acknowledged == false then
                        awardCount = awardCount + 1
                    end
                end
            end
        end
        CuePointModel.SubType.Welfare.RookieGrowth.Number = awardCount + giftCount
        CuePointModel:CheckWelfare()
        Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.RookieGrowth.Id)
    end
    if respone then
        refresh_func(respone)
    else
        Net.SevenDaysActivity.SevenDaysActivityInfo(refresh_func)
    end
end
--赌场集结
function WelfareCuePointModel:CheckCasionMassPoint()
    Net.ActivityTask.GetActivityTaskInfos(
        function(rsp)
            -- print("===--- 赌场集结 rsp: ", table.inspect(rsp))
            local amount = 0
            for _, v in pairs(rsp.Accomplished) do
                if not v.AwardTaken then
                    amount = amount + 1
                end
            end
            CuePointModel.SubType.Welfare.CasionMass.Number = amount
            CuePointModel:CheckWelfare()
            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.CasionMass.Id)
        end
    )
end
--侦查行动
function WelfareCuePointModel:CheckDetectActvityPoint()
    Net.InvestigationActivity.GetInvestigationActivityInfo(
        function(rsp)
            local amount = 0
            for _, v in pairs(rsp.Accomplished) do
                if not v.AwardTaken then
                    amount = amount + 1
                end
            end
            CuePointModel.SubType.Welfare.DetectActivity.Number = amount
            CuePointModel:CheckWelfare()
            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.DetectActivity.Id)
        end
    )
end

--猎鹰行动
function WelfareCuePointModel:CheckFalconActvityPoint()
    if (Model.EagleHuntInfos.Fuel > 0) then
        CuePointModel.SubType.Welfare.FanconActivity.Number = 1
    else
        CuePointModel.SubType.Welfare.FanconActivity.Number = 0
    end
    CuePointModel:CheckWelfare()
    Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.FanconActivity.Id)
end

--钻石基金
function WelfareCuePointModel:CheckSuperCheapActvityPoint()
    for i = 1, #Model.DiamondFundInfo do
        if Model.DiamondFundInfo[i].ExpireAt and Model.DiamondFundInfo[i].ExpireAt >= Tool.Time() then
            if (Model.DiamondFundInfo[i].ShowTimes <= 0) then
                CuePointModel.SubType.Welfare.SuperCheap.Number = 0
            else
                CuePointModel.SubType.Welfare.SuperCheap.Number = 1
                break
            end
        else
            CuePointModel.SubType.Welfare.SuperCheap.Number = 0
        end
    end
    CuePointModel:CheckWelfare()
    Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.SuperCheap.Id)
    BuildBubbleModel.CheckDiamond()
end

--长留基金检测红点
function WelfareCuePointModel:CheckGemFundPoint()
    Net.GemFund.GetInfo(
        function(rsp)
            local amount = 0
            for _, v in pairs(rsp.Infos) do
                if not v.Taken and v.Bought then
                    amount = amount + 1
                end
            end
            CuePointModel.SubType.Welfare.GemFundActivity.Number = amount
            --主界面福利中心红点检测
            CuePointModel:CheckWelfare()
            --添加红点
            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.GemFundActivity.Id)
        end
    )
end

--成长基金
function WelfareCuePointModel:CheckGrowthFundPoint()
    local growItemDatas = {}
    local growList = WelfareModel.GetGrowFundInfo()
    for i = 1, #growList do
        local growInfo = WelfareModel.GetGrowItemInfo(i)
        table.insert(growItemDatas, growInfo)
    end
    -- print("growItemDatas:--------------", table.inspect(growItemDatas))
    local pointNum = 0
    --主堡等级
    local playerLevel = Model.Player.Level
    local isBuy = Model.GrowthFundBought
    if isBuy then
        Net.Purchase.GetGrowthFundInfo(
            function(rsp)
                if isBuy then
                    for _, v in pairs(growItemDatas) do
                        if v.level <= playerLevel then
                            pointNum = pointNum + 1
                        end
                    end
                    for _, v1 in pairs(rsp.Infos) do
                        if v1.Status == 2 then
                            pointNum = pointNum - 1
                        end
                    end
                end
                -- print("playerLevel:-------",playerLevel)
                -- print("pointNum:---------", pointNum)
                -- print("rsp-----------:成长基金:", table.inspect(rsp))
                CuePointModel.SubType.Welfare.GrowthFund.Number = pointNum
                CuePointModel:CheckWelfare()
                Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.GrowthFund.Id)
                BuildBubbleModel.CheckShip()
            end
        )
    else
        pointNum = 0
        CuePointModel.SubType.Welfare.GrowthFund.Number = pointNum
        CuePointModel:CheckWelfare()
        Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.GrowthFund.Id)
        BuildBubbleModel.CheckShip()
    end
end

function WelfareCuePointModel:CheckHuntingDogPoint()
    Net.ActivityTask.GetHuntFoxInfos(
        function(rsp)
            -- print("===--- 赌场集结 rsp: ", table.inspect(rsp))
            local amount = 0
            for _, v in pairs(rsp.Accomplished) do
                if not v.AwardTaken then
                    amount = amount + 1
                end
            end
            CuePointModel.SubType.Welfare.HuntFox.Number = amount
            CuePointModel:CheckWelfare()
            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.HuntFox.Id)
        end
    )
end

--检测国旗日红点
function WelfareCuePointModel:CheckMemerDayPoint()
    Net.FlagDayDetect.GetInfo(
        function(rsp)
            local amount = 0
            for _, v in pairs(rsp.Accomplished) do
                if not v.AwardTaken then
                    amount = amount + 1
                end
            end
            CuePointModel.SubType.Welfare.MemorialDay.Number = amount
            CuePointModel:CheckWelfare()
            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.MemorialDay.Id)
        end
    )
end
return WelfareCuePointModel
