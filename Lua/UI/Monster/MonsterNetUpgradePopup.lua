--[[
    Author: xiaosao
    Function: 怪兽梯级提升弹窗
]]
local MonsterNetUpgradePopup = UIMgr:NewUI("MonsterNetUpgradePopup")
local MonsterModel = import("Model/MonsterModel")
local MaxLv = 10

function MonsterNetUpgradePopup:OnInit()
	self:InitEvent()
end

function MonsterNetUpgradePopup:InitEvent()
	self:AddListener(self._btnClose.onClick,function ( )
		UIMgr:Close("MonsterNetUpgradePopup")
	end)

	self:AddListener(self._bgMask.onClick,function ( )
		UIMgr:Close("MonsterNetUpgradePopup")
	end)
end


function MonsterNetUpgradePopup:OnOpen(info)
	self.info = info
	if self.info.type == 1 then
		Util.SetPlayerData("GodzillaUpgradingMark", nil)
	else
		Util.SetPlayerData("KingkangUpgradingMark", nil)
	end
	self:RefrehWindow()
end

function MonsterNetUpgradePopup:RefrehWindow()
	self._titleName.text = ConfigMgr.GetI18n("configI18nCommons", "UI_BEASTLVUP_TIPS")
	self._expend.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon,"equip_ui_19_2")
	local leftConf = ConfigMgr.GetItem("configArmys", self.info.monsterId - 1)
	local rightConf = ConfigMgr.GetItem("configArmys", self.info.monsterId)

	local leftLevel = "T".. self.info.monsterLevel - 1
	local rightLevel = "T".. self.info.monsterLevel
	local leftName = _G.ConfigMgr.GetI18n("configI18nArmys", (self.info.monsterId - 1).."_NAME")
	local rightName =  _G.ConfigMgr.GetI18n("configI18nArmys", self.info.monsterId .."_NAME")
	local monsterType = self.info.type == 1 and "g" or "k"
	local leftImagePath = {"IconFactory","t"..(self.info.monsterLevel - 1).."_"..monsterType}
	local rightImagePath = {"IconFactory","t"..self.info.monsterLevel.."_"..monsterType}
	self._leftImage:SetData(leftLevel,leftName,leftImagePath,false)
	self._rightImage:SetData(rightLevel,rightName,rightImagePath,true)

	self._armyAttribute1:SetArmyAttribute(self.info.monsterId-1)
    self._armyAttribute2:SetArmyAttribute(self.info.monsterId-1)
    self._armyAttribute2:SetArmyAttributeOver(self.info.monsterId)
end

return MonsterNetUpgradePopup