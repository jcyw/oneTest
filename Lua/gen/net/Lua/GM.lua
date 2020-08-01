Net.GM = {}

-- 请求-GM添加资源
function Net.GM.AddAllRes(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddAllResParams", fields, ...)
end

-- 请求-GM添加钻石
function Net.GM.AddGem(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddGemParams", fields, ...)
end

-- 请求-清理账号
function Net.GM.CleanAccount(...)
    local fields = {
        "Username", -- string
    }
    Network.RequestDynamic("GMCleanAccountParams", fields, ...)
end

-- 请求-添加士兵
function Net.GM.AddArmies(...)
    local fields = {
        "ConfId", -- int32
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddArmiesParams", fields, ...)
end

-- 请求-添加道具
function Net.GM.AddItems(...)
    local fields = {
        "UserId", -- string
    }
    Network.RequestDynamic("GMAddItemsParams", fields, ...)
end

-- 请求-立即完成事件
function Net.GM.Speedup(...)
    local fields = {
        "UserId", -- string
        "EventId", -- string
    }
    Network.RequestDynamic("GMSpeedupParams", fields, ...)
end

-- 请求-添加测试邮件
function Net.GM.AddMails(...)
    local fields = {
        "UserId", -- string
    }
    Network.RequestDynamic("GMAddMailsParams", fields, ...)
end

-- 请求-清理道具
function Net.GM.ClearItems(...)
    local fields = {
        "UserId", -- string
    }
    Network.RequestDynamic("GMClearItemsParams", fields, ...)
end

-- 请求-清理道具
function Net.GM.AddItem(...)
    local fields = {
        "ConfId", -- int32
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddItemParams", fields, ...)
end

-- 请求-删除测试邮件
function Net.GM.ClearMails(...)
    local fields = {
        "UserId", -- string
    }
    Network.RequestDynamic("GMClearMailsParams", fields, ...)
end

-- 请求-城墙着火
function Net.GM.OnFire(...)
    local fields = {
        "UserId", -- string
    }
    Network.RequestDynamic("GMWallOnFireParams", fields, ...)
end

-- 请求-重置军需站
function Net.GM.ResetMS(...)
    local fields = {
        "UserId", -- string
    }
    Network.RequestDynamic("GMResetMSParams", fields, ...)
end

-- 请求-添加攻击预警
function Net.GM.AddWarnings(...)
    local fields = {
        "UserId", -- string
    }
    Network.RequestDynamic("GMAddWarningParams", fields, ...)
end

-- 请求-添加联盟活跃
function Net.GM.AddAllianceActive(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddAllianceActiveParams", fields, ...)
end

-- 请求-添加联盟贡献
function Net.GM.AddAllianceContribution(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddAllianceContributionParams", fields, ...)
end

-- 请求-重置联盟
function Net.GM.ResetAllianceDaily(...)
    local fields = {
        "UserId", -- string
    }
    Network.RequestDynamic("GMResetAllianceDailyParams", fields, ...)
end

-- 请求-添加联盟荣誉
function Net.GM.AddAllianceHonor(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddAllianceHonorParams", fields, ...)
end

-- 请求-请求任务加速
function Net.GM.SpeedupHelpTask(...)
    local fields = {
        "TaskId", -- string
    }
    Network.RequestDynamic("GMSpeedupHelpTaskParams", fields, ...)
end

-- 请求-添加联盟礼包
function Net.GM.AddAllianceItems(...)
    local fields = {
        "UserId", -- string
    }
    Network.RequestDynamic("GMAddAllianceItemsParams", fields, ...)
end

-- 请求-加入联盟排行榜
function Net.GM.JoinAllianceContriRank(...)
    local fields = {
        "ChangeScore", -- int32
    }
    Network.RequestDynamic("GMJoinAllianceContriRankParams", fields, ...)
end

-- 请求-联盟科技捐献值最大
function Net.GM.AllianceTechContriMax(...)
    local fields = {
        "TechId", -- string
    }
    Network.RequestDynamic("GMAllianceTechContriMax", fields, ...)
end

-- 请求-添加所有建筑
function Net.GM.AddAllBuilding(...)
    local fields = {
        "UserId", -- string
        "Level", -- int32
    }
    Network.RequestDynamic("GMAddAllBuildingParams", fields, ...)
end

-- 请求-添加伤兵
function Net.GM.AddInjured(...)
    local fields = {
        "ConfId", -- int32
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddInjuredParams", fields, ...)
end

-- 请求-建造联盟建筑
function Net.GM.BuildAllianceBuilding(...)
    local fields = {
        "ConfId", -- int32
        "X", -- int32
        "Y", -- int32
    }
    Network.RequestDynamic("GMBuildAllianceBuildingParams", fields, ...)
end

-- 请求-建好联盟建筑
function Net.GM.CompleteAllianceBuilding(...)
    local fields = {
        "ConfId", -- int32
        "X", -- int32
        "Y", -- int32
    }
    Network.RequestDynamic("GMCompleteAllianceBuildingParams", fields, ...)
end

-- 请求-联盟投票时间立刻结束
function Net.GM.CompleteAllianceVote(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("GMCompleteAllianceVoteParams", fields, ...)
end

-- 请求-增加vip积分
function Net.GM.AddVipPoints(...)
    local fields = {
        "Points", -- int32
    }
    Network.RequestDynamic("GMAddVipPointsParams", fields, ...)
end

-- 请求-改变服务器时间
function Net.GM.SetTime(...)
    local fields = {
        "Seconds", -- int32
    }
    Network.RequestDynamic("GMChangeTimeParams", fields, ...)
end

-- 请求-获取服务器时间
function Net.GM.GetTime(...)
    Network.RequestDynamic("GMGetServerTimeParams", {}, ...)
end

-- 请求-改变用户vip时间
function Net.GM.ChangeVipDuration(...)
    local fields = {
        "Seconds", -- int32
    }
    Network.RequestDynamic("GMChangeVipDuration", fields, ...)
end

-- 请求-一键补满防御武器至容量上限
function Net.GM.AddDefenceWeaponsToLimit(...)
    Network.RequestDynamic("GMAddDefenceWeaponsToLimit", {}, ...)
end

-- 请求-添加联盟动态
function Net.GM.AddAllianceNews(...)
    Network.RequestDynamic("GMAddAllianceNewsParams", {}, ...)
end

-- 请求-清空聊天
function Net.GM.CleanChat(...)
    Network.RequestDynamic("GMCleanChatParams", {}, ...)
end

-- 请求-联盟科技等级最大
function Net.GM.AllianceTechLevelUp(...)
    local fields = {
        "TechId", -- string
        "Max", -- bool
    }
    Network.RequestDynamic("GMAllianceTechLevelUp", fields, ...)
end

-- 请求-游戏内购买钻石
function Net.GM.GMInAppPurchaseGem(...)
    local fields = {
        "ConfId", -- int32
    }
    Network.RequestDynamic("GMInAppPurchaseGemParams", fields, ...)
end

-- 请求-添加玩家英雄经验
function Net.GM.GMAddHeroExp(...)
    local fields = {
        "Exp", -- int64
    }
    Network.RequestDynamic("GMAddHeroExpParams", fields, ...)
end

-- 请求-打印地块信息
function Net.GM.GMGetTileInfo(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GMGetTileInfoParams", fields, ...)
end

-- 请求-添加联盟积分
function Net.GM.AddAllianceHonorScore(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddAllianceHonorScoreParams", fields, ...)
end

-- 请求-添加联盟成员
function Net.GM.AddAllianceMembers(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddAllianceMembersParams", fields, ...)
end

-- 请求-添加联盟战力
function Net.GM.AddAlliancePower(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddAlliancePowerParams", fields, ...)
end

-- 请求-发送公告
function Net.GM.SendNotify(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMSendNotifyParams", fields, ...)
end

-- 请求-解锁所有技能
function Net.GM.UnlockSkill(...)
    Network.RequestDynamic("GMUnlockSkillParams", {}, ...)
end

-- 请求-设置城墙耐久
function Net.GM.SetDurable(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMWallSetDurableParams", fields, ...)
end

-- 请求-添加联盟战争记录
function Net.GM.AddBattleLog(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddBattleLogParams", fields, ...)
end

-- 请求-刷新排行榜
function Net.GM.RefreshRankList(...)
    Network.RequestDynamic("GMRefreshRankListParams", {}, ...)
end

-- 请求-指定建筑升级
function Net.GM.AddBuilding(...)
    local fields = {
        "BuildingId", -- int32
        "Level", -- int32
    }
    Network.RequestDynamic("GMAddBuildingParams", fields, ...)
end

-- 请求-完成任务
function Net.GM.FinishTask(...)
    local fields = {
        "Category", -- int32
        "Id", -- int32
    }
    Network.RequestDynamic("GMFinishTaskParams", fields, ...)
end

-- 请求-完成区间内的任务
function Net.GM.FinishTasksInSection(...)
    local fields = {
        "StartId", -- int32
        "EndId", -- int32
    }
    Network.RequestDynamic("GMFinishTasksInSectionParams", fields, ...)
end

-- 请求-断开连接
function Net.GM.CloseConn(...)
    Network.RequestDynamic("GMCloseConnParams", {}, ...)
end

-- 请求-刷新每日任务
function Net.GM.RefreshDailyTasks(...)
    Network.RequestDynamic("GMRefreshDailyTasksParams", {}, ...)
end

-- 请求-冷却所有主动技能
function Net.GM.CooldownSkills(...)
    Network.RequestDynamic("GMCooldownSkillsParams", {}, ...)
end

-- 请求-城墙耐久变为1
function Net.GM.BreakTheWall(...)
    Network.RequestDynamic("GMWallIsBrokenParams", {}, ...)
end

-- 请求-开服
function Net.GM.AddServer(...)
    local fields = {
        "Id", -- string
        "Name", -- string
    }
    Network.RequestDynamic("GMAddServerParams", fields, ...)
end

-- 请求-切服
function Net.GM.EnterServer(...)
    local fields = {
        "Id", -- string
    }
    Network.RequestDynamic("GMEnterServerParams", fields, ...)
end

-- 请求-一键升级所有科技
function Net.GM.AddAllTechs(...)
    Network.RequestDynamic("GMAddAllTechsParams", {}, ...)
end

-- 请求-减少巨兽的生命值
function Net.GM.ReduceBeastHealth(...)
    local fields = {
        "Id", -- int32
        "Health", -- int32
    }
    Network.RequestDynamic("GMReduceBeastHealthParams", fields, ...)
end

-- 请求-解锁成长基金
function Net.GM.UnlockGrowthFund(...)
    Network.RequestDynamic("GMUnlockGrowthFundParams", {}, ...)
end

-- 请求-按推荐任务顺序完成主线任务
function Net.GM.FinishRecommendedMainTasks(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GMFinishRecommendedMainTasksParams", fields, ...)
end

-- 请求-结算黑骑士
function Net.GM.SumSiege(...)
    Network.RequestDynamic("GMSumSiegeParams", {}, ...)
end

-- 请求-一键领取所有主线任务奖励
function Net.GM.GetAllMainTaskAwards(...)
    Network.RequestDynamic("GMGetAllMainTaskAwardsParams", {}, ...)
end

-- 请求-按任务顺序完成普通主线任务
function Net.GM.FinishCommonMainTasks(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GMFinishCommonMainTasksParams", fields, ...)
end

-- 请求-完成当前章节的任务
function Net.GM.FinishCurChapterTasks(...)
    Network.RequestDynamic("GMFinishCurChapterTasksParams", {}, ...)
end

-- 请求-调整七日活动完成的任务的数量
function Net.GM.ChangeFinishedSevenDayTaskAmount(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMChangeFinishedSevenDayTaskAmountParams", fields, ...)
end

-- 请求-发送订单购买成功的消息
function Net.GM.PurchaseSuccess(...)
    local fields = {
        "Id", -- int32
        "Category", -- int32
    }
    Network.RequestDynamic("GMPurchaseSuccessParams", fields, ...)
end

-- 请求-清除月卡信息
function Net.GM.DeleteCard(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GMDeleteCardParams", fields, ...)
end

-- 请求-添加指挥官技能点
function Net.GM.AddHeroSkillPoints(...)
    local fields = {
        "Points", -- int32
    }
    Network.RequestDynamic("GMAddHeroSkillPointsParams", fields, ...)
end

-- 请求-完成指定赌场集结任务
function Net.GM.FinishActivityTask(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GMFinishActivityTaskParams", fields, ...)
end

-- 请求-将指定月卡的过期时间改为现在时间的5天之后
function Net.GM.ChangeCardExpiryTime(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("GMChangeCardExpiryTimeParams", fields, ...)
end

-- 请求-增加当前阶段之前的限时比赛积分
function Net.GM.AddLimitTimesMatchScore(...)
    local fields = {
        "Score", -- int32
    }
    Network.RequestDynamic("GMAddLimitTimeStageScoreParams", fields, ...)
end

-- 请求-玩家破除自己的保护罩
function Net.GM.BreakShield(...)
    Network.RequestDynamic("GMBreakShieldParams", {}, ...)
end

-- 请求-设置礼包组开关状态
function Net.GM.SetGiftGroupInfo(...)
    local fields = {
        "GroupId", -- int32
        "Days", -- int32
    }
    Network.RequestDynamic("GMSetGiftGroupInfoParams", fields, ...)
end

-- 请求-改变礼包组关闭时间
function Net.GM.CloseGiftGroup(...)
    local fields = {
        "GroupId", -- int32
    }
    Network.RequestDynamic("GMCloseGiftGroupParams", fields, ...)
end

-- 请求-结束新手期
function Net.GM.EndNewbiePeriod(...)
    Network.RequestDynamic("GMEndNewbiePeriodParams", {}, ...)
end

-- 请求-改变玩家体力
function Net.GM.ChangeEnergy(...)
    local fields = {
        "Num", -- int32
    }
    Network.RequestDynamic("GMChangeEnergyParams", fields, ...)
end

-- 请求-黑骑士攻击
function Net.GM.SiegeAttack(...)
    Network.RequestDynamic("GMSiegeAttackParams", {}, ...)
end

-- 请求-触发充值任务
function Net.GM.TriggerRechargeTask(...)
    Network.RequestDynamic("GMTriggerRechargeTaskParams", {}, ...)
end

-- 请求-全服保护罩
function Net.GM.AddServerShield(...)
    Network.RequestDynamic("GMServerShieldParams", {}, ...)
end

-- 请求-移除全服保护罩
function Net.GM.RemoveServerShield(...)
    Network.RequestDynamic("GMRemoveServerShieldParams", {}, ...)
end

-- 请求-回收基地
function Net.GM.RecoverBase(...)
    Network.RequestDynamic("GMRecoverBaseParams", {}, ...)
end

-- 请求-增加美女好感度
function Net.GM.AddBeautyFavor(...)
    local fields = {
        "Value", -- int32
    }
    Network.RequestDynamic("GMAddBeautyFavorParams", fields, ...)
end

-- 请求-增加玫瑰
function Net.GM.AddRose(...)
    local fields = {
        "Value", -- int32
    }
    Network.RequestDynamic("GMAddRoseParams", fields, ...)
end

-- 请求-测试日志
function Net.GM.LogTest(...)
    Network.RequestDynamic("GMLogTestParams", {}, ...)
end

-- 请求-侦查活动增加完成次数
function Net.GM.InvestigationAddProcess(...)
    local fields = {
        "Process", -- int32
    }
    Network.RequestDynamic("GMInvestigationAddProcessParams", fields, ...)
end

-- 请求-发送玩家单人活动排名奖励
function Net.GM.PlayerIndiEventStageRankSum(...)
    local fields = {
        "Rank", -- int32
        "RankNum", -- int32
    }
    Network.RequestDynamic("GMIndiEventStageRankSumParams", fields, ...)
end

-- 请求-GM添加X资源
function Net.GM.GMAddXRes(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddXParams", fields, ...)
end

-- 请求-添加宝石
function Net.GM.GMAddJewel(...)
    local fields = {
        "JewelId", -- int32
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddJewel", fields, ...)
end

-- 请求-添加装备
function Net.GM.GMAddEquip(...)
    local fields = {
        "EquipId", -- int32
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddEquip", fields, ...)
end

-- 请求-添加所有宝石每种加N个
function Net.GM.GMAddAllJewel(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddAllJewel", fields, ...)
end

-- 请求-添加所有装备每种装备添加N个
function Net.GM.GMAddAllEquip(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddAllEquip", fields, ...)
end

-- 请求-发送强更邮件
function Net.GM.GMAddForceUpdateMails(...)
    Network.RequestDynamic("GMAddForceUpdateMails", {}, ...)
end

-- 请求-立即发送新城竞赛排名邮件
function Net.GM.GMSendNewWarZoneRankEmail(...)
    local fields = {
        "Period", -- int32
        "Type", -- int32
        "Rank", -- int32
    }
    Network.RequestDynamic("GMSendNewWarZoneRankEmailParams", fields, ...)
end

-- 请求-成为国王
function Net.GM.BecomeKing(...)
    Network.RequestDynamic("GMBecomeKingParams", {}, ...)
end

-- 请求-王位战占领结束
function Net.GM.PeaceContract(...)
    Network.RequestDynamic("GMWarEndParams", {}, ...)
end

-- 请求-重置王位战
function Net.GM.ResetKingdomEvent(...)
    Network.RequestDynamic("GMResetKingdomEventParams", {}, ...)
end

-- 请求-竞技场获取指定排名奖励
function Net.GM.GetArenRankAwards(...)
    local fields = {
        "Rank", -- int32
    }
    Network.RequestDynamic("GMGetArenRankAwardsParams", fields, ...)
end

-- 请求-GM添加战争劵
function Net.GM.GMAddWarRoll(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddWarRoll", fields, ...)
end

-- 请求-添加飞机零件
function Net.GM.GMAddPart(...)
    local fields = {
        "PartId", -- int32
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddPart", fields, ...)
end

-- 请求-解锁需要解锁的飞机
function Net.GM.GMUnlockPlane(...)
    local fields = {
        "PlaneId", -- int32
    }
    Network.RequestDynamic("GMUnlockPlane", fields, ...)
end

-- 请求-添加所有飞机零件每种加N个
function Net.GM.GMAddAllJPart(...)
    local fields = {
        "Amount", -- int32
    }
    Network.RequestDynamic("GMAddAllJPart", fields, ...)
end

-- 请求-解锁所有需要解锁的飞机
function Net.GM.GMUnlockAllPlane(...)
    Network.RequestDynamic("GMUnlockAllPlane", {}, ...)
end

return Net.GM