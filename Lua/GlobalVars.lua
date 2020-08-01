local GlobalVars = {}

--公用遮罩
GlobalVars.CommonMask = {}
--是否在重启中
GlobalVars.IsRestar = false
--是否在内城 默认内城 false为世界地图
GlobalVars.IsInCity = true
--用于判断触发式引导内外城(因为在云层切换过程中还属于内城，会有bug)
GlobalVars.IsInCityTrigger = true
--标准屏幕分辨率
GlobalVars.ScreenStandard = {width = 750, height = 1334}
--标准屏幕分辨率与屏幕分辨率的比例
GlobalVars.ScreenRatio = {x = GlobalVars.ScreenStandard.width / Screen.width, y = GlobalVars.ScreenStandard.height / Screen.height}
--实际大小
-- GRoot.inst.width, GRoot.inst.height
--滚动容器ScrollPanel默认滚动时间 0.5
GlobalVars.ScrollDelayTime = 0.01
GlobalVars.ScrollAnimTime = 0.5
--是否开发模式
GlobalVars.IsDevelop = false
--是否在触发式引导状态(当前在触发式引导时有可能会触发其他引导，所以当前处于引导状态时其他触发的引导会缓存)
GlobalVars.IsTriggerStatus = false
--是否在新手引导状态
GlobalVars.IsNoviceGuideStatus = false
--是否开启新手引导
GlobalVars.IsOpenNoviceGuide = true
--是否开启引导
GlobalVars.IsOpenTriggerGuide = true
--当前关键步
GlobalVars.CurrentKeyStep = 0
--内城建筑功能列表点击按钮
GlobalVars.ClickBuildFunction = false
--建筑队列点击按钮
GlobalVars.ClickBuilder = false
--建筑跳转按钮
GlobalVars.ClickBuildTurn = false
--是否有点击事件
GlobalVars.IsClicking = false
--是否允许弹窗
GlobalVars.IsAllowPopWindow = false
--是否检测建筑队列空闲状态
GlobalVars.IsCheckQueueIdle = true
--当前正在进行的引导ID
GlobalVars.NowTriggerId = 0
--侧边栏是否打开
GlobalVars.IsSidebarOpen = false
--剧情完成后动画
GlobalVars.IsTaskPlotAnim = false
--显示遮罩调试
GlobalVars.IsMaskView = false
--联盟投票翻译是否打开
GlobalVars.UnionVoteingIsTranslated = false
--用于判断场景没有切换云收到关闭只能
GlobalVars.IsHadChangeMap = false
--是否显示特效 (低端机不显示不显示特效,可降低卡顿)
--GlobalVars.IsShowEffect = Sdk.GetAndroidVersion() == 0 or Sdk.GetAndroidVersion() > 22
--GlobalVars.IsShowEffect = Sdk.GetAndroidVersion() == 0 or tonumber(Util.GetDeviceMemory()) == 0 or (tonumber(Util.GetDeviceMemory()) > 2048 or Sdk.GetAndroidVersion() > 22)
--是否开始前往功能
GlobalVars.IsJumpGuide=false
--是否可以弹单人界面积分提示弹窗
GlobalVars.IsOpenSingleScoreTips = false
--是否购买过月卡
GlobalVars.IsBuyMonthCard = true

--注册FairyGuiOnComplete
GlobalVars.GtweenOnComplete = "GtweenOnComplete"
--注册FairyGuiOnStart
GlobalVars.GtweenOnStart = "GtweenOnStart"
--注册FairyGuiOnUpdate
GlobalVars.GtweenOnUpdate = "GtweenOnUpdate"
--机型配置判定
function GlobalVars.IsShowEffect()
    if(Util.GetSystemInfoProcessorFrequency)then
        if(Sdk.GetAndroidVersion() == 0 or tonumber(Util.GetDeviceMemory()) == 0 or Util.GetSystemInfoProcessorFrequency() == 0) then
            return  true
        elseif(Util.GetSystemInfoProcessorFrequency() >= 1900 and tonumber(Util.GetDeviceMemory()) >= 2048) then
            return  true
        else
            return  false
        end
    else
        if(Sdk.GetAndroidVersion() == 0 or tonumber(Util.GetDeviceMemory()) == 0 or (tonumber(Util.GetDeviceMemory()) > 2048)) then
            return  true
        else
            return  false
        end
    end
end

_G.GlobalVars = GlobalVars
return GlobalVars