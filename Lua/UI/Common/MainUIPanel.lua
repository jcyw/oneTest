--[[
    Author: All
    Function: 主界面
]]
local GD = _G.GD
local MainUIPanel = UIMgr:NewUI("MainUIPanel")
local BuildModel = import("Model/BuildModel")
local UnionModel = import("Model/UnionModel")
local MarchLineModel = import("Model/MarchLineModel")
local ChatModel = import("Model/ChatModel")
local Emojies = import("Utils/Emojies")
local TaskModel = import("Model/TaskModel")
local DailyTaskModel = import("Model/DailyTaskModel")
local WelfareModel = import("Model/WelfareModel")
local RadarModel = import("Model/RadarModel")
local WallModel = import("Model/WallModel")
local JumpMap = import("Model/JumpMap")
local BlockListModel = import("Model/BlockListModel")
local GuidePanelModel = import("Model/GuideControllerModel")
local MissionEventModel = import("Model/MissionEventModel")
local WorldMap = import("UI/WorldMap/WorldMap")
local SkillModel = import("Model/SkillModel")
local UIType = _G.GD.GameEnum.UIType
local GiftModel = import("Model/GiftModel")
local MonsterData = import("Model/MonsterModel")
local ParadeSquareModel = import("Model/Animation/ParadeSquareModel")
local AnimationArmy = import("Model/Animation/AnimationArmy")
local AnimationArmyQueue = import("Model/Animation/AnimationArmyQueue")
local BuildQueueModel = import("Model/CityMap/BuildQueueModel")
local BeautyGirlModel = import("Model/BeautyGirlModel")
local TaskPlotModel = import("Model/TaskPlotModel")
local WaterModel = import("Model/CityMap/WaterModel")
local GlobalVars = GlobalVars
--推荐任务描述颜色
local WhiteColor = Color(213 / 255, 224 / 255, 224 / 255)
local YellowColor = Color(241 / 255, 206 / 255, 89 / 255)
local IsAorBGuide = false
import("UI/MainUI/MainUIGain")
import("UI/MainUI/MainUIOnline")
import("UI/MainUI/MainUIPay")
import("UI/WorldCity/WorldCity")
local triggerGuide = import("Model/TriggerGuideLogic")
--当前跳转信息
MainUIPanel.cutJump = nil
local isShowPanel = true
--打开主界面只进行一次请求活动信息
local IsGetActivityInfo = false
--0代表默认活动Icon
local cutActivityIndex = 0
local cutActivityId = 0
local count = 0
local isSetWorldBtnGuideShow = true --是否可以指引回城手指
--界面按钮储存
local groupBtns = {}
function MainUIPanel:OnInit()
    local view = self.Controller.contentPane
    self._view = view
    self._taskplotBtnPos = view:GetChild("plotGuideCom")
    --添加全局遮罩
    MaskModel.InitMask(self)

    GuidePanelModel:Init()
    BeautyGirlModel.Init()
    self._taskAnim = view:GetTransition("taskAnim")
    GuidePanelModel:SetParentUI(self, UIType.UnionBtnUI)
    self:AddListener(
        view.onClick,
        function()
            if not CommonType.MAIN_UI_CLICK_JUMP and not GuidePanelModel:IsGuideState() and not GlobalVars.IsTriggerStatus then
                CityMapModel.GetCityFunction():SetFuncVisible(false)
            end
            CommonType.MAIN_UI_CLICK_JUMP = false

            if CityType.BUILD_MOVE_TIP then
                Event.Broadcast(EventDefines.UICityBuildMove, BuildType.MOVE.Reset)
            end

            GlobalVars.ClickBuildFunction = false
            if GlobalVars.ClickBuilder then
                GlobalVars.ClickBuilder = false
            else
                ScrollModel.SetWhetherMoveScale(false)
            end
            if not GlobalVars.ClickBuildTurn and GlobalVars.ClickBuilder then
                ScrollModel.Scale(nil, false)
            end

            if BuildQueueModel.IsShowQueTip then
                BuildQueueModel.HideQueueTip()
            end
        end
    )
    self._taskController = view:GetController("task")
    self._abGuideController = view:GetController("ABGuide")
    --建筑队列
    self._btnQueue = view:GetChild("btnBuild")
    self._btnQueueLock = view:GetChild("btnBuildLock")
    GuidePanelModel:SetValParams(UIType.btnQueueBuild, self._btnQueue)
    GuidePanelModel:SetValParams(UIType.btnQueueBuildLock, self._btnQueueLock)
    self:BuildQueue()
    BuildQueueModel.InitQueue(self._btnQueue, self._btnQueueLock)
    --哥斯拉
    self._btnGodzilla = view:GetChild("btnGodzilla")
    self._btnGodzillaRed = self._btnGodzilla:GetChild("redPoint")
    self._btnGodzillaRed.visible = false
    self._btnOnline = view:GetChild("btnOnline")
    self._btnOnlineCT = self._btnOnline:GetController("button")
    self._btnOnlineCT.selectedIndex = 1
    self.frontEffect, self.behindEffect = AnimationModel.GiftEffect(self._btnOnline, nil, Vector3(0.8, 0.8, 1), "MainUIPanlebtnOnline", self.frontEffect, self.behindEffect)
    self._btnOnlneText = self._btnOnline:GetChild("title")
    self._btnOnlneText.text = StringUtil.GetI18n(I18nType.Commmon, "Button_Receive_Award")
    self.down = view:GetChild("mainDown")
    self._btnWorld = self.down:GetChild("_btnWorld")
    self._btnTask = self.down:GetChild("_btnTask")
    self._btnBackpack = self.down:GetChild("_btnBackpack")
    self._btnMail = self.down:GetChild("_btnMail")
    self._btnUnion = self.down:GetChild("_btnUnion")
    self._chatVeiw = self.down:GetChild("_btnChat")
    self._btnWorldEffect = self.down:GetChild("_btnWorldEffect")
    self._btnSkill = view:GetChild("btnSkill")
    self._btnHelp = view:GetChild("btnHelp")
    self._mainTop = view:GetChild("mainTop")
    self._mainHead = self._mainTop:GetChild("mainHead")
    self._btnPower = self._mainTop:GetChild("_btnPower")
    self._btnVip = self._mainTop:GetChild("_btnVip")
    self._btnGold = self._mainTop:GetChild("_btnGold")
    self._tagResources = self._mainTop:GetChild("_tagResources")

    self._controller = view:GetController("c1")
    self._controller2 = self.down:GetController("c2")
    self._btnRadar = view:GetChild("btnRadar")
    self._textRadar = self._btnRadar:GetChild("text")
    self._btnWall = view:GetChild("btnWall")
    self._taskFinishEffect_Right = view:GetChild("effectNode")

    --美女按钮
    self._btnBeauty = view:GetChild("btnBeauty")
    self._btnBeautyRed = self._btnBeauty:GetChild("redPoint")
    --sourcePosY = self._btnBeauty.y

    self._btnGift = view:GetChild("btnGift")
    self._iconBtnGift = self._btnGift:GetChild("icon")
    self._textGiftTime = self._btnGift:GetChild("title")
    -- self._btnGift:GetChild("redPoint").visible = false
    -- self._btnGift:GetChild("text").visible = false
    self.curGiftGroup = 1
    self:InitGiftBtn()

    self._btnWelfare = view:GetChild("btnWelfare")
    self._btnWelfare:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "WELFAREACTIVITY_TITLE1")
    self._btnActiviCenter = view:GetChild("btnActivity")

    self._radarTypeControl = self._btnRadar:GetController("typeControl")

    --设置位置控制器
    self._setIconPosCon = view:GetController("setIconPos")

    self._msgCtrView = self.down:GetController("c1")
    self._msgIcon = self._chatVeiw:GetChild("icon")
    self._msgNameTag = self._chatVeiw:GetChild("textChatName")
    self._msgText = self._chatVeiw:GetChild("textChat")
    self._msgText.emojies = EmojiesMgr:GetEmojies()
    self._groupTask = view:GetChild("groupTask")
    self._taskGuideNode = view:GetChild("taskMainGuideNode")
    self._groupTaskPlot = view:GetChild("groupTaskPlot")
    self._taskPlot = view:GetChild("taskPlot")
    if self._canPlayOLRewardEffect == nil and self._cachePlayOnlineEffect == nil then
        self._canPlayOLRewardEffect = Model.Player.Level < Global.UnlockLevelBase4
        self._cachePlayOnlineEffect = false
    end

    self._btnGm.visible = false
    --按钮列表
    groupBtns = {
        ["upperLeft"] = {
            self._btnQueue,
            self._btnQueueLock
        },
        ["lowerLeft"] = {
            self._btnOnline,
            self._btnBeauty,
            self._btnGodzilla
        },
        ["lowerRight"] = {
            self._btnSkill,
            self._btnRadar,
            self._btnHelp,
            self._btnWall
        },
        ["upperRight"] = {
            self._btnQuest,
            self._btnActiviCenter,
            self._btnWelfare,
            self._btnGift
        }
    }
    self:GroupBtnsMatch()

    --TODO测试触发引导
    -- self._testBtn = view:GetChild("n147")
    -- self._testIcon = view:GetChild("n148")
    -- self._testBtn.visible = false
    -- self._testIcon.visible = false
    local tableFunc = {}

    local function testTabale1()
        self._groupTaskPlot.visible = false
        self._btnBeauty.visible = true
        self._groupTask.visible = false
    end
    local function testTabale2()
        self._groupTaskPlot.visible = false
        self._btnBeauty.visible = true
        self._groupTask.visible = true
    end
    local function testTabale3()
        self._groupTaskPlot.visible = false
        self._btnBeauty.visible = false
        self._groupTask.visible = false
    end
    local function testTabale4()
        self._groupTaskPlot.visible = false
        self._btnBeauty.visible = false
        self._groupTask.visible = true
    end
    local function testTabale5()
        self._groupTaskPlot.visible = true
        self._btnBeauty.visible = true
        self._groupTask.visible = false
    end
    local function testTabale6()
        self._groupTaskPlot.visible = true
        self._btnBeauty.visible = true
        self._groupTask.visible = true
    end
    local function testTabale7()
        self._groupTaskPlot.visible = true
        self._btnBeauty.visible = false
        self._groupTask.visible = false
    end
    local function testTabale8()
        self._groupTaskPlot.visible = true
        self._btnBeauty.visible = false
        self._groupTask.visible = true
    end

    table.insert(tableFunc, testTabale1)
    table.insert(tableFunc, testTabale2)
    table.insert(tableFunc, testTabale3)
    table.insert(tableFunc, testTabale4)
    table.insert(tableFunc, testTabale5)
    table.insert(tableFunc, testTabale6)
    table.insert(tableFunc, testTabale7)
    table.insert(tableFunc, testTabale8)
    local indexCount = 1
    -- self:AddListener(
    --     self._testBtn.onClick,
    --     function()
    --         -- self:SetWorldBtnGuideShow()
    --         -- UIMgr:Open("WelfareMain")
    --         -- local WelfareMain = UIMgr:GetUI("WelfareMain")
    --         -- WelfareMain:OpenPage(WelfareModel.WelfarePageType.FALCON_ACTIVITY)
    --         -- Scheduler.ScheduleOnceFast(
    --         --     function()
    --         --         JumpMap:JumpSimple(816000)
    --         --     end,
    --         --     0.3
    --         -- )
    --         -- tableFunc[indexCount]()
    --         -- indexCount = indexCount + 1
    --         -- if indexCount > 8 then
    --         --     indexCount = 1
    --         -- end
    --         -- self:SetIconPos()
    --         GD.ItemAgent.GetUseResMininum(3, 6000078)
    --     end
    -- )
    self.redPointList = {
        [MAIN_UI_BTN_TYPE.Hero] = {
            redPoint = self.down:GetChild("greenPointHero")
        },
        [MAIN_UI_BTN_TYPE.Mail] = {
            redPoint = self.down:GetChild("greenPointMail")
        },
        [MAIN_UI_BTN_TYPE.Backpack] = {
            redPoint = self.down:GetChild("greenPointBackpack")
        }
    }

    self._worldPos = view:GetChild("text")
    self._text = view:GetChild("text")
    self._btnSearch = view:GetChild("btnSearch")
    self._animOut = view:GetTransition("out")
    self._animIn = view:GetTransition("in")
    self:AddListener(
        self._btnActiviCenter.onClick,
        function()
            UIMgr:Open("ActivityCenter", cutActivityId)
        end
    )
    self:AddListener(
        self._btnQuest.onClick,
        function()
            Sdk.OpenBrowser(ConfigMgr.GetItem("configQuestions", 1)[ConfigMgr.GetItem("configLanguages", Model.User.Language).language])
        end
    )
    self:AddListener(
        self._btnWorld.onClick,
        function()
            local isCheckTrigger = GD.TriggerGuideAgent.CheckIsTriggerStatus()
            --如果触发引导并且
            if isCheckTrigger and not self.Triggercallback then
                return
            end
            if GlobalVars.IsInCity then
                GlobalVars.IsInCityTrigger = false
            else
                GlobalVars.IsInCityTrigger = true
            end
            self:ChangeMap()
            --关闭引导图标指引
            if GuidePanelModel.isBeginGuide and GuidePanelModel.uiType == UIType.UIMainTaskIcon then
                Event.Broadcast(EventDefines.CloseGuide)
            end
            if self.Triggercallback then
                self.Triggercallback()
            end

            WaterModel.CheckShow()
        end
    )
    self:AddListener(
        self._btnOnline.onClick,
        function()
            --在线奖励
            GlobalVars.ClickBuildTurn = true
            if not CommonType.DAILY_REWARD_CLICK then
                return
            end
            CommonType.DAILY_REWARD_CLICK = false
            JumpMap:JumpSimple(811300, true)
        end
    )

    --主线任务
    self._bgTipsBar = view:GetChild("bgTipsBar")
    self._bgTipsBar2 = view:GetChild("bgTipsBar2")
    self._iconMissionOk = view:GetChild("iconMissionOK")
    self._iconOk = view:GetChild("iconOk")
    self._ok = view:GetChild("ok")
    self._iconBg = view:GetChild("iconBg")
    self._iconBgbg = view:GetChild("iconBgbg")
    self._iconMissionDown = view:GetChild("iconMissionDown")
    self._iconMissionTop = view:GetChild("iconMissionTop")
    self._textTips = view:GetChild("textTips") --主界面显示的任务名称
    self._textBguideTips = view:GetChild("textBGuideTips") --B引导时推荐任务的一个领取奖励提示
    self._iconGift = view:GetChild("iconGift")
    self._mainTaskEffect = self._view:GetChild("effectNode2")
    self._textTips.color = WhiteColor
    MainCity.GetRewardCenterPoint = self._getRewardCenterPoint
    --如果是A引导则没有领取奖励提示
    if ABTest.Task_ABLogic() == 2001 or ABTest.Task_ABLogic() == 9999 then
        self._abGuideController.selectedIndex = 0
        IsAorBGuide = true
        self._textBguideTips.text = ""
    else
        self._abGuideController.selectedIndex = 1
        IsAorBGuide = false
        self._textBguideTips.text = StringUtil.GetI18n(I18nType.Commmon, "Button_Receive_Award")
    end
    GuidePanelModel:SetValParams(UIType.TipBarUI, self._bgTipsBar)
    GuidePanelModel:SetValParams(UIType.TipBarUI2, self._bgTipsBar2)
    GuidePanelModel:SetValParams("TaskStage", self._taskController.selectedIndex)

    self.tipList = {
        self._bgTipsBar,
        self._bgTipsBar2,
        self._iconMissionOk,
        self._iconOk,
        self._iconMissionDown,
        self._iconMissionTop,
        self._textTips,
        self._iconGift,
        self._iconBg,
        self._iconBgbg,
        self._ok,
        self._taskFinishEffect_Right
    }
    self._dragRect = view:GetChild("dragRect")
    self._buildFace = view:GetChild("moveBuildFace")
    self._plotPoint = self._buildFace:GetChild("DragArea")
    self._btnGroup = self._buildFace:GetChild("btnGroup")

    --章节任务
    self._plotIcon = view:GetChild("btnPlot")
    self._textChapter = view:GetChild("textChapter")
    self._redPointofChapter = view:GetChild("redChapter")
    self.chapterRedCtr = self._redPointofChapter:GetController("Ctr")
    self.chapterRedNum = self._redPointofChapter:GetChild("_numberGreen")
    self.taskPlotCtr = view:GetController("taskPlot")

    --
    local net_func = function()
        Event.Broadcast(EventDefines.DelayMask, true)
        Net.Chapter.GetChapterInfo(
            function(msg)
                self:ScheduleOnceFast(
                    function()
                        Event.Broadcast(EventDefines.DelayMask, false)
                    end,
                    0.3
                )
                if not UIMgr:GetUIOpen("BuildRelated/BuildCreate") then
                    UIMgr:Open("TaskPlot", msg)
                end
            end
        )
        --容错处理
        self:ScheduleOnceFast(
            function()
                Event.Broadcast(EventDefines.DelayMask, false)
            end,
            2
        )
    end

    self:SetBuildCenterShow()

    --指挥中心升级
    self:AddEvent(
        EventDefines.UICityBuildCenterUpgrade,
        function()
            self:SetBuildCenterShow()
            UnlockModel:UnlockBuildAnim(UnlockModel.Build.BuildingBridge)
            --成长基金打开，并且购买
            if WelfareModel.IsActivityOpen(WelfareModel.WelfarePageType.GROWTHCAPITALTYPE) and Model.GrowthFundBought then
                Event.Broadcast(EventDefines.UIWelfareGrowthFund)
            end
            --升级主堡刷新
            if self._groupTaskPlot.visible or self._bgTipsBar.visible then
                self:SetTaskPlotGuideShow()
            end
        end
    )
    --城墙升级
    self:AddEvent(
        EventDefines.UICityBuildWallUpgrade,
        function()
        end
    )
    --刷新主动技能红点
    self:AddEvent(
        EventDefines.UIActiveSkillRedMes,
        function(val)
            if next(val) then
                SkillModel.SetRedData(val.Id)
                Event.Broadcast(EventDefines.UIRefreshSkillRed)
            end
        end
    )
    self:AddEvent(
        EventDefines.MainUITouchEvent,
        function(isTouch, touchStr)
            self:SetTouchEnable(isTouch, touchStr)
        end
    )
    --两个不同的区域都能打开章节任务界面
    self:AddListener(self._taskPlot.onClick, net_func)
    self:AddListener(self._plotIcon.onClick, net_func)

    self:AddListener(
        self._btnGodzilla.onClick,
        function()
            UIMgr:Open("MainGodzillaAward")
        end
    )
    self:AddListener(
        self._btnBeauty.onClick,
        function()
            --打开美女在线奖励
            UIMgr:Open("BeautyOnlineRewards")
        end
    )

    self:AddEvent(
        EventDefines.UnlockMainPanelBeauty,
        function(isVisble)
            self._btnBeautyRed.visible = false
            self:SetBeutyBtnVisble(isVisble)
            self:SetIconPos()
        end
    )
    self:AddEvent(
        EventDefines.RefreshMainUIBeauty,
        function(nextIndex, nextAvaliableAt)
            self:SetIconByBeauty(nextIndex, nextAvaliableAt)
        end
    )

    --获取章节信息
    self.chapterInfo = Model.GetMap(ModelType.ChapterTasksInfo)

    self:AddEvent(
        EventDefines.UIOpenTaskPanel,
        function(isOpenDaily, callBack)
            UIMgr:Open("TaskMain", isOpenDaily, callBack)
        end
    )
    self:AddListener(
        self._btnTask.onClick,
        function()
            if self.Triggercallback then
                self.Triggercallback()
            end
            Event.Broadcast(EventDefines.UIOpenTaskPanel)
        end
    )
    --关闭和刷新章节界面的事件监听
    self:AddEvent(
        EventDefines.UICloseChapterShow,
        function()
            self:CloseChapterTaskShow()
        end
    )
    self:AddEvent(
        EventDefines.UIRefreshChapterShow,
        function()
            self.chapterInfo = Model.GetMap(ModelType.ChapterTasksInfo)
            self:RefreshChapterMsg()
        end
    )

    self:AddEvent(
        EventDefines.UIOnLineIcon,
        function(rewardTime)
            if rewardTime > 0 then
                self._btnOnlineCT.selectedIndex = 0
                AnimationModel.DisPoseGiftEffect("MainUIPanlebtnOnline", self.frontEffect, self.behindEffect)
                self._btnOnlneText.text = Tool.FormatTime(rewardTime)
            else
                self._btnOnlineCT.selectedIndex = 1
                self.frontEffect, self.behindEffect = AnimationModel.GiftEffect(self._btnOnline, nil, Vector3(0.8, 0.8, 1), "MainUIPanlebtnOnline", self.frontEffect, self.behindEffect)
                self._btnOnlneText.text = StringUtil.GetI18n(I18nType.Commmon, "Button_Receive_Award")
            end
        end
    )

    self:AddEvent(
        EventDefines.UIGodzillaOnlineBonusFinish,
        function(val)
            self._btnGodzillaRed.visible = val
        end
    )
    --需要监听完成和未完成的章节任务及其进度等信息 并更新
    self:AddEvent(
        EventDefines.UIAccomplishedPlotTasks,
        function(rsp)
            for _, v in pairs(rsp.Tasks) do
                local reid = false
                for _, av in pairs(self.chapterInfo.AccomplishedPlotTasks) do
                    if v.Id == av.Id then
                        reid = true
                    end
                end
                if not reid then
                    table.insert(Model[ModelType.ChapterTasksInfo].AccomplishedPlotTasks, v)
                    for k, kv in pairs(Model[ModelType.ChapterTasksInfo].UnlockedPlotTasks) do
                        if v.Id == kv.Id then
                            table.remove(Model[ModelType.ChapterTasksInfo].UnlockedPlotTasks, k)
                        end
                    end
                end
            end
            --需要及时更新章节任务信息
            self.chapterInfo = Model.GetMap(ModelType.ChapterTasksInfo)
            self:RefreshChapterMsg()
        end
    )
    self:AddEvent(
        EventDefines.UIUnlockedPlotTasks,
        function(rsp)
            for _, v in pairs(rsp.Tasks) do
                for _, kv in pairs(Model[ModelType.ChapterTasksInfo].UnlockedPlotTasks) do
                    if v.Id == kv.Id then
                        kv.CurrentProcess = v.CurrentProcess
                    end
                end
            end
            self.chapterInfo = Model.GetMap(ModelType.ChapterTasksInfo)
        end
    )
    self:AddEvent(
        EventDefines.UIChapterSort,
        function()
            self:RefreshRedPointOfChapter()
        end
    )

    self:InitSetJumpData()
    self:AddEvent(
        EventDefines.UITipMainTaskMes,
        function(rsp)
            local infoList = TaskModel.GetRecommendTask()
            self.cutJump = infoList
            self:SetJumpTipParams()
        end
    )

    self:AddEvent(
        EventDefines.MesTaskMainTipEvent,
        function(recTask)
            if not recTask then
                self.cutJump = nil
                self:SetTipShow(false)
                return
            end
            self.cutJump = recTask
            self._textTips.text = TaskModel:GetTaskNameByType(self.cutJump)
            self:SetJumpTipParams()
        end
    )
    self:AddEvent(
        EventDefines.RefreshSkillIconShow,
        function()
            local isActivity = SkillModel.GetActiveSkillUseIcon()
            if isActivity then
                local skillActivityIcon = SkillModel.GetActiveSkillUseIcon()
                self._btnSkill.visible = true
                self._btnSkill:GetChild("icon").icon = UITool.GetIcon(skillActivityIcon)
            else
                self._btnSkill.visible = false
            end
        end
    )
    -- self:AddEvent(
    --     EventDefines.RefreshActivityUI,
    --     function()
    --         UIMgr:Open("ActivityCenter")
    --     end
    -- )

    self.isShowTaskMission = true
    self:AddEvent(
        SYSTEM_SETTING_EVENT.HideDayGiftTip,
        function(flag)
            self.isShowTaskMission = flag
        end
    )
    self:AddEvent(
        EventDefines.DailyTaskPopupUI,
        function(data)
            self:ScheduleOnce(
                function()
                    if
                        (GlobalVars.IsInCity or GlobalVars.IsInCityTrigger) and self.isShowTaskMission and UIMgr:GetShowPanelCount() == 0 and not GlobalVars.IsNoviceGuideStatus and
                            not GlobalVars.IsTriggerStatus
                     then
                        if Model.Player.Level >= GlobalMisc.DailyTaskWindowunlocklevel then
                            UIMgr:Open("TaskMissionAutomaticPopup", data)
                        end
                    end
                end,
                3
            )
        end
    )

    self:AddEvent(
        EventDefines.RefreshGiftPacks,
        function()
            self:RefreshGiftShow()
        end
    )

    self:AddEvent(
        EventDefines.FlyFalconGetTech,
        function(screenX, screenY, TechId)
            AnimationModel.TechCollect(self._mainHead, screenX, screenY, TechId)
        end
    )

    local taskReceiveFunc = function()
        Event.Broadcast(EventDefines.CloseGuide)
        local isGuide = GuidePanelModel:IsGuideState()
        --TODO新增触发引导不能点击推荐任务指引,修改建造
        if (isGuide and GuidePanelModel:GetJumpId() ~= 814000) or self._taskAnim.playing == true then
            return
        end
        local isAward = self.cutJump.AwardTaken
        if isAward == false then
            --领取
            -- if self.taskFinishEffect_Click then
            --     self.taskFinishEffect_Click.x = 10000
            -- end
            --NodePool.Init(NodePool.KeyType.TaskFinishEffect_Click, "Effect", "EffectNode")
            -- self.taskFinishEffect_Click = NodePool.Get(NodePool.KeyType.TaskFinishEffect_Click)
            -- self.taskFinishEffect_Click.xy = Vector2(100, 13)
            --self._view:GetChild("effectNode2"):AddChild(self.taskFinishEffect_Click)
            --self.taskFinishEffect_Click:InitNormal()
            local rewardData = self.cutJump.award
            Net.MainTask.GetMainTaskAward(
                self.cutJump.id,
                function(rsp)
                    --播放领奖动画
                    --UITool.GiftReward(rewardData)
                    AnimationModel.MainTaskFinishAnim(rewardData)
                    TaskModel:GetRemoveTaskInfo(rsp)
                    self:ScheduleOnceFast(
                        function()
                            self.cutJump = TaskModel.GetRecommendTask()
                            if not self.cutJump then
                                self:SetTipShow(false)
                                return
                            end
                            self._textTips.text = TaskModel:GetTaskNameByType(self.cutJump)
                            self:SetJumpTipParams()
                            Event.Broadcast(EventDefines.UITaskRefreshRed)
                            if GlobalVars.IsNoviceGuideStatus == true then
                                Event.Broadcast(EventDefines.NextNoviceStep, 1016)
                            end
                            if GlobalVars.IsTriggerStatus == true then
                                if self._taskController.selectedIndex == 1 then
                                    Log.Error("领取奖励过后推荐任务还是可领取的一个状态退出引导")
                                    Event.Broadcast(EventDefines.ClearTrigger)
                                else
                                    if self.Triggercallback then
                                        self.Triggercallback()
                                    end
                                end
                            end
                        end,
                        0.1
                    )
                    local scale = IsAorBGuide and Vector3(1, 1, 1) or Vector3(1, 1.42, 1)
                    self._taskAnim:Play()
                    self._mainTaskEffect:PlayEffectSingle(
                        "effects/task/taskfinish/prefab/effect_main_mission2_lizi",
                        function()
                            self._mainTaskEffect.visible = false
                        end,
                        scale,
                        nil,
                        nil,
                        true
                    )
                end
            )
        else
            CityMapModel.GetCityFunction():SetFuncVisible(false)
            CommonType.MAIN_UI_CLICK_JUMP = true
            --解锁资源块
            if self.cutJump.jump.jump == 810500 then
                --如果该地块已解锁则向下查找有没有未解锁的地块
                local pieceId = self.cutJump.jump.para
                local unlockNode = CityMapModel.GetLockBtn(pieceId)
                if unlockNode:GetVisible() then
                    for i = pieceId, 1, -1 do
                        local lockNode = CityMapModel.GetLockBtn(i)
                        if not lockNode:GetVisible() then
                            pieceId = i
                            break
                        end
                    end
                end
                TurnModel.MapLockPiece(pieceId)
            else
                JumpMap:JumpTo(self.cutJump.jump, self.cutJump.finish)
            end
            if GlobalVars.IsTriggerStatus == true then
                if self.Triggercallback then
                    self.Triggercallback()
                end
            end
        end
    end
    self:AddEvent(
        EventDefines.TaskIconJump,
        function()
            taskReceiveFunc()
        end
    )
    self:AddListener(
        self._bgTipsBar.onClick,
        function()
            taskReceiveFunc()
        end
    )
    self:AddListener(
        self._bgTipsBar2.onClick,
        function()
            taskReceiveFunc()
        end
    )

    self:AddEvent(
        EventDefines.DefenceCenterTrigger,
        function(value)
            if value then
                UIMgr:Open("AttackAlert")
            else
                UIMgr:Close("AttackAlert")
            end
        end
    )

    self:AddEvent(
        EventDefines.KingkongTrigger,
        function(value)
            if value then
                UIMgr:Open("AttackAlert")
            else
                UIMgr:Close("AttackAlert")
            end
        end
    )

    self:AddListener(
        self._btnBackpack.onClick,
        function()
            self.visible = false
            local cb = function()
                self.visible = true
            end
            UIMgr:Open("Backpack", {cb = cb})
            if self.Triggercallback then
                self.Triggercallback()
            end
        end
    )
    self:AddListener(
        self._btnSearch.onClick,
        function()
            UIMgr:Open("WorldSearch", {x = self.posX, y = self.posY})
        end
    )

    self:AddListener(
        self._textBg.onClick,
        function()
            UIMgr:Open("WorldSearch", {x = self.posX, y = self.posY})
        end
    )

    self:AddListener(
        self._btnRadar.onClick,
        function()
            UIMgr:Open("Radar")
            if self.Triggercallback then
                self.Triggercallback()
            end
        end
    )

    self:AddListener(
        self._btnWall.onClick,
        function()
            UIMgr:Open("Wall")
        end
    )

    self:AddListener(
        self._btnGift.onClick,
        function()
            GiftModel:openGiftPushWin(self.curGiftGroup)
        end
    )

    self:AddListener(
        self._btnLookup.onClick,
        function()
            UIMgr:Open("Lookup")
        end
    )
    self:AddListener(
        self._btnMap.onClick,
        function()
            local callFunc = function()
                Net.MiniMap.GetMiniMapInfo(
                    function(data)
                        UIMgr:Open("MapThumbnail", data, MathUtil.GetPosNum(self.posX, self.posY))
                    end
                )
            end
            local popup_data = {
                bundleName = "world",
                loadBack = callFunc,
                textBtnSure = StringUtil.GetI18n(I18nType.Commmon, "MAP_RETURN_BUTTON"),
                textPopupDesc = StringUtil.GetI18n(I18nType.Commmon, "THUMBNAIL_LoadingInterface_DESC")
            }
            UIMgr:Open("ConfirmPopupLoadRes", popup_data)
        end
    )
    self:AddListener(
        self._btnFavorite.onClick,
        function()
            UIMgr:Open("Favorites")
        end
    )

    local _touchX = 0
    local _touchY = 0

    local _move = 0

    self:AddListener(
        self._chatVeiw.onTouchBegin,
        function(context)
            _move = 0
            _touchX = context.inputEvent.x
            _touchY = context.inputEvent.y
        end
    )

    self:AddListener(
        self._chatVeiw.onTouchEnd,
        function(context)
            _move = context.inputEvent.x - _touchX
            if math.abs(_move) < 10 then
                UIMgr:Open("Chat")
            else
                if ChatModel.chatType == CHAT_TYPE.WorldChat then
                    ChatModel.chatType = CHAT_TYPE.UnionChat
                else
                    ChatModel.chatType = CHAT_TYPE.WorldChat
                end
                self:RefreshMsg()
            end
        end
    )

    self:AddListener(
        self._btnMail.onClick,
        function()
            UIMgr:Open("Mail_Main")
        end
    )

    self:AddListener(
        self._btnGm.onClick,
        function()
            local cb = function()
                local serverId = ""
                local accountId = ""
                if Auth and Auth.WorldData then
                    serverId = Auth.WorldData.sceneId
                    accountId = string.gsub(Auth.WorldData.accountId, "#", "-")
                end
                Sdk.AiHelpShowConversation(accountId, serverId)
                SdkModel.GmNotRead = 0
                Event.Broadcast(GM_MSG_EVENT.MsgIsRead, SdkModel.GmNotRead)
            end

            -- 屏蔽权限提示
            -- if not Sdk.CanAccessGM() then
            --     local data = {
            --         content = "GM_Request",
            --         buttonType = "double",
            --         sureCallback = function()
            --             Sdk.RequestGM()
            --         end
            --     }
            --     UIMgr:Open("ConfirmPopupText", data)
            -- else
            cb()
            -- end
        end
    )

    self._worldQueueList.visible = false

    self:AddEvent(
        EventDefines.UIOnMissionInfo,
        function(val)
            if not val.OK then
                MissionEventModel.OnRefresh(val)
                Event.Broadcast(EventDefines.MissionEventRefresh)
            end
            self:OnRefreshQueueBar()
        end
    )
    self:AddEvent(
        EventDefines.UIDelMarchLine,
        function()
            self:OnRefreshQueueBar()
        end
    )
    self:AddEvent(
        EventDefines.UIDelMission,
        function()
            Event.Broadcast(EventDefines.MissionEventRefresh)
            self:OnRefreshQueueBar()
        end
    )
    self:AddEvent(
        EventDefines.UIWorldCityQueueFinish,
        function()
            self:OnRefreshQueueBar()
        end
    )
    self:AddEvent(
        ACIIVI_EVENT.Open,
        function()
            self:RefreshQusetionBtn()
        end
    )
    self:AddEvent(
        ACIIVI_EVENT.Close,
        function()
            self:RefreshQusetionBtn()
        end
    )
    ChatModel:Init()
    BlockListModel.Init()

    if WelfareModel.IsActivityOpen(WelfareModel.WelfarePageType.CUMULATIVE_ATTENDANCE) then
        WelfareModel.GetRookieSignInfos()
    end

    MonsterData.RequestGetMonsterList(true)
    self:EventListener()
    self:Init()
    self:AddEvent(
        --当哥斯拉领取奖励解锁时通知界面解锁
        EventDefines.GozillzUnlockEvent,
        function(val)
            self._btnGodzilla.visible = val
            Net.GodzillaOnlineBonus.GetGodzillaOnlineBonusInfo(
                function(rsp)
                    for _, v in pairs(rsp.Info) do
                        --1是有可领取的，0是没有可领取的
                        if v.Status == 1 then
                            self._btnGodzillaRed.visible = true
                            break
                        else
                            self._btnGodzillaRed.visible = false
                        end
                    end
                end
            )
            self:SetIconPos()
        end
    )
    self:AddEvent(
        --当哥斯拉领取奖励解锁时通知界面解锁
        EventDefines.RefreshSetIconPos,
        function()
            self:SetIconPos()
        end
    )

    self:AddEvent(
        EventDefines.UIMainShow,
        function(flag)
            view.visible = flag
        end
    )

    self:AddEvent(
        WORLD_CHAT_EVENT.Refresh,
        function()
            self:RefreshMsg()
        end
    )

    self:AddEvent(
        UNION_EVENT.Exit,
        function(rsp)
            ChatModel.chatType = CHAT_TYPE.WorldChat
            ChatModel.newUnionMsgs = ""
            self:RefreshMsg()

            --退出联盟清除本地联盟标记缓存
            Model.Clear(ModelType.AllianceBookmarks)
            Event.Broadcast(EventDefines.WorldMapAllianceRefresh)
        end
    )

    self:AddEvent(
        EventDefines.UITownMove,
        function(val)
            --被强制位移
            if GlobalVars.IsInCity then
                Event.Broadcast(EventDefines.OpenWorldMap, val.X, val.Y)
            else
                --使用随机飞城
                UIMgr:Close("Backpack")
                Event.Broadcast(EventDefines.OpenWorldMap, val.X, val.Y)
            end
        end
    )

    self:AddEvent(
        SYSTEM_SETTING_EVENT.HideTaskLable,
        function(flag)
            self._groupTask.visible = flag
            self:SetIconPos()
        end
    )

    self:AddEvent(
        EventDefines.RefreshTaskPlotGuide,
        function()
            self:SetTaskPlotGuideShow()
        end
    )
    self:AddEvent(
        EventDefines.WorldGuideShow,
        function()
            self:SetWorldBtnGuideShow()
        end
    )

    --第三周活动、军备竞技获得宝箱的时候特效展示
    self:AddEvent(
        EventDefines.MemoryActivityEffectShow,
        function(rsp)
            --[[if rsp.Category == 100070101 then
                return
            end--]]
            --特效显示
            local rewards = {}
            local reward = {
                Category = Global.RewardTypeItem,
                ConfId = rsp.ItemId,
                Amount = rsp.Amount
            }
            table.insert(rewards, reward)
            UITool.ShowReward(rewards)
        end
    )

    --首次登陆刷新联盟任务未读
    UnionModel:RefreshUnionTaskNotRead()
    UnionModel:RefreshUnionBossTaskNotRead()
    self:Schedule(
        function()
            Sdk.GetUnreadMessageFetchUid(Auth.WorldData.accountId)
        end,
        300
    )

    if ABTest.Task_ABLogic() == 2001 then
        local taskInfo = Model.GetMap(ModelType.ChapterTasksInfo)
        local alreadyTrigger = false
        for j = 1, #Model.Player.TriggerGuides do
            if Model.Player.TriggerGuides[j].Id == 15500 then
                alreadyTrigger = true
                break
            end
        end
        if taskInfo.CurrentChapter ~= 0 and taskInfo.CurrentChapter < 5 then
            if alreadyTrigger == false then
                Event.Broadcast(SYSTEM_SETTING_EVENT.HideTaskLable, false)
            else
                Event.Broadcast(SYSTEM_SETTING_EVENT.HideTaskLable, true)
            end
        else
            Event.Broadcast(SYSTEM_SETTING_EVENT.HideTaskLable, true)
        end
    end

    if ABTest.Task_ABLogic() == 2002 then
        Event.Broadcast(EventDefines.UICloseChapterShow)
        if GlobalVars.IsNoviceGuideStatus and Model.Player.GuideStep < 10032 then
            Event.Broadcast(SYSTEM_SETTING_EVENT.HideTaskLable, false)
        else
            Event.Broadcast(SYSTEM_SETTING_EVENT.HideTaskLable, true)
        end
    end

    --内外城切换按钮特效
    self:SwitchCityEffect()
end

--设置跳转条属性
function MainUIPanel:InitSetJumpData()
    local taskDatas = TaskModel.GetRecommendTask()
    if not taskDatas then
        return
    end
    self.cutJump = taskDatas
    self:SetJumpTipParams()
    self._textTips.text = TaskModel:GetTaskNameByType(self.cutJump)
end

--设置跳转图标颜色
function MainUIPanel:SetJumpTipParams()
    if not self.cutJump then
        return
    end
    NodePool.Init(NodePool.KeyType.TaskFinishEffect_Left, "Effect", "EffectNode")
    NodePool.Init(NodePool.KeyType.TaskFinishEffect_Right, "Effect", "EffectNode")
    self.isReceive = self.cutJump.AwardTaken
    local isShow = self.isReceive == false and true or false
    if isShow then
        self._taskController.selectedIndex = 1
        self:SetRecommendTaskColor(true)
        if not self.taskFinishEffect_Left then
            self.taskFinishEffect_Left = NodePool.Get(NodePool.KeyType.TaskFinishEffect_Left)
            self.taskFinishEffect_Left.xy = Vector2(-15, 140)
            self._iconOk:AddChild(self.taskFinishEffect_Left)
            self.taskFinishEffect_Left:InitNormal()
            self.taskFinishEffect_Left:PlayEffectLoop("effects/task/taskfinish/prefab/effect_main_mission_left")
            self.taskFinishEffect_Left.visible = true
        end
        if not self.taskFinishEffect_Right then
            self.taskFinishEffect_Right = NodePool.Get(NodePool.KeyType.TaskFinishEffect_Right)
            self.taskFinishEffect_Right.xy = Vector2(0, 0)
            self._taskFinishEffect_Right:AddChild(self.taskFinishEffect_Right)
            self.taskFinishEffect_Right:InitNormal()
            local scale = IsAorBGuide and Vector3(1, 1, 1) or Vector3(1, 1.42, 1)
            self.taskFinishEffect_Right:PlayEffectLoop("effects/task/taskfinish/prefab/effect_main_mission_right", scale)
            self.taskFinishEffect_Right.visible = true
        end
    else
        self._taskController.selectedIndex = 0
        self:SetRecommendTaskColor(false)
        if self.taskFinishEffect_Right then
            self.taskFinishEffect_Right:StopEffect()
            NodePool.Set(NodePool.KeyType.TaskFinishEffect_Right, self.taskFinishEffect_Right)
            self.taskFinishEffect_Right = nil
        end
        if self.taskFinishEffect_Left then
            self.taskFinishEffect_Left:StopEffect()
            NodePool.Set(NodePool.KeyType.TaskFinishEffect_Left, self.taskFinishEffect_Left)
            self.taskFinishEffect_Left = nil
        end
    end
end

function MainUIPanel:SetTipShow(isShow)
    for _, v in pairs(self.tipList) do
        v.visible = isShow
    end
    self:SetIconPos()
    if not self._bgTipsBar.visible then
        --关闭手指引导显示
        self:SetTaskPlotGuideShow()
    end
end

function MainUIPanel:OnOpen()
    JumpMap:Init()
    GlobalVars.IsInCity = true --是否在内城

    --长留基金是否有可领取的奖励,红点检测
    if Model.GemFundInfo then
        Event.Broadcast(EventDefines.UIWelfareGemFund)
    end

    --登录游戏时判断哥斯拉领奖按钮的状态
    local level = BuildModel.FindByConfId(Global.BuildingWall).Level
    if Model.FinishedGodzillaCategory == 1 and level >= Global.UnlockLevelWall2 then
        --功能开启
        self._btnGodzilla.visible = true
        Net.GodzillaOnlineBonus.GetGodzillaOnlineBonusInfo(
            function(rsp)
                local statusInfo = rsp.Info
                for _, v in pairs(statusInfo) do
                    --1是有可领取的，0是没有可领取的
                    if v.Status == 1 then
                        self._btnGodzilla.visible = true
                        self._btnGodzillaRed.visible = true
                        break
                    else
                        self._btnGodzilla.visible = true
                        self._btnGodzillaRed.visible = false
                    end
                end
                self:SetIconPos()
            end
        )
    elseif Model.FinishedGodzillaCategory == 0 or level < Global.UnlockLevelWall2 then
        --全部领取完毕或功能未解锁
        self._btnGodzilla.visible = false
    end

    --设置美女图标得显示
    self._btnBeautyRed.visible = false
    local modelBeautyOnlineBonus = Model.GetMap(ModelType.BeautyOnlineBonus)
    if modelBeautyOnlineBonus.AvaliableAt == 0 then
        self:SetBeutyBtnVisble(false)
    end
    if modelBeautyOnlineBonus.AvaliableAt == -1 then
        --全都领取完了
        self._btnBeauty.visible = false
    elseif modelBeautyOnlineBonus.BonusStatus == 0 and modelBeautyOnlineBonus.StartAt > 0 then
        --正在进行中
        self._btnBeauty.visible = true
        self:SetIconByBeauty(modelBeautyOnlineBonus.BeautyOnlineBonusIndex, modelBeautyOnlineBonus.AvaliableAt)
    elseif modelBeautyOnlineBonus.BonusStatus == 1 then
        --已完成可领取
        self._btnBeauty.visible = true
        self:SetIconByBeauty(modelBeautyOnlineBonus.BeautyOnlineBonusIndex, modelBeautyOnlineBonus.AvaliableAt)
    end
    NodePool.Init(NodePool.KeyType.BeautyEnterEffect, "Effect", "EffectNode")
    self._btnBeautyEnterEffect = NodePool.Get(NodePool.KeyType.BeautyEnterEffect)
    self._btnBeautyEnterEffect.xy = Vector2(40, 45)
    self._btnBeauty:AddChild(self._btnBeautyEnterEffect)
    self._btnBeautyEnterEffect:InitNormal()
    self._btnBeautyEnterEffect:PlayEffectLoop("effects/beauty/prefab/effect_beauty_icon")

    if not self._taskPlotEffect then
        local c = 1334 - GRoot.inst.height
        NodePool.Init(NodePool.KeyType.TaskPlotEffect, "Effect", "EffectNode")
        self._taskPlotEffect = NodePool.Get(NodePool.KeyType.TaskPlotEffect)
        --self._taskPlotEffect.xy = Vector2(0, c)
        self._plotEffectNode:AddChild(self._taskPlotEffect)
        self._taskPlotEffect:InitNormal()
        self._taskPlotEffect:PlayEffectLoop("effects/task/taskploteffect/prefab/effect_main_task")
    end

    self:SetIconPos()

    Event.Broadcast(EventDefines.RefreshSkillIconShow)
    --判断任务是否都完成
    local recTask = TaskModel:GetRecommendTask()
    if not recTask then
        self:SetTipShow(false)
    else
        self:SetTipShow(true)
    end

    self._banList = BlockListModel.GetList()
    self:RefreshChapterMsg()

    Net.Chat.GetChatHistory(
        "World",
        0,
        1,
        function(msg)
            if #msg.History <= 0 then
                self._msgIcon.icon = nil
                self._msgText.text = ""
                self._msgNameTag.text = ""
                return
            end
            for _, banUser in ipairs(self._banList) do
                if banUser.UserId == msg.SenderId then
                    return
                end
            end
            msg = msg.History[1]
            ChatModel.newWorldMsgs = msg
            self:RefreshMsg()
        end
    )

    if Model.Player.AllianceId ~= "" then
        Net.Chat.GetChatHistory(
            Model.Player.AllianceId,
            0,
            1,
            function(msg)
                if #msg.History <= 0 then
                    return
                end
                for _, banUser in ipairs(self._banList) do
                    if banUser.UserId == msg.SenderId then
                        return
                    end
                end
                msg = msg.History[1]
                ChatModel.newUnionMsgs = msg
                self:RefreshMsg()
            end
        )
    end

    self._buildFace:Init(self._dragRect)
    NotifyMgr.Instance:StartCall()

    local uid = Auth.WorldData.accountId
    if not PlayerDataModel:GetData(PlayerDataEnum.BindReward .. uid) then
        --查看是否已经绑定了奖励
        if SdkModel.IsBind() then
            --请求服务器发送绑定账号奖励
            Net.UserInfo.CheckAccountBindRewards(
                function()
                    PlayerDataModel:SetData(PlayerDataEnum.BindReward .. uid, uid)
                end
            )
        end
    end
end

--设置图标位置根据显隐
function MainUIPanel:SetIconPos()
    if self._groupTaskPlot.visible == false and self._btnBeauty.visible == true and (self._groupTask.visible == false or self._bgTipsBar == false) then
        --[[ A：章节任务隐藏 美女奖励显示 推荐任务隐藏]]
        self._setIconPosCon.selectedIndex = IsAorBGuide and 0 or 10
    elseif self._groupTaskPlot.visible == false and self._btnBeauty.visible == true and (self._groupTask.visible == true or self._bgTipsBar == true) then
        --[[ A：章节任务隐藏 美女奖励显示 推荐任务显示]]
        self._setIconPosCon.selectedIndex = IsAorBGuide and 1 or 8
    elseif self._groupTaskPlot.visible == false and self._btnBeauty.visible == false and (self._groupTask.visible == true or self._bgTipsBar == true) then
        --[[ A：章节任务隐藏 美女奖励隐藏 推荐任务显示]]
        self._setIconPosCon.selectedIndex = IsAorBGuide and 2 or 9
    elseif self._groupTaskPlot.visible == false and self._btnBeauty.visible == false and (self._groupTask.visible == false or self._bgTipsBar == false) then
        --[[ A：章节任务隐藏 美女奖励隐藏 推荐任务隐藏]]
        self._setIconPosCon.selectedIndex = IsAorBGuide and 3 or 11
    elseif self._groupTaskPlot.visible == true and self._btnBeauty.visible == true and (self._groupTask.visible == false or self._bgTipsBar == false) then
        --[[ A：章节任务显示 美女奖励显示 推荐任务隐藏]]
        self._setIconPosCon.selectedIndex = 4
    elseif self._groupTaskPlot.visible == true and self._btnBeauty.visible == true and (self._groupTask.visible == true or self._bgTipsBar == true) then
        --[[ A：章节任务显示 美女奖励显示 推荐任务显示]]
        self._setIconPosCon.selectedIndex = 5
    elseif self._groupTaskPlot.visible == true and self._btnBeauty.visible == false and (self._groupTask.visible == false or self._bgTipsBar == false) then
        --[[ A：章节任务显示 美女奖励隐藏 推荐任务隐藏]]
        self._setIconPosCon.selectedIndex = 6
    elseif self._groupTaskPlot.visible == true and self._btnBeauty.visible == false and (self._groupTask.visible == true or self._bgTipsBar == true) then
        --[[ A：章节任务显示 美女奖励隐藏 推荐任务显示]]
        self._setIconPosCon.selectedIndex = 7
    end
end

--刷新章节任务显示
function MainUIPanel:RefreshChapterMsg()
    if not next(self.chapterInfo) or self.chapterInfo.Closed then
        self:CloseChapterTaskShow()
        return
    end
    self:RefreshRedPointOfChapter()
    local icon, desc, title, titlekey, progress = TaskModel:GetPlotTaskMsg(self.chapterInfo)
    if self._redPointofChapter.visible then
        local awardStr = StringUtil.GetI18n(I18nType.Commmon, "Button_Receive_Award")
        self._textChapter.text = titlekey .. " " .. title .. "(" .. "[color=#F1CE59]" .. awardStr .. "[/color]" .. ")"
    else
        self._textChapter.text = titlekey .. " " .. title .. progress
    end
end

--刷新章节红点显示
function MainUIPanel:RefreshRedPointOfChapter()
    local plotinfo = Model.GetMap(ModelType.ChapterTasksInfo)
    local plotinfoAcc = plotinfo.AccomplishedPlotTasks
    local redshow = false
    local awardNum = 0
    local _, _, _, _, _, finishNum, sumNum = TaskModel:GetPlotTaskMsg(plotinfo)
    for _, v in pairs(plotinfoAcc) do
        if not v.AwardTaken then
            awardNum = awardNum + 1
            redshow = true
        end
    end
    if finishNum == sumNum then
        awardNum = awardNum + 1
        redshow = true
    end
    --绿色加数字
    if redshow then
        self.chapterRedCtr.selectedIndex = 2
        self.chapterRedNum.text = awardNum
    end
    self._redPointofChapter.visible = redshow
    local icon, desc, title, titlekey, progress = TaskModel:GetPlotTaskMsg(self.chapterInfo)
    if redshow then
        local awardStr = StringUtil.GetI18n(I18nType.Commmon, "Button_Receive_Award")
        self._textChapter.text = titlekey .. " " .. title .. "(" .. "[color=#F1CE59]" .. awardStr .. "[/color]" .. ")"
    else
        self._textChapter.text = titlekey .. " " .. title .. progress
    end
end

function MainUIPanel:RefreshMsg()
    local msg
    if ChatModel.chatType == CHAT_TYPE.WorldChat then
        msg = ChatModel.newWorldMsgs
        self._msgCtrView.selectedIndex = 0
    else
        if Model.Player.AllianceId == "" then
            return
        end
        msg = ChatModel.newUnionMsgs
        self._msgCtrView.selectedIndex = 1
    end

    if msg then
        self._msgNameTag.text = TextUtil.FormatPlayName(msg, MSG_TYPE.Chat)
        CommonModel.SetUserAvatar(self._msgIcon, msg.Avatar)
        if msg.MType == PUBLIC_CHAT_TYPE.Normal then
            if msg.Content ~= "" then
                local emojiesName = Emojies:GetEmojieNameByIcon(EmojiesMgr:EmojieTo16String(msg.Content))
                if emojiesName then
                    self._msgText.text = StringUtil.GetI18n(I18nType.Commmon, emojiesName)
                else
                    self._msgText.text = TextUtil.FormatPosHref(msg.Content)
                end
            else
                self._msgText.text = msg.Content
            end
        else
            ChatModel:SetMsgTemplateByType(self._msgText, MSG_TYPE.Chat, msg)
        end
    else
        self._msgIcon.icon = nil
        self._msgText.text = ""
        self._msgNameTag.text = ""
    end
end

function MainUIPanel:EventListener()
    self:AddEvent(
        EventDefines.UIOnWorldMapChange,
        function(posX, posY)
            self.posX = posX
            self.posY = posY
            self._worldPos.text = "X: " .. posX .. "  Y: " .. posY
            -- --检测行军路线是否回收
            MarchLineModel.CheckRectMarchLine(posX, posY)
        end
    )
    self:AddEvent(
        EventDefines.UITriggerPanelAnim,
        function(isShow)
            if isShowPanel == isShow then
                return
            end

            if (isShowPanel) then
                self._animIn:Stop()
                self._animOut:Play()
                isSetWorldBtnGuideShow = false
                Event.Broadcast(EventDefines.CloseGuide)
            else
                self:ScheduleOnceFast(
                    function()
                        if not isShowPanel then
                            return
                        end
                        self._animIn:Play(
                            function()
                                isSetWorldBtnGuideShow = true
                            end
                        )
                        Event.Broadcast(EventDefines.CloseGuide)
                    end,
                    0.2
                )
            end
            isShowPanel = not isShowPanel
        end
    )
    self:AddEvent(
        EventDefines.UIMailsNumChange,
        function(rsp)
            self:refreshRedPoint(MAIN_UI_BTN_TYPE.Mail)
        end
    )
    self:AddEvent(
        MAILEVENTTYPE.MailsReadEvent,
        function(rsp)
            self:refreshRedPoint(MAIN_UI_BTN_TYPE.Mail)
        end
    )
    --新的成就达成
    self:AddEvent(
        EventDefines.GetNewAchievement,
        function()
            self:refreshRedPoint(MAIN_UI_BTN_TYPE.PlayerInfo)
        end
    )
    self:AddEvent(
        EventDefines.HeadPlayerRedPointCheck,
        function()
            self:refreshRedPoint(MAIN_UI_BTN_TYPE.PlayerInfo)
        end
    )
    --获取新物品
    self:AddEvent(
        EventDefines.UIRefreshBackpackRedPoint,
        function()
            self:refreshRedPoint(MAIN_UI_BTN_TYPE.Backpack)
        end
    )

    self:AddEvent(
        GM_MSG_EVENT.NewMsgNotRead,
        function()
            self._btnGm.visible = true
        end
    )

    self:AddEvent(
        GM_MSG_EVENT.MsgIsRead,
        function()
            self._btnGm.visible = false
        end
    )

    self:AddEvent(
        EventDefines.ChatEvent,
        function(msg)
            if msg.RoomId == "World" then
                ChatModel.newWorldMsgs = msg
            else
                ChatModel.newUnionMsgs = msg
            end
            self:RefreshMsg()
        end
    )
    self:AddEvent(
        EventDefines.OpenWorldMap,
        function(posX, posY, cb)
            if not posX and not posY then
                posX = Model.Player.X
                posY = Model.Player.Y
            end
            if GlobalVars.IsInCity then
                Event.Broadcast(EventDefines.UIOutCityScale)
                UIMgr:Open(
                    "MainUICloud",
                    function()
                        WeatherModel.Show(false)
                        GlobalVars.IsInCity = false
                        GlobalVars.IsInCityTrigger = false
                        GlobalVars.IsHadChangeMap = true
                        UIMgr:ClosePopAndTopPanel()
                        UIMgr:Close("City")
                        UIMgr:Open("WorldCity", posX, posY)
                        self._controller.selectedIndex = 1
                        self._controller2.selectedIndex = 1
                        --切换外城 删除收集士兵的动画
                        AnimationArmyQueue.Clear()
                        AnimationArmy.Clear()
                        GlobalVars.IsJumpGuide = false
                        self:SetWorldBtnGuideShow()
                        if cb then
                            cb()
                        end
                    end
                )
                AudioModel.Play(10002)
            else
                -- Event.Broadcast(EventDefines.UIEnterCityScale)
                WorldMap.Instance():GotoPoint(posX, posY)
                self._controller.selectedIndex = 1
            end
        end
    )
    self:AddEvent(
        EventDefines.UIEnterMyCity,
        function(cb)
            UIMgr:Open(
                "MainUICloud",
                function()
                    WeatherModel.Show(true)
                    GlobalVars.IsInCity = true
                    GlobalVars.IsInCityTrigger = true
                    GlobalVars.IsHadChangeMap = true
                    UIMgr:Close("WorldCity")
                    UIMgr:Open("City")
                    Event.Broadcast(EventDefines.UIEnterCityScale)
                    if GlobalVars.IsJumpGuide then
                        GlobalVars.IsJumpGuide = false
                    else
                        TurnModel.BuildCenter(false, true)
                    end
                    WeatherModel.CheckWeatherRain()
                    self._controller.selectedIndex = 0
                    self._controller2.selectedIndex = 0
                    --阅兵广场部队变化
                    ParadeSquareModel.ParadeSquareShow()
                    Event.Broadcast(EventDefines.UITriggerPanelAnim, true)
                    ScrollModel.RefreshMap()
                end,
                cb
            )
        end
    )
    self:AddEvent(
        EventDefines.UITaskRefreshRed,
        function()
            self:ScheduleOnce(
                function()
                    self:refreshRedPoint(MAIN_UI_BTN_TYPE.Hero)
                end,
                0.3
                --任务绿点刷新时间
            )
        end
    )
    self:AddEvent(
        EventDefines.UIOnRaderEvent,
        function()
            self:SetRadarTip()
        end
    )
    self:AddEvent(
        EventDefines.UIOnRefreshWall,
        function(rsp)
            self:SetWallFireTip()
        end
    )
    self:AddEvent(
        EventDefines.ReLoginSuccess,
        function()
            if GlobalVars.IsInCity then
                return
            end
            UIMgr:Open("WorldCity", self.posX, self.posY)
            if WorldMap.Instance() then
                WorldMap.Instance().waitingRequest()
            end
        end
    )
    self:AddEvent(
        EventDefines.PlayOnlineEffect,
        function()
            --播放在线奖励特效
            self:SetBuildAnimShow()
        end
    )
end

function MainUIPanel:Init()
    local skillDatas = Model.GetMap(ModelType.ActivitySkills)
    for _, v in pairs(skillDatas) do
        SkillModel.SetRedData(v)
    end

    for _, v in pairs(MAIN_UI_BTN_TYPE) do
        self:refreshRedPoint(v)
    end
    self:SetRadarTip()
    self:SetWallFireTip()
end

function MainUIPanel:refreshRedPoint(type)
    if not self.redPointList[type] then
        return
    end
    self.redPointList[type].redPoint:SetData(false)
    if type == MAIN_UI_BTN_TYPE.Hero then
        self:_refreshTaskReadPoint(type)
    elseif type == MAIN_UI_BTN_TYPE.Mail then
        if SqliteHelper:IsDbExist(MailModel.mail_db_name) then
            self:_refreshMailReadPoint(type)
        else
            SqliteHelper:Open(MailModel.mail_db_name)
            self:_refreshMailReadPoint(type)
            SqliteHelper:Close(MailModel.mail_db_name)
        end
    elseif type == MAIN_UI_BTN_TYPE.PlayerInfo then
        self:_refreshPlayerInfoRedPoint(type)
    elseif type == MAIN_UI_BTN_TYPE.Backpack then
        self:_refreshBackpackRedPoint(type)
    end
end

function MainUIPanel:_refreshTaskReadPoint(type)
    local taskAmount = TaskModel:GetNoticeReadAmount()
    local dailyTaskAmount = DailyTaskModel.GetRedAmount()
    local amount = taskAmount + dailyTaskAmount
    if amount > 0 then
        amount = amount > 99 and "99+" or amount
        self.redPointList[type].redPoint:SetData(true, amount)
    end
end

function MainUIPanel:_refreshMailReadPoint(type)
    local amount = MailModel:GetNotReadAmount()
    if amount > 0 and UnlockModel:UnlockCenter(UnlockModel.Center.Mail) then
        amount = amount > 99 and "99+" or amount
        self.redPointList[type].redPoint:SetData(true, amount)
    end
end

function MainUIPanel:_refreshAllianceRedPoint(type)
    local amount, flag = UnionModel:GetNotReadAmount()
    if amount > 0 then
        amount = amount > 99 and "99+" or amount
        self.redPointList[type].redPoint:SetData(true, amount)
    elseif flag then
        self.redPointList[type].redPoint:SetData(true, flag)
    end
end

function MainUIPanel:_refreshPlayerInfoRedPoint(type)
    local amount = UserModel:GetNotReadAmount()
    if amount > 0 then
        amount = amount > 99 and "99+" or amount
        self.redPointList[type].redPoint:SetData(true, amount)
    end
end

function MainUIPanel:_refreshBackpackRedPoint(type)
    local amount = GD.ItemAgent.GetNewItemAmount()
    if amount > 0 then
        self.redPointList[type].redPoint:SetData(true, amount)
    else
        self.redPointList[type].redPoint:SetData(false)
    end
end

-- 建筑队列
function MainUIPanel:BuildQueue()
    self:AddEvent(
        EventDefines.UIResetBuilder,
        function()
            self._btnQueue:Check()
            self._btnQueueLock:Check()
            Event.Broadcast(EventDefines.UISidebarPoint)
            BuildModel.UpgradePrompt()
        end
    )
    local queue_func = function(type, isbusy)
        if isbusy then
            local bid = Model.Builders[type].EventId
            local building = Model.Find(ModelType.Buildings, bid)
            if not building then
                return
            end
            GlobalVars.ClickBuilder = true
            JumpMap:JumpTo({jump = 810100, para = building.ConfId, para1 = building})
        else
            BuildModel.QueueGuideOrder()
        end
    end
    self._btnQueue:Init(BuildType.QUEUE.Free, queue_func)
    self._btnQueueLock:Init(BuildType.QUEUE.Charge, queue_func)
end

--切换内外城
function MainUIPanel:ChangeMap()
    --UIMgr.DelayCollect(5)
    if GlobalVars.IsInCity then
        Event.Broadcast(EventDefines.UIOutCityScale)
        --处理搜索引导点击
        local isGuide = GuidePanelModel:IsGuideState()
        --是否为指引大地图
        local isWorldGuide = GuidePanelModel.Info
        if isGuide and GuidePanelModel.uiType == UIType.UIMapTurnBtnUI and not isWorldGuide then
            WorldMap.AddEventAfterMap(
                function()
                    Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.SearchIconUI)
                end
            )
        end
    else
        Event.Broadcast(EventDefines.UIEnterCityScale)
    end
    UIMgr:Open(
        "MainUICloud",
        function()
            if GlobalVars.IsInCity then
                WeatherModel.Show(false)
                GlobalVars.IsInCity = not GlobalVars.IsInCity
                GlobalVars.IsHadChangeMap = true
                UIMgr:Close("City")
                UIMgr:ClosePopAndTopPanel()
                UIMgr:Open("WorldCity")
                AudioModel.Play(10002)
                self._controller.selectedIndex = 1
                self._controller2.selectedIndex = 1
                CityMapModel.GetCityFunction():SetFuncVisible(false)
                --切换外城 删除收集士兵的动画
                AnimationArmyQueue.Clear()
                self:SetWorldBtnGuideShow()
                GlobalVars.IsJumpGuide = false
            else
                self:CloseWorldBtnGuideShow()
                WeatherModel.Show(true)
                GlobalVars.IsInCity = not GlobalVars.IsInCity
                GlobalVars.IsHadChangeMap = true
                UIMgr:Close("WorldCity")
                UIMgr:Open("City")
                AudioModel.Play(10001)
                if GlobalVars.IsJumpGuide then
                    GlobalVars.IsJumpGuide = false
                else
                    TurnModel.BuildCenter(false, true)
                end
                WeatherModel.CheckWeatherRain()
                self._controller.selectedIndex = 0
                self._controller2.selectedIndex = 0
                --阅兵广场部队变化
                ParadeSquareModel.ParadeSquareShow()
                Event.Broadcast(EventDefines.UITriggerPanelAnim, true)
                ScrollModel.RefreshMap()
            end
        end
    )
end

--设置雷达提示图标
function MainUIPanel:SetRadarTip()
    local warningNum = RadarModel.GetWarningNum()
    if warningNum > 0 then
        self._btnRadar.visible = true
        self._radarTypeControl.selectedPage = "attack"
        self._textRadar.text = warningNum
    else
        local assitNum = RadarModel.GetAssitNum()
        if assitNum > 0 then
            self._btnRadar.visible = true
            self._radarTypeControl.selectedPage = "assit"
            self._textRadar.text = assitNum
        else
            self._btnRadar.visible = false
        end
    end

    if RadarModel.CheckWarning() then
        UIMgr:Open("AttackAlert")
    else
        if GlobalVars.NowTriggerId ~= 14200 then
            UIMgr:Close("AttackAlert")
        end
    end
end

--设置城墙燃烧提示效果l
function MainUIPanel:SetWallFireTip()
    local data = WallModel.GetWallData()
    if data.IsOnFire then
        --动态资源加载
        if self._wallFireNode == nil then
            self._wallFireNode = UIMgr:CreateObject("Effect", "EffectNode")
            self._wallFireNode.xy = Vector2(52, 49)
            self._btnWall:AddChild(self._wallFireNode)
            --self._wallFireNode:PlayEffectLoop("effects/basefireicon/prefab/effect_icon_fire",Vector3(130,130,130))
            self._wallFireNode:PlayDynamicEffectLoop("effect_collect", "effect_icon_fire", Vector3(130, 130, 130))
        end
        self._btnWall.visible = true
    else
        self._btnWall.visible = false
    end
end

---------------------------------行军进度条---------------------

--显示世界进度条
function MainUIPanel:OnRefreshQueueBar()
    local missionList = MissionEventModel.GetList()
    self.missions = {}
    for _, v in pairs(missionList) do
        table.insert(self.missions, v)
    end
    self.nowQueueCount = #self.missions
    self._worldQueueList.visible = self.nowQueueCount > 0
    self._worldQueueList:Init(self.missions)
    Event.Broadcast(EventDefines.UIQueueRefresh)
end

---------------------------------------------------------------

function MainUIPanel:GuildShow()
    return self._btnUnion
end

function MainUIPanel:CloseChapterTaskShow()
    self._groupTaskPlot.visible = false
    --关闭剧情任务引导
    self:SetTaskPlotGuideShow()
    self:SetIconPos()
end

--初始化礼包按钮计时和icon显示
function MainUIPanel:InitGiftBtn()
    local finish = 0
    local closeAt = 0
    local config  --礼包组
    local giftConfig  --礼包
    local curIndex = #Model.GiftPacks.GiftPacks

    local func = function()
        local time = finish - TimeUtil.UTCTime()
        if time > 0 then
            -- 显示礼包关闭倒计时
            self._textGiftTime.text = Tool.FormatTime(closeAt - TimeUtil.UTCTime())
        else
            -- 获取下一个推荐礼包
            config, curIndex, closeAt, giftConfig = GiftModel.GetNextGift(curIndex)

            if config ~= nil then
                finish = config.recommend_time + TimeUtil.UTCTime()
                self.curGiftGroup = config.id
                self._iconBtnGift.url = UITool.GetIcon(config.recommend_ticon)
                self._textGiftTime.text = Tool.FormatTime(closeAt - TimeUtil.UTCTime())
            else
                -- 没有推荐礼包的情况显示隔天刷新倒计时
                closeAt = TimeUtil.UTCTimeToTomorrow()
                finish = closeAt
                self._iconBtnGift.url = UITool.GetIcon(Global.GiftCentreIcon)
                self._textGiftTime.text = Tool.FormatTime(closeAt - TimeUtil.UTCTime())
            end
        end
    end

    local closeAt = GiftModel.GetLeftTimeOfShowSpecialNewCommanderGift()
    if closeAt > 0 then
        -- 有新手礼包推荐的情况，显示新手礼包推荐
        finish = closeAt
        local config = GiftModel.GetGiftConfig(GiftEnum.NewCommonderGiftOne)
        self._iconBtnGift.url = UITool.GetIcon(config.s_icon)
    end
    self:Schedule(func, 1)
end

function MainUIPanel:RefreshGiftShow()
    local finish = GiftModel.GetLeftTimeOfShowSpecialNewCommanderGift()
    if self.icon_func and finish <= 0 then
        self.icon_func()
    end
end
--设置指挥中心等级限制的按钮是否显示
function MainUIPanel:SetBuildCenterShow()
    --基地2级解锁
    local Mailvisible = UnlockModel:UnlockCenter(UnlockModel.Center.Mail)
    self._btnMail:CheckShow(Mailvisible)
    self.redPointList[MAIN_UI_BTN_TYPE.Mail].redPoint.visible = Mailvisible
    local Backpackvisible = UnlockModel:UnlockCenter(UnlockModel.Center.Backpack)
    self._btnBackpack:CheckShow(Backpackvisible)
    self.redPointList[MAIN_UI_BTN_TYPE.Backpack].redPoint.visible = Backpackvisible
    self._btnUnion:CheckShow(UnlockModel:UnlockCenter(UnlockModel.Center.Union))
    --基地3级解锁
    UnlockModel:UnlockCenter(UnlockModel.Center.Gift, self._btnGift)
    if not self._btnGiftEffect and UnlockModel:UnlockCenter(UnlockModel.Center.Gift) then
        NodePool.Init(NodePool.KeyType.MainUIGiftBtnEffect, "Effect", "EffectNode")
        self._btnGiftEffect = NodePool.Get(NodePool.KeyType.MainUIGiftBtnEffect)
        self._giftBtnEffectNode:AddChild(self._btnGiftEffect)
        --self._btnGiftEffect.xy = Vector2(self._view.width / 2, self._view.height / 2)
        self._btnGiftEffect:InitNormal()
        self._btnGiftEffect:PlayEffectLoop("effects/giftbtnonmainui/prefab/effect_ui_zuanshi")
    end
    UnlockModel:UnlockCenter(UnlockModel.Center.Welfare, self._btnWelfare)
    UnlockModel:UnlockCenter(UnlockModel.Center.Activity, self._btnActiviCenter)
    UnlockModel:UnlockCenter(UnlockModel.Center.Queue, self._btnQueueLock)
    self._btnQuest.visible = false
    if self._btnActiviCenter.visible then
        self:ScheduleOnceFast(
            function()
                if not IsGetActivityInfo then
                    --玩家登入游戏判断是否有开启单人活动
                    if ActivityModel.GetIsOpenActivity(1001001) then
                        GD.SingleActivityAgent.GetSingleActivityInfo()
                    end
                    ActivityModel.GetNetActivityData(
                        function()
                            IsGetActivityInfo = true
                            self:RefreshActivityIcon()
                            self:RefreshQusetionBtn()
                        end
                    )
                else
                    self:RefreshQusetionBtn()
                end
            end,
            0.2
        )
    end
    --基地4级解锁
    UnlockModel:UnlockCenter(
        UnlockModel.Center.Online,
        self._btnOnline,
        function()
            --当基地4级之后，暂存播放特效的方法，当界面只有MainUI的时候才播放
            if self._canPlayOLRewardEffect then
                self._btnOnline.visible = false
                self._cachePlayOnlineEffect = true
            end
        end
    )
    if self._groupTaskPlot.visible or self._bgTipsBar.visible then
        self:SetTaskPlotGuideShow()
    end
end

function MainUIPanel:RefreshQusetionBtn()
    local qusetOpen = false
    for _, v in pairs(ActivityModel.ActivityInfo) do
        if v.Id == 1001501 and v.Open then
            qusetOpen = true
            break
        end
    end
    if qusetOpen then
        UnlockModel:UnlockCenter(UnlockModel.Center.Question, self._btnQuest)
    else
        self._btnQuest.visible = false
    end
end

function MainUIPanel:PlayOnlineEffect()
end

--[[
    @desc:解锁在线奖励特效播放
]]
function MainUIPanel:SetBuildAnimShow()
    if not self._cachePlayOnlineEffect then
        return
    end
    self:SetIconPos()
    if self._canPlayOLRewardEffect then --or
        self._btnOnline.visible = false
        self._canPlayOLRewardEffect = false
        self._cachePlayOnlineEffect = false
        NodePool.Init(NodePool.KeyType.OnlineRewardUnlockEffect, "Effect", "EffectNode")
        local effect = NodePool.Get(NodePool.KeyType.OnlineRewardUnlockEffect)
        self._view:AddChild(effect)
        effect.xy = Vector2(self._view.width / 2, self._view.height / 2)
        effect:InitNormal()
        effect:PlayEffectSingle(
            "effects/unlock/unlockfunction/prefab/effect_unlock_function",
            function()
                NodePool.Set(NodePool.KeyType.OnlineRewardUnlockEffect, effect)
                --拖尾特效
                local _node = UIMgr:CreateObject("Effect", "EmptyNode")
                _node.xy = Vector2(self._view.width / 2, self._view.height / 2)
                self._view:AddChild(_node)
                --动态资源加载
                DynamicRes.GetBundle(
                    "effect_collect",
                    function()
                        DynamicRes.GetPrefab(
                            "effect_collect",
                            "effect_jindutiao_trail",
                            function(prefab)
                                local object = GameObject.Instantiate(prefab)
                                local particle = object:GetComponent("ParticleSystem")
                                particle:Play()
                                _node:GetGGraph():SetNativeObject(GoWrapper(object))
                                --移动
                                self:GtweenOnComplete(
                                    _node:TweenMove(self._btnOnline.xy + Vector2(44, 44), 1),
                                    function()
                                        _node:Dispose()
                                        self._btnOnline.visible = true
                                        local anim = self._btnOnline:GetTransition("Unlock")
                                        anim:Play()
                                    end
                                )
                            end
                        )
                    end
                )
            end
        )
    end
end

--设置剧情任务引导展示
function MainUIPanel:SetTaskPlotGuideShow()
    local isOK = false
    local ABIndex = ABTest.Task_ABLogic()
    print("ABTest---------------------:", ABIndex)
    if ABTest.Task_ABLogic() == 2002 then
        local bgTask = self._view:GetChild("bgTipsBar")
        isOK = bgTask.visible
    else
        isOK = self._groupTaskPlot.visible
    end

    if self.guideTimeFunc then
        if self._groupTaskPlot.visible then
            TaskPlotModel.SetGuideStage(false)
        end
        self:UnScheduleFast(self.guideTimeFunc)
    end
    if not isOK then
        Event.Broadcast(EventDefines.CloseGuide)
        return
    end
    local plotGuideData = TaskPlotModel.GetGuideData()
    local timeCount = plotGuideData.time
    local guideCount = 0
    self.guideTimeFunc = function()
        local isGuiding = GuidePanelModel:IsGuideState()
        local isBtnFreeGuiding = not GlobalVars.IsNoviceGuideStatus and not GlobalVars.IsTriggerStatus and GuidePanelModel:IsBtnFreeGuide()
        local isOk = UIMgr:GetShowPanelCount() == 0 and not GlobalVars.IsTaskPlotAnim and not ScrollModel.GetScaling()
        local isCondtion = (GlobalVars.IsInCity or GlobalVars.IsInCityTrigger) and not isGuiding and not GlobalVars.IsClicking and not GlobalVars.IsTriggerStatus and not GlobalVars.IsNoviceGuideStatus
        isCondtion = isBtnFreeGuiding and isBtnFreeGuiding or isCondtion
        if isCondtion and isOk then
            timeCount = timeCount - 1
            if self._groupTaskPlot.visible then
                TaskPlotModel.SetGuideStage(false)
            end
        else
            timeCount = plotGuideData.time
        end
        if timeCount <= 0 and guideCount < plotGuideData.number then
            guideCount = guideCount + 1
            timeCount = plotGuideData.time
            Event.Broadcast(EventDefines.CloseBtnFreeGuide)
            JumpMap:JumpSimple(812400)
            if self._groupTaskPlot.visible then
                TaskPlotModel.SetGuideStage(true)
            end
        end

        --指引固定次数
        if guideCount == plotGuideData.number then
            self:UnScheduleFast(self.guideTimeFunc)
            Event.Broadcast(EventDefines.CloseGuide)
        end
    end
    if isOK then
        --0.1秒
        if GuidePanelModel:IsGuideState() and GuidePanelModel.uiType == UIType.UIMainTaskIcon then
            Event.Broadcast(EventDefines.CloseGuide)
        end
        self:ScheduleFast(self.guideTimeFunc, 0.1)
    end
end

--在外城是指引返回内城
function MainUIPanel:SetWorldBtnGuideShow()
    --如果动画正在播放中则不指引手指--如果正在指向城外浮标，那么不指引回城
    if not isSetWorldBtnGuideShow or GuidePanelModel:IsWorldCityTownTip() or self._animIn.playing or self._animOut.playing then
        return
    end
    if self.WorldGuideTimeFunc then
        self:UnSchedule(self.WorldGuideTimeFunc)
    end
    local timeCount = GlobalMisc.BackguideTime
    self.WorldGuideTimeFunc = function()
        local isGuiding = GuidePanelModel:IsGuideState()
        if not isGuiding and UIMgr:GetShowPanelCount() == 0 and not GlobalVars.IsInCity and Model.Player.Level < GlobalMisc.BackguideLevel then
            timeCount = timeCount - 1
        else
            timeCount = GlobalMisc.BackguideTime
        end
        if timeCount <= 0 and isSetWorldBtnGuideShow then
            timeCount = GlobalMisc.BackguideTime
            JumpMap:JumpSimple(813000, true) --指引到大地图
        end
    end
    self:Schedule(self.WorldGuideTimeFunc, 1)
end

function MainUIPanel:CloseWorldBtnGuideShow()
    if self.WorldGuideTimeFunc then
        self:UnSchedule(self.WorldGuideTimeFunc)
        local isGuiding = GuidePanelModel:IsGuideState()
        if isGuiding and GuidePanelModel:GetJumpId() == 813000 then
            Event.Broadcast(EventDefines.CloseGuide)
        end
    end
end

--显示主界面活动图标
function MainUIPanel:RefreshActivityIcon()
    self.mTimeFunc = function()
        if not self.timego then
            return
        end
        local tempEndTime = 0
        local tempTime = 0
        if self.mEndTime and self.mEndTime - Tool.Time() >= 0 then
            tempEndTime = self.mEndTime - Tool.Time()
        end
        if self.mTime - Tool.Time() >= 0 then
            tempTime = self.mTime - Tool.Time()
        end
        if (self.mEndTime and tempEndTime < 0) or tempTime <= 0 then
            if self.mEndTime and tempEndTime <= 0 and cutActivityIndex > 0 then
                --优化 更新活动数据
                ActivityModel.RemoveActivityInShow()
            end
            self:SetActivityIcon()
            return
        end
        if cutActivityIndex > 0 then
            self._btnActiviCenter:GetController("c1").selectedIndex = tempEndTime > 0 and 1 or 0
            local nameStr = StringUtil.GetI18n(I18nType.Commmon, self.activityInfo.activity_name)
            self._btnActiviCenter:GetChild("title").text = nameStr
            self._btnActiviCenter:GetChild("titleTime").text = TimeUtil.SecondToDHMS(tempEndTime)
        end
    end
    if cutActivityIndex == 0 then
        self.mTime = Tool.Time() + 5
        self.mEndTime = nil
        self._btnActiviCenter:GetController("c1").selectedIndex = 0
        self._btnActiviCenter:GetChild("icon").icon = UITool.GetIcon(Global.ActivityCentreIcon)
        self._btnActiviCenter:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_CENTER")
        self.timego = true
        if self.mTimeFunc then
            self:UnSchedule(self.mTimeFunc)
        end
        self:Schedule(self.mTimeFunc, 1)
    else
        --延迟获得活动信息
        self:ScheduleOnceFast(
            function()
                local data = ActivityModel.GetActivityData(ActivityModel.TypeModel.Show)
                if data[cutActivityIndex] then
                    self.timego = true
                    self.mTime = Tool.Time() + ActivityModel.GetActivityConfig(data[cutActivityIndex].Id).main_show_time
                    self.mEndTime = data[cutActivityIndex].EndAt
                    if self.mTimeFunc then
                        self:UnSchedule(self.mTimeFunc)
                    end
                    self:Schedule(self.mTimeFunc, 1)
                end
            end,
            0.2
        )
    end
end

function MainUIPanel:SetActivityIcon()
    self.timego = false
    local data = ActivityModel.GetActivityData(ActivityModel.TypeModel.Show)
    for k, v in ipairs(data) do -- 问卷调查  不显示再活动中心  （特殊处理）
        if v.Id == 1001501 then
            table.remove(data, k)
            break
        end
    end
    if not next(data) then
        self:UnSchedule(self.mTimeFunc)
        return
    end
    if (self.mEndTime and self.mEndTime - Tool.Time() <= 0 and cutActivityIndex ~= 0) or cutActivityIndex >= #data then
        cutActivityIndex = 0
    else
        cutActivityIndex = cutActivityIndex + 1
    end

    cutActivityIndex = cutActivityIndex > #data and 0 or cutActivityIndex
    if data[cutActivityIndex] then
        cutActivityId = data[cutActivityIndex].Id
    else
        cutActivityId = 0
    end
    if cutActivityIndex < #data + 1 then
        if cutActivityIndex == 0 then
            self._btnActiviCenter:GetController("c1").selectedIndex = 0
            self._btnActiviCenter:GetChild("icon").icon = UITool.GetIcon(Global.ActivityCentreIcon)
            self._btnActiviCenter:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_CENTER")
            self.mTime = Tool.Time() + 5
            self.mEndTime = nil
            self.timego = true
            return
        end
        local activiytInfo = ActivityModel.GetActivityConfig(data[cutActivityIndex].Id)
        if data[cutActivityIndex].Id == 1001001 then
            self.mEndTime = Model.SingleActivity_EndAt
        else
            self.mEndTime = data[cutActivityIndex].EndAt
        end
        self._btnActiviCenter:GetChild("icon").icon = UITool.GetIcon(activiytInfo.circleicon)
        local nameStr = StringUtil.GetI18n(I18nType.Commmon, activiytInfo.activity_name)
        self._btnActiviCenter:GetChild("title").text = nameStr
        local timeStr = nil
        if not self.mEndTime or self.mEndTime - Tool.Time() <= 0 then
            timeStr = "00:00:00"
            self._btnActiviCenter:GetController("c1").selectedIndex = 0
        else
            self._btnActiviCenter:GetController("c1").selectedIndex = 1
            timeStr = TimeUtil.SecondToDHMS(self.mEndTime - Tool.Time())
        end
        self._btnActiviCenter:GetChild("titleTime").text = timeStr
        self.activityInfo = activiytInfo
        self.mTime = Tool.Time() + self.activityInfo.main_show_time
        self.timego = true
    end
end

function MainUIPanel:TriggerOnclick(callback)
    self.Triggercallback = callback
end

--美女图标显隐藏
function MainUIPanel:SetBeutyBtnVisble(isVisble)
    self._btnBeauty.visible = isVisble
end
--美女图标计时
function MainUIPanel:SetIconByBeauty(nextIndex, nextAvaliableAt)
    local beautyTimeText = self._btnBeauty:GetChild("title")
    local beautyCon = self._btnBeauty:GetController("c1")
    if nextIndex < 0 then
        self._btnBeautyRed.visible = false
        return
    end
    self:StartBeautyTime(
        beautyTimeText,
        nextAvaliableAt,
        function(isTiming)
            if isTiming then
                beautyCon.selectedIndex = 1
                self._btnBeautyRed.visible = isTiming
            else
                beautyCon.selectedIndex = 0
                self._btnBeautyRed.visible = isTiming
            end
        end
    )
end

function MainUIPanel:StartBeautyTime(beautyTimeText, nextAvaliableAt, func)
    if self.beautyTimeFunc then
        self:UnSchedule(self.beautyTimeFunc)
    end
    --委托
    self.beautyTimeFunc = function()
        local cutT = nextAvaliableAt - Tool.Time()
        if cutT > 0 then
            func(false)
            beautyTimeText.text = TimeUtil.SecondToDHMS(cutT)
        else
            func(true)
            self:UnSchedule(self.beautyTimeFunc)
        end
    end
    self:Schedule(self.beautyTimeFunc, 1)
    --这里暂停0.5s
    --Scheduler.ScheduleOnce(0.01)
end

function MainUIPanel:GroupBtnsMatch()
    local upwardBtn = {
        self._btnQueueLock,
        self._btnWelfare,
        self._btnActiviCenter,
        self._btnActiviCenter
    }
    local downwardBtn = {
        self._btnOnline,
        self._btnHelp,
        self._btnHelp,
        self._btnRadar,
        self._btnRadar,
        self._btnWall,
        self._btnWall,
        self._btnWall,
        self._btnOnline,
        self._btnBeauty,
        self._btnGodzilla
    }
    if MathUtil.HaveMatch() then
        local scaleRatio = 0.75
        --1 - (heightRatio - 1)
        local offset = 1 - scaleRatio
        for k, v in pairs(groupBtns) do
            for _, btn in pairs(v) do
                if k == "upperLeft" then
                    btn:SetPivot(0, 0)
                elseif k == "lowerLeft" then
                    btn:SetPivot(0, 1)
                elseif k == "lowerRight" then
                    btn:SetPivot(1, 1)
                else
                    btn:SetPivot(1, 0)
                end
                btn:SetScale(scaleRatio, scaleRatio)
            end
        end
        for _, v in pairs(upwardBtn) do
            self:UpwardOffset(v, offset)
        end
        for _, v in pairs(downwardBtn) do
            self:DownwardOffset(v, offset)
        end
        self._btnGodzilla.x = self._btnGodzilla.x - self._btnGodzilla.width * offset - 10
    --self._btnWall.y = self._btnWall.y + 30
    --self._btnActiviCenter.y = self._btnActiviCenter.y - 20
    end
end
--向上偏移
function MainUIPanel:UpwardOffset(btn, offsetRatio)
    btn.y = btn.y - btn.height * offsetRatio
end
--向下偏移
function MainUIPanel:DownwardOffset(btn, offsetRatio)
    btn.y = btn.y + btn.height * offsetRatio
end
--侧边栏适配时的一个位置
function MainUIPanel:GetBtnQueueLockPos()
    return self._btnOnline.y - self._btnOnline.height
end

--屏蔽相关主界面按钮
function MainUIPanel:SetTouchEnable(touchEnable, touchStr)
    local touchArray = {}
    table.insert(touchArray, self._mainHead)
    table.insert(touchArray, self._btnPower)
    table.insert(touchArray, self._btnVip)
    table.insert(touchArray, self._btnGold)
    table.insert(touchArray, self._tagResources)
    table.insert(touchArray, self._btnSkill)
    table.insert(touchArray, self._btnQueue)
    table.insert(touchArray, self._btnQueueLock)
    table.insert(touchArray, self._btnSkill)
    table.insert(touchArray, self._btnWelfare)
    table.insert(touchArray, self._btnOnline)
    table.insert(touchArray, self._btnGift)
    table.insert(touchArray, self._btnActiviCenter)
    table.insert(touchArray, self._btnWall)
    table.insert(touchArray, self._btnRadar)
    table.insert(touchArray, self._btnGodzilla)
    table.insert(touchArray, self._btnBeauty)
    table.insert(touchArray, self._btnHelp)
    table.insert(touchArray, self._btnWorld)
    table.insert(touchArray, self._btnTask)
    table.insert(touchArray, self._btnBackpack)
    table.insert(touchArray, self._btnMail)
    table.insert(touchArray, self._btnUnion)
    table.insert(touchArray, self._chatVeiw)
    table.insert(touchArray, self._taskPlot)
    table.insert(touchArray, self._plotIcon)
    table.insert(touchArray, self._bgTipsBar)
    table.insert(touchArray, self._bgTipsBar2)
    for _, v in pairs(touchArray) do
        if v.name == touchStr then
            v.touchable = true
        else
            v.touchable = touchEnable
            local tempTouchable = v.touchable
        end
    end
end

--城市切换的时候的特效
function MainUIPanel:SwitchCityEffect()
    self._btnWorldEffect:PlayEffectLoop("effects/innercity/prefab/effect_ui_innercity", Vector3(134, 133, 120),1)
end

--设置推荐任务的描述的颜色
function MainUIPanel:SetRecommendTaskColor(finish)
    if IsAorBGuide and finish then
        self._textTips.color = YellowColor
    else
        self._textTips.color = WhiteColor
    end
    --如果是B引导
    if not IsAorBGuide then
        if finish then
            self._textTips.textFormat.size = 24
            self._textTips.verticalAlign = VertAlignType.Top
        else
            self._textTips.textFormat.size = 30
            self._textTips.verticalAlign = VertAlignType.Middle
        end
    end
end

return MainUIPanel
