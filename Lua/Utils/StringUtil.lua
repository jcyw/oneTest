--[[
    author:{zhanzhang}
    time:2019-06-30 16:47:35
    function:{字符串工具类}
]]
if StringUtil then
    return
end

StringUtil = {}
--(括号+坐标)
function StringUtil.GetCoordinataStr(x, y)
    return "(" .. math.floor(x) .. "," .. math.floor(y) .. ")"
end
--X：Y：
function StringUtil.GetCoordinataWithLetter(x, y)
    return "X:" .. math.floor(x) .. ",Y:" .. math.floor(y)
end

--获取多语言字符串
function StringUtil.GetI18n(I18nType, str, data)
    local str = ConfigMgr.GetI18n(I18nType, str)
    if not data then
        return str
    end
    for k, v in pairs(data) do
        local preStr = string.gsub(v, "(%%)", "%%%%") -- 防止配置中出现单个%导致报错
        str = string.gsub(str, "{" .. k .. "}", preStr)
    end
    return str
end

--截取utf-8编码的字符串，i为开始位置，j为长度
function StringUtil.Utf8Sub(str, i, j)
    if not i or not j or i <= 0 or j <= 0 then
        return str
    end

    local from = utf8.offset(str, i)
    local to = utf8.offset(str, i + j)
    if not from or not to then
        return str
    end

    return string.sub(str, from, to - 1)
end

--按给定的字节长度截取utf-8编码字符串
function StringUtil.Utf8LimitOfByte(str, limit)
    if str == "" then
        return ""
    end
    local byteLen = string.len(str) / utf8.len(str)
    local len = math.floor(limit / byteLen)
    return StringUtil.Utf8Sub(str, 1, len)
end

--检查中文，返回中文字符个数
function StringUtil.CheckChineseCount(str)
    local len = 0
    for v in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do
        if #v > 1 then
            len = len + 1
        end
    end
    return len
end

--字符串分割
function StringUtil.Split(content, pattern, plain)
    local index = 1
    local splitIndex = 1
    local result = {}
    while true do
        local lastIndex = string.find(content, pattern, index, plain)
        if not lastIndex then
            result[splitIndex] = string.sub(content, index, string.len(content))
            break
        end
        result[splitIndex] = string.sub(content, index, lastIndex - 1)
        index = lastIndex + string.len(pattern)
        splitIndex = splitIndex + 1
    end
    return result
end

--字符串格式化 {value}
function StringUtil.Format(content, ...)
    local args = {...}
    for k, v in pairs(args) do
        content = string.gsub(content, "{" .. k .. "}", v)
    end
    return content
end

--去掉字符串首位空格
function StringUtil.RemoveStringSpace(str)
    return (" " .. str .. " "):match("^%s+(.-)%s+$")
end

function StringUtil.RemoveSpaceAndNextLine(str)
    return string.gsub(str, "[\t\n\r[%]]+", "")
end

--计算字符宽度，用于显示使用 小写字母算1个宽度，大写1.5（因为大写W太宽），汉字2 ，特殊参数处理，可以单独使用（不传widthLimit）获得宽度
function StringUtil.StringWidth(inputstr,widthLimit)
    local width = 0
    if widthLimit == nil then
        widthLimit = #inputstr * 2 --无宽度限制，则扩展为全中文的宽度，保证不会被截短
    end
    local shortlyStringIndex
    local i = 1
    while (i<=#inputstr) do
        local curByte = string.byte(inputstr, i)
        local byteCount = 1;
        if curByte>0 and curByte<=127 then
            byteCount = 1
            if curByte >= 65 and curByte <= 90 then
                width = width + 1.5
            else
                width = width + 1
            end
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
            width = width + 1
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
            width = width + 2
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
            width = width + 2
        end
        if width >= widthLimit - 2 and shortlyStringIndex == nil then --widthLimit - 2 因为给"..."留位置
            shortlyStringIndex = i - 1
        end
        i = i + byteCount
    end
    return width , shortlyStringIndex
end

--截短字符串，超出长度限制的，用 ... 代替
function StringUtil.StringShortly(inputstr,widthLimit)
    local width ,shortlyStringIndex = StringUtil.StringWidth(inputstr,widthLimit)
    if width >= widthLimit and shortlyStringIndex then
        local shortlyString = string.sub(inputstr, 1, shortlyStringIndex).."..."
        return shortlyString
    end
    return inputstr
end

_G.StringUtil = StringUtil
return StringUtil
