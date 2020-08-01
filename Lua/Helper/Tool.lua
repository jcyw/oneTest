local Tool = {
    timeDiff = 0
}

function Tool.SyncTime(cb)
    local t1 = Util.GetNowMS() -- 客户端发给服务端
    Net.Logins.SyncTime(function(msg)
        local t2 = Util.GetNowMS() -- 客户端收到
        local t3 = msg.Now -- 服务端接收到
        local delay = (t2 - t1) / 2 -- 网络延时
        local diff = (t3 - t1) - delay
        Log.Info("t1: {0}, t2: {1}, t3: {2}", t1/1000, t2/1000, t3/1000)
        Log.Info("diff: {0}ms, delay: {1}ms", diff, delay)
        Tool.timeDiff = math.ceil(diff/1000)
        if cb then
            cb()
        end
    end)
end

-- 服务器时间 服务器与客服端时间校验
function Tool.Time()
    return os.time() + Tool.timeDiff
end

-- 保留n位小数位数
function Tool.GetPreciseDecimal(value, n)
    if type(value) ~= 'number' then
        return value
    end
    n = n or 0
    n = math.floor(n)
    if n < 0 then
        n = 0
    end
    local decimal = 10 ^ n
    local nTemp = math.floor(value * decimal)
    local nRet = nTemp / decimal
    return nRet
end

-- 数量格式化 单位K/M
function Tool.FormatAmountUnit(number)
    if not number then
        return 0
    end
    local unit = 1000
    if number < unit then
        return math.ceil(number)
    elseif number < unit ^ 2 then
        return Tool.GetPreciseDecimal(number / unit, 1) .. 'K'
    elseif number < unit ^ 3 then
        return Tool.GetPreciseDecimal(number / (unit ^ 2), 1) .. 'M'
    elseif number < unit ^ 4 then
        return Tool.GetPreciseDecimal(number / (unit ^ 3), 1) .. 'B'
    else
        return Tool.GetPreciseDecimal(number / (unit ^ 4), 1) .. 'G'
    end
end

function Tool.FormatAmount(number)
    if not number then
        return 0
    end
    local unit = 1000
    if number < unit then
        return math.ceil(number)
    elseif number < unit ^ 2 then  
        return Tool.FormatFloat(number / unit) .. 'K'
    elseif number < unit ^ 3 then
        return Tool.FormatFloat(number / (unit ^ 2)) .. 'M'
    elseif number < unit ^ 4 then
        return Tool.FormatFloat(number / (unit ^ 3)).. 'B'
    else
        return Tool.FormatFloat(number / (unit ^ 4)) .. 'G'
    end
end

-- 数量格式化 每1000以","隔开
function Tool.FormatNumberThousands(number)
    if not number then return end

    --处理精度问题
    local num = math.floor(number)
    num = number / num
    if num < 1.001 then
        number = number + 0.001
    end

    number = math.floor(tonumber(number))
    local newStr = ''
    number = tostring(number)
    local len = string.len(number)
    for i = 1, len do
        newStr = string.char(string.byte(number, len + 1 - i)) .. newStr
        if math.fmod(i, 3) == 0 then
            if len - i ~= 0 then
                newStr = ',' .. newStr
            end
        end
    end
    return newStr
end

-- 时间格式化 将时间戳转换为 天/时/分/秒 eg(1d:23:05:40)
function Tool.FormatTime(time)
    if not time then
        return 0
    end
    local radix = {24, 60, 60}
    local base_value, value
    local array = {'00', '00', '00'}
    local i = #radix
    while i > 0 do
        base_value = radix[i]
        value = time % base_value
        if value > 0 then
            array[i] = Tool.FormateNumberZero(value)
        end
        time = math.floor(time / base_value)
        i = i - 1
    end
    local time_str = string.format('%s:%s:%s', array[1], array[2], array[3])
    if time > 0 then
        -- time_str = time .. 'd ' .. time_str
        time_str = string.format("%dd %s", time, time_str)
    end
    return time_str
end

-- 时间格式化 将时间戳转换为 天/时/分/秒 eg(1天23小时05分钟40秒)
function Tool.FormatTimeCN(time)
    if not time then
        return 0
    end
    local radix = {24, 60, 60}
    local base_value, value
    local array = {'00', '00', '00'}
    local i = #radix
    while i > 0 do
        base_value = radix[i]
        value = time % base_value
        if value > 0 then
            array[i] = value
        end
        time = math.floor(time / base_value)
        i = i - 1
    end
    local a1 = Tool.FormateNumberZero(array[1])
    local a2 = Tool.FormateNumberZero(array[2])
    local a3 = Tool.FormateNumberZero(array[3])
    local t_func = function(a, b, c, d)
        local _a = a > 0 and a .. '天' or ''
        local _b = b == '00' and '' or b .. '小时'
        local _c = c == '00' and '' or c .. '分钟'
        local _d = d == '00' and '' or d .. '秒'
        return _a .. _b .. _c .. _d
    end
    local str = t_func(time, a1, a2, a3)
    if string.sub(str, 1, 1) == '0' then
        return string.sub(str, 2)
    end
    return str
end

-- 时间格式化 将时间戳转化为 年/月/日 时/分 eg(09/06/19 13:17)
function Tool.FormatTimeSF(time)
    return os.date("%Y/%m/%d %H:%M", time)
end

-- 时间格式化 将时间戳转化为 年/月/日 时/分/秒 eg(09/06/19 13:17:21)
function Tool.FormatTimeAll(time)
    return os.date("%Y/%m/%d %H:%M:%S", time)
end

-- 时间格式化 将总秒数转为 d:hh:mm:ss
function Tool.FormatTimeOfSecond(time)
    local day = math.floor(time / 86400)
    local hour = math.floor((time % 86400) / 3600)
    local min = math.floor((time % 3600) / 60)
    local sec = time % 60

    return day <= 0 and string.format("%02d:%02d:%02d", hour, min, sec) or string.format("%02dd:%02d:%02d%02d", day, hour, min, sec) 
    -- return day <= 0 and hour .. ':' .. min .. ':' .. sec or day .. 'd:' .. hour .. ':' .. min .. ':' .. sec
end

-- 时间格式化 将总秒数转为带单位的形式，去掉零头
function Tool.FormatShortTimeOfSecond(time)
    local hour = math.floor(time / 3600)
    if hour > 0  then
        return string.format("%dh", hour )
    end
    local min = math.floor(time/60)
    return string.format("%dmin", min)

    -- return math.floor(time / 3600) > 0 and math.floor(time / 3600).."h" or math.floor(time / 60).."min"
end

-- 数字格式化 位数不足补零 两位数[string]
function Tool.FormateNumberZero(number)
    if not number then
        return '00'
    end
    return string.format("%02d", number)
    -- local str = tostring(number)
    -- return #str == 1 and string.format('0%s', str) or str
end

-- 时间转化金币 time-需要转化的时间 freeTime-免费时间(不需要免费的则不传)
function Tool.TimeTurnGold(time, freeTime)
    if not time or time <= 0 then
        return 0
    end
    if freeTime then
        if time <= freeTime then
            return 0
        end
        time = time - freeTime
    end
    local conf = Global.TimeToGemParams
    local K1 = conf[1]
    local K2 = conf[2]
    return math.ceil(time / (K1 * ((time / 3600) ^ (K2 / 100))))
end

-- 资源转化金币公式
function Tool.ResTurnGold(category, amount)
    if amount <= 0 then
        return 0
    end

    local N = amount
    local T = ConfigMgr.GetItem('configResourcess', category).ratio
    local conf = ConfigMgr.GetList('configResToGems')
    local K1, K2, K3
    for _, v in ipairs(conf) do
        local toV = v.scope.to
        if N <= toV or toV == -1 then
            K1 = v.k1
            K2 = v.k2
            K3 = v.k3
            break
        end
    end
    return math.ceil(K1 * ((N * T) ^ K2) + K3)
end

-- 合并多个table
function Tool.MergeTables(...)
    local tabs = {...}
    if not tabs then
        return {}
    end
    local obj = {}
    for i = 1, #tabs do
        if obj then
            if tabs[i] then
                for _, v in ipairs(tabs[i]) do
                    table.insert(obj, v)
                end
            end
        else
            obj = tabs[i]
        end
    end
    return obj
end

-- 合并两个table且Uuid不能相同
function Tool.MergeDiffTables(t1, t2)
    for _, v in pairs(t2) do
        local isDiff = false
        for _, vv in pairs(t1) do
            if v.Uuid == vv.Uuid then
                isDiff = true
                break
            end
        end
        if not isDiff then
            table.insert(t1, v)
        end
    end
    return t1
end

--获取table的长度
function Tool.GetTableLength(t)
    local leng = 0
    for _, _ in pairs(t) do
        leng = leng + 1
    end
    return leng
end

--判断两个Bool值是否相等 (区分 nil 和 false)
function Tool.EqualBool(a, b)
    return a == b or (not a and not b)
end

--判断是否相等 (Bool请使用Tool.EqualBool)
function Tool.Equal(a, ...)
    local args = {...}
    for _, v in pairs(args) do
        if a == v then
            return true
        end
    end
end

--判断是否为整数
function Tool.Integer(number)
    return tonumber(number) and math.floor(number) == number or false
end

--将字符串转化为数字(强行)
function Tool.StringToNumber(str)
    if not str then return end
    if type(str) == "string" then
        local number = ""
        for i = 1, #str do
            local s = string.sub(str, i, i)
            if tonumber(s) then
                number = string.format("%s%s", number, s)
                -- number = number .. s
            end
        end
        if number == "" then
            return
        else
            return tonumber(number)
        end
    elseif type(str) == "number" then
        return str
    else
        return
    end
end

---如果小数位数为0，则只保留整数
function Tool.FormatFloat(number)
    if number <= 0 then
        return 0
    end

    local integer, decimal = math.modf(number)
    if decimal > 0 then
        return number
    else
        return integer
    end
end

--数组倒序
 function Tool.ReverseTable(tab)
	local tmp = {}
	for i = 1, #tab do
		local key = #tab
		tmp[i] = table.remove(tab)
	end
	return tmp
end

--获取国家Id
function Tool.GetCountry()
    local country = Util.GetCountry()
    local conf = ConfigMgr.GetList("configFlags")
    for _, v in pairs(conf) do
        if country == v.language then
            return v.id
        end
    end
    return 239
end

--获取数组并打乱顺序
function Tool.ShuffleArray(num)
    local array = {}
    for i = 1, num do
        table.insert(array, i)
    end

    local randomArray = {}
    while #array ~= 0 do
        local n = math.random(0, #array)
        if array[n] then
            randomArray[#randomArray + 1] = array[n]
            table.remove(array, n)
        end
    end

    return randomArray
end

_G.Tool = Tool
return Tool
