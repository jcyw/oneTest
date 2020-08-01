local TroopsArmyDetailItem = fgui.extension_class(GButton)
fgui.register_extension("ui://MainCity/itemTroopsDetailsValue", TroopsArmyDetailItem)

local TrainModel = import("Model/TrainModel")

function TroopsArmyDetailItem:ctor()
    self._txtArms = self:GetChild("textArms")
    self._hero = self:GetChild("hero")
    self._txtCombatEffect = self:GetChild("textCombatEffectivenessNumber")
    self._txtAttack = self:GetChild("textAttackNumber")
    self._txtDefense = self:GetChild("textDefenseNumber")
    self._txtLife = self:GetChild("textLifeNumber")
    self._txtSpeed = self:GetChild("textSpeedNumber")
    self._txtWeight = self:GetChild("textWeight-bearingNumber")
    self._txtAttackDist = self:GetChild("textAttackDistanceNumber")
    self._txtGrain = self:GetChild("textGrainConsumptionNumber")
end

function TroopsArmyDetailItem:Init(config)
    self._config = config
    self._txtArms.text = ConfigMgr.GetI18n("configI18nArmys", config.id.."_NAME")
    self._hero.url = TrainModel.GetImageNormal(config.id)
    self._txtCombatEffect.text = tostring(config.power)
    self._txtAttack.text = tostring(config.attack)
    self._txtDefense.text = tostring(config.defence)
    self._txtLife.text = tostring(config.health)
    self._txtSpeed.text = tostring(config.speed)
    self._txtWeight.text = tostring(config.load)
    self._txtAttackDist.text = tostring(math.max(math.ceil(config.range / 10), 1))
    self._txtGrain.text = tostring(math.floor(config.upkeep / 24 * 100) / 100)
end

return TroopsArmyDetailItem