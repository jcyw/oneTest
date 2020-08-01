--[[
    author:{zhanzhang}
    time:2019-06-28 20:20:29
    function:{联盟集结功能}
]]
local UnionAggregation = UIMgr:NewUI("UnionAggregation")
local ItemUnionAggregation = import("UI/Union/ItemUnionAggregation")
local UnionWarfareModel = import("Model/Union/UnionWarfareModel")

function UnionAggregation:OnInit()
    -- body
    self:OnRegister()
end

function UnionAggregation:OnRegister()
    self.calTimeFunc = function()
        self:RefreshAttackCountDown()
    end
    self.closeFunc = function(uuid)
        if self.battleInfo.Uuid == uuid then
            self:Close()
        end
    end

    self:AddListener(self.Controller.contentPane.onRemovedFromStage,
        function()
            self:UnSchedule(self.calTimeFunc)
        end
    )

    self:AddListener(self._btnReturn.onClick,
        function()
            self:Close()
        end
    )

    --跳转到对应建筑
    self:AddListener(self._textCoordinate.onClick,
        function()
            TurnModel.WorldPos(self.battleInfo.TargetX, self.battleInfo.TargetY)
        end
    )

    --解散集结
    self:AddListener(self._btnDissolution.onClick,
        function()
            Net.AllianceBattle.Disband(
                self.battleInfo.Uuid,
                function(rsp)
                    if rsp.Fail then
                        return
                    end
                end
            )
        end
    )
    
    self._contentList.itemRenderer = function(index, item)
        if index < #self.missionData then
            -- 集结部队
            local mission = self.missionData[index + 1]
            local itemClickFunc = function()
                if item:GetSelected() then
                    for k,v in pairs(self.curSelectedList) do
                        if v == mission.Uuid then
                            table.remove(self.curSelectedList, k)
                            break
                        end
                    end

                    self._contentList.numItems = self:GetListNum()
                else
                    table.insert(self.curSelectedList, mission.Uuid)
                    self._contentList.numItems = self:GetListNum()
                    self._contentList:ScrollToView(index)
                end
            end

            if mission.Status == Global.ABMStatusArrived then
                item:Init(ItemUnionAggregation.TypeEnum.Arrived, itemClickFunc)
            else
                item:Init(ItemUnionAggregation.TypeEnum.Coming, itemClickFunc, function()
                    mission.marchType = MarchType.Union
                    UIMgr:Open("MarchAcceleration", mission)
                end)
                item:StartTimer(mission.FinishAt, mission.Duration)
            end

            --选中项展开士兵列表
            for _,v in pairs(self.curSelectedList) do
                if v == mission.Uuid then
                    if UnionWarfareModel.CheckWarIsMy(mission.AllianceBattleId) and mission.UserId ~= Model.Account.accountId then
                        item:OpenList(mission.Armies, mission.Beasts, function()
                            Net.AllianceBattle.Removal(mission.AllianceBattleId, mission.Uuid, function(rsp)
                                local id = mission.Uuid
                                for k,v in pairs(self.missionData) do
                                    if v.Uuid == id then
                                        table.remove(self.missionData, k)
                                        break
                                    end
                                end
                                table.remove(self.curSelectedList, index + 1)
                                self._contentList.numItems = self:GetListNum()
                                Event.Broadcast(EventDefines.UIAllianceBattleRemoval, id)
                            end)
                        end)
                    else
                        item:OpenList(mission.Armies, mission.Beasts)
                    end
                    break
                end
            end

            local total = 0
            for _,v in pairs(mission.Armies) do
                total = total + v.Amount
            end
            item:SetContent(StringUtil.GetI18n(I18nType.Commmon, "Ui_Aggregated"), total)

            item:SetPlayerInfo(mission, mission.Name, mission.UserId)
        else
            local func = function()
                local data = {
                    openType = ExpeditionType.JoinUnionAttack,
                    posNum = self.battleInfo.X * 10000 + self.battleInfo.Y,
                    battleId = self.battleInfo.Uuid,
                    monsterId = (self.battleInfo.DesCategory == Global.MapTypeMonster) and self.battleInfo.TargetId or nil
                }
                UIMgr:Open("Expedition", data)
            end

            if self.battleInfo.MemberLimit < Global.RallyMemberAmountMax and index == self.battleInfo.MemberLimit then
                --锁    
                item:Init(ItemUnionAggregation.TypeEnum.Lock)
                item:SetAddBtnContent(StringUtil.GetI18n(I18nType.Commmon, "Ui_Assemble_Unlock"))
            else
                --加入集结按钮
                item:Init(ItemUnionAggregation.TypeEnum.Add, function()
                    --加入集结
                    local build = BuildModel.FindByConfId(Global.BuildingJointCommand)
                    if UnionWarfareModel.CheckInWar(self.battleInfo.Uuid) then
                        --不能重复加入同一集结
                        TipUtil.TipById(50141)
                    -- elseif not build or build.Level <= 0 then
                    --     --需要作战指挥部
                    --     TipUtil.TipById(50291)
                    elseif self.battleInfo.DesCategory ~= Global.MapTypeMonster and BuffModel.CheckIsProtect() and self.battleInfo.BreakProtection then
                        local data = {
                            content = StringUtil.GetI18n(I18nType.Commmon, "TIPS_BROKEN_PROTECTION"),
                            sureCallback = function()
                                func()
                            end
                        }
                        UIMgr:Open("ConfirmPopupText", data)
                    else
                        func()
                    end
                end)
                item:SetAddBtnContent(StringUtil.GetI18n(I18nType.Commmon, "Ui_Assemble_Tips"))
            end
        end
    end

end

function UnionAggregation:Close()
    UIMgr:Close("UnionAggregation")
end

function UnionAggregation:OnOpen(battleInfo)
    --是否是进攻方
    self.isAttack = Model.Player.AllianceId == battleInfo.AttackAllianceId

    self.curSelectedList = {}
    self.battleInfo = battleInfo
    self.isMyBattle = self:CheckIsMyBattle()
    self._textBuildName.text = battleInfo.TargetName
    self._textPlayerName.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_Assemble_Captain").." "..battleInfo.UserName
    self._textArmy.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_Assemble_Army").." "..battleInfo.Member.."/"..battleInfo.MemberLimit
    self._textForce.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TOTAL_FORCE_TEXT").." "..battleInfo.Power
    self.missionData = UnionWarfareModel.GetMissionListByBattleId(battleInfo.Uuid)
    table.sort(self.missionData, function(a, b)
        if a.Uuid == self.battleInfo.OwnerMissionId then
            return true
        else
            return false
        end
    end)
    self._textSoldiersNum.text = self:GetAmountArmies().."/"..battleInfo.MaxRally
    self._contentList.numItems = self:GetListNum()--#self.missionData
    self._textCoordinate.text = StringUtil.GetCoordinataStr(battleInfo.TargetX, battleInfo.TargetY)
    -- CommonModel.SetUserAvatar(self._iconHead, self.battleInfo.Avatar, self.battleInfo.UserId)
    -- self._iconHead:SetAvatar(self.battleInfo, nil, self.battleInfo.UserId)
    self._iconHead:SetAvatar({Avatar = self.battleInfo.Avatar, DressUpUsing = self.battleInfo.AttackerDressUpUsing}, nil, self.battleInfo.UserId)
    self._progressBar.max = self.battleInfo.FinishAt - self.battleInfo.CreatedAt
    self:Schedule(self.calTimeFunc, 1, true)
    if self.battleInfo.DesCategory == Global.MapTypeMonster then
        local monster = ConfigMgr.GetItem("configMonsters", self.battleInfo.TargetId)
        self._textBuildName.text = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_"..self.battleInfo.TargetId)
        self._iconBuild.icon = UITool.GetIcon(monster.monster_avatar)
        -- self._iconHead.icon = UITool.GetIcon(monster.monster_avatar)
    elseif self.battleInfo.DesCategory == Global.MapTypeAllianceDomain then
        local config = ConfigMgr.GetItem("configAllianceFortresss", tonumber(self.battleInfo.DefendUserId))
        self._textBuildName.text = StringUtil.GetI18n(I18nType.Commmon, config.building_name)
        self._iconBuild.icon = UITool.GetIcon(Global.AllianceBase)
    elseif self.battleInfo.DesCategory == Global.MapTypeThrone or self.battleInfo.DesCategory == Global.MapTypeFort then
        -- 进攻王城/炮台
        local config = ConfigMgr.GetItem("configWarZoneBuildings", self.battleInfo.TargetX*10000+self.battleInfo.TargetY)
        self._textBuildName.text = StringUtil.GetI18n(I18nType.Commmon, config.name)
        self._iconBuild.icon = UITool.GetIcon(config.image)
    else
        self._iconBuild.icon = UITool.GetIcon(Global.PlayCity)
    end

    self.refreshFunc = function()
        self.missionData = UnionWarfareModel.GetMissionListByBattleId(self.battleInfo.Uuid)
        self._contentList.numItems = self:GetListNum()
    end
    self:AddEvent(EventDefines.UIOnRefreshAggregation, self.refreshFunc)
    self:AddEvent(EventDefines.UIAllianceBattleChange, self.refreshFunc)
    self:AddEvent(EventDefines.UIAllianceBattleCancel, self.closeFunc)
end

--检测是否本人发起战斗
function UnionAggregation:CheckIsMyBattle()
    local isMyBattle = self.battleInfo.UserId == Model.Account.accountId
    -- self._btnAggregation.visible = not isMyBattle
    self._btnDissolution.visible = isMyBattle
    -- self._btnInvitation.visible = isMyBattle

    return isMyBattle
end

function UnionAggregation:RefreshAttackCountDown()
    local delayTime = self.battleInfo.FinishAt - Tool.Time()
    if (delayTime < 0) then
        self:UnSchedule(self.calTimeFunc)
        return
    end
    local total = self.battleInfo.FinishAt - self.battleInfo.CreatedAt
    local title = "Ui_Alliance_Assmble"
    if self.battleInfo.Status == Global.ABStatusMarch then
        title = "Ui_Alliance_March"
    end
    self._textTimeNum.text = StringUtil.GetI18n(I18nType.Commmon, title, {time = TimeUtil.SecondToHMS(delayTime)})
    self._progressBar.value = (total - delayTime)
end

function UnionAggregation:OnClose()
    self:UnSchedule(self.calTimeFunc)
    Event.RemoveListener(EventDefines.UIOnRefreshAggregation, self.refreshFunc)
    Event.RemoveListener(EventDefines.UIAllianceBattleChange, self.refreshFunc)
    Event.RemoveListener(EventDefines.UIAllianceBattleCancel, self.closeFunc)
end

function  UnionAggregation:GetListNum()
    return (self.battleInfo.MemberLimit < Global.RallyMemberAmountMax) and (self.battleInfo.MemberLimit + 1) or self.battleInfo.MemberLimit
end

function UnionAggregation:GetAmountArmies()
    local amount = 0
    for _,v in pairs(self.missionData) do
        for _,v1 in pairs(v.Armies) do
            amount = amount + v1.Amount
        end
    end

    return amount
end

return UnionAggregation
