-- 功能列表打开界面
local GD = _G.GD
local FuncListModel = {}

local BuildModel = import("Model/BuildModel")
local EventModel = import("Model/EventModel")
local CommonModel = import("Model/CommonModel")
local TechModel = import("Model/TechModel")
local MonsterModel = import("Model/MonsterModel")
local WelfareModel = import("Model/WelfareModel")

-- 建筑金币加速
function FuncListModel.BuildingGoldSpeedup(building)
    local event = EventModel.GetUpgradeEvent(building.Id)
    if not event then
        return
    end
    local time = event.FinishAt - Tool.Time()
    local freeTime = CommonModel.FreeTime()
    local needGold = Tool.TimeTurnGold(time, freeTime)
    local data = {
        content = "Ui_CompleteNow_Up",
        gold = needGold,
        tipType = TipType.TYPE.ConditionUpgrade,
        event = event,
        sureCallback = function()
            Net.Events.Speedup(
                event.Category,
                event.Uuid,
                function(rsp)
                    Model.Delete(ModelType.UpgradeEvents, rsp.EventId)
                    local buildObj = BuildModel.GetObject(building.Id)
                    if event.Category == EventType.B_BUILD then
                        buildObj:UpgradeEnd(rsp.BuildingLevel)
                        Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.EndLvUp, building.ConfId, {rsp.BuildingLevel, 5})
                        Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.NoTrigger, building.ConfId, rsp.BuildingLevel)
                    elseif event.Category == EventType.B_DESTROY then
                        buildObj:RemoveEnd()
                    end
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

-- 道具加速 [建筑道具加速、训练道具加速、制造道具加速、研究]
function FuncListModel.ItemSpeedup(building)
    if EventModel.GetEvent(building) then
        UIMgr:Open("BuildAcceleratePopup", building)
    end
end

-- 训练金币加速
function FuncListModel.TrainGoldSpeedup(building)
    local event = EventModel.GetTrainEvent(building.ConfId)
    local time = event.FinishAt - Tool.Time()
    local needGold = Tool.TimeTurnGold(time)
    local data = {
        content = "Ui_CompleteNow_Train",
        gold = needGold,
        tipType = TipType.TYPE.ConditionTrain,
        event = event,
        sureCallback = function()
            Net.Events.Speedup(
                event.Category,
                event.Uuid,
                function(rsp)
                    EventModel.SetTrainEnd(rsp.EventId)
                    BuildModel.GetObject(building.Id):TrainAnim(true)
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

-- 锻造金币加速
function FuncListModel.ProduceGoldSpeedup(building)
    FuncListModel.TrainGoldSpeedup(building)
end

local function BoostItem(building)
    local parameter = CommonModel.GetResParameter(building.ConfId)
    local conf = ConfigMgr.GetItem("configResourcess", parameter.category)
    local v1 = {
        res_name = StringUtil.GetI18n(I18nType.Commmon, conf.key),
        prop_name = GD.ItemAgent.GetItemNameByConfId(parameter.itemId)
    }
    local v2 = {
        res_factory = BuildModel.GetName(building.ConfId)
    }
    local isBoost = Model.ResBuilds[building.Id].BuffExpireAt - Tool.Time() > 0
    local content = ""
    if isBoost then
        content = StringUtil.GetI18n(I18nType.Commmon, "Afresh_Inrease_Production_1", v2)
    else
        content = StringUtil.GetI18n(I18nType.Commmon, "Prop_Inrease_Production", v1)
    end
    local data = {
        content = content,
        sureCallback = function()
            Net.ResBuilds.UseBuffItem(building.Id, 1, function()
                TipUtil.TipById(50052, v2, conf.icon_upgrade)
            end)
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end
-- 食品道具提升(道具)
function FuncListModel.FoodBoostItem(building)
    BoostItem(building)
end
-- 石油道具提升(道具)
function FuncListModel.OilBoostItem(building)
    BoostItem(building)
end
-- 合金道具提升(道具)
function FuncListModel.SteelBoostItem(building)
    BoostItem(building)
end
-- 稀土道具提升(道具)
function FuncListModel.MineralBoostItem(building)
    BoostItem(building)
end

-- 产量金币提升
function FuncListModel.BoostGold(building)
    local parameter = CommonModel.GetResParameter(building.ConfId)
    local v1 = {
        res_name = StringUtil.GetI18n(I18nType.Commmon, ConfigMgr.GetItem("configResourcess", parameter.category).key)
    }
    local v2 = {
        res_factory = BuildModel.GetName(building.ConfId)
    }
    local isBoost = Model.ResBuilds[building.Id].BuffExpireAt - Tool.Time() > 0
    local content = ""
    if isBoost then
        content = StringUtil.GetI18n(I18nType.Commmon, "Afresh_Inrease_Production_2", v1)
    else
        content = StringUtil.GetI18n(I18nType.Commmon, "Diamond_Inrease_Production", v1)
    end
    local goldNum = parameter.coefficient * building.Level
    local data = {
        content = content,
        gold = goldNum,
        sureCallback = function()
            if UITool.CheckGem(goldNum) then
                Net.ResBuilds.BuyBuff(building.Id, function()
                    TipUtil.TipById(50052, v2, ConfigMgr.GetItem("configResourcess", Global.ResDiamond).icon)
                end)
            end
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

-- 联盟医院
function FuncListModel.AllianceHospital()
    TipUtil.TipById(50259)
end

-- 收集
function Collect(building)
    Net.ResBuilds.CollectSingle(
        building.Id,
        function(rsp)
            for _, v in pairs(rsp.CollectAmounts) do
                if v.Amount >= 1 then
                    local buildObj = BuildModel.GetObject(v.BuildingId)
                    local resCategory = CommonModel.GetResParameter(building.ConfId).category
                    AnimationModel.ResCollect(buildObj, resCategory)
                    buildObj:HarestEndAnim(v.Amount)
                end
            end
            Event.Broadcast(EventDefines.UIResourcesAmount, rsp.ResAmounts)
        end
    )
end
function FuncListModel.CollectFood(building)
    Collect(building)
end
function FuncListModel.CollectOil(building)
    Collect(building)
end
function FuncListModel.CollectSteel(building)
    Collect(building)
end
function FuncListModel.CollectMineral(building)
    Collect(building)
end

-- 提速还剩下
function FuncListModel.BoostTime()
    --该按钮不支持点击
end

function FuncListModel.Cure(building)
    UIMgr:Open("CureRelated/CureArmy", BuildType.CUREARMY.Build, building)
end

-- 治疗金币加速
function FuncListModel.CureGoldSpeedup(building)
    local event = EventModel.GetCureEvent()
    local time = event.FinishAt - Tool.Time()
    local needGold = Tool.TimeTurnGold(time)
    local data = {
        content = "Ui_CompleteNow_Treatment",
        gold = needGold,
        tipType = TipType.TYPE.ConditionCure,
        event = event,
        sureCallback = function()
            Net.Events.Speedup(
                event.Category,
                event.Uuid,
                function(rsp)
                    Model.Delete(ModelType.CureEvents, rsp.EventId)
                    for _, v in pairs(rsp.Armies) do
                        Model.Create(ModelType.Armies, v.ConfId, v)
                    end
                    for _, v in pairs(Model.Buildings) do
                        if v.ConfId == Global.BuildingHospital then
                            BuildModel.GetObject(v.Id):CureEnd()
                        end
                    end
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

-- 治疗道具加速
function FuncListModel.CureItemSpeedup(building)
    UIMgr:Open("BuildAcceleratePopup", building)
end

-- 研究
function FuncListModel.Research(building)
    UIMgr:Open("Laboratory", building)
end

-- 研究金币加速
function FuncListModel.ResearchGoldSpeedup(building)
    local event = TechModel.GetUpgradeTech(building.ConfId == Global.BuildingBeastScience and Global.BeastTech or Global.NormalTech)
    if event and next(event) then
        local time = event.FinishAt - Tool.Time()
        local needGold = Tool.TimeTurnGold(time)
        local data = {
            content = "Ui_CompleteNow_Tech",
            gold = needGold,
            tipType = TipType.TYPE.ConditionTech,
            event = event,
            sureCallback = function()
                Net.Events.Speedup(
                    event.Category,
                    event.Uuid,
                    function(rsp)
                        Model.Delete(ModelType.UpgradeEvents, rsp.EventId)
                        TechModel.UpdateTechModel({ConfId = rsp.ConfId, Level = rsp.TechLevel, Type = rsp.TechType})
                        if rsp.TechType == Global.NormalTech then
                            Model.ResearchGift = true
                        else
                            Model.BeastResearchGift = true
                        end
                        -- 显示科技完成奖励气泡
                        for _, v in pairs(Model.Buildings) do
                            if rsp.TechType == Global.BeastTech and v.ConfId == Global.BuildingBeastScience then
                                BuildModel.GetObject(v.Id):ScienceAwardAnim(true)
                            elseif rsp.TechType == Global.NormalTech and v.ConfId == Global.BuildingScience then
                                BuildModel.GetObject(v.Id):ScienceAwardAnim(true)
                            end
                        end
                        BuildModel.GetObject(building.Id):ResetCD()
                        local config = TechModel.GetDisplayConfigItem(rsp.TechType, rsp.ConfId)
                        TipUtil.TipById(30105, {tech_name =  TechModel.GetTechName(rsp.ConfId)}, config.icon)
                        Event.Broadcast(EventDefines.UIRefreshTechResearchFinish, rsp.ConfId)
                    end
                )
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end
end

-- 增益
function FuncListModel.Buff()
    UIMgr:Open("BaseGain", Global.PageBaseBuff)
end

-- 补给
function FuncListModel.Supply(building)
    UIMgr:Open("MilitarySupplies", building)
end

-- 查看仓库
function FuncListModel.ViewVault(building)
    UIMgr:Open("ResourceDisplay")
end

-- 加入联盟
function FuncListModel.JoinUnion()
    TurnModel.UnionView()
end

-- 盟友援助
function FuncListModel.AidAllies(building)
    Net.AllianceBattle.AllianceGarrisonsInfo(
        MathUtil.GetPosNum(Model.Player.X, Model.Player.Y), 
        function(rsp)
            UIMgr:Open("TroopAssistance", rsp)
        end
    )
end
--联盟帮助
function FuncListModel:UnionHelp()
    TurnModel.UnionHelp()
end
--联盟科技
function FuncListModel:UnionTechnology()
    TurnModel.UnionTeck()
end
-- 城市大厅
function FuncListModel.CityHall(building)
    TipUtil.TipById(50259)
end

-- 材料制造道具加速
function FuncListModel.ProduceItemSpeedup(building)
    TipUtil.TipById(50259)
end

-- 锻造道具加速
function FuncListModel.ForgeItemSpeedup(building)
    UIMgr:Open("BuildAcceleratePopup", building)
end

-- 锻造金币加速
function FuncListModel.ForgeGoldSpeedup(building)
    local event = EquipModel.GetEquipEvents()
    local typeConfig = EquipModel.GetEquipTypeByEquipQualityID(event.EquipId)
    local timeGold = Tool.TimeTurnGold(typeConfig.need_time)
    if timeGold > Model.Player.Gem then
        UITool.GoldLack()
        return
    end
    local data = {
        content = StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_CompleteNow_Train", {diamond_num = timeGold}),
        tipType = TipType.TYPE.ConditionTrain,
        gold = timeGold,
        sureCallback = function()
            Net.Events.Speedup(EventType.B_EQUIPTRAN, event.Uuid, function(rsp)
                EquipModel.SetEquipEventEnd(rsp.EventId)
        
                --收取气泡
                local typeConfig = EquipModel.GetEquipTypeById(EquipModel.QualityID2TypeID(rsp.EquipId))
                local buildId = BuildModel.GetObjectByConfid(Global.BuildingEquipFactory)
                BuildModel.GetObject(buildId):EquipMakeAnim(true, typeConfig.icon)
            end)
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

-- 宝库
function FuncListModel.TreasuryHouse(building)
    UIMgr:Open("EquipmentGemVault")
end

-- 情报
function FuncListModel.Intelligence(building)
    UIMgr:Open("Radar")
end

-- 联盟战争
function FuncListModel.UnionWar(building)
    UIMgr:Open("UnionWarfare")
end

-- 资源援助
function FuncListModel.AidResources(building)
    if Model.Player.AllianceId ~= "" then
        UnionModel.RequestUnionInfo(function()
            UIMgr:Open("UnionMember/UnionMember")
        end)
    else
        TipUtil.TipById(50053)
    end
end

-- 防御
function FuncListModel.Defense()
    UIMgr:Open("Wall")
end

--巨兽基地 图鉴
function FuncListModel.BeastMap(building, armyType)
    MonsterModel.RequestGetMonsterList(false, function (rsp)
        if not armyType then
            UIMgr:Open("MonsterOverview", rsp)
        else
            for i, v in ipairs(rsp) do
                local monsterId = MonsterModel.GetMonsterRealID(v.Id, v.Level)
                if MonsterModel.GetMonsterTypeId(monsterId) == armyType then
                    UIMgr:Open("MonsterManual", rsp, i, true)
                    break
                end
            end
        end
    end)
end

--巨兽医院 治疗
function FuncListModel.BeastCure()
    MonsterModel.RequestGetMonsterList(false, function(list)
        UIMgr:Open("MonsterHospital")
    end)
end

--巨兽研究所 研究
function FuncListModel.BeastResearch(building)
    UIMgr:Open("Laboratory", building)
end

--巨兽研究钻石加速
function FuncListModel.BeastResearchGold(building)
    FuncListModel.ResearchGoldSpeedup(building)
end

--巨兽研究道具加速
function FuncListModel.BeastResearchItem(building)
    UIMgr:Open("BuildAcceleratePopup", building)
end

--哥斯拉巢穴
function FuncListModel.Godzilla(building)
    FuncListModel.BeastMap(building, ArmyType.SMALL.Godzilla)
end

--金刚巢穴
function FuncListModel.KingKong(building)
    FuncListModel.BeastMap(building, ArmyType.SMALL.KingKong)
end

--巨兽治疗道具加速
function FuncListModel.BeastCureItem(building)
    UIMgr:Open("BuildAcceleratePopup", building)
end

--巨兽治疗钻石加速
function FuncListModel.BeastCureGold(building)
    local event = EventModel.GetBeastCureEvent()
    local time = event.FinishAt - Tool.Time()
    local needGold = Tool.TimeTurnGold(time)
    local data = {
        content = "Ui_CompleteNow_Treatment",
        gold = needGold,
        tipType = TipType.TYPE.ConditionBeastCure,
        event = event,
        sureCallback = function()
            Net.Events.Speedup(
                event.Category,
                event.Uuid,
                function(rsp)
                    Model.Delete(ModelType.BeastCureEvents, rsp.EventId)

                    for _, v in pairs(Model.Buildings) do
                        if v.ConfId == Global.BuildingBeastHospital then
                            BuildModel.GetObject(v.Id):CureEnd(true)
                        end
                    end
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

--赌场
function FuncListModel.RangeTurntable()
    TurnModel.Casion()
end

--美女
function FuncListModel.BeautySystemMain(building)
    UIMgr:Open("BeautySystemMain", building)
end

--客服中心：游戏客服
function FuncListModel.GameCustomerService()
    -- 屏蔽权限提示
    -- if not Sdk.CanAccessGM() then
    --     local data = {
    --         content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Gm_Upload_Permission"),
    --         buttonType= "double",
    --         sureCallback = function()
    --             Sdk.RequestGM()
    --         end
    --     }
    --     UIMgr:Open("ConfirmPopupText", data)
    -- else
    local serverId = ""
    local accountId = "" 
    if Auth and Auth.WorldData then
        serverId = Auth.WorldData.sceneId
        accountId = string.gsub(Auth.WorldData.accountId, "#", "-")
    end
    Sdk.AiHelpShowConversation(accountId, serverId)
    SdkModel.GmNotRead = 0
    Event.Broadcast(GM_MSG_EVENT.MsgIsRead, SdkModel.GmNotRead)
    -- end
end
--客服中心：游戏说明
function FuncListModel.GameGuide()
    Sdk.AiHelpShowFAQs()
end

--钻石基金（新）
function FuncListModel.DiamondsFundPrice()
    UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.DIAMOND_FUND_ACTIVITY)
end
--见面礼
function FuncListModel.CumulativeAttendance()
    UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.CUMULATIVE_ATTENDANCE)
end
--签到
function FuncListModel.DailyAttendance()
    UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.DAILY_ATTENDANCE)
end
--排行榜
function FuncListModel.Rank()
    Net.Rank.RankInfo(Global.RankByAlliancePower, 1, 0, function(rsp)
        if rsp.Fail then
            return
        end
        UIMgr:Open("RankMain", rsp)
    end)
end
--成长基金
function FuncListModel.GrowthFund()
    UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.GROWTHCAPITALTYPE)
    PlayerDataModel:SetDayNotTip(PlayerDataEnum.DAY_GROWTHFUND)
end
--月卡
function FuncListModel.MonthlyCard()
    UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.SPECIALGIFTTYPE)
    PlayerDataModel:SetDayNotTip(PlayerDataEnum.DAY_MONTHCARD)
end
--猎鹰行动
function FuncListModel.FalconAction()
    UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.FALCON_ACTIVITY)
end

--装备制造
function FuncListModel.Forge()
    UIMgr:Open("EquipmentSelect",1)
end

--幸运转盘
function FuncListModel.LuckyDraw()
    UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.LUCKYTURNTABLE_ACTIVITY)
    PlayerDataModel:SetDayNotTip(PlayerDataEnum.DAY_MONTHCARD)
end

--转盘
function FuncListModel.DressUp()
    UIMgr:Open("Individuation")
end
--战机零件
function FuncListModel.PlanePart()
    UIMgr:Open("AircraftAccessories")
end
--战机机库
function FuncListModel.Plane()
    UIMgr:Open("AircraftHangar")
end
return FuncListModel
