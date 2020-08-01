--[[
    Author:Baggio-Wang
    Function:新手引导界面
]]
local Novice = UIMgr:NewUI("Novice")
local NoviceModel = import("Model/NoviceModel")
local JumpMap = import("Model/JumpMap")
local JumpModel = import("Model/JumpMapModel")
local TriggerGuide = import("Model/TriggerGuideLogic")
local GlobalVars = GlobalVars
local NoviceType = _G.GD.GameEnum.NoviceType

local triggerId = 0
local triggerStep = 0
local lastRole = nil
local lastType = 0
local dialogDirection = 0
local triggerClick = nil
local IsTaskPlotDialog = nil

function Novice:OnInit()
    local view = self.Controller.contentPane
    self._ctr = view:GetController("c1")
    self._bg = view:GetChild("bgTouch")
    self._bgDown = view:GetChild("bgDown")
    self._bgTop = view:GetChild("bgTop")
    self._novice = view:GetChild("item"):GetChild("item")
    self._novice2 = view:GetChild("item"):GetChild("item2")
    self._name = view:GetChild("item"):GetChild("item"):GetChild("titleName")
    self._dialog = view:GetChild("item"):GetChild("item"):GetChild("text")
    self._name1 = view:GetChild("item"):GetChild("item2"):GetChild("titleName")
    self._dialog1 = view:GetChild("item"):GetChild("item2"):GetChild("text")
    self._dialogBg = view:GetChild("item"):GetChild("bgDownBox")
    self._noviceText = view:GetChild("text")
    self._noviceStart = view:GetChild("itemStart")
    self._asideSpeak = view:GetChild("itemStart"):GetChild("text")
    self._noviceCtr = view:GetChild("itemStart"):GetController("c1")
    self._noviceStartSkip = view:GetChild("_skip")
    self._noviceStartSkip.text = StringUtil.GetI18n(I18nType.Commmon, "UI_skip")
    self._noviceClose = self._novice:GetChild("_btnClose")
    self._noviceClose1 = self._novice2:GetChild("_btnClose")

    self._bgCtr = view:GetChild("item"):GetController("c1")
    self._startCtr = view:GetChild("item"):GetChild("item"):GetController("c1")
    self._startBtn = view:GetChild("item"):GetChild("item"):GetChild("btnUpgrade")
    self._leftBtn = view:GetChild("item"):GetChild("item"):GetChild("btnLeft")
    self._leftBtn:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "ALLIANCE_BUTTON_CONSIDER")
    self._rightBtn = view:GetChild("item"):GetChild("item"):GetChild("btnRight")
    self._rightBtn:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "ALLIANCE_BUTOTN_AGREE")
    self._btntxt = self._startBtn:GetChild("title")
    self._btntxt.text = StringUtil.GetI18n(I18nType.Commmon, "UI_GUIDE_BUTTON_FIRE")

    view:GetChild("item").sortingOrder = 1001
    view:GetChild("itemStart").sortingOrder = 1002
    --self._noviceText.sortingOrder = 1003
    self._skip.sortingOrder = 1003

    self:AddListener(
        self._startBtn.onClick,
        function()
            if Model.Player.GuideStep == 10007 then
                Event.Broadcast(EventDefines.CloseGuide)
            end
            local NoviceInfo = NoviceModel.GetNoviceGuideByConfId(Model.Player.GuideStep, Model.Player.GuideVersion)
            AudioModel.StopSpeech()
            self:DialogSelectPage(0)
            self:DialogButtonSelectPage(0)
            self.timeControllerFast = function()
                self:RemoveCharacter()
                NoviceModel:NextStep()
            end
            self:ScheduleOnceFast(self.timeControllerFast, 0.2)
        end
    )
    self:AddListener(
        self._leftBtn.onClick,
        function()
            self:DialogSelectPage(0)
            self.timeControllerFast = function()
                self:RemoveCharacter()
                self:NextTriggerStep()
            end
            self:ScheduleOnceFast(self.timeControllerFast, 0.2)
        end
    )

    self:AddEvent(
        EventDefines.BuildingCenterJumpNovice,
        function()
            self.timeControllerFast = function()
                NoviceModel.SetCanSkipNovice(true)
            end
            self:ScheduleOnceFast(self.timeControllerFast, 1)
        end
    )
    self:AddEvent(
        EventDefines.BuildingCenterFreeClick,
        function()
            self.timeControllerFast = function()
                if NoviceModel.GetCanSkipNovice() == false then
                    NoviceModel.SetCanSkipNovice(true)
                end
            end
            self:ScheduleOnceFast(self.timeControllerFast, 0.5)
        end
    )
    self:AddListener(
        self._rightBtn.onClick,
        function()
            self:DialogSelectPage(0)
            self.timeControllerFast = function()
                self:RemoveCharacter()
                self:NextTriggerStep()
                Net.Items.GetAllianceFlyCityPos(
                    function(rsp)
                        UIMgr:ClosePopAndTopPanel()

                        local data = {}
                        data.ConfId = Global.AllianceFlyCityItemID
                        data.BuildType = WorldBuildType.UnionGoLeader
                        data.posNum = rsp.X * 10000 + rsp.Y
                        WorldMap.AddEventAfterMap(
                            function()
                                Event.Broadcast(EventDefines.BeginBuildingMove, data)
                            end
                        )
                        Event.Broadcast(EventDefines.OpenWorldMap, rsp.X, rsp.Y)
                        UIMgr:Close("UnionMain/UnionMain")
                    end
                )
            end
            self:ScheduleOnceFast(self.timeControllerFast, 0.2)
        end
    )
    self.PlayerFire = {}
    self.EnemyFire = {}
    local btn = view

    self:AddListener(
        btn.onTouchEnd,
        function()
            if Stage.inst.touchCount > 1 then
                return
            end
            if IsTaskPlotDialog then
                if NoviceModel.GetCanSkipNovice() then
                    NoviceModel.SetCanSkipNovice(false)
                    self.timeControllerFast = function()
                        --最后一步时
                        if self.dialogInfo.isEnd then
                            self:RemoveCharacter()
                            UIMgr:Close("Novice")
                            NoviceModel.CloseUI()
                            if not self.dialogInfo.isStart then
                                Event.Broadcast(EventDefines.TaskPlotReview)
                            else
                                --最后一步
                                GlobalVars.IsTaskPlotAnim = false
                                return
                            end
                        else
                            self:RemoveCharacter()
                            UIMgr:Close("Novice")
                            NoviceModel.CloseUI()
                            Event.Broadcast(EventDefines.TaskPlotDialog, self.dialogInfo.isStart)
                        end
                    end
                    self:ScheduleOnceFast(self.timeControllerFast, 0.2)
                    return
                end
            end

            if NoviceModel.GetCanSkipNovice() == true then
                NoviceModel.SetCanSkipNovice(false)
                if triggerId == 0 then
                    local step = Model.Player.GuideStep
                    local version = Model.Player.GuideVersion
                    local NoviceInfo = NoviceModel.GetNoviceGuideByConfId(step, version)
                    if NoviceInfo.type == _G.GD.GameEnum.NoviceType.Dialog and Model.Player.GuideStep ~= 10007 then
                        AudioModel.StopSpeech()
                        if NoviceInfo.spokesman ~= nil then
                            self.timeControllerFast = function()
                                self:RemoveCharacter()
                                NoviceModel:NextStep()
                            end
                            self:ScheduleOnceFast(self.timeControllerFast, 0.2)
                        else
                            if self.skipFunc then
                                AudioModel.StopSpeech()
                                self:UnScheduleFast(self.skipFunc)
                                self.skipFunc()
                                self.skipFunc = nil
                            end
                        end
                    else
                        if Model.Player.GuideVersion == 1 and Model.Player.GuideStep < 10057 then
                            --Log.Error("Weak Guide NextStep-----------------------")
                            self:RemoveCharacter()
                            NoviceModel:NextStep()
                        elseif Model.Player.GuideVersion == 0 and Model.Player.GuideStep < 10049 then
                            --Log.Error("Weak Guide NextStep-----------------------")
                            self:RemoveCharacter()
                            NoviceModel:NextStep()
                        elseif Model.Player.GuideVersion == 2 and Model.Player.GuideStep < 10043 then
                            self:RemoveCharacter()
                            NoviceModel:NextStep()
                        elseif Model.Player.GuideVersion == 3 and Model.Player.GuideStep < 10050 then
                            self:RemoveCharacter()
                            NoviceModel:NextStep()
                        end
                        if
                            Model.Player.GuideStep == 10031 or (Model.Player.GuideStep == 10043 and Model.Player.GuideVersion == 1) or
                                (Model.Player.GuideStep == 10049 and Model.Player.GuideVersion == 0)
                         then
                            --Log.Error("11111111111222222222222------")
                            Event.Broadcast(EventDefines.NoviceBuildingGuideNextStep, true)
                        end
                    end
                else
                    local NoviceInfo = NoviceModel.GetNoviceGuideByConfId(triggerId + triggerStep)
                    if NoviceInfo.type == _G.GD.GameEnum.NoviceType.TriggerDialog then
                        Log.Info("novice triggerdialog....................click")
                        AudioModel.StopSpeech()
                        self.timeControllerFast = function()
                            self:RemoveCharacter()
                            self:NextTriggerStep()
                        end
                        self:ScheduleOnceFast(self.timeControllerFast, 0.5)
                    else
                        self:UnScheduleFast(self.timeControllerFast)
                        self.skipFunc = nil
                        self:RemoveHelicopter()
                        self:RemoveCharacter()
                        self:NextTriggerStep()
                    end
                end
            end
        end
    )

    self:AddListener(
        self._noviceStartSkip.onClick,
        function()
            self._noviceStartSkip.visible = false
            if GlobalVars.IsTriggerStatus or (GlobalVars.IsNoviceGuideStatus and ABTest.GuideSkipButtonAB_Logic() == 7001) then
                if self.skipFunc then
                    AudioModel.StopSpeech()
                    self:UnScheduleFast(self.skipFunc)
                    self.skipFunc()
                    self.skipFunc = nil
                end
            end
            if GlobalVars.IsNoviceGuideStatus and ABTest.GuideSkipButtonAB_Logic() == 7002 then
                --Log.Error("11111111111111111111------")
                NoviceModel.SetCanSkipNovice(false)
                Event.Broadcast(EventDefines.NoviceBuildingGuideNextStep, false)
                if self.passImage then
                    self.passImage:Dispose()
                    self.passImage = nil
                end
                if self.timeControllerFast then
                    self:UnScheduleFast(self.timeControllerFast)
                end
                if Model.Player.GuideStep < 10012 then
                    self:StopMovie()
                end
                self:RemoveMovieController()
                Event.Broadcast(EventDefines.OpenPanelAndBuilding)
                Event.Broadcast(EventDefines.SkipNoviceGuide)
            end
        end
    )
end

--是否是剧情任务对话
function Novice:OnOpen(id, step, chunkInfo, isTaskPlotDialog)
    --开始对话时跳转引导屏蔽关闭遮罩
    Event.Broadcast(EventDefines.DelayMask, false)
    self:CreateCharacter()
    self.dialogInfo = nil
    IsTaskPlotDialog = isTaskPlotDialog
    if IsTaskPlotDialog then
        self:TaskPlotDialog(chunkInfo)
        return
    end
    if id ~= nil then
        self:TriggerGuideShowMessage(id, step, chunkInfo)
    else
        self:UpdateShowMessage()
    end
end

function Novice:SelectPage(page)
    self._ctr.selectedIndex = page
end

function Novice:ItemSelectPage(page)
    self._noviceCtr.selectedIndex = page
end

function Novice:DialogSelectPage(page)
    self._bgCtr.selectedIndex = page
end

function Novice:DialogButtonSelectPage(page)
    self._startCtr.selectedIndex = page
end

function Novice:SetComponentVisible(value)
    self._bg.visible = value
    self._novice.visible = value
    self._itemStart.visible = value
end

function Novice:CreateMovieController()
    -- print("novice step===", Model.Player.GuideStep)
    --视频测试
    if self.MovieNode == nil and Model.Player.GuideStep < 10011 then
        Event.Broadcast(EventDefines.ClosePanelAndBuilding)

        NodePool.Init(NodePool.KeyType.NoviceMovieController, "Effect", "SpineNode")
        self.MovieNode = NodePool.Get(NodePool.KeyType.NoviceMovieController)
        self.MovieNode:PlayVideoPlayerAnim("prefabs/videoplay")
        self.MovieNode.displayObject.cachedTransform.name = "MovieNode"
        self.MovieNode.sortingOrder = 1000
        self.Controller.contentPane:AddChild(self.MovieNode)
        --self._noviceStart:AddChild(self.MovieNode)

        if self.MovieNode ~= nil then
            local gObj = self.MovieNode.displayObject.cachedTransform:Find("GoWrapper")
            local a = gObj:Find("MovieCanvas(Clone)")
            local b = a:Find("RawImage")
            self.MovieController = b:GetComponent("VideoPlayerController")
            b:GetComponent("RectTransform").sizeDelta = Vector2(GRoot.inst.width, GRoot.inst.height)
            b:GetComponent("RectTransform").anchoredPosition = Vector2(0, Screen.height - GRoot.inst.height)
        end
    end

    -- if Model.Player.GuideStep < 10010 then
    --     Event.Broadcast(EventDefines.ClosePanelAndBuilding)
    -- end
end

function Novice:RemoveMovieController()
    if self.MovieNode ~= nil then
        self.MovieNode:RemoveMovieNode()
        NodePool.Remove(NodePool.KeyType.NoviceMovieController)
        self.MovieNode:Dispose()
    end
end

function Novice:CreateHelicopter()
    if self.helicopter == nil then
        NodePool.Init(NodePool.KeyType.NoviceHelicopter, "Effect", "SpineNode")
        self.helicopter = NodePool.Get(NodePool.KeyType.NoviceHelicopter)
        self.helicopter:PlayNoviceHelicopterAnim("prefabs/spine/novice/tu_anim", "ZSJ")
        self.helicopter:SetXY(GRoot.inst.width / 2, GRoot.inst.height / 2 + 400)
        self._noviceStart:AddChild(self.helicopter)
    end
end

function Novice:RemoveHelicopter()
    if self.helicopter ~= nil then
        self.helicopter:RemoveNoviceHelicopterAnim()
        NodePool.Remove(NodePool.KeyType.NoviceHelicopter)
    end
end

function Novice:CreateCharacter()
    if self.character == nil then
        local view = self.Controller.contentPane
        NodePool.Init(NodePool.KeyType.NoviceCharacter, "Effect", "SpineNode")
        self.character = NodePool.Get(NodePool.KeyType.NoviceCharacter)
        view:GetChild("item"):AddChild(self.character)
    end
end

function Novice:RemoveCharacter()
    if self.character ~= nil then
        self.character:RemoveNoviceCharacterAnim()
        NodePool.Remove(NodePool.KeyType.NoviceCharacter)
    end
end

function Novice:PlayDialogMoveAnim(person, text, spinePath, spineName)
    self._novice.sortingOrder = 1002
    self._novice2.sortingOrder = 1003
    self._novice:SetXY(0 - self._novice.width, GRoot.inst.height - 480)
    self._novice2:SetXY(GRoot.inst.width + self._novice2.width, GRoot.inst.height - 480)
    if dialogDirection == 0 then
        self._name.text = StringUtil.GetI18n(I18nType.Spokesman, person)
        self._dialog.text = StringUtil.GetI18n(I18nType.NoviceDialog, text)
        self.character:SetXY(0 - GRoot.inst.width / 2, self._novice.y + 50)
        self.character:TweenMove(Vector2(GRoot.inst.width / 2, self._novice.y + 50), 0.2)
        self._novice:TweenMove(Vector2(GRoot.inst.width / 2 - self._novice.width / 2, GRoot.inst.height - 480), 0.3)
        self.character:PlayNoviceCharacterAnim(spinePath, spineName)
    else
        self._name1.text = StringUtil.GetI18n(I18nType.Spokesman, person)
        self._dialog1.text = StringUtil.GetI18n(I18nType.NoviceDialog, text)
        self._novice2:TweenMove(Vector2(GRoot.inst.width / 2 - self._novice.width / 2, GRoot.inst.height - 480), 0.3)
        self.timeControllerFast = function()
            self.character:SetXY(GRoot.inst.width / 2, self._novice.y + 50)
            self.character:PlayNoviceCharacterAnim(spinePath, spineName)
        end
        self:ScheduleOnceFast(self.timeControllerFast, 0.3)
    end
    if lastRole ~= person then
        if dialogDirection == 1 then
            dialogDirection = 0
        else
            dialogDirection = 1
        end
    else
        dialogDirection = 0
    end
    lastRole = person
end
--打印效果结束回调
function Novice:TypingEffectEndCall()
    self._noviceClose.visible = true
    self._noviceClose1.visible = true
    self.waitDialp = false
end

--Boot steps触发引导各个类型步骤执行方法
function Novice:TriggerGuideShowMessage(id, step, chunkInfo)
    if (triggerId + triggerStep) == (id + step) then
        return
    end
    --同一步骤的不执行两次
    Log.Warning("================>>>>Novice:TriggerGuideShowMessage:{0}", (id + step))
    triggerId = id
    triggerStep = step
    Event.Broadcast(EventDefines.GuideMask, false)
    local NoviceInfo = NoviceModel.GetNoviceGuideByConfId(id + step)
    self._noviceStartSkip.visible = false
    local guideLayer = UIMgr:GetUI("GuideLayer")
    if guideLayer then
        guideLayer._guide:SetShow(true)
    end
    local typeSwitch = {
        --触发式引导对话
        [NoviceType.TriggerDialog] = function()
            --对话引导出现时关闭手指
            Event.Broadcast(EventDefines.CloseGuide)
            if guideLayer then
                guideLayer._guide:SetShow(false)
            end
            if id == 11700 and step == 3 then
                UIMgr:Close("PlayerDetails")
            end
            if id == 11200 and step == 1 then
                self:DialogSelectPage(2)
            elseif id == 13900 and step == 1 then
                self:DialogSelectPage(3)
            else
                self:DialogSelectPage(0)
            end
            self:SelectPage(0)
            self:DialogButtonSelectPage(0)
            self._dialogBg.sortingOrder = 0
            self.character.sortingOrder = 1001
            if NoviceInfo.dubbing then
                AudioModel.PlaySpeech(string.lower(NoviceInfo.dubbing))
            end
            self:PlayDialogMoveAnim(NoviceInfo.spokesman, NoviceInfo.text, NoviceInfo.roleRes[1], NoviceInfo.roleRes[2])
            self.timeControllerFast = function()
                NoviceModel.SetCanSkipNovice(true)
            end
            self:ScheduleOnceFast(self.timeControllerFast, 0.5)
        end,
        --选框对话
        [NoviceType.TriggerSpeDialog] = function()
            self:SelectPage(0)
            self:DialogSelectPage(0)
            self:DialogButtonSelectPage(2)
            self._dialogBg.sortingOrder = 0
            self.character.sortingOrder = 1001
            if NoviceInfo.dubbing then
                AudioModel.PlaySpeech(string.lower(NoviceInfo.dubbing))
            end
            self:PlayDialogMoveAnim(NoviceInfo.spokesman, NoviceInfo.text, NoviceInfo.roleRes[1], NoviceInfo.roleRes[2])
        end,
        --框带文字
        [NoviceType.TriggerTxt] = function()
            Log.Info("novice.... triggertxt....{0}", triggerId + triggerStep)
            TriggerGuide:TriggerGuideStart(triggerId + triggerStep, StringUtil.GetI18n(I18nType.NoviceDialog, NoviceInfo.text))
            NoviceModel.CloseUI()
        end,
        --触发引导点击
        [NoviceType.TriggerClick] = function()
            self:RemoveCharacter()
            if NoviceInfo.turnId ~= nil then
                if chunkInfo ~= nil then
                    TriggerGuide:TriggerGuideStart(triggerId + triggerStep, chunkInfo)
                else
                    TriggerGuide:TriggerGuideStart(triggerId + triggerStep, NoviceInfo.turnId.jump)
                end
            else
                TriggerGuide:TriggerGuideStart(triggerId + triggerStep)
            end
            if triggerId + triggerStep ~= 12107 and triggerId + triggerStep ~= 15307 then
                NoviceModel.CloseUI()
            end
        end,
        --触发引导播放图片
        [NoviceType.TriggerPic] = function()
            self:SelectPage(1)
            self._asideSpeak.text = ""
            --self._noviceText.text = ""
            self._noviceStart.alpha = 0
            self._noviceStartSkip.visible = false
            NoviceModel.SetCanSkipNovice(false)
            local sTime = 3
            if (id == 14500 or id == 14600) and step == 1 then
                --sTime = 11
                self:ItemSelectPage(2)
            elseif (id == 14500 or id == 14600) and step == 3 then
                self:ItemSelectPage(3)
                self:CreateHelicopter()
            elseif id == 14700 and step == 2 then
                --sTime = 8
                self:ItemSelectPage(4)
            end

            if NoviceInfo.dubbing then
                sTime = AudioModel.PlaySpeech(string.lower(NoviceInfo.dubbing))
            end
            self.skipFunc = function()
                NoviceModel.SetCanSkipNovice(false)
                self:RemoveHelicopter()
                self:GtweenOnComplete(
                    self._noviceStart:TweenFade(0, 0.2),
                    function()
                        self:NextTriggerStep()
                    end
                )
            end

            local speakFun = function(allInterval)
                NoviceModel.SetCanSkipNovice(true)
                self._noviceStartSkip.visible = true
                local waitTime = math.abs(sTime - allInterval)
                self.timeControllerFast = function()
                    if self.skipFunc then
                        self.skipFunc()
                        self.skipFunc = nil
                    end
                end
                self:ScheduleOnceFast(self.timeControllerFast, waitTime)
            end

            self:GtweenOnComplete(
                self._noviceStart:TweenFade(1, 0.2),
                function()
                    if NoviceInfo.text then
                        self._asideSpeak.text = StringUtil.GetI18n(I18nType.NoviceDialog, NoviceInfo.text)
                        _G.GameUtil.TypingEffectState(self._asideSpeak, 0.034, 1.5, speakFun)
                        --self._noviceText.text = StringUtil.GetI18n(I18nType.NoviceDialog, NoviceInfo.text)
                        --_G.GameUtil.TypingEffectState(self._noviceText, 0.034, 1.5, speakFun)
                    else
                        local wait = function() speakFun(1.5) end
                        self:ScheduleOnceFast(wait, 1.5)
                    end
                end
            )
        end
    }
    if typeSwitch[NoviceInfo.type] then
        typeSwitch[NoviceInfo.type]()
    end
    lastType = NoviceInfo.type
end

function Novice:PlayMovie()
    if self.MovieController.videoPlayer ~= nil then
        self.MovieController.videoPlayer:Play()
    end
end

function Novice:PauseMovie()
    if self.MovieController.videoPlayer ~= nil then
        self.MovieController.videoPlayer:Pause()
    end
end

function Novice:StopMovie()
    if self.MovieController.videoPlayer ~= nil then
        self.MovieController.videoPlayer:Stop()
    end
end

function Novice:SetMovie()
    if self.MovieController.videoPlayer ~= nil then
        self.MovieController.videoPlayer.clip = self.MovieController.videoClips[0]
    end
end

function Novice:UpdateShowMessage()
    local step = Model.Player.GuideStep
    local version = Model.Player.GuideVersion
    local NoviceInfo = NoviceModel.GetNoviceGuideByConfId(step, version)
    if ABTest.GuideSkipButtonAB_Logic() == 7001 then
        self._noviceStartSkip.visible = false
    elseif ABTest.GuideSkipButtonAB_Logic() == 7002 then
        self._noviceStartSkip.visible = true
    end
    self:CreateMovieController()
    if NoviceInfo.type == _G.GD.GameEnum.NoviceType.Start then
        self.passImage = UIMgr:CreateObject("Effect", "EmptyNode")
        if self.passImage then
            self.passImage:SetIcon(UIPackage.GetItemURL("NoviceImage", "pass_0"))
            self.passImage:SetSize(GRoot.inst.width, GRoot.inst.height)
            self.passImage.sortingOrder = 999
            self.Controller.contentPane:AddChild(self.passImage)
        end
    elseif NoviceInfo.type == _G.GD.GameEnum.NoviceType.PlayMovie then
        NoviceModel.SetCanSkipNovice(false)
        self:SelectPage(5)
        if Model.Player.GuideStep == 10002 then ---行军动画 3秒
            self:SetMovie()
            self:PlayMovie()
            self.timeControllerFast = function()
                if self.passImage then
                    self.passImage:Dispose()
                    self.passImage = nil
                end
                self:PauseMovie()
                NoviceModel:NextStep()
            end
            self:ScheduleOnceFast(self.timeControllerFast, 4.8)
        elseif Model.Player.GuideStep == 10004 then --- 我方进军 3秒
            self:PlayMovie()
            self.timeControllerFast = function()
                self:PauseMovie()
                NoviceModel:NextStep()
            end
            self:ScheduleOnceFast(self.timeControllerFast, 4.7)
        elseif Model.Player.GuideStep == 10006 then --- 我方进军 3秒
            self:PlayMovie()
            self.timeControllerFast = function()
                self:PauseMovie()
                NoviceModel:NextStep()
            end
            self:ScheduleOnceFast(self.timeControllerFast, 1.5)
        elseif Model.Player.GuideStep == 10008 then --- 开打 8秒
            self:PlayMovie()
            self.timeControllerFast = function()
                self:PauseMovie()
                NoviceModel:NextStep()
            end
            self:ScheduleOnceFast(self.timeControllerFast, 8)
        elseif Model.Player.GuideStep == 10010 then --- 哥斯拉吐火 2秒
            self:PlayMovie()
            self.timeControllerFast = function()
                self:PauseMovie()
                NoviceModel:NextStep()
            end
            self:ScheduleOnceFast(self.timeControllerFast, 5)
        elseif Model.Player.GuideStep == 10011 then --退场
            self:PlayMovie()
            self.timeControllerFast = function()
                self:PauseMovie()
                self:RemoveMovieController()
                NoviceModel:NextStep()
            end
            self:ScheduleOnceFast(self.timeControllerFast, 3)
        elseif Model.Player.GuideStep == 10013 then
            Event.Broadcast(EventDefines.OpenPanelAndBuilding)
            TurnModel.BuildCenter(true, true)
            self.timeControllerFast = function()
                NoviceModel:NextStep()
            end
            self:ScheduleOnceFast(self.timeControllerFast, 1)
        end
    elseif NoviceInfo.type == _G.GD.GameEnum.NoviceType.Dialog then
        NoviceModel.SetCanSkipNovice(false)
        if NoviceInfo.spokesman ~= nil then
            self:SelectPage(0)
            if Model.Player.GuideStep == 10007 then
                JumpMap:JumpSimple(813700, self._startBtn)
                self:DialogSelectPage(1)
                self:DialogButtonSelectPage(1)
            else
                self:DialogSelectPage(0)
                self:DialogButtonSelectPage(0)
            end
            self._dialogBg.sortingOrder = 0
            self.character.sortingOrder = 1001
            if NoviceInfo.dubbing then
                AudioModel.PlaySpeech(string.lower(NoviceInfo.dubbing))
            end
            self:PlayDialogMoveAnim(NoviceInfo.spokesman, NoviceInfo.text, NoviceInfo.roleRes[1], NoviceInfo.roleRes[2])
            self.timeControllerFast = function()
                if Model.Player.GuideStep ~= 10007 then
                    NoviceModel.SetCanSkipNovice(true)
                end
            end
            self:ScheduleOnceFast(self.timeControllerFast, 0.5)
        else
            self:SelectPage(1)
            self._noviceStart.alpha = 0
            if ABTest.GuideSkipButtonAB_Logic() == 7001 then
                self._noviceStartSkip.visible = false
            end
            if Model.Player.GuideStep == 10001 then
                self:ItemSelectPage(0)
            elseif Model.Player.GuideStep == 10012 then
                self:ItemSelectPage(1)
            end
            local sTime = 3
            if NoviceInfo.dubbing then
                sTime = AudioModel.PlaySpeech(string.lower(NoviceInfo.dubbing))
            end
            self.skipFunc = function()
                NoviceModel.SetCanSkipNovice(false)
                self:GtweenOnComplete(
                    self._noviceStart:TweenFade(0, 0.2),
                    function()
                        NoviceModel:NextStep()
                    end
                )
            end
            local speakFun = function(allInterval)
                NoviceModel.SetCanSkipNovice(true)
                if ABTest.GuideSkipButtonAB_Logic() == 7001 then
                    self._noviceStartSkip.visible = true
                end
                local waitTime = math.abs(sTime - allInterval) + 1
                self.timeControllerFast = function()
                    if self.skipFunc then
                        self.skipFunc()
                        self.skipFunc = nil
                    end
                end
                self:ScheduleOnceFast(self.timeControllerFast, waitTime)
            end
            self:GtweenOnComplete(
                self._noviceStart:TweenFade(1, 0.2),
                function()
                    self._asideSpeak.text = StringUtil.GetI18n(I18nType.NoviceDialog, NoviceInfo.text)
                    _G.GameUtil.TypingEffectState(self._asideSpeak, 0.034, 1.5, speakFun)
                end
            )
        end
    elseif NoviceInfo.type == _G.GD.GameEnum.NoviceType.TaskTurn then
        NoviceModel.SetCanSkipNovice(false)
        self:SelectPage(5)
        if NoviceInfo.turnId ~= nil then
            local item = NoviceInfo.turnId
            if item.type == 1 then
                JumpMap:JumpTo({jump = item.jump, para = item.para})
                if Tool.Equal(item.jump, 810000, 810001, 810101) then --建筑引导
                    self.timeControllerFast = function()
                        NoviceModel.SetCanSkipNovice(true)
                    end
                    self:ScheduleOnceFast(self.timeControllerFast, 0.5)
                elseif item.jump == 810200 then --训练引导
                    self.timeControllerFast = function()
                        NoviceModel.SetCanSkipNovice(true)
                    end
                    self:ScheduleOnceFast(self.timeControllerFast, 2)
                end
            elseif item.type == 2 then
                TriggerGuide:StepTriggerGuide(item.jump, true)
            elseif item.type == 3 then
            end
        else
            if Model.Player.GuideStep == 10034 and (Model.Player.GuideVersion == 0 or Model.Player.GuideVersion == 1) then
                self.timeControllerFast = function()
                    NoviceModel.SetCanSkipNovice(true)
                end
                self:ScheduleOnceFast(self.timeControllerFast, 1)
            elseif Model.Player.GuideStep == 10047 and Model.Player.GuideVersion == 0 then
                self.timeControllerFast = function()
                    NoviceModel.SetCanSkipNovice(true)
                end
                self:ScheduleOnceFast(self.timeControllerFast, 0.5)
            elseif Model.Player.GuideStep == 10046 and Model.Player.GuideVersion == 3 then
                self.timeControllerFast = function()
                    NoviceModel.SetCanSkipNovice(true)
                end
                self:ScheduleOnceFast(self.timeControllerFast, 0.5)
            elseif Model.Player.GuideStep == 10054 and Model.Player.GuideVersion == 1 then
                self.timeControllerFast = function()
                    NoviceModel.SetCanSkipNovice(true)
                end
                self:ScheduleOnceFast(self.timeControllerFast, 0.5)
            end
        end
        if Model.Player.GuideVersion == 0 or Model.Player.GuideVersion == 1 then
            if Model.Player.GuideStep ~= 10042 then
                Event.Broadcast(EventDefines.NoviceBuildingGuideNextStep, true)
            end
        elseif Model.Player.GuideVersion == 2 then
            if Model.Player.GuideStep ~= 10035 then
                Event.Broadcast(EventDefines.NoviceBuildingGuideNextStep, true)
            end
        elseif Model.Player.GuideVersion == 3 then
            if Model.Player.GuideStep ~= 10034 and Model.Player.GuideStep ~= 10046 then
                Event.Broadcast(EventDefines.NoviceBuildingGuideNextStep, true)
            end
        else
            Event.Broadcast(EventDefines.NoviceBuildingGuideNextStep, true)
        end
    end
    lastType = NoviceInfo.type
end

--章节任务对话相关
function Novice:TaskPlotDialog(dialogInfo)
    self:DialogSelectPage(0)
    self:SelectPage(0)
    self:DialogButtonSelectPage(0)
    self._dialogBg.sortingOrder = 0
    self.character.sortingOrder = 1001
    self.dialogInfo = dialogInfo
    self:PlayDialogMoveAnim(dialogInfo.spokesMain, dialogInfo.dialogText, dialogInfo.roleRes[1], dialogInfo.roleRes[2])
    self.timeControllerFast = function()
        NoviceModel.SetCanSkipNovice(true)
    end
    self:ScheduleOnceFast(self.timeControllerFast, 0.5)
end

function Novice:NextTriggerStep()
    Event.Broadcast(EventDefines.TriggerGuideNextStep, triggerId, triggerStep)
end

return Novice
