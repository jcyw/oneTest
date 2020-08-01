--[[
  @Author: Simon
  @Date: 2020-06-10 19:42:24
  @LastEditTime: 2020-06-11 11:52:40
  @LastEditors: Simon
  @function: {}
--]]
local GD = _G.GD
local GameEnum = {}

local Global     = _G.Global
local indexer = _G.funex.indexer()

GameEnum.BubbleType = {
    TRAIN           = indexer(),--训练
    FREE            = indexer(),--免费
    HARVEST         = indexer(),--收获
    HELP            = indexer(),--帮助
    GIFT            = indexer(),--礼物
    SPECIAL_SHOP    = indexer(),--特价商城
    SCIENCE_AWARD   = indexer(),--科技研究完成奖励
    GM              = indexer(),--客服
    BEAUTY          = indexer(),--美女约会
    RANGE           = indexer(), --靶场飞镖免费
    MILITARY_SUPPLY = indexer(), --军需站免费
    UNION_WARFARE   = indexer(), --联盟战争
    ACTIVITY_CENTER = indexer(), --活动中心
    WELFARE         = indexer(), --福利中心
    FALCON_ACTIVITY = indexer(), --猎鹰行动
    EQUIP_MAKE      = indexer(),
    EQUIP_MAT_MAKE  = indexer(),
}

GameEnum.BuildFuncType = {
    DIAMONDS_FUNDPRICE    = 63,
    CUMULATIVE_ATTENDANCE = 64,
    DAILY_ATTENDANCE      = 65,
    GROWTH_FUND           = 67,
    MONTHLY_CARD          = 68,
    [Global.BuildingTankFactory] = 42,
    [Global.BuildingWarFactory] = 43,
    [Global.BuildingHelicopterFactory] = 44,
    [Global.BuildingVehicleFactory] = 45,
    [Global.BuildingSecurityFactory] = 25
}

GameEnum.IsAirplaneBuilding = {
    [Global.BuildingAirPlane1] = true, --直升机(步) 435000
    [Global.BuildingAirPlane2] = true, --直升机(步) 436000
    [Global.BuildingAirPlane3] = true, --直升机(步) 437000
}

GameEnum.MonsterId = {
    [Global.BuildingGodzilla] = Global.BeastGodzilla,
    [Global.BuildingKingkong] = Global.BeastKingkong
}

GameEnum.GuideType = {
    GUIDE_TYPE_NOVICE  = indexer(0),
    GUIDE_TYPE_TRIGGER = indexer(),
    GUIDE_TYPE_TASK    = indexer(),
}

GameEnum.GuideResult = {
    Cancel = 1
}

GameEnum.Const = {
    NO = 0,
    YES = 1,

    GOTO_SCENE          = indexer(0), --1:引导切换场景
    GOTO_OPEN_UI        = indexer(),  --2:引导打开UI
    GOTO_CLICK_BUILDING = indexer(),  --3:引导点击建筑、Billboard
    GOTO_CLICK_UI       = indexer(),  --4:引导点击UI
    GOTO_DIALOG         = indexer(),  --5:引导对话
    GOTO_VIDEO          = indexer(),  --6:引导播放视频
    GOTO_AREA           = indexer(),  --7:引导到区域
    GOTO_SLOT           = indexer(),  --8:引导到坑位
    GOTO_STORY          = indexer(),  --9:转场说明
}

GameEnum.SceneType = {
    CITY  = indexer(0),
    WORLD = indexer(),
    HERO_BATTLE = indexer(), --03use
}




--:请在下面添加新的枚举

--触发条件枚举
GameEnum.TriggerType = {
    --第一条件
    MainType = {
        Level               = indexer(0), --等级
        StartLvUp           = indexer(), --开始升级建筑
        EndLvUp             = indexer(), --结束升级建筑
        ActiveSkill         = indexer(), --激活主动技能
        JoinUnion           = indexer(), --加入联盟
        ClickWorld          = indexer(), -- 点击野外
        ClickMine           = indexer(), -- 点击矿
        ClickCastle         = indexer(), -- 点击敌人基地
        HaveInjure          = indexer(), -- 有伤兵
        OpenUI              = indexer(), -- 打开界面
        ClickTask           = indexer(), --点击任务
        LvUpOrEndLvUp       = indexer(), --又可以点立即升级触发，又可以点开始升级触发
        SendSoldierEnd      = indexer(), --送兵引导后续
        NoTrigger           = indexer(), --没有触发过的引导，且指挥中心大于某个等级
    },
    --第二条件
    SecondType = {
        InnerCity           = indexer(0), -- 是否在内城
        IsVip               = indexer(), -- 是否激活Vip
        IsAddSkillPoint     = indexer(), -- 是否添加过技能点
        InnerCityNoWindow   = indexer() -- 在内城且没有弹窗
    }
}

--跳转指引功能菜单枚举
GameEnum.JumpType = {
    Null            = 1,
    Upgrade         = 2,
    Cure            = 3,
    Speed           = 4,
    Tech            = 5,
    Promote         = 6,
    Use             = 7,
    Supply          = 8,
    Make            = 9,
    Train           = 10,
    Create          = 11,
    BeastCure       = 12,
    BeastResearch   = 13,
    Drats           = 14, --飞镖游戏
    Girls           = 15, --美女引导
    Forge           = 16, --装备锻造
}

--引导类型枚举
GameEnum.NoviceType = {
	Start               = 1,
    PlayMovie           = 2,  --播放动画
    Dialog              = 3, 	--对话
    TaskTurn            = 4,   --任务跳转
    End                 = 5, 		--结束
    TriggerStart        = 6, -- 触发式引导开启
    TriggerDialog       = 7, -- 触发式引导对话
    TriggerClick        = 8, -- 触发式引导点击
    TriggerBoth         = 9, --又有人物对话框，又有手指箭头
    TriggerEnd          = 10, -- 触发式引导结束
    TriggerPic          = 11, -- 触发引导播图片
    TriggerSpeDialog    = 12, -- 选择
    TriggerTxt          = 13, --框框带文字
}

--弱引导指引建筑按钮类型
GameEnum.UIType = {
    BuildCreateUI               = "BuildCreateUI", --建造UI
    CityCompleteUI              = "CityCompleteUI", --功能列表
    BuildUpgradeUI              = "BuildUpgradeUI", --建筑升级UI
    BuildTrainUI                = "BuildTrainUI", --训练UI
    BuildAccelerateUI           = "BuildAccelerateUI", --加速UI
    LaboratoryUI                = "LaboratoryUI", --研究科技UI
    LaboratorySkillUI           = "LaboratorySkillUI", --研究固定科技
    CityMapUI                   = "CityMapUI", --城市建造
    WorldMapPoint               = "WorldMapPoint", --世界地图指引
    WorldMapUI                  = "WorldMapUI", --世界地图
    WildMonsterUI               = "WildMonsterUI", --打怪
    ItemDetailUI                = "ItemDetailUI", --采矿功能UI
    UnionBtnUI                  = "UnionBtnUI", --联盟按钮UI
    UnionUI                     = "UnionStoreUI", --联盟主界面
    UnionAidUI                  = "UnionAidUI", --联盟援助
    CureArmyUI                  = "CureArmyUI", --治疗页面
    CureMonsterUI               = "CureMonsterUI", --治疗巨兽
    TipBarUI                    = "TipBarUI",
    TipBarUI2                   = "TipBarUI2",
    TipBarReceiveUI             = "TipBarReceiveUI",
    LockUI                      = "LockUI",
    BtnFreeCompleteUI           = "BtnFreeCompleteUI",
    OtherUI                     = "OtherUI",
    UIWelfareIcon               = "UIWelfareIcon",
    UIGodzillaIcon              = "UIGodzillaIcon",
    UIMainTaskIcon              = "UIMainTaskIcon",
    UISetupAccountUI            = "UISetupAccountUI",
    PlayerSkillPopupUI          = "PlayerSkillPopupUI",
    UIMapTurnBtnUI              = "UIMapTurnBtnUI",
    PlayerDetailsUI             = "PlayerDetailsUI",
    PlayerDetailsAddUI          = "PlayerDetailsAddUI",
    UIMapTurnMonster            = "UIMapTurnMonster", --地图打怪跳转
    NewGuidePlayerTip           = "NewGuidePlayerTip",
    BeautySystemMainUI          = "BeautySystemMainUI",
    BeautyDateUI                = "BeautyDateUI",
    BeautyExit                  = "BeautyExit",
    BeautyClothUI               = "BeautyClothUI",
    SearchIconUI                = "SearchIconUI",
    LookUpUI                    = "LookUpUI",
    btnQueueBuild               = "btnQueueBuild",
    btnQueueBuildLock           = "btnQueueBuildLock",
    MosterLouckUI               = "MosterLouckUI",
    PlayerDetailSkillUI         = "PlayerDetailSkillUI", --指挥官技能
    FalconUI                    = "FalconUI", --猎鹰行动页面
    ExpeditionUI                = "ExpeditionUI", --出征界面UI
    BuildUpgradeGotoBtn         = "BuildUpgradeGotoBtn", --建造页面点击前往按钮
    EquipmentUIItem             = "EquipmentUIItem", --装备制造界面装备材料栏Item
    EquipmentMakeFreeItem       = "EquipmentMakeFreeItem", --材料界面免费第二队列item
    EquipmentMakeMaterialBtn    = "EquipmentMakeMaterialBtn", --材料界面材料栏
    WorldCityTownTip            = "WorldCityTownTip", --外城浮标按钮
    BuildObject                 = "BuildObject", --指引建筑
}

GameEnum.DialogType = {
    BuildArmy = 0, --造兵队列空闲功能性对话
    BuildQueue = 1, --建造队列空闲功能性对话（这一部分跳转和点击主界面锤子逻辑相同jira-3165）
    BuildScience = 2, --科研队列空闲功能性对话
    Activity = 3, --活动推送形对话（枢纽争夺战、单人活动等）
    Soldier = 4 --代入感类对话
}
GameEnum.DialogTrainSort = {
    Global.BuildingTankFactory, --坦克工厂(步) 423000
    Global.BuildingWarFactory, --战车工厂(骑) 424000
    Global.BuildingHelicopterFactory, --直升机工厂(弓) 425000
    Global.BuildingVehicleFactory, --重型载具工厂(车) 426000
}

GameEnum.TrainType = {
    Global.BuildingTankFactory, --坦克工厂(步) 423000
    Global.BuildingWarFactory, --战车工厂(骑) 424000
    Global.BuildingHelicopterFactory, --直升机工厂(弓) 425000
    Global.BuildingVehicleFactory, --重型载具工厂(车) 426000
    Global.BuildingSecurityFactory --安保工厂 416000
}

GD.LVar("GameEnum", GameEnum)
return GameEnum
