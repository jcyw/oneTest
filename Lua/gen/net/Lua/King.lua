Net.King = {}

-- 请求-王位战信息
function Net.King.WarInfo(...)
    Network.RequestDynamic("GetKingWarInfoParams", {}, ...)
end

-- 请求-修改服务器名称
function Net.King.ChangeServerName(...)
    local fields = {
        "Name", -- string
    }
    Network.RequestDynamic("KingChangeServerNameParams", fields, ...)
end

-- 请求-转让国王
function Net.King.TransferCrown(...)
    local fields = {
        "UserId", -- string
    }
    Network.RequestDynamic("TransferCrownParams", fields, ...)
end

-- 请求-获取王城礼包信息
function Net.King.GetGiftInfos(...)
    Network.RequestDynamic("GetKingdomGiftInfosParams", {}, ...)
end

-- 请求-发送礼包
function Net.King.SendGift(...)
    local fields = {
        "UserIds", -- array-string
        "GiftId", -- int32
    }
    Network.RequestDynamic("SendGiftParams", fields, ...)
end

-- 请求-获取头衔信息
function Net.King.TitlesInfo(...)
    Network.RequestDynamic("GetTitlesInfoParams", {}, ...)
end

-- 请求-授予头衔
function Net.King.GiveTitle(...)
    local fields = {
        "UserId", -- string
        "Title", -- int32
    }
    Network.RequestDynamic("KingGiveTitleParams", fields, ...)
end

-- 请求-取消头衔
function Net.King.RemoveTitle(...)
    local fields = {
        "UserId", -- string
        "Title", -- int32
    }
    Network.RequestDynamic("KingRemoveTitleParams", fields, ...)
end

-- 请求-获取历史国王信息
function Net.King.HistoryKings(...)
    Network.RequestDynamic("GetHistoryKingsParams", {}, ...)
end

-- 请求-获取战斗记录信息
function Net.King.WarLogs(...)
    Network.RequestDynamic("GetWarLogsParams", {}, ...)
end

-- 请求-主动技能
function Net.King.UseSkill(...)
    local fields = {
        "SkillId", -- int32
        "Param", -- string
    }
    Network.RequestDynamic("KingSkillParams", fields, ...)
end

-- 请求-搜索玩家位置
function Net.King.GetPlayerPosition(...)
    local fields = {
        "Name", -- string
    }
    Network.RequestDynamic("GetPlayerPositionParams", fields, ...)
end

-- 请求-获取城市经费换钻石信息
function Net.King.GetBlackMoneyBuyDiamondInfo(...)
    Network.RequestDynamic("GetBlackMoneyBuyDiamondParams", {}, ...)
end

-- 请求-获取城市经费捐赠信息
function Net.King.GetFundDonationInfo(...)
    Network.RequestDynamic("GetCityFundDonationParams", {}, ...)
end

-- 请求-捐献城市资金
function Net.King.DonateCityFund(...)
    local fields = {
        "Selection", -- int32
    }
    Network.RequestDynamic("DonateCityFundParams", fields, ...)
end

-- 请求-获取礼物赠送历史信息
function Net.King.KingdomGiftRecords(...)
    Network.RequestDynamic("GetKingdomGiftRecordsParams", {}, ...)
end

-- 请求-国王信息
function Net.King.GetKingInfo(...)
    Network.RequestDynamic("GetKingInfoParams", {}, ...)
end

-- 请求-玩家成为国王
function Net.King.BecomeKing(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("KingRpcBecomeKingParams", fields, ...)
end

-- 请求-玩家获得头衔
function Net.King.GivenTitle(...)
    local fields = {
        "Title", -- int32
        "KingName", -- string
    }
    Network.RequestDynamic("KingRpcGivenTitleParams", fields, ...)
end

-- 请求-玩家失去头衔
function Net.King.LostTitle(...)
    local fields = {
        "Title", -- int32
    }
    Network.RequestDynamic("KingRpcLostTitleParams", fields, ...)
end

-- 请求-通知王位战信息更新
function Net.King.NotifyKingdomInfoUpdate(...)
    local fields = {
        "Notify", -- GetKingWarInfoRsp
    }
    Network.RequestDynamic("NotifyKingdomInfoUpdateParams", fields, ...)
end

return Net.King