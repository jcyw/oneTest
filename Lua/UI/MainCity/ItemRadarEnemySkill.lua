--[[
    author:{zhanzhang}
    time:2019-11-01 19:36:10
    function:{雷达兵种技能详情}
]]
local ItemRadarEnemySkill = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemRadarEnemySkill", ItemRadarEnemySkill)

function ItemRadarEnemySkill:ctor()
end

function ItemRadarEnemySkill:Init(data)
    self._textName.text = ""
    self._textDesc.text = ""
end

return ItemRadarEnemySkill
