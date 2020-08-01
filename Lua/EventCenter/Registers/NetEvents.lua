local GD = _G.GD
local NetEvents = {}
local FavoriteModel = import("Model/FavoriteModel")

local BuildEvents = import("EventCenter/Registers/BuildEvents")
local CommonEvents = import("EventCenter/Registers/CommonEvents")
local UnionEvents = import("EventCenter/Registers/UnionEvents")
local TechEvent = import("EventCenter/Registers/TechEvents")
local ArmyEvent = import("EventCenter/Registers/ArmyEvents")
local VipEvent = import("EventCenter/Registers/VipEvents")
local WelfareEvents = import("EventCenter/Registers/WelfareEvents")
local BuildModel = import("Model/BuildModel")
local MissionEventModel = import("Model/MissionEventModel")
local ArmiesModel = import("Model/ArmiesModel")
local MarchLineModel = import("Model/MarchLineModel")
local MarchManagerModel = import("Model/MarchManagerModel")
local RadarModel = import("Model/RadarModel")
local UnionModel = import("Model/UnionModel")
local MapModel = import("Model/MapModel")
local SkillModel = import("Model/SkillModel")
local BuffItemModel = import("Model/BuffItemModel")
local UnionWarfareModel = import("Model/Union/UnionWarfareModel")
local WelfareModel = import("Model/WelfareModel")
local GiftModel = import("Model/GiftModel")
local MarchAnimModel = import("Model/MarchAnimModel")
local Reason = import("Enum/Reason")
local TaskModel = import("Model/TaskModel")
local AchievementModel = import("Model/AchievementModel")
local ActivityModel = import("Model/ActivityModel")
local MonsterModel = import("Model/MonsterModel")
local CustomEventManager = import("GameLogic/CustomEventManager")
local WelfareCuePointModel = import("Model/CuePoint/WelfareCuePointModel")
local RoyalBattleManager = import("UI/WorldMap/RoyalBattleManager")
local PlaneModel = import("Model/PlaneModel")
local DressUpModel = import("Model/DressUpModel")
-- local TriggerGuideLogic=import("Model/TriggerGuideLogic")
local DailyTaskModel = import("Model/DailyTaskModel")
local GlobalVars = GlobalVars
local EquipModel =  _G.EquipModel
local Model = _G.Model

function NetEvents.Regist()
    BuildEvents.init() -- 建筑监听事件
    CommonEvents.init() -- 公用监听事件 [道具等]
    UnionEvents.init() --联盟监听事件
    TechEvent.init() -- 科技研究监听事件2
    ArmyEvent.init() -- 部队变化监听事件
    VipEvent.init() --vip变化监听事件
    WelfareEvents.init() --福利中心监听事件

    RoyalBattleManager.Init()

    -- 通知-同一账号登录被挤下线提示通知
    Event.AddListener(
        ApiMap.protos.PT_LoginAtOtherPlace,
        function(rsp)
            Event.Broadcast(EventDefines.UILoginAtOtherPlace, rsp)
        end
    )
    -- 通知-建筑建造完成
    Event.AddListener(
        ApiMap.protos.PT_BuildingFinishRsp,
        function(rsp)
            Event.Broadcast(EventDefines.UIBuildingFinish, rsp)
            AudioModel.Play(40014)
        end
    )
    -- 建筑升级完成通知
    Event.AddListener(
        ApiMap.protos.PT_BuildingUpgradeParams,
        function(rsp)
            Event.Broadcast(EventDefines.UIBuildingUpgrade, rsp)
        end
    )
    -- 建筑拆除通知
    Event.AddListener(
        ApiMap.protos.PT_BuildingFinishDestroyRsp,
        function(rsp)
            Event.Broadcast(EventDefines.UIBuildingDestroy, rsp)
        end
    )
    -- 建筑队列通知
    Event.AddListener(
        ApiMap.protos.PT_Builder,
        function(rsp)
            Event.Broadcast(EventDefines.UIBuilder, rsp)
        end
    )
    -- 建筑队列购买通知
    Event.AddListener(
        ApiMap.protos.PT_BuildingBuyBuilderRsp,
        function(rsp)
            Model.Builders[BuildType.QUEUE.Charge].ExpireAt = rsp.ExpireAt
            Event.Broadcast(EventDefines.UIResetBuilder)
        end
    )
    -- 建筑升级事件刷新
    Event.AddListener(
        ApiMap.protos.PT_UpgradeEvent,
        function(rsp)
            Event.Broadcast(EventDefines.UIUpgradeEvent, rsp)
        end
    )
    -- 士兵治疗事件刷新
    Event.AddListener(
        ApiMap.protos.PT_CureEvent,
        function(rsp)
            Event.Broadcast(EventDefines.UICureEvent, rsp)
        end
    )
    -- 造兵完成通知
    Event.AddListener(
        ApiMap.protos.PT_ArmyTrainFinishRsp,
        function(rsp)
            Event.Broadcast(EventDefines.UIArmyTrainFinish, rsp)
        end
    )
    -- 单一兵种数量变化通知
    Event.AddListener(
        ApiMap.protos.PT_Army,
        function(rsp)
            Event.Broadcast(EventDefines.UIArmyChange, rsp)
        end
    )
    -- 资源变化通知
    Event.AddListener(
        ApiMap.protos.PT_ResAmountInfos,
        function(rsp)
            Event.Broadcast(EventDefines.UIResourcesAmount, rsp.ResAmounts)
            GD.ResAgent.Update(rsp.ResAmounts)
        end
    )
    -- 保护资源变化通知
    Event.AddListener(
        ApiMap.protos.PT_ResProtects,
        function(rsp)
            Event.Broadcast(EventDefines.UIResProtects, rsp)
        end
    )
    -- 通知-行军事件
    Event.AddListener(
        ApiMap.protos.PT_MissionEvent,
        function(rsp)
            Event.Broadcast(EventDefines.UIOnMissionInfo, rsp)
        end
    )
    -- --侦查野怪任务通知
    Event.AddListener(
        ApiMap.protos.PT_MonsterVisitInfo,
        function(rsp)
            Model.MonsterVisitInfo[rsp.ActivityId] = rsp
            if GlobalVars.IsInCity then
                return
            end
            Event.Broadcast(EventDefines.MapFalconMonster)
            if rsp.ActivityId == WelfareModel.WelfarePageType.FALCON_ACTIVITY then
                local oldSpyedPosList = Model.MonsterVisitInfo[rsp.ActivityId].VisitFullRecs
                Event.Broadcast(EventDefines.MapSpyMonster,oldSpyedPosList)
            end
        end
    )

    -- 通知-部队回家
    Event.AddListener(
        ApiMap.protos.PT_MissionReturnRsp,
        function(rsp)
            ArmiesModel.RefreshArmies(rsp.Armies)
            Event.Broadcast(EventDefines.UIArmyAmount, rsp)
            Event.Broadcast(EventDefines.UIInjuredArmyAmount, rsp)
        end
    )
    -- 通知-资源建筑新增更新
    Event.AddListener(
        ApiMap.protos.PT_ResBuild,
        function(rsp)
            local resBuildInfo = Model.GetMap(ModelType.ResBuilds)
            Event.Broadcast(EventDefines.UIResBuilAdd, rsp)
            resBuildInfo[rsp.Id] = rsp
        end
    )
    -- 通知-资源建筑更新
    Event.AddListener(
        ApiMap.protos.PT_ResBuilds,
        function(rsp)
            Event.Broadcast(EventDefines.UIResBuils, rsp)
        end
    )
    -- 通知-士兵
    Event.AddListener(
        ApiMap.protos.PT_ArmyInfos,
        function(rsp)
            Event.Broadcast(EventDefines.UIArmyAmount, rsp)
        end
    )
    -- 通知-伤兵信息
    Event.AddListener(
        ApiMap.protos.PT_InjuredArmy,
        function(rsp)
            Model.Create(ModelType.InjuredArmies, rsp.ConfId, rsp)
            Event.Broadcast(EventDefines.UIInjuredArmyAmountExg)
            Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.HaveInjure, 12600, 0)
        end
    )
    -- 通知-删除伤兵
    Event.AddListener(
        ApiMap.protos.PT_ArmyDeleteInjuredParams,
        function(rsp)
        end
    )
    -- 通知-伤兵信息-复数
    Event.AddListener(
        ApiMap.protos.PT_InjuredArmies,
        function(rsp)
            for _, v in pairs(rsp.InjuredArmies) do
                Model.Create(ModelType.InjuredArmies, v.ConfId, v)
            end
            Event.Broadcast(EventDefines.UIInjuredArmyAmountExg)
            Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.HaveInjure, 12600, 0)
        end
    )
    -- 通知-完成治疗士兵
    Event.AddListener(
        ApiMap.protos.PT_ArmyFinishCureRsp,
        function(rsp)
            Event.Broadcast(EventDefines.UIArmyCureFinish, rsp)
        end
    )
    -- 通知-道具
    Event.AddListener(
        ApiMap.protos.PT_ItemInfos,
        function(rsp)
            Event.Broadcast(EventDefines.UIItemsAmount, rsp)
        end
    )
    -- 通知-单个道具
    Event.AddListener(
        ApiMap.protos.PT_ItemInfo,
        function(rsp)
            Event.Broadcast(EventDefines.UIItemAmount, rsp)
        end
    )
    -- 通知-单个道具
    Event.AddListener(
        ApiMap.protos.PT_Item,
        function(rsp)
            Event.Broadcast(EventDefines.ItemAmount, rsp)
        end
    )
    -- 通知-钻石更新
    Event.AddListener(
        ApiMap.protos.PT_GemInfo,
        function(rsp)
            Event.Broadcast(EventDefines.UIGemAmount, rsp.Gem)
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_Bookmark,
        function(rsp)
            FavoriteModel.RefreshItem(rsp)
            Event.Broadcast(EventDefines.UIOnRefreshFavorite)
        end
    )
    -- 通知-根据ModelType进行相关删除
    Event.AddListener(
        ApiMap.protos.PT_DeleteById,
        function(rsp)
            if rsp.Name == ModelType.BuffItem then
                Model.Delete(ModelType.BuffItem, rsp.Id)
                BuffItemModel.Refresh()
            elseif rsp.Name == "AllianceBookmark" then
                local list = Model.GetMap(ModelType.AllianceBookmarks)
                for key, v in pairs(list) do
                    if v.Category == rsp.Id then
                        list[key] = nil
                        Event.Broadcast(EventDefines.MapDelAllianceMark, rsp.Id)
                    end
                end
            elseif rsp.Name == "MainTask" then
                local taskMainId = rsp.Id
                TaskModel.RemoveTaskInfo(taskMainId)
                --如果在任务界面主动刷新页面
                if UIMgr:GetUIOpen("TaskMain") then
                    Event.Broadcast(EventDefines.UITaskMainRefresh)
                end
            else
                Event.Broadcast(EventDefines.UIResBuilsDelete, rsp)
            end
        end
    )
    -- 通知-邮件
    Event.AddListener(
        ApiMap.protos.PT_Mail,
        function(rsp)
            if not MailModel:InsertData(rsp) then
                Log.Error("===============收到重复邮件============= Category:"..rsp.Category .. " Uuid: " .. rsp.Uuid)
                return
            end
            Event.Broadcast(EventDefines.UIReqMails, rsp)
            Event.Broadcast(EventDefines.UIMailsNumChange, {})
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_MailMessageInfo,
        function(rsp)
            MailModel:InsertMsg(rsp)
            Event.Broadcast(MAILEVENTTYPE.MailNewMsg, rsp)
            Event.Broadcast(EventDefines.UIMailsNumChange, {})
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_MailSessionInfo,
        function(rsp)
            MailModel:SessionInfoChange(MAIL_TYPE.Msg, rsp)
            Event.Broadcast(MAILEVENTTYPE.MailGroupChange, rsp)
            Event.Broadcast(MAILEVENTTYPE.MailRefresh)
        end
    )

    local ModelType = import("Enum/ModelType")
    -- 通知-军需
    Event.AddListener(
        ApiMap.protos.PT_MSItem,
        function(rsp)
            Model.InitOtherInfo(ModelType.MSInfos, rsp)
            Event.Broadcast(EventDefines.UIReqMSInfo)
        end
    )

    -- 通知-军需汇总
    Event.AddListener(
        ApiMap.protos.PT_MSInfos,
        function(rsp)
            Model.InitOtherInfo(ModelType.MSInfos, rsp)
            Event.Broadcast(EventDefines.UIReqMSInfo)
        end
    )

    --通知-删除事件
    Event.AddListener(
        ApiMap.protos.PT_Delete,
        function(rsp)
            if rsp.Name == "MapMarchLine" then
                MarchManagerModel.DelMarchInfo(rsp.Uuid, rsp.Reason == Reason.MarchLineDeleteForCancel)
                Event.Broadcast(EventDefines.UIDelMarchLine, rsp)
            elseif rsp.Name == "MissionEvent" then
                MissionEventModel.DelMission(rsp.Uuid)
                Event.Broadcast(EventDefines.UIDelMission, rsp)
            elseif rsp.Name == "AppliedAlliance" then
                Model.Delete(ModelType.AppliedAlliance, rsp.Uuid)
            elseif rsp.Name == "AllianceTask" then
                UnionModel.DelTask(rsp.Uuid)
            elseif rsp.Name == "AllianceHelp" then
                Event.Broadcast(EventDefines.UIAllianceHelped, rsp.Uuid)
            elseif rsp.Name == "AllianceBattle" then
                --删除联盟战斗信息
                UnionWarfareModel.RemoveAttackBattle(rsp.Uuid)
                UnionWarfareModel.RemoveDefendBattle(rsp.Uuid)
                UnionModel.RemoveUnionAttackPoint(rsp.Uuid)
                UnionModel.RemoveUnionDefendPoint(rsp.Uuid)
                Event.Broadcast(EventDefines.UIAllianceBattleCancel, rsp.Uuid)
                Event.Broadcast(EventDefines.UIAllianceWarefarePonit)
            elseif rsp.Name == "MailSession" then
                MailModel:DeleteSessionInfo(MAIL_TYPE.Msg, rsp.Uuid)
                Event.Broadcast(MAILEVENTTYPE.MailGroupDel)
                Event.Broadcast(MAILEVENTTYPE.MailRefresh)
            elseif rsp.Name == "MarchWarning" then
                -- 取消雷达预警
                RadarModel.DeleteItem(rsp.Uuid)
            elseif rsp.Name == "AllianceBattleMission" then
                UnionWarfareModel.RemoveMission(rsp.Uuid)
                Event.Broadcast(EventDefines.UIDelMarchLine, rsp)
                Event.Broadcast(EventDefines.UIDelMission, rsp)
            else
                Log.Warning("Delete msg not handle: {0}", rsp.Name)
            end
        end
    )

    -- 通知-科技研究完成
    Event.AddListener(
        ApiMap.protos.PT_TechFinishRsp,
        function(rsp)
            Event.Broadcast(EventDefines.UITechResearchFinish, rsp)
        end
    )
    --通知 -战斗预警
    Event.AddListener(
        ApiMap.protos.PT_MarchWarning,
        function(rsp)
            RadarModel.AddItem(rsp)
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_MapBattleBegin,
        function(rsp)
            if GlobalVars.IsInCity then
                return
            end
            MarchAnimModel.BeginAttackAnim(rsp)
            Event.Broadcast(EventDefines.WorldMarchAnimPoint, rsp)
        end
    )

    -- 通知-BuffItem变更
    Event.AddListener(
        ApiMap.protos.PT_BuffItem,
        function(rsp)
            Model.Create(ModelType.BuffItem, rsp.Id, rsp)
            BuffItemModel.Refresh()
        end
    )

    --通知-Buff变更
    Event.AddListener(
        ApiMap.protos.PT_Buff,
        function(rsp)
            Model.Create(ModelType.Buffs, rsp.ConfId, rsp)
            Event.Broadcast(EventDefines.UIBuffUpdate)
        end
    )

    -----------------------------------------------------联盟相关------------------------------------------------
    -- 通知-联盟信息变化
    Event.AddListener(
        ApiMap.protos.PT_UserAllianceInfo,
        function(rsp)
            Event.Broadcast(EventDefines.UIUserAllianceInfo, rsp)
        end
    )
    -- 通知-联盟成员变化
    Event.AddListener(
        ApiMap.protos.PT_AllianceMember,
        function(rsp)
            Event.Broadcast(EventDefines.UIAllianceMember, rsp)
        end
    )
    -- 通知-联盟申请信息
    Event.AddListener(
        ApiMap.protos.PT_AppliedAlliance,
        function(rsp)
            Event.Broadcast(EventDefines.UIAllianceApplied, rsp)
        end
    )
    -- 通知-联盟成员移除
    Event.AddListener(
        ApiMap.protos.PT_RemoveAllianceMemberInfo,
        function(rsp)
            Event.Broadcast(EventDefines.UIAllianceFire, rsp)
        end
    )
    --通知-联盟帮助通知
    Event.AddListener(
        ApiMap.protos.PT_AllianceHelp,
        function(rsp)
            Event.Broadcast(EventDefines.UIAllianceHelp, rsp)
        end
    )
    --通知-联盟帮助之自己被帮助
    Event.AddListener(
        ApiMap.protos.PT_AllianceHelpOnHelp,
        function(rsp)
            Event.Broadcast(EventDefines.UIAllianceHelpOnHelp, rsp)
        end
    )
    --通知-联盟协作任务被帮助
    Event.AddListener(
        ApiMap.protos.PT_AllianceTask,
        function(rsp)
            if rsp then
                UnionModel.RefreshTask(rsp)
            end
            Event.Broadcast(EventDefines.UIAllianceRefeshHelpTask)
        end
    )
    --通知--联盟集结变化
    Event.AddListener(
        ApiMap.protos.PT_AllianceBattleSpeedUp,
        function(rsp)
            if rsp.Mission then
                UnionWarfareModel.RefreshMission(rsp.Mission)
            end
            if rsp.BattleId ~= "" then
                UnionWarfareModel.RefreshBattleFinishAt(rsp.BattleId, rsp.BattleFinishAt)
            end
            Event.Broadcast(EventDefines.UIOnRefreshAggregation, rsp)
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_AllianceTaskInfo,
        function(rsp)
            UnionModel.InitHelpTask(rsp)
            Event.Broadcast(EventDefines.UIAllianceRefeshHelpTask)
        end
    )
    --单个联盟标记刷新
    Event.AddListener(
        ApiMap.protos.PT_AllianceBookmark,
        function(val)
            local list = Model.GetMap(ModelType.AllianceBookmarks)
            list[val.Category] = val
            Event.Broadcast(EventDefines.MapAddAllianceMark, val)
        end
    )
    --联盟标记刷新
    Event.AddListener(
        ApiMap.protos.PT_AllianceBookmarks,
        function(val)
            Model.Init(ModelType.AllianceBookmarks, "Category", val.AllianceBookmarks)
        end
    )

    --通知-联盟留言
    Event.AddListener(
        ApiMap.protos.PT_MessageItem,
        function(rsp)
            Event.Broadcast(EventDefines.AllianceMessage, rsp)
            Event.Broadcast(EventDefines.UIUnionManger)
        end
    )

    -- 留言删除
    Event.AddListener(
        ApiMap.protos.PT_MessageItemDelete,
        function(msg)
            local oldMsgId = PlayerDataModel:GetData(PlayerDataEnum.UnionMsgId)
            if not oldMsgId then
                oldMsgId = 0
            end
            if msg.MessageId and msg.MessageId > oldMsgId then
                Model.UnreadAllianceMessages = Model.UnreadAllianceMessages - 1
                Event.Broadcast(EventDefines.UIUnionManger)
            end
        end
    )

    -- 投票开始
    Event.AddListener(
        ApiMap.protos.PT_AllianceVoteStarted,
        function(msg)
            for _, v in pairs(UnionModel.notVoteList) do
                if v == msg.Uuid then
                    return
                end
            end
            table.insert(UnionModel.notVoteList, msg.Uuid)
            Event.Broadcast(EventDefines.UIUnionManger)
        end
    )

    -- 投票结束
    Event.AddListener(
        ApiMap.protos.PT_AllianceVoteFinished,
        function(msg)
            for k, v in pairs(UnionModel.notVoteList) do
                if v == msg.Uuid then
                    table.remove(UnionModel.notVoteList, k)
                    Event.Broadcast(EventDefines.UIUnionManger)
                    return
                end
            end
        end
    )

    -- 通知-联盟集结到达集结点
    Event.AddListener(
        ApiMap.protos.PT_AllianceBattleMission,
        function(msg)
            UnionWarfareModel.RefreshMission(msg)
            Event.Broadcast(EventDefines.UIOnRefreshAggregation)
        end
    )

    -- 通知-新建联盟集结进攻
    Event.AddListener(
        ApiMap.protos.PT_AllianceBattleCreated,
        function(msg)
            for _, v in pairs(msg.Battles) do
                if v.AllianceId == Model.Player.AllianceId then
                    UnionModel.AddOneUnionAttackPoint(v)
                else
                    UnionModel.AddOneUnionDefendPoint(v.Uuid)
                end
            end
            Event.Broadcast(EventDefines.UIAllianceBattleCreate)
            Event.Broadcast(EventDefines.UIAllianceWarefarePonit)
        end
    )

    -- 通知-联盟集结信息变更
    Event.AddListener(
        ApiMap.protos.PT_AllianceBattle,
        function(msg)
            Event.Broadcast(EventDefines.UIAllianceBattleChange, msg)
        end
    )

    -- 通知-联盟集结战争数量
    Event.AddListener(
        ApiMap.protos.PT_AllianceBattleNums,
        function(msg)
            for _, v in pairs(msg.Attack) do
                UnionModel.AddOneUnionAttackPoint(v)
            end

            for _, v in pairs(msg.Defence) do
                UnionModel.AddOneUnionDefendPoint(v)
            end

            Event.Broadcast(EventDefines.UIAllianceWarefarePonit)
        end
    )

    -- 通知-联盟科技捐献冷却结束
    Event.AddListener(
        ApiMap.protos.PT_AllianceTechContriCoolDown,
        function(msg)
            Model.Player.AllianceTechCanContri = true
            Event.Broadcast(EventDefines.UIUnionScience)
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_AllianceDailyUpdateInfo,
        function(msg)
            UnionModel:RefreshUnionTaskNotRead()
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_AlliancePresidentTask,
        function(msg)
            if UnionModel.bossTasks then
                for _, v in ipairs(UnionModel.bossTasks) do
                    if v.ConfId == msg.ConfId then
                        v.Status = msg.Status
                        break
                    end
                end
                UnionModel:RefreshUnionBossTaskNotRead()
            end
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_AllianceAnnouncement,
        function(msg)
            UnionModel.SetUnionNotice(msg.Content)
            Event.Broadcast(EventDefines.UIAllianceNoticeUpdate)
        end
    )

    -- 通知-联盟成员上线
    Event.AddListener(
        ApiMap.protos.PT_AllianceMemberOnline,
        function(rsp)
            if Model.Account.accountId ~= rsp.MemberId then
                local params = {
                    play_name = rsp.Name
                }
                TipUtil.TipById(50292, params)
            end
        end
    )

    --通知-聊天
    Event.AddListener(
        ApiMap.protos.PT_ChatNotice,
        function(rsp)
            Event.Broadcast(EventDefines.ChatEvent, rsp)
        end
    )

    --通知--广播跑马灯
    Event.AddListener(
        ApiMap.protos.PT_NotifyInfo,
        function(msg)
            Event.Broadcast(EventDefines.RadioChatEvent, msg)
        end
    )

    --玩家体力刷新
    Event.AddListener(
        ApiMap.protos.PT_UserEnergy,
        function(val)
            local userInfo = Model.GetMap(ModelType.User)
            userInfo.Energy = val.Energy
            userInfo.EnergyRefreshAt = val.EnergyRefreshAt
            Model.EnergyRecoverTick = val.EnergyRecoverTick
            Event.Broadcast(EventDefines.UIPlayerInfoExchange)
        end
    )
    --新手前程刷新名字
    Event.AddListener(
        ApiMap.protos.PT_NameModified,
        function(value)
            local userInfo = Model.GetMap(ModelType.User)
            userInfo.Name = value.NewName
            Event.Broadcast(EventDefines.UIPlayerInfoExchange)
        end
    )
    --通知-玩家总战斗力的值变更
    Event.AddListener(
        ApiMap.protos.PT_UserTotalPower,
        function(rsp)
            Event.Broadcast(EventDefines.UIPlayerPowerEffectShow, rsp)
            if Model.Player.Power < 10500 and rsp.Power >= 10500 then
                SdkModel.TrackBreakPoint(30001)
            end
            Model.Player.Power = rsp.Power
            Event.Broadcast(EventDefines.UIPlayerInfoExchange)
            AudioModel.Play(40012)
        end
    )
    --通知-玩家杀敌数刷新
    Event.AddListener(
        ApiMap.protos.PT_UserBeatEnemiesNotify,
        function(rsp)
            Model.Player.Kills = rsp.BeatEnemies
            Event.Broadcast(EventDefines.UIPlayerInfoExchange)
        end
    )

    --通知更新后玩家vip信息
    Event.AddListener(
        ApiMap.protos.PT_VipEventInfo,
        function(rsp)
            Event.Broadcast(EventDefines.UIVipInfo, rsp)
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_Wall,
        function(rsp)
            Model.InitOtherInfo(ModelType.Wall, rsp)
            Event.Broadcast(EventDefines.UIOnRefreshWall)
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_MapMatrixInfoRsp,
        function(rsp)
            if not WorldMap.Instance() then
                return
            end
            WorldMap.Instance():RefreshMap(rsp)
            WorldMap.Instance():RefreshMapObjects(rsp, false)
        end
    )

    --通知已完成主线任务
    Event.AddListener(
        ApiMap.protos.PT_AccomplishedMainTasks,
        function(rsp)
            print("AccomplishedRsp:------------------------------------------------", table.inspect(rsp))
            TaskModel:GetReplaceTaskData(rsp.Tasks)
            Event.Broadcast(EventDefines.UITipMainTaskMes, rsp)
            Event.Broadcast(EventDefines.UITaskMainRefresh)
            AudioModel.Play(40015)
            --已经完成
        end
    )

    --通知主线已解锁的任务
    Event.AddListener(
        ApiMap.protos.PT_UnlockedMainTasks,
        function(rsp)
            print("Unlock:------------------------------------------------", table.inspect(rsp))
            TaskModel:GetReplaceTaskData(rsp.Tasks)
            Event.Broadcast(EventDefines.UITipMainTaskMes, rsp)
            Event.Broadcast(EventDefines.UITaskMainRefresh)
        end
    )

    --通知推荐任务完结
    Event.AddListener(
        ApiMap.protos.PT_RecommedMainTaskOver,
        function()
            Log.Info("推荐任务完结:------------------------------------------------")
            TaskModel.ClearRecommendTask()
        end
    )

    --通知宝箱领取后宝箱进度
    Event.AddListener(
        ApiMap.protos.PT_UnlockedMainTask,
        function(rsp)
            -- Event.Broadcast(EventDefines.UIUnlockedMainTask, rsp)
            -- Event.Broadcast(EventDefines.UITaskRefreshRed)
            Event.Broadcast(EventDefines.UITaskMainRefresh)
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_Limit,
        function(rsp)
            Model.Update(ModelType.Limits, rsp.Category, rsp)
            Event.Broadcast(EventDefines.UIOnExpeditionLimitChange)
        end
    )

    local UnionInfoModel = import("Model/Union/UnionInfoModel")
    --联盟积分改变
    Event.AddListener(
        ApiMap.protos.PT_AllianceHonor,
        function(val)
            local info = UnionInfoModel.GetInfo()
            info.Honor = val.Amount
            Event.Broadcast(EventDefines.HonorChange)
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_InvestFinishInfo,
        function(val)
            Event.Broadcast(EventDefines.UIInvestFinishedAction, val)
        end
    )
    --野怪等级推送
    Event.AddListener(
        ApiMap.protos.PT_MaxMonsterLevel,
        function(val)
            Model.Player.MaxMonsterLevel = val.Level
        end
    )
    --玩家保护罩状态
    Event.AddListener(
        ApiMap.protos.PT_ProtectedAt,
        function(val)
            Event.Broadcast(EventDefines.ShieldAt, val)
        end
    )
    --全服保护罩消息，收到立即强制刷新当前地图消息
    Event.AddListener(
        ApiMap.protos.PT_ServerShield,
        function(val)
            if GlobalVars.IsInCity or not WorldMap.Instance() then
                return
            end
            WorldMap.Instance():ForceRefresh()
        end
    )
    --日常任务每天固定刷新
    Event.AddListener(
        ApiMap.protos.PT_DailyTaskRefresh,
        function(val)
            Event.Broadcast(EventDefines.DailyTaskRefreshAction, val.RefreshAt)
        end
    )

    --玩家升级推送
    Event.AddListener(
        ApiMap.protos.PT_HeroLevelUpInfo,
        function(val)
            Event.Broadcast(EventDefines.UIPlayerExpEffectShow, val)
            Model.Player.HeroLevel = val.HeroLevel
            Model.Player.HeroExp = val.Exp
            AudioModel.Play(40013)
            SdkModel.TrackBreakPoint(10077, math.ceil(val.HeroLevel)) --打点
            for _, v in pairs(val.SkillPoints) do
                SkillModel.UpdateSkillPoints(v.Points, v.Page)
            end
            Event.Broadcast(EventDefines.UIPlayerInfoExchange)
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_RandFlyCityLoc,
        function(val)
            Model.Player.X = val.X
            Model.Player.Y = val.Y
            Event.Broadcast(EventDefines.UITownMove, val)
            Event.Broadcast(EventDefines.UIOnMoveCity)
        end
    )

    --任务红点提示
    -- Event.AddListener(
    --     ApiMap.protos.PT_ActivityFinish,
    --     function(val)
    --         Event.Broadcast(EventDefines.WelfareFinishAction, val)
    --     end
    -- )
    --完成侦查任务通知
    Event.AddListener(
        ApiMap.protos.PT_AccomplishedInvestigationTask,
        function(msg)
            Event.Broadcast(EventDefines.UIWelfareDetectActvity, msg)
            if UIMgr:GetUIOpen("WelfareMain") then
                Event.Broadcast(EventDefines.DetectRefresh)
            end
        end
    )
    --侦查行动刷新
    Event.AddListener(
        ApiMap.protos.PT_InvestigationTaskRefresh,
        function(msg)
            Event.Broadcast(EventDefines.UIWelfareDetectActvity, msg)
            if UIMgr:GetUIOpen("WelfareMain") then
                Event.Broadcast(EventDefines.DetectRefresh)
            end
        end
    )

    --理财基金提示
    Event.AddListener(
        ApiMap.protos.PT_InvestFinishInfo,
        function(val)
            Event.Broadcast(EventDefines.InvestFinishAction, val)
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_AccomplishedAchievements,
        function(val)
            for _, v in ipairs(val.Achievements) do
                Model.Create(ModelType.AccomplishedAchievement, v.Id, v)
            end
            Event.Broadcast(EventDefines.GetNewAchievement)
        end
    )
    --通知-活动开启
    Event.AddListener(
        ApiMap.protos.PT_ActivityOpen,
        function(val)
            local isActivityCenter = ActivityModel.IsActivityById(val.ActivityId, ApiMap.protos.PT_ActivityOpen)
            if isActivityCenter then
                ActivityModel.SetActivityOpen(val)
            else
                WelfareModel.ActivityOpen(val.ActivityId)
                WelfareCuePointModel:CheckWelfarePoint()
                if UIMgr:GetUIOpen("WelfareMain") then
                    Event.Broadcast(EventDefines.WelfareRefreshUI)
                end
            end
            -- 猎鹰行动 主界面记录时间
            if (val.ActivityId == WelfareModel.WelfarePageType.FALCON_ACTIVITY) then
                Model.isFalconOpen = true
                Event.Broadcast(EventDefines.FalconOpen)
            elseif val.ActivityId == 1000501 then
                _G.RoyalModel.SetKingWarInfo()
                ActivityModel.SetRoyalBattleOpen(true)
                Event.Broadcast(EventDefines.RoyalBattleActivity)
            end
            Event.Broadcast(ACIIVI_EVENT.Open)
        end
    )
    --通知-有阶段的活动变更(比如限时比赛，单人活动)
    Event.AddListener(
        ApiMap.protos.PT_ActivityStageSwitch,
        function(val)
            local isActivityCenter = ActivityModel.IsActivityById(val.ActivityId, ApiMap.protos.PT_ActivityStageSwitch)
            if isActivityCenter then
                ActivityModel.SetActivityChange(val)
            end
            if val.ActivityId == 1001001 then
                --之前是阶段更新时刷新界面，现在逻辑改为如果在单人活动界面时则关闭活动界面
                Event.Broadcast(EventDefines.SingleActivityContentRefresh)
            end
        end
    )
    --通知-活动关闭
    Event.AddListener(
        ApiMap.protos.PT_ActivityClose,
        function(val)
            local isActivityCenter = ActivityModel.IsActivityById(val.ActivityId, ApiMap.protos.PT_ActivityClose)
            --刷新显示数据
            if isActivityCenter then
                ActivityModel.SetActivityClose(val)
            else
                WelfareModel.ActivityClose(val.ActivityId)
                --如果猎鹰活动关闭在引导过程直接抢关
                if val.ActivityId == WelfareModel.WelfarePageType.FALCON_ACTIVITY then
                    if GlobalVars.IsTriggerStatus and (GlobalVars.NowTriggerId == 15000 or GlobalVars.NowTriggerId == 15100) then
                        Event.Broadcast(EventDefines.ClearTrigger)
                    end
                end
                if UIMgr:GetUIOpen("WelfareMain") then
                    Event.Broadcast(EventDefines.WelfareRefreshUI)
                end
            end
            -- 猎鹰行动 主界面记录时间
            if (val.ActivityId == WelfareModel.WelfarePageType.FALCON_ACTIVITY) then
                if Model.MonsterVisitInfo and Model.MonsterVisitInfo[val.ActivityId] then
                    Model.MonsterVisitInfo[val.ActivityId].Avaliable = {}
                end
                Model.isFalconOpen = false
                Event.Broadcast(EventDefines.MapFalconMonster)
                Event.Broadcast(EventDefines.FalconOpen)
            elseif val.ActivityId == 1000501 then
                _G.RoyalModel.SetKingWarInfo()
                ActivityModel.SetRoyalBattleOpen(false)
                Event.Broadcast(EventDefines.RoyalBattleActivity)
            end
            Event.Broadcast(ACIIVI_EVENT.Close)
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_GodzillaOnlineBonusUnlocked,
        function(val)
            if ABTest.Kingkong_ABLogic() then
                Event.Broadcast(EventDefines.GozillzUnlockEvent, true)
            end
        end
    )
    --通知-探索奖品信息
    Event.AddListener(
        ApiMap.protos.PT_ExploreInfo,
        function(val)
            Event.Broadcast(EventDefines.UIExploreRewardInfo, val)
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_ExploreRewardInfo,
        function(val)
            Event.Broadcast(EventDefines.UIExploreRewardInfo, val)
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_ActiveSkillCoolDown,
        function(val)
            Event.Broadcast(EventDefines.UIActiveSkillRedMes, val)
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_BeastFinishCureRsp,
        function(val)
            Model.Delete(ModelType.BeastCureEvents, val.EventId)
            MonsterModel.RefreshMonsterHealth(val.BeastId, val.HealHealth, false)
            Event.Broadcast(EventDefines.UIBeastFinishCureRsp, val)
            for _, v in pairs(Model.Buildings) do
                if v.ConfId == Global.BuildingBeastHospital then
                    BuildModel.GetObject(v.Id):CureEnd(true)
                end
            end
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_AccomplishedPlotTasks,
        function(val)
            Event.Broadcast(EventDefines.UIAccomplishedPlotTasks, val)
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_UnlockedPlotTasks,
        function(val)
            Event.Broadcast(EventDefines.UIUnlockedPlotTasks, val)
        end
    )

    --发货成功
    Event.AddListener(
        ApiMap.protos.PT_PurchaseSuccess,
        function(msg)
            Event.Broadcast(SKUDETAIL_EVENT.Success, msg)
            if msg.Category == RCHARGE.Diamond then
                Event.Broadcast(EventDefines.RefreshDiamondData, msg.ConfId, true)
                TipUtil.TipById(50248)
            elseif msg.Category == RCHARGE.GiftPack then
                Event.Broadcast(EventDefines.PurchaseGiftSuccess, msg.ConfId)
            elseif msg.Category == RCHARGE.MonthlyPack then
                --激活月卡成功广播，不用再次更新月卡信息，况且信息结构还不是月卡信息的对应结构
                --Event.Broadcast(EventDefines.RefreshMonthData, {Id = msg.ConfId, IsActivated = true, RestTimes = 1})
            elseif msg.Category == RCHARGE.Fund then
                _G.Model.GrowthFundBought = true
                Event.Broadcast(EventDefines.GrowthFundPayed)
                Event.Broadcast(EventDefines.UIWelfareGrowthFund)
            --成长基金红点
            -- Event.Broadcast(EventDefines.RefreshGrowthFund)--成长基金页面刷新
            end
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_PlayerSiegeInfoRsp,
        function(msg)
            Event.Broadcast(EventDefines.UIRefreshBlackKnight, msg)
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_GodzillaOnlineBonusFinish,
        function()
            Event.Broadcast(EventDefines.UIGodzillaOnlineBonusFinish, true)
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_CallRallyMonsterRsp,
        function(msg)
            UIMgr:ClosePopAndTopPanel()
            Event.Broadcast(EventDefines.OpenWorldMap, msg.X, msg.Y)
        end
    )

    -- 通知-刷新礼包信息
    Event.AddListener(
        ApiMap.protos.PT_GiftPackInfos,
        function(msg)
            GiftModel.RefreshGiftPacks(msg.GiftPacks)
        end
    )

    -- 通知-开启礼包
    Event.AddListener(
        ApiMap.protos.PT_GiftGroupOpen,
        function(msg)
            local data = {
                GroupId = msg.GroupId,
                GiftId = msg.GiftId,
                CloseAt = msg.CloseAt
            }
            GiftModel.AddGift(data)
        end
    )

    -- 通知-关闭礼包
    Event.AddListener(
        ApiMap.protos.PT_GiftGroupClose,
        function(msg)
            GiftModel.RemoveGift(msg.GroupId)
        end
    )

    -- 通知-每日礼包可领取标记刷新
    Event.AddListener(
        ApiMap.protos.PT_EveryDayGiftRefresh,
        function(msg)
            GiftModel.SetDailyGiftFlag(false)
            GiftModel.SetDailyBonusFlag(true)
            Event.Broadcast(EventDefines.RefreshDailyGiftFlag)
        end
    )

    --月卡刷新数据
    Event.AddListener(
        ApiMap.protos.PT_CardInfo,
        function(msg)
            Event.Broadcast(EventDefines.UIMonthlyCardRed)
            Event.Broadcast(EventDefines.RefreshMonthData, msg)
        end
    )
    --钻石刷新
    Event.AddListener(
        ApiMap.protos.PT_GemPacksRefresh,
        function(msg)
            Event.Broadcast(EventDefines.RefreshDiamondData, msg.Id, false)
        end
    )

    --巨兽信息推送
    Event.AddListener(
        ApiMap.protos.PT_GiantBeast,
        function(msg)
            Model.Create(ModelType.GiantBeasts, msg.Id, msg)
            for _, v in pairs(Model.Buildings) do
                if v.ConfId == Global.BuildingBeastHospital then
                    BuildModel.GetObject(v.Id)._btnIcon:CheckInjuredArmy()
                end
            end
        end
    )

    -- 通知-成就解锁推送
    Event.AddListener(
        ApiMap.protos.PT_UnlockedAchievements,
        function(rsp)
            AchievementModel.SetUnlockData(rsp)
            Event.Broadcast(EventDefines.UnlockedAchievementUI, rsp)
        end
    )

    -- 通知-成就完成推送
    Event.AddListener(
        ApiMap.protos.PT_AccomplishedAchievements,
        function(rsp)
            AchievementModel.SetAccomplishedData(rsp)
            Event.Broadcast(EventDefines.AccomplishedAchievementsUI, rsp)
        end
    )

    -- 通知-福利中心 七日活动
    Event.AddListener(
        ApiMap.protos.PT_AccomplishedSevenDaysTasks,
        function(rsp)
            Event.Broadcast(EventDefines.UIWelfareRookieGrowth)
        end
    )
    -- 通知-福利中心 日常任务(上面)
    Event.AddListener(
        ApiMap.protos.PT_AccomplishedDailyAward,
        function(rsp)
            if rsp.IsAwardTaken == false then
                DailyTaskModel.AddRedAmount(1)
            end
            Event.Broadcast(EventDefines.UITaskRefreshRed)
            Event.Broadcast(EventDefines.RefreshDailyRed)
            Event.Broadcast(EventDefines.UIWelfareDailyTaskUp, rsp)
        end
    )
    -- 通知-福利中心 日常任务(下面)
    Event.AddListener(
        ApiMap.protos.PT_DailyTasksUnlockedOrAccomplished,
        function(rsp)
            Event.Broadcast(EventDefines.UIWelfareDailyTaskDown, rsp)
        end
    )
    -- 通知-福利中心 成长基金
    Event.AddListener(
        ApiMap.protos.PT_GrowthFundAwardInfo,
        function(rsp)
            Event.Broadcast(EventDefines.UIWelfareGrowthFund, rsp)
        end
    )
    -- 通知-福

    Event.AddListener(
        ApiMap.protos.PT_ActivityTaskRefresh,
        function(msg)
            Event.Broadcast(EventDefines.UIWelfareCasionMass, msg)
        end
    )
    -- 通知完成猎狐犬活动
    Event.AddListener(
        ApiMap.protos.PT_AccomplishedHuntFoxTask,
        function(msg)
            --刷新猎狐犬红点
            Event.Broadcast(EventDefines.UIWelfareHuntingFox)
            if UIMgr:GetUIOpen("WelfareMain") then
                Event.Broadcast(EventDefines.HuntingUIRefreshUI)
            end
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_UnlockedHuntFoxTask,
        function(msg)
            --刷新猎狐犬红点
            Event.Broadcast(EventDefines.UIWelfareHuntingFox)
            if UIMgr:GetUIOpen("WelfareMain") then
                Event.Broadcast(EventDefines.HuntingUIRefreshUI)
            end
        end
    )
    --刷新猎狐犬
    Event.AddListener(
        ApiMap.protos.PT_HuntFoxRefresh,
        function()
            --刷新猎狐犬红点
            Event.Broadcast(EventDefines.UIWelfareHuntingFox)
            if UIMgr:GetUIOpen("WelfareMain") then
                Event.Broadcast(EventDefines.HuntingUIRefreshUI)
            end
        end
    )
    --国旗日完成通知
    Event.AddListener(
        ApiMap.protos.PT_AccomplishedFlagDayDetectTask,
        function()
            Event.Broadcast(EventDefines.RefreshFlagDayRedData)
            if UIMgr:GetUIOpen("WelfareMain") then
                Event.Broadcast(EventDefines.MemorialDayRefresh)
            end
        end
    )
    --国旗日刷新
    Event.AddListener(
        ApiMap.protos.PT_FlagDayDetectTaskRefresh,
        function()
            Event.Broadcast(EventDefines.RefreshFlagDayRedData)
            if UIMgr:GetUIOpen("WelfareMain") then
                Event.Broadcast(EventDefines.MemorialDayRefresh)
            end
        end
    )
    --国旗日解锁
    Event.AddListener(
        ApiMap.protos.PT_UnlockedFlagDayDetectTask,
        function()
            Event.Broadcast(EventDefines.RefreshFlagDayRedData)
            if UIMgr:GetUIOpen("WelfareMain") then
                Event.Broadcast(EventDefines.MemorialDayRefresh)
            end
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_ProfitActivityUnlock,
        function(msg)
            WelfareModel.ActivityOpen(msg.Id)
            Log.Info("msg:-----------GrowthFund", table.inspect(msg))
            if UIMgr:GetUIOpen("WelfareMain") then
                Event.Broadcast(EventDefines.RefreshGrowthFund)
            end
        end
    )

    -- 新手保护罩变化通知
    Event.AddListener(
        ApiMap.protos.PT_RookieShieldChange,
        function(msg)
            Model.User.RookieShield = msg.Change
        end
    )

    --美女在线奖励解锁
    Event.AddListener(
        ApiMap.protos.PT_BeautyOnlineBonusUnlock,
        function()
            --执行通知事件,打开主界面得美女在线按钮
            Event.Broadcast(EventDefines.UnlockMainPanelBeauty, true)
            Event.Broadcast(EventDefines.RefreshMainUIBeauty, 1, Tool.Time() + GlobalMisc.GirlOnlineReward2[1])
        end
    )

    --美女在线奖励可以领取
    Event.AddListener(
        ApiMap.protos.PT_BeautyOnlineBonusAvaliable,
        function(msg)
            --执行通知事件
        end
    )
    --美女在线奖励初始化
    Event.AddListener(
        ApiMap.protos.PT_BeautyOnlineBonus,
        function(msg)
            --执行通知事件
        end
    )

    --美女好感度增加
    Event.AddListener(
        ApiMap.protos.PT_BeautyInfo,
        function(msg)
            Event.Broadcast(BEAUTY_GIRL_EVENT.FavorAdd, msg)
        end
    )

    --美女技能解锁
    Event.AddListener(
        ApiMap.protos.PT_BeautySkillUnlock,
        function(msg)
            Event.Broadcast(BEAUTY_GIRL_EVENT.UnlockSkill, msg)
        end
    )

    --美女服装解锁
    Event.AddListener(
        ApiMap.protos.PT_BeautyCostumeUnlock,
        function(msg)
            Event.Broadcast(BEAUTY_GIRL_EVENT.UnlockCostume, msg)
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_MapFlyCity,
        function(rsp)
            -- FromX: params.FromX,
            -- FromY: params.FromY,
            -- ToX:   params.ToX,
            -- ToY:   params.ToY,
            if GlobalVars.IsInCity then
                return
            end
            local oldPosNum = MathUtil.GetPosNum(rsp.FromX, rsp.FromY)
            local newPosNum = MathUtil.GetPosNum(rsp.ToX, rsp.ToY)
            Event.Broadcast(EventDefines.WorldMapBuildAnim, oldPosNum, newPosNum)
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_DailySearchTimes,
        function(val)
            Model.Player.SearchUsed = val.Times
            if GlobalVars.IsInCity then
                return
            end
            Event.Broadcast(EventDefines.UISearchTimeChange)
        end
    )

    -- 通知-全服加防御罩
    Event.AddListener(
        ApiMap.protos.PT_ServerShield,
        function(val)
            Model.ServerShield = val.ProtectedAt
            Model.ServerShieldStart = val.StartAt
        end
    )
    --请求刷新VIP商城
    Event.AddListener(
        ApiMap.protos.PT_VipShopRefresh,
        function(val)
            -- 如果是打开状态才刷新
            if UIMgr:GetUIOpen("VIPShopping") then
                UIMgr:Open("VIPShopping")
            end
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_DailySignRefresh,
        function(val)
            if WelfareModel.GetSelectedIndex() == WelfareModel.WelfarePageType.DAILY_ATTENDANCE then
                Event.Broadcast(EventDefines.RefreshDailyAttend)
            end
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_RookieSignRefresh,
        function()
            if WelfareModel.GetSelectedIndex() == WelfareModel.WelfarePageType.CUMULATIVE_ATTENDANCE then
                Event.Broadcast(EventDefines.RefreshDailyCumA)
            end
        end
    )

    -- 通知-战场Tip
    Event.AddListener(
        ApiMap.protos.PT_BattleTipInfo,
        function(rsp)
            local config = TipUtil.GetTipConfig(rsp.Id)
            local y = TipUtil.GetPos(config)
            if next(rsp.Avatar) then
                TipUtil.TipByContent(rsp.Title, rsp.Content, y, nil, rsp.Avatar[1], rsp.Avatar[2])
            else
                TipUtil.TipByContent(rsp.Title, rsp.Content, y, rsp.Icon)
            end
        end
    )

    --通知-使用主动技能通知
    Event.AddListener(
        ApiMap.protos.PT_SkillGetAllResInfo,
        function(rsp)
            Event.Broadcast(EventDefines.SkillGetResInfo, rsp)
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_CustomEvent,
        function(rsp)
            Log.Info(dump(rsp))
            -- Name: int32
            -- CreatedAt: int64
            -- FinishAt: int64
            -- Finished: bool
            -- ClientProcessed: bool
            CustomEventManager.RefreshCustormEvent()
        end
    )
    --刷新自定义事件信息
    Event.AddListener(
        ApiMap.protos.PT_CustomEvents,
        function(rsp)
            for _, v in pairs(rsp) do
                CustomEventManager.RefreshCustormEvent(v)
            end
        end
    )

    --第三周活动获得宝箱通知,并且更新次数
    Event.AddListener(
        ApiMap.protos.PT_MemorialDayTreasure,
        function(rsp)
            Event.Broadcast(EventDefines.MemoryActivityEffectShow, rsp)
            --更新次数
            ActivityModel.RefreshMemoryTimesInfo(rsp)
        end
    )

    --第三周活动通知次数
    Event.AddListener(
        ApiMap.protos.PT_MemorialDayInfos,
        function(rsp)
            --更新次数
            --ActivityModel.MemoryTimesInfo = rsp.Infos
            _G.Model.MemorialDayInfos = rsp
        end
    )

    --军备竞技获得宝箱通知,并且更新次数
    Event.AddListener(
        ApiMap.protos.PT_ArmsRaceTreasure,
        function(rsp)
            Event.Broadcast(EventDefines.MemoryActivityEffectShow, rsp)
            --更新次数
            ActivityModel.RefreshArmsRaceTimesInfo(rsp)
        end
    )

    --军备竞技通知次数
    Event.AddListener(
        ApiMap.protos.PT_ArmsRaceInfos,
        function(rsp)
            --更新次数
            _G.Model.ArmsRaceInfos = rsp
        end
    )

    -- 狩猎活动数据刷新
    Event.AddListener(
        ApiMap.protos.PT_EagleHuntInfo,
        function(rsp)
            -- print("PT_EagleHuntInfoParams rsp ======================" .. table.inspect(rsp))
            Model.EagleHuntInfos = rsp
            Event.Broadcast(EventDefines.UIFalconDetectActvity)
            Event.Broadcast(EventDefines.FalconInfoEvent)
        end
    )

    -- 狩猎科技推送
    Event.AddListener(
            ApiMap.protos.PT_HuntTechGift,
            function(rsp)
                print("PT_HuntTechGift rsp ======================" .. table.inspect(rsp))
                 local value = {}
                 value.X = rsp.X
                 value.Y = rsp.Y
                 value.TechId = rsp.TechId
                Event.Broadcast(EventDefines.FalconGetTech,value)
                -- print("PT_HuntHelicopter Model.HuntHelicopters ======================" .. table.inspect(Model.HuntHelicopters))
            end
    )

    -- 狩猎活动数据刷新
    Event.AddListener(
        ApiMap.protos.PT_HuntHelicopter,
        function(rsp)
            -- print("PT_HuntHelicopter rsp ======================" .. table.inspect(rsp))
            local isFound = false
            if (Model.HuntHelicopters and #Model.HuntHelicopters > 0) then
                for i = 1, #Model.HuntHelicopters do
                    if (Model.HuntHelicopters[i].Id == rsp.Id) then
                        isFound = true
                        Model.HuntHelicopters[i] = rsp
                    end
                end
            end
            if (isFound == false) then
                table.insert(Model.HuntHelicopters, rsp)
            end
            -- print("PT_HuntHelicopter Model.HuntHelicopters ======================" .. table.inspect(Model.HuntHelicopters))
        end
    )
    --长留基金刷新
    Event.AddListener(
        ApiMap.protos.PT_GemFundRefresh,
        function()
            Log.Info("============>>>>>在线开启活动")
            --界面刷新
            Event.Broadcast(EventDefines.DiamondsFundPriceRefresh)
            --提示点刷新
            Event.Broadcast(EventDefines.UIWelfareGemFund)
        end
    )

    --通知-战报分享收费计数归零
    Event.AddListener(
        ApiMap.protos.PT_FlushChatShareTimes,
        function()
            Model.ChatShareTimes = 0
        end
    )

    --单人活动获得奖励通知
    Event.AddListener(
        ApiMap.protos.PT_IndividualEventStageBonus,
        function()
            GlobalVars.IsOpenSingleScoreTips = true
            --UIMgr:Open("SingleActivityGetRewardTips")
        end
    )
    --换装 装备槽更改通知
    Event.AddListener(
        ApiMap.protos.PT_EquipSlotInfo,
        function(partInfo)
            EquipModel.UpdateEquipPartInfo(partInfo)
            Event.Broadcast(EventDefines.RefreshEquipInfo)
        end
    )
    --换装 装备锁定 装备信息刷新
    Event.AddListener(
        ApiMap.protos.PT_UpdateEquipInfo,
        function(equipInfo)
            EquipModel.UpdateEquipInfo(equipInfo)
            Event.Broadcast(EventDefines.RefreshEquipInfo)
        end
    )
    --刷新装备材料
    Event.AddListener(
        ApiMap.protos.PT_UpdateJewelInfos,
        function(rsp)
            EquipModel.AddJewelBag(rsp.JewelList)
            Event.Broadcast(EventDefines.RefreshEquipInfo)
        end
    )
    --装备交易完成可领取
    Event.AddListener(
        ApiMap.protos.PT_EquipEventFinishRsp,
        function(rsp)
            Event.Broadcast(EventDefines.EquipEventFinish, rsp.EventId)
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_DelteEquip,
        function(rsp)
            local i = Model
            for _, v in pairs(rsp.EquipList) do
                EquipModel.DelEquip(v)
            end
        end
    )

    --装备材料制造完成推送
    Event.AddListener(
        ApiMap.protos.PT_JewelMakeInfo,
        function(rsp)
            Model.InitOtherInfo(ModelType.JewelMakeInfo, rsp)

            local buildId = BuildModel.GetObjectByConfid(Global.BuildingEquipMaterialFactory)
            local node = BuildModel.GetObject(buildId)
            if node then
                --刷新建筑倒计时条
                node:ResetCD()
            end
        end
    )

    Event.AddListener(
        ApiMap.protos.PT_RechargeLotteryTimesChange,
        function(msg)
            Event.Broadcast(TURNTABLE_EVENT.TimesChange, msg)
        end
    )

    --通知-王位战活动信息（暂时没）
    Event.AddListener(
        ApiMap.protos.PT_KingInfo,
        function(msg)
            _G.RoyalModel.UpdataKingInfo(msg)
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_CannonAttack,
        function(msg)
            Event.Broadcast(EventDefines.RoyalDartFly, msg)
        end
    )
    --通知-王位战信息
    Event.AddListener(
        ApiMap.protos.PT_GetKingWarInfoRsp,
        function(msg)
            _G.RoyalModel.GetKingWarInfoRsp(msg)
        end
    )
    Event.AddListener(
        ApiMap.protos.PT_FakeMission,
        function(msg)
            Model.InitOtherInfo(ModelType.BattleCareInfo, msg)
            Event.Broadcast(EventDefines.CareSystemMarchAnim)
        end
    )
    -- 通知-在线奖励跨天刷新
    Event.AddListener(
        ApiMap.protos.PT_OnlineBonus,
        function(rsp)
            Event.Broadcast(EventDefines.OnlineBonusInfoRefresh, rsp)
        end
    )

    -- 通知-切换装扮
    Event.AddListener(ApiMap.protos.PT_DressUpUsingAll, function(msg)
        local dressUpType = msg.Using[1].DressType
        DressUpModel.ClearDressUpItemInfo(dressUpType)
        DressUpModel.RefreshUsingDressUp(msg.Using[1])
        Event.Broadcast(DRESSUP_EVENT.ChangeDressUp, dressUpType)
    end)

    ----------------------战机系统相关推送----------------------
    --零件更新，零件状态变更和新增都会推送
    Event.AddListener(
        ApiMap.protos.PT_UpdatePartInfos,
        function(msg)
            PlaneModel.UpdataPartInfos(msg.UpdateList)
            Event.Broadcast(EventDefines.UpdataPartInfos)
        end
    )
    --零件删除
    Event.AddListener(
        ApiMap.protos.PT_DeltePart,
        function(msg)
            PlaneModel.DelPartInfos(msg.DelList)
            Event.Broadcast(EventDefines.UpdataPartInfos)
        end
    )
    --飞机状态更新，解锁、启动、零件的拆卸状态都会推送
    Event.AddListener(
        ApiMap.protos.PT_UpdatePlane,
        function(msg)
            PlaneModel.UpdataPlaneInfos(msg)
            Event.Broadcast(EventDefines.UpdatePlaneInfo)
        end
    )
end

return NetEvents
