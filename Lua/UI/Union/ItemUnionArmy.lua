--[[
    author:Temmie
    time:2019-12-12 10:21:38
    function:联盟集结进攻显示士兵item
]]
local ItemUnionArmy = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemArmy2", ItemUnionArmy)

local ArmiesModel = import("Model/ArmiesModel")
local TrainModel = import("Model/TrainModel")
local MonsterModel = import("Model/MonsterModel")

function ItemUnionArmy:ctor()
    self._btnControl = self:GetController("btnControl")

    self:AddListener(self._btnRepatriate.onClick,function()
        if self.cb then
            self.cb()
        end
    end)
end

function ItemUnionArmy:Init(data)
    local config = ArmiesModel.GetArmyConfig(data.ConfId)
    self.cb = nil
    self.isBeast = false

    self._textNumber.text = data.Amount
    self._textLevel.text = ArmiesModel.GetLevelText(config.level)
    self._textName.text = StringUtil.GetI18n(I18nType.Army, config.id .. "_NAME")
    self._icon.icon = TrainModel.GetImageAvatar(data.ConfId)
    self._iconBg.icon = TrainModel.GetBgAvatar(data.ConfId)
    self._iconType.icon = TrainModel.GetArmIcon(config.arm)
    self._iconType.visible = true
end

function ItemUnionArmy:BeastInit(data)
    self.cb = nil
    self.isBeast = true

    local confId = data.Level > 0 and (data.Id + data.Level - 1) or data.Id
    local config = ConfigMgr.GetItem("configArmys", confId)
    self._textName.text = StringUtil.GetI18n(I18nType.Army, config.id.."_NAME")
    self._textLevel.text = ArmiesModel.GetLevelText(data.Level)
    self._icon.icon = UITool.GetIcon(config.army_port)
    self._iconBg.icon = UITool.GetIcon(config.amry_icon_bg)
    self._textNumber.text = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_Power")..Tool.FormatNumberThousands(MonsterModel.GetMonsterRealPower(data.Id, data.Level, data.Health, data.MaxHealth))
    self._iconType.visible = false
    self._barHp.value = (data.Health / config.health) * 100
end

function ItemUnionArmy:ShowBtn(isShow)
    local cur = self.isBeast and "beast" or "hide"
    self._btnControl.selectedPage = isShow and "show" or cur
end

function ItemUnionArmy:SetCb(cb)
    self.cb = cb
end

return ItemUnionArmy
