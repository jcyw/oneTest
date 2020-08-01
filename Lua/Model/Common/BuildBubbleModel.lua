--[[
    Author: songzeming
    Function: 建筑气泡
]]
local BuildBubbleModel = {}

local WelfareModel = import("Model/WelfareModel")
local FuncListModel = import("Model/FuncListModel")
local BuildModel = import("Model/BuildModel")

local isShowDiamondBubble = false

--检测是否有气泡
local function CheckByLevel(funcId)
    local conf = ConfigMgr.GetItem("configBuildingFuncs", funcId)
    local conditions = conf.condition
    if not conditions then
        return false
    end
    for _, v in pairs(conditions) do
        if v.confId == 1 then
            local cid = (math.modf(v.numer / 100)) * 100
            local building = BuildModel.FindByConfId(cid)
            if not building or building.Level < math.fmod(v.numer, 10) then
                return false
            end
        end
    end
    return true, UITool.GetIcon(conf.img)
end

--[[
    检测轮船气泡
        成长基金和月卡逻辑一致：
            （1）未购买的玩家没进过界面时 出现气泡 点进界面后消失（每日重置）
            （2）玩家存在可领取奖励时 出现气泡 领取完毕后界面消失
]]
function BuildBubbleModel.CheckShip()
    Log.Debug("检测轮船气泡")
    local building = BuildModel.FindByConfId(Global.BuildingShip)
    if not building then
        return
    end
    local itemBuild = BuildModel.GetObject(building.Id)
    if not itemBuild then
        return
    end
    --成长基金
    if not Model.GrowthFundBought and not PlayerDataModel:GetDayNotTip(PlayerDataEnum.DAY_GROWTHFUND) then
        if WelfareModel.IsActivityOpen(WelfareModel.WelfarePageType.GROWTHCAPITALTYPE) then
            local condition, icon = CheckByLevel(67)
            if condition then
                itemBuild:WelfareAnim(true, icon, function()
                    FuncListModel.GrowthFund()
                end)
                return
            end
        end
    end
    if CuePointModel.SubType.Welfare.GrowthFund.Number > 0 then
        local condition, icon = CheckByLevel(67)
        if condition then
            itemBuild:WelfareAnim(true, icon, function()
                FuncListModel.GrowthFund()
            end)
            return
        end
    end
    --月卡
    if not GlobalVars.IsBuyMonthCard and not PlayerDataModel:GetDayNotTip(PlayerDataEnum.DAY_MONTHCARD) then
        if WelfareModel.IsActivityOpen(WelfareModel.WelfarePageType.SPECIALGIFTTYPE) then
            local condition, icon = CheckByLevel(68)
            if condition then
                itemBuild:WelfareAnim(true, icon, function()
                    FuncListModel.MonthlyCard()
                end)
                return
            end
        end
    end
    if CuePointModel.SubType.Welfare.MonthCard.Number > 0 then
        local condition, icon = CheckByLevel(68)
        if condition then
            itemBuild:WelfareAnim(true, icon, function()
                FuncListModel.MonthlyCard()
            end)
            return
        end
    end
    --幸运转盘气泡
    if CuePointModel.SubType.Welfare.Turntable.Number > 0 then
        local condition, icon = CheckByLevel(69)
        if condition then
            itemBuild:WelfareAnim(true, icon, function()
                FuncListModel.LuckyDraw()
            end)
            return
        end
    end
    itemBuild:WelfareAnim(false)
end

--[[
    检测战争雕像气泡
        见面礼
            玩家存在可领取奖励时 出现气泡 领取完毕后界面消失
        签到
            玩家存在可领取奖励时 出现气泡 领取完毕后界面消失
        气泡排序逻辑（多个气泡同时出现冲突逻辑）钻石基金 > 见面礼 > 签到
]]
function BuildBubbleModel.CheckRank()
    Log.Debug("检测战争雕像气泡")
    local building = BuildModel.FindByConfId(Global.BuildingRank)
    if not building then
        return
    end
    local itemBuild = BuildModel.GetObject(building.Id)
    if not itemBuild then
        return
    end
    if CuePointModel.SubType.Welfare.SuperCheap.Number > 0 then
        --钻石基金
        local condition, icon = CheckByLevel(63)
        if condition then
            itemBuild:WelfareAnim(true, icon, function()
                FuncListModel.DiamondsFundPrice()
            end)
            return
        end
        return
    end
    if CuePointModel.SubType.Welfare.RookieSign.Number > 0 then
        --见面礼(新手签到)
        local condition, icon = CheckByLevel(64)
        if condition then
            itemBuild:WelfareAnim(true, icon, function()
                FuncListModel.CumulativeAttendance()
            end)
            return
        end
    end
    if CuePointModel.SubType.Welfare.DailySign.Number > 0 then
        --签到
        local condition, icon = CheckByLevel(65)
        if condition then
            itemBuild:WelfareAnim(true, icon, function()
                FuncListModel.DailyAttendance()
            end)
            return
        end
    end
    itemBuild:WelfareAnim(false)
end

--[[
    检查钻石基金气泡显示
        钻石基金（新）：
        （1）基金每次重置后（包括第一次）玩家没进过界面时 出现气泡 点进界面后消失
        （2）玩家存在可领取奖励时 出现气泡 领取完毕后界面消失
]]
local function CheckBuySuperCheap()
    if not WelfareModel.IsActivityOpen(WelfareModel.WelfarePageType.DIAMOND_FUND_ACTIVITY) then
        return false
    end
    local isGet = false --是否
    local isGeted = false --是否领取
    for _, v in pairs(Model.DiamondFundInfo) do
        if v.ExpireAt and v.ExpireAt >= Tool.Time() then
            if v.ShowTimes <= 0 then
                isGeted = true
            else
                isGet = true
                break
            end
        end
    end
    return isGet or not isGeted
end
function BuildBubbleModel.CheckDiamond()
    Log.Debug("检测钻石基金气泡")
    local building = BuildModel.FindByConfId(Global.BuildingDiamond)
    if not building then
        return
    end
    local conf = BuildModel.GetConf(building.ConfId)
    if Model.Player.Level < conf.unlock_level then
        return
    end

    if CheckBuySuperCheap() then
        isShowDiamondBubble = true
        CSCoroutine.Start(function()
            coroutine.yield(BuildModel.GetObject(building.Id))
            if not isShowDiamondBubble then
                return
            end

            local buildObj = BuildModel.GetObject(building.Id)
            if buildObj then
                buildObj:DiamondAnim(isShowDiamondBubble, function()
                    FuncListModel.DiamondsFundPrice()
                end)
            else
                Log.Error(" 没找到buildObj id:{0}", building.ConfId)
            end
        end)
    else
        isShowDiamondBubble = false
        local itemBuild = BuildModel.GetObject(building.Id)
        if itemBuild then
            itemBuild:DiamondAnim(false)
        end
    end
end

return BuildBubbleModel