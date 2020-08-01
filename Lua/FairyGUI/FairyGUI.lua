EventContext = CS.FairyGUI.EventContext
EventListener = CS.FairyGUI.EventListener
EventDispatcher = CS.FairyGUI.EventDispatcher
InputEvent = CS.FairyGUI.InputEvent
NTexture = CS.FairyGUI.NTexture
Container = CS.FairyGUI.Container
Image = CS.FairyGUI.Image
Stage = CS.FairyGUI.Stage
Controller = CS.FairyGUI.Controller
GObject = CS.FairyGUI.GObject
GGraph = CS.FairyGUI.GGraph
GGroup = CS.FairyGUI.GGroup
GImage = CS.FairyGUI.GImage
GLoader = CS.FairyGUI.GLoader
GMovieClip = CS.FairyGUI.GMovieClip
TextFormat = CS.FairyGUI.TextFormat
GTextField = CS.FairyGUI.GTextField
GRichTextField = CS.FairyGUI.GRichTextField
GTextInput = CS.FairyGUI.GTextInput
GComponent = CS.FairyGUI.GComponent
GList = CS.FairyGUI.GList
GRoot = CS.FairyGUI.GRoot
GLabel = CS.FairyGUI.GLabel
GButton = CS.FairyGUI.GButton
GComboBox = CS.FairyGUI.GComboBox
GProgressBar = CS.FairyGUI.GProgressBar
GSlider = CS.FairyGUI.GSlider
PopupMenu = CS.FairyGUI.PopupMenu
ScrollPane = CS.FairyGUI.ScrollPane
Transition = CS.FairyGUI.Transition
UIPackage = CS.FairyGUI.UIPackage
Window = CS.FairyGUI.Window
GObjectPool = CS.FairyGUI.GObjectPool
Relations = CS.FairyGUI.Relations
RelationType = CS.FairyGUI.RelationType
UIPanel = CS.FairyGUI.UIPanel
UIPainter = CS.FairyGUI.UIPainter
TypingEffect = CS.FairyGUI.TypingEffect
GTween = CS.FairyGUI.GTween
GTweener = CS.FairyGUI.GTweener
TweenManager = CS.FairyGUI.TweenManager
EaseType = CS.FairyGUI.EaseType
HitTestMode = CS.FairyGUI.HitTestMode
UIContentScaler = CS.FairyGUI.UIContentScaler
AlignType = CS.FairyGUI.AlignType
VertAlignType = CS.FairyGUI.VertAlignType
GoWrapper = CS.FairyGUI.GoWrapper
LongPressGesture = CS.FairyGUI.LongPressGesture
PinchGesture = CS.FairyGUI.PinchGesture
StageCamera = CS.FairyGUI.StageCamera
InputTextField = CS.FairyGUI.InputTextField

Object = CS.UnityEngine.Object
Vector2 = CS.UnityEngine.Vector2
Vector3 = CS.UnityEngine.Vector3
RenderMode = CS.UnityEngine.RenderMode
ParticleSystem = CS.UnityEngine.ParticleSystem
Quaternion = CS.UnityEngine.Quaternion
GUIUtility = CS.UnityEngine.GUIUtility

FUIWindow = CS.KSFramework.FUIController

fgui = {}

function fgui.register_extension(url, extension)
    FUIUtils.SetExtension(url, typeof(extension.base), extension)
end

function fgui.extension_class(base)
    return extension_class(base)
end
