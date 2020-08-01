--[[
    Author: zixiao
    Function: 怪兽图鉴
]]
local Global = _G.Global

local MonsterManual = UIMgr:NewUI("MonsterManual")
local MonsterModel = import("Model/MonsterModel")
local JumpMap = import("Model/JumpMap")
local AnimationMonster = import("Model/Animation/AnimationMonster")
	
function MonsterManual:OnInit()
	local view = self.Controller.contentPane
	self._ctr = view:GetController("Blood")
	self._iconArrow = view:GetChild("iconArrow")
	self._iconArrow2 = view:GetChild("iconArrow2")
	self._textTitle = view:GetChild("textName")
	-- self._textArmName = view:GetChild("titleArmName")
	self._textName = view:GetChild("titleName")
	self._textDesc = view:GetChild("titleName2")
	self._textLevel = view:GetChild("textLevel")
	self._textAttribute = view:GetChild("textAttribute")
	self._textAttributeNum = view:GetChild("textAttributeNum")
	self._textBlood = view:GetChild("textBlood")
	-- self._textHpTitle = view:GetChild("textHP")
	self._btnHelp = view:GetChild("btnHelp")
	self._btnReturn = view:GetChild("btnReturn")
	self._btnGet = view:GetChild("btnGet")
	self._btnTreat = view:GetChild("btnTreatment")
	self._btnArrowL = view:GetChild("arrowL")
	self._btnArrowR = view:GetChild("arrowR")
	self._attributedrop = view:GetChild("attributedrop")
	self.itemAttributes = {}
	local names = {"MAP_ATTACK_BUTTON", "BUTTON_DEFENSE", "UI_Details_Health"}
	for i = 1, 3 do
		self.itemAttributes[i] = view:GetChild("itemAttributes" .. i)
		self.itemAttributes[i]:SetTitle(StringUtil.GetI18n(I18nType.Commmon, names[i]))
	end
	self.bloodProgressBar = {}
	local barsName = {"BloodDark", "BloodRed", "BloodGreen", "BloodOrange"}
	for _, name in ipairs(barsName) do
		table.insert(self.bloodProgressBar, view:GetChild(name))
	end
	self._btnGet.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CLASS_PREVIEW")
	self._btnTreat.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CURE")
	self._textAttribute.text = StringUtil.GetI18n(I18nType.Commmon, "UI_BASIC_ATTRIBUTE")
	self._textTitle.text = StringUtil.GetI18n(I18nType.Commmon, "UI_BEAST_BASE_IMG")
	-- self._textHpTitle.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Health")
	self.featuresList = {self._icon1,self._icon2,self._icon3}

	self:InitEvent()

	self.effectNodeL = UIMgr:CreateObject("Effect", "EffectNode")
    self.effectNodeL.xy = Vector2(self._btnArrowL.width,self._btnArrowL.height)*0.5
	self._btnArrowL:AddChild(self.effectNodeL)
	self.effectNodeL:PlayEffectLoop("effects/arrow_guide/prefab/effect_arrow_guide_p",Vector3.one,0)

    self.effectNodeR = UIMgr:CreateObject("Effect", "EffectNode")
    self.effectNodeR.xy = Vector2(self._btnArrowR.width,self._btnArrowR.height)*0.5
    self._btnArrowR:AddChild(self.effectNodeR)
    self.effectNodeR:PlayEffectLoop("effects/arrow_guide/prefab/effect_arrow_guide_p",Vector3.one,0)

	self._loadProgress.visible = false
end

function MonsterManual:OnClose()
	AnimationMonster.Clear()
end

--播放巨兽动画
function MonsterManual:PlayBeastAnim()
	if UIMgr:GetUIOpen("MonsterManual") then
        AnimationMonster.PlayMonsterAnim(self.Controller.contentPane, AnimationMonster.From.Manual, self.realMonsterID, self.percent < 0.1, 2)
    end
end

function MonsterManual:InitEvent()
	self:AddListener(self._btnReturn.onClick,function ()
		UIMgr:Close("MonsterManual")
	end)

	self:AddListener(self._btnHelp.onClick,function ()
		local data = {
		    title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
		    info = StringUtil.GetI18n(I18nType.Commmon, "TIPS_BEAST_HAND_BOOK")
		}
		UIMgr:Open("ConfirmPopupTextCentered", data)
	end)

	self:AddListener(self._btnGet.onClick,function ()
		UIMgr:Open("MonsterClassPreview", self.info)
	end)

	self:AddListener(self._btnTreat.onClick,function ()
		local build = BuildModel.FindByConfId(Global.BuildingBeastHospital)
		if build and build.Level > 0 then
			MonsterModel.RequestGetMonsterList(false, function(list)
				AnimationMonster.Clear()
				UIMgr:Open("MonsterHospital", self.info.Id, function()
					self:PlayBeastAnim()
				end)
			end)
		else
			UIMgr:Close("MonsterManual")
			UIMgr:Close("MonsterOverview")
			local data = {jump = 810000, para = Global.BuildingBeastHospital}
			JumpMap:JumpTo(data)
		end
	end)

	self:AddListener(self._btnArrowL.onClick,function ()
		self:ChangeIndex(-1)
		self._btnArrowR.visible = true
	end)

	self:AddListener(self._btnArrowR.onClick,function ()
		self:ChangeIndex(1)
		self._btnArrowL.visible = true
	end)

	--巨兽治疗完成通知
    self:AddEvent(
        EventDefines.UIBeastFinishCureRsp,
        function()
            --治疗完成后应该收到通知
            self:RefreshWindow()
        end
    )
end

function MonsterManual:ChangeIndex(num)
	self.index = self.index + num
	if self.index <= 1 then
		-- self.index = #self.infos
		self._btnArrowL.visible = false
	elseif self.index >= #self.infos then
		-- self.index = 1
		self._btnArrowR.visible = false
	end
	self.info = self.infos[self.index]
	self:RefreshWindow()
end

function MonsterManual:OnOpen(infos, index, ignoreArrow)
	self.info = infos[index]

	-- 提取已解锁巨兽
	self.infos = {}
	for _,v in pairs(infos) do
		if MonsterModel.IsUnlock(v.Id) then
			table.insert(self.infos, v)
		end
	end
	table.sort(self.infos, function(a, b)
		return a.Id < b.Id
	end)

	self.index = 0
	for _,v in pairs(self.infos) do
		self.index = self.index + 1
		if self.info.Id == v.Id then
			break;
		end
	end
	
	self.ignoreArrow = ignoreArrow

	self:RefreshWindow()
end

function MonsterManual:RefreshWindow()
	if not self.info then
		return
	end
	self.realMonsterID = MonsterModel.GetMonsterRealID(self.info.Id, self.info.Level)
	local name, desc = MonsterModel.GetMonsterNames(self.realMonsterID)
	-- self._textArmName.text = name
	self._textName.text = name
	
	self._textDesc.text = desc
	local conf = ConfigMgr.GetItem("configArmys", self.realMonsterID)
	local typeConf = ConfigMgr.GetItem("configArmyTypes", conf.arm)
	local maxHealth = MonsterModel.GetMonsterRealMaxHealth(self.info)--conf.health
	local percent = MonsterModel.GetBloodPercent(self.index, 0) * 0.01
	self.percent = percent
	-- percent = (percent > 1 and 1 or percent) * 0.01
	self.monsterHpMax = maxHealth

	self._bg.icon = UITool.GetIcon(typeConf.beast_nest)
	self._iconMonster.icon = UITool.GetIcon(typeConf.icon)

	-- self._textLevel.text = MonsterModel.GetLevelLabel(self.realMonsterID)

	local curmaxAttack = MonsterModel.GetMonsterRealMaxAttack(self.info.Id)
	local maxAttack =Global.AtkMax6
	-- local curAttack = MonsterModel.GetMonsterRealAttack(self.info.Id)
	local curmaxDefence = MonsterModel.GetMonsterRealMaxDefence(self.info.Id)
	local maxDefence = Global.DefMax6
	-- local curDefence = MonsterModel.GetMonsterRealDefence(self.info.Id)

	local beastmaxHealth = Global.HpMax6
	--local curHp = MonsterModel.GetMonsterDisplayHealth(self.index)
	--巨兽最大等级10 （如果要拓展等级上限需要优化）
	local maxMonsterId = MonsterModel.GetMonsterRealID(self.info.Id, 10)
	local maxMonsterCfg = ConfigMgr.GetItem("configArmys",maxMonsterId)
	--巨兽中最高值对应的进度条长度
	self.itemAttributes[1]:SetBarScaleX(maxMonsterCfg.attack/maxAttack)
	self.itemAttributes[2]:SetBarScaleX(maxMonsterCfg.defence/maxDefence)
	self.itemAttributes[3]:SetBarScaleX(maxMonsterCfg.health/beastmaxHealth)
	--当前巨兽属性成长进度
	self.itemAttributes[1]:SetMax(maxMonsterCfg.attack)
	self.itemAttributes[2]:SetMax(maxMonsterCfg.defence)
	self.itemAttributes[3]:SetMax(maxMonsterCfg.health)
	self.itemAttributes[1]:SetBarColor("red")
	self.itemAttributes[2]:SetBarColor("green")
	self.itemAttributes[3]:SetBarColor("blue")
	self.itemAttributes[1]:SetTextNum(curmaxAttack)
	self.itemAttributes[2]:SetTextNum(curmaxDefence)
	self.itemAttributes[3]:SetTextNum(self.monsterHpMax)
	self.itemAttributes[1]:SetPercent(conf.attack / maxMonsterCfg.attack)
	self.itemAttributes[2]:SetPercent(conf.defence / maxMonsterCfg.defence)
	self.itemAttributes[3]:SetPercent(conf.health / maxMonsterCfg.health)
	local power = MonsterModel.GetMonsterRealPower(self.info.Id, self.info.Level)
	local maxpower = MonsterModel.GetMonsterPower(self.info.Id, self.info.Level)
	self._textAttributeNum.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Main_Power", {num = Tool.FormatNumberThousands(power)})
	self._attributedrop.text = string.format("%.0f",((maxpower-power) / maxpower*100)).. "%"

	self._textBlood.text = math.floor(math.min(percent * 100, 100)) .. "%"
	self:SetProgressMax(maxHealth)
	self:SetProgressValue(MonsterModel.GetMonsterDisplayHealth(self.index))
	if self.ignoreArrow then
		self._btnArrowL.visible = false
		self._btnArrowR.visible = false
	else
		self._btnArrowL.visible = #self.infos ~= 1
		self._btnArrowR.visible = #self.infos ~= 1
	end
	if self.index <= 1 then
		self._btnArrowL.visible = false
	elseif self.index >= #self.infos then
		self._btnArrowR.visible = false
	end
	self:ShowFeatures(typeConf)

	self:PlayBeastAnim()
end

function MonsterManual:SetProgressMax(value)
	for i, bar in ipairs(self.bloodProgressBar) do
		bar.max = value
	end
end

function MonsterManual:SetProgressValue(value)
	for _, bar in ipairs(self.bloodProgressBar) do
		bar.value = value
	end
	self:CheckBarState(value)
end

function MonsterManual:CheckBarState(value)
	local breakPer = {10,60,90,100}
	local percent = value / self.monsterHpMax * 100
	self._ctr.selectedIndex = 0
	local visible = percent < 100 and true or false
	self._iconArrow.visible = visible
	self._iconArrow2.visible = visible
	self._attributedrop.visible = visible
	self._textAttribute.x =
		visible and (750/2 - self._textAttribute.width) or (750 - self._textAttribute.width)/2
	print(_G.Screen.width,self._textAttribute.width,self._textAttribute.x)
	for i, v in ipairs(breakPer) do
		if percent < v then
			self._ctr.selectedIndex = 4 - i
			break
		end
	end
end

function MonsterManual:ShowFeatures(typeConf)
	if typeConf then
		for i=1,3 do
			local skillId =  typeConf.skill_id[i]
			self.featuresList[i].visible = skillId
			if skillId then
				self.featuresList[i]:SetData(skillId)
			end
		end
	end
end

return MonsterManual