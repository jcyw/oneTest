--[[
    Author: zixiao
    Function: 怪兽图鉴
]]
local ItemMonsterOverview = fgui.extension_class(GComponent)
fgui.register_extension("ui://Monster/itemMonsterOverview", ItemMonsterOverview)
local MonsterModel = import("Model/MonsterModel")
local CustomEventManager = import("GameLogic/CustomEventManager")

function ItemMonsterOverview:ctor()
	self._textName = self:GetChild("titleName")
	self._textDesc = self:GetChild("titleName2")
	self._textBlood = self:GetChild("textBlood")
	self._icon = self:GetChild("icon")
	self._bgTouch = self:GetChild("touch")
	self._textLevel = self:GetChild("textLevel")
	self._textComing = self:GetChild("textComing")
	self.bloodProgressBar = {}
	local barsName = {"BloodDark", "BloodRed", "BloodGreen", "BloodOrange"}
	for _, name in ipairs(barsName) do
		table.insert(self.bloodProgressBar, self:GetChild(name))
	end
	self._ctrBlood = self:GetController("Blood")
	self._ctrC1 = self:GetController("c1")
	self._iconImage = self:GetChild("imageUnlock")

	self.tipText = StringUtil.GetI18n(I18nType.Commmon, "UI_LOCKED")
	self._textComing.text = self.tipText
	self:InitEvent()
end

function ItemMonsterOverview:InitEvent()
	self:AddListener(self._bgTouch.onClick,function ()
		if self.data then
			UIMgr:Open("MonsterManual", self.datas, self.index)
		elseif self.lockData then
			if self.lockData.Id == Global.BeastKingkong then
				local temp = Model.GetMap(ModelType.MarchWarnings)[1003]
				
				if temp then
					TipUtil.TipById(50322)
				else
					TipUtil.TipById(50321)
				end
			else
				TipUtil.TipById(50323)
			end
		else
			TipUtil.TipById(50323)
		end
	end)

	--巨兽治疗完成通知
    self:AddEvent(
        EventDefines.UIBeastFinishCureRsp,
        function()
            --治疗完成后应该收到通知
            self:RefreshInfo()
        end
    )
end

function ItemMonsterOverview:SetData(datas, index)
	self.datas = datas
	self.data = datas[index]
	self.index = index
	self:RefreshInfo()
end

function ItemMonsterOverview:RefreshInfo()
	if not self.data then
		return
	end
	self.realMonsterID = MonsterModel.GetMonsterRealID(self.data.Id, self.data.Level)
	local name, desc = MonsterModel.GetMonsterNames(self.realMonsterID)
	local typeId = MonsterModel.GetMonsterTypeId(self.realMonsterID)
	local typeConfig = ConfigMgr.GetItem("configArmyTypes", typeId)

	self._banner.icon = UITool.GetIcon(typeConfig.beast_entrance)
	self._iconMonster.icon = UITool.GetIcon(typeConfig.icon)
	self._textName.text = name
	self._textDesc.text = desc
	-- local armyType = MonsterModel.GetArmyType(self.realMonsterID)
	-- self._iconImage.icon = UITool.GetIcon(armyType.icono)
	self._textLevel.text = MonsterModel.GetLevelLabel(self.realMonsterID)
	self.monsterHpMax = MonsterModel.GetMonsterRealMaxHealth(self.data)--ConfigMgr.GetItem("configArmys", self.realMonsterID).health
	self._textBlood.text = math.floor(MonsterModel.GetBloodPercent(self.index, 0)).."%"
	self._ctrC1.selectedIndex = 0
	self:SetProgressMax(self.monsterHpMax)
	self:SetProgressValue(MonsterModel.GetMonsterDisplayHealth(self.index))
end


function ItemMonsterOverview:SetProgressMax(value)
	for i, bar in ipairs(self.bloodProgressBar) do
		bar.max = value
	end
end

function ItemMonsterOverview:SetProgressValue(value)
	for _, bar in ipairs(self.bloodProgressBar) do
		bar.value = value
	end
	self:CheckBarState(value)
end

function ItemMonsterOverview:CheckBarState(value)
	local breakPer = {10,60,90}
	local percent = value / self.monsterHpMax * 100
	self._ctrBlood.selectedIndex = 0
	for i, v in ipairs(breakPer) do
		if percent < v then
			self._ctrBlood.selectedIndex = 3 - i
			break
		end
	end
end

function ItemMonsterOverview:SetLock(data)
	self.data = nil
	self._ctrC1.selectedIndex = 1
	self.lockData = data
	self.realMonsterID = MonsterModel.GetMonsterRealID(data.Id, 1)
	local name, desc = MonsterModel.GetMonsterNames(self.realMonsterID)
	local typeId = MonsterModel.GetMonsterTypeId(self.realMonsterID)
	local typeConfig = ConfigMgr.GetItem("configArmyTypes", typeId)

	self._banner.icon = UITool.GetIcon(typeConfig.beast_entrance)
	self._iconMonster.icon = UITool.GetIcon(typeConfig.icon)
	self._textName.text = name
	self._textDesc.text = desc
	self._textLevel.text = MonsterModel.GetLevelLabel(self.realMonsterID)
end

function ItemMonsterOverview:SetMoreState(icon)
	self.data = nil
	self._ctrC1.selectedIndex = 2
	self.tipText = StringUtil.GetI18n(I18nType.Commmon, "Tech_Tips2")
	self._textComing.text = self.tipText
	self._banner.icon = UITool.GetIcon(icon)
end


return ItemMonsterOverview