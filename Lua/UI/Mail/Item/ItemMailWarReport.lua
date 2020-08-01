-- author:{Amu}
-- time:2019-06-04 10:39:50

local GD = _G.GD

local ItemMailWarReport = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailWarReport", ItemMailWarReport)


function ItemMailWarReport:ctor()

    self._poslab = self:GetChild("textPlace")
    self._timelab = self:GetChild("textTime")

    self._result = self:GetChild("textName1")

    self._textExplain = self:GetChild("textExplain")
    self._itemPlayer1 = self:GetChild("itemPlayer1")
    self._itemPlayer2 = self:GetChild("itemPlayer2")
    self._itemPlayer3 = self:GetChild("itemPlayer3")
    self._itemPlayer4 = self:GetChild("itemPlayer4")

    self._btnShare = self:GetChild("btnShare")
    self._btnPlaceEnemy = self:GetChild("btnPlaceEnemy")
    self._textShare = self:GetChild("textShare")
    self._btnBattleDetail = self:GetChild("btnBattleDetail")

    self._massLine = self:GetChild("bgLine1")
    self._btnBoxLine = self:GetChild("bgLine3")
    self._btnBoxH = self.height - self._btnBoxLine.y
    self._sharebtenCtr = self:GetController("sharebtn")

    self.ResLab = {
        [RES_TYPE.Wood] = {
            labText = self:GetChild("textIconNameNumber2"),
            icon = self:GetChild("icon2"),
            nameText = self:GetChild("textIconName2"),
        },
        [RES_TYPE.Iron] = {
            labText = self:GetChild("textIconNameNumber3"),
            icon = self:GetChild("icon3"),
            nameText = self:GetChild("textIconName3"),
        },
        [RES_TYPE.Stone] = {
            labText = self:GetChild("textIconNameNumber4"),
            icon = self:GetChild("icon4"),
            nameText = self:GetChild("textIconName4"),
        },
        [RES_TYPE.Food] = {
            labText = self:GetChild("textIconNameNumber1"),
            icon = self:GetChild("icon1"),
            nameText = self:GetChild("textIconName1"),
        },
    }
    for k,v in pairs(self.ResLab)do
        local config = ConfigMgr.GetItem("configResourcess", k)
        v.nameText.text = StringUtil.GetI18n(I18nType.Commmon, config.key)
    end

    self.attackLab ={
        _icon = self:GetChild("iconMy"),
        namelab = self:GetChild("textNameMy"),
        _poslab = self:GetChild("textPlaceMy"),
        Power = self:GetChild("textBattleNumMy"),
        armyNumlab = self:GetChild("textTroopsNumMy"),
        Killed = self:GetChild("textEliminateNumMy"),
        Lost = self:GetChild("textLossNumMy"),
        Injured = self:GetChild("textInjuredNumMy"),
        Survival = self:GetChild("textSurvivalNumMy"),
        DefendLost = self:GetChild("textArmsNumMy"),
        DefendBeastsLost = self:GetChild("textLostPowerNumMy"),
    }

    self.defenseLab = {
        _icon = self:GetChild("iconEnemy"),
        namelab = self:GetChild("textNameEnemy"),
        _poslab = self:GetChild("textPlaceEnemy"),
        Power = self:GetChild("textBattleNumEnemy"),
        armyNumlab = self:GetChild("textTroopsNumEnemy"),
        Killed = self:GetChild("textEliminateNumEnemy"),
        Lost = self:GetChild("textLossNumEnemy"),
        Injured = self:GetChild("textInjuredNumEnemy"),
        Survival = self:GetChild("textSurvivalNumEnemy"),
        DefendLost = self:GetChild("textArmsNumEnemy"),
        DefendBeastsLost = self:GetChild("textLostPowerNumEnemy"),
    }

    self.massAttackerMembers = {}
    self.massDefenderMembers = {}
    self.myAttriList = {}
    self.enemyAttriList = {}
    self.defenseArmyList = {}
    self.attackArmyList = {}
    self.myAttriList[1] = self:GetChild("item3")
    self.enemyAttriList[1] = self:GetChild("item4")
    self.defenseArmyList[1] = self:GetChild("item1")
    self.attackArmyList[1] = self:GetChild("item2")

    self.massAttackerMembers = {
        self._itemPlayer1,
        self._itemPlayer3,
    }
    self.massDefenderMembers = {
        self._itemPlayer2,
        self._itemPlayer4
    }

    self.massY = self._itemPlayer1.y
    self.massAttackX = self._itemPlayer1.x
    self.massDefenseX = self._itemPlayer2.x
    self.massH = self._itemPlayer1.height + 5


    -- self._myAttri = self:GetChild("bgMy2")
    -- self._enemyAttri = self:GetChild("bgEnemy2")
    -- self._defenseArmy = self:GetChild("bgMy4")
    -- self._attackArmy = self:GetChild("bgEnemy4")

    self._height = self.height
    -- self._myAttriH = self._myAttri.height
    -- self._enemyAttriH = self._enemyAttri.height
    -- self._defenseArmyH = self._defenseArmy.height
    -- self._attackArmyH = self._attackArmy.height

    self.bgBox = self:GetChild("bg")
    -- self.bgBattle = self:GetChild("bgBattle")
    -- self.defenseBox = self:GetChild("tagAttacker")
    -- self.attackBox = self:GetChild("tagDefender")

    self.bgBoxH = self.bgBox.height
    self.bgBoxY = self.bgBox.y
    self._massLineY = self._massLine.y
    self._btnBoxLineY = self._btnBoxLine.y
    -- self.bgBattleY = self.bgBattle.y
    -- self.defenseBoxY = self.defenseBox.y
    -- self.attackBoxY = self.attackBox.y

    self._itemH = self.myAttriList[1].height


    self:InitEvent()
end

function ItemMailWarReport:InitEvent()
    self:AddListener(self._btnShare.onClick,function()
        -- local type = 0
        -- local params = {}
        -- if self.report.Attacker.UserId == self.player or self:IsAttack() then --我攻击别人
        --     params = {
        --         id = self.info.Uuid,
        --         name = self.report.Defender.Name
        --     }
        --     if self.report.IsWin then --胜利
        --         type = PUBLIC_CHAT_TYPE.ChatAttackSuccessShare
        --     else--失败
        --         type = PUBLIC_CHAT_TYPE.ChatAttackFailShare
        --     end
        -- else--别人攻击我
        --     params = {
        --         id = self.info.Uuid,
        --         name = self.report.Attacker.Name
        --     }
        --     if self.report.IsWin then --胜利
        --         type = PUBLIC_CHAT_TYPE.ChatDefenceFailShare
        --     else--失败
        --         type = PUBLIC_CHAT_TYPE.ChatDefenceSuccessShare
        --     end
        -- end
        -- UIMgr:Open("ConfirmPopupShade", type, JSON.encode(params))
    end)

    self:AddListener(self._btnPlaceEnemy.onClick,function() 
        local data = {
            title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
            info = StringUtil.GetI18n(I18nType.Commmon, "Ui_BattleMail_Tips")
        }
        UIMgr:Open("ConfirmPopupTextList", data)
    end)

    self:AddListener(self._btnBattleDetail.onClick,function() 
        UIMgr:Open("MailWarReportBattleDetail", self.report)
    end)

    self:AddListener(self.attackLab._poslab.onClick,function() 
        TurnModel.WorldPos(self.report.Attacker.X, self.report.Attacker.Y)

    end)

    self:AddListener(self.defenseLab._poslab.onClick,function()
        TurnModel.WorldPos(self.report.Defender.X, self.report.Defender.Y)
    end)
end

function ItemMailWarReport:SetData(index, _info, player, showType)
    self.info = _info
    self.player = player

    self.report = JSON.decode(self.info.Report)

    if showType == MAIL_SHOWTYPE.Shere then
        self._sharebtenCtr.selectedPage = "show"
    else
        self._sharebtenCtr.selectedPage = "hide"
    end

    --屏蔽分享
    self._sharebtenCtr.selectedPage = "hide"

    self:initListView()
end

function ItemMailWarReport:InitBaseData(list, infoList)
    for k,v in pairs(infoList) do
        if list[k] then
            list[k].text = math.ceil(v)
        end
    end

    if math.ceil(infoList.Power) > 0 then
        list["Power"].text = "-"..math.ceil(infoList.Power)
    else
        list["Power"].text = 0
    end
    list.armyNumlab.text = math.ceil(infoList.Injured+infoList.Lost+infoList.Survival)
    list.DefendLost.text = math.ceil(infoList.DefendLost)
    if infoList.Beasts and #infoList.Beasts > 0 then
        local lostPower = 0
        for _,v in ipairs(infoList.Beasts)do
            lostPower = lostPower + v.LostPower
        end
        list.DefendBeastsLost.text = math.ceil(lostPower)
    else
        list.DefendBeastsLost.text = 0
    end
    local str = ""
    if infoList.Alliance ~= "" then
        str = str.."["..infoList.Alliance.."]"
    end
    str = str..infoList.Name
    list.namelab.text = str
    list._poslab.text = "("..math.ceil(infoList.X)..", "..math.ceil(infoList.Y)..")"
    list._icon:SetAvatar(infoList)
end

function ItemMailWarReport:initListView(  )
    local report = self.report
    -- self._poslab.text = string.format("交战地点：[color=#ffff99](%d,%d)[/color]",report.X, report.Y)
    local data = {
        x = math.ceil(report.X),
        y = math.ceil(report.Y)
    }
    self._poslab.text = StringUtil.GetI18n("configI18nCommons", "Ui_MTR_Place", data)
    self:AddListener(self._poslab.onClick,function() 
        TurnModel.WorldPos(data.x, data.y)
    end)
    self._timelab.text = TimeUtil:StampTimeToYMDHMS(self.info.CreatedAt)

    for k,v in pairs(self.ResLab)do
        v.labText.text = 0
        v.icon.icon = GD.ResAgent.GetIconUrl(k)
    end

    for _,v in pairs(report.ResAmounts) do
        if v.Amount then
            self.ResLab[v.Category].labText.text = math.ceil(v.Amount)
        else
            self.ResLab[v.Category].labText.text = 0
        end
    end

    self:InitBaseData(self.defenseLab, report.Defender)
    self:InitBaseData(self.attackLab, report.Attacker)
    
    if report.Defender.Buffs == JSON.null then
        report.Defender.Buffs = {}
    end
    
    if report.Attacker.Buffs == JSON.null then
        report.Attacker.Buffs = {}
    end

    if report.Members == JSON.null then
        report.Members = {}
    end

    if report.Attacker.UserId == self.player or self:IsAttack() then --我攻击别人
        if report.IsWin then --胜利
            self._textExplain.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_MTR_Briefing_AttWin")
            self._result.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Win_Report")
        else--失败
            self._textExplain.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_MTR_Briefing_AttFail")
            self._result.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Fail_Report")
        end
    else--别人攻击我
        if not report.IsWin then --胜利
            self._textExplain.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_MTR_Briefing_AttWin")
            self._result.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Win_Report")
        else--失败
            self._textExplain.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_MTR_Briefing_AttFail")
            self._result.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Fail_Report")
        end
    end

    --进攻方集结部队
    local index = 1
    for _,v in ipairs(report.Members)do
        if v.Side == 0 then -- 攻击方
            if not self.massAttackerMembers[index] then
                local temp = UIMgr:CreateObject("Mail", "itemMailWarReportTeam")
                self:AddChild(temp)
                self.massAttackerMembers[index] = temp
            end
            self.massAttackerMembers[index].x = self.massAttackX
            self.massAttackerMembers[index].y = self.massY + (self.massH)*(index-1)
            self.massAttackerMembers[index]:GetChild("textPlayerName").text = v.Name
            self.massAttackerMembers[index]:GetChild("iconHead"):SetAvatar(v)
            self.massAttackerMembers[index].visible = true

            index = index + 1
        end
    end
    self.massAttackNum = index
    for i = index, #self.massAttackerMembers do
        self.massAttackerMembers[i].visible = false
    end

    --防守方集结部队
    index = 1
    for _,v in ipairs(report.Members)do
        if v.Side == 1 then -- 防守方
            if not self.massDefenderMembers[index] then
                local temp = UIMgr:CreateObject("Mail", "itemMailWarReportTeam")
                self:AddChild(temp)
                self.massDefenderMembers[index] = temp
            end
            self.massDefenderMembers[index].x = self.massDefenseX
            self.massDefenderMembers[index].y = self.massY + (self.massH)*(index-1)
            self.massDefenderMembers[index]:GetChild("textPlayerName").text = v.Name
            self.massDefenderMembers[index]:GetChild("iconHead"):SetAvatar(v)
            self.massDefenderMembers[index].visible = true

            index = index + 1
        end
    end
    self.massDefenseNum = index
    for i = index, #self.massDefenderMembers do
        self.massDefenderMembers[i].visible = false
    end

    local _massNum = (self.massAttackNum > self.massDefenseNum and self.massAttackNum or self.massDefenseNum) - 3
    self._massLine.y = self._massLineY + _massNum * self.massH

    self._attackerBuffTextX = self:GetChild("item3").x
    self._attackerBuffTextY = self:GetChild("item3").y
    self._defenderBuffTextX = self:GetChild("item4").x
    self._defenderBuffTextY = self:GetChild("item4").y

    local buffNameConfig = ConfigMgr.GetList("configAttributenames")
    
    --初始化进攻方属性
    index = 1
    local _AttackerBuffTextH = 0
    local buffsCache = {}
    for _,v in pairs(report.Attacker.Buffs) do
        local nameKey = ""
        local flag = false
        for _,buffNameInfo in ipairs(buffNameConfig)do
            local _isbreak = false
            for _,buff in ipairs(buffNameInfo.buff_id)do
                if buff == v.ConfId then
                    if buffsCache[buffNameInfo.id] then
                        flag = true
                        break
                    end
                    _isbreak = true
                    nameKey = buffNameInfo.name
                    buffsCache[buffNameInfo.id] = true
                    break
                end
            end
            if _isbreak then
                break
            end
        end
        if flag then
            goto continue
        end
        if not self.myAttriList[index] then
            local temp = UIMgr:CreateObject("Mail", "itemMailWarReport1")
            self:AddChild(temp)
            self.myAttriList[index] = temp
        end
        -- self.myAttriList[index]:GetChild("text").text = ConfigMgr.GetI18n("configI18nCommons", "Ui_BattleReport_"..math.ceil(v.ConfId))
        
        self.myAttriList[index]:GetChild("text").text = ConfigMgr.GetI18n("configI18nCommons", nameKey)
        self.myAttriList[index].x = self._attackerBuffTextX
        self.myAttriList[index].y = self._attackerBuffTextY + _AttackerBuffTextH
        _AttackerBuffTextH = _AttackerBuffTextH + self.myAttriList[index].height
        local buffConfig = ConfigMgr.GetItem("configAttributes", math.ceil(v.ConfId))
        local value = 0
        if buffConfig.value_type == 1 then
            if buffConfig.plus_minus == 1 then
                value = "+" .. math.ceil(v.Value)
            elseif buffConfig.plus_minus == 2 then
                value = "-" .. math.ceil(v.Value)
            else
                value = math.ceil(v.Value)
            end
        else
            if buffConfig.plus_minus == 1 then
                value = "+" .. math.ceil(v.Value/100).."%"
            elseif buffConfig.plus_minus == 2 then
                value = "-" .. math.ceil(v.Value/100).."%"
            else
                value = math.ceil(v.Value/100).."%"
            end
        end
        self.myAttriList[index]:GetChild("textNumber").text = value
        self.myAttriList[index].visible = true
        index = index + 1
        ::continue::
    end
    for i = index, #self.myAttriList do
        self.myAttriList[i].visible = false
    end

    --初始化防守方属性
    index = 1
    local _DefenderBuffTextH = 0
    local buffsCache = {}
    for _,v in pairs(report.Defender.Buffs) do
        local nameKey = ""
        local flag = false
        for _,buffNameInfo in ipairs(buffNameConfig)do
            local _isbreak = false
            for _,buff in ipairs(buffNameInfo.buff_id)do
                if buff == v.ConfId then
                    if buffsCache[buffNameInfo.id] then
                        flag = true
                        break
                    end
                    _isbreak = true
                    nameKey = buffNameInfo.name
                    buffsCache[buffNameInfo.id] = true
                    break
                end
            end
            if _isbreak then
                break
            end
        end
        if flag then
            goto continue
        end
        if not self.enemyAttriList[index] then
            local temp = UIMgr:CreateObject("Mail", "itemMailWarReport1")
            self:AddChild(temp)
            self.enemyAttriList[index] = temp
        end
        -- self.enemyAttriList[index]:GetChild("text").text = ConfigMgr.GetI18n("configI18nCommons", "Ui_BattleReport_"..math.ceil(v.ConfId))
        self.enemyAttriList[index]:GetChild("text").text = ConfigMgr.GetI18n("configI18nCommons", nameKey)
        self.enemyAttriList[index].x = self._defenderBuffTextX
        self.enemyAttriList[index].y = self._defenderBuffTextY + _DefenderBuffTextH
        _DefenderBuffTextH = _DefenderBuffTextH + self.enemyAttriList[index].height
        local buffConfig = ConfigMgr.GetItem("configAttributes", math.ceil(v.ConfId))
        local value = 0
        if buffConfig.value_type == 1 then
            if buffConfig.plus_minus == 1 then
                value = "+" .. math.ceil(v.Value)
            elseif buffConfig.plus_minus == 2 then
                value = "-" .. math.ceil(v.Value)
            else
                value = math.ceil(v.Value)
            end
        else
            if buffConfig.plus_minus == 1 then
                value = "+" .. math.ceil(v.Value/100).."%"
            elseif buffConfig.plus_minus == 2 then
                value = "-" .. math.ceil(v.Value/100).."%"
            else
                value = math.ceil(v.Value/100).."%"
            end
        end
        self.enemyAttriList[index]:GetChild("textNumber").text = value
        self.enemyAttriList[index].visible = true
        index = index + 1
        ::continue::
    end
    for i = index, #self.enemyAttriList do
        self.enemyAttriList[i].visible = false
    end

    -- --初始化进攻部队
    -- index = 1
    -- for _,v in pairs(report.Detail.AttackerArmies) do
    --     if not self.defenseArmyList[index] then
    --         local temp = UIMgr:CreateObject("Mail", "itemMailWarReport2")
    --         self:AddChild(temp)
    --         self.defenseArmyList[index] = temp
    --     end
    --     self.defenseArmyList[index].x = self:GetChild("item1").x
    --     self.defenseArmyList[index].y = self:GetChild("item1").y + self._itemH*(index-1)
    --     self.defenseArmyList[index]:GetChild("textTypeArmsName").text = ConfigMgr.GetI18n('configI18nArmys', math.ceil(v.ConfId)..'_NAME')
    --     self.defenseArmyList[index]:GetChild("textTotalForceNumber").text = math.ceil(v.Total)
    --     self.defenseArmyList[index]:GetChild("textEliminateNumber").text = math.ceil(v.Killed)
    --     self.defenseArmyList[index]:GetChild("textInjuredNumber").text = math.ceil(v.Injured)
    --     self.defenseArmyList[index]:GetChild("textLossNumber").text = math.ceil(v.Lost)
    --     self.defenseArmyList[index]:GetChild("textPlayGameName").text = report.Attacker.Name
    --     self.defenseArmyList[index].visible = true
    --     index = index + 1
    -- end
    -- for i = index, #self.defenseArmyList do
    --     self.defenseArmyList[i].visible = false
    -- end

    -- --初始化防守部队
    -- index = 1
    -- for _,v in pairs(report.Detail.DefenderArmies) do
    --     if not self.attackArmyList[index] then
    --         local temp = UIMgr:CreateObject("Mail", "itemMailWarReport2")
    --         self:AddChild(temp)
    --         self.attackArmyList[index] = temp
    --     end
    --     self.attackArmyList[index].x = self:GetChild("item2").x
    --     self.attackArmyList[index].y = self:GetChild("item2").y + self._itemH*(index-1)
    --     self.attackArmyList[index]:GetChild("textTypeArmsName").text = ConfigMgr.GetI18n('configI18nArmys', math.ceil(v.ConfId)..'_NAME')
    --     self.attackArmyList[index]:GetChild("textTotalForceNumber").text = math.ceil(v.Total)
    --     self.attackArmyList[index]:GetChild("textEliminateNumber").text = math.ceil(v.Killed)
    --     self.attackArmyList[index]:GetChild("textInjuredNumber").text = math.ceil(v.Injured)
    --     self.attackArmyList[index]:GetChild("textLossNumber").text = math.ceil(v.Lost)
    --     self.attackArmyList[index]:GetChild("textPlayGameName").text = report.Defender.Name
    --     self.attackArmyList[index].visible = true
    --     index = index + 1
    -- end
    -- for i = index, #self.attackArmyList do
    --     self.attackArmyList[i].visible = false
    -- end

    local _maxBuffTextH = _DefenderBuffTextH > _AttackerBuffTextH and _DefenderBuffTextH or _AttackerBuffTextH
    local _H = self._height + 
                _massNum*self.massH + 
                _maxBuffTextH
                -- (#report.Detail.DefenderArmies-1)*self._itemH + 
                -- (#report.Detail.AttackerArmies-1)*self._itemH
    self:SetSize(self.width, _H)
    self.bgBox:SetSize(self.bgBox.width, self.bgBoxH+_massNum * self.massH + _maxBuffTextH)
    -- self._myAttri:SetSize(self._myAttri.width, self._myAttriH + (_maxNum - 1)*self._itemH)
    -- self._enemyAttri:SetSize(self._enemyAttri.width, self._enemyAttriH + (_maxNum - 1)*self._itemH)
    -- self._defenseArmy:SetSize(self._defenseArmy.width, self._defenseArmyH + (#report.Detail.DefenderArmies - 1)*self._itemH)
    -- self._attackArmy:SetSize(self._attackArmy.width, self._attackArmyH + (#report.Detail.AttackerArmies - 1)*self._itemH)

    -- self.box.y = self.boxY + (_maxNum - 1)*self._itemH
    self._btnBoxLine.y = self._btnBoxLineY + _massNum*self.massH + _maxBuffTextH

    -- self.bgBattle.y = self.bgBattleY + (_massNum - 2)*self.massH
    -- self.defenseBox.y = self.defenseBoxY + (_massNum - 2)*self.massH + (_maxNum - 1)*self._itemH
    -- self.attackBox.y = self.attackBoxY + (_massNum - 2)*self.massH + (_maxNum - 1)*self._itemH + (#report.Detail.AttackerArmies-1)*self._itemH

end

function ItemMailWarReport:IsAttack()
    for _,v in ipairs(self.report.Members)do
        if v.Side == 0 then -- 攻击方
            if v.UserId == self.player then
                return true
            end
        elseif v.Side == 1 then -- 防守方
            if v.UserId == self.player then
                return false
            end
        end
    end
    return false
end

return ItemMailWarReport