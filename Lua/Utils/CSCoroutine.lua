local util = require 'xlua.util'
local cs_coroutine_runner = CS.KSFramework.Main.Instance

local funcMap = {}

return {
    Start = function(func)
        local t_fun =util.cs_generator(func)
        local co = cs_coroutine_runner:StartCoroutine(t_fun)
        funcMap[func] = co
    end,

    Stop = function(func)
        local co = funcMap[func]
        if co then
            cs_coroutine_runner:StopCoroutine(co)
            funcMap[func] = nil
        end
    end,

    Clear = function()
        for func, co in pairs(funcMap) do
            cs_coroutine_runner:StopCoroutine(co)
        end
        funcMap = {}
    end
}