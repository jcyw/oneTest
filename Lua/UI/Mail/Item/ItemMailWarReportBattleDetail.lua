--author: 	Amu
--time:		2019-11-07 10:19:51
local TrainModel = import("Model/TrainModel")
local ArmiesModel = import("Model/ArmiesModel")

local ItemMailWarReportBattleDetail = fgui.extension_class(GButton)
fgui.register_extension("ui://Mail/itemMailWarReportBattleDetail", ItemMailWarReportBattleDetail)


function ItemMailWarReportBattleDetail:ctor()

    self.attackArmyList = {}
    self.defenseArmyList = {}

    self.attackArmyList[1] = self:GetChild("item1")
    self.defenseArmyList[1] = self:GetChild("item2")

    self.attackBox = self:GetChild("tagAttackerR")
    self.defenseBox = self:GetChild("tagDefenderR")

    self.attackBg = self:GetChild("bgWhite1")
    self.defenseBg = self:GetChild("bgWhite2")

    self._height = self.height
    self._itemH = self.attackArmyList[1].height

    self.attackBoxY = self.attackBox.y
    self.defenseBoxY = self.defenseBox.y

    -- self.attackBoxY = self.attackBg.y
    -- self.defenseBoxY = self.defenseBg.y

    self:InitEvent()
end

function ItemMailWarReportBattleDetail:InitEvent(  )
end

function ItemMailWarReportBattleDetail:SetData(report)

    self:Refresh(report)
end

function ItemMailWarReportBattleDetail:Refresh(report)
    local _H = self._height + (#report.Detail.DefenderArmies-1)*self._itemH + (#report.Detail.AttackerArmies-1)*self._itemH
    self:SetSize(self.width, _H)

    self.attackBg.height = #report.Detail.AttackerArmies*self._itemH
    self.defenseBg.height = #report.Detail.DefenderArmies*self._itemH

    -- self.defenseBox.y = self.defenseBoxY + (_massNum - 2)*self.massH + (_maxNum - 1)*self._itemH
    self.defenseBox.y = self.defenseBoxY + (#report.Detail.AttackerArmies-1)*self._itemH

    local index

    --初始化进攻巨兽
    index = 1
    for _,v in pairs(report.Attacker.Beasts) do
        if not self.attackArmyList[index] then
            local temp = UIMgr:CreateObject("Mail", "itemMailWarReport2")
            self:AddChild(temp)
            self.attackArmyList[index] = temp
        end
        self.attackArmyList[index]:GetController("c1").selectedIndex = 1

        self.attackArmyList[index].x = self:GetChild("item1").x
        self.attackArmyList[index].y = self:GetChild("item1").y + self._itemH*(index-1)
        local armyConf = ConfigMgr.GetItem("configArmys", v.Id)
        self.attackArmyList[index]:GetChild("icon").icon = TrainModel.GetImageAvatar(v.Id)
        self.attackArmyList[index]:GetChild("iconBg").icon = TrainModel.GetBgAvatar(v.Id)
        -- local iconArmsUrl = ConfigMgr.GetItem("configArmyTypes", armyConf.arm)
        -- self.attackArmyList[index]:GetChild("iconArms").icon = UITool.GetIcon(iconArmsUrl.icon)

        self.attackArmyList[index]:GetChild("_barHp").max = math.ceil(v.TotalHealth)
        self.attackArmyList[index]:GetChild("_barHp").value = math.ceil(v.Health)

        self.attackArmyList[index]:GetChild("textLifeNum1").text = math.ceil(v.Health)
        self.attackArmyList[index]:GetChild("textLifeNum3").text = math.ceil(v.LostHealth)
        self.attackArmyList[index]:GetChild("textLifeNum2").text = math.ceil(v.Kill)
        self.attackArmyList[index]:GetChild("textLifeNum4").text = math.ceil(v.Damage)

        self.attackArmyList[index]:GetChild("textLv").text = ArmiesModel.GetLevelText(math.ceil(v.Level))
        -- self.attackArmyList[index]:GetChild("textPlayGameName").text = report.Defender.Name
        self.attackArmyList[index].visible = true
        index = index + 1
    end
    
    local attackBeastIndex = (index - 1) > 0 and (index - 1) or 1

    --初始化进攻部队
    -- index = 1
    for _,v in pairs(report.Detail.AttackerArmies) do
        if v.ConfId < 108000 or v.ConfId > 108109 then
            if not self.attackArmyList[index] then
                local temp = UIMgr:CreateObject("Mail", "itemMailWarReport2")
                self:AddChild(temp)
                self.attackArmyList[index] = temp
            end
            self.attackArmyList[index]:GetController("c1").selectedIndex = 0
    
            self.attackArmyList[index].x = self.attackArmyList[attackBeastIndex].x
            self.attackArmyList[index].y = self.attackArmyList[attackBeastIndex].y + self._itemH*(index-attackBeastIndex)
            -- self.attackArmyList[index]:GetChild("textTypeArmsName").text = ConfigMgr.GetI18n('configI18nArmys', math.ceil(v.ConfId)..'_NAME')
            local armyConf = ConfigMgr.GetItem("configArmys", v.ConfId)
            self.attackArmyList[index]:GetChild("icon").icon = TrainModel.GetImageAvatar(v.ConfId)
            self.attackArmyList[index]:GetChild("iconBg").icon = TrainModel.GetBgAvatar(v.ConfId)
            self.attackArmyList[index]:GetChild("textSurvivalNum").text = math.ceil(v.Total - v.Lost)
            self.attackArmyList[index]:GetChild("textAnnihilationNum").text = math.ceil(v.Killed)
            self.attackArmyList[index]:GetChild("textInjuredNum").text = math.ceil(v.Injured)
            self.attackArmyList[index]:GetChild("textKilledNum").text = math.ceil(v.Lost)
            local iconArmsUrl = ConfigMgr.GetItem("configArmyTypes", armyConf.arm)
            self.attackArmyList[index]:GetChild("iconArms").icon = UITool.GetIcon(iconArmsUrl.icon)
            -- self.attackArmyList[index]:GetChild("textPlayGameName").text = report.Defender.Name
            self.attackArmyList[index]:GetChild("textLv").text = ArmiesModel.GetLevelText(math.ceil(armyConf.level))
            self.attackArmyList[index].visible = true
            index = index + 1
        end
    end
    for i = index, #self.attackArmyList do
        self.attackArmyList[i].visible = false
    end

    --初始化防御巨兽
    index = 1
    for _,v in pairs(report.Defender.Beasts) do
        if not self.defenseArmyList[index] then
            local temp = UIMgr:CreateObject("Mail", "itemMailWarReport2")
            self:AddChild(temp)
            self.defenseArmyList[index] = temp
        end
        self.defenseArmyList[index]:GetController("c1").selectedIndex = 1

        self.defenseArmyList[index].x = self:GetChild("item2").x
        self.defenseArmyList[index].y = self:GetChild("item2").y + self._itemH*(index-1)
        local armyConf = ConfigMgr.GetItem("configArmys", v.Id)
        self.defenseArmyList[index]:GetChild("icon").icon = TrainModel.GetImageAvatar(v.Id)
        self.defenseArmyList[index]:GetChild("iconBg").icon = TrainModel.GetBgAvatar(v.Id)
        -- local iconArmsUrl = ConfigMgr.GetItem("configArmyTypes", armyConf.arm)
        -- self.defenseArmyList[index]:GetChild("iconArms").icon = UITool.GetIcon(iconArmsUrl.icon)

        self.defenseArmyList[index]:GetChild("_barHp").max = math.ceil(v.TotalHealth)
        self.defenseArmyList[index]:GetChild("_barHp").value = math.ceil(v.Health)

        self.defenseArmyList[index]:GetChild("textLifeNum1").text = math.ceil(v.Health)
        self.defenseArmyList[index]:GetChild("textLifeNum3").text = math.ceil(v.LostHealth)
        self.defenseArmyList[index]:GetChild("textLifeNum2").text = math.ceil(v.Kill)
        self.defenseArmyList[index]:GetChild("textLifeNum4").text = math.ceil(v.Damage)
        -- self.defenseArmyList[index]:GetChild("textPlayGameName").text = report.Defender.Name
        self.defenseArmyList[index]:GetChild("textLv").text = ArmiesModel.GetLevelText(math.ceil(v.Level))
        self.defenseArmyList[index].visible = true
        index = index + 1
    end
    
    local defenderBeastIndex = (index - 1) > 0 and (index - 1) or 1

    --初始化防守部队
    -- index = 1
    for _,v in pairs(report.Detail.DefenderArmies) do
        if v.ConfId < 108000 or v.ConfId > 108109 then
            if not self.defenseArmyList[index] then
                local temp = UIMgr:CreateObject("Mail", "itemMailWarReport2")
                self:AddChild(temp)
                self.defenseArmyList[index] = temp
            end
            self.defenseArmyList[index]:GetController("c1").selectedIndex = 0
    
            self.defenseArmyList[index].x = self.defenseArmyList[defenderBeastIndex].x
            self.defenseArmyList[index].y = self.defenseArmyList[defenderBeastIndex].y + self._itemH*(index-defenderBeastIndex)
            -- self.defenseArmyList[index]:GetChild("textTypeArmsName").text = ConfigMgr.GetI18n('configI18nArmys', math.ceil(v.ConfId)..'_NAME')
            local armyConf = ConfigMgr.GetItem("configArmys", v.ConfId)
            self.defenseArmyList[index]:GetChild("icon").icon = TrainModel.GetImageAvatar(v.ConfId)
            self.defenseArmyList[index]:GetChild("iconBg").icon = TrainModel.GetBgAvatar(v.ConfId)
            self.defenseArmyList[index]:GetChild("textSurvivalNum").text = math.ceil(v.Total - v.Lost)
            self.defenseArmyList[index]:GetChild("textAnnihilationNum").text = math.ceil(v.Killed)
            self.defenseArmyList[index]:GetChild("textInjuredNum").text = math.ceil(v.Injured)
            self.defenseArmyList[index]:GetChild("textKilledNum").text = math.ceil(v.Lost)
            -- self.defenseArmyList[index]:GetChild("textPlayGameName").text = report.Attacker.Name
            local iconArmsUrl = ConfigMgr.GetItem("configArmyTypes", armyConf.arm)
            self.defenseArmyList[index]:GetChild("iconArms").icon = UITool.GetIcon(iconArmsUrl.icon)
            self.defenseArmyList[index]:GetChild("textLv").text = ArmiesModel.GetLevelText(math.ceil(armyConf.level))
            self.defenseArmyList[index].visible = true
            index = index + 1
        end
    end
    for i = index, #self.defenseArmyList do
        self.defenseArmyList[i].visible = false
    end
end

return ItemMailWarReportBattleDetail