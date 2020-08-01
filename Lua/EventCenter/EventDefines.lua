if EventDefines then
    return EventDefines
end

GM_MSG_EVENT = {}
GM_MSG_EVENT.NewMsgNotRead = "GM_MSG_EVENTNewMsgNotRead"
GM_MSG_EVENT.MsgIsRead = "GM_MSG_EVENTMsgIsRead"

EventDefines = {
    Mask = "Mask", --遮罩
    GuideMask = "GuideMask", --引导遮罩 (非引导勿用)
    LayerMask = "LayerMask", --界面动画遮罩
    CityMask = "CityMask", --内城遮罩
    UpgradeMask = "UpgradeMask", --玩家升级/指挥官升级弹窗
    OpenNetLoading = "OpenNetLoading",
    CloseNetLoading = "CloseNetLoading",
    NetOnConnected = "NetOnConnected",
    NetReConnected = "NetReConnected",
    NetLoginFromReconnect = "NetLoginFromReconnect",
    NetOnDisconnected = "NetOnDisconnected",
    UILoginAtOtherPlace = "UILoginAtOtherPlace", --同一账号登录被挤下线提示通知
    LoginSuccess = "LoginSuccess",
    ReLoginSuccess = "ReLoginSuccess",
    UIToolTip = "UIToolTip", --提示通知
    UIMainShow = "UIMainShow", --主界面显示与隐藏
    UIVipInfo = "UIVipInfo", --VIP玩家信息
    RefreshVipUpgradeTip = "RefreshVipUpgradeTip",
    -- UIAccomplishedMainTasks = "UIAccomplishedMainTasks", --主线已完成任务
    -- UIUnlockedMainTasks = "UIUnlockedMainTasks",
    UITaskMainRefresh = "UITaskMainRefresh",
     --刷新主线任务界面
    UITipMainTaskMes = "UITipMainTaskMes",
    --主线任务通知
    --主线已解锁的任务
    -- UIUnlockedMainTask = "UIUnlockedMainTask", --宝箱领取后宝箱进度
    UIGemAmount = "UIGemAmount", --钻石变化通知
    UIApAmount = "UIApAmount", --体力变化通知
    UIPlayerInfoExchange = "UIPlayerInfoExchange", --玩家信息变化通知
    UIPlayerUpdateHead = "UIPlayerUpdateHead", --玩家设置自定义头像通知
    UIPlayerPowerEffectShow = "UIPlayerPowerEffectShow", --玩家战斗力特效显示：升级（建造），训练，科研，治疗士兵
    UIPlayerExpEffectShow = "UIPlayerExpEffectShow", --玩家战斗力特效显示：升级（建造）
    UICityBuildCenterUpgrade = "UICityBuildCenterUpgrade", --指挥中心升级
    UICityBuildWallUpgrade = "UICityBuildWallUpgrade", --城墙升级
    UIItemsAmount = "UIItemsAmount", --道具变化通知
    UIItemAmount = "UIItemAmount", --单个道具变化通知
    ItemAmount = "ItemAmount", --单个道具变化通知
    UIResourcesAmount = "UIResourcesAmount", --资源变化通知
    UIMainResourcesAmount = "UIMainResourcesAmount", --资源变化通知 通知每个组件
    UIResourcesAnim = "UIResourcesAnim", --资源收集动画
    UIResourcesDisplayClose = "UIResourcesDisplayClose", --关闭资源购买界面
    UIResProtects = "UIResProtects", --保护资源变化通知
    UIBuildingFinish = "UIBuildingFinish", --建筑建造完成通知
    UIBuildingUpgrade = "UIBuildingUpgrade", --建筑升级完成通知
    UIBuildingDestroy = "UIBuildingDestroy", --建筑拆除通知
    UIUpgradeEvent = "UIUpgradeEvent", --建筑升级事件刷新
    UICureEvent = "UICureEvent", --士兵治疗事件刷新
    UIResetBuilder = "UIResetBuilder", --重置建筑队列
    UIBuilder = "UIBuilder", --建筑队列通知
    UISidebarPoint = "UISidebarPoint", --队列总览红点提示
    UISidebarOpen = "UISidebarOpen", --队列总览是否打开
    UIResBuilAdd = "UIResBuilAdd", --资源建筑新增通知
    UIResBuils = "UIResBuils", --资源建筑通知
    UIResBuilsDelete = "UIResBuilsDelete", --删除资源建筑的资源产生信息
    UIArmyTrainFinish = "UIArmyTrainFinish", --造兵完成通知
    UIArmyAmount = "UIArmyAmount", --军队数量变化通知
    UIArmyChange = "UIArmyChange", --单一兵种数量变化通知
    UIInjuredArmyAmount = "UIInjuredArmyAmount", --伤兵数量变化通知
    UIArmyCureFinish = "UIArmyCureFinish", --军队治疗完成
    UIInjuredArmyDel = "UIInjuredArmyDel", --删除伤兵
    UIInjuredArmyAmountExg = "UIInjuredArmyAmountExg", --伤兵数量变化
    UIInjuredBeastExg = "UIInjuredBeastExg", --巨兽治疗变化
    UICityBuildMove = "UICityBuildMove", --建筑移动
    UICityBuildTurn = "UICityBuildTurn", --建筑跳转
    UICityBuildImage = "UICityBuildImage", --建筑图片显示
    UICityAddBuild = "UICityAddBuild", --添加建筑(建筑建造)
    UICitySpecialBuildTurn = "UICitySpecialBuildTurn", --特殊建筑跳转
    UICityTurnBuildCreate = "UICityTurnBuildCreate", --建筑跳转建造
    UIReqMails = "UIReqMails", --通知-邮件
    UIReadMsgMails = "UIReadMsgMails",
    UIMailsNumChange = "UIMailsNumChange",
    UIAllianceTaskPonit = "UIAllianceTaskPonit",
    UIAllianceBossTaskPonit = "UIAllianceBossTaskPonit",
    UICloseEffectBuildCenter = "UICloseEffectBuildCenter",
    --邮件未读数量变化
    UIWorldCityQueueFinish = "UIWorldCityQueueFinish",
    UITechResearchFinish = "UITechResearchFinish", --科技研究完成通知
    UIRefreshTechResearchFinish = "UIRefreshTechResearchFinish", --科技研究完成界面刷新通知
    UIClickWorldMap = "UIClickWorldMap",
    UIClickMarchUnit = "UIClickMarchUnit",
    UICloseMapDetail = "UICloseMapDetail",
    UIOnArmiesChange = "UIOnArmiesChange",
    --进入主城
    --出征界面数量变化
    UIOnExpetionNumChange = "UIOnExpetionNumChange",
    --出征界面上限变化
    UIOnExpeditionLimitChange = "UIOnExpeditionLimitChange",
    --开启收藏夹编辑
    UIOnEditFavorite = "UIOnEditFavorite",
    --收藏夹全选
    UIOnSelectAllFavorite = "UIOnSelectAllFavorite",
    --收藏夹刷新
    UIOnRefreshFavorite = "UIOnRefreshFavorite",
    --收藏夹选择部分
    UIOnSelectFavorite = "UIOnSelectFavorite",
    --选择搜索类型
    UISelectMapSearch = "UISelectMapSearch",
    --触发页面动画
    UITriggerPanelAnim = "UITriggerPanelAnim",
    --邮件收藏刷新
    UIMailAddFavorite = "UIMailAddFavorite",
    UIMailDelFavorite = "UIMailDelFavorite",
    --邮件选择刷新
    UIMailAdd = "UIMailAdd",
    UIMailDel = "UIMailDel",
    --删除邮件
    UIDelMiil = "UIDelMiil",
    UIReqMSInfo = "UIReqMSInfo",
    --雷达 事件抵达通知
    UIOnRadarItemArrived = "UIOnRadarItemArrived",
    --雷达 新事件通知
    UIOnRaderEvent = "UIOnRaderEvent",
    --雷达 警报状态刷新
    UIOnRadarTipRefresh = "UIOnRadarTipRefresh",
    --雷达页面变化
    UIOnRadarHeightChange = "UIOnRadarHeightChange",
    UIOnRadarRefresh = "UIOnRadarRefresh",
    UIOnRefreshWall = "UIOnRefreshWall",
    --军队数量变化界面通知
    UIArmiesRefresh = "UIArmiesRefresh",
    --科技界面帮助按钮刷新
    UILaboratoryHelpTipRefresh = "UILaboratoryHelpTipRefresh",
    --联盟科技捐献后科技界面荣誉刷新
    UIUnionDonateHonorRefresh = "UIUnionDonateHonorRefresh",
    --UIMgr.CloseTop 通知相关界面即将关闭（处理关闭时的逻辑）
    UIClosingSoon = "UIClosingSoon";
    ---------外城相关功能----------------

    IsInCity = "IsInCity",
    --进入城市页面
    --打开大地图
    OpenWorldMap = "OpenWorldMap",
    UIEnterMyCity = "UIEnterMyCity",
    UIEnterCityScale = "UIEnterCityScale",
    --入城云动画伴随大地图放大
    ------地图相关-----------------------------------
    UIOffAnim = "UIOffAnim",
    --通知--删除行军路线
    UIDelMarchLine = "UIDelMarchLine",
    UIOnWorldMapMove = "UIOnWorldMapMove",
    UIOnWorldMapChange = "UIOnWorldMapChange",
    UIOnMoveCity = "UIOnMoveCity",
    --行军事件消息
    UIOnMissionInfo = "UIOnMissionInfo",
    UIDelMission = "UIDelMission",
    --刷新地块行军
    UIOnRefreshMarchLine = "UIOnRefreshMarchLine",
    --通知--地图初始化完毕
    UIWorldMapInitFinish = "UIWorldMapInitFinish",
    -------------联盟相关-----------------------------------
    --刷新协作任务列表
    UIUnionCooperationRefreshTaskList = "UIUnionCooperationRefreshTaskList",
    --刷新我的协作任务列表
    UIUnionCooperationRefreshMykList = "UIUnionCooperationRefreshMykList",
    --帮助任务通知
    UIOnUnionHelpOtherTask = "UIOnUnionHelpOtherTask",
    --完成协作任务
    UIOnFinishUnionTask = "UIOnFinishUnionTask",
    --通知-联盟留言
    AllianceMessage = "AllianceMessage",
    --通知-聊天
    ChatEvent = "ChatEvent",
    --通知-广播聊天
    RadioChatEvent = "RadioChatEvent",
    --退出赌场
    OpenCasinoRadioChatEvent = "OpenCasinoRadioChatEvent",
    ExitCasinoRadioChatEvent = "ExitCasinoRadioChatEvent",
    OpenRangeRewardRecord = "OpenRangeRewardRecord",
    ExitRangeRewardRecord = "ExitRangeRewardRecord",
    --通知结束
    RadioEndChatEvent = "RadioEndChatEvent",
    --联盟相关
    UIUserAllianceInfo = "UIUserAllianceInfo", --联盟信息变化
    UIAllianceInfoExchanged = "", --联盟信息变化显示
    UIAllianceMember = "UIAllianceMember", --联盟成员变化
    UIAllianceFire = "UIAllianceFire", --联盟开除成员
    UIAllianceApplied = "UIAllianceApplied", --联盟申请信息
    UIAllianceMemberUpdate = "UIAllianceMemberUpdate", --联盟成员列表刷新
    UIAllianceHelp = "UIAllianceHelp", --联盟帮助通知
    UIAllianceHelped = "UIAllianceHelped", --联盟已帮助通知
    UIAllianceHelpOnHelp = "UIAllianceHelpOnHelp", --联盟帮助之自己被帮助
    UIAllianceHelpInfoExg = "UIAllianceHelpInfoExg", --联盟帮助信息变化
    UIAllianceRefeshHelpTask = "UIAllianceRefeshHelpTask",
    UIAllianceBattleCancel = "UIAllianceBattleCancel", --联盟战争取消
    UIAllianceBattleCreate = "UIAllianceBattleCreate", --联盟战争信息创建
    UIAllianceBattleChange = "UIAllianceBattleChange", --联盟战争信息变更
    UIAllianceBattleRemoval = "UIAllianceBattleRemoval", --遣返玩家刷新界面
    UIAllianceOpen = "UIAllianceOpen", --打开联盟界面(没有联盟打开加入联盟界面)
    UIAllianceNoticeUpdate = "UIAllianceNoticeUpdate",
    UIOnRefreshAggregation = "UIOnRefreshAggregation",
    UIAllianceWarefarePonit = "UIAllianceWarefarePonit",
    UIAllianceIconExchanged = "UIAllianceIconExchanged", --联盟信息变化显示
    UIMainAllianceIconRefresh = "UIMainAllianceIconRefresh", --mainuipanel界面联盟按钮刷新
    --刷新联盟集结状态
    HonorChange = "HonorChange",
    --联盟积分改变
    --联盟协作任务刷新
    UIAllianceCreateBuilding = "UIAllianceCreateBuilding",
    --联盟建筑修建
    UIAllianceJoin = "UIAllianceJoin", --加入联盟通知
    UIAllianceCreate = "UIAllianceCreate", --创建联盟通知
    --联盟加入成功通知
    --Buff变更
    UIBuffUpdate = "UIBuffUpdate",
    --理财基金完成通知
    UIInvestFinishedAction = "UIInvestFinishedAction",
    --日常任务红点提示
    UIDailyTaskRedDotEvent = "UIDailyTaskRedDotEvent",
    --日常任务刷新
    DailyTaskRefreshAction = "DailyTaskRefreshAction",
    --可以领取在线礼物
    UIGiftFinish = "UIGiftFinish",
    --没有完成在线礼物
    UIGiftFinishing = "UIGiftFinishing",
    --防护罩
    ShieldAt = "ShieldAt",
    --关闭操作栏
    UIOnCloseItemDetail = "UIOnCloseItemDetail",
    --搜索次数变化
    UISearchTimeChange = "UISearchTimeChange",
    --任务主界面红点数量刷新
    UITaskRefreshRed = "UITaskRefreshRed",
    UIMapLoadingFinish = "UIMapLoadingFinish", --大地图加载完成
    UITownMove = "UITownMove", --主城移动
    BeginBuildingMove = "BeginBuildingMove",
    --开始建筑移动
    BuildingMoveing = "BuildingMoveing",
    --建筑移动中
    EndBuildingMove = "EndBuildingMove",
    --结束建筑 移动
    UIWorldMapSerch = "UIWorldMapSerch", --世界地图搜索,
    RefreshStore = "RefreshStore",
    --刷新任务储值数据
    CarzyStore = "CarzyStore",--疯狂兑换
    -- WelfareFinishAction = "WelfareFinishAction",   --活动红点提示
    InvestFinishAction = "InvestFinishAction",
    --理财基金完成提示
    WelfareIconRedShow = "WelfareIconRedShow",
    --跳转提示
    JumpTipEvent = " JumpTipEvent",
    --内城地图相关
    UIMapTurnLockPiece = "UIMapTurnLockPiece", --地图解锁区域跳转
    AchievementRewardChange = "AchievementRewardChange", --领取了成就奖励
    GetNewAchievement = "GetNewAchievement", --有新的成就达成
    HeadPlayerRedPointCheck = "HeadPlayerRedPointCheck", --玩家头像红点检测
    UIOutCityScale = "UIOutCityScale",
    --出城云动画伴随内城地图缩放
    UICloudOutFinish = "UICloudOutFinish", --云层动画结束
    --赌场相关
    UIRangeTurntableData = "UIRangeTurntableData", --靶场信息
    RangeFlopClose = "RangeFlopClose",
    MesTaskMainTipEvent = "MesTaskMainTipEvent",
    --通知主线任务提示
    GozillzUnlockEvent = "GozillzUnlockEvent",
    --刷新主界面三个在线按钮的位置
    RefreshSetIconPos = "RefreshSetIconPos",
    --美女在线奖励信息
    BeautySetOnlineInfo = "BeautySetOnlineInfo",
    --美女在线奖励刷新
    BeautyOnlineRefresh = "BeautyOnlineRefresh",
    --打开主界面得美女按钮
    UnlockMainPanelBeauty = "UnlockMainPanelBeauty",
    --刷新主界面计时
    RefreshMainUIBeauty = "RefreshMainUIBeauty",
    --背包刷新
    UIRefreshBackpack = "UIRefreshBackpack",
    --背包红点刷新
    UIRefreshBackpackRedPoint = "UIRefreshBackpackRedPoint",
    --是否可以修建建筑
    UIIsCanBuild = "UIIsCanBuild",
    --关闭监狱界面
    UIOnClosePrison = "UIOnClosePrison",
    --探索奖励
    UIExploreRewardInfo = "UIExploreRewardInfo",
    --主动技能红点提示
    UIActiveSkillRedMes = "UIActiveSkillRedMes",
    UIRefreshSkillRed = "UIRefreshSkillRed",
    VipPointsChange = "VipPointsChange",
    --巨兽治疗完成
    UIBeastFinishCureRsp = "UIBeastFinishCureRsp",
    --成长基金引导显示
    GrowthGuideView = "GrowthGuideView",
    --关闭福利中心
    WelareCenterClose = "WelareCenterClose",
    --完成的剧情任务数组
    UIAccomplishedPlotTasks = "UIAccomplishedPlotTasks",
    --解锁的剧情任务数组
    UIUnlockedPlotTasks = "UIUnlockedPlotTasks",
    UIRefreshBlackKnight = "UIRefreshBlackKnight",
    --关闭章节显示入口
    UICloseChapterShow = "UICloseChapterShow",
    --章节显示刷新
    UIRefreshChapterShow = "UIRefreshChapterShow",
    UIOnLineIcon = "UIOnLineIcon",
    --刷新赌场基金信息
    ActivityTaskCasino = "ActivityTaskCasino",
    --侦查界面刷新
    DetectRefresh = "DetectRefresh",
    --在线奖励页面获取
    OnlineGiftOpen = "OnlineGiftOpen",
    --章节顺序刷新
    UIChapterSort = "UIChapterSort",
    --刷新任务数据
    RefreshTaskData = "RefreshTaskData",
    CloseUiTaskMain = "CloseUiTaskMain",
    --接收哥斯拉在线通知
    UIGodzillaOnlineBonusFinish = "UIGodzillaOnlineBonusFinish",
    --刷新迁城按钮信息
    RefreshBuildBtnInfo = "RefreshBuildBtnInfo",
    --打开功能列表回调
    GuideCompGuideFunc = "GuideCompGuideFunc",
    --显示签到引导
    GuideDailyShow = "GuideDailyShow",
    -- --普通任务领取刷新
    -- CommonTaskRefresh = "CommonTaskRefresh",
    --成就解锁
    UnlockedAchievementUI = "UnlockedAchievementUI",
    --礼包购买成功
    PurchaseGiftSuccess = "PurchaseGiftSuccess",
    --成就完成推送
    AccomplishedAchievementsUI = "AccomplishedAchievementsUI",
    --刷新可购买礼包
    RefreshGiftPacks = "RefreshGiftPacks",
    --刷新每日礼包领取标记
    RefreshDailyGiftFlag = "RefreshDailyGiftFlag",
    GrowthFundPayed = "GrowthFundPayed",
    --刷新月卡显示
    RefreshMonthData = "RefreshMonthData",
    --刷新钻石显示
    RefreshDiamondData = "RefreshDiamondData",
    --新手引导
    NoviceGuide = "NoviceGuide",
    --新手引导下一步
    NoviceNextStep = "NoviceNextStep",
    --行军队列显示刷新
    UIQueueRefresh = "UIQueueRefresh",
    --播放迁城动画
    WorldMapBuildAnim = "WorldMapBuildAnim",
    UIQueueRefresh = "UIQueueRefresh",
    --打开任务
    UIOpenTaskPanel = "UIOpenTaskPanel",
    --刷新技能图标显示
    RefreshSkillIconShow = "RefreshSkillIconShow",
    --新手引导关闭所有界面和节点
    ClosePanelAndBuilding = "ClosePanelAndBuilding",
    --打开所有界面和节点
    OpenPanelAndBuilding = "OpenPanelAndBuilding",
    --新手引导地图放大
    NoviceMapScale = "NoviceMapScale",
    --新手引导地图缩小移动
    NoviceMapTweenMove = "NoviceMapTweenMove",
    WorldMapMarchTest = "WorldMapMarchTest",
    --刷新活动页面
    RefreshActivityUI = "RefreshActivityUI",
    CloseActivityUI = "CloseActivityUI",
    --日常任务弹窗
    DailyTaskPopupUI = "DailyTaskPopupUI",
    --新手引导建筑引导下一步
    NoviceBuildingGuideNextStep = "NoviceBuildingGuideNextStep",
    --大地图行军动画缓存
    WorldMarchAnimPoint = "WorldMarchAnimPoint",
    --大地图进攻动画完结
    WorldMarchAnimFinish = "WorldMarchAnimFinish",
    WorldMapCameraPosReturn = "WorldMapCameraPosReturn",
    WorldCloseClickUnit = "WorldCloseClickUnit",
    UIMonsterCureEvent = "UIMonsterCureEvent",
    --触发式引导判断
    TriggerGuideJudge = "TriggerGuideJudge",
    TriggerGuideShow = "TriggerGuideShow",
    TriggerGuideNextStep = "TriggerGuideNextStep",
    TriggerGuideDo = "TriggerGuideDo",
    TriggerGuideOnClick = "TriggerGuideOnClick",
    --所有top和pop界面都关闭
    TriggerAllPanelClose = "TriggerAllPanelClose",
    GameOutFocus = "GameOutFocus",
    --游戏重新获得焦点
    GameOnFocus = "GameOnFocus",
    DelMarchAnim = "DelMarchAnim",
    -- --删除进攻返回缓存路线
    -- MarchLineAttackReturnDel = "MarchLineAttackReturnDel"

    --添加联盟标记
    MapAddAllianceMark = "MapAddAllianceMark",
    --删除联盟标记
    MapDelAllianceMark = "MapDelAllianceMark",
    --关闭活动new标签
    CloseIsNewTag = "CloseIsNewTag",
    WorldMapAllianceRefresh = "WorldMapAllianceRefresh",
    --美女约会完毕
    BeautyDateFinish = "BeautyDateFinish",
    --临时隐藏建筑气泡
    HideBuidingCompleteBtn = "HideBuidingCompleteBtn",
    -----------------------------------------------------------------------------提示点 >>>
    ------>>> 福利中心
    WelfareRefreshPoint = "WelfareRefreshPoint",
    UIWelfareRookieGrowth = "UIWelfareRookieGrowth", --福利中心：新手成长之路
    UIWelfareDailyTaskUp = "UIWelfareDailyTaskUp", --福利中心：日常任务(上面)
    UIWelfareDailyTaskDown = "UIWelfareDailyTaskDown", --福利中心：日常任务(下面)
    UIWelfareGrowthFund = "UIWelfareGrowthFund", --福利中心：成长基金
    UIWelfareCasionMass = "UIWelfareCasionMass", --福利中心：赌场集结
    UIWelfareDetectActvity = "UIWelfareDetectActvity", --福利中心：侦查活动
    UIWelfareGemFund="UIWelfareGemFund",--福利中心：长留基金
    ------>>> 联盟
    UIUnionMainList = "UIUnionMainList", --联盟列表
    UIUnionWarfare = "UIUnionWarfare", --联盟列表：联盟战争
    UIUnionTeamTask = "UIUnionTeamTask", --联盟列表：联盟合作任务
    UIUnionTaskRefresh = "UIUnionTaskRefresh", --联盟列表：联盟刷新合作任务
    UIUnionScience = "UIUnionScience", --联盟列表：联盟科技
    UIUnionHelp = "UIUnionHelp", --联盟列表：联盟帮助
    UIUnionTask = "UIUnionTask", --联盟列表：联盟任务
    UIUnionMainMember = "UIUnionMainMember", --联盟成员列表
    UIUnionMainManger = "UIUnionMainManger",
    --联盟管理
    UIUnionManger = "UIUnionManger", --联盟管理界面
    -----------------------------------------------------------------------------提示点 <<<

    BuildItemStateChange = "BuildItemStateChange",
    --建筑状态改变
    CloseClipGuideRender = "CloseClipGuideRender",
    --关闭指引遮罩显示
    CloseGuide = "CloseGuide",
    --关闭弱引导
    CloseBtnFreeGuide="CloseBtnFreeGuide", --关闭指引免费气泡的手指
    CheakMask = "CheakMask",
    --强制关闭遮罩在触发引导期间
    MoveMapEvent = "MoveMapEvent",
    --内城移动事件
    DelayMask = "DelayMask",
    --延迟点击屏蔽mask
    TaskPlotDialog = "TaskPlotDialog",
    --章节任务对话
    TaskPlotReview = "TaskPlotReview",
    --章节任务描述页面
    RefreshGirlName = "RefreshGirlName", -- 刷新美女名字
    GirlDisappearEvent = "GirlDisappearEvent", -- 美女出现隐藏控制
    MainUITouchEvent = "MainUITouchEvent",
    --屏蔽主界面点击按钮
    RefreshDailyAttend = "RefreshDailyAttend",
    --刷新每日签到
    RefreshDailyCumA = "RefreshDailyCumA",
    --新手签到刷新
    WelfareRefreshUI = "WelfareRefreshUI",
     --刷新福利中心
    --兑换奖励界面刷新
    ExchangeRefresh = "ExchangeRefresh",
    --播放在线奖励动画
    PlayOnlineEffect = "PlayOnlineEffect",
    TaskIconJump = "TaskIconJump",
    SkillGetResInfo = "SkillGetResInfo",
     --主动技能获得建筑信息
     TaskPlotCloseGuide = "TaskPlotCloseGuide",
     --剧情任务引导
    RefreshTaskPlotGuide = "RefreshTaskPlotGuide",
    DefenceCenterTrigger = "DefenceCenterTrigger", -- 防御中心ABTest
    --TwelveHourTrigger = "TwelveHourTrigger", -- 12小时送兵逻辑
    --TwelveHourTriggerFinish = "TwelveHourTriggerFinish", --完成援兵引导,
    CustomEventRefresh = "CustomEventRefresh", --自定义事件刷新
    MemoryActivityEffectShow="MemoryActivityEffectShow",--第三周活动获得宝箱的时候特效展示
    UIMonthlyCardRed="UIMonthlyCardRed",

    --猎鹰行动
    FalconInfoEvent = "FalconInfoEvent",
    UIFalconDetectActvity = "UIFalconDetectActvity", --福利中心：猎鹰行动
    SetFalconAirPlaneVisible = "SetFalconAirPlaneVisible", --设置主城飞机的显隐
    FalconOpen = "FalconOpen", -- 飞机返回基地
    CreateMapObj = "CreateMapObj",
    RefreshGrowthFund="RefreshGrowthFund",--刷新成长基金
    RefreshWorldMapBorder = "RefreshWorldMapBorder",--"刷新地图边界"
    DiamondsFundPriceRefresh="DiamondsFundPriceRefresh",--钻石基金通知刷新
    GemFundUIRefresh="GemFundUIRefresh",--返回钻石界面时刷新
    MissionEventRefresh = "MissionEventRefresh"  ,--行军信息刷新
    MapFalconMonster = "MapFalconMonster",--猎鹰活动野怪
    MapSpyMonster = "MapSpyMonster",--侦察活动野怪
    UIWelfareHuntingFox="UIWelfareHuntingFox",--猎狐犬福利UI红点刷新
    HuntingUIRefreshUI="HuntingUIRefreshUI",
    TaskPlotGotoGuide="TaskPlotGotoGuide",--剧情任务前往引导
    NextNoviceStep="NextNoviceStep",--下一步强引回调
    NoviceGuideBuildUpgrade = "NoviceGuideBuildUpgrade", --引导建造完成
    MemorialDayRefresh="MemorialDayRefresh",--阵亡纪念日刷新

    KingkongTrigger = "KingkongTrigger", -- 金刚引导逻辑
    KingkongTriggerFinish = "KingkongTriggerFinish", --完成金刚引导,

    SingleActivityContentRefresh="SingleActivityContentRefresh",--单人活动页面刷新
    FalconSearchEndCb="FalconSearchEndCb",--猎鹰行动扫描结束后刷新
    WorldGuideShow="WorldGuideShow",--世界地图引导
    ClearTrigger="ClearTrigger",--退出触发引导
    RefreshSuperCheapRedData="RefreshSuperCheapRedData",
    RefreshFlagDayRedData="RefreshFlagDayRedData",--国旗纪念日
    EndTouchGuide="EndTouchGuide",--点击弱引导
    RoyalDartFly = "RoyalDartFly",
    ------------------------王城战----------------------------------
  --选择王城站市长礼包进行选人发放
    SelectRoyalGiftToGive = "SelectRoyalGiftToGive",
    --选择王城站市长礼包进行选人
    SelectRoyalGiftPlayerToGive = "SelectRoyalGiftPlayerToGive",
  --王城站礼包信息刷新
    RoyalGiftRefresh = "RoyalGiftRefresh",
    --王城站官职刷新
    OfficialPositionRefresh = "OfficialPositionRefresh",
    OfficialPositionRefresh2 = "OfficialPositionRefresh2",
    RoyalBattleActivity = "RoyalBattleActivity",
  --通知王城战活动信息
    KingInfoChange  = "KingInfoChange",
    BuildingCenterUpgradeNovice="BuildingCenterUpgradeNovice", --引导基地升级完成
    BuildingCenterJumpNovice="BuildingCenterJumpNovice", --新手引导跳转到基地
    BuildingCenterFreeClick="BuildingCenterFreeClick",--免费气泡出现
    GameReStart="GameReStart",--游戏重启
    LoadMapUIFinish = "LoadMapUIFinish",
    RefreshDailyRed="RefreshDailyRed",--日常任务红点
    DailyRedPointRefresh="DailyRedPointRefresh",--日常任务红点2
    CloseNewWarZoneRankPageTimer="CloseNewWarZoneRankPageTimer",--关闭新城竞赛rank页面的倒计时
    OpenTurnRadioChatEvent="OpenTurnRadioChatEvent",--打开转盘跑马灯
    ExitTurnRadioChatEvent="ExitTurnRadioChatEvent",--关闭转盘跑马灯
    ExitWelfareMainEvnet = "ExitWelfareMainEvnet", 
    RefreshTurntableredpoint = "RefreshTurntableredpoint",
    RefreshEquipInfo = "RefreshEquipInfo",--装备信息刷新
    RefreshEquipEvent = "RefreshEquipEvent",--装备交易事件变更
    EquipEventFinish = "EquipEventFinish",--装备交易事件变更
    SevenDayContentRefresh = "SevenDayContentRefresh", --成长之路界面刷新
    AddParentNode="AddParentNode", --GuideControllerModel添加节点
    WorldMapClickMarch ="WorldMapClickMarch",--点击行军路线
    CareSystemMarchAnim ="CareSystemMarchAnim",--点击行军路线
    UpdataPartInfos = "UpdataPartInfos",--更新战机零件
    UpdatePlaneInfo = "UpdatePlaneInfo",--更新飞机信息
    FalconGetTech = "FalconGetTech",--猎鹰获得科技
    FlyFalconGetTech = "FlyFalconGetTech",-- 飞猎鹰获得科技
    OnlineBonusInfoRefresh = "OnlineBonusInfoRefresh", --在线奖励跨天刷新
    RefreshHangarContent="RefreshHangarContent", --刷新战机机库界面
    RefreshAirDetailsContent="RefreshAirDetailsContent", --刷新战机详情界面
    KingKongBackCD = "KingKongBackCD", --金刚回来倒计时

    SkipNoviceGuide = "SkipNoviceGuide", --跳过新手引导
    EventDialogSoldier = "EventDialogSoldier", --大兵对话框
    EventDialogScale = "EventDialogScale", --对话框大小自适应
    RefreshUnionOfficer = "RefreshUnionOfficer", --刷新联盟官员职位
}

return EventDefines
