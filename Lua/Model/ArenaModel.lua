--author: 	Amu
--time:		2020-06-21 16:04:44

local ArenaModel = {}

local start = 0
local showLen = 10

-- 请求-获取挑战标签页信息
-- DayBattleiFreeTimes 今日挑战免费次数
-- RefreshFreeExpireAt 免费刷新过期时间
-- RefreshFreeTimes 免费刷新次数
-- WeekPriedFreeTimes 本周免费查看队伍信息次数
-- PriedRanks 查看过的排名列表
function ArenaModel.GetArenaBattlePageInfo(cb)
    Net.Arena.GetArenaBattlePageInfo(function(msg)
        if msg.Rank > 0 then
            ArenaModel._rank = msg.Rank
        else
            ArenaModel._rank = StringUtil.GetI18n(I18nType.Commmon, "Button_Commander_UnRank")
        end
        ArenaModel._rankNum = msg.Rank
        ArenaModel._DayBattleiFreeTimes = msg.DayBattleiFreeTimes
        ArenaModel._RefreshBoughtTimes = msg.RefreshBoughtTimes
        ArenaModel._endTime = msg.RefreshFreeExpireAt
        ArenaModel._RefreshFreeTimes = msg.RefreshFreeTimes
        ArenaModel._WeekPriedFreeTimes = msg.WeekPriedFreeTimes
        ArenaModel._Candidates = msg.Candidates
        ArenaModel._BattleEndAt = msg.BattleEndAt

        table.sort(ArenaModel._Candidates, function(a, b)
            return a.PlayerRankInfo.Rank < b.PlayerRankInfo.Rank
        end)
        ArenaModel._PriedRanks = {}
        for _,v in ipairs(msg.PriedRanks)do
            ArenaModel._PriedRanks[v] = true
        end
        cb()
    end)
end

-- 请求-刷新挑战候选人
function ArenaModel.RefreshBattleCandidate(cb)
    Net.Arena.RefreshBattleCandidate(function(msg)
        ArenaModel._endTime = msg.RefreshFreeExpireAt
        ArenaModel._RefreshBoughtTimes = msg.RefreshBoughtTimes
        ArenaModel._RefreshFreeTimes = msg.RefreshFreeTimes
        ArenaModel._Candidates = msg.Candidates

        table.sort(ArenaModel._Candidates, function(a, b)
            return a.PlayerRankInfo.Rank < b.PlayerRankInfo.Rank
        end)
        ArenaModel._PriedRanks = {}
        for _,v in ipairs(msg.PriedRanks)do
            ArenaModel._PriedRanks[v] = true
        end
        cb()
    end)
end

-- 请求-查看队伍信息
function ArenaModel.ArenaPryTroopInfo(rank, cb)
    Net.Arena.ArenaPryTroopInfo(rank, function(msg)
        ArenaModel._WeekPriedFreeTimes = msg.WeekPriedFreeTimes
        Event.Broadcast(ARENA_CHALLENGE_EVNET.RefreshTimes)
        if msg.Candidate then
            ArenaModel._PriedRanks[msg.Candidate.PlayerRankInfo.Rank] = true
        end
        cb(msg)
    end)
end

-- 请求-挑战
function ArenaModel.ArenaAttack(Armies, BeastId, BattleId, BattleRank, cb)
    Net.Arena.ArenaAttack(Armies, BeastId, BattleId, BattleRank, function(msg)
        if ArenaModel._DayBattleiFreeTimes > 0 then
            ArenaModel._DayBattleiFreeTimes = ArenaModel._DayBattleiFreeTimes - 1
        end
        if msg.IsWin then
            Event.Broadcast(ARENA_CHALLENGE_EVNET.WinRefresh)
        else
            Event.Broadcast(ARENA_CHALLENGE_EVNET.RefreshTimes)
        end
        -- Event.Broadcast(ARENA_CHALLENGE_EVNET.RefreshTimes)
        cb(msg)
    end)
end

-- 请求-排行榜标签页信息
function ArenaModel.ArenaRankPageInfo(cb)
    start = 0
    Net.Arena.ArenaRankPageInfo(showLen, function(msg)
        if msg.Rank > 0 then
            ArenaModel._rank = msg.Rank
        else
            ArenaModel._rank = StringUtil.GetI18n(I18nType.Commmon, "Button_Commander_UnRank")
        end
        ArenaModel._rankNum = msg.Rank
        ArenaModel._ranlList = {}
        ArenaModel._ranlList = msg.List
        table.sort(ArenaModel._ranlList, function(a, b)
            return a.Rank < b.Rank
        end)
        start = ArenaModel._ranlList[#ArenaModel._ranlList].Rank+1
        -- start = ArenaModel._ranlList[showLen].Rank+1
        cb()
    end)
end

-- 请求-拉取排行榜玩家信息
function ArenaModel.ArenaRankPlayerInfo(cb)
    Net.Arena.ArenaRankPlayerInfo(start, showLen, function(msg)
        if msg.List and #msg.List > 0 and msg.List[1].Rank == start then
            for _,v in ipairs(msg.List)do
                table.insert(ArenaModel._ranlList, v)
            end
            table.sort(ArenaModel._ranlList, function(a, b)
                return a.Rank < b.Rank
            end)
            start = ArenaModel._ranlList[#ArenaModel._ranlList].Rank+1
            cb()
        end
    end)
end

-- 请求-拉取奖励标签页信息
function ArenaModel.ArenaAwardPageInfo(cb)
    Net.Arena.ArenaAwardPageInfo(function(msg)
        ArenaModel._GotAward = msg.GotAward
        ArenaModel._AwardAt = msg.AwardAt
        ArenaModel._TroopInfoPriedTimes = msg.TroopInfoPriedTimes
        ArenaModel._WinStreakTimes = msg.WinStreakTimes
        ArenaModel._BattleResultList = msg.BattleResultList
        ArenaModel._PlayerRankInfo = msg.PlayerRankInfo
        ArenaModel._GotAward = msg.GotAward
        ArenaModel._WinStreakOrTerminateList = msg.WinStreakOrTerminateList
        cb()
    end)
end

-- 请求-领取奖励
function ArenaModel.ArenaGetAwards(cb)
    Net.Arena.ArenaGetAwards(function(msg)
        ArenaModel._GotAward = true
        cb(msg)
    end)
end

return ArenaModel