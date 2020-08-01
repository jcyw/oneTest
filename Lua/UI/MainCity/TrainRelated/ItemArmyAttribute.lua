--[[
    Author: xiaoze
    Function: 训练进阶 兵种属性列表
]]
local ItemArmyAttribute = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/ItemArmyAttribute", ItemArmyAttribute)

local TrainModel = import("Model/TrainModel")
local ConfigMgr = _G.ConfigMgr
local I18nType = _G.I18nType
local StringUtil = _G.StringUtil

--通过建筑配置ID获取兵种 攻击/防御/生命 最大值
local ARMY_TYPE = {
    {
        Key = "Atk",
        GlobalKey = "attack",
        I18n = "UI_Details_Attack"
    },
    {
        Key = "Def",
        GlobalKey = "defence",
        I18n = "UI_Details_Defense"
    },
    {
        Key = "Hp",
        GlobalKey = "health",
        I18n = "UI_Details_Health"
    }
}

function ItemArmyAttribute:ctor()
end

function ItemArmyAttribute:SetArmyAttribute(armyId)
    local conf = TrainModel.GetConf(armyId)
    if not conf then
        return
    end

    self._list:GetChildAt(0):SetLevel(string.format("T%d", conf.level))

    local maxPower = TrainModel.GetMaxArmyPower(armyId)
    local textPower = StringUtil.GetI18n(I18nType.Commmon, "Ui_Power")
    self._list:GetChildAt(1):SetAttribute(textPower, conf.power / maxPower * 100, math.floor(conf.power))

    for i = 3, self._list.numChildren do
        local data = ARMY_TYPE[i - 2]
        local maxValue = ConfigMgr.GetVar(data.Key .. 'Max' .. conf.army_type)
        local value = conf[data.GlobalKey]
        local item = self._list:GetChildAt(i - 1)
        local title = StringUtil.GetI18n(I18nType.Commmon, data.I18n)
        item:SetAttribute(title, value / maxValue * 100, value)
    end
end

function ItemArmyAttribute:SetArmyAttributeOver(advancedArmyId)
    local conf = TrainModel.GetConf(advancedArmyId)
    if not conf then
        return
    end

    self._list:GetChildAt(0):SetLevel(string.format("T%d", conf.level))
    self._list:GetChildAt(0):SetHighColor(true)

    local maxPower = TrainModel.GetMaxArmyPower(advancedArmyId)
    self._list:GetChildAt(1):SetAttributeOver(true, conf.power / maxPower, math.floor(conf.power))

    for i = 3, self._list.numChildren do
        local data = ARMY_TYPE[i - 2]
        local maxValue = ConfigMgr.GetVar(data.Key .. 'Max' .. conf.army_type)
        local value = conf[data.GlobalKey]
        self._list:GetChildAt(i - 1):SetAttributeOver(true, value / maxValue, value)
    end 
end

return ItemArmyAttribute