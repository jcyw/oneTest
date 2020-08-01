if not Util then
    Util = CS.KSFramework.Util
end

if not ByteBuffer then
    ByteBuffer = CS.KSFramework.ByteBuffer
end

if not Time then 
	Time = CS.UnityEngine.Time
end

if not WWW then
    WWW = CS.UnityEngine.WWW
end

if not UnityWebRequest then
    UnityWebRequest = CS.UnityEngine.Networking.UnityWebRequest
end

if not UnityEngine then
    UnityEngine = CS.UnityEngine
end

if not Color then
    Color = CS.UnityEngine.Color
end

if not FullScreenMovieControlMode then
    FullScreenMovieControlMode = CS.UnityEngine.FullScreenMovieControlMode
end

if not FullScreenMovieScalingMode then
    FullScreenMovieScalingMode = CS.UnityEngine.FullScreenMovieScalingMode
end

if not GameObject then
    GameObject = CS.UnityEngine.GameObject
end

if not KSGame then
    KSGame = CS.KSFramework.KSGame
end

if not LuaModule then
    LuaModule = CS.KSFramework.LuaModule
end

if not FUIController then
    FUIController = CS.KSFramework.FUIController
end

if not FUIUtils then
    FUIUtils = CS.KSFramework.FUIUtils
end

if not KResourceModule then
    KResourceModule = CS.KEngine.KResourceModule
end

if not NetworkManager then
    NetworkManager = CS.KSFramework.NetworkManager
end

if not ObjectPoolManager then
    ObjectPoolManager = CS.KSFramework.ObjectPoolManager
end

if not ResMgr then
    ResMgr = CS.KSFramework.ResMgr
end

if not UIPackage then
    UIPackage = CS.FairyGUI.UIPackage
end

if not UBBParser then
    UBBParser = CS.FairyGUI.Utils.UBBParser.inst
end

if not UIConfig then
    -- body
    UIConfig = CS.FairyGUI.UIConfig
    UIConfig.bringWindowToFrontOnClick = false
end

if not GObject then
    GObject = CS.FairyGUI.GObject
end

if not GRoot then
    GRoot = CS.FairyGUI.GRoot
end

if not TweenPropType then
    TweenPropType = CS.FairyGUI.TweenPropType
end

if not DragDropManager then
    DragDropManager = CS.FairyGUI.DragDropManager
end

if not Log then
    Log = CS.KEngine.Log
end

if not LuaBehaviour then
    LuaBehaviour = CS.KSFramework.LuaBehaviour
end

if not ObjectUtil then
    ObjectUtil = CS.KSFramework.ObjectUtil
end

if not UILayerType then
    UILayerType = {
        ["LOW"] = "low",
        ["MID"] = "mid",
        ["UP"] = "up",
        ["TOP"] = "top"
    }
end

if not KSUtil then
    KSUtil = CS.KSFramework.Util
end

if not EmojiesMgr then
    EmojiesMgr = CS.KSFramework.EmojiesMgr.getInstance()
end

if not Screen then
    Screen = CS.UnityEngine.Screen
end

if not Application then
    Application = CS.UnityEngine.Application
end

if not Sdk then
    Sdk = CS.KSFramework.InitSdk
end

if not XLuaEvent then
    XLuaEvent = CS.KSFramework.XLuaEvent
end

if not XluaEventType then
    XluaEventType = CS.KSFramework.XluaEventType
end

if not Input then
    Input = CS.UnityEngine.Input
end
if not CVector2 then
    CVector2 = CS.UnityEngine.Vector2
end

if not CVector3 then
    CVector3 = CS.UnityEngine.Vector3
end

if not CVector4 then
    CVector4 = CS.UnityEngine.Vector4
end

if not TouchPhase then
    TouchPhase = CS.UnityEngine.TouchPhase
end

if not Rect then
    Rect = CS.UnityEngine.Rect
end

if not AudioManager then
    AudioManager = CS.KSFramework.AudioManager.getInstance()
end

if not AudioSource then
    AudioSource = CS.UnityEngine.AudioSource
end

if not AudioClip then
    AudioClip = CS.UnityEngine.AudioClip
end

if not NotifyMgr then
    NotifyMgr = CS.KSFramework.NotifyMgr
end

if not GateConfig then
    GateConfig = CS.KSFramework.GateConfig
end

if not MaterialPropertyBlock then
    MaterialPropertyBlock = CS.UnityEngine.MaterialPropertyBlock
end

if not DOTween then
    DOTween = CS.DG.Tweening.DOTween
    DOTween.defaultEaseType = CS.DG.Tweening.Ease.Linear
end

if not BoxCollider then
    BoxCollider = CS.UnityEngine.BoxCollider
end

if not Camera then
    Camera = CS.UnityEngine.Camera
end

if not VideoPlayer then
    VideoPlayer = CS.UnityEngine.Video.VideoPlayer
end

if not UObject then
    UObject = CS.UnityEngine.Object
end

if not DOTween then
    DOTween = CS.DG.Tweening.DOTween
end

if not AssetBundle then
    AssetBundle = CS.UnityEngine.AssetBundle
end

if not KTool then
    KTool = CS.KEngine.KTool
end

if not CustomGLoader then
    CustomGLoader = CS.FairyGUI.CustomGLoader
end

if not Texture2D then
    Texture2D = CS.UnityEngine.Texture2D
end

if not CustomInput then
    CustomInput = CS.KSFramework.CustomInput
end

PlayformEnum = {
    UNITYEDITOR = "UNITYEDITOR", --unity编辑器
    WINDOWS = "WINDOWS",
    ANDROID = "ANDROID", --安卓
    IPHONE = "IPHONE", --苹果
    OTHER = "OTHER" --其他
}