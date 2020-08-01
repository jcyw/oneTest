-- author:{Amu}
-- _time:2019-05-28 15:48:59


local ItemMailFieldEnemyWarReport = fgui.extension_class(GButton)
fgui.register_extension("ui://Mail/itemMailFieldEnemyWarReport", ItemMailFieldEnemyWarReport)

function ItemMailFieldEnemyWarReport:ctor()
    -- self._pos = self:GetChild("textPlace")
    self._btnHelp = self:GetChild("btnHelp")

    self._pos1 = self:GetChild("textCoordinate")
    self._time = self:GetChild("textTime")

    self._warText = self:GetChild("textName1")
    self._winText = self:GetChild("textWin")

    self._enemyIcon = self:GetChild("iconSoldier")
    self._enemyName = self:GetChild("textSoldierName")
    self._enemyLevel = self:GetChild("textSoldierLevel")

    -- self._enemyPro = self:GetChild("progressBar")
    -- self._enemyProNum = self:GetChild("progressBarNum")

    self._armyPower = self:GetChild("numberCombatEffectiveness")
    self._armyNum = self:GetChild("numberTroops")
    self._armyAlive = self:GetChild("numberSurvival")
    self._armyInjured = self:GetChild("numberHurt")
    self._brastsAlive = self:GetChild("textRestHpNum")
    self._brastsLost = self:GetChild("textLostHpNum")

    self._textName2 = self:GetChild("textName2")
    self._bgTagBox2 = self:GetChild("bgTagBox2")

    self._textFail = self:GetChild("textFail")

    self.myHeight = self.height

    self._listView = self:GetChild("liebiao")
    self._listView.touchable = false

    self.itemHeight = 87

    self._ctrView = self:GetController("c1")

    -- self._enemyPro.visible = false
    -- self._enemyProNum.visible = false

    self:InitEvent()
end

function ItemMailFieldEnemyWarReport:InitEvent()
    self._listView.itemRenderer = function(index, item)
        if not index then
            return
        end
        item:SetData(self.rewards[index + 1])
    end

    self:AddListener(self._pos1.onClick,
        function()
            TurnModel.WorldPos(self._pos.x, self._pos.y)
        end
    )

    self:AddListener(self._btnHelp.onClick,
        function()
            UIMgr:Open("MailfailureReason")
        end
    )
end

function ItemMailFieldEnemyWarReport:SetData(index, _info)
    local report = JSON.decode(_info.Report)
    self._pos = {x = report.X, y = report.Y}
    self.rewards = report.Rewards
    -- self._pos.text = "("..math.ceil(report.X)..","..math.ceil(report.Y)..")"
    self._pos1.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_MTR_PlayPlace", {x = math.ceil(report.X), y = math.ceil(report.Y)})
    -- local data = {
    --     x = math.ceil(report.X),
    --     y = math.ceil(report.Y)
    -- }
    -- self._pos.text = StringUtil.GetI18n("configI18nCommons", "Ui_MTR_Place", data)
    self._time.text = TimeUtil:StampTimeToYMDHMS(_info.CreatedAt)
    local monsterInfo = ConfigMgr.GetItem("configMonsters", math.ceil(report.ConfId))
    self._enemyName.text = ConfigMgr.GetI18n("configI18nCommons", "MAP_MONTSTER_" .. math.ceil(report.ConfId)) .. StringUtil.GetI18n(I18nType.Commmon, "Ui_Monsterlv", {number = monsterInfo.level})
    self._enemyIcon.icon = UITool.GetIcon(monsterInfo.monster_avatar)
    -- self._enemyLevel.text = "等级".._info.armyLevel

    self._armyPower.text = "-" .. math.ceil(report.PowerLose)
    self._armyNum.text = math.ceil(report.TotalMember)
    self._armyAlive.text = math.ceil(report.MemberRemain)
    self._armyInjured.text = math.ceil(report.MemberInjured)

    if report.Beasts and #report.Beasts > 0 then
        -- self._brastsAlive.text = math.ceil(report.Beasts[1].Health)
        -- self._brastsLost.text = math.ceil(report.Beasts[1].LostHealth)
        local Health = 0
        local LostHealth = 0
        for _, v in ipairs(report.Beasts) do
            Health = Health + v.Health
            LostHealth = LostHealth + v.LostHealth
        end
        --这个fgui里面是反的，所以这里反一下
        self._brastsAlive.text = math.ceil(LostHealth)
        self._brastsLost.text = math.ceil(Health)
    end

    -- local maxH = math.ceil(#report.Rewards/5)

    if report.IsWin then
        self._warText.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Win_Report")
        self._textName2.text = ConfigMgr.GetI18n("configI18nCommons", "AWARD_TITLE")
        if report.FirstWin then
            self._ctrView.selectedIndex = 1
            if monsterInfo.level >= 30 then
                self._winText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Mail_PVEMAX", {level1 = "lv." .. monsterInfo.level})
            else
                self._winText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Mail_PVE", {level1 = "lv." .. monsterInfo.level, level2 = "lv." .. monsterInfo.level + 1})
            end
        else
            if report.Beasts and #report.Beasts > 0 then
                self._ctrView.selectedIndex = 8
            else
                self._ctrView.selectedIndex = 4
            end
        end
        -- self:SetSize(self.width, self.myHeight + self.itemHeight*#report.Rewards)
        self._listView:SetSize(self._listView.width, self.itemHeight * #report.Rewards + 20)
    else
        self._warText.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Fail_Report")
        self._textName2.text = ConfigMgr.GetI18n("configI18nCommons", "Tips_TITLE")

        if report.Beasts and #report.Beasts > 0 then
            self._ctrView.selectedIndex = 6
        else
            self._ctrView.selectedIndex = 2
        end
        -- self:SetSize(self.width, self.myHeight - self.itemHeight + self._textFail.height)
        self._listView:SetSize(self._listView.width, self._textFail.height + 20)
    end

    self:RefreshListView()
end

function ItemMailFieldEnemyWarReport:RefreshListView()
    self._listView.numItems = #self.rewards
end

return ItemMailFieldEnemyWarReport
