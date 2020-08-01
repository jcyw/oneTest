--[[
    author:{zhanzhang}
    time:2019-07-02 13:50:02
    function:{联盟战争防御Item}
]]
local ItemUnionWarfareDefense = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionWarfareDefense", ItemUnionWarfareDefense)
local WorldMap = import("UI/WorldMap/WorldMap")
local UnionWarfareModel = import("Model/Union/UnionWarfareModel")

function ItemUnionWarfareDefense:ctor()
    -- self._textAction = self:GetChild("textAction")
    -- self._textActionTime = self:GetChild("textActionTime")
    -- self._textNameL = self:GetChild("textNameL")
    -- self._textCoordinateL = self:GetChild("textCoordinateL")
    -- self._textNameR = self:GetChild("textNameR")
    -- self._textCoordinateR = self:GetChild("textCoordinateR")
    -- self._iconHeadL = self:GetChild("iconHeadL")
    -- self._iconHeadR = self:GetChild("iconHeadR")
    self._typeController = self:GetController("c1")

    self:OnRegister()
end
function ItemUnionWarfareDefense:OnRegister()
    self.calTimeFunc = function()
        self:RefreshDenseCountDown()
    end
    self:AddListener(self.onRemovedFromStage,
        function()
            self:UnSchedule(self.calTimeFunc)
        end
    )
    -- self:AddListener(self._btnAssistance.onClick,
    --     function()
    --         self:onBtnAssistanceClick()
    --     end
    -- )
    --点击自己坐标跳转
    self:AddListener(self._textCoordinateL.onClick,
        function()
            UIMgr:ClosePopAndTopPanel()
            Event.Broadcast(EventDefines.OpenWorldMap, self.data.TargetX, self.data.TargetY)
        end
    )
    --点击敌方坐标跳转
    self:AddListener(self._textCoordinateR.onClick,
        function()
            UIMgr:ClosePopAndTopPanel()
            Event.Broadcast(EventDefines.OpenWorldMap, self.data.X, self.data.Y)
        end
    )

    --联盟堡垒坐标跳转
    self:AddListener(self._textCoordinate.onClick,
        function()
            TurnModel.WorldPos(self.data.TargetX, self.data.TargetY)
        end
    )

    self.timerFunc = function()
        local time = self.finishAt - Tool.Time()
        if time > 0 then
            local time = TimeUtil.SecondToDHMS(time)
            self._textActionTime.text = time
        else
            self:UnSchedule(self.timerFunc)
        end
    end
end

function ItemUnionWarfareDefense:Init(data)
    self.data = data
    self:UnSchedule(self.timerFunc)
    self:UnSchedule(self.calTimeFunc)
    
    if self.data.Category == Global.ABStatusDestroying then
        self._typeController.selectedIndex = 1
        self:InitUnionDefense()
    else
        self._typeController.selectedIndex = 0
        self:InitSingleDefense()
    end
end

--联盟堡垒正被摧毁防御
function ItemUnionWarfareDefense:InitUnionDefense()
    local name = ConfigMgr.GetItem("configAllianceFortresss", tonumber(self.data.DefendUserId)).building_name
    self._iconBuild.icon = UITool.GetIcon(Global.AllianceBase)
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, name)
    self._textCoordinate.text = StringUtil.GetCoordinataStr(self.data.TargetX, self.data.TargetY)
    self._textEnemyName.text = self.data.UserName
    self._textEnemyNum.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_TeamNumber")..#self.data.GarrisonMembers
    self._textAction.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Destroy")
    self.finishAt = self.data.FinishAt

    self._contentAttackMember:RemoveChildrenToPool()
    for _,v in pairs(self.data.GarrisonMembers) do
        local item = self._contentAttackMember:AddItemFromPool()
        CommonModel.SetUserAvatar(item:GetChild("icon"), v.Avatar, v.UserId)
    end

    self:Schedule(self.timerFunc, 1)
end

-- 单人的防御信息
function ItemUnionWarfareDefense:InitSingleDefense()
    --被进攻方（我方）
    if self.data.DesCategory == Global.MapTypeAllianceDomain then
        local config = ConfigMgr.GetItem("configAllianceFortresss", tonumber(self.data.DefendUserId))
        self._textNameL.text = StringUtil.StringShortly(StringUtil.GetI18n(I18nType.Commmon, config.building_name),10)
        self._iconHeadL.icon = UITool.GetIcon(Global.AllianceBase)
    else
        self._textNameL.text = StringUtil.StringShortly(self.data.TargetName,10)
        CommonModel.SetUserAvatar(self._iconHeadL, self.data.TargetAvatar, self.data.DefendUserId)
    end
    self._textCoordinateL.text = StringUtil.GetCoordinataStr(self.data.TargetX, self.data.TargetY)

    --进攻方 （敌方）
    self._textCoordinateR.text = StringUtil.GetCoordinataStr(self.data.X, self.data.Y)
    if self.data.UserName == Global.PVECategorySiege then
        -- 黑骑士
        local config = ConfigMgr.GetItem("configKnightBases", tonumber(self.data.UserId))
        self._textNameR.text = StringUtil.StringShortly(StringUtil.GetI18n(I18nType.Commmon, config.I18n),10)
        self._iconHeadR.icon = UITool.GetIcon(config.icon)
    else
        -- 玩家
        self._textNameR.text = StringUtil.StringShortly(self.data.UserName,10)
        CommonModel.SetUserAvatar(self._iconHeadR, self.data.Avatar, self.data.UserId)
    end

    self:CheckStaus()

    if self.data.Status == Global.ABStatusMarch then
        self._textAction.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Enemy")
    else
        self._textAction.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Enemy_Assmble")
    end

    if self.data.FinishAt > Tool.Time() then
        self:RefreshDenseCountDown()
        self:Schedule(self.calTimeFunc, 1, true)
    end
end

function ItemUnionWarfareDefense:RefreshDenseCountDown()
    local delayTime = self.data.FinishAt - Tool.Time()
    self._textActionTime.text = TimeUtil.SecondToHMS(delayTime)
end

--检测援助状态
function ItemUnionWarfareDefense:CheckStaus()
    --如果自己是被打的，什么都不显示
    if self.data.DefendUserId == Model.Account.accountId then
        -- self._btnAssistance.visible = false
        -- self._textAssistance.visible = false
    else
        local isAssist = UnionWarfareModel.GetMissionListByBattleId(self.data.Uuid)
        -- self._btnAssistance.visible = isAssist
        -- self._textAssistance.visible = not isAssist
    end
end

function ItemUnionWarfareDefense:onBtnAssistanceClick()
    --[[此处应该判断
        1.是否同意同一联盟
        2.是否有足够的出征部队数量
        3.防守队伍是否有足够的空位
    ]]
    local posNum = self.data.TargetX * 10000 + self.data.TargetY
    local list = UnionWarfareModel.GetMissionListByBattleId(self.data.Uuid)
    local armyCount = 0
    for i = 1, #list do
        for j = 1, #list[i].Armies do
            armyCount = armyCount + list[i].Armies[j].Amount
        end
    end
    UIMgr:Open("UnionSoldierAssistancePopup", posNum, self.data.MaxRally, armyCount, ExpeditionType.JoinUnionDefense)
end

return ItemUnionWarfareDefense
-- 回复-集结信息
-- path=AllianceBattleInfosRsp
-- params={Battles: array-AllianceBattle, Missions: array-AllianceBattleMission, Defences: array-AllianceBattle, Assists: array-AllianceBattleMission}

--     请求-援助士兵
-- path=AllianceBattleAssistParams
-- params={UserId: string, X: int32, Y: int32, HeroId: string, Armies: array-Army}

--     请求-取消联盟援助
-- path=AllianceBattleCancelAssistParams
-- params={EventId: string}
