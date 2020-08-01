--[[
    author:{zhanzhang}
    time:2020-02-26 16:55:11
    function:{联盟标记地图图标}
]]
local ItemMapAllianceMark = fgui.extension_class(GComponent)
fgui.register_extension("ui://WorldCity/ItemMapAllianceMark", ItemMapAllianceMark)

function ItemMapAllianceMark:ctor()
    --
    self._controller = self:GetController("c1")
end

function ItemMapAllianceMark:OnRegister()
end
--刷新联盟标记
function ItemMapAllianceMark:Refresh(info)
    -- Category:0
    -- CreatedAt:1582705995
    -- Name:""
    -- X:314
    -- Y:238
    self._controller.selectedIndex = info.Category
    if info.Name ~= "" then
        self._nameGroup.visible = true
        self._markName.text = info.Name
    else
        self._nameGroup.visible = false
    end
end

return ItemMapAllianceMark
