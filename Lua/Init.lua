function import(filename)
    return CS.KSFramework.LuaModule.Instance:Import(filename)
end

import("GD")
import("GlobalVars")
import("EngineLua")
import("Requires")
import("DataAgent/AgentInit")
import("RequireExtensions")

local Main = import("Main")
Main.OnInitOK()