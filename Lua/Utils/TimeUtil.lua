--[[
    author:{zhanzhang}
    time:2019-06-30 16:47:35
    function:{时间处理工具类}
]]
if TimeUtil then
    return
end
TimeUtil = {}
local timeZone = 0

--每隔5秒检测一次是否跨天
function TimeUtil.CheckSecondDay()
    local lastTime = os.date("!%d", Tool.Time())
    Scheduler.Schedule(
        function()
            local _time = os.date("!%d", Tool.Time())
            if lastTime ~= _time then
                Event.Broadcast(TIME_REFRESH_EVENT.Refresh)
            end
            lastTime = _time
        end,
        5
    )
end

function TimeUtil.SecondToHMS(second)
    local timeStr = ""
    if (timeZone == 0) then
        timeZone = TimeUtil.GetLocalTimeZone()
    end
    timeStr = timeStr .. os.date("%H:%M:%S", second + 86400 - timeZone)
    return timeStr
end

function TimeUtil:StampTimeToYMDHMS(stampTime)
    return os.date("%Y-%m-%d %H:%M", stampTime, stampTime / 1000)
end

function TimeUtil.StampTimeToYMD(stampTime)
    return os.date("!%Y-%m-%d", stampTime)
end

function TimeUtil:StampTimeToYMDHMS_OR_HMS(stampTime)
    local now_time = Tool.Time()

    local _yaer = os.date("%Y", stampTime)
    local _week = os.date("%W", stampTime)
    local _weekday = os.date("%w", stampTime)
    local _day = os.date("%d", stampTime)

    local now_yaer = os.date("%Y", now_time)
    local now_week = os.date("%W", now_time)
    -- local now_weekday = os.date("%w", now_time)
    local now_day = os.date("%d", now_time)

    if _yaer == now_yaer then
        if _week == now_week then
            if _day == now_day then
                -- if now_time - stampTime < 300 then
                --     return ""
                -- end
                return os.date("%H:%M", stampTime)
            elseif tonumber(_day) + 1 == tonumber(now_day) then
                return ConfigMgr.GetI18n("configI18nCommons", "Chat_Time_Yesterday") .. os.date(" %H:%M", stampTime)
            else
                return ConfigMgr.GetI18n("configI18nCommons", "Chat_Time_Date" .. _weekday) .. os.date(" %H:%M", stampTime)
            end
        else
            return os.date("%m-%d %H:%M", stampTime)
        end
    else
        return os.date("%Y-%m-%d %H:%M", stampTime)
    end
end

--判断是否是同一周
function TimeUtil.IsSameWeek(oldDate, newDate)
    local oneDayTime = 1000 * 60 * 60 * 24
    oldDate = math.floor(oldDate / oneDayTime)
    newDate = math.floor(newDate / oneDayTime)
    return math.floor((oldDate + 3) / 7) == math.floor((newDate + 3) / 7)
end

function TimeUtil.SecondToDHMS(stamp)
    if stamp < 0 then
        Log.Warning(" 警告，传入时间有误  ")
        return 0
    end
    local pointTime = stamp
    local day = math.floor(pointTime / 86400)
    local timeStr = ""
    if (day > 0) then
        timeStr = string.format("%s%dd:", timeStr, day)
    end
    if (timeZone == 0) then
        timeZone = TimeUtil.GetLocalTimeZone()
    end

    timeStr = timeStr .. os.date("%H:%M:%S", stamp + 86400 - timeZone)
    return timeStr
end
--计算XX前时间，时间需要以前的时间
function TimeUtil:GetTimesAgo(timeSamp)
    local time = Tool.Time() - timeSamp
    local year = math.floor(time / 31104000)
    local month = math.floor(time / 2592000)
    local day = math.floor(time / 86400)
    local hour = math.floor(time / 3600)
    local min = math.floor(time / 60)
    local second = time
    local str = ""
    if year >= 1 then
        str = StringUtil.GetI18n(I18nType.Commmon, "Ui_YearAgo", {year = year})
    elseif month >= 1 then
        str = StringUtil.GetI18n(I18nType.Commmon, "Ui_MonthAgo", {month = month})
    elseif day >= 1 then
        str = StringUtil.GetI18n(I18nType.Commmon, "Ui_DayAgo", {day = day})
    elseif hour >= 1 then
        str = StringUtil.GetI18n(I18nType.Commmon, "Ui_HourAgo", {hour = hour})
    elseif min >= 1 then
        str = StringUtil.GetI18n(I18nType.Commmon, "Ui_MinutesAgo", {minutes = min})
    elseif second >= 0 then
        str = StringUtil.GetI18n(I18nType.Commmon, "Ui_JustNow")
    end
    return str
end

function TimeUtil.GetLocalTimeZone()
    local now = Tool.Time()
    local localTimeZone = os.difftime(now, os.time(os.date("!*t", now)))
    return localTimeZone
end

function TimeUtil:Now()
    return os.time(os.date("!*t", Tool.Time()))
end

--检测方法运行耗时运行10W次
function TimeUtil.CheckFuncTime(cb)
    local delayTime = os.clock()
    for i = 1, 100000 do
        cb()
    end
    delayTime = os.clock() - delayTime
    Log.Info(string.format("cost time  : %.4f", delayTime))
    return delayTime
end

--显示XX时间以前
function TimeUtil.ShowCeateTime(lastTime)
    local delayTime = Tool.Time() - lastTime
    if delayTime < 60 then
        return delayTime .. "秒以前"
    end

    return
end

--是否是今天
function TimeUtil.ToDay(time)
    if not time then
        return
    end
    local nowtime = os.date("*t", Tool.Time())
    local timestamp =
        os.time(
        {
            day = nowtime.day,
            month = nowtime.month,
            year = nowtime.year,
            hour = 0,
            minute = 0,
            second = 0
        }
    )
    return time >= timestamp and time < timestamp + 24 * 60 * 60
end

--返回还有多久跨天 返回是秒
function TimeUtil.ToDayRemianSecond()
    local nowtime = os.date("!*t", Tool.Time())
    past = nowtime.hour * 3600 + nowtime.min * 60 + nowtime.sec
    return 3600 * 24 - past
end

--显示需要的时间 X分钟  X小时
function TimeUtil.ShowNeedTime(time)
    -- local day = math.floor(time / 86400)
    local hour = math.floor(time / 3600)
    local min = math.floor(time / 60)
    if hour > 0 then
        return StringUtil.GetI18n(I18nType.Commmon, "UI_TIME_HOUR", {num = hour})
    elseif min > 0 then
        return StringUtil.GetI18n(I18nType.Commmon, "UI_TIME_MINUTE", {num = min})
    else
        return "时间有误"
    end
end

--得到第二天0点的UTC
function TimeUtil.UTCTimeToTomorrow()
    local nowtime = os.date("!*t", Tool.Time())
    local tommorowBegin =
        os.time(
        {
            day = nowtime.day + 1,
            month = nowtime.month,
            year = nowtime.year,
            hour = 0,
            minute = 0,
            second = 0
        }
    )

    return tommorowBegin
end

--得到当前UTC时间
function TimeUtil.UTCTime()
    return os.time(os.date("!*t", Tool.Time()))
end

--得到给定时间的零点
function TimeUtil.UTCTimeTodayByTime(time)
    local nowtime = os.date("!*t", time)
    local todayBegin =
        os.time(
        {
            day = nowtime.day,
            month = nowtime.month,
            year = nowtime.year,
            hour = 0,
            minute = 0,
            second = 0
        }
    )

    return todayBegin
end

--得到当天0点的UTC时间
function TimeUtil.UTCTimeToToday()
    local nowtime = os.date("!*t", Tool.Time())
    local todayBegin =
        os.time(
        {
            day = nowtime.day,
            month = nowtime.month,
            year = nowtime.year,
            hour = 0,
            minute = 0,
            second = 0
        }
    )

    return todayBegin
end

--得到给定时间的给定天数后0点的UTC时间
function TimeUtil.UTCTimeSomeDayByTime(time, day)
    local nowtime = os.date("!*t", time)
    local somedayBegin =
        os.time(
        {
            day = nowtime.day + day,
            month = nowtime.month,
            year = nowtime.year,
            hour = 0,
            minute = 0,
            second = 0
        }
    )

    return somedayBegin
end


function TimeUtil.IsExpire(t)
    return Tool.Time() >= t
end

function TimeUtil.Expire(t)
    return Tool.Time() - t
end

function TimeUtil.Left(t)
    return math.max(t - Tool.Time(), 0)
end

_G.TimeUtil = TimeUtil
return TimeUtil
