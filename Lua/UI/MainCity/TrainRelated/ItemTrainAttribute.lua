--[[
    Author: songzeming
    Function: 训练界面 兵种属性Item 攻击、防御、生命
]]
local ItemTrainAttribute = fgui.extension_class(GComponent)
fgui.register_extension('ui://MainCity/itemTrainAttributes', ItemTrainAttribute)

local CTR = {
    'attack', --攻击
    'defence', --防御
    'health', --生命
    'power', --战斗力
    'range' --攻击距离
}
local ARMY_TYPE = {
    'Atk',
    'Def',
    'Hp',
    'Power',
    'Distance'
}
--通过建筑配置ID获取兵种 攻击/防御/生命 最大值
local function GetAttMax(armyType, index)
    return ConfigMgr.GetVar(ARMY_TYPE[index] .. 'Max'..armyType)
end

function ItemTrainAttribute:ctor()
    self._ctr = self:GetController('Ctr')
end

function ItemTrainAttribute:Init(index, armyId)
    local conf = ConfigMgr.GetItem('configArmys', armyId)
    local name = CTR[index]
    self._ctr.selectedPage = name
    local value = conf[name]
    self._text.text = value
    self['_' .. name].value = value / GetAttMax(conf.army_type, index) * 100
end

return ItemTrainAttribute
