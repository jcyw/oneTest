--[[
    author:{zhanzhang}
    time:2019-07-02 15:53:22
    function:{联盟进攻Item}
]]
local ItemUnionWarfareAttack = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionWarfare", ItemUnionWarfareAttack)

local UnionWarfareModel = import("Model/Union/UnionWarfareModel")

function ItemUnionWarfareAttack:ctor()
    self.unionHeight = 484
    self.singleHeight = 268

    self._statusControl = self:GetController("statusControl")
    self._typeControl = self:GetController("typeController")
    
    self:OnRegister()
end

function ItemUnionWarfareAttack:OnRegister()
    self._contentAttackMember.itemRenderer = function(index, item)
        -- item:Init(index, self.missionData[index + 1], function()
        --     -- local data = {
        --     --     openType = ExpeditionType.JoinUnionAttack,
        --     --     posNum = self.battleInfo.TargetX * 10000 + self.battleInfo.TargetY,
        --     --     battleId = self.battleInfo.Uuid,
        --     --     monsterId = (self.battleInfo.DesCategory == Global.MapTypeMonster) and self.battleInfo.TargetId or nil
        --     -- }
        --     -- UIMgr:Open("Expedition", data)
        -- end)
        local info = self.missionData[index + 1]
        if info then
            item:GetChild("n12"):SetAvatar(info, nil, info.UserId)
        else
            item:Init(index, info, function()
                
            end)
        end
    end

    self._contentAttackMember.itemProvider = function(index)
        if not index then 
            return
        end

        if self.missionData[index + 1] then
            return "ui://Common/itemHeadPhotoList"
        else
            return "ui://Union/itemUnionWarfareAttackHead"
        end
    end

    self._contentAttackMember:SetVirtual()
    
    --点击坐标跳转
    self:AddListener(self._CoordinateBtn.onClick,
        function()
            TurnModel.WorldPos(self.targetX, self.targetY)
        end
    )

    self:AddListener(self._textCoordinateL.onClick,
        function()
            TurnModel.WorldPos(self.battleInfo.X, self.battleInfo.Y)
        end
    )

    self:AddListener(self._textCoordinateR.onClick,
        function()
            TurnModel.WorldPos(self.battleInfo.TargetX, self.battleInfo.TargetY)
        end
    )

    self:AddListener(self._btnBg.onClick,
        function()
            UIMgr:Open("UnionAggregation", self.battleInfo, self.armyInfo)
        end
    )

    self.calTimeFunc = function()
        self:RefreshCountDowm()
    end
    
    --移除状态
    self:AddListener(self.onRemovedFromStage,
        function()
            self:UnSchedule(self.calTimeFunc)
        end
    )

    self:AddEvent(
        EventDefines.UIAllianceBattleChange,
        function(val)
            if val.Uuid == self.battleInfo.Uuid and val.Status == Global.ABStatusMarch then
                self.textTime = "Ui_Alliance_March"
                self.FinishAt = val.FinishAt
                self:UnSchedule(self.calTimeFunc)
                self:Schedule(self.calTimeFunc, 1, true)
            end
        end
    )

    self:AddEvent(
        EventDefines.UIAllianceBattleRemoval,
        function(missionId)
            for k,v in pairs(self.missionData) do
                if v.Uuid == missionId then
                    table.remove(self.missionData, k)
                    break
                end
            end
            self._contentAttackMember.numItems = self.canJoin and (#self.missionData + 1) or #self.missionData
        end
    )
end

function ItemUnionWarfareAttack:Init(battleInfo)
    self.battleInfo = battleInfo
    self.missionData = UnionWarfareModel.GetMissionListByBattleId(self.battleInfo.Uuid)
    if self.battleInfo.Category == Global.ABCategorySingle then
        self:InitSingleAttack()
    else
        self:InitUnionAttack()
    end
end

function ItemUnionWarfareAttack:InitSingleAttack()
    self._typeControl.selectedPage = "single"
    self.height = self.singleHeight
    self._textTitleName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Attack")
    self.textTime = "Ui_Alliance_March"
    self._textCoordinateR.text = StringUtil.GetCoordinataStr(self.battleInfo.TargetX, self.battleInfo.TargetY)

    if self.battleInfo.DesCategory == Global.MapTypeAllianceDomain then
        local name = ConfigMgr.GetItem("configAllianceFortresss", tonumber(self.battleInfo.DefendUserId)).building_name
        self._textNameR.text = StringUtil.StringShortly(StringUtil.GetI18n(I18nType.Commmon, name),10)
        self._iconHeadR.icon = UITool.GetIcon(Global.AllianceBase)
    elseif self.battleInfo.DesCategory == Global.MapTypeThrone or self.battleInfo.DesCategory == Global.MapTypeFort then
        -- 进攻王城/炮台
        local config = ConfigMgr.GetItem("configWarZoneBuildings", self.battleInfo.TargetX*10000+self.battleInfo.TargetY)
        self._textNameR.text = StringUtil.GetI18n(I18nType.Commmon, config.name)
        self._iconHeadR.icon = UITool.GetIcon(config.image)
    else
        self._textNameR.text = StringUtil.StringShortly(self.battleInfo.TargetName,10)
        CommonModel.SetUserAvatar(self._iconHeadR, self.battleInfo.TargetAvatar, self.battleInfo.DefendUserId)
    end

    if #self.missionData > 0 then
        local mission = self.missionData[1]
        self._textNameL.text = StringUtil.StringShortly(mission.Name,10)
        self._textCoordinateL.text = StringUtil.GetCoordinataStr(self.battleInfo.X, self.battleInfo.Y)
        CommonModel.SetUserAvatar(self._iconHeadL, self.battleInfo.Avatar, self.battleInfo.UserId)
    end

    self._JoinedTip.visible = false
    self.FinishAt = self.battleInfo.FinishAt
    self:UnSchedule(self.calTimeFunc)
    self:Schedule(self.calTimeFunc, 1, true)
end

function ItemUnionWarfareAttack:InitUnionAttack()
    self._typeControl.selectedPage = "union"
    self.height = self.unionHeight
    self._textTitleName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Assemble")
    self._textWeName.text = self.battleInfo.UserName
    self._textEnemyName.text = self.battleInfo.TargetName
    self._textBattleNum.text = Tool.FormatNumberThousands(self.battleInfo.Power)
    self.targetX = self.battleInfo.TargetX
    self.targetY = self.battleInfo.TargetY
    self._textName.text = self.battleInfo.TargetName
    self._textCoordinate.text = StringUtil.GetCoordinataStr(self.targetX, self.targetY)
    self._textMemberNum.text = #self.missionData.."/"..self.battleInfo.MemberLimit
    self.FinishAt = self.battleInfo.FinishAt

    if self.battleInfo.DesCategory == Global.MapTypeMonster then
        -- 进攻野怪
        local monster = ConfigMgr.GetItem("configMonsters", self.battleInfo.TargetId)
        self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_"..self.battleInfo.TargetId)
        self._textEnemyName.text = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_"..self.battleInfo.TargetId)
        self._iconBuild.icon = UITool.GetIcon(monster.monster_avatar)
        -- self._iconHead.icon = UITool.GetIcon(monster.monster_avatar)
        self._iconHead:SetAvatar(monster.monster_avatar, "custom")
    elseif self.battleInfo.DesCategory == Global.MapTypeAllianceDomain then
        -- 进攻联盟堡垒
        local config = ConfigMgr.GetItem("configAllianceFortresss", tonumber(self.battleInfo.DefendUserId))
        self._textName.text = StringUtil.GetI18n(I18nType.Commmon, config.building_name)
        self._textEnemyName.text = StringUtil.GetI18n(I18nType.Commmon, config.building_name)
        self._iconBuild.icon = UITool.GetIcon(Global.AllianceBase)
        -- self._iconHead.icon = UITool.GetIcon(Global.AllianceBase)
        self._iconHead:SetAvatar(Global.AllianceBase, "custom")
    elseif self.battleInfo.DesCategory == Global.MapTypeThrone or self.battleInfo.DesCategory == Global.MapTypeFort then
        -- 进攻王城/炮台
        local config = ConfigMgr.GetItem("configWarZoneBuildings", self.battleInfo.TargetX*10000+self.battleInfo.TargetY)
        self._textName.text = StringUtil.GetI18n(I18nType.Commmon, config.name)
        self._textEnemyName.text = StringUtil.GetI18n(I18nType.Commmon, config.name)
        self._iconBuild.icon = UITool.GetIcon(config.image)
        -- self._iconHead.icon = UITool.GetIcon(config.image)
        self._iconHead:SetAvatar(config.image, "custom")
        --CommonModel.SetUserAvatar(self._iconHead, self.battleInfo.TargetAvatar, self.battleInfo.DefendUserId)
    else
        -- 进攻玩家
        self._iconBuild.icon = UITool.GetIcon(Global.PlayCity)
        -- CommonModel.SetUserAvatar(self._iconHead, self.battleInfo.TargetAvatar, self.battleInfo.DefendUserId)
        self._iconHead:SetAvatar({Avatar = self.battleInfo.TargetAvatar, DressUpUsing = self.battleInfo.TargetDressUpUsing}, nil, self.battleInfo.DefendUserId)
    end
    
    if self.battleInfo.Status == Global.ABStatusMarch then
        self.textTime = "Ui_Alliance_March"
        self._statusControl.selectedPage = "over"
    else
        self.textTime = "Ui_Alliance_Assmble"
        self._statusControl.selectedPage = "waiting"
    end
    
    self:UnSchedule(self.calTimeFunc)
    self:Schedule(self.calTimeFunc, 1, true)

    self.canJoin = false
    if Model.Account.accountId ~= self.battleInfo.UserId and #self.missionData < self.battleInfo.MemberLimit and self.battleInfo.Status == Global.ABStatusPrepare then
        self.canJoin = true
        self._JoinedTip.visible = false
        for _,v in pairs(self.missionData) do
            if v.UserId ==  Model.Account.accountId then
                self.canJoin = false
                self._JoinedTip.visible = true
                break
            end
        end
    end
    self._contentAttackMember.numItems = self.canJoin and (#self.missionData + 1) or #self.missionData
end

--跳转前往坐标点
function ItemUnionWarfareAttack:GotoPoint()
end

--刷新倒计时
function ItemUnionWarfareAttack:RefreshCountDowm()
    local delayTime = self.FinishAt - Tool.Time()
    if (delayTime < 0) then
        self:UnSchedule(self.calTimeFunc)
        return
    end
    self._textActionTime.text = StringUtil.GetI18n(I18nType.Commmon, self.textTime, {time = TimeUtil.SecondToHMS(delayTime)})
end

--刷新进攻方成员
function ItemUnionWarfareAttack:RefreshAttackMember(Info)
end

return ItemUnionWarfareAttack
