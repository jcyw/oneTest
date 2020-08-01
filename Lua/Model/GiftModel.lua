local NoviceModel = import("Model/NoviceModel")

local GiftModel = {}
local GlobalVars = GlobalVars

GiftModel.IgnoreGiftPush = false

-- 获取当前礼包列表
function GiftModel.GetCurGiftList()
    local result = {}
    local gifts = Model.GiftPacks.GiftPacks
    for _,v in pairs(gifts) do
        local config = GiftModel.GetGiftConfig(v.GiftId)
        local group = GiftModel.GetGiftGroupConfig(config.group_id)
        if ShopModel:GetPriceByProductId(config.giftId) ~= "null" and group.show_giftpackage then
            table.insert(result, config)
        end
    end

    -- local gifts = ConfigMgr.GetList("configGiftPacks")
    -- for _,v in pairs(gifts) do
    --     table.insert(result, v)
    -- end

    local firstPool = {}
    local secondPool = {}
    for _,v in pairs(result) do
        local group = GiftModel.GetGiftGroupConfig(v.group_id)
        local isFirst = false
        for _,v1 in pairs(group.ranking) do
            if v1.x == 0 then
                table.insert(firstPool, v)
                isFirst = true
                break
            elseif v1.x == 1 then
                if Model.Player.Level >= v1.y then
                    table.insert(firstPool, v)
                    isFirst = true
                    break
                end
            elseif v1.x == 2 then
                if Model.Player.RechargeInThirtyDays >= vi.y then
                    table.insert(firstPool, v)
                    isFirst = true
                    break
                end
            end
        end

        if not isFirst then
            table.insert(secondPool, v)
        end
    end
    table.sort(firstPool, function(a,b)
        local groupA = GiftModel.GetGiftGroupConfig(a.group_id)
        local groupB = GiftModel.GetGiftGroupConfig(b.group_id)
        return groupA.order < groupB.order
    end)
    table.sort(secondPool, function(a,b)
        local groupA = GiftModel.GetGiftGroupConfig(a.group_id)
        local groupB = GiftModel.GetGiftGroupConfig(b.group_id)
        return groupA.order < groupB.order
    end)

    result = {}
    for _,v in pairs(firstPool) do
        table.insert(result, v)
    end
    for _,v in pairs(secondPool) do
        table.insert(result, v)
    end

    return result
end

-- 获取下一个礼包配置
function GiftModel.GetNextGift(curIndex)
    local gifts = Model.GiftPacks.GiftPacks
    -- local gifts = ConfigMgr.GetList("configGiftPacks")
    if #gifts <= 0 or curIndex < 0 then
        return nil, -1, 0
    end

    local next = curIndex + 1
    while true do
        if next > #gifts then
            next = 1
        end

        local config = GiftModel.GetGiftConfig(gifts[next].GiftId)
        local groupConfig = GiftModel.GetGiftGroupConfig(gifts[next].GroupId)
        if ShopModel:GetPriceByProductId(config.giftId) ~= "null" and groupConfig.recommend == 1 and groupConfig.recommend_time then
            return groupConfig, next, gifts[next].CloseAt, config
        end

        -- local groupConfig = GiftModel.GetGiftGroupConfig(math.floor(gifts[next].id / 100))
        -- if groupConfig.recommend == 1 then
        --     return groupConfig, next
        -- end

        if next == curIndex then
            return nil, -1, 0
        end
        
        next = next + 1
    end

    return nil, -1, 0
end

function GiftModel.GetGiftConfig(id)
    return ConfigMgr.GetItem("configGiftPacks", id)
end

function GiftModel.GetGiftGroupConfig(id)
    return ConfigMgr.GetItem("configGiftGroups", id)
end

-- 获取礼包刷新时间
function GiftModel.GetRefreshTime(id)
    for _,v in pairs(Model.GiftPacks.GiftPacks) do
        if id == v.GiftId then
            return v.CloseAt
        end
    end

    return 0--Model.GiftPacks.RefreshAt
end

-- 获取每日礼包是否领取
function GiftModel.HasDailyGift()
    return not Model.EveryGiftTaken
end

-- 设置每日礼包是否领取标记
function GiftModel.SetDailyGiftFlag(flag)
    Model.EveryGiftTaken = flag
end

function GiftModel.SetDailyBonusFlag(flag)
    Model.TurntableDailyBonus = flag
end

function GiftModel.GetDailyBonusFlag()
    return Model.TurntableDailyBonus
end

function GiftModel.RefreshGiftPacks(datas)
    Model.GiftPacks.GiftPacks = datas
    Event.Broadcast(EventDefines.RefreshGiftPacks)
end

function GiftModel.AddGift(data)
    table.insert(Model.GiftPacks.GiftPacks, data)
    Event.Broadcast(EventDefines.RefreshGiftPacks)
end

function GiftModel.RemoveGift(id)
    for k,v in pairs(Model.GiftPacks.GiftPacks) do
        if v.GroupId == id then
            table.remove(Model.GiftPacks.GiftPacks, k)
            break
        end
    end

    Event.Broadcast(EventDefines.RefreshGiftPacks)
end

-- 是否有一阶段新手礼包
function GiftModel.HasNewCommonderGiftOne()
    for k,v in pairs(Model.GiftPacks.GiftPacks) do
        if v.GiftId == GiftEnum.NewCommonderGiftOne then
            return true
        end
    end

    return false
end

-- 显示新手礼包推送界面结束时间
function GiftModel.GetLeftTimeOfShowSpecialNewCommanderGift()
    local created = TimeUtil.UTCTimeTodayByTime(Model.User.CreatedAt)
    local today = TimeUtil.UTCTimeToToday()
    local spendTime = today - created
    local spendDay = spendTime / 86400
    if spendDay < 3 and GiftModel.HasNewCommonderGiftOne() then
        -- 返回结束时间
        return TimeUtil.UTCTimeSomeDayByTime(Model.User.CreatedAt, 3)
    else
        -- 不再推送
        return 0
    end
end

function GiftModel:CheckGiftPush()
    if GiftModel.IgnoreGiftPush then
        return
    end

    local firstCheck = self.firstCheck
    self.firstCheck = true
    if GlobalVars.IsNoviceGuideStatus or GlobalVars.IsTriggerStatus then
        return
    end

    --判断是不是第一天
    local IsFirstDayFunc = function ()
        local time= Tool.Time() - Model.Player.CreatedAt
        if time > 86400 then
            return false
        else
            return true
        end
    end

    if IsFirstDayFunc() then
        return
    end

    if not firstCheck then
        self:openGiftPushWin()
        return
    end
    local nowTime = Tool.Time()
    if not self.pushCheckInfo then
        local info = Util.GetPlayerData("pushCheck")
        if info ~= "" then
            self.pushCheckInfo = JSON.decode(info)
        else
            self.pushCheckInfo = {
                count = 0,
                time = nowTime,
            }
        end
    end
    --检测是否跨天的逻辑 有通用方法的话可以把这段优化掉
    if math.floor(nowTime/86400) > math.floor(self.pushCheckInfo.time/86400) then
        self.pushCheckInfo = {
            count = 0,
            time = nowTime,
        }
    end
    self.pushCheckInfo.count = self.pushCheckInfo.count + 1
    Util.SetPlayerData("pushCheck", JSON.encode(self.pushCheckInfo))
    if not self.pushCountConf then
        self.pushCountConf = Global.GiftPopupNumber or {}
    end
    for _, v in ipairs(self.pushCountConf) do
        if self.pushCheckInfo.count == v then
            self:openGiftPushWin()
        end
    end
end

function GiftModel:openGiftPushWin(curIndex)
    local time = self.GetLeftTimeOfShowSpecialNewCommanderGift()
    if time > 0 then
        UIMgr:Open("SpecialNewCommanderGift")
    elseif #self.GetCurGiftList() > 0 then
        UIMgr:Open("RechargeMain", false, true, curIndex)
    end
end

return GiftModel