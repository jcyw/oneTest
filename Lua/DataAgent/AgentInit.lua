local function AgentDefine(Agent, name, value)
    assert(Agent[name] == nil, "duplicate key to export! : " .. name)
    Agent[name] = value
end
_G.GD.LVar("AgentDefine", AgentDefine)

--:TODO
--:Hot Load Editor Use
_G.GD.RegHotLoad(function()
    for path in pairs(_G.package.loaded) do
        if string.startwith(path, "DataAgent") and not string.startwith(path, "DataAgent/Init") then
            _G.reload(path)
        end
    end
end)

require("DataAgent/GuideAgent")
require("DataAgent/ItemAgent")
require("DataAgent/ResAgent")
require("DataAgent/TriggerGuideAgent")
require("DataAgent/BeautyAgent")
require("DataAgent/NewWarZoneActivityAgent")
require("DataAgent/SingleActivityAgent")