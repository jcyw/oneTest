--[[
    author:{zhanzhang}
    time:2019-11-01 21:40:23
    function:{雷达兵种详情}
]]
local ArmiesModel = import("Model/ArmiesModel")
local ItemRadarEnemyTroops = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemRadarEnemyTroops", ItemRadarEnemyTroops)
local TrainModel = import("Model/TrainModel")

function ItemRadarEnemyTroops:ctor()
    self._icon = self:GetChild("itemArmy"):GetChild("icon")
    self._controller = self:GetController("c1")
    self._textHP = self:GetChild("textHP")
    self._textHPnum = self:GetChild("textHPnum")
end

function ItemRadarEnemyTroops:Init(data, isShowNum)
    if data.ConfId then
        self._controller.selectedIndex = 0
        local config = ArmiesModel.GetArmyConfig(data.ConfId)
        --显示巨兽

        self._textNumber.text = data.Amount
        self._textNumber.visible = isShowNum
        self._textLevel.text =ArmiesModel.GetLevelText(config.level)
        self._textName.text = StringUtil.GetI18n(I18nType.Army, config.id .. "_NAME")
        -- self._icon.icon = TrainModel.GetImageNormal(data.ConfId)
        self._icon.icon = UITool.GetIcon(config.amry_radar_icon)
        self._iconType.icon = TrainModel.GetArmIcon(config.arm)
    else
        --         DisplayHealth:0
        -- Healing:false
        -- Health:552720
        -- Id:108000
        -- Injured:0
        -- Level:10
        -- MaxHealth:552720
        -- MissionEventId:"bpevaqlpi1ifgr7igtv0"
        -- TemporaryHealth:0
        self._controller.selectedIndex = 1
        self._barHp.max = data.MaxHealth
        self._barHp.value = data.Health
        self._textHPnum.text = math.ceil(data.Health/data.MaxHealth*100).."%"
        self._textHP.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Health")

        self._barHp.visible = isShowNum
        self._textHP.visible = isShowNum

        local config = ArmiesModel.GetArmyConfig(data.Id + data.Level - 1)
        self._textLevel.text = ArmiesModel.GetLevelText(config.level)
        self._textName.text = StringUtil.GetI18n(I18nType.Army, config.id .. "_NAME")
        self._icon.icon = UITool.GetIcon(config.amry_radar_icon)
        self._iconType.icon = TrainModel.GetArmIcon(config.arm)
    end
end

return ItemRadarEnemyTroops
