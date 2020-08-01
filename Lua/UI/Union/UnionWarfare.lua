--[[
    author:{zhanzhang}
    time:2019-07-01 17:32:16
    function:{联盟战争}
]]
local UnionWarfare = UIMgr:NewUI("UnionWarfare")
local UnionInfoModel = import("Model/Union/UnionInfoModel")
local UnionWarfareModel = import("Model/Union/UnionWarfareModel")
local UnionModel = import("Model/UnionModel")

-- Alliance_War_2 指挥官，当前行军时间大于集结时间，可能无法及时参与集结，您是否继续参加集结？
-- Alliance_War_GoOn 继续
-- BUTTON_NO 取消

function UnionWarfare:OnInit()
    -- body
    local view = self.Controller.contentPane
    self._textTagName = view:GetChild("textTagName")
    self._textAttackMy = view:GetChild("textAttackMy")
    self._textBattleNum = view:GetChild("textBattleNum")

    self._btnReturn = view:GetChild("btnReturn")
    self._btnAttack = view:GetChild("btnSttack")
    self._btnDefense = view:GetChild("btnDefense")
    self._btnWarfareRecord = view:GetChild("btnWarfareRecord")
    self._contentAttackList = view:GetChild("liebiaoAttack")
    self._contentDefense = view:GetChild("liebiaoDefense")
    self._contorller = view:GetController("c1")
    self._contorller2 = view:GetController("c2")
    -- self._textEmpty = view:GetChild("textEmpty")
    self._contentAttackList:SetVirtual()
    self._contentDefense:SetVirtual()

    self.calTimeFunc = {}
    self:OnRegister()
end

function UnionWarfare:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnAttack.onClick,
        function()
            self:ShowUnionAttack()
        end
    )
    self:AddListener(self._btnDefense.onClick,
        function()
            self:ShowUnionDefense()
        end
    )
    self:AddListener(self._btnWarfareRecord.onClick,
        function()
            UIMgr:Open("UnionBattleRecords")
        end
    )

    self.battleCancelFunc = function()
        if self._btnAttack.selected == true then
            self:ShowUnionAttack()
        else
            self:ShowUnionDefense()
        end
    end

    self.battleCreateFunc = function()
        local info = UnionInfoModel.GetInfo()
        UnionModel.RequestAllianceBattle(
            info.Uuid,
            function(rsp)
                UnionWarfareModel.SetUnionWarfareInfo(rsp)

                if self._btnAttack.selected == true then
                    self:ShowUnionAttack()
                else
                    self:ShowUnionDefense()
                end
            end
        )
    end

    self.battleRefreshFunc = function()
        if self._btnAttack.selected == true then
            self:ShowUnionAttack()
        else
            self:ShowUnionDefense()
        end
    end

    self.calTimeFunc = function()
        self:RefreshTaskCountDown()
    end

    self:AddEvent(
        EventDefines.UIUnionWarfare,
        function()
            self:CheckCuePoint()
        end
    )
    self._contentAttackList.itemRenderer = function(index, item)
        if not index then
            return
        end
        local list = UnionWarfareModel.GetUnionAttackList()
        item:Init(list[index + 1])
    end
    self._contentDefense.itemRenderer = function(index, item)
        if not index then
            return
        end
        local list = UnionWarfareModel.GetDenfenceList()
        item:Init(list[index + 1])
    end
end

function UnionWarfare:CheckCuePoint()
    local sub = CuePointModel.SubType.Union.UnionWarfare
    CuePointModel:SetSingle(sub.Type, sub.NumberBattles, self._btnAttack, CuePointModel.Pos.RightUp2515)
    CuePointModel:SetSingle(sub.Type, sub.NumberDefences, self._btnDefense, CuePointModel.Pos.RightUp2515)
end

function UnionWarfare:OnOpen(openType)
    local info = UnionInfoModel.GetInfo()
    UnionModel.RequestAllianceBattle(
        info.Uuid,
        function(rsp)
            UnionWarfareModel.SetUnionWarfareInfo(rsp)

            if not openType or openType == 1 then
                self:ShowUnionAttack()
            else
                self:ShowUnionDefense()
            end

            self:AddEvent(EventDefines.UIAllianceBattleCancel, self.battleCancelFunc)
            self:AddEvent(EventDefines.UIAllianceBattleCreate, self.battleCreateFunc)
            self:AddEvent(EventDefines.UIOnRefreshAggregation, self.battleRefreshFunc)
        end
    )

    self:UnSchedule(self.calTimeFunc)
    self._btnAttack.selected = true
    if not openType or openType == 1 then
        self._contorller.selectedIndex = 0
    else
        self._contorller.selectedIndex = 1
    end

    self:CheckCuePoint()
    
    -- 进入界面就认为所有进攻信息已读
    UnionModel.ResetNotReadUnionAttackList()
end

function UnionWarfare:Close()
    UIMgr:Close("UnionWarfare")
end

function UnionWarfare:RefreshTaskCountDown()
    self._textRefreshTimeNum.text = TimeUtil.secondToHMS(1)
end
--打开联盟战争进攻页面
function UnionWarfare:ShowUnionAttack()
    self._contorller2.selectedIndex = 0
    self._contentAttackList.visible = true
    self._contentDefense.visible = false
    local list = UnionWarfareModel.GetUnionAttackList()
    -- self._contentAttackList:RemoveChildrenToPool()
    -- local list = UnionWarfareModel.GetUnionAttackList()
    -- for i = 1, #list do
    --     local item = self._contentAttackList:AddItemFromPool()
    --     item:Init(list[i])
    -- end
    
    self._contentAttackList.numItems = #list
    if #list > 0 then
        self._contorller.selectedIndex = 0
    else
        self._contorller.selectedIndex = 2
    end
end
--打开联盟战争防御页面
function UnionWarfare:ShowUnionDefense()
    self._contorller2.selectedIndex = 1
    local list = UnionWarfareModel.GetDenfenceList()
    -- self._textEmpty.visible = #list == 0
    self._contentAttackList.visible = false
    self._contentDefense.visible = true
    -- self._contentDefense:RemoveChildrenToPool()

    -- for i = 1, #list do
    --     -- --状态0为集结进攻 1为单体进攻
    --     -- if (list[i].Category == 0) then
    --     -- item = self._contentDefense:AddItemFromPool("ui://Union/itemUnionWarfareDefenseArmies")
    --     -- item:Init(list[i])
    --     local item = self._contentDefense:AddItemFromPool("ui://Union/itemUnionWarfareDefense")
    --     item:Init(list[i])
    -- end
    self._contentDefense.numItems = #list
    if #list > 0 then
        self._contorller.selectedIndex = 1
    else
        self._contorller.selectedIndex = 2
    end
end

function UnionWarfare:OnClose()
    self:UnSchedule(self.calTimeFunc)
    Event.RemoveListener(EventDefines.UIAllianceBattleCancel, self.battleCancelFunc)
    Event.RemoveListener(EventDefines.UIAllianceBattleCreate, self.battleCreateFunc)
    Event.RemoveListener(EventDefines.UIOnRefreshAggregation, self.battleRefreshFunc)
    UnionModel.ResetUnionAttackPoint()
    UnionModel.ResetUnionDefendPoint()
    Event.Broadcast(EventDefines.UIAllianceWarefarePonit)
end
--[[
-- 请求-集结信息
-- path=AllianceBattleInfosParams
-- params={AllianceId: string}

--     请求-创建集结
-- path=AllianceBattleCreateParams
-- params={DurationType: int32, TargetX: int32, TargetY: int32, Armies: array-Army}

--     请求-解散
-- path=AllianceBattleDisbandParams
-- params={AllianceBattleId: string}

--     请求-遣返
-- path=AllianceBattleRemovalParams
-- params={AllianceBattleId: string, MissionId: string}

--     请求-加速
-- path=AllianceBattleSpeedupParams
-- params={AllianceBattleId: string, MissionId: string, ConfId: int32}

--     请求-联盟战斗记录
-- path=AllianceBattleLogsParams
-- params={Offset: int32, Limit: int32}

--     回复-联盟战斗记录
-- path=AllianceBattleLogsRsp
-- params={Offset: int32, Logs: array-AllianceBattleLog}

--     回复-集结信息
-- path=AllianceBattleInfosRsp
-- params={Battles: array-AllianceBattle, Missions: array-AllianceBattleMission}---
]]
return UnionWarfare
