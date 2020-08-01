local GD = _G.GD
local GVar = GD.GVar
local LVar = GD.LVar


local EditorHotLoadTable = {}

LVar("RegHotLoad", function(t)
    table.insert(EditorHotLoadTable, t)
end)

dump(GD, "GD")

GVar("EditorRefresh", function()
    for _, v in ipairs(EditorHotLoadTable) do
        if type(v) == "function" then
            v()
        elseif type(v) == "table" and type(v.EditorRefresh) == "function" then
            v:EditorRefresh()
        end
    end
end)

