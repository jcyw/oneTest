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

--- @module mathex
-- @author kris
-- @license MIT
-- @copyright 2019

local Mathf       = _G.Mathf
local _math       = _G.math
local random      = _math.random
local min         = _math.min
local max         = _math.max
_math.randomseedc = _math.randomseed
_math.nonnegative = function(value)
    return max(value, 0)
end
_math.randomc = function(minval, maxval)
    local diff = maxval - minval
    if diff > 0 then
        diff = diff * random()
        return minval + diff
    else
        return minval
    end
end
_math.hit = function(range, maximum)
    if maximum == nil then
        maximum = 100
    end
    return random(maximum) <= range
end
_math.clamp = Mathf.Clamp
_math.clamp01 = Mathf.Clamp01
_math.range = function(x, a, b)
    return min(a, b) <= x and x < max(a, b)
end
_math.inrange = function(x, a, b)
    return min(a, b) <= x and x <= max(a, b)
end
_math.decimalEqual = function(a, b, e)
    return math.abs(a - b) < (e or 0.00001)
end