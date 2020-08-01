table.inspect = import("Utils/inspect")

import("Common/functions")
import("FairyGUI/FairyGUI")

-- Configs
import("ConfigFiles/ConfigMgr")
Global = import("gen/excels/Global")
GlobalBattle = import("gen/excels/GlobalBattle")
GlobalAlliance = import("gen/excels/GlobalAlliance")
GlobalItem = import("gen/excels/GlobalItem")
GlobalMisc = import("gen/excels/GlobalMisc")
GlobalBanner = import("gen/excels/GlobalBanner")
GlobalColor = import("gen/excels/GlobalColor")
ApiMap = import("gen/net/Lua/ApiMap")

-- Enums
import("Enum/CommonType")
import("Enum/MarchType")
import("Enum/TipType")
import("Enum/PlayerDataEnum")
import("Enum/PropType")
import("Enum/BuildType")
import("Enum/CityType")
import("Enum/EventType")
import("Enum/UnionType")
import("Enum/I18nType")
import("Enum/ArmyType")
import("Enum/ItemType")
import("Enum/ColorType")
import("Enum/BuffType")
import("Enum/AnimationType")
--import("Enum/JumpType")
import("Enum/ActivitySkillType")
--import("Enum/NoviceType")
--import("Enum/TriggerType")
import("Enum/PrefabType")
import("Enum/GiftEnum")

--Tool 放到TimeUtil之前
_G.Tool = import("Helper/Tool")
-- Utils
import("Utils/SceneObjUtils")
import("Utils/TimeUtil")
import("Utils/MathUtil")
import("Utils/StringUtil")
import("Utils/ConfirmPopupTextUtil")
import("Utils/GameUtil")
import("Utils/TextUtil")
import("Utils/EffectPool")
import("Utils/NodePool")
import("Utils/Util")
import("Utils/Scheduler")
import("Utils/TipUtil")
import("Utils/EffectTools")
CSCoroutine = import("Utils/CSCoroutine")
MathUtil = import("Utils/MathUtil")
JSON = require("CJson")

-- Helpers
import("Helper/UITool")
import("Helper/MainCity")
import("Helper/SqliteHelper")
import("Helper/LoadHelper")

-- Models
_G.Model = import("Model/Model")
import("Model/NotifyModel")
import("Model/LoginModel")
import("Model/AudioModel")
import("Model/GuidedModel")
import("Model/RedPointModel")
import("Model/UserModel")
import("Model/SdkModel")
import("Model/MapModel")
import("Model/PlayerDataModel")
import("Model/MailModel")
import("Model/TurnModel")
import("Model/SystemSetModel")
import("Model/ShopModel")
import("Model/RoyalBattle/RoyalModel")

MaskModel = import("Model/MaskModel")
MapModel = import("Model/MapModel")
BuildModel = import("Model/BuildModel")
GameShareModel = import("Model/GameShareModel")
CommonModel = import("Model/CommonModel")
BuffModel = import("Model/BuffModel")
ActivityModel = import("Model/ActivityModel")
CuePointModel = import("Model/CuePoint/CuePointModel")
AnimationLayer = import("Model/Animation/AnimationLayer")
AnimationModel = import("Model/Animation/AnimationModel")
WeatherModel = import("Model/CityMap/WeatherModel")
UnlockModel = import("Model/CityMap/UnlockModel")
ScrollModel = import("Model/CityMap/ScrollModel")
CityMapModel = import("Model/CityMap/CityMapModel")
JumpMap = import("Model/JumpMap")
ArmiesModel = import("Model/ArmiesModel")
EquipModel = import("Model/EquipModel")
PlaneModel = import("Model/PlaneModel")
NetSaveModel = import("Model/NetSaveModel")
FunOpenMgr = import("Mgr/FunOpenMgr")

-- -- EventCenter
-- import("EventCenter/EventDefines")
-- Event = import("EventCenter/events")

-- Net
import("Net/Network")

-- UIs
UIMgr = import("Common/UIMgr")
_G.UIMgr = UIMgr
CSWorldMap = import("UI/WorldMap/CSWorldMap")
WorldMap = import("UI/WorldMap/WorldMap")
PopupWindowQueue = import("UI/Common/PopupWindowQueue")

-- 通用MonoBehaviour
GameUpdate = import("Behaviour/GameUpdate")
-- 动态资源
DynamicRes = import("HotUpdate/DynamicRes/DynamicRes")
DynamicModel = import("Model/Common/DynamicModel")
-- 兼容更新资源
PreHotUpdateRes = import("HotUpdate/PreHotUpdateRes/PreHotUpdateRes")
