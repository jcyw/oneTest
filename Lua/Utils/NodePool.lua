--[[
    Author: songzeming
    Function: 对象池
]]
if NodePool then
    return
end

NodePool = {}

--对象池Key值类型 [自定义]
NodePool.KeyType = {
    ResCollectAnim = "ResCollectAnim", --资源收集
    TechCollectAnim = "TechCollectAnim", --科技收集
    TrainArmyTrainAnim = "TrainArmyTrainAnim", --正在训练
    TrainArmyTrainComplete = "TrainArmyTrainComplete", --训练完成
    TrainArmyCollectEffect = "TrainArmyCollectEffect", --训练完成收集
    BuildUpgradeAnimInner = "BuildUpgradeAnimInner", --建筑建造、升级动画 城内、巨兽
    BuildUpgradeAnimOuter = "BuildUpgradeAnimOuter", --建筑建造、升级动画 城外
    BuildUpgradeAnimNest = "BuildUpgradeAnimNest", --建筑建造、升级动画 巢穴
    BuildUpgradeNormalEffect = "BuldUpgradeNormalEffect", --1*1、2*2建筑建造特效
    BuldUpgradeCityEffect = "BuldUpgradeCityEffect", --主基地建筑建造特效
    ReceiveAwardAnim = "ReceiveAwardAnim", --领奖动画
    ItemPropBig = "ItemPropBig", --道具
    ReceiveAwardLight = "ReceiveAwardLight", --领奖动画 光效
    ReceiveAwardRes = "ReceiveAwardRes", --领奖动画 资源
    ReceiveAwardLabel = "ReceiveAwardLabel", --领奖动画 标签
    ClickBlackEffect = "ClickBlackEffect", --城内地图点击空白区域特效
    HospitalBuildCure = "HospitalBuildCure", --战区医院等待治疗动画
    MapAreaUnlockEffect = "MapAreaUnlockEffect", --地图解锁区域解锁动画
    MapThumbnailTip = "MapThumbnailTip", --"缩略图tip"
    PlayerPowerExpEffect = "PlayerPowerExpEffect", --玩家战斗力经验特效
    PlayerPowerLightEffect = "PlayerPowerLightEffect", --玩家战斗力特效
    PlayerExpLightEffect = "PlayerExpLightEffect", --玩家经验特效
    -- ResearchEffect = "ResearchEffect", --科研特效
    MilitaryEffectNum = "MilitaryEffectNum", --军需站补给特效数字
    MilitaryEffectIcon = "MilitaryEffectIcon", --军需站补给特效icon
    SupplyEffect = "SupplyEffect", --军需站补给特效
    SupplyDoubleEffect = "SupplyDoubleEffect", --军需站补给特效 加倍
    TrainShowAnim = "TrainShowAnim", --训练界面兵种出场动画
    -- ScientistAnim = "ScientistAnim", --内城人物动画 科学家
    -- SoldierAnim = "SoldierAnim", --内城人物动画 大兵巡逻
    -- WorkerAnim = "WorkerAnim", --内城人物动画 工程师
    -- CityGodzillaAnim = "CityGodzillaAnim", --内城哥斯拉动画
    -- CityKingkongAnim = "CityKingkongAnim", --内城金刚动画
    OnlineRewardEffect = "OnlineRewardEffect", --在线奖励动画
    OnlineItemEffect = "OnlineItemEffect", --在线奖励动画
    -- FireworksEffect = "FireworksEffect", --烟花特效
    -- RibbonEffect = "RibbonEffect", --彩纸特效
    ShopLightEffect = "ShopLightEffect", --特价商城光效
    VipUpgradeEffect = "VipUpgradeEffect", --Vip升级特效
    -- BuildCenterUpgradeEffect = "BuildCenterUpgradeEffect", --指挥中心升级特效
    NestCloudEffect = "NestCloudEffect", --巢穴云雾特效
    -- ItemImage = "ItemImage", --图片
    CuePointCmpt = "CuePointCmpt", --提示点组件
    NoviceMovieController = "NoviceMovieController", -- 新手引导哥斯拉
    NoviceCharacter = "NoviceCharacter", 
    -- WeatherRainEffect = "WeatherRainEffect", --天气特效：下雨
    -- WeatherLightEffect = "WeatherLightEffect", --天气特效：闪电
    ActiveSkillEffect = "ActiveSkillEffect", --主动技能特效
    ResBuildSpeedUp = "ResBuildSpeedUp", --资源田加速特效
    LockBuildButton = "LockBuildButton", --建筑队列未解锁特效
    GiftItemEffect = "GiftItemEffect", --礼包特殊物品特效
    BuildButtonFreeEffect = "BuildButtonFreeEffect", --建筑队列按钮免费状态特效
    GiftEffect = "GiftEffect", --小礼物背景特效
    -- BeautyGirl_Effect = "BeautyGirl_Effect", -- 美女相关特效
    BeautyGirl_CardEffect = "BeautyGirl_CardEffect",
    TaskFinishEffect_Left = "TaskFinishEffect_Left", --主线任务完成按钮特效
    TaskFinishEffect_Right = "TaskFinishEffect_Right", --主线任务完成按钮特效
    TaskFinishEffect_Click = "TaskFinishEffect_Click", --主线任务完成按钮特效
    BeautyEnterEffect = "BeautyEnterEffect", --美女系统主界面按钮特效
    BeautyGirl_ClothesEffect = "BeautyGirl_ClothesEffect",
    BeautyGirl_CurtainEffect = "BeautyGirl_CurtainEffect",
    BeautyGirl_FavorEffect = "BeautyGirl_FavorEffect",
    BeautyGirl_FlowerEffect = "BeautyGirl_FlowerEffect",
    -- BeautyGirl_OnlineEffect = "BeautyGirl_OnlineEffect",
    BeautyGirl_SkillEffect = "BeautyGirl_SkillEffect",
    BackpackPopupEffect = "BackpackPopupEffect", --获得礼包物品弹窗特效
    TaskPlotConfirmEffect = "TaskPlotConfirmEffect", --章节任务全完成领取奖励特效
    BaseUpgradeEffect = "BaseUpgradeEffect", --主基地升级弹窗飞机特效
    GiftPaySuccess = "GiftPaySuccess", --礼包购买成功特效
    CardCilckEffect = "CardCilckEffect", --赌场翻牌特效
    BeautyIntroduceEffect = "BeautyIntroduceEffect", --美女介绍界面花瓣特效
    OnlineRewardUnlockEffect = "OnlineRewardUnlockEffect", --在线奖励解锁特效
    -- OnlineRewardUnlockMoveEffect = "OnlineRewardUnlockMoveEffect", --在线奖励解锁拖尾特效
    RangeTurntableHuanEffect = "RangeTurntableHuanEffect", --靶场十环特效
    RangeTurntableHitEffect = "RangeTurntableHitEffect", --飞镖击中靶场特效
    PlayerUpgradeBoxTitleEffect = "PlayerUpgradeBoxTitleEffect",
    MainUIGiftBtnEffect = "MainUIGiftBtnEffect", --礼包入口按钮特效
    TaskPlotEffect = "TaskPlotEffect", --章节任务流光特效
    ResHarvestEffect="ResHarvestEffect",--资源丰收特效
    -- ResCollectEffect="ResCollectEffect",--收取资源特效
    GiftIconEffect = "GiftIconEffect", -- 首冲特效
    BtnEffect = "BtnEffect", -- 按钮流光特效
    -- ProgressBarEffect="ProgressBarEffect",--进度条特效
    GemFundEffect="GemFundEffect",--长留基金特效
    Effect_Radar_sweep = "Effect_Radar_sweep", --猎鹰行动扫描特效
    SevenDaySignInEffect="SevenDaySignInEffect",--七日签到特效
    GiftBoxEffect="GiftBoxEffect",--礼物宝箱特效
    Effect_Button_Light="Effect_Button_Light",--猎鹰按钮特效
    UnionMedalEffect="UnionMedalEffect",--联盟徽章特效
    BuildBeastHospitalEffect="BuildBeastHospitalEffect",--巨兽医院常驻特效
    -- BuildBeastHospitalArrow_Left="BuildBeastHospitalArrow_Left",--巨兽医院左箭头特效
    -- BuildBeastHospitalArrow_Right="BuildBeastHospitalArrow_Right",--巨兽医院右箭头特效
    MainUIHeadEffect = "MainUIHeadEffect",--主界面头像框特效
    TurntableCirCle = "TurntableCirCle",
    TurntableGet = "TurntableGet",
    TurntableFrame = "TurntableFrame",
    NoviceHelicopter = "NoviceHelicopter", --金刚引导spine
    -- SidebarQueue = "SidebarQueue",--侧边栏队列特效
    -- EquipWearing = "EquipWearing",--装备穿戴动画
    HammerBuild = "hammerBuild",--低配建筑锤子效果
    LaboratoryResearching = "LaboratoryResearching",--科技正在研究
    LaboratoryResearchEnd = "LaboratoryResearchEnd",--科技研究结束
    NewReceiveAwardAnim="NewReceiveAwardAnim",--主界面推荐栏新领奖动画
    NewReceiveAwardRes="NewReceiveAwardRes",--主界面推荐栏新领奖动画资源
    ArenaWinEffect="ArenaWinEffect",--竞技场胜利特效
    ArenaLightEffect="ArenaLightEffect",--竞技场战斗闪光特效
    EquipMaterialMake = "EquipMaterialMake",--装备材料生产特效
    -- EquipMaterialGet = "EquipMaterialGet",--装备材料收取特效
    RankMainEffect="RankMainEffect",--排行榜火星特效
    StarShowEffect="StarShowEffect",--星星出现特效
    StarSweepEffect="StarSweepEffect",--星星扫光特效
    BackpackIconAnim = "BackpackIconAnim",--背包道具使用特效
    BackpackIconObj = "BackpackIconObj",--背包道具动画组件
    CenterBuildingEffect = "CenterBuildingEffect",--指挥中心建造特效
    WallBuildingEffect = "WallBuildingEffect",--城墙建造特效
    InnerBuildingEffect = "InnerBuildingEffect",--内城建造特效
    OuterBuildingEffect = "OuterBuildingEffect",--外城建造特效
}

local Info = {} --对象包名,d对象名称缓存
local Pool = {} --对象池缓存

--初始化对象池
function NodePool.Init(key, pkgName, uiName)
    if Info[key] then
        --已经初始化过该对象
        return
    end
    if not pkgName or not uiName then
        Log.Warning("NodePool.Init 没有传入对象的包名或对象名 pkgName: {0}, uiName: {1}", pkgName, uiName)
        return
    end
    Info[key] = {
        pkgName = pkgName,
        uiName = uiName
    }
end

--将对象放回对象池
function NodePool.Set(key, value)
    if not Info[key] then
        Log.Warning("NodePool.Set 对象池没有初始化包名和对象名 key: {0}", key)
        return
    end
    if not Pool[key] then
        Log.Warning("NodePool.Set 对象池没有提前生成对象 key: {0}", key)
        return
    end
    value.visible = false
    for _, v in ipairs(Pool[key]) do
        if v == value then
            --防止已经加入对象池的对象再次被添加
            return
        end
    end
    -- value:RemoveFromParent()
    table.insert(Pool[key], value)
end

--将对象从对象池中取出
function NodePool.Get(key)
    if not Info[key] then
        Log.Warning("NodePool.Get 对象池没有初始化包名和对象名 key: {0}", key)
        return
    end
    if not Pool[key] then
        Pool[key] = {}
    end
    if next(Pool[key]) == nil then
        local obj = UIMgr:CreateObject(Info[key].pkgName, Info[key].uiName)
        if not obj then
            Log.Warning("NodePool.Get 对象创建失败 key: {0}", key,Info[key].pkgName,Info[key].uiName)
            return
        end
        --obj:PoolObject(key)
        return obj
    end
    local obj = Pool[key][1]
    table.remove(Pool[key], 1)
    --(优化 父容器释放是 对象池特效会被释放 需要是一个是否被释放的判定)
    if(obj)then
        obj.visible = true
        obj.alpha = 1
        return obj
    else
        local tempObj = UIMgr:CreateObject(Info[key].pkgName, Info[key].uiName)
        if not tempObj then
            Log.Error("NodePool.Get 再次对象创建失败 key: {0}", key,Info[key].pkgName,Info[key].uiName)
            return
        end
        --tempObj:PoolObject(key)
        return tempObj
    end
end

--将对象从对象池中删除
function NodePool.SelfRemove(key)
    if not Info[key] then
        -- Log.Warning("NodePool.Remove 对象池没有初始化包名和对象名 key: {0}", key)
        return
    end
    if not Pool[key] then
        -- Log.Warning("NodePool.Remove 对象池没有提前生成对象 key: {0}", key)
        return
    end
    local objs = Pool[key]
    for k, v in pairs(objs) do
        v = nil
        objs[k] = nil
    end
    Pool[key] = nil
end

--将对象从对象池中删除
function NodePool.Remove(key)
    if not Info[key] then
        -- Log.Warning("NodePool.Remove 对象池没有初始化包名和对象名 key: {0}", key)
        return
    end
    if not Pool[key] then
        -- Log.Warning("NodePool.Remove 对象池没有提前生成对象 key: {0}", key)
        return
    end
    local objs = Pool[key]
    for k, v in pairs(objs) do
        if v then
            v:Dispose()
        end
        v = nil
        objs[k] = nil
    end
    Pool[key] = nil
end

--清空对象池 [重启用]
function NodePool.Clear()
    for _, v in pairs(Pool) do
        for k, value in pairs(v) do
            if value then
                value:Dispose()
            end
            value = nil
            v[k] = nil
        end
    end
    Info = {}
    Pool = {}
end

return NodePool
