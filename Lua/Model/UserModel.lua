local GD = _G.GD
if UserModel then
    return UserModel
end
UserModel = {}

UserModel._init = false

UserModel.data = {
    accountId = "", -- 玩家账户
    token = "", -- 登录验证码
    connectHost = "", -- 游戏服地址
    port = "" -- 游戏服端口
}

local TaskModel = import("Model/TaskModel")
local ModelType = import("Enum/ModelType")
local DailyTaskModel = import("Model/DailyTaskModel")
local WelfareModel = import("Model/WelfareModel")
local BuffItemModel = import("Model/BuffItemModel")
local LanguageModel = import("Model/LanguageModel")
local DressUpModel = import("Model/DressUpModel")
function UserModel.AuthParams()
    UserModel.data = Auth.WorldData
    local data = Auth.WorldData
    return {
        AccountId = data.accountId,
        Token = data.token
    }
end

function UserModel.SceneId()
    return Auth.WorldData.sceneId
end

function UserModel.ConnectParams()
    local data = Auth.WorldData
    return {
        Host = data.connectHost,
        Port = data.port
    }
end

function UserModel.SaveServerData(serverInfo, gate)
    local data = UserModel.data
    data.accountId = serverInfo.accountId
    data.connectHost = serverInfo.connectHost
    data.port = serverInfo.port
    data.token = serverInfo.sessionToken
    data.sceneId = serverInfo.sceneId
    data.gate = gate
end

--断线重连检测
function UserModel.ReconnectCheck()
    if not CommonType.LOGIN then
        return
    end
    --断线重连
    if Model.Player.AllianceId == "" then
        --没有联盟(被踢出联盟、本身没有联盟)
        UIMgr:ClosePopAndTopPanel()
    end
end

function UserModel.Login(cb)
    Loading.SetLoadingTip("login_game")
    local failCb = function()
        Network.ReloginAlert("ALERT_CONNECT_NET_ERROR", true)
    end
    local timeOutCb = function()
        Network.ReloginAlert("ALERT_CONNECT_NET_ERROR", true)
    end
    local deviceLanguage = Language.Device()
    local params = {
        UserId = Auth.WorldData.accountId, -- string
        AccountId = "", -- string
        Country = Util.GetCountry(), -- string
        Device = Util.GetDevice(), -- string
        DeviceOS = Util.GetDeviceOS(), -- string
        DeviceId = Util.GetDeviceId(), -- string
        AppVersion = GameVersion.localV, --string
        UID = SdkModel.GetUserId(),
        Language = LanguageModel.GetConfigByShortName(deviceLanguage).id,
        DeviceLanguage = deviceLanguage,
        APKVersion = GameVersion.GetInAppVersion().String
    }
    CS.KSFramework.Main.Instance:SetData("ServerId", Auth.WorldData.sceneId)
    CS.KSFramework.Main.Instance:SetData("PlayerId", Auth.WorldData.accountId)
    CS.KSFramework.Main.Instance:SetData("GameVersion", GameVersion.localV)

    --input = assert(io.read("*number"))
    --print(input)
    
    Network.ResetPacketId()
    Net.Logins.Login(
        params.UserId,
        params.AccountId,
        params.Country,
        params.Device,
        params.DeviceOS,
        params.DeviceId,
        params.DeviceAdId,
        params.AppVersion,
        params.UID,
        params.Language,
        params.DeviceLanguage,
        params.APKVersion,
        function(rsp)
            Tool.SyncTime(
                function()
                    Network.MarkLogin()
                    UserModel.InitData(rsp)
                    cb()
                end
            )
        end,
        failCb,
        timeOutCb
    )
end

function UserModel.StartNewGame()
    Net.UserInfo.StartNewGame(Network.Relogin)
end

function UserModel.SwitchRole(roleId)
    Net.UserInfo.SwitchRole(roleId, Network.Relogin)
end

function UserModel.InitData(loginInfo)
    PlayerDataModel:Init(UserModel.data.accountId)
    Model.InitPlayer(loginInfo.User)
    Model.Account = Auth.WorldData
    Model.Init(ModelType.Items, "ConfId", loginInfo.Items)
    Model.Init(ModelType.Buildings, "Id", loginInfo.Buildings)
    Model.Init(ModelType.Resources, "Category", loginInfo.Resources)
    Model.Init(ModelType.ResBuilds, "Id", loginInfo.ResBuilds)
    Model.Init(ModelType.ResProtects, "Category", loginInfo.ResProtects)
    Model.Init(ModelType.InjuredArmies, "ConfId", loginInfo.InjuredArmies)
    Model.Init(ModelType.Armies, "ConfId", loginInfo.Armies)
    Model.Init(ModelType.UpgradeEvents, "Uuid", loginInfo.UpgradeEvents)
    --建造升级
    Model.Init(ModelType.TrainEvents, "Uuid", loginInfo.TrainEvents)
    --造兵
    Model.Init(ModelType.MissionEvents, "Uuid", loginInfo.MissionEvents)
    --行军
    Model.Init(ModelType.CureEvents, "Uuid", loginInfo.CureEvents)
    --治疗
    Model.Init(ModelType.BeastCureEvents, "Uuid", loginInfo.BeastCureEvents)
    --巨兽治疗
    Model.Init(ModelType.Bookmarks, "Id", loginInfo.Bookmarks)
    Model.Init(ModelType.Techs, "ConfId", loginInfo.Techs)
    Model.Init(ModelType.BeastTechs, "ConfId", loginInfo.BeastTechs)
    Model.Init(ModelType.Limits, "Category", loginInfo.Limits)
    Model.Init(ModelType.MarchWarnings, "Uuid", loginInfo.MarchWarnings)
    Model.Init(ModelType.BuffItem, "Id", loginInfo.BuffItems)
    Model.Init(ModelType.Buffs, "ConfId", loginInfo.Buffs)
    Model.Init(ModelType.Formations, "FormId", loginInfo.Formations)
    Model.Init(ModelType.AppliedAlliance, "AllianceId", loginInfo.AppliedAlliance)
    Model.Init(ModelType.AccomplishedAchievement, "Id", loginInfo.AccomplishedAchievement)
    Model.Init(ModelType.GiantBeasts, "Id", loginInfo.GiantBeasts)
    Model.Init(ModelType.NotifySettings, "SettingId", loginInfo.NotifySettings)
    Model.Init(ModelType.AllianceBookmarks, "Category", loginInfo.AllianceBookmarks)
    Model.Init(ModelType.MonsterVisitInfo, "ActivityId", loginInfo.MonsterVisitInfo)
    Model.InitOtherInfo(ModelType.User, loginInfo.User)
    Model.InitOtherInfo(ModelType.Wall, loginInfo.Wall)
    Model.InitOtherInfo(ModelType.MSInfos, loginInfo.MSInfos)
    Model.InitOtherInfo(ModelType.UserAllianceInfo, loginInfo.UserAllianceInfo)
    --Model.InitOtherInfo(ModelType.NextOnlineBonus, loginInfo.NextOnlineBonus)
    Model.InitOtherInfo(ModelType.OnlineBonusList, loginInfo.OnlineBonusList)
    Model.InitOtherInfo(ModelType.PlayerSkills, loginInfo.PlayerSkills)
    Model.InitOtherInfo(ModelType.ActivitySkills, loginInfo.AvailableActivitySkills)
    Model.InitOtherInfo(ModelType.ChapterTasksInfo, loginInfo.ChapterTasksInfo)
    Model.InitOtherInfo(ModelType.GiftPacks, loginInfo.GiftPacks)
    Model.InitOtherInfo(ModelType.CenterUpgradeGifts, loginInfo.CenterUpgradeGifts)
    Model.InitOtherInfo(ModelType.BeautyOnlineBonus, loginInfo.BeautyOnlineBonus)

    ---装备
    _G.Model.InitOtherInfo(ModelType.JewelMakeInfo, loginInfo.JewelMakeInfo)
    if loginInfo.EquipEvents and loginInfo.EquipEvents.EquipId ~= 0 then
        _G.Model.InitOtherInfo(ModelType.EquipEvents, loginInfo.EquipEvents)
    end
    _G.Model.Init(ModelType.EquipBag, "Uuid", loginInfo.EquipBag)
    _G.Model.Init(ModelType.JewelBag, "ConfId", loginInfo.JewelBag)
    _G.Model.Init(ModelType.EquipSlot, "Pos", loginInfo.EquipSlot)

    -- 装扮
    DressUpModel.InitUser(loginInfo.User.DressUpUsing)

    -- 关怀系统
    Model.InitOtherInfo(ModelType.BattleCareInfo, loginInfo.BattleCareInfo)
    -- 服务器保存的设置
    Model.InitOtherInfo(ModelType.NetSaveInfo, loginInfo.SystemSettings)

    -- 战机系统
    Model.InitOtherInfo(ModelType.PlanePartList, loginInfo.PartBag)
    Model.InitOtherInfo(ModelType.PlaneList, loginInfo.PlaneBag)
    Model.InitOtherInfo(ModelType.CollectPlaneList, loginInfo.CollectPlaneList)

    Model.Builders = loginInfo.Builders
    Model.AllMessageIndex = loginInfo.AllMessageIndex
    Model.SpecialShopRefreshFreeTimes = loginInfo.SpecialShopRefreshFreeTimes
    Model.UnreadAllianceMessages = loginInfo.UnreadAllianceMessages
    Model.EnergyRecoverTick = loginInfo.EnergyRecoverTick
    UnionModel.InitHelpTask(loginInfo.AllianceTaskInfo)
    -- DailyTaskModel:SetRedDailyTask(true, loginInfo.AccomplishedDailyAward)
    WelfareModel:AwardFinishToAct(loginInfo.AwardFinish)
    WelfareModel.SetActiveActivityId(loginInfo.ActivityIds)
    -- print("ActivityIds rsp ======================".. table.inspect(loginInfo.ActivityIds))
    Model.MainTaskInfo = loginInfo.MainTaskInfo
    Model.NextBonusTime = loginInfo.NextBonusTime
    Model.OnlineBonusTime = loginInfo.OnlineBonusTime
    Model.PlayerSkillCurPage = loginInfo.PlayerSkillCurrentPage
    Model.ResearchGift = loginInfo.ResearchGift
    Model.BeastResearchGift = loginInfo.BeastTechGift
    Model.UnlockedAreas = loginInfo.UnlockedAreas
    Model.ServerMaxMonsterLevel = loginInfo.ServerMaxMonsterLevel
    Model.GrowthFundBought = loginInfo.GrowthFundBought
    Model.NewUser = loginInfo.NewUser
    Model.FinishedGodzillaCategory = loginInfo.FinishedGodzillaCategory
    Model.EveryGiftTaken = loginInfo.EveryGiftTaken
    Model.BoughtGemIds = loginInfo.BoughtGemIds
    Model.MapConfId = loginInfo.MapConfId
    Model.RechargeInThirtyDays = loginInfo.RechargeInThirtyDays
    Model.ServerShield = loginInfo.ServerShield
    Model.ServerShieldStart = loginInfo.ServerShieldStart
    Model.MainTaskNewUser = loginInfo.MainTaskNewUser--玩家是否是新号
    BuffItemModel.Refresh()
    TaskModel.InitAddTaskInfo(Model.MainTaskInfo)
    Model.MemorialDayInfos = loginInfo.MemorialDayInfos
    Model.ArmsRaceInfos = loginInfo.ArmsRaceInfo
    -- print("EagleHuntInfos rsp ======================".. table.inspect(loginInfo.EagleHuntInfo))
    Model.EagleHuntInfos = loginInfo.EagleHuntInfo
    -- print("Model.EagleHuntInfos rsp ======================".. table.inspect(Model.EagleHuntInfos))
    Model.HuntHelicopters = loginInfo.Helicopters
    --print("Model.HuntHelicopters rsp ======================".. table.inspect(Model.HuntHelicopters))
    Model.GemFundInfo = loginInfo.GemFundInfo--长留基金是否有可领取的奖励
	--Log.Error("DiamondFundInfo rsp ======================: {0}", table.inspect(loginInfo.DiamondFundInfos))
    Model.DiamondFundInfo = loginInfo.DiamondFundInfos
    Model.ChatShareTimes = loginInfo.ChatShareTimes

    --缓存的新获取物品
    GD.ItemAgent.InitCacheNewItemsStatus()

    --设置玩家语言设置信息
    LanguageModel.SetLanguageCache(Model.User.Language)

    -- LoginModel.EndGm()
    --初始化  aihelp   sdk
    local name = StringUtil.GetI18n("configI18nCommons", "UI_GAME_NAME")
    Sdk.AiHelpSetName(name)
    Sdk.AiHelpSetUserName(Model.Player.Name)
    Sdk.AiHelpSetUserId(string.gsub(Auth.WorldData.accountId, "#", "-"))
    Sdk.AiHelpSetServerId(Model.Account.sceneId)
    Sdk.AiHelpSetSDKLanguage(ConfigMgr.GetItem("configLanguages", Model.User.Language).language_faq)

    --初始化联盟战争未读信息
    if Model.Player.AllianceId ~= "" then
        UnionModel.InitUnionWarfarePoint()
    end

    MailModel:Init()

    UserModel._init = true

    -- --如果大于5堡且没有触发金刚引导，则触发
    -- if Model.Player.Level >= 5 then
    --     for _, v in pairs(Model.Player.TriggerGuides) do
    --         if v.Id == 14600 then
    --             return
    --         end
    --     end
    --     table.insert(Model.Player.TriggerGuides, {Step = 0, Id = 14600, Finish = false})
    -- end
end

function UserModel:GetNotReadAmount() --玩家信息未读
    local amount = 0

    amount = amount + self:NotReadPlayerNumber()
    amount = amount + self:GetGmMsgNotReadAmount()

    return math.ceil(amount)
end

function UserModel:NotReadPlayerNumber() -- 账号是否绑定
    local _bindList = SdkModel.GetBindList()
    for _, v in ipairs(_bindList) do
        if v.isBind == "1" then
            return 0
        end
    end
    return 1
end

function UserModel.GetGmMsgNotReadAmount() -- GM未读消息数量
    return SdkModel.GmNotRead
end

local SkillModel = import("Model/SkillModel")
function UserModel:NotReadPlayerSkillPoints()
    local points = SkillModel.GetSkillPoints(SkillModel.GetCurPage())
    return points
end

return UserModel
