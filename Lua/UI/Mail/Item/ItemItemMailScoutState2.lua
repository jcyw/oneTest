--author: 	Amu
--time:		2019-06-28 11:13:32

local TrainModel = import("Model/TrainModel")

local ItemItemMailScoutState2 = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemItemMailScoutState2", ItemItemMailScoutState2)


function ItemItemMailScoutState2:ctor()
    self._icon = self:GetChild("icon")
    self._iconArms = self:GetChild("iconArms")
    self._name = self:GetChild("textName")
    self._num = self:GetChild("textNumber")
    self._level = self:GetChild("textTroops")
    self._troopsBg = self:GetChild("textTroopsBg")
    self._troopsBg.visible = false

    self:InitEvent()
end

function ItemItemMailScoutState2:InitEvent(  )
end

function ItemItemMailScoutState2:SetData(info, isAcc, isMonster)
    if isMonster then
        self._name.text = ConfigMgr.GetI18n('configI18nArmys', math.ceil(info.Id)..'_NAME')
        local armyConf = ConfigMgr.GetItem("configArmys", info.Id)
        self._icon.icon = TrainModel.GetImageAvatar(info.Id)
        self._level.text = ArmiesModel.GetLevelText(armyConf.level)
        -- local armyTypeConf = ConfigMgr.GetItem("configArmyTypes", armyConf.arm)
        -- self._iconArms.icon = UITool.GetIcon(armyTypeConf.icon)
        self._iconArms.visible = false
        if isAcc then
            self._num.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Main_Power", {num = math.ceil(info.Power)})
        else
            self._num.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Main_Power", {num = "~".. math.ceil(info.Power)})
        end 
    else
        self._name.text = ConfigMgr.GetI18n('configI18nArmys', math.ceil(info.ConfId)..'_NAME')
        local armyConf = ConfigMgr.GetItem("configArmys", info.ConfId)
        self._icon.icon = TrainModel.GetImageAvatar(info.ConfId)
        local armyTypeConf = ConfigMgr.GetItem("configArmyTypes", armyConf.arm)
        self._iconArms.icon = UITool.GetIcon(armyTypeConf.icon)
        self._level.text = ArmiesModel.GetLevelText(armyConf.level)
        if isAcc then
            self._num.text =  math.ceil(info.Amount)
        else
            self._num.text = "~".. math.ceil(info.Amount)
        end 
    end
end

return ItemItemMailScoutState2