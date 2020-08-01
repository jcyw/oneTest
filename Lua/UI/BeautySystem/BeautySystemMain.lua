--author: 	Amu
--time:		2020-03-11 15:24:57

local BeautyGirlModel = import("Model/BeautyGirlModel")

local BeautySystemMain = UIMgr:NewUI("BeautySystemMain")
local CheckValidModel = import("Model/Common/CheckValidModel")
local GuideControllerModel = import("Model/GuideControllerModel")
local TriggerGuideLogic = import("Model/TriggerGuideLogic")
local GlobalVars = GlobalVars
local UIType = _G.GD.GameEnum.UIType
BeautySystemMain.selectItem = nil

local PageCtrView = {} --界面控制
PageCtrView.Game = 0
PageCtrView.Skill = 1

local GameCtrView = {} --游戏状态控制
GameCtrView.Ready = 0
GameCtrView.Gameing = 1

local GameViewState = {}
GameViewState.Show = 0
GameViewState.Hide = 1

local LockClothState = {}
LockClothState.NoState = 0
LockClothState.Ready = 1
LockClothState.Locking = 2

function BeautySystemMain:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._btnReturn = self._view:GetChild("btnReturn")
    self._btnWardrobe = self._view:GetChild("btnWardrobe")

    self._timeBg = self._btnWardrobe:GetChild("timeBg")
    self._textTime = self._btnWardrobe:GetChild("titleTime")

    self._grilName = self._view:GetChild("textName")
    self._itemDown = self._view:GetChild("itemDown")
    self._groupTop = self._view:GetChild("groupTop")
    self._btnSkill = self._itemDown:GetChild("_btnRank")
    self._btnGame = self._itemDown:GetChild("_btnAchievementWall")
    self._btnData = self._itemDown:GetChild("_btnSkill")
    self._btnSet = self._itemDown:GetChild("_btnSet")
    self._gameView = self._view:GetChild("itemGame")
    self._btnView = self._view:GetChild("itemArrowBtn")
    self._itemCurtainView = self._view:GetChild("itemCurtainAnim")
    self._itemSkillLock = self._view:GetChild("itemSkillLock")
    self._itemCurtainView.visible = false
    self._listViewSkill = self._view:GetChild("liebiaoSkill")
    self._itemCloth = self._view:GetChild("itemReloading")

    self._redPoint = self._itemDown:GetChild("itemPointGreen")
    self._dateRedPoint = self._itemDown:GetChild("itemDatePointGreen")

    self._itemReloadingArrwo = self._view:GetChild("itemReloadingArrwo")
    self.clotheseffect = nil
    self._itemSkillLock.visible = false

    -- self._bgBeauty = self._view:GetChild("bgBeauty")
    self._girlNode = self._view:GetChild("girlGraph")
    self._girlGraph = self._girlNode:GetChild("girlGraph")
    self._lightGraph = self._girlNode:GetChild("lightGraph")

    self._btnGirl = self._girlNode:GetChild("touch")
    self._btnGirl.draggable = true
    self._btnGirl.sortingOrder = 10
    self._girlGraphW = self._girlGraph.width
    self._girlGraphH = self._girlGraph.height
    self._girlNodeY = self._girlNode.y

    self._clothesCtrView = self._view:GetController("c1")
    self._pageCtrView = self._view:GetController("c2")
    self._newClothView = self._view:GetController("c3")

    self._moveAnim = self._view:GetTransition("t0")

    self._btnWardrobe.visible = false
    self._loadProgress.visible = false
    self._btnView.visible = false

    self._lockClothState = LockClothState.NoState

    self.girlsInfo={}
    table.deepCopy(ConfigMgr.GetList("configGirls"),self.girlsInfo)

    -- if BeautyGirlModel.Shield then
    --     table.remove(self.girlsInfo[1].skill, 6)
    -- end
    for _, v in ipairs(self.girlsInfo) do
        for _, clothId in ipairs(v.clothid) do
            if not v.clothInfo then
                v.clothInfo = {}
            end
            v.clothInfo[clothId] = ConfigMgr.GetItem("configGirlclothings", clothId)
        end
    end

    self.modelUrl = "beauty/daria"
    self.modelName = "daria_p"
    self.lightModelName = "daria_light"
    self.modelRotationY = 180
    self.modelScale = 600

    self.spiniUrl = "beauty/dariaspine"
    -- self.spineName = "nvjizhe1_Anim"
    self.spineScale = 100
    self._girlSpine = {}
    self._initSpine = false

    local uibg = self._uibg:GetChild("_icon")
    UITool.GetIcon({"falcon", "bg_beauty_01"},uibg)
    self:InitEvent()
end

function BeautySystemMain:InitGirlModel()

    self._loadProgress.visible = true
    self._loadProgress:GetChild("title").visible = true
    self._loadProgress.max = 1
    self._loadProgress.value = 0

    if BeautyGirlModel.Shield then
        self:InitSpine()
    else
        self:InitModel()
    end
end

function BeautySystemMain:InitModel()
    local cb = function(prefab)
        if not self._girlModel then
            self.modelScale = 600 * self._view.height / GlobalVars.ScreenStandard.height
            local _girlModel = GameObject.Instantiate(prefab)
            _girlModel.transform.localScale = Vector3(self.modelScale, self.modelScale, self.modelScale)
            -- _girlModel.transform.localPosition = Vector3(self._girlGraphW/2, -self._girlGraphH, 400)
            _girlModel.transform.localPosition = Vector3(0, 50, 600)
            self._girlModel = _girlModel
            self._girlAnimator = _girlModel:GetComponent("Animator")
            self._girlGoWrapper = GoWrapper(_girlModel)
            self._girlGraph:SetNativeObject(self._girlGoWrapper)

            self._girlModelParts = {}

            local grilInfo = self.girlsInfo[self._selectGirlIndex]
            local allClothes = grilInfo.clothing_resource

            for _, name in ipairs(allClothes) do
                self._girlModelParts[name] = self._girlModel.transform:Find(name).gameObject
                self._girlModelParts[name]:SetActive(false)
            end
            self._girlModelParts["Daria_01_cloth"]:SetActive(true)
            self._girlModelParts["Daria_01_hair"]:SetActive(true)
            -- _girlModel.transform:Find("Daria_01_hair").gameObject:GetComponent("SkinnedMeshRenderer").material.renderQueue = 3001
            self._girlModelParts["Daria_01_hair"]:GetComponent("SkinnedMeshRenderer").material.renderQueue = 3001
            self._girlModelParts["Daria_hair"]:GetComponent("SkinnedMeshRenderer").material.renderQueue = 3001
        end
        self._girlAnimator:Play("kaichang")
        self._loadProgress.visible = false

        local grilInfo = self.girlsInfo[self._selectGirlIndex]
        if grilInfo and grilInfo.msg then
            self:ChangeChothes(grilInfo.msg.Costume)
        end
        self._girlGoWrapper.layer = 13
    end

    local progressCb = function(proNum)
        self._loadProgress.value = proNum
    end
    if self._girlModel then
        self._girlModel.transform.localEulerAngles = Vector3(0, 180, 0)
        self._loadProgress.visible = false
    else
        BeautyGirlModel.DynamicLoad(self.modelUrl, self.modelName, cb, progressCb)
    end

    if not self._lightModel then
        BeautyGirlModel.DynamicLoad(self.modelUrl, self.lightModelName, function(prefab)
            if not self._lightModel then
                local _lightModel = GameObject.Instantiate(prefab)
                _lightModel.transform.localPosition = Vector3(0, 50, 600)
                self._lightModel = _lightModel
                self._lightGoWrapper = GoWrapper(_lightModel)
                self._lightGraph:SetNativeObject(self._lightGoWrapper)
            end
        end)
    end

    self.__delyCB = function()
        self:DelayDispose()
    end
end

function BeautySystemMain:InitSpine()
    if not self._initSpine then
        self.spineScale = self.spineScale * self._view.height / GlobalVars.ScreenStandard.height
        self._initSpine = true
    end

    -- self:RefreshGirlSpine(self.spineName)
    local grilInfo = self.girlsInfo[self._selectGirlIndex]
    if grilInfo and grilInfo.msg then
        self:ChangeChothes(grilInfo.msg.Costume)
    end

    if not self._lightModel then
        BeautyGirlModel.DynamicLoad(self.modelUrl, self.lightModelName, function(prefab)
            if not self._lightModel then
                local _lightModel = GameObject.Instantiate(prefab)
                _lightModel.transform.localPosition = Vector3(0, 50, 600)
                self._lightModel = _lightModel
                self._lightGoWrapper = GoWrapper(_lightModel)
                self._lightGraph:SetNativeObject(self._lightGoWrapper)
            end
        end)
    end
end

function BeautySystemMain:RefreshGirlSpine(spineName)
    if not self._initSpine or spineName == self.spineName then
        self._loadProgress.visible = false
        return
    end
    if self._girlSpine[self.spineName] then
        self._girlSpine[self.spineName].transform.localPosition = Vector3(2000, 50, 600)
    end

    self.spineName = spineName
    local cb = function(prefab)
        if not self._girlSpine[spineName] then
            local _girlSpine = GameObject.Instantiate(prefab)
            _girlSpine.transform.localScale = Vector3(self.spineScale, self.spineScale, self.spineScale)
            -- _girlSpine.transform.localPosition = Vector3(0, 50, 600)
            self._girlSpineGoWrapper = GoWrapper(_girlSpine)
            self._girlGraph:SetNativeObject(self._girlSpineGoWrapper)
            self._girlSpine[spineName] = _girlSpine
        end
        if self.spineName == spineName then
            self._girlSpine[spineName].transform.localPosition = Vector3(0, 50, 600)
        else
            self._girlSpine[spineName].transform.localPosition = Vector3(2000, 50, 600)
        end
        self._loadProgress.visible = false

        local anim = self._girlSpine[spineName]:GetComponent("SkeletonAnimation")
        anim.state:SetAnimation(0, "idle", true)
    end

    local progressCb = function(proNum)
        self._loadProgress.value = proNum
    end
    if self._girlSpine[spineName] then
        self._girlSpine[spineName].transform.localPosition = Vector3(0, 50, 600)
        self._loadProgress.visible = false
    else
        BeautyGirlModel.DynamicLoad(self.spiniUrl, spineName, cb, progressCb)
    end
end

function BeautySystemMain:InitEvent()
    self:AddListener(self._btnReturn.onClick,
        function()
            --退出关闭弱引导

            if self._pageCtrView.selectedIndex == PageCtrView.Game then
                self:Close()
            else
                self:ChangePage(PageCtrView.Game)
            end
        end
    )

    self:AddListener(self._btnSkill.onClick,
        function()
            self:ChangePage(PageCtrView.Skill)
        end
    )

    self:AddListener(self._btnGame.onClick,
        function()
            self:ChangePage(PageCtrView.Game)
        end
    )

    self:AddListener(self._btnData.onClick,
        function()
            Net.Beauties.Date(
                self.girlsInfo[self._selectGirlIndex].id,
                function(msg)
                    self.canDate = false
                    self:RefreshDateRedPoint()
                    if not self.isShow then
                        return
                    end
                    self:ChangePage(PageCtrView.Game)
                    self._gameView:RefreshGameViewShow(GameViewState.Hide)
                    self._itemCurtainView.visible = true
                    self._btnWardrobe.visible = false
                    -- self._btnView.visible = false
                    self._mark.visible = true
                    self._itemDown.visible = false
                    self._groupTop.visible = false
                    self._gameView.visible = false

                    self._itemCurtainView:Play(
                        function()
                            self._itemCurtainView.visible = false
                            -- self._btnView.visible = true
                            self._mark.visible = false
                            self._itemDown.visible = true
                            self._groupTop.visible = true
                            self._gameView.visible = true
                            self:CheckClothesOpen()
                            self._gameView:RefreshGameViewShow(GameViewState.Show)
                            local rewards = {{Category = Global.RewardTypeItem, Amount = 1, ConfId = 200110}, {Category = Global.RewardTypeItem, Amount = 1, ConfId = 200111}}
                            UITool.ShowReward(rewards)
                            if TriggerGuideLogic.noviceID == 14102 then
                                TriggerGuideLogic:SetTriggerNextStep()
                            end
                        end
                    )
                    Event.Broadcast(EventDefines.BeautyDateFinish)
                end
            )
        end
    )

    self:AddListener(self._btnSet.onClick,
        function()
            TipUtil.TipById(50193)
        end
    )

    -- self._btnView:SetCallBack(function()
    --     if self._girlAnimator then
    --         self._girlAnimator:Play("dianji")
    --     end
    -- end)

    self:AddListener(self._btnGirl.onClick,
        function(context)
            if self._girlAnimator then
                local x = context.inputEvent.x
                local diff = 210 * (Screen.width / 750) * (self._view.height / GlobalVars.ScreenStandard.height)
                if x >= Screen.width * 0.5 - diff and x <= Screen.width * 0.5 + diff then
                    self._girlAnimator:Play("dianji")
                end
            end
        end
    )

    local _touchX = 0
    local _touchY = 0

    local _move = 0
    self.rotationOffset = 10

    self:AddListener(self._btnGirl.onTouchBegin,
        function(context)
            if not self._girlModel then
                return
            end
            _touchX = context.inputEvent.x
            self.curModelRY = self._girlModel.transform.localEulerAngles.y
        end
    )

    self:AddListener(self._btnGirl.onTouchMove,
        function(context)
            if not self._girlModel then
                return
            end
            local rY = self.curModelRY - (context.inputEvent.x - _touchX) / 2
            self._girlModel.transform.localEulerAngles = Vector3(0, rY, 0)
        end
    )

    self:AddListener(self._btnGirl.onTouchEnd,
        function(context)
            self._btnGirl.x = 0
            self._btnGirl.y = 0
        end
    )

    self:AddListener(self._btnWardrobe.onClick,
        function()
            local grilInfo = self.girlsInfo[self._selectGirlIndex]
            if self._btnWardrobe.selected then
                if not self.ChangeCostumeCoolAt or self.ChangeCostumeCoolAt <= Tool.Time() then
                    self._clothesCtrView.selectedIndex = 1
                    self._itemDown.visible = false
                    -- self._btnView.visible = false
                    self._itemCloth:RefreshClothes(grilInfo, self.ChangeCostumeCoolAt)
                else   -- 在进入换装界面前判断是否处于cd状态
                    local data = {
                        content = StringUtil.GetI18n("configI18nCommons", "Girl_Change_Cloth_Tips6"),
                        gold = 300,
                        sureCallback = function()
                            Net.Beauties.BuyChangeCostumeCool(function(msg)
                                Event.Broadcast(BEAUTY_GIRL_EVENT.RefreshChoiceTime, 0)
                            end)
                        end
                    }
                    UIMgr:Open("ConfirmPopupText", data)
                    self._btnWardrobe.selected = false
                end
            else
                -- self._btnView.visible = true
                self:ClothToMainStage()
            end
        end
    )

    self.LeftArrowCB = function()
        self._selectGirlIndex = self._selectGirlIndex - 1
        if self._selectGirlIndex < 1 then
            self._selectGirlIndex = #self.girlsInfo
        end
        self:RefreshGirl()
        self._gameView:StopGame()
        self:CheckIsUnLocakSkill()
    end

    self.RightArrowCB = function()
        self._selectGirlIndex = self._selectGirlIndex + 1
        if self._selectGirlIndex > #self.girlsInfo then
            self._selectGirlIndex = 1
        end
        self:RefreshGirl()
        self._gameView:StopGame()
        self:CheckIsUnLocakSkill()
    end

    self:AddListener(self._btnEditName.onClick,
        function()
            local grilInfo = self.girlsInfo[self._selectGirlIndex]
            UIMgr:Open("Rename", CheckValidModel.From.BeautyRename, self._grilName.text, grilInfo)
        end
    )

    self._listViewSkill.itemRenderer = function(index, item)
        if not index then
            return
        end
        local grilInfo = self.girlsInfo[self._selectGirlIndex]
        item:SetData(grilInfo.skill[index + 1], grilInfo.msg.Exp)
    end

    self:AddEvent(
        EventDefines.RefreshGirlName,
        function(girlName)
            self:RefreshGirl(girlName)
        end
    )

    self:AddEvent(BEAUTY_GIRL_EVENT.LeftArrow, self.LeftArrowCB)
    self:AddEvent(BEAUTY_GIRL_EVENT.RightArrow, self.RightArrowCB)

    self:AddEvent(
        BEAUTY_GIRL_EVENT.FavorAdd,
        function(msg)
            if self.isShow then
                for _, v in ipairs(self.girlsInfo) do
                    if v.id == msg.Id then
                        v.msg = msg
                        break
                    end
                end
                self:CheckClothesOpen()
                self:RefreshDateRedPoint()
                self._gameView:RefreshView(self._selectGirlIndex, self.girlsInfo, self._state, self._Rose)
            end
        end
    )

    self:AddEvent(
        BEAUTY_GIRL_EVENT.FlowerReduce,
        function(rose)
            self._Rose = rose
            if self._Rose > 0 then
                self._redPoint:SetData(true, self._Rose)
            else
                self._redPoint:SetData(false)
            end
        end
    )

    self:AddEvent(
        BEAUTY_GIRL_EVENT.FlowerAdd,
        function(num)
            self._Rose = self._Rose + num
            if self._Rose > 0 then
                self._redPoint:SetData(true, self._Rose)
            else
                self._redPoint:SetData(false)
            end
        end
    )

    self:AddEvent(
        BEAUTY_GIRL_EVENT.UnlockSkill,
        function(msg)
            -- local grilInfo = self.girlsInfo[self._selectGirlIndex]
            -- if msg.Beauty == grilInfo.id then
            --     self._itemSkillLock.visible = true
            --     self._itemSkillLock:PlayUnLockAnime(msg.Skill, function()
            --         self._itemSkillLock.visible = false
            --     end)
            -- end
            if not self.isShow then
                return
            end

            -- local grilInfo = self.girlsInfo[self._selectGirlIndex]
            -- local skillInfo = BeautyGirlModel.GetUnlockSkill(grilInfo.id)
            -- if skillInfo then
            --     self._itemSkillLock.visible = true
            --     self._itemSkillLock:PlayUnLockAnime(skillInfo.Skill, function()
            --         self._itemSkillLock.visible = false
            --     end)
            -- end
            self:CheckIsUnLocakSkill()
        end
    )

    self:AddEvent(
        EventDefines.GirlDisappearEvent,
        function(value)
            self._girlGraph.visible = value
            if value then
                if self._girlAnimator then
                    self._girlAnimator:Play("lanyao")
                end
            end
        end
    )

    self:AddEvent(
        BEAUTY_GIRL_EVENT.UnlockCostume,
        function(msg)
            -- Beauty:10002
            -- Costume:1006
            -- self._newClothView.selectedIndex = 1
            -- self._gameView.visible = false
            -- self._btnWardrobe.visible = false
            -- -- self._btnView.visible = false
            -- self._itemReloadingArrwo:Show(function()
            --     self._newClothView.selectedIndex = 0
            --     self._gameView.visible = true
            --     self:CheckClothesOpen()
            --     -- self._btnView.visible = true
            -- end,
            -- function()
            --     self:PlayeClothesEffect()
            --     local grilInfo = self.girlsInfo[self._selectGirlIndex]
            --     grilInfo.msg.Costume = msg.Costume
            --     self:ChangeChothes(msg.Costume)
            -- end, self._moveAnim)
            self:CheckIsUnLocakSkill()
        end
    )

    self:AddEvent(
        BEAUTY_GIRL_EVENT.ChangeChothes,
        function(clothid)
            local grilInfo = self.girlsInfo[self._selectGirlIndex]
            grilInfo.msg.Costume = clothid
            self:ChangeChothes(clothid)
            self:ClothToMainStage()
        end
    )

    self:AddEvent(
        BEAUTY_GIRL_EVENT.ChoiceChothes,
        function(clothid)
            self:ChangeChothes(clothid)
        end
    )

    self._refreshChangeCostumeCoolAt = function()
        if self.ChangeCostumeCoolAt > Tool.Time() then
            local time = self.ChangeCostumeCoolAt - Tool.Time()
            self._textTime.text = TimeUtil.SecondToHMS(time)
        else
            self._timeBg.visible = false
            self._textTime.visible = false
            self._scheduler = false
            self:UnSchedule(self._refreshChangeCostumeCoolAt)
        end
    end

    self:AddEvent(
        BEAUTY_GIRL_EVENT.RefreshChoiceTime,
        function(ChangeCostumeCoolAt)
            self.ChangeCostumeCoolAt = ChangeCostumeCoolAt

            if self.ChangeCostumeCoolAt > Tool.Time() then
                if not self._scheduler then
                    self._scheduler = true
                    self._timeBg.visible = true
                    self._textTime.visible = true
                    self:Schedule(self._refreshChangeCostumeCoolAt, 1)
                end
            else
                self._timeBg.visible = false
                self._textTime.visible = false
                self._scheduler = false
                self:UnSchedule(self._refreshChangeCostumeCoolAt)
            end
        end
    )

    self:AddEvent(
        BEAUTY_GIRL_EVENT.GameOver,
        function()
            self:CheckIsUnLocakSkill()
            self:CheckBtnGuide()
        end
    )

    self:AddEvent(
        BEAUTY_GIRL_EVENT.GameTableIn,
        function()
            self:InitGirlModel()
        end
    )
end

function BeautySystemMain:ClothToMainStage()
    local grilInfo = self.girlsInfo[self._selectGirlIndex]
    self:ChangeChothes(grilInfo.msg.Costume)
    self._clothesCtrView.selectedIndex = 0
    self._itemDown.visible = true
    self._btnWardrobe.selected = false
end

function BeautySystemMain:OnOpen(shopInfo)
    self:UnSchedule(self.__delyCB)
    self.canDate = true
    self.curPage = nil
    self.modelRotationY = 180
    if self._girlModel then
        self._girlModel.transform.localEulerAngles = Vector3(0, self.modelRotationY, 0)
    end

    self.isShow = true
    self._mark.visible = false
    self._state = GameViewState.Show
    BeautyGirlModel.gameState = GameCtrView.Ready
    self._clothesCtrView.selectedIndex = 0
    self._btnWardrobe.selected = false
    self._selectGirlIndex = 1
    self._shakeState = false
    BeautyGirlModel._canClick = false
    self._itemDown.visible = true
    self._groupTop.visible = true
    self._gameView.visible = true
    self._girlGraph.visible = true
    self._newClothView.selectedIndex = 0

    -- if self._lockClothState == LockClothState.Ready then
    --     self._gameView.visible = false
    --     self._newClothView.selectedIndex = 1
    -- else
    --     self._gameView.visible = true
    --     self._newClothView.selectedIndex = 0
    -- end

    self._itemCurtainView.visible = false

    self._girlNode.y = self._girlNodeY
    if self._girlAnimator then
        self._girlAnimator:Play("kaichang")
    end

    Net.Beauties.GetBeautiesInfo(
        function(msg)

            self._Rose = msg.Rose
            self.isGaming = msg.BeautyInGame > 0 and true or false
            self.Except = msg.GameExcept
            self.ChangeCostumeCoolAt = msg.ChangeCostumeCoolAt

            if self.ChangeCostumeCoolAt > Tool.Time() then
                if not self._scheduler then
                    self._scheduler = true
                    self._timeBg.visible = true
                    self._textTime.visible = true
                    self:Schedule(self._refreshChangeCostumeCoolAt, 1)
                end
            else
                self._timeBg.visible = false
                self._textTime.visible = false
                self._scheduler = false
                self:UnSchedule(self._refreshChangeCostumeCoolAt)
            end

            if self._Rose > 0 then
                self._redPoint:SetData(true, self._Rose)
            else
                self._redPoint:SetData(false)
            end


            for _, v in ipairs(self.girlsInfo) do
                for _, info in ipairs(msg.Infos) do
                    if v.id == info.Id then
                        v.msg = info
                        break
                    end
                end
            end

            self:CheckBtnGuide()
            local grilInfo = self.girlsInfo[self._selectGirlIndex]
            self:RefreshDateRedPoint()
            self:CheckClothesOpen()
            local unlockClostInfo = BeautyGirlModel.IsHavaUnlockCostume(grilInfo.id)
            if unlockClostInfo and #unlockClostInfo > 0 then
                grilInfo.msg.Costume = grilInfo.msg.Costume - 1
                self:ChangeChothes(grilInfo.msg.Costume)
            else
                self:ChangeChothes(grilInfo.msg.Costume)
            end
            -- self:RefreshGameView()
            if self.isGaming then
                BeautyGirlModel._canClick = true
                BeautyGirlModel.gameState = GameCtrView.Gameing
            end
            self:RefreshGirl()
            self._gameView:RefreshView(self._selectGirlIndex, self.girlsInfo, self._state, self._Rose)
            Event.Broadcast(BEAUTY_GIRL_EVENT.Open)
            self:CheckIsUnLocakSkill()
            Event.Broadcast(EventDefines.BeautyDateFinish)
        end
    )
    self._gameView:RefreshGameViewShow(self._state)
    -- self:RefreshGameViewShow()
    self:ChangePage(PageCtrView.Game)
end

function BeautySystemMain:CheckBtnGuide()
    if not self.girlsInfo then
        return
    end
    local firstGirl = self.girlsInfo[1]
    if firstGirl then
        local msg = firstGirl.msg
        if msg.Exp < 30 then
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BeautySystemMainUI)
        end
    end
end

function BeautySystemMain:ChangePage(type)
    if type == self.curPage then
        if type == PageCtrView.Game then
            self._gameView:StopGame()
            self._gameView:ChangeBoardState()
        end
        return
    end

    if type == PageCtrView.Skill then
        self:RefreshSkillListView()
    elseif type == PageCtrView.Game then
    -- self._gameCtrView.selectedIndex = BeautyGirlModel.gameState
    end

    -- if self._gameCtrView.selectedIndex ~= GameCtrView.Ready then

    -- end
    self._gameView:StopGame()
    self._pageCtrView.selectedIndex = type
    self.curPage = type
end

function BeautySystemMain:CheckClothesOpen()
    for _, v in ipairs(self.girlsInfo) do
        if v.id == 10001 and v.msg.Exp >= 290 then
            -- if BeautyGirlModel.Shield then
            --     self._btnWardrobe.visible = false
            -- else
                self._btnWardrobe.visible = true
            -- end
            break
        end
    end
end

function BeautySystemMain:RefreshGirl(girlName)
    local grilInfo = self.girlsInfo[self._selectGirlIndex]
    -- Log.Error("grilInfo.msg.Name==={0}", girlName)
    if girlName then
        self._grilName.text = girlName
        grilInfo.msg.Name = girlName
    else
        self._grilName.text = grilInfo.msg.Name == "" and StringUtil.GetI18n("configI18nCommons", grilInfo.name) or grilInfo.msg.Name
    end

    self._gameView:RefreshView(self._selectGirlIndex, self.girlsInfo, self._state, self._Rose)
    -- self:RefreshFlower()
    -- self:RefreshFavorable()
end

function BeautySystemMain:RefreshSkillListView()
    self._listViewSkill.numItems = #self.girlsInfo[self._selectGirlIndex].skill
end

function BeautySystemMain:CheckIsUnLocakSkill(_skillInfo)
    if not self.isShow then
        return
    end
    if self._playSkillUnlock then
        return
    end
    if BeautyGirlModel.gameState == GameCtrView.Gameing then
        return
    end
    local grilInfo = self.girlsInfo[self._selectGirlIndex]
    -- local skillInfo = _skillInfo or BeautyGirlModel.GetUnlockSkill(grilInfo.id)

    self._mark.visible = true

    self.unLockCostume = BeautyGirlModel.UnlockCostume(grilInfo.id)

    if self.unLockCostume then
        self._mark.visible = false
        self._itemSkillLock.visible = false
        self._newClothView.selectedIndex = 1
        self._gameView.visible = false
        self._btnWardrobe.visible = false
        -- self._btnView.visible = false
        self._lockClothState = LockClothState.Ready
        self._itemReloadingArrwo:Show(function()
            self._newClothView.selectedIndex = 0
            self._gameView.visible = true
            self:CheckClothesOpen()
            -- if skillInfo then
            --     self._playSkillUnlock = true
            --     self._itemSkillLock.visible = true
            --     self._itemSkillLock:PlayUnLockAnime(skillInfo.Skill, function()
            --         self._playSkillUnlock = false
            --         self:CheckIsUnLocakSkill()
            --         Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.OpenUI, 14100, 0)
            --     end)
            -- end
            self:CheckIsUnLocakSkill()
            -- self._btnView.visible = true
            self._girlNode.y = self._girlNodeY
        end, 
        function(unLockCostume)
            self._lockClothState = LockClothState.Locking
            self:PlayeClothesEffect()
            local grilInfo = self.girlsInfo[self._selectGirlIndex]
            grilInfo.msg.Costume = unLockCostume.Costume
            self:ChangeChothes(unLockCostume.Costume)
        end, self._moveAnim, self.unLockCostume)
        return
    end

    local skillInfo = BeautyGirlModel.GetUnlockSkill(grilInfo.id)
    if skillInfo then
        self._playSkillUnlock = true
        self._itemSkillLock.visible = true
        self._itemSkillLock:PlayUnLockAnime(
            skillInfo.Skill,
            function()
                self._playSkillUnlock = false
                self:CheckIsUnLocakSkill()
                Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.OpenUI, 14100, 0)
                if skillInfo.Skill == 10005 then -- 解鎖美女衣櫃
                    Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.OpenUI, 14400, 0)
                end
            end
        )
    else
        self._mark.visible = false
        self._itemSkillLock.visible = false
    end
end

function BeautySystemMain:ChangeChothes(clothId)
    if BeautyGirlModel.Shield then
        local clothInfo = self.girlsInfo[self._selectGirlIndex].clothInfo[clothId]
        if clothInfo then
            self:RefreshGirlSpine(clothInfo.sipneUrl)
        end
    else
        if not self._girlModel then
            return
        end
        local grilInfo = self.girlsInfo[self._selectGirlIndex]
        local allClothes = grilInfo.clothing_resource
        local showClothes = grilInfo.clothInfo[clothId].clothing_resource
    
        for _, name in ipairs(allClothes) do
            local show = false
            for _, showName in ipairs(showClothes) do
                if name == showName then
                    show = true
                    break
                end
            end
            -- self._girlModel.transform:Find(name).gameObject:SetActive(show)
            self._girlModelParts[name]:SetActive(show)
        end
    end
end

function BeautySystemMain:PlayeClothesEffect()
    NodePool.Init(NodePool.KeyType.BeautyGirl_ClothesEffect, "Effect", "EffectNode")
    local item = NodePool.Get(NodePool.KeyType.BeautyGirl_ClothesEffect)
    self.clotheseffect1 = item
    item.y = self._uibg.height / 2
    item.x = self._uibg.width / 2
    self._girlNode:AddChild(item)
    item:InitNormal()
    item:PlayEffectLoop("effects/beauty/prefab/effect_clothes_hua", Vector3(50, 50, 50))

    self:ScheduleOnce(function()
        if self.clotheseffect1 then
            self.clotheseffect1:RemoveFromParent()
            NodePool.Set(NodePool.KeyType.BeautyGirl_ClothesEffect, self.clotheseffect1)
            self.clotheseffect1 = nil
        end
    end,4)

    NodePool.Init(NodePool.KeyType.BeautyGirl_ClothesEffect, "Effect", "EffectNode")
    local item = NodePool.Get(NodePool.KeyType.BeautyGirl_ClothesEffect)
    self.clotheseffect2 = item
    item.y = -50
    item.x = self._uibg.width / 2
    self._girlNode:AddChild(item)
    item:InitNormal()
    item:PlayEffectLoop("effects/beauty/prefab/effect_clothes_hua", Vector3(50, 50, 50))

    self:ScheduleOnce(function()
        if self.clotheseffect2 then
            self.clotheseffect2:RemoveFromParent()
            NodePool.Set(NodePool.KeyType.BeautyGirl_ClothesEffect, self.clotheseffect2)
            self.clotheseffect2 = nil
        end
    end,4)
end

--[[
    由于按下约会按钮不会更新美女的candate数值,所以用self.candate来表示是否在此次进入窗口
    后按了约会按钮,如果self.candate为true则从美女的candate参数来判断是否能约会。
    为false表示此次按过了约会按钮,无法进行约会
]]--
function BeautySystemMain:RefreshDateRedPoint()
    local canDate
    if self.canDate then  
        canDate = self.girlsInfo[self._selectGirlIndex].msg.CanDate
    else
        canDate = false
    end
    self._dateRedPoint:SetData(canDate)
    if canDate then
        -- 如果已经走过14100引导了,就直接显示约会按钮的提示
        for j = 1, #Model.Player.TriggerGuides do
            if 14100 == Model.Player.TriggerGuides[j].Id then
                Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BeautyDateUI)
                break
            end
        end 
    end
end

function BeautySystemMain:Close()
    UIMgr:Close("BeautySystemMain")
end

function BeautySystemMain:OnClose()
    local grilInfo = self.girlsInfo[self._selectGirlIndex]
    Event.Broadcast(BEAUTY_GIRL_EVENT.Close)
    self._gameView:StopGame()
    self._gameView:HideGirlIntroduce()

    if self._lockClothState == LockClothState.Ready then
        Event.Broadcast(BEAUTY_GIRL_EVENT.UnlockCostume, self.unLockCostume)
        BeautyGirlModel.AddUnlockCostume(self.unLockCostume.Beauty, self.unLockCostume)
    elseif self._lockClothState == LockClothState.Locking then
        self._moveAnim:Stop()

        if self.clotheseffect1 then
            self.clotheseffect1:RemoveFromParent()
            NodePool.Set(NodePool.KeyType.BeautyGirl_ClothesEffect, self.clotheseffect1)
            self.clotheseffect1 = nil
        end
        if self.clotheseffect2 then
            self.clotheseffect2:RemoveFromParent()
            NodePool.Set(NodePool.KeyType.BeautyGirl_ClothesEffect, self.clotheseffect2)
            self.clotheseffect2 = nil
        end
    end

    if Tool.Equal(TriggerGuideLogic.noviceID, 14102, 14103, 14402) then
        TriggerGuideLogic:ClearTriggerGuide()
    end
      if GuideControllerModel.isBeginGuide then
        Event.Broadcast(EventDefines.CloseGuide)
    end
    self.isShow = false

    if self.__delyCB then
        self:ScheduleOnce(self.__delyCB, 2)
    end
end

function BeautySystemMain:DelayDispose()
    if self._girlGoWrapper then
        self._girlGoWrapper:Dispose()
    end
    if self._lightGoWrapper then
        self._lightGoWrapper:Dispose()
    end

    if ResMgr.Instance.UnLoadCacheBundles then
        UIMgr.AddDelayDisposeBundle(self.modelUrl)
    end
    
    self._girlModel = nil
    self._lightModel = nil
    self._girlAnimator = nil
end

return BeautySystemMain
