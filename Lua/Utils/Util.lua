--author: 	Amu
--time:		2019-12-11 20:48:02

local function __TRACKBACK__(errmsg)
    local track_text = debug.traceback(tostring(errmsg), 6);
    Log.Error("===============LUA ERROR=================: {0}", track_text);
    return false;
end

function trycall(func, ...)
    local args = { ... };
    return xpcall(function() 
        func(table.unpack(args)) 
    end, __TRACKBACK__);
end