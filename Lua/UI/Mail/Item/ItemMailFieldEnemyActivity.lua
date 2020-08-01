--author: 	Amu
--time:		2019-12-09 21:12:05

local CommonModel = import("Model/CommonModel")

local ItemMailFieldEnemyActivity = fgui.extension_class(GButton)
fgui.register_extension("ui://Mail/itemMailFieldEnemyActivity", ItemMailFieldEnemyActivity)


function ItemMailFieldEnemyActivity:ctor()
    self._title = self:GetChild("textName1")
    self._time = self:GetChild("textTime")

    self._playIcon = self:GetChild("icon")
    self._playName = self:GetChild("textPlayerName")
    self._playPos = self:GetChild("textPlayerCoordinate")

    self._enemyIcon = self:GetChild("iconSoldier")
    self._enemyName = self:GetChild("textSoldierName")
    -- self._enemyLevel = self:GetChild("textSoldierLevel")

    self._enemyArmyLevel = self:GetChild("numberCombatEffectiveness2")
    self._enemyArmyNum = self:GetChild("numberCombatEffectiveness")
    self._enemyArmyLost = self:GetChild("numberTroops")
    self._enemyArmyAlive = self:GetChild("numberSurvival")

    self._playerPower = self:GetChild("text1")
    self._playerArmyNum = self:GetChild("text2")
    self._playerArmyInjured = self:GetChild("text3")
    self._playerArmyPoint = self:GetChild("text4")
    self._brastsAlive = self:GetChild("text5")
    self._brastsLost = self:GetChild("text6")

    self._line = self:GetChild("iconBg2")

    self._lineY = self._line.y

    self._content = self:GetChild("textContent2")

    self._ctrView = self:GetController("c1")


    self:InitEvent()
end

function ItemMailFieldEnemyActivity:InitEvent(  )
    -- self._listView.itemRenderer = function(index, item)
    --     if not index then 
    --         return
    --     end
    --     item:SetData(self.rewards[index+1])
    -- end

    self:AddListener(self._playPos.onClick,function()
        TurnModel.WorldPos(self._pos.x, self._pos.y)
    end)
end

function ItemMailFieldEnemyActivity:SetData(index, _info)

--    self._line.y = self._lineY

    self._time.text = TimeUtil:StampTimeToYMDHMS(_info.CreatedAt)


    local report = JSON.decode(_info.Report)

    -- CommonModel.SetUserAvatar(self._playIcon, report.Defender.Avatar)
    self._playIcon:SetAvatar(report.Defender)
    self._playName.text = report.Defender.Name
    self._pos = {
        x = math.ceil(report.X),
        y = math.ceil(report.Y)
    }
    self._playPos.text = StringUtil.GetI18n("configI18nCommons", "Ui_MTR_Place", self._pos)

    local monsterInfo = ConfigMgr.GetItem("configKnightBases", math.ceil(report.Round))
    self._enemyIcon.icon = UITool.GetIcon(monsterInfo.icon)
    self._enemyName.text = ConfigMgr.GetI18n("configI18nCommons", monsterInfo.I18n)

    self._enemyArmyLevel.text =  math.ceil(report.Round)
    self._enemyArmyNum.text = math.ceil(report.Attacker.Injured + report.Attacker.DefendLost + report.Attacker.Survival)
    self._enemyArmyLost.text = math.ceil(report.Attacker.Injured + report.Attacker.DefendLost)
    self._enemyArmyAlive.text = math.ceil(tonumber(self._enemyArmyLost.text)/tonumber(self._enemyArmyNum.text)*100).."%"

    if report.Defender.Power > 0 then
        self._playerPower.text = "-"..math.ceil(report.Defender.Power)
    else
        self._playerPower.text = math.ceil(report.Defender.Power)
    end
    self._playerArmyNum.text = math.ceil(report.Defender.Injured + report.Defender.DefendLost + report.Defender.Survival)
    self._playerArmyInjured.text = math.ceil(report.Defender.Injured)
    self._playerArmyPoint.text = math.ceil(report.Defender.AddScore)

    if report.Defender.Beasts and #report.Defender.Beasts > 0 then
        -- self._brastsAlive.text = math.ceil(report.Defender.Beasts[1].Health)
        -- self._brastsLost.text = math.ceil(report.Defender.Beasts[1].LostHealth)

        local Health = 0
        local LostHealth = 0
        for _,v in ipairs(report.Defender.Beasts)do
            Health = Health + v.Health
            LostHealth = LostHealth + v.LostHealth
        end
        self._brastsAlive.text = math.ceil(Health)
        self._brastsLost.text = math.ceil(LostHealth)
    end

    if not report.IsWin then
        if report.Defender.Beasts and #report.Defender.Beasts > 0 then
            self._ctrView.selectedIndex = 2
        else
            self._ctrView.selectedIndex = 0
        end
        self._title.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Win_Report")
        self._content.text = ""
    else
        if report.Defender.Beasts and #report.Defender.Beasts > 0 then
            self._ctrView.selectedIndex = 3
        else
            self._ctrView.selectedIndex = 1
        end
        self._title.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Fail_Report")
        self._content.text = StringUtil.GetI18n("configI18nCommons", "Ui_Mail_MonestrDefeat_tips", {number = math.ceil(report.Fail)})
    end

end

return ItemMailFieldEnemyActivity