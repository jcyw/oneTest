--author: 	Amu
--time:		2019-07-22 17:21:45

local TrainModel = import("Model/TrainModel")

local ItemTroopAssistance = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemTroopAssistance", ItemTroopAssistance)


function ItemTroopAssistance:ctor()
    self._nameText = self:GetChild("textName")
    self._numText = self:GetChild("textNumber")
    self._icon = self:GetChild("icon")
    self._iconArms = self:GetChild("iconArms")
    self._troopsBg = self:GetChild("textTroopsBg")
    self._textTroops = self:GetChild("textTroops")

    self._icon_x = self._icon.x
    -- self._troopsBg.visible = false

    self:InitEvent()
end

function ItemTroopAssistance:InitEvent(  )
end

function ItemTroopAssistance:SetData(index, info)
    local confId = nil
    if info.ConfId then
        confId = info.ConfId
        self._numText.text = math.ceil(info.Amount)
    else
        confId = info.Id + info.Level - 1
    end

    self._nameText.text = ConfigMgr.GetI18n("configI18nArmys", math.ceil(confId) .. "_NAME")
    local config = ConfigMgr.GetItem("configArmys", math.ceil(confId))
    self._icon.icon = TrainModel.GetImageAvatar(confId)
    local iconArmsUrl = ConfigMgr.GetItem("configArmyTypes", config.arm)
    if iconArmsUrl.icon then
        self._iconArms.icon = UITool.GetIcon(iconArmsUrl.icon)
    end
    self._textTroops.text = ArmiesModel.GetLevelText(config.level)
end

return ItemTroopAssistance