--[[
Copyright (c) 2019 kirs

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

--- @module stringex
-- @author kris
-- @license MIT
-- @copyright 2019
local string = _G.string
local gmatch = string.gmatch
local format = string.format
local sub    = string.sub
local gsub   = string.gsub
function string.split(str, sep)
    local r = {}
    for i in gmatch(str, format('[^%s]+', sep)) do
        -- table.insert(r, i)
        r[#r+1] = i
    end
    return r
end

function string.ltrim(input)
    return gsub(input, "^[ \t\n\r]+", "")
end

function string.rtrim(input)
    return gsub(input, "[ \t\n\r]+$", "")
end

function string.trim(input)
    input = gsub(input, "^[ \t\n\r]+", "")
    return gsub(input, "[ \t\n\r]+$", "")
end

function string.startwith(str , start)
    return (string.find(str, "^" .. start))
end

function string.endwith(str , ends)
    return (string.find(str, ends .."$"))
end


function string.IsNullOrEmpty(str)
    return not str or #str == 0
end

function string.replace(text, data)
    for oldKey in gmatch(text, "%[[%w_]+%]") do
        local key = sub(oldKey, 2,-2)
        oldKey = "%[" .. key .. "%]"
        local value = data[key]
        if  value then
            text = gsub(text, oldKey, value)
        else
            return ""
        end
    end
    return text
end

function string.CheckStringIsValid(str)

    if not str then
        _G.GameUtils.LogError(debug.traceback("str为空"))
        return false
    end
    if type(str) ~= "string" then
         _G.GameUtils.LogError(debug.traceback(string.format("非string类型参数" , str)))
         return false
    end

    if string.IsNullOrEmpty(str) then
        return false
    end

    return true
end

function string.strfmt(fmt, ...)
    local params = {...}
    return (gsub(
        fmt,
        "{(%d+)}",
        function(k)
            return params[tonumber(k)]
        end
    ))
end