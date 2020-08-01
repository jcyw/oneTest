--author: 	Amu
--time:		2020-06-28 15:13:18

local ArmiesModel = import("Model/ArmiesModel")
local TrainModel = import("Model/TrainModel")
local MonsterModel = import("Model/MonsterModel")

local ItemArmy2 = fgui.extension_class(GComponent)
fgui.register_extension("ui://Arena/itemArmy2", ItemArmy2)


function ItemArmy2:ctor()

    self._iconRank = self:GetChild("iconRank")

    self._icon = self:GetChild("_icon")
    self._name = self:GetChild("_name")
    self._union = self:GetChild("_union")


    self._ctrView = self:GetController("c1")

    self:InitEvent()
end

function ItemArmy2:InitEvent(  )
end

function ItemArmy2:ArmieInit(data)
    local config = ArmiesModel.GetArmyConfig(data.ConfId)

    self._textNumber.text = data.Amount
    self._textLevel.text = ArmiesModel.GetLevelText(config.level)
    self._textName.text = StringUtil.GetI18n(I18nType.Army, config.id .. "_NAME")
    self._icon.icon = TrainModel.GetImageAvatar(data.ConfId)
    self._bg.icon = TrainModel.GetBgAvatar(data.ConfId)
    self._iconType.icon = TrainModel.GetArmIcon(config.arm)
    self._iconType.visible = true
    self._ctrView.selectedIndex = 0
end

function ItemArmy2:BeastInit(data)
    local confId = data.Level > 0 and (data.Id + data.Level - 1) or data.Id
    local config = ConfigMgr.GetItem("configArmys", confId)
    self._textName.text = StringUtil.GetI18n(I18nType.Army, config.id.."_NAME")
    self._textLevel.text = ArmiesModel.GetLevelText(data.Level)
    self._icon.icon = UITool.GetIcon(config.army_port)
    self._bg.icon = UITool.GetIcon(config.amry_icon_bg)
    self._textNumber.text = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_Power")..Tool.FormatNumberThousands(MonsterModel.GetMonsterRealPower(data.Id, data.Level, data.Health, data.MaxHealth))
    self._barHp.value = (data.Health / config.health) * 100
    self._iconType.visible = false
    self._ctrView.selectedIndex = 1
end

return ItemArmy2