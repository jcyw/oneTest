--[[
    Author: songzeming
    Function: 公用工具 搜索
]]
local SearchUtil = {}

--[[
    模糊搜索
        a: 被匹配的字符串
        b: 将要和 a 匹配的字符串
        flag: 是否区分大小写 [默认不区分]
        return: ture or false
]]
function SearchUtil.FuzzySearch(a, b, flag)
    if not flag then
        a = string.lower(a)
        b = string.lower(b)
    end
    return not not string.find(a, b)
end

--[[
    精准搜索
        a: 被匹配的字符串
        b: 将要和 a 匹配的字符串
        flag: 是否区分大小写 [默认不区分]
        return: true or false
]]
function SearchUtil.PreciseSearch(a, b, flag)
    if not flag then
        a = string.lower(a)
        b = string.lower(b)
    end
    return a == b
end

return SearchUtil
