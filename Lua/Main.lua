local Main = {}

local DebugUtil = import("DebugUtil")
local GlobalVars = GlobalVars

function Main.OnInitOK()
    -- 开发模式
    GlobalVars.IsDevelop = GateConfig.GetStage() ~= "Production"
    -- 设置语言
    ResMgr.Instance:SetLanguage(Language.Current())
    ConfigMgr.Init()
    -- 初始化UIMgr
    UIMgr.Init()
    HULoading.SetLoadingTip("check_dynamicres")
    -- 启动调试
    DebugUtil.OpenLua_IdeDebug()
    -- 设置JSON
    JSON.encode_sparse_array(true)
    -- 初始化sdk
    SdkModel.Init()
    SdkModel.TrackBreakPoint(10001)
    -- 启动商店
    ShopModel:Init()
    -- 注册事件
    LoginModel.InitEvent()
    -- 设置推送
    NotifyModel.Init()
    -- 设置字体
    UIConfig.defaultFont = "Microsoft YaHei Light"
    -- 启动定时器
    GameUpdate.Create()
    Scheduler.Start()
    HULoading.SetLoadingTip("open_login")
    -- 加载资源
    if HotUpdate.IsDev or Auth.WorldData.isWhiteDevice then
        UIMgr:Open("Login")
    else
        UIMgr:Open("Loading")
    end

    GmModel.StartGM()

    --修改相机远景深度
    StageCamera.main.farClipPlane = 50
    local UILayer = CS.UnityEngine.LayerMask.NameToLayer("UI")
    local BeautyGirlLayer = CS.UnityEngine.LayerMask.NameToLayer("BeautyGirl")
    local Water = CS.UnityEngine.LayerMask.NameToLayer("Water")
    StageCamera.main.cullingMask = (1 << UILayer) + (1 << BeautyGirlLayer) + (1 << Water)

end

return Main
