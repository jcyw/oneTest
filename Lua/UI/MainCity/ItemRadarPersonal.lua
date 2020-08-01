--[[
    author:{zhanzhang}
    time:2019-10-31 10:26:27
    function:{雷达详细条目}
]]

local ItemRadarPersonal = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemRadarPersonal", ItemRadarPersonal)

function ItemRadarPersonal:ctor()
    self._textTagName = self:GetChild("textTagName")
    self._controller = self:GetController("c1")
    self._armyContent = self:GetChild("liebiaoTroops")
    self._skillContent = self:GetChild("liebiaoSkill")
end

function ItemRadarPersonal:Init(data, index, category)
    self._controller.selectedIndex = index
    self._armyContent:RemoveChildrenToPool()
    self._skillContent:RemoveChildrenToPool()
    local info = BuildModel.FindByConfId(Global.BuildingRadar)
    local buildLevel = info.Level

    if index == 0 then
        local len = 0
        if buildLevel > 6 or category == Global.MissionAISiege or data.IsCustomEvent then
            for i = 1, #data.Beasts do
                local item = self._armyContent:AddItemFromPool()
                item:Init(data.Beasts[i], buildLevel > 9 or category == Global.MissionAISiege or data.IsCustomEvent )
            end
            len = len + #data.Beasts
        end
        if buildLevel > 10 or category == Global.MissionAISiege  or data.IsCustomEvent then
            for i = 1, #data.Armies do
                local item = self._armyContent:AddItemFromPool()
                item:Init(data.Armies[i], buildLevel > 12 or category == Global.MissionAISiege )
            end
            len = len + #data.Armies
        end
        self._armyContent.height = len * 134
        self.height = len * 134
        self._skillContent.height = 0
        if category == Global.MissionAssit then
            self._textTagName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Friend_Army")
        else
            self._textTagName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Enemy_Army")
        end
    else
        for i = 1, #data do
            local item = self._skillContent:AddItemFromPool()
            item:Init(data[i])
        end
        self._skillContent.height = #data * 130
        self._armyContent.height = 0
        self.height = #data * 134
    end
end

return ItemRadarPersonal
