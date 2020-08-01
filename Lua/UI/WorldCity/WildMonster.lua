local GD = _G.GD
local WildMonster = UIMgr:NewUI("WildMonster")
local MapModel = import("Model/MapModel")
local GuidePanelModel = import("Model/GuideControllerModel")
local UIType = _G.GD.GameEnum.UIType
local MissionEventModel = import("Model/MissionEventModel")
local view = nil

local Global = import("gen/excels/Global")
local MarchAnimModel = import("Model/MarchAnimModel")
local isClicking = false

function WildMonster:OnInit()
    view = self.Controller.contentPane
    self:OnRegister()
    GuidePanelModel:SetParentUI(self, UIType.WildMonsterUI)
end

function WildMonster:OnRegister()
    self:AddListener(
        self._bgMask.onClick,
        function()
            UIMgr:Close("WildMonster")
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(
        self._btnAttack.onClick,
        function()
            self:OnClick(self.isGuide)
        end
    )
    self:AddListener(
        self._btnShare.onClick,
        function()
            --目前策划只要求对联盟频道分享
            local posX, posY = MathUtil.GetCoordinate(self.posNum)
            GameShareModel.ShareCoordinateToUnion(Global.CoordinateShareAlliance, Global.CoordinateShareMonster, self.monster.id, posX, posY)
        end
    )
    self:AddListener(
        self._numberCoordinate.onClick,
        function()
            WorldMap.Instance():GotoPoint(MathUtil.GetCoordinate(self.posNum))
            UIMgr:Close("WildMonster")
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddEvent(
        EventDefines.UICloseMapDetail,
        function()
            UIMgr:Close("WildMonster")
        end
    )
    self._controller = view:GetController("c1")
end
--type 1--普通野怪
--type 2--集结野怪
--type 3--活动野怪
function WildMonster:OnOpen(posNum, isGuide)
    self.info = MapModel.GetArea(posNum)
    if self.info.Category ~= Global.MapTypeMonster then
        UIMgr:Close("WildMonster")
        TipUtil.TipByContent(nil, StringUtil.GetI18n(I18nType.Commmon, "Ui_Target_Lost"))
        Log.Warning("野怪信息未找到")
        return
    end

    self.posNum = self.info.Occupied == 0 and posNum or self.info.Occupied
    self:OnRefreshInfo(self.info.ConfId)
    self.isGuide = isGuide
    if isGuide then
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.WildMonsterUI)
    end
end
--进攻野怪
function WildMonster:OnClick(isGuide)
    if isClicking then
        return
    end
    if self.monster.type ~= Global.MonsterTypeHunt and ArmiesModel.CheckMissionLimit() then
        UIMgr:Close("WildMonster")
        return
    end

    UIMgr:Close("WildMonster")
    Event.Broadcast(EventDefines.CloseGuide)
    --此处为集结野怪，没有联盟是直接跳转到联盟界面
    local data
    if self.monster.type == 2 then
        local build = BuildModel.FindByConfId(Global.BuildingJointCommand)
        if not build or build.Level <= 0 then
            TipUtil.TipById(50291)
            return
        end
        if Model.Player.AllianceId == "" then
            UIMgr:Close("WildMonster")
            Event.Broadcast(EventDefines.CloseGuide)
            TurnModel.UnionView()
            return
        end
        UIMgr:Open("Aggregation", self.posNum, self.monster.id)
    elseif self.monster.type == Global.MonsterTypeVisit then
        if GD.ResAgent.GetEnergy() < self.monster.usePower then
            -- UIMgr:Open("MarchAP")
            _G.UIMgr:Open("PlayerItem/PlayerItem", "Hp")
        else
            local posX, posY = MathUtil.GetCoordinate(self.posNum)
            Net.Missions.March(
                posX,
                posY,
                Global.MissionVisit,
                nil,
                {},
                nil,
                0,
                function(val)
                    -- MarchAnimModel.SetLookAt(val.Event.Uuid)
                    Event.Broadcast(EventDefines.UIOnMissionInfo, val.Event)
                end
            )
        end
    elseif self.monster.type == Global.MonsterTypeHunt then
        if GD.ResAgent.GetEnergy() < self.monster.usePower then
            -- UIMgr:Open("MarchAP")
            _G.UIMgr:Open("PlayerItem/PlayerItem", "Hp")
            return
        end
        local posX, posY = MathUtil.GetCoordinate(self.posNum)
        Net.EagleHunt.Hunt(
            posX,
            posY,
            function(rsp)
                -- MarchAnimModel.SetLookAt(rsp.Event.Uuid)
                Event.Broadcast(EventDefines.UIOnMissionInfo, rsp.Event)
            end
        )
    else
        if not self.isUnlock then
            isClicking = true
            Net.MapInfos.SearchMonster(
                true,
                Model.Player.MaxMonsterLevel + 1,
                function(val)
                    isClicking = false
                    UIMgr:Close("WildMonster")
                    Event.Broadcast(EventDefines.CloseGuide)
                    WorldMap.Instance():MoveToPoint(val.X, val.Y, false, true)
                end
            )
            return
        end

        if GD.ResAgent.GetEnergy() < self.monster.usePower then
            -- UIMgr:Open("MarchAP")
            _G.UIMgr:Open("PlayerItem/PlayerItem", "Hp")
        else
            data = {
                openType = ExpeditionType.Pve,
                posNum = self.posNum,
                monsterId = self.monster.id
            }
            UIMgr:Open("Expedition", data, isGuide)
        end
    end
end

function WildMonster:OnRefreshInfo(ConfId)
    self._itemGlist:RemoveChildrenToPool()
    self.monster = ConfigMgr.GetItem("configMonsters", ConfId)
    self._iconMonster.icon = UITool.GetIcon(self.monster.monster_avatar)
    self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_" .. self.monster.id) .. "Lv." .. self.monster.level
    self._numberCoordinate.text = StringUtil.GetCoordinataWithLetter(MathUtil.GetCoordinate(self.posNum))
    self._textMonster.text = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_SLOGAN_" .. self.monster.id)
    local posX, posY = MathUtil.GetCoordinate(self.posNum)

    for i = 1, #self.monster.reward_show do
        local item = self._itemGlist:AddItemFromPool()
        local propInfo = ConfigMgr.GetItem("configItems", self.monster.reward_show[i])
        item:SetAmount(propInfo.icon, propInfo.color, false, GD.ItemAgent.GetItemNameByConfId(propInfo.id))
    end
    if self.monster.type ~= Global.MonsterTypeVisit then
        self._btnAttack.enabled = true
        self._btnAttack.grayed = false
    end
    self._btnShare.visible = true
    self:OnCheckIsUnlock()
    self._controller.selectedIndex = 0

    self._progressNum.text = ""
    self._textTime.text = ""

    if self.monster.type == Global.MonsterTypeRally then
        -- elseif self.monster.type == Global.MonsterTypeActivity then
        --     print("asd")
        --集结野怪
        --是否显示血量
        self._progressBar.visible = self.monster.blood_show
        self._progressBar.max = self.monster.blood
        self._progressBar.value = self.info.Value
        self._textDesc.text = ""
    elseif self.monster.type == Global.MonsterTypeVisit then
        -- elseif
        --活动侦查野怪
        self._controller.selectedIndex = 1

        local posX, posY = MathUtil.GetCoordinate(self.posNum)
        if ConfId == 9900001 then
            self._textDesc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_INVERSTIGATION2_EXPLAIN")
        end
        Net.Activity.GetActivitiyBuildingInfo(
            posX,
            posY,
            function(info)
                local config = ConfigMgr.GetItem("configScouts", info.ConfId)
                local canScoutTime = math.max(config.limit_reward - info.PlayerRewardTimes, 0)
                local canAwardTime = math.max(config.limit_building - info.TotalVisitTimes, 0)
                self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TITTLE_INVESTIGATION_NUM_DAY", {num = canScoutTime})
                self._textAwardNum.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TITTLE_INVESTIGATION_NUM_REWARD", {num = canAwardTime})

                if MapModel.IsCanScoutMonster(self.posNum, self.monster.activity_id) then
                    self._btnAttack.enabled = true
                    self._btnAttack.grayed = false
                else
                    self._btnAttack.enabled = false
                    self._btnAttack.grayed = true
                end
            end
        )
    else
        -- self._textAttackNum.visible = false
        self._progressBar.visible = false
    end

    if self.monster.blood_show then
        self._progressBar.visible = true
        self._progressBar.max = self.monster.blood
        self._progressBar.value = self.info.Value
        self._progressNum.text = math.ceil(100 * self.info.Value / self.monster.blood) .. "%"
    else
        self._progressBar.visible = false
    end

    if self.monster.time_show then
    else
        -- self._textTime.text =StringUtil.GetI18n(I18nType.Commmon,"")
    end

    if self.monster.leftnum_show then
    else
    end
end

function WildMonster:OnCheckIsUnlock()
    self.isUnlock = self.monster.level <= Model.Player.MaxMonsterLevel + 1
    --2为集结野怪，3为普通野怪
    self._btnAttack:GetController("EnergyControl").selectedIndex = 0
    if self.isUnlock then
        self._textDesc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_PVE_MOVESPEED_TIPS")
        self._btnAttack.title = StringUtil.GetI18n(I18nType.Commmon, "MAP_ATTACK_BUTTON")
        self._btnAttack:GetChild('Energetitle').text = StringUtil.GetI18n(I18nType.Commmon, "MAP_ATTACK_BUTTON")
    else
        self._textDesc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ATTACK_MONSTER_TIPS", {level = Model.Player.MaxMonsterLevel + 1})
        self._btnAttack.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
        self._btnAttack:GetChild('Energetitle').text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
    end

    if self.monster.type == Global.MonsterTypeRally then
        if Model.Player.AllianceId == "" then
            self._btnAttack.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_JOINUNION")
            self._btnAttack:GetChild('Energetitle').text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_JOINUNION")
        else
            self._btnAttack.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_Assemble")
            self._btnAttack:GetChild('Energetitle').text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_Assemble")
        end
    elseif self.monster.type == Global.MonsterTypeVisit then
        self._btnAttack.title = StringUtil.GetI18n(I18nType.Commmon, "MAP_DETECT_BUTTON")
        self._btnAttack:GetChild('Energetitle').text = StringUtil.GetI18n(I18nType.Commmon, "MAP_DETECT_BUTTON")
        self._textDesc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_INVERSTIGATION_EXPLAIN")
    elseif self.monster.type == Global.MonsterTypeHunt then
        self._btnAttack:GetController("EnergyControl").selectedIndex = 1
        self._btnAttack:GetChild('EnergeNum').text = self.monster.usePower
        self._textDesc.text = ""
        self._btnAttack.title = StringUtil.GetI18n(I18nType.Commmon, "UI_GUIDE_BUTTON_RESCUE")
        self._btnAttack:GetChild('Energetitle').text = StringUtil.GetI18n(I18nType.Commmon, "UI_GUIDE_BUTTON_RESCUE")
        self._btnShare.visible = false
        if MissionEventModel.IsMarchToPoint(self.posNum) then
            self._btnAttack.enabled = false
            self._btnAttack.grayed = true
        end
    end
end

--手指引导
function WildMonster:GuildShow()
    return self._btnAttack
end

return WildMonster
