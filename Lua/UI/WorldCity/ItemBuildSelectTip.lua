--[[
    author:{zhanzhang}
    time:2019-10-10 15:18:10
    function:{地块选中闪烁白色图案}
]]
local GD = _G.GD
local ItemBuildSelectTip = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/BuildSelectTip", ItemBuildSelectTip)

local ItemType = import("Enum/ItemType")

---BuildSelectTip   环状操作列表item
function ItemBuildSelectTip:ctor()
    self._controller = self:GetController("c1")
end

function ItemBuildSelectTip:Init(index)
    self._controller.selectedIndex = index
end

return ItemBuildSelectTip
