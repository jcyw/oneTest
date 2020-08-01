--[[
  @Author: Simon
  @Date: 2020-05-22 00:54:59
  @LastEditTime: 2020-05-25 11:55:24
  @LastEditors: Simon
  @function: {}
--]]
local funex = {}

function funex.indexer(startIdx)
    local count = startIdx or 0
    return setmetatable({}, {
        __call = function(_,idx)
            count = idx or count
            count = count + 1
            return count
        end

    })
end

function funex.partial(fun, ...)
    local argCount = select('#', ...)
    assert(type(fun) == "function", "partial need a function")
    assert(argCount <= 7, "partial parameter only support 7 args")
    if argCount == 0 then
        return fun
    elseif argCount == 1 then
        local a = select('1', ...)
        return function(...)
            return fun(a, ...)
        end
    elseif argCount == 2 then
        local a = select('1', ...)
        local b = select('2', ...)
        return function(...)
            return fun(a, b, ...)
        end
    elseif argCount == 3 then
        local a = select('1', ...)
        local b = select('2', ...)
        local c = select('3', ...)
        return function(...)
            return fun(a, b, c, ...)
        end
    elseif argCount == 4 then
        local a = select('1', ...)
        local b = select('2', ...)
        local c = select('3', ...)
        local d = select('4', ...)
        return function(...)
            return fun(a, b, c, d, ...)
        end
    elseif argCount == 5 then
        local a = select('1', ...)
        local b = select('2', ...)
        local c = select('3', ...)
        local d = select('4', ...)
        local e = select('5', ...)
        return function(...)
            return fun(a, b, c, d, e, ...)
        end
    elseif argCount == 6 then
        local a = select('1', ...)
        local b = select('2', ...)
        local c = select('3', ...)
        local d = select('4', ...)
        local e = select('5', ...)
        local f = select('6', ...)
        return function(...)
            return fun(a, b, c, d, e, f, ...)
        end
    elseif argCount == 7 then
        local a = select('1', ...)
        local b = select('2', ...)
        local c = select('3', ...)
        local d = select('4', ...)
        local e = select('5', ...)
        local f = select('6', ...)
        local g = select('7', ...)
        return function(...)
            return fun(a, b, c, d, e, f, g, ...)
        end
    end
end

_G.funex = funex
