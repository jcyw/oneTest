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

--- @module tablex
-- @author kris
-- @license MIT
-- @copyright 2019
local table             = _G.table
local next              = _G.next
local ipairs            = _G.ipairs
local pairs             = _G.pairs
local formattablelist   = {}
local emptyTable        = {}

local function formatvalue(v)
    if type(v) == 'string' then
        return string.format('%q', v)
    end
    if type(v) == 'number' then
        return tostring(v)
    end
    if type(v) == 'boolean' then
        return tostring(v)
    end
    if type(v) == 'table' then
        return table.format(v)
    end
    if type(v) == "nil" then
        return 'nil'
    end
    return 'Unknown'
end

local function formattab(n)
    local t = {}
    for _ = 1, n do
        t[#t+1] = '\t'
    end
    return table.concat(t)
end

function table.format( t, depth )
    depth = depth or 0
    local ot = {}
    table.insert(ot, "{\n")
    depth = depth + 1
    formattablelist[t] = true
    for k, v in pairs(t) do
        if type(v) ~= "function" then
            if depth > 0 then table.insert(ot, formattab(depth)) end
            table.insert(ot, '[')
            table.insert(ot, formatvalue(k))
            table.insert(ot, '] = ')
            if type(v) == "table" then
                if formattablelist[v] then
                    table.insert(ot, tostring(v))
                else
                    table.insert(ot, table.format(v, depth))
                end
            else
                table.insert(ot, formatvalue(v))
            end
            table.insert(ot, ',\n')
        end
    end
    formattablelist[t] = nil
    depth = depth - 1
    if depth > 0 then table.insert(ot, formattab(depth)) end
    table.insert(ot, '}')
    return table.concat(ot)
end

function table.printf( t, depth )
    if(t == nil) then
        io.write("nil")
        return
    end
    io.write(table.format(t, depth))
end

function table.output(t, name, depth)
    if t == nil then
        print("table is nil")
    end
    local str = name or "table"
    str = str .. " = " .. table.format(t, depth)
    print(str)
end

function table.rcopy(t)
    local r = {}
    for k, v in pairs(t or {}) do
        if type(v) == 'table' then
            r[k] = table.rcopy(v)
        else
            r[k] = v
        end
    end
    return r
end

function table.rcopya(t)
    local r = {}
    for k, v in pairs(t) do
        if type(v) == 'table' then
            r[k] = table.rcopy(v)
        elseif type(v) ~= "function" then
            r[k] = v
        end
    end
    return r
end

function table.copy(t)
    return table.merge({}, t)
end

function table.deepCopy(src , dest)
    if type(src) ~= "table" then
        return {}
    end
    local t = type(dest) == "table" and dest or {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            t[k] = table.rmerge(t[k], v)
        else
            t[k] = v
        end
    end
    return t
end

function table.hashmap(t, f)
    local r = {}
    for k,v in pairs(t) do
        local key, value = f(v, k)
        if key then
            r[key] = value or v
        end
    end
    return r
end

function table.filter(t, f)
    local r = {}
    for i,v in ipairs(t or emptyTable) do
        if f(v, i) then
            r[#r+1] = v
        end
    end
    return r
end

function table.kfilter(t, f)
    local r = {}
    for k,v in pairs(t or emptyTable) do
        if f(k,v) then
            r[#r+1] = v
        end
    end
    return r
end

function table.find(t, f)
    for i,v in ipairs(t or emptyTable) do
        if f(v, i) then return v, i end
    end
end

function table.contains(t , v)
    for index , it in ipairs(t or emptyTable) do
        if it == v then
            return true, index
        end
    end
    return false
end

function table.kfind(t, f)
    for k,v in pairs(t or emptyTable) do
        if f(v, k) then return v, k end
    end
end

function table.drop(t, count)
    local d = {}
    for i = #t, count + 1, -1 do
        table.insert(d, 1, t[i])
    end
    return d
end

function table.take(t, count)
    local d = {}
    for i,v in ipairs(t) do
        d[#d+1] = v
        if i >= count then break end
    end
    return d
end

function table.removeItem(array, item, func)
    if type(func) == "function" then
        local id = func(item)
        for index, v in ipairs(array or emptyTable) do
            if func(v) == id then
                return table.remove(array, index)
            end
        end
        return
    end
    for index, v in ipairs(array or emptyTable) do
        if v == item then
            return table.remove(array, index)
        end
    end
end

local function Index(array, item, func)
    if not  array then
        return
    end

    if type(func) == "function" then
        local id = func(item)
        for index, v in ipairs(array) do
            if func(v) == id then
                return index
            end
        end
        return
    end
    for index, v in ipairs(array) do
        if v == item then
            return index
        end
    end
end
table.index = Index
function table.replaceItem(array, item, func)
    if array then
        local index = Index(array, item, func)
        if index then
            array[index] = item
        else
            array[#array+1] = item
        end
    end
    return array
end

function table.replaceItems(array, items, idfunc, diffFunc)
    diffFunc = diffFunc or function() return true end
    local idMap = {}
    local diffList = {}
    for _,v in ipairs(items) do
        idMap[idfunc(v)] = v
    end
    if array and next(idMap) then
        for i,v in ipairs(array) do
            if not next(idMap) then
                break
            end
            local id = idfunc(v)
            local new = idMap[id]
            local old = array[i]
            if new and diffFunc(old, new) then
                diffList[#diffList + 1] = new
                array[i] = new
            end
            idMap[id] = nil
        end
        for _,v in pairs(idMap) do
            array[#array+1] = v
            diffList[#diffList + 1] = v
        end
    end
    return array, next(diffList), diffList
end

function table.removeItems(array, items, func1, func2)
    local removed = {}
    if not array then
        return array, removed
    end
    local idMap = table.reverse(items, true, type(func2) == "function" and func2 or function(v) return v end)
    local t = {}
    if type(func1) == "function" then
        for _,v in ipairs(array) do
            if not idMap[func1(v)] then
                t[#t+1] = v
            else
                removed[#removed+1] = v
            end
        end
        return t, removed
    end

    for _,v in ipairs(array) do
        if not idMap[v] then
            t[#t+1] = v
        else
            removed[#removed+1] = v
        end
    end
    return t, removed
end

function table.getkey(t, item)
    for index, v in pairs(t or emptyTable) do
        if v == item then
            return index
        end
    end
end

function table.foreachk(t, func)
    for k, v in pairs(t or emptyTable) do
        func(v, k)
    end
end


function table.foreach(t, func)
    for i, v in ipairs(t or emptyTable) do
        func(v, i)
    end
end

function table.merge(dest, src)
    --安全校验，防止报错
    if not src then
        return dest or {}
    end
    for k, v in pairs(src or emptyTable) do
        dest[k] = v
    end
    return dest
end

function table.rmerge(dest, src)
    --安全校验，防止报错
    if not src then
        return dest or {}
    end
    local t = dest or {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            t[k] = table.rmerge(t[k], v)
        else
            t[k] = v
        end
    end
    return t
end

function table.mergea(dest, src)
    for k, v in pairs(src) do
        if type(v) ~= 'function' then
            dest[k] = v
        end
    end
    return dest
end

function table.keys(t)
    local r = {}
    for k in pairs(t or emptyTable) do
        r[#r+1] = k
    end
    return r
end

function table.values(t)
    local r = {}
    for _, v in pairs(t or emptyTable) do
        r[#r+1] = v
    end
    return r
end

function table.size(t)
    if not t then
        return 0
    end

    if type(t) ~= "table" then
        return 0
    end
    local r = 0
    for _, _ in pairs(t) do r = r + 1 end
    return r
end

function table.empty(t)
    if type(t) ~= "table" then
        return true
    end
    return not next(t)
end

function table.clean(t)
    for key, _ in pairs(t) do
        t[key] = nil
    end
end

function table.array(t, dest)
    local list = dest or {}
    for _, data in pairs(t) do
        list[#list + 1] = data
    end
    return list
end

function table.addrange(t1, t2)
    if not table.empty(t2) then
        for _, v in ipairs(t2) do
            t1[#t1 + 1] = v
            -- table.insert(t1, v)
        end
        return t1
    end
    return t1
end

function table.addrangeWithFilter(t1, t2 , f)
    if not table.empty(t2) then
        for _, v in ipairs(t2) do
            if f(v) then
            t1[#t1 + 1] = v
                -- table.insert(t1, v)
            end
        end
        return t1
    end
    return t1
end

local function next_attribute(t, name)
    local value
    repeat
        name, value = next(t, name)
    until type(value) ~= 'function'
    return name, value
end

function table.attributes(t)
    return next_attribute, t, nil
end

function table.reverse(t, default, func)
    local d = {}
    if type(func) == "function" then
        for k,v in pairs(t) do
            d[func(v)] = default or k
        end
    else
        for k,v in pairs(t) do
            d[v] = default or k
        end
    end
    return d
end

function table.mixin(target, source, force)
    for k,v in pairs(source) do
        if force or not target[k] then
            target[k] = v
        end
    end
end

function table.split(array, split_func)
    local satisfy = {}
    local unsatisfy = {}
    for _,v in ipairs(array or emptyTable) do
        if split_func(v) then
            satisfy[#satisfy + 1] = v
        else
            unsatisfy[#unsatisfy + 1] = v
        end
    end
    return satisfy, unsatisfy
end

function table.arithmetic(default)
    return function(t)
        return setmetatable(t or {}, {
            __index = function() return default end,
            __add = function(a, b)
                if type(a) == "number" then
                    local new = setmetatable({}, getmetatable(b))
                    for k,v in pairs(b) do
                        new[k] = v + a
                    end
                    return new
                elseif type(b) == "number" then
                    local new = setmetatable({}, getmetatable(a))
                    for k,v in pairs(a) do
                        new[k] = v + b
                    end
                    return new
                else
                    local new = setmetatable({}, getmetatable(b))
                    for k,v in pairs(a) do
                        new[k] = v
                    end
                    for k,v in pairs(b) do
                        new[k] = new[k] + v
                    end
                    return new
                end
            end,
            __sub = function(a, b)
                if type(a) == "number" then
                    local new = setmetatable({}, getmetatable(b))
                    for k,v in pairs(b) do
                        new[k] = a - v
                    end
                    return new
                elseif type(b) == "number" then
                    local new = setmetatable({}, getmetatable(a))
                    for k,v in pairs(a) do
                        new[k] = v - b
                    end
                    return new
                else
                    local new = setmetatable({}, getmetatable(b))
                    for k,v in pairs(a) do
                        new[k] = v
                    end
                    for k,v in pairs(b) do
                        new[k] = new[k] - v
                    end
                    return new
                end
            end
        })
    end
end


table.default = table.arithmetic

function table.group(array, func)
    local group = {}
    for _,v in ipairs(array) do
        local key = func(v)
        group[key] = group[key] or {}

        table.insert(group[key], v)
    end
    return group
end

function table.groups(array, func)
    local group = _G.table.group(array, func)
    local groups = {}
    for k,v in pairs(group) do
        groups[#groups+1] = { k, v }
    end
    table.sort(groups, function(a, b) return a[1] < b[1] end)
    return groups
end

function table.distinct(array, f)
    local h = {}
    local r = {}
    for _, v in ipairs(array) do
        local hash = f(v)
        if not h[hash] then
            h[hash] = true
            r[#r+1] = v
        end
    end
    return r
end