-- author:{Amu}
-- time:2019-05-22 17:22:25

SET_TYPE = {}
SET_TYPE.SoundVolume    = 1    --音量
SET_TYPE.GoTo           = 2    --前往
SET_TYPE.Open           = 3    --开启
SET_TYPE.Clear          = 4    --清理


RCHARGE = {}          --充值
RCHARGE.Diamond     = Global.PurchaseTypeGem        --购买砖石  -- 钻石|configDiamond
RCHARGE.GiftPack    = Global.PurchaseTypeGift       --购买礼包    --礼包|configGiftPack  --礼包组|configGiftGroup
RCHARGE.MonthlyPack = Global.PurchaseTypeCard       --购买月卡    --月卡|configMonthlyPack
RCHARGE.Fund        = Global.PurchaseTypeFund       --购买基金    --基金|configFund


ITEM_TYPE = {} --物品类型
ITEM_TYPE.Item = 1 --道具
ITEM_TYPE.Gift = 2 --礼物
ITEM_TYPE.Res = 3 --资源

REWARD_TYPE = {} --奖励类型
REWARD_TYPE.Res = ConfigMgr.GetVar("RewardTypeRes") --资源类
REWARD_TYPE.Item = ConfigMgr.GetVar("RewardTypeItem") --道具类
REWARD_TYPE.Gift = ConfigMgr.GetVar("RewardTypeGift") --礼包类
REWARD_TYPE.Tech = ConfigMgr.GetVar("RewardTypeTech") --科技类

-------资源种类
RES_TYPE = {}
RES_TYPE.Wood = ConfigMgr.GetVar("ResWood") --木材 = 钢铁
RES_TYPE.Stone = ConfigMgr.GetVar("ResStone") --石头 = 稀土矿
RES_TYPE.Iron = ConfigMgr.GetVar("ResIron") --钢铁 = 石油
RES_TYPE.Food = ConfigMgr.GetVar("ResFood") --粮食 = 食品
RES_TYPE.Diamond = ConfigMgr.GetVar("ResDiamond") --砖石
RES_TYPE.UnionHonor = ConfigMgr.GetVar("ResAllianceHonor") --联盟荣誉
RES_TYPE.UnionCredit = ConfigMgr.GetVar("ResAlliancePoint") --联盟积分
RES_TYPE.Res4Equip = ConfigMgr.GetVar("Res4Equip") --芯片

--资源解锁 所需基地等级
RES_LOCK = {}
RES_LOCK[RES_TYPE.Wood] = ConfigMgr.GetVar("ResIronSupply") --木材 = 钢铁
RES_LOCK[RES_TYPE.Stone] = ConfigMgr.GetVar("ResMineralSupply") --石头 = 稀土矿
RES_LOCK[RES_TYPE.Iron] = ConfigMgr.GetVar("ResOilSupply") --钢铁 = 石油
RES_LOCK[RES_TYPE.Food] = ConfigMgr.GetVar("ResFoodSupply") --粮食 = 食品
RES_LOCK[RES_TYPE.Res4Equip] = ConfigMgr.GetVar("ResEquipCoinSupply") --芯片

QUALITY_COLOR = {
    ConfigMgr.GetVar("ResIronSupply"),
    ConfigMgr.GetVar("ResIronSupply"),
    ConfigMgr.GetVar("ResIronSupply"),
    ConfigMgr.GetVar("ResIronSupply"),
    ConfigMgr.GetVar("ResIronSupply")
}

-------建筑头上Tips种类
TIPS_TYPE = {}
TIPS_TYPE.Res = 1 --收获资源
TIPS_TYPE.Cure = 2 --治疗

-------邮件Panel
MAIL_SPANEL = {}
MAIL_SPANEL.Mail_Main = nil
MAIL_SPANEL.Mail_News = nil
MAIL_SPANEL.Mail_StarLogo = nil

MAIL_SHOWTYPE = {} --邮件展示方式
MAIL_SHOWTYPE.Normal = 1 -- 普通
MAIL_SHOWTYPE.Shere = 2 -- 分享

-------邮件种类
MAIL_TYPE = {}
MAIL_TYPE.Collecat = ConfigMgr.GetVar("MailTypeMineReport") --采矿报告
MAIL_TYPE.PVEReport = ConfigMgr.GetVar("MailTypeMonsterReport") --进攻野怪战报
MAIL_TYPE.System = ConfigMgr.GetVar("MailTypeSystem") --系统邮件
MAIL_TYPE.Activity = ConfigMgr.GetVar("MailTypeActivity") --活动邮件
MAIL_TYPE.PVPReport = ConfigMgr.GetVar("MailTypeReport") --战报
MAIL_TYPE.Alliance = ConfigMgr.GetVar("MailTypeAlliance") --联盟邮件
MAIL_TYPE.Msg = ConfigMgr.GetVar("MailTypeMsg") --对话邮件
MAIL_TYPE.Studio = ConfigMgr.GetVar("MailTypeStudio") --工作室邮件
MAIL_TYPE.Favorite = ConfigMgr.GetVar("MailTypeStar") --收藏邮件
MAIL_TYPE.NPCAttack = ConfigMgr.GetVar("MailTypeNPCAttackReport") --NPC攻城战报
MAIL_TYPE.Sports = ConfigMgr.GetVar("MailTypeSports") --竞技场邮件

-------邮件子类型
MAIL_SUBTYPE = {}
MAIL_SUBTYPE.subPVPReport = ConfigMgr.GetVar("MailSubTypePvP") --pve
MAIL_SUBTYPE.subTypeAttackFailure = ConfigMgr.GetVar("MailSubTypeAttackFailure") --进攻大败
MAIL_SUBTYPE.subScoutReport = ConfigMgr.GetVar("MailSubTypeSpy") --侦察
MAIL_SUBTYPE.subBeScoutReport = ConfigMgr.GetVar("MailSubTypeUnderSpy") --被侦察
MAIL_SUBTYPE.subScoutFailReport = ConfigMgr.GetVar("MailSubTypeSpyFail") --侦察失败
MAIL_SUBTYPE.subexploreReport = ConfigMgr.GetVar("MailSubTypeSecretBase")  --秘密基地搜索报告
MAIL_SUBTYPE.subOrderReport = ConfigMgr.GetVar("MailSubTypeAllianceOrder") --联盟指令
MAIL_SUBTYPE.subAllianceAssistRes = ConfigMgr.GetVar("MailSubTypeAllianceAssistRes") --援助资源
MAIL_SUBTYPE.subAllianceAssistArmies = ConfigMgr.GetVar("MailSubTypeAllianceAssistArmies") --援助士兵
MAIL_SUBTYPE.subAllianceInvite = ConfigMgr.GetVar("MailSubTypeAllianceInvite") --入盟邀请
MAIL_SUBTYPE.subAlliance = ConfigMgr.GetVar("MailSubTypeAlliance") --联盟通知
MAIL_SUBTYPE.subAllianceBuildcomplete = ConfigMgr.GetVar("MailSubTypeAllianceBuildcomplete") --联盟建筑完工
MAIL_SUBTYPE.subAllianceBuildRecovery = ConfigMgr.GetVar("MailSubTypeAllianceBuildRecovery") --联盟建筑回收
MAIL_SUBTYPE.subAllianceBuildPlace = ConfigMgr.GetVar("MailSubTypeAllianceBuildPlace") --联盟建筑放置通知
MAIL_SUBTYPE.subTypeActiveCombat = ConfigMgr.GetVar("MailSubTypeActiveCombat")   --秘密基地搜索报告
MAIL_SUBTYPE.subPersonalMsg = ConfigMgr.GetVar("MailSubTypePersonal") --个人邮件
MAIL_SUBTYPE.subGroupMsg = ConfigMgr.GetVar("MailSubTypeGroup") --群组邮件
MAIL_SUBTYPE.subMailSubTypeAllianceNotify = ConfigMgr.GetVar("MailSubTypeAllianceNotify") --全体邮件
MAIL_SUBTYPE.subMailSubTypeNewPlayer = ConfigMgr.GetVar("MailSubTypeNewPlayer") --新手邮件
MAIL_SUBTYPE.subMailSubTypeForceUpgrade = ConfigMgr.GetVar("MailSubTypeForceUpgrade") --强更提醒邮件
MAIL_SUBTYPE.MailSubTypeSports = ConfigMgr.GetVar("MailSubTypeSports") --竞技场邮件

MAIL_CHATHOME_TYPE = {}
MAIL_CHATHOME_TYPE.Chat = 0         --普通聊天
MAIL_CHATHOME_TYPE.TempChat = 1     --临时聊天
MAIL_CHATHOME_TYPE.UnionChat = 2    --联盟全体邮件

MAIL_MSG_TYPE = {} --聊天消息类型
MAIL_MSG_TYPE.Normal = 0
MAIL_MSG_TYPE.System = 1

MAIL_INVITE_STATUS = {} --邮件状态
MAIL_INVITE_STATUS.Normal = 0 --初始状态
MAIL_INVITE_STATUS.Accept = 1 --接受
MAIL_INVITE_STATUS.Refused = 2 --拒绝

EMOJIES_TYPE = {}
EMOJIES_TYPE.First = 1
EMOJIES_TYPE.Second = 2
EMOJIES_TYPE.BigFirst = 100

MAIN_UI_BTN_TYPE = {} --主UI按钮类型
MAIN_UI_BTN_TYPE.Hero = 1
-- MAIN_UI_BTN_TYPE.Item = 2
MAIN_UI_BTN_TYPE.Mail = 3
MAIN_UI_BTN_TYPE.Alliance = 4
-- MAIN_UI_BTN_TYPE.Skill=5
MAIN_UI_BTN_TYPE.PlayerInfo = 6
MAIN_UI_BTN_TYPE.Backpack = 7


UNION_BTN_TYPE = {} --联盟UI按钮类型
-- UNION_BTN_TYPE.Msg = 1
-- UNION_BTN_TYPE.Invition = 2
UNION_BTN_TYPE.Member = 3
UNION_BTN_TYPE.Manager = 4

PLAYER_BTN_TYPE = {}
PLAYER_BTN_TYPE.Wall = 1
PLAYER_BTN_TYPE.Skill = 2
PLAYER_BTN_TYPE.Set = 3

MILITARY_SUPPLY = {}
MILITARY_SUPPLY.MilitarySupplyLimit = ConfigMgr.GetVar("MilitarySupplyLimit") --军需站每日次数限制
MILITARY_SUPPLY.MilitarySupplyFee = ConfigMgr.GetVar("MilitarySupplyFee") --军需站钻石费用
MILITARY_SUPPLY.MilitarySupplyFeeStep = ConfigMgr.GetVar("MilitarySupplyFeeStep") --军需站钻石费用递增数值
MILITARY_SUPPLY.MilitarySupplyFeeMax = ConfigMgr.GetVar("MilitarySupplyFeeMax") --军需站钻石最大费用
MILITARY_SUPPLY.ResSupplyIncrease = ConfigMgr.GetVar("ResSupplyIncrease") --补给资源增长百分比
MILITARY_SUPPLY.MSItemConfId = ConfigMgr.GetVar("MSItemConfId") --军需次数兑换道具ID

SHOP_TYPE = {} --商店类型
SHOP_TYPE.UnionShop = 1 --联盟商店
SHOP_TYPE.UnionAddShop = 2 --联盟补货商店
SHOP_TYPE.SpecialShop = 3 --特惠商店
SHOP_TYPE.VipShop = 4 --vip商店
SHOP_TYPE.ItemShop = 4 --item商店

ALLIANCE_SHOP_LOG_TYPE = {} --联盟商店日志
ALLIANCE_SHOP_LOG_TYPE.AllianceShopLogTypeStock = ConfigMgr.GetVar("AllianceShopLogTypeStock") --联盟商店日志-采购
ALLIANCE_SHOP_LOG_TYPE.AllianceShopLogTypeBuy = ConfigMgr.GetVar("AllianceShopLogTypeBuy") --联盟商店日志-购买

UNION_VOTITEM_TYPE = {} --联盟投票成员item类型
UNION_VOTITEM_TYPE.SelectItem = 1
UNION_VOTITEM_TYPE.InfoItem = 2

UNION_RANK_TYPE = {} --联盟捐献排行
UNION_RANK_TYPE.UNIONRANKDAY = ConfigMgr.GetVar("AllianceDonateRankDaily") --联盟捐献—日排行
UNION_RANK_TYPE.UNIONRANKWEEK = ConfigMgr.GetVar("AllianceDonateRankWeekly") --联盟捐献—周排行
UNION_RANK_TYPE.UNIONRANKHISTORY = ConfigMgr.GetVar("AllianceDonateRankHistory") --联盟捐献—历史排行

RECEIVE_STATE = {} --领取状态
RECEIVE_STATE.CanReceive = 1 --可领取
RECEIVE_STATE.HavaReceive = 2 --已经领取
RECEIVE_STATE.CantReceive = 3 --不能领取

MSG_TYPE = {} --消息类型
MSG_TYPE.Mail = 1 --邮件聊天
MSG_TYPE.Chat = 2 --普通聊天（包括联盟聊天）
MSG_TYPE.LMsg = 3 --留言
MSG_TYPE.RMsg = 4 --跑马灯

CHAT_TYPE = {} --聊天类型
CHAT_TYPE.WorldChat = 0 --世界聊天
CHAT_TYPE.UnionChat = 1 --联盟聊天
CHAT_TYPE.UnionHelpChat = 2 --联盟帮助聊天信息

CHAT_BOX_TYPE = {}
CHAT_BOX_TYPE.Normal    = 0     --普通
CHAT_BOX_TYPE.System    = 1     --系统
CHAT_BOX_TYPE.Gm        = 3     --GM
CHAT_BOX_TYPE.Radio     = 4     --喇叭

RADIO_TYPE = {}
RADIO_TYPE.ChatRadio = Global.AnnouncementPlayer --玩家喇叭
RADIO_TYPE.FirstRadio = Global.AnnouncementSeverStop --全服公告喇叭（最优先）
RADIO_TYPE.SystemRadio = Global.AnnouncementServer --系统喇叭
RADIO_TYPE.CasinoRadio = Global.AnnouncementTurntabledraw --赌场喇叭
RADIO_TYPE.TurnRadio = Global.AnnouncementLottery --转盘喇叭
RADIO_TYPE.OperateRadio = Global.AnnouncementSperation --普通运营喇叭

WORLD_CHAT_TYEP = {} --世界聊天消息类型
WORLD_CHAT_TYEP.Lucky = ConfigMgr.GetVar("World_chat_Lucky") --快来看看我在幸运转盘中获得的超赞奖励
WORLD_CHAT_TYEP.Gift = ConfigMgr.GetVar("World_chat_gift") --兄弟们，快来抢伴手礼
WORLD_CHAT_TYEP.Invite = ConfigMgr.GetVar("World_chat_Alliance_Invite") --联盟{alliance_name}招人
WORLD_CHAT_TYEP.GreatAlliance = ConfigMgr.GetVar("World_GreatAlliance") --我创建了联盟{alliance_name}，大家快来加入联盟一起壮大联盟（系统）

ALLIANCE_CHAT_TYEP = {} --联盟聊天消息类型
ALLIANCE_CHAT_TYEP.ResHelp = ConfigMgr.GetVar("Res_For_Help") --急需{res_name}资源应急，请求盟友支持！
ALLIANCE_CHAT_TYEP.Aggregation = ConfigMgr.GetVar("Army_Aggregation") --我发起了一次集结，请大家协助
ALLIANCE_CHAT_TYEP.SignShop = ConfigMgr.GetVar("Alliance_shop_sign") --我在联盟商店标记了{item_name}，需要进行货物补充
ALLIANCE_CHAT_TYEP.SharePos = ConfigMgr.GetVar("Alliance_coordinate_share") --我分享了一个坐标(x,y)
ALLIANCE_CHAT_TYEP.Voting = ConfigMgr.GetVar("Alliance_Voting") -- 我分享了投票

ALLIANCE_CHAT_TYEP.ArmyHelp = ConfigMgr.GetVar("Army_For_Help") --我正在遭受敌人的攻击，请求盟友援助
ALLIANCE_CHAT_TYEP.Likes = ConfigMgr.GetVar("Alliance_Likes") --{playername}的基地等级达到了{number}级，，实力更上一层楼，大家一起来为他点赞吧
ALLIANCE_CHAT_TYEP.ShopSupplement = ConfigMgr.GetVar("Alliance_shop_supplement") --{playername}为联盟商店补充了{item_name}
ALLIANCE_CHAT_TYEP.TaskHelp = ConfigMgr.GetVar("Alliance_Task_Help") -- 我正在执行{task_name}，请协助我完成
ALLIANCE_CHAT_TYEP.Exit = ConfigMgr.GetVar("Alliance_Exit") --我退出了联盟，我会想念大家的
ALLIANCE_CHAT_TYEP.Join = ConfigMgr.GetVar("Alliance_Join") --{playernam}前来报到，我将和大家一起建设联盟
ALLIANCE_CHAT_TYEP.BePromoted = ConfigMgr.GetVar("Alliance_BePromoted") --我将{playername}的权限等级由{lvname}调整为{lvname}，希望他能为联盟做更多的贡献
ALLIANCE_CHAT_TYEP.Expel = ConfigMgr.GetVar("Alliance_Expel") --{playernama}已经被移出联盟。
ALLIANCE_CHAT_TYEP.Bossreplace = ConfigMgr.GetVar("Alliance_Bossreplace") --我将盟主转让给了{playname}，希望在他的带领下联盟更加强大
ALLIANCE_CHAT_TYEP.HelpDefence = ConfigMgr.GetVar("Army_Help_TXT") --派遣部队帮助你的盟友守卫他们的基地。
ALLIANCE_CHAT_TYEP.BePromotedDown = ConfigMgr.GetVar("Alliance_BePromotedDown") --我将{playername}的权限等级由{rank1}调整为{rank2}，希望他不要气馁，再接再厉继续为联盟做出更多贡献
ALLIANCE_CHAT_TYEP.Bossdisplacement = ConfigMgr.GetVar("Alliance_Bossdisplacement") --我已经取代{play_name}成为新的盟主，我将会带领联盟变得更加强大

PUBLIC_CHAT_TYPE = {} --世界 联盟聊天 公用 消息类型
PUBLIC_CHAT_TYPE.Normal = ConfigMgr.GetVar("CHAT_TYEP_Normal") --普通
PUBLIC_CHAT_TYPE.Radio = ConfigMgr.GetVar("CHAT_TYEP_Radio") --广播
PUBLIC_CHAT_TYPE.RedPacket = ConfigMgr.GetVar("CHAT_TYEP_RedPacket ") --红包
PUBLIC_CHAT_TYPE.ChatAttackSuccessShare = ConfigMgr.GetVar("ChatAttackSuccessShare")   --我进攻了{playername}，战斗胜利
PUBLIC_CHAT_TYPE.ChatAttackFailShare = ConfigMgr.GetVar("ChatAttackFailShare")  --我进攻了{playername}，战斗失败
PUBLIC_CHAT_TYPE.ChatDefenceSuccessShare = ConfigMgr.GetVar("ChatDefenceSuccessShare")  --我受到了{playername}的攻击，战斗胜利
PUBLIC_CHAT_TYPE.ChatDefenceFailShare = ConfigMgr.GetVar("ChatDefenceFailShare")    --我受到了{playername}的攻击，战斗失败
PUBLIC_CHAT_TYPE.ChatBescoutShare = ConfigMgr.GetVar("ChatBescoutShare")    --{playername}侦察了我
PUBLIC_CHAT_TYPE.ChatScoutShare = ConfigMgr.GetVar("ChatScoutShare")    --我侦察了{playername}
PUBLIC_CHAT_TYPE.ChatRangeRewardRecordShare = ConfigMgr.GetVar("ChatRangeRewardRecordShare")    --快来看看我在靶场中获得的超赞奖励
PUBLIC_CHAT_TYPE.OperationFalcon_Technology = ConfigMgr.GetVar("OperationFalcon_Technology")    --快来看看我在猎鹰行动中获取的科技奖励
PUBLIC_CHAT_TYPE.OperationFalcon_Share = ConfigMgr.GetVar("OperationFalcon_Share")    --我在猎鹰行动中获取到的奖励
PUBLIC_CHAT_TYPE.Alliance_OperationFalcon_Technology = ConfigMgr.GetVar("Alliance_OperationFalcon_Technology")    --我在猎鹰行动中获取到的奖励
PUBLIC_CHAT_TYPE.Alliance_OperationFalcon_Share = ConfigMgr.GetVar("Alliance_OperationFalcon_Share")    --我在猎鹰行动中获取到的奖励

MAIL_CHAT_TYPE = {}
MAIL_CHAT_TYPE.MailMsgTypeAllianceNotify = ConfigMgr.GetVar("MailMsgTypeAllianceNotify") --邮件聊天-联盟全体邮件
MAIL_CHAT_TYPE.Invite = ConfigMgr.GetVar("MailGroup_Invite") --{playername}邀请{playername}加入了聊天
MAIL_CHAT_TYPE.Remove = ConfigMgr.GetVar("MailGroup_Remove") --{playername}被移出聊天室
MAIL_CHAT_TYPE.Leave = ConfigMgr.GetVar("MailGroup_Leave") --{playername}离开了聊天室

PLAYER_CONTACT_BOX_TYPE = {} --点击玩家头像弹出框类型
PLAYER_CONTACT_BOX_TYPE.ChatBox = 1 --聊天
PLAYER_CONTACT_BOX_TYPE.RankBox = 2 --排行榜

FLAG_TYPE = {} --旗帜类型 1 玩家信息 2 联盟 3 王战
FLAG_TYPE.Player = 1
FLAG_TYPE.Alliance = 2
FLAG_TYPE.Royal = 3

EFFECT_TYPE = {} --特效类型
EFFECT_TYPE.MilitaryEffect = 1
EFFECT_TYPE.MilitaryEffectIcon = 2

UNION_BOSS_TASK = {}
UNION_BOSS_TASK.APTStatusIdle = 0       --未完成
UNION_BOSS_TASK.APTStatusFinished = 1   --已完成
UNION_BOSS_TASK.APTStatusClaimed = 2    --已领奖

DRESSUP_TYPE = {}   --装扮类型
DRESSUP_TYPE.Nameplate  = Global.DressUpNamePlate       --铭牌
DRESSUP_TYPE.Bubble     = Global.DressUpBubble          --气泡
DRESSUP_TYPE.Avatar     = Global.DressUpAvatar          --头像框

DRESSUP_BUBBLE_TYPE = {}
DRESSUP_BUBBLE_TYPE.Arrow = 1           --气泡尖
DRESSUP_BUBBLE_TYPE.Box = 2             --框
DRESSUP_BUBBLE_TYPE.RightTop = 3        --挂坠
DRESSUP_BUBBLE_TYPE.RightBotton = 4     --挂坠
DRESSUP_BUBBLE_TYPE.LeftTop = 5         --挂坠
DRESSUP_BUBBLE_TYPE.LeftBotton = 6      --挂坠

DRESSUP_NAMEPLATE_TYPE = {}
DRESSUP_NAMEPLATE_TYPE.Head = 21
DRESSUP_NAMEPLATE_TYPE.Bg = 22