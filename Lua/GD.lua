--[[
  @Author: Simon
  @Date: 2020-06-08 11:07:54
  @LastEditTime: 2020-06-11 16:19:41
  @LastEditors: Simon
  @function: {}
--]]
local __GD = {}
local __g = _G

local function DefineVar(t, globalName, var, mark)
    if mark then
        if type(rawget(t, globalName)) == type(var) then
            return rawget(t, globalName)
        end
    end

    rawset(t, globalName, var)

    return var
end
--[[
setmetatable(__GD, {
    __newindex = function(_, name, value)
        rawset(__GD, name, value)
    end,

    __index = function(_, name)
        return rawget(__GD, name)
    end
})
--]]

--:定义文件内的局部变量
local function LVar(globalName, var, mark)
    DefineVar(__GD, globalName, var, mark)

    return var
end

--:定义全局变量
local function GVar(globalName, var, mark)
    DefineVar(__g, globalName, var, mark)

    return var
end

--开启严格模式，不能直接定义Lua 全局变量
local function Strict()
    setmetatable(__g, {
        __newindex = function(_, k)
            error(debug.traceback(("Can not Define GlobalVar %s please Use LVar()"):format(k)))

            --[[ rawset(_G, k, v) --]]
        end
    })
end
--[[ Strict() --]]

LVar("GVar", GVar)
LVar("LVar", LVar)
GVar("GD", __GD)

--[[ _G.GD = __GD --]]

return __GD

--:Test
--[[
--ModelA.lua
local GD = require("GD")
local ModelA = GD.LVar("ModelA", {})

function ModelA:Test()
print("This is a Test")
end
--]]

--[[
--Test.lua
local GD = require("GD")
local ModelA = GD.ModelA
ModelA:Test()
--]]
