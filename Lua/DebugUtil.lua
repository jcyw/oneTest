local DebugUtil = {}

local debugPrint = print
_G.isGMClosePrint = false
local isNotShowLog = (CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.Android or CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer)

function print(...)
    if isNotShowLog or isGMClosePrint then
        return
    end
    debugPrint(...)
end

function dump(a, ...)
    if type(a) == "table" then
        print(table.inspect(a), ...)
    else
        print(a, ...)
    end
end

--设置Lua_Ide监听端口
local breakSocketHandle, debugXpCall
function DebugUtil.OpenLua_IdeDebug()
    if KSUtil.IsEditor() then
        breakSocketHandle, debugXpCall = require("LuaDebug")("localhost", 7003)
    end
end

return DebugUtil