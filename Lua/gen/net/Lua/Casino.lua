Net.Casino = {}

-- 请求-赌场信息
function Net.Casino.GetCasinoInfo(...)
    Network.RequestDynamic("GetCasinoInfoParams", {}, ...)
end

-- 请求-抽奖
function Net.Casino.Gamble(...)
    Network.RequestDynamic("GambleParams", {}, ...)
end

-- 请求-高级场抽奖
function Net.Casino.HyperGamble(...)
    local fields = {
        "Index", -- int32
    }
    Network.RequestDynamic("HyperGambleParams", fields, ...)
end

-- 请求-取消高级场抽奖
function Net.Casino.QuitHyperGambling(...)
    Network.RequestDynamic("QuitHyperGambleParams", {}, ...)
end

-- 请求-分享高级场抽奖信息
function Net.Casino.ShareHyperGambling(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("ShareHyperGambleParams", fields, ...)
end

-- 请求-赌场跑马灯信息
function Net.Casino.GetCasinoNotice(...)
    Network.RequestDynamic("GetCasinoNoticeParams", {}, ...)
end

-- 请求-获取集结活动奖励
function Net.Casino.GetCasinoActivityAward(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GetCasinoActivityAwardParams", fields, ...)
end

return Net.Casino