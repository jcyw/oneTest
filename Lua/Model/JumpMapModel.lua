--[[    Function:跳转Map
]]
local JumpMapModel = {}
local BuildModel = import("Model/BuildModel")
local EventModel = import("Model/EventModel")
local TechModel = import("Model/TechModel")
local TaskModel = import("Model/TaskModel")
local MonsterData = import("Model/MonsterModel")
local UIType = _G.GD.GameEnum.UIType
local ArmiesModel = import("Model/ArmiesModel")
local SpecialBuildModel = import("Model/SpecialBuildModel")
local WelfareModel = import("Model/WelfareModel")
function JumpMapModel:MapInit()
    if self.Map ~= nil then
        return self.Map
    end
end

--条件枚举
JumpMapModel.ConditionState = {
    NULL = 0,
    ID = 1,
    LEVEL = 2,
    COUNT = 3,
    --提升
    PROMOTE = 4
}
JumpMapModel.Map = {
    --内城建造
    [810000] = function(buildId)
        local buildItem = BuildModel.CheckExist(buildId)
        if buildItem then
            TurnModel.BuildFuncDetail(buildId, nil, true)
        else
            JumpMapModel.BuildCreate(buildId, true)
        end
    end,
    --外城建造
    [810001] = function(buildId)
        local buildItem = BuildModel.CheckExist(buildId)
        if buildItem then
            TurnModel.BuildFuncDetail(buildId, buildItem, true)
        else
            JumpMapModel.BuildCreate(buildId, false)
        end
    end,
    --对应建筑升级
    [810100] = function(buildId, tempBuilding)
        JumpMapModel.UpgradeJump(buildId, tempBuilding)
    end,
    --多个建筑建造
    [810101] = function(buildId)
        local count = JumpMapModel.GetBuildIDCount(buildId)
        local maxCount = 0
        if JumpMapModel.finishParams and JumpMapModel.finishParams.para2 then
            maxCount = JumpMapModel.finishParams.para2
        else
            maxCount = 1
        end
        count = count > maxCount and maxCount or count
        local remainCount = maxCount - count
        if remainCount == 0 then --满足建筑数量
            local eventBuilding = nil
            --执行对应建筑升级
            local buildings = BuildModel.GetAll(buildId)
            for _, v in pairs(buildings) do
                if EventModel.GetUpgradeEvent(v.Id) then
                    eventBuilding = v
                    break
                end
            end
            if eventBuilding then
                TurnModel.BuildFuncDetail(buildId, eventBuilding, true)
            else
                JumpMapModel.UpgradeJump(buildId)
            end
        else --剩余多少没被建造
            --执行建筑建造
            local isCity = BuildModel.GetBuildPosType(buildId) == JumpMapModel.IsCityEnter(buildId)
            JumpMapModel.BuildCreate(buildId, isCity)
        end
    end,
    --建筑升级 日常任务--1代表队列，0代表其他
    [810102] = function(SidebaNum)
        JumpMapModel.DailyTaskUpgrade(SidebaNum)
    end,
    --训练兵种
    [810200] = function(buildId)
        JumpMapModel.TrainJump(buildId)
    end,
    --制造防御武器
    [810201] = function(buildId)
        JumpMapModel.TrainJump(buildId)
    end,
    --训练固定坦克
    [810202] = function(armId)
        local buildId = BuildModel.GetConfIdByArmId(armId)
        JumpMapModel:SetJumpArmyId(armId)
        JumpMapModel.TrainJump(buildId)
    end,
    --训练固定战车
    [810203] = function(armId)
        local buildId = BuildModel.GetConfIdByArmId(armId)
        JumpMapModel:SetJumpArmyId(armId)
        JumpMapModel.TrainJump(buildId)
    end,
    --训练固定直升机
    [810204] = function(armId)
        local buildId = BuildModel.GetConfIdByArmId(armId)
        JumpMapModel:SetJumpArmyId(armId)
        JumpMapModel.TrainJump(buildId)
    end,
    --训练固定重型载具
    [810205] = function(armId)
        local buildId = BuildModel.GetConfIdByArmId(armId)
        JumpMapModel:SetJumpArmyId(armId)
        JumpMapModel.TrainJump(buildId)
    end,
    --研究科技
    [810300] = function(studyId)
        JumpMapModel:StudyTechnology(false, studyId)
    end,
    --研究固定科技
    [810301] = function(studyId)
        JumpMapModel:StudyTechnology(true, studyId)
    end,
    --治疗伤兵
    [810400] = function(buildId)
        JumpMapModel.CureJump(buildId)
    end,
    --解锁巨兽巢穴
    [810002] = function(buildId)
        local cb = function()
            Event.Broadcast(EventDefines.MoveMapEvent, true)
        end
        local jumpGuide = function(piece)
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.MosterLouckUI, buildId)
        end
        Event.Broadcast(EventDefines.MoveMapEvent, false)
        TurnModel.TurnMapPiece(buildId, jumpGuide, cb)
    end,
    --治疗巨兽
    [810401] = function(buildId)
        JumpMapModel.CureMonster(buildId)
    end,
    --解锁资源区域
    [810500] = function(pieceId)
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.LockUI, pieceId)
    end,
    --采集资源
    [810600] = function(resouId)
        TurnModel.MineTurnPos(resouId)
    end,
    --击杀或攻打固定等级野怪
    [810700] = function(confId)
        local level = ConfigMgr.GetItem("configMonsters", confId).level
        JumpMapModel.KillJump(level)
    end,
    --击杀或攻打野怪
    [810701] = function(buildId)
        JumpMapModel.KillJump()
    end,
    --探险
    [810800] = function(buildId)
        TurnModel.Explore()
    end,
    --猎鹰行动残骸
    [810801] = function(index)
        Net.EagleHunt.AimTarget(
            index,
            function(rsp)
                if rsp.Fail then
                    return
                else
                    if (GlobalVars.IsInCity == false) then
                        UIMgr:Close("WelfareMain")
                    end
                    TurnModel.OpenWorldMap(rsp, false)
                    Event.Broadcast(EventDefines.WorldGuideShow)
                end
            end
        )
    end,
    --提升产量
    [810900] = function(buildId)
        local isExist = BuildModel.CheckExist(buildId)

        if isExist then
            local noBuffBuilds = {}
            for _, v in pairs(BuildModel.GetAll(buildId)) do
                local resBuild = Model.Find(ModelType.ResBuilds, v.Id)
                local effectTime = resBuild.BuffExpireAt - Tool.Time()
                if effectTime <= 0 then
                    table.insert(noBuffBuilds, v)
                end
            end
            local max = 0
            local building = nil
            for _1, v1 in pairs(noBuffBuilds) do
                if v1.Level >= max then
                    max = v1.Level
                    building = v1
                end
            end
            --
            if building then
                local buildLevelMax = BuildModel.GetConf(building.ConfId).max_level
                if building.Level < buildLevelMax then
                    JumpMapModel.bid = building.Id
                else
                    local isCityEnter = JumpMapModel.IsCityEnter(buildId)
                    JumpMapModel.BuildCreate(buildId, isCityEnter)
                    return
                end
            end
            JumpMapModel.SetBuildState(buildId, _G.GD.GameEnum.JumpType.Promote)
            TurnModel.BuildFuncDetail(buildId, building, true)
        else
            JumpMapModel.BuildCreate(buildId, false)
        end
    end,
    --使用资源道具
    [811000] = function()
        TurnModel.GoBackpackStore(false, 2)
    end,
    --补给
    [811100] = function(buildId)
        local building = BuildModel.FindByConfId(buildId)
        if building then
            JumpMapModel.bid = building.Id
        else
            JumpMapModel.BuildCreate(buildId, false)
            return
        end
        TurnModel.BuildFuncDetail(buildId, nil, true)
        JumpMapModel.SetBuildState(buildId, _G.GD.GameEnum.JumpType.Supply)
    end,
    --在线奖励
    [811300] = function(isMove)
        -- local isEqualPos = CityMapModel.CheckBuildPosEqualMovePos(405000)
        TurnModel.TurnMapPiece(
            405000,
            nil,
            function()
                TurnModel.BuildTurnSpecial(405000)
            end,
            isMove
        )
    end,
    --背包商城
    [812200] = function(storePage, itemPage)
        TurnModel.GoBackpackStore(storePage, itemPage)
    end,
    --超值礼包
    [811701] = function()
        UIMgr:Open("RechargeMain", false, true)
    end,
    --加入联盟
    [811800] = function()
        JumpMapModel.UnionJump()
    end,
    --联盟捐献
    [811900] = function()
        JumpMapModel.UnionJump("Button_Technology")
    end,
    --资源援助
    [811901] = function()
        JumpMapModel.UnionJump("BUTTON_AIDRESOURCES")
    end,
    --成员援助
    [811902] = function()
        JumpMapModel.UnionJump("Button_AssistanceForce")
    end,
    --联盟帮助
    [811903] = function()
        JumpMapModel.UnionJump("Button_Help")
    end,
    --联盟接受任务
    [811904] = function()
        if Model.Player.AllianceId == "" then
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.UnionBtnUI, nil)
        else --加入联盟
            TurnModel.UnionTask()
        end
    end,
    --联盟协助任务
    [811905] = function()
        if Model.Player.AllianceId == "" then
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.UnionBtnUI, nil)
        else --加入联盟
            TurnModel.UnionTaskHelp()
        end
    end,
    --队列联盟捐献
    [811906] = function()
        if Model.Player.AllianceId == "" then
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.UnionBtnUI, nil)
        else --加入联盟
            TurnModel.UnionTeck()
        end
    end,
    --联盟商场
    [812201] = function(buildId)
        if Model.Player.AllianceId == "" then
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.UnionBtnUI, nil)
        else --加入联盟
            TurnModel.GoUnionStore()
        end
    end,
    --使用转盘
    [811200] = function(indexId)
        if indexId == 0 then
            TurnModel.Casion()
        end
    end,
    --签到
    [811400] = function()
        TurnModel.GoDayActivities(WelfareModel.WelfarePageType.DAILY_ATTENDANCE)
    end,
    --应用商店评价 1代表苹果，2代表谷歌
    [812000] = function(id)
        -- Sdk.OpenAppStore()
        Sdk.OpenBrowser("https://play.google.com/store/apps/details?id=com.global.neocrisis2")
        Net.UserInfo.EvaluateGame()
        --前往商店后通知服务器
    end,
    --特价商城
    [812100] = function()
        TurnModel.GoSpecialMall()
    end,
    --跳转至大地图
    [812300] = function()
        TurnModel.WorldMap()
    end,
    --章节任务指引
    [812400] = function()
        local mainUI = UIMgr:GetUI("MainUIPanel")
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.UIMainTaskIcon)
    end,
    --福利中心Icon
    [812500] = function()
        local uiPanel = UIMgr:GetUI("MainUIPanel")
        if uiPanel._btnActiviCenter.visible then
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.UIWelfareIcon, nil, nil)
        else
            return
        end
    end,
    --建筑免费按钮
    [812600] = function(buildingInfo, btnComplete)
        if JumpMapModel:GuideStage() then
            return
        end
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BtnFreeCompleteUI, btnComplete, buildingInfo.Id)
    end,
    --哥斯拉在线奖励
    [812700] = function()
        local uiPanel = UIMgr:GetUI("MainUIPanel")
        if uiPanel._btnGodzilla.visible then
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.UIGodzillaIcon, nil, nil)
        else
            return
        end
    end,
    --账号绑定
    [812800] = function()
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.UISetupAccountUI, nil, nil)
    end,
    --技能使用弹窗
    [812900] = function()
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.PlayerSkillPopupUI)
    end,
    --地图按钮指引
    [813000] = function(params)
        --在世界地图不屏蔽
        local isWorldShow = params
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.UIMapTurnBtnUI, isWorldShow, nil)
    end,
    --指挥官升级
    [813100] = function()
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.PlayerDetailsUI)
    end,
    --地图打怪
    [813200] = function()
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.UIMapTurnMonster, 0)
    end,
    --提示图标指引
    [813300] = function(Building, otherParams)
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BtnFreeCompleteUI, otherParams, Building.Id)
    end,
    --扔飞镖
    [813400] = function()
        local buildItem = BuildModel.FindByConfId(Global.BuildingCasino)
        JumpMapModel.bid = buildItem.Id
        JumpMapModel.SetBuildState(Global.BuildingCasino, _G.GD.GameEnum.JumpType.Drats)
        TurnModel.BuildFuncDetail(Global.BuildingCasino, nil, true)
    end,
    --美女玩游戏
    [813500] = function()
        local buildItem = BuildModel.FindByConfId(Global.BuildingCasino)
        JumpMapModel.bid = buildItem.Id
        JumpMapModel.SetBuildState(Global.BuildingCasino, _G.GD.GameEnum.JumpType.Girls)
        TurnModel.BuildFuncDetail(Global.BuildingCasino, nil, true)
    end,
    --充值钻石页面
    [813600] = function()
        UIMgr:Open("RechargeMain", true)
    end,
    --新手引导开始战斗引导按钮
    [813700] = function(params)
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.NewGuidePlayerTip, params, nil)
    end,
    [814000] = function(buildId, tempBuilding)
        if JumpMapModel:GuideStage() then
            Event.Broadcast(EventDefines.CloseGuide)
        end
        JumpMapModel.UpgradeJump(buildId, tempBuilding)
    end,
    --点击技能引导
    [815000] = function()
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.PlayerDetailSkillUI)
    end,
    --猎鹰行动页面引导
    [816000] = function()
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.FalconUI)
    end,
    --跳转大地图中心城市
    [817000] = function()
        TurnModel.WorldPos(600, 600)
    end,
    --装备工厂
    [818000] = function(buildId)
        JumpMapModel.ForgeJump(buildId)
    end,
    --建筑升级条件不足
    [819000] = function()
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BuildUpgradeGotoBtn)
    end,
    --材料工厂
    [820000] = function(configInfo, isDelay)
        if isDelay then
            TurnModel.TurnMapPiece(
                Global.BuildingEquipMaterialFactory,
                nil,
                function()
                    local triggerCall = function()
                        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BuildObject, nil, Global.BuildingEquipMaterialFactory)
                        Scheduler.ScheduleOnce(
                            function()
                                if JumpMapModel.IsGuideing then
                                    Event.Broadcast(EventDefines.CloseGuide)
                                    UIMgr:Open("EquipmentMake")
                                end
                            end,
                            4
                        )
                    end
                    local info = Model.JewelMakeInfo
                    if #info.OverList > 0 then
                        local buildingId = BuildModel.GetObjectByConfid(Global.BuildingEquipMaterialFactory)
                        BuildModel.GetObject(buildingId):SetClickMateriakCall(triggerCall)
                        BuildModel.GetObject(buildingId):BuildClick()
                    else
                        triggerCall()
                    end
                end,
                true
            )
        else
            TurnModel.TurnMapPiece(
                Global.BuildingEquipMaterialFactory,
                nil,
                function()
                    UIMgr:Open("EquipmentMake", configInfo.type, configInfo.id)
                end,
                true
            )
        end
    end,
    --装备材料不足指引
    [821000] = function()
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.EquipmentUIItem)
    end,
    --未解锁第二材料免费队列时指引
    [822000] = function()
        if not GlobalVars.IsNoviceGuideStatus and not GlobalVars.IsTriggerStatus then
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.EquipmentMakeFreeItem)
        end
    end
}

--建造
function JumpMapModel.BuildCreate(buildId, isCity)
    Event.Broadcast(EventDefines.MoveMapEvent, false)
    local jumpGuide = function(piece)
        if piece then
            CityMapModel.SetCutPos(piece, isCity)
            local posNum = piece:GetPiecePos()
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.CityMapUI, posNum, buildId)
        else
            TipUtil.TipById(50036)
            return
        end
    end

    local endMoveFunc = function()
        Event.Broadcast(EventDefines.MoveMapEvent, true)
    end

    JumpMapModel.SetBuildState(buildId, _G.GD.GameEnum.JumpType.Create)
    if isCity == true then
        local buildItem = BuildModel.CheckExist(buildId)
        if buildItem then
            TurnModel.BuildFuncDetail(buildId, buildItem, true)
        else
            TurnModel.TurnMapPiece(buildId, jumpGuide, endMoveFunc)
        end
    else --外城建筑
        local isConditon = JumpMapModel:FinishCondition(buildId, JumpMapModel.ConditionState.COUNT)
        if isConditon == true then
            TurnModel.TurnMapPiece(buildId, jumpGuide, endMoveFunc)
        end
    end
end

--日常任务升级
function JumpMapModel.DailyTaskUpgrade(SidebaNum)
    local freeQueue = Model.Builders[BuildType.QUEUE.Free]
    local chargeQueue = Model.Builders[BuildType.QUEUE.Charge]
    local FindBuildFunc = function()
        local taskData = TaskModel.GetQueueConfig()
        local taskDataID = math.floor(taskData.id / 100) * 100
        JumpMapModel:SetBuildId(taskDataID)
        if taskData then
            --1级为建造
            local isCity = BuildModel.IsInnerByConfigId(taskDataID)
            if taskData.level == 1 then
                --内外城建造
                JumpMapModel.BuildCreate(taskDataID, isCity)
            else
                --升级
                if isCity then
                    local building = BuildModel.FindByConfId(taskDataID)
                    JumpMapModel.UpgradeJump(taskDataID, building)
                else
                    local building = BuildModel.FindMaxLevel(taskDataID)
                    JumpMapModel.UpgradeJump(taskDataID, building)
                end
            end
        else
            TipUtil.TipById(50037)
        end
    end
    --有队列
    if SidebaNum == 1 then
        FindBuildFunc()
    else
        if freeQueue.IsWorking or chargeQueue.IsWorking then
            if freeQueue.IsWorking and not chargeQueue.IsWorking then
                local buildNode = BuildModel.GetObject(freeQueue.EventId)
                JumpMapModel.UpgradeJump(buildNode.building.ConfId)
            elseif not freeQueue.IsWorking and chargeQueue.IsWorking then
                local buildNode = BuildModel.GetObject(chargeQueue.EventId)
                JumpMapModel.UpgradeJump(buildNode.building.ConfId)
            else --队列都有优先时间最少
                local freeNode = BuildModel.GetObject(freeQueue.EventId)
                local chargeNode = BuildModel.GetObject(chargeQueue.EventId)
                local freeEvent = EventModel.GetEvent(freeNode.building)
                local chargeEvent = EventModel.GetEvent(chargeNode.building)
                if freeEvent.FinishAt and chargeEvent.FinishAt then
                    local freeTime = freeEvent.FinishAt - Tool.Time()
                    local chargeTime = chargeEvent.FinishAt - Tool.Time()
                    local buildNode = freeTime - chargeTime >= 0 and freeNode or chargeNode
                    JumpMapModel.UpgradeJump(buildNode.building.ConfId)
                end
            end
        else --没有队列
            FindBuildFunc()
        end
    end
end

--装备锻造
function JumpMapModel.ForgeJump(buildId)
    local isExist = BuildModel.CheckExist(buildId)
    if not isExist then
        --内城建造
        JumpMapModel.BuildCreate(buildId, true)
        return
    end
    JumpMapModel.bid = BuildModel.FindByConfId(buildId).Id
    TurnModel.BuildFuncDetail(buildId, nil, true)
    --指导到锻造
    if buildId == Global.BuildingEquipFactory then
        JumpMapModel.SetBuildState(buildId, _G.GD.GameEnum.JumpType.Forge)
        return
    end
end

--训练
function JumpMapModel.TrainJump(buildId)
    local isExist = BuildModel.CheckExist(buildId)
    if not isExist then
        --内城建造
        JumpMapModel.BuildCreate(buildId, true)
        return
    end
    JumpMapModel.bid = BuildModel.FindByConfId(buildId).Id
    TurnModel.BuildFuncDetail(buildId, nil, true)
    --指导到训练
    if buildId == Global.BuildingSecurityFactory then
        JumpMapModel.SetBuildState(buildId, _G.GD.GameEnum.JumpType.Make)
        return
    end
    JumpMapModel.SetBuildState(buildId, _G.GD.GameEnum.JumpType.Train)
end

function JumpMapModel:GetTech()
    if self.TechId == nil then
        return
    end
    return self.TechId
end

--研究科技
function JumpMapModel:StudyTechnology(isFix, studyId)
    self.TechId = studyId
    if Tool.Equal(studyId, Global.BuildingScience, Global.BuildingBeastScience) then
        studyId = studyId
    else
        --为普通科技研究
        if not TechModel.GetTechConfigItem(Global.BeastTech, studyId) then
            studyId = Global.BuildingScience
        else
            studyId = Global.BuildingBeastScience
        end
    end
    local isExist = BuildModel.CheckExist(studyId)
    if not isExist then
        JumpMapModel.BuildCreate(studyId, true)
        return
    end

    JumpMapModel.bid = BuildModel.FindByConfId(studyId).Id
    --固定科技
    if isFix then
        local isHaveTech = TechModel.CheckTechCanUpgradeOfAll(Global.NormalTech)
        if isHaveTech == false then
            TipUtil.TipById(50038)
        else
            -- 403000科研中心
            TurnModel.BuildFuncDetail(studyId, nil, true)
        end
    else
        TurnModel.BuildFuncDetail(studyId, nil, true)
    end
    if studyId == Global.BuildingScience then
        JumpMapModel.SetBuildState(studyId, _G.GD.GameEnum.JumpType.Tech)
    elseif studyId == Global.BuildingBeastScience then
        JumpMapModel.SetBuildState(studyId, _G.GD.GameEnum.JumpType.BeastResearch)
    end
end

--治疗
function JumpMapModel.CureJump(buildId)
    local cureTable = {}
    local noCureTable = {}
    local otherTable = {}
    local isHave = ArmiesModel.IsHaveInjuredArmy()
    local isExist = BuildModel.CheckExist(Global.BuildingHospital)
    if not isExist then
        JumpMapModel.BuildCreate(buildId, false)
        return
    end
    if not isHave then
        TipUtil.TipById(50039)
        return
    end

    local buildings = BuildModel.GetAll(Global.BuildingHospital)
    for key, value in pairs(buildings) do
        local buildEvent = EventModel.GetEvent(value)
        if buildEvent == nil then
            table.insert(noCureTable, value)
        elseif buildEvent.Category == Global.EventTypeCure then
            table.insert(cureTable, value)
        else
            table.insert(otherTable, value)
        end
    end
    local cureItem = nil
    if #noCureTable > 0 then
        if #noCureTable > 1 then
            table.sort(
                noCureTable,
                function(a, b)
                    return a.Id > b.Id
                end
            )
        end
        cureItem = noCureTable[1]
    else
        if #cureTable > 1 then
            table.sort(
                cureTable,
                function(a, b)
                    return a.Id > b.Id
                end
            )
        end
        cureItem = cureTable[1]
    end
    if not cureItem then
        if next(otherTable) then
            table.sort(
                otherTable,
                function(a, b)
                    return a.Id > b.Id
                end
            )
        else
            return
        end
        JumpMapModel:SetFinishParams(nil)
        cureItem = otherTable[1]
        JumpMapModel.UpgradeJump(cureItem.ConfId, cureItem)
        return
    end
    JumpMapModel.bid = cureItem.Id
    JumpMapModel.SetBuildState(cureItem, _G.GD.GameEnum.JumpType.Cure, true)
    TurnModel.BuildFuncDetail(Global.BuildingHospital, cureItem, true)
end

function JumpMapModel.CureMonster(buildId)
    local building = BuildModel.FindByConfId(buildId)
    local cureCount = MonsterData.GetMonsterHurtNum()
    if cureCount == 0 or not cureCount then
        TipUtil.TipById(50039)
        return
    end
    JumpMapModel.bid = building.Id
    JumpMapModel.SetBuildState(building.ConfId, _G.GD.GameEnum.JumpType.BeastCure)
    TurnModel.BuildFuncDetail(buildId, nil, true)
end

--击杀/攻打
function JumpMapModel.KillJump(level)
    local pos = nil
    if level ~= nil then
        TurnModel.MonstherTurnPos(level)
    else
        TurnModel.MonsterKilledTurnPos()
    end
end

--联盟
function JumpMapModel.UnionJump(unionName)
    --没有加入联盟
    if Model.Player.AllianceId == "" then
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.UnionBtnUI, nil)
    else --加入联盟
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.UnionBtnUI, UIType.UnionBtnUI, unionName)
    end
end

--完成条件
function JumpMapModel:FinishCondition(buildId, state)
    --没有完成条件
    if self.finishParams == nil or self.finishParams == 0 then
        return true
    end
    local type = self.finishParams.type
    local isRight = false
    if state == self.ConditionState.LEVEL then
        local param1Data = 0
        local maxLevel = BuildModel.GetConf(buildId).max_level
        if type == 101 or type == 102 then
            param1Data = self.finishParams.para1 + self.finishParams.para2
        end
        if param1Data == 0 then
            return true
        end

        local building = BuildModel.FindByConfId(buildId, "Min")
        if building == nil then
            isRight = false
        else
            if building.Level >= maxLevel then
                isRight = false
            else
                local buildUpgrade = ConfigMgr.GetItem("configBuildingUpgrades", param1Data)
                local Finishlevel = 0
                if buildUpgrade then
                    Finishlevel = buildUpgrade.level
                else
                    return false
                end
                isRight = building.Level < Finishlevel and true or false
            end
        end
    elseif state == self.ConditionState.ID then
    elseif state == self.ConditionState.COUNT then
        local count = self.finishParams.para2
        local buildCount = self:GetBuildIDCount(buildId)
        isRight = buildCount < count and true or false
    end
    return isRight
end

function JumpMapModel:SetFinishParams(finishParams)
    self.finishParams = finishParams
end

function JumpMapModel:GetFinishiParams()
    return self.finishParams
end

--升级如果是城外建筑自动选择等级最小,tempBuilding没有升级条件必填
function JumpMapModel.UpgradeJump(buildId, tempBuilding)
    local isExist = BuildModel.CheckExist(buildId)
    local isCity = JumpMapModel.IsCityEnter(buildId)
    if not isExist then
        JumpMapModel.BuildCreate(buildId, isCity)
        return
    end
    local building = nil
    JumpMapModel.bid = 0

    local isCondition = nil
    if tempBuilding then
        isCondition = true
    else
        isCondition = JumpMapModel:FinishCondition(buildId, JumpMapModel.ConditionState.LEVEL)
    end
    if not isCondition then
        TipUtil.TipById(50037)
        return
    end
    if isCity then
        local buildItem = BuildModel.FindByConfId(buildId)
        JumpMapModel.bid = buildItem.Id
        --加速引导
        JumpMapModel.SetBuildState(buildId, _G.GD.GameEnum.JumpType.Upgrade)
        TurnModel.BuildFuncDetail(buildId, nil, true)
    else
        if JumpMapModel.finishParams and JumpMapModel.finishParams.type == 131 then
            building = BuildModel.FindByConfId(buildId, "Min")
            --没有找到低等级的就指引创建，没有空地的就指引解锁区域，区域都解锁了没有空地的弹出提示
            local buildLevelMax = BuildModel.GetConf(building.ConfId).max_level
            if building and building.Level == buildLevelMax then
                local isCityEnter = JumpMapModel.IsCityEnter(buildId)
                JumpMapModel.BuildCreate(buildId, isCityEnter)
                return
            end
        elseif JumpMapModel.finishParams then
            building = JumpMapModel:GetOutCityNearLevel(buildId)
        elseif not JumpMapModel.finishParams and tempBuilding then --当不需要升级条件
            building = tempBuilding
        else
            return
        end
        --容错处理
        if not building then
            if tempBuilding then
                JumpMapModel.bid = tempBuilding.Id
                --加速引导
                JumpMapModel.SetBuildState(tempBuilding, _G.GD.GameEnum.JumpType.Upgrade, true)
                TurnModel.BuildFuncDetail(buildId, tempBuilding, true)
            end
            return
        end
        JumpMapModel.bid = building.Id
        --加速引导
        JumpMapModel.SetBuildState(building, _G.GD.GameEnum.JumpType.Upgrade, true)
        TurnModel.BuildFuncDetail(buildId, building, true)
    end
end

--得到建筑Id相同的数量
function JumpMapModel.GetBuildIDCount(buildId)
    local sameBuilds = BuildModel.GetAll(buildId)
    return #sameBuilds
end

function JumpMapModel:GetOutCityNearLevel(BuildId)
    local tableTemp = {}
    if self.finishParams and (self.finishParams.type == 101 or self.finishParams.type == 103) then
        local levelID = 0
        if self.finishParams.type == 101 then
            levelID = self.finishParams.para1 + self.finishParams.para2
        elseif self.finishParams.type == 103 then
            levelID = self.finishParams.para1
        end
        local allBuild = BuildModel.GetAll(BuildId)
        local finishlevel = ConfigMgr.GetItem("configBuildingUpgrades", levelID).level
        for k, v in pairs(allBuild) do
            if v.Level < finishlevel then
                table.insert(tableTemp, v)
            end
        end
        table.sort(
            tableTemp,
            function(a, b)
                return a.Level > b.Level
            end
        )
        return tableTemp[1]
    end
    return nil
end

--设置建筑状态 otherType是菜单类型
function JumpMapModel.SetBuildState(buildparams, otherType, isOut)
    local event = nil
    if isOut then
        event = EventModel.GetEvent(buildparams)
    else
        local goalBuild = BuildModel.FindByConfId(buildparams)
        event = EventModel.GetEvent(goalBuild)
    end
    if event or (event and Tool.Equal(event.Category, EventType.B_TRAIN, event.EventType.B_CURE)) then
        JumpMapModel:SetJumpType(_G.GD.GameEnum.JumpType.Speed)
    else
        JumpMapModel:SetJumpType(otherType)
    end
end

function JumpMapModel.IsCityEnter(buildId)
    return Tool.Equal(BuildModel.GetBuildPosType(buildId), Global.BuildingZoneInnter, Global.BuildingZoneBeast, Global.BuildingZoneNest)
end

function JumpMapModel:SetJumpType(type)
    self.cutJumpType = type
end

function JumpMapModel:GetJumpType()
    return self.cutJumpType
end
function JumpMapModel:GetJumpBidId()
    return self.bid
end

function JumpMapModel:SetJumpBidInit()
    self.bid = 0
end

function JumpMapModel:SetJumpArmyId(armyId)
    self.jumpArmyId = armyId
end

function JumpMapModel:SetGuideStage(guide)
    self.IsGuideing = guide
end

--是否开始弱引导状态
function JumpMapModel:GuideStage()
    return self.IsGuideing
end

function JumpMapModel:GetJumpArmyId()
    return self.jumpArmyId
end

function JumpMapModel:GetBuildId()
    return self.buildId
end
function JumpMapModel:SetBuildId(buildId)
    self.buildId = buildId
end

function JumpMapModel:SetJumpId(jumId)
    self.JumpId = jumId
end

function JumpMapModel:GetJumpId()
    return self.JumpId
end

return JumpMapModel
