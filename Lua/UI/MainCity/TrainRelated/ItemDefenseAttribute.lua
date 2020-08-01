--[[
    Author: songzeming
    Function: 训练界面 兵种属性Item 攻击、战斗力、攻击距离
]]
local ItemDefenseAttribute = fgui.extension_class(GComponent)
fgui.register_extension('ui://MainCity/itemDefenseAttributes', ItemDefenseAttribute)

local CONFIG_TYPE = {
    'attack', --攻击
    'power', --战斗力
    'range' --攻击距离
}
local I18N = {
    "UI_Details_Attack",
    "UI_Details_Power",
    "UI_Details_Distance"
}
local ARMY_TYPE = {
    'Atk',
    'Power',
    'Distance'
}
--通过建筑配置ID获取兵种 攻击/战斗力/攻击距离 最大值
local function GetAttMax(armyType, index)
    return ConfigMgr.GetVar(ARMY_TYPE[index] .. 'Max'..armyType)
end

function ItemDefenseAttribute:ctor()
    self._bar.value = -1
end

function ItemDefenseAttribute:Init(index, armyId)
    local conf = ConfigMgr.GetItem('configArmys', armyId)
    local value = conf[CONFIG_TYPE[index]]
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, I18N[index])
    self._text.text = value
    self._bar.value = value / GetAttMax(conf.army_type, index) * 100
end

return ItemDefenseAttribute
