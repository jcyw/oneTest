Net.Sign = {}

-- 请求-签到信息
function Net.Sign.GetDailySignInfos(...)
    Network.RequestDynamic("GetSignInfosParams", {}, ...)
end

-- 请求-签到
function Net.Sign.DailySign(...)
    Network.RequestDynamic("SignParams", {}, ...)
end

-- 请求-新手签到信息
function Net.Sign.GetRookieSignInfos(...)
    Network.RequestDynamic("GetRookieSignInfosParams", {}, ...)
end

-- 请求-新手签到
function Net.Sign.RookieSign(...)
    Network.RequestDynamic("RookieSignParams", {}, ...)
end

return Net.Sign