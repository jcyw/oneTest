--[[
    author:Temmie
    time:2019-12-04 21:26:27
    function:出征、编队界面巨兽item
]]
local ItemTroopsDetailsMonster = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemTroopsDetailsFormationMonster", ItemTroopsDetailsMonster)

local BuildModel = import("Model/BuildModel")
local ArmiesModel = import("Model/ArmiesModel")
local MonsterModel = import("Model/MonsterModel")

function ItemTroopsDetailsMonster:ctor()
    self._typeControl = self:GetController("typeControl")
    self:AddListener(self._checkBox.onClick,function(param)
        if self.funcCheckCb then
            self.funcCheckCb(self)
        end
    end)
end

function ItemTroopsDetailsMonster:Init(model, isSelected, ignoreExpedition, checkCallback)
    local confId = model.Level > 0 and (model.Id + model.Level - 1) or model.Id
    self.model = model
    self.funcCheckCb = checkCallback
    self.config = ConfigMgr.GetItem("configArmys", confId)
    self._icon.url = UITool.GetIcon(self.config.army_port)
    self._iconBg.url = UITool.GetIcon(self.config.amry_icon_bg)
    self._textLv.text = ArmiesModel.GetLevelText(model.Level > 0 and model.Level or 1)
    self._barHp.value = (model.Health / self.config.health) * 100
    self._textName.text = StringUtil.GetI18n(I18nType.Army, self.config.id.."_NAME")
    if isSelected then
        if self.funcCheckCb then
            self.funcCheckCb(self)
        end
        self._checkBox.selected = true
    else
        self._checkBox.selected = false
    end
    
    if MonsterModel.IsUnlock(model.Id) then
        if ArmiesModel.IsBeastExpedition(model.Id) and not ignoreExpedition then
            self._typeControl.selectedPage = "out"
        else
            self._typeControl.selectedPage = "unlock"
        end
        self._textDesc.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Power").." "..Tool.FormatNumberThousands(MonsterModel.GetMonsterRealPower(model.Id, model.Level))
    else
        self._typeControl.selectedPage = "lock"
        if model.Id == Global.BeastKingkong then
            self._textLockDesc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_KINGKONG_UNLOCK_TEXT")
        else
            -- local unlockLv = math.fmod(self.config.building, 100)
            local conf = ConfigMgr.GetItem("configBuildingUpgrades", self.config.building)
            local condition = conf.condition[1]
            self._textLockDesc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_MARCH_MONSTER_UNLOCK", {level = condition.level})
        end
    end
end

function ItemTroopsDetailsMonster:SetSelected(isSelected)
    if isSelected then
        if self.funcCheckCb then
            self.funcCheckCb(self)
        end
        self._checkBox.selected = true
    else
        self._checkBox.selected = false
    end
end

return ItemTroopsDetailsMonster
