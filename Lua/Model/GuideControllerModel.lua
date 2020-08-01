--[[    author:{maxiaolong}
    time:2019-11-07 11:41:54
    function:{弱引导}
]]
if GuideControllerModel then
    return GuideControllerModel
end
local GuideControllerModel = {}
local UIType = _G.GD.GameEnum.UIType
local Guide = import("UI/Common/Guide")
local BuildModel = import("Model/BuildModel")
local MapModel = import("Model/MapModel")
local JumpModel = import("Model/JumpMapModel")
local WorldMap = import("UI/WorldMap/WorldMap")
local NoviceModel = import("Model/NoviceModel")
local WelfareModel = import("Model/WelfareModel")
local BuildDelayTime = 1.2
local onClickCount = 0 --材料工厂弱引导点击计数
--新手引导跳过步骤
GuideControllerModel.parentPanels = {}
local isNewGuideStep = false
local cutJumpBuildId = 0
local isEndMove = true
local isInit = false
local GlobalVars = GlobalVars

function GuideControllerModel:Init()
    if isInit == true then
        return
    end
    isInit = true
    self.ValParams = {}
    local guide = UIMgr:CreatePopup("Common", "Guide")
    --设置引导居中
    guide:SetPivot(0.5, 0.5)
    guide:ResetTrans()
    self.isBeginGuide = false
    Event.AddListener(
        EventDefines.JumpTipEvent,
        function(buinding, time, type, params, bId)
            self:AddEventJumpTip(buinding, time, type, params, bId)
        end
    )
    Event.AddListener(
        EventDefines.NoviceBuildingGuideNextStep,
        function(isStep)
            isNewGuideStep = isStep
            if self.isBeginGuide and isNewGuideStep then
                self:SetGuideAuto()
            end
        end
    )
    Event.AddListener(
        EventDefines.CloseGuide,
        function(isWorldMap)
            if isWorldMap then
                if self.isBeginGuide then
                    self:SetCloseGuide()
                end
            else
                self:SetCloseGuide()
            end
        end
    )
    Event.AddListener(
        EventDefines.CloseBtnFreeGuide,
        function()
            if self.isBtnFreeCompleteUI then
                self:SetCloseGuide()
            end
        end
    )
    Event.AddListener(
        EventDefines.MoveMapEvent,
        function(isEnd) --是否移动完成
            if isEndMove and not isEnd then
                isEndMove = isEnd
            elseif not isEndMove and isEnd then
                isEndMove = isEnd
            end
        end
    )
    --添加节点
    Event.AddListener(
        EventDefines.AddParentNode,
        function(node, type) --是否移动完成
            self:SetParentUI(node, type)
        end
    )
    self:InitAction()
end

function GuideControllerModel.GetGudiePanel()
    local guide = UIMgr:GetPopupUIByKey("Common", "Guide")
    if not guide then
        guide = UIMgr:CreatePopup("Common", "Guide")
        GRoot.inst:AddChild(guide)
        guide:SetTrans(-4000, -4000)
    end
    return guide
end

function GuideControllerModel:AddEventJumpTip(building, time, type, params, bId)
    if building then
        self.Info = building
        if self:SetCutJumBid(building.ConfId) then
            --只打开UI
            self:OpenGuide(time, type, building.Id)
        end
    else
        if type and params then
            self.Info = params
            if bId then
                self:SetCutJumBid(bId)
            end
        end
        self:OpenGuide(time, type, bId)
    end
end

function GuideControllerModel:OpenGuide(time, type, bId)
    local node = self.parentPanels[type]
    if time then
        self:SetChild(node, time, type, bId)
    end
end

function GuideControllerModel:GetPanelByType(type)
    return self.parentPanels[type]
end

--@desc:这里是添加弱引导条件，指向不同类型的UI可以在这添加条件
function GuideControllerModel:SetChild(parentNode, time, type, bId)
    self.guidePanel = self.GetGudiePanel()
    if (not self.guidePanel) then
        return
    end
    local delayTime = time
    self.guidePanel.sortingOrder = 99
    self.uiType = type
    self.guidePanel:SetTopAnim(false)
    self.guidePanel:SetGuideScale(1)
    self.guidePanel:SetArrowSize(1)
    local tableFunc = {
        [UIType.CityCompleteUI] = function()
            --指向建筑展开的功能菜单类型
            self.isBeginGuide = true
            Scheduler.ScheduleOnceFast(
                function()
                    self.guidePanel:SetShow(false)
                end,
                BuildDelayTime - 0.4
            )
            self.cityCompleteNode = parentNode
            local buildParent = BuildModel.GetObject(bId)
            CityMapModel.GetCityMap():AddChild(self.guidePanel)
            local posX = buildParent.x - (self.guidePanel.width / 2)
            local posY = buildParent.y - (self.guidePanel.height / 2)
            local buildId = JumpModel:GetBuildId()
            local isInnerCity = BuildModel.IsInnerOrBeast(buildId)
            local disNum = isInnerCity and 100 or 50
            if buildId == Global.BuildingCenter then
                posX = posX + 200
                posY = posY - 200
            end

            self.guidePanel:SetTrans(posX, posY - disNum)
            Event.Broadcast(
                EventDefines.GuideCompGuideFunc,
                function()
                    parentNode:AddChild(self.guidePanel)
                    self.jumpType = JumpModel:GetJumpType()
                    local str = nil
                    --这里添加功能菜单的名字，在表里可以找到
                    local strTable = {
                        [_G.GD.GameEnum.JumpType.Upgrade] = "Upgrade", --升级
                        [_G.GD.GameEnum.JumpType.Train] = {
                            [Global.BuildingTankFactory] = "TrainTank", --坦克
                            [Global.BuildingWarFactory] = "TrainChariot", --战车
                            [Global.BuildingHelicopterFactory] = "TrainHelicopter", --直升机
                            [Global.BuildingVehicleFactory] = "TrainVehicle", --重载载具
                            [Global.BuildingSecurityFactory] = "Produce" --安保中心
                        }, --训练
                        [_G.GD.GameEnum.JumpType.Cure] = "Cure", --士兵治疗
                        [_G.GD.GameEnum.JumpType.BeastCure] = "BeastCure", --巨兽治疗
                        [_G.GD.GameEnum.JumpType.Speed] = "Speed", --加速
                        [_G.GD.GameEnum.JumpType.Tech] = "Research", --研究
                        [_G.GD.GameEnum.JumpType.BeastResearch] = "BeastResearch", --巨兽研究
                        [_G.GD.GameEnum.JumpType.Promote] = "Boost", --提速
                        [_G.GD.GameEnum.JumpType.Supply] = "Supply", --补给
                        [_G.GD.GameEnum.JumpType.Make] = "Produce", --制造
                        [_G.GD.GameEnum.JumpType.Drats] = "RangeTurntable", --飞镖赌场
                        [_G.GD.GameEnum.JumpType.Girls] = "BeautySystemMain", --美女
                        [_G.GD.GameEnum.JumpType.Forge] = "Forge" --装备制造
                    }
                    if strTable[self.jumpType][buildId] and self.jumpType == _G.GD.GameEnum.JumpType.Train then
                        str = strTable[self.jumpType][buildId]
                    elseif strTable[self.jumpType] then
                        str = strTable[self.jumpType]
                    end
                    local btn, btnName = parentNode:GetFuncItem(str)
                    if btn == nil then
                        Log.Info("CompleteType Btn is Nil")
                        return
                    end
                    self.cutCompleteName = btnName
                    local y = btn.y - self.guidePanel.height / 2 + btn.height / 2
                    local x = btn.x - self.guidePanel.width / 2 + btn.width / 2
                    self.guidePanel:SetTrans(x, y)
                    self.guidePanel:SetShow(true)
                end
            )
        end,
        [UIType.CityMapUI] = function()
            --指引城市建造
            self.isBeginGuide = true
            local nodeBtn, isEnterCity = CityMapModel:GetCutBtn()
            self.cutSpeace = nodeBtn
            self.piecePosNum = nodeBtn:GetPiecePos()
            CityMapModel.GetCityMap():AddChild(self.guidePanel)

            local posX = nodeBtn.x - (self.guidePanel.width / 2)
            local posY = nodeBtn.y - (self.guidePanel.height / 2)
            local disNum = isEnterCity and 95 or 85
            if JumpModel:GetBuildId() == Global.BuildingCenter then
                posX = posX - 200
                posY = posY - 200
            end
            self.guidePanel:SetTopAnim(false)
            self.guidePanel:SetGuideScale(0.8)
            self.guidePanel:SetTrans(posX, posY - disNum)
        end,
        [UIType.BuildUpgradeUI] = function()
            --指引建筑升级
            self.guidePanel:SetTopAnim(true)
            self.guidePanel:SetGuideScale(0.8)
            self:GetPanelGuide(parentNode)
        end,
        [UIType.BuildCreateUI] = function()
            --指引建筑创建
            self.guidePanel:SetTopAnim(true)
            self.guidePanel:SetGuideScale(0.8)
            self:GetPanelGuide(parentNode)
        end,
        [UIType.BuildTrainUI] = function()
            --指引训练
            self.isBeginGuide = true
            self.guidePanel:SetTopAnim(true)
            self.guidePanel:SetGuideScale(0.8)
            self:GetPanelGuide(parentNode)
        end,
        [UIType.BuildAccelerateUI] = function()
            --指引建筑加速
            self.guidePanel:SetGuideScale(0.8)
            self:GetPanelGuide(parentNode)
        end,
        [UIType.LockUI] = function()
            --指引解锁地块
            self.isBeginGuide = true
            local lockNode = CityMapModel.GetLockBtn(self.Info)
            lockNode:AddChild(self.guidePanel)
            self.guidePanel:SetTrans(lockNode.width / 2 - self.guidePanel.width / 2, lockNode.height / 2 - self.guidePanel.height / 2)
        end,
        [UIType.LaboratoryUI] = function()
            --指引研究科技
            local studyId = JumpModel:GetTech()
            self:GetPanelGuide(parentNode, studyId)
        end,
        [UIType.LaboratorySkillUI] = function()
            --指引研究科技技能
            local skillUI = UIMgr:GetUI("LaboratorySkill")
            local techId = JumpModel:GetTech()
            local item = skillUI:GetSkillItemByConfid(techId)
            item:AddChild(self.guidePanel)
            self.guidePanel:SetTrans(-30, -30)
        end,
        [UIType.WorldMapPoint] = function()
            --世界地图指引
            self.isBeginGuide = true
            local info = self.Info
            local screenX, screenY = info.ScreenPos.x, info.ScreenPos.y
            parentNode:AddChild(self.guidePanel)
            self.guidePanel:SetTrans(screenX - 125, screenY - 125)
        end,
        [UIType.WorldMapUI] = function()
            --世界地图UI
            self.isBeginGuide = true
            Scheduler.ScheduleOnceFast(
                function()
                    Event.Broadcast(EventDefines.DelayMask, false)
                end,
                0.6
            )
        end,
        [UIType.WildMonsterUI] = function()
            --指引攻击野怪
            Event.Broadcast(EventDefines.DelayMask, false)
            self.isBeginGuide = true
            self:GetPanelGuide(parentNode)
        end,
        [UIType.ItemDetailUI] = function()
            --野怪展开功能详情
            self.isBeginGuide = true
            Scheduler.ScheduleOnceFast(
                function()
                    Event.Broadcast(EventDefines.DelayMask, false)
                    local btn = parentNode:GuildShow()
                    self.itemDetail = btn
                    if not btn then
                        self:SetCloseGuide()
                        return
                    end
                    btn:AddChild(self.guidePanel)
                    self.guidePanel:SetTrans(-self.guidePanel.width / 2 + btn.width / 2, -self.guidePanel.height / 2 + btn.height / 2)
                end,
                0.5
            )
        end,
        [UIType.UnionBtnUI] = function()
            --指引主界面联盟按钮
            self.isBeginGuide = true
            self.unionBtn = parentNode:GuildShow()
            local mainUI = UIMgr:GetUI("MainUIPanel")
            mainUI._view:AddChild(self.guidePanel)
            self.guidePanel.visible = true
            self.guidePanel:SetTopAnim(true)
            self.guidePanel:SetGuideScale(0.8)
            self.guidePanel.xy = Vector2(mainUI.down.x + self.unionBtn.x - 120, mainUI.down.y + self.unionBtn.y - 110)
            self.unionItemName = bId
        end,
        [UIType.UnionUI] = function()
            --指引联盟界面
            local unionMain = UIMgr:GetUI("UnionMain/UnionMain")
            local jumpId = JumpModel:GetJumpId()
            local posx, posy = nil
            local unionItem = parentNode:GetUnionItem(self.unionItemName)
            local listItem = unionItem
            unionMain._unionList.scrollPane:SetPosY(listItem.y)
            local listMoveDis = (unionMain._unionList.scrollPane.posY)
            local disItemY = listItem.y - listMoveDis
            Scheduler.ScheduleOnceFast(
                function()
                    unionItem = parentNode:GetUnionItem(self.unionItemName)
                    unionMain._view:AddChild(self.guidePanel)
                    self.guidePanel:SetShow(false)
                    -- 容错处理
                    Scheduler.ScheduleOnceFast(
                        function()
                            self.guidePanel:SetShow(true)
                            if Tool.Equal(jumpId, 811903, 811900) then
                                posx = unionMain._unionList.x - self.guidePanel.width / 2 + unionItem.width / 2 + unionItem.x
                                posy = unionMain._unionList.y - self.guidePanel.height / 2 + unionItem.height / 2 + disItemY
                            elseif Tool.Equal(jumpId, 811901, 811902) then
                                posx = -self.guidePanel.width / 2 + unionItem.width / 2 + unionItem.x
                                posy = -self.guidePanel.height / 2 + unionItem.height / 2 + unionItem.y
                            end
                            self.guidePanel:SetGuideScale(0.8)
                            self.guidePanel:SetTrans(posx, posy)
                        end,
                        0.1
                    )
                end,
                0.1
            )
        end,
        [UIType.UnionAidUI] = function()
            --指引联盟盟主详情
            local btn = parentNode:GuildShow(self.unionItemName)
            local detail = UIMgr:GetUI("UnionMember/UnionMemberDetail")
            detail._view:AddChild(self.guidePanel)
            local posx, posy = -self.guidePanel.width / 2 + btn.width / 2 + btn.x, -self.guidePanel.height / 2 + btn.height / 2 + btn.y
            self.guidePanel:SetTrans(posx, posy)
        end,
        [UIType.CureArmyUI] = function()
            --指引治疗军队
            self.guidePanel:SetTopAnim(true)
            self.guidePanel:SetGuideScale(0.8)
            self:GetPanelGuide(parentNode)
        end,
        [UIType.CureMonsterUI] = function()
            --指引治疗怪兽
            self.guidePanel:SetTopAnim(true)
            self.guidePanel:SetGuideScale(0.8)
            self:GetPanelGuide(parentNode)
        end,
        [UIType.BtnFreeCompleteUI] = function()
            --指引免费气泡按钮
            local func = function()
                self.guidePanel:SetShow(true)
                local buildNode = BuildModel.GetObject(bId)
                self.isBeginGuide = true
                self.isBtnFreeCompleteUI = true
                local btnComplete = buildNode:GetBtnComplete()
                btnComplete:AddChild(self.guidePanel)
                local buildCenter = buildNode:LocalToGlobal(Vector2.zero)
                local buildX, buildY = MathUtil.ScreenRatio(buildCenter.x, buildCenter.y)
                local globalPos = buildNode:LocalToGlobal(Vector2.zero)
                local screenPosX, screenPosY = MathUtil.ScreenRatio(globalPos.x, globalPos.y)
                local posX, posY = buildX - screenPosX, buildY - screenPosY
                self.guidePanel:SetTrans(posX - 50, posY - 65)
            end
            if (GlobalVars.IsNoviceGuideStatus == true and Tool.Equal(Model.Player.GuideVersion, 1, 2, 3) and Tool.Equal(Model.Player.GuideStep, 10044, 10037, 10036)) then
                self.Info = nil
                func()
            elseif self.isBeginGuide then
                return
            elseif self.Info then
                func()
            else
                return
            end
        end,
        [UIType.UIWelfareIcon] = function()
            --指引福利中心Icon
            self:SetMainIconGuide("_btnWelfare")
        end,
        [UIType.UIGodzillaIcon] = function()
            --指引哥斯拉Icon
            self:SetMainIconGuide("_btnGodzilla")
        end,
        [UIType.UIMainTaskIcon] = function()
            --指引主界面任务按钮
            local uiMain = UIMgr:GetUI("MainUIPanel")
            if uiMain._controller.selectedIndex == 1 then
                return
            end
            self:SetMainIconGuide("_groupTaskPlot")
        end,
        [UIType.UISetupAccountUI] = function()
            --指引玩家绑定账号
            self.isBeginGuide = true
            local accountNumber = UIMgr:GetUI("SetupAccountNumber")
            accountNumber._view:AddChild(self.guidePanel)
            local btn = accountNumber:GetFaceBookBtn()
            local posx, posy = nil
            if not btn then
                posx, posy = accountNumber._listView.x, accountNumber._listView.y
            else
                posx, posy = accountNumber._listView.x + btn.x + 100, accountNumber._listView.y + btn.y - 75
            end
            self.guidePanel:SetTrans(posx, posy)
        end,
        [UIType.PlayerSkillPopupUI] = function()
            --指引玩家技能学习
            self.isBeginGuide = true
            local skillPopup = UIMgr:GetUI("PlayerSkillPopup")
            self.guidePanel:SetGuideScale(0.8)
            skillPopup._btnAllLearning:AddChild(self.guidePanel)
            self.guidePanel:SetTrans(40, -85)
        end,
        [UIType.UIMapTurnBtnUI] = function()
            --指引主界面世界地图按钮
            self:SetMainIconGuide("down")
        end,
        [UIType.PlayerDetailsUI] = function()
            --指引跳转指挥官界面
            self.isBeginGuide = true
            TurnModel.PlayerDetails()
        end,
        [UIType.PlayerDetailsAddUI] = function()
            --指引指挥官界面增加经验按钮
            local playerDetails = UIMgr:GetUI("PlayerDetails")
            if playerDetails._btnAddExp.visible then
                self.guidePanel:SetGuideScale(0.6)
                playerDetails._view:AddChild(self.guidePanel)
                playerDetails._centerList.scrollPane:ScrollBottom()
                Scheduler.ScheduleOnceFast(
                    function()
                        self.isBeginGuide = true
                        local position = playerDetails._centerItem:LocalToRoot(playerDetails._btnAddExp.xy)
                        local posx, posy = position.x, position.y
                        self.guidePanel:SetTrans(posx - 95, posy - 95)
                    end,
                    0.2
                )
            end
        end,
        [UIType.UIMapTurnMonster] = function()
            --指引世界地图跳转到野怪
            self:SetMainIconGuide("down")
        end,
        [UIType.NewGuidePlayerTip] = function()
            self.isBeginGuide = true
            self.guidePanel:SetGuideScale(1)
            self.Info:AddChild(self.guidePanel)
            local posX, posY = -self.guidePanel.width / 2 + self.Info.width / 2, -self.guidePanel.height / 2 + self.Info.height / 2
            self.guidePanel:SetTrans(posX, posY)
        end,
        [UIType.BeautySystemMainUI] = function()
            --指引美女界面开始按钮
            self.isBeginGuide = true
            local beautySystemMain = UIMgr:GetUI("BeautySystemMain")
            local btnStart = beautySystemMain._gameView:GetChild("btnStart")
            local posX, posY = -self.guidePanel.width / 2 + btnStart.width / 2, -self.guidePanel.height / 2 + btnStart.height / 2
            btnStart:AddChild(self.guidePanel)
            self.btnBeautyStart = btnStart
            self.guidePanel:SetGuideScale(0.8)
            self.guidePanel:SetTrans(posX, posY)
        end,
        [UIType.BeautyDateUI] = function()
            --指引美女界面技能
            self.isBeginGuide = true
            local beautySystemMain = UIMgr:GetUI("BeautySystemMain")
            local btnDate = beautySystemMain._btnData
            local posX, posY = -self.guidePanel.width / 2 + btnDate.width / 2, -self.guidePanel.height / 2 + btnDate.height / 2
            btnDate:AddChild(self.guidePanel)
            self.btnBeautyData = btnDate
            self.guidePanel:SetGuideScale(0.8)
            self.guidePanel:SetTrans(posX, posY)
        end,
        [UIType.BeautyExit] = function()
            --指引美女界面退出
            self.isBeginGuide = true
            local beautySystemMain = UIMgr:GetUI("BeautySystemMain")
            local btnReturn = beautySystemMain._btnReturn
            local posX, posY = -self.guidePanel.width / 2 + btnReturn.width / 2, -self.guidePanel.height / 2 + btnReturn.height / 2
            btnReturn:AddChild(self.guidePanel)
            self.btnBeautyReturn = btnReturn
            self.guidePanel:SetGuideScale(0.8)
            self.guidePanel:SetTrans(posX, posY)
        end,
        [UIType.BeautyClothUI] = function()
            --指引美女界面倒计时
            self.isBeginGuide = true
            local beautySystemMain = UIMgr:GetUI("BeautySystemMain")
            local btnCloth = beautySystemMain._btnWardrobe
            local posX, posY = -self.guidePanel.width / 2 + btnCloth.width / 2, -self.guidePanel.height / 2 + btnCloth.height / 2
            btnCloth:AddChild(self.guidePanel)
            self.btnBeautyClothBtn = btnCloth

            self.guidePanel:SetGuideScale(0.8)
            self.guidePanel:SetTrans(posX, posY)
        end,
        [UIType.SearchIconUI] = function()
            --指引主界面地球按钮
            self.isBeginGuide = true
            local mainUI = UIMgr:GetUI("MainUIPanel")
            local btnLookUp = mainUI._view:GetChild("_btnLookup")
            self.btnLookUp = btnLookUp
            local posX, posY = -self.guidePanel.width / 2 + btnLookUp.width / 2, -self.guidePanel.height / 2 + btnLookUp.height / 2
            btnLookUp:AddChild(self.guidePanel)
            self.guidePanel:SetGuideScale(0.8)
            self.guidePanel:SetTrans(posX, posY)
        end,
        [UIType.LookUpUI] = function()
            --指引主动技能界面
            self.isBeginGuide = true
            local LookupUI = UIMgr:GetUI("Lookup")
            local lookupWidht = LookupUI._btnLookup.width / 2
            local lookupHeight = LookupUI._btnLookup.height / 2
            local posX, posY = -self.guidePanel.width / 2 + lookupWidht, -self.guidePanel.height / 2 + lookupHeight
            LookupUI._btnLookup:AddChild(self.guidePanel)
            self.guidePanel:SetTopAnim(true)
            self.guidePanel:SetGuideScale(0.8)
            self.guidePanel:SetTrans(posX, posY)
        end,
        [UIType.MosterLouckUI] = function()
            --指引怪兽巢穴解锁
            local buildId = JumpModel:GetBuildId()
            local buildID = BuildModel.GetObjectByConfid(buildId)
            local buildNode = BuildModel.GetObject(buildID)
            local lockEntity = buildNode:GetLockCmpt()
            lockEntity:AddChild(self.guidePanel)
            self.guidePanel:SetTrans(-self.guidePanel.width / 2 + lockEntity.width / 2, -self.guidePanel.height / 2 + lockEntity.height / 2)
        end,
        [UIType.PlayerDetailSkillUI] = function()
            --指引指挥官技能
            self:SetMainIconGuide("_mainHead")
        end,
        [UIType.FalconUI] = function()
            --指引福利中心猎鹰行动UI
            self.isBeginGuide = true
            local welfareMain = UIMgr:GetUI("WelfareMain")
            local falconId = WelfareModel.WelfarePageType.FALCON_ACTIVITY
            local falconNode = welfareMain.GetWelfareNode(falconId)
            local btnPoint, falconIndex = falconNode:GetbtnPoint()
            btnPoint:AddChild(self.guidePanel)
            self.guidePanel:SetTopAnim(true)
            self.guidePanel:SetGuideScale(0.8)
            self.guidePanel:SetTrans(btnPoint.width / 2 - self.guidePanel.width / 2, btnPoint.height / 2 - self.guidePanel.height / 2)
            self.falconBtn = btnPoint
            self.falConIndex = falconIndex
        end,
        [UIType.ExpeditionUI] = function()
            --指引出征界面
            self.isBeginGuide = true
            local expeditionUI = UIMgr:GetUI("Expedition")
            local btnExpedition = expeditionUI._btnExpedition
            self.guidePanel:SetTopAnim(true)
            self.guidePanel:SetGuideScale(0.8)
            btnExpedition:AddChild(self.guidePanel)
            self.guidePanel:SetTrans(-self.guidePanel.width / 2 + btnExpedition.width / 2, -self.guidePanel.height / 2 + btnExpedition.height / 2)
        end,
        [UIType.BuildUpgradeGotoBtn] = function()
            --建造页面前往按钮
            self.isBeginGuide = true
            local BuildUpgradeUI = UIMgr:GetUI("BuildRelated/BuildUpgrade")
            local bgDown = BuildUpgradeUI._bgDown
            local listCom = BuildUpgradeUI._list
            self.guidePanel:SetTopAnim(false)
            self.guidePanel:SetGuideScale(0.5)
            bgDown:AddChild(self.guidePanel)
            --检查是否有空闲队列
            local isQueueIdle = BuildModel.CheckQueueIdle()
            local guideTarget = {type = "", target = nil, index = 0}
            local func = function()
                --条件不足时指引前往
                --列表的坐标
                local listPos = bgDown:GlobalToLocal(listCom:LocalToGlobal(Vector2.zero))
                --手某个单元格的坐标
                local pointPos = Vector2(-self.guidePanel.width / 2 + listPos.x, -self.guidePanel.height / 2 + listPos.y + (guideTarget.index - 1) * guideTarget.target.height)
                --按钮的坐标
                local btnPos =
                    Vector2(pointPos.x + guideTarget.target._btnFree.x + guideTarget.target._btnFree.width / 2, pointPos.y + guideTarget.target._btnFree.y + guideTarget.target._btnFree.height / 2)
                self.guidePanel:SetTrans(btnPos.x, btnPos.y)
            end
            for i = 1, listCom.numChildren do
                local child = listCom:GetChildAt(i - 1)
                local condition = child:GetCondition()

                --不满足条件
                if not condition.IsSatisfy then
                    if isQueueIdle then
                        if condition.Type == "Turn" or condition.Type == "Free" then
                            if guideTarget.type == condition.Type or guideTarget.type == "Turn" then
                                break
                            end
                            guideTarget.type = condition.Type
                            guideTarget.target = child
                            guideTarget.index = i
                        elseif condition.Type == "Accelerate" then
                            guideTarget.type = condition.Type
                            guideTarget.target = child
                            guideTarget.index = i
                        end
                    elseif not isQueueIdle then
                        if condition.Type == "Free" or condition.Type == "Accelerate" then
                            if guideTarget.type == condition.Type or guideTarget.type == "Free" then
                                break
                            end
                            guideTarget.type = condition.Type
                            guideTarget.target = child
                            guideTarget.index = i
                        end
                    end
                else
                    --满足条件
                    if condition.Type == "Free" or condition.Type == "Accelerate" then
                        if guideTarget.type == condition.Type or guideTarget.type == "Free" then
                            break
                        end
                        guideTarget.type = condition.Type
                        guideTarget.target = child
                        guideTarget.index = i
                    end
                end
            end
            if guideTarget.target then
                func()
            end
        end,
        [UIType.EquipmentUIItem] = function()
            --装备制造界面装备栏Item指引
            self.isBeginGuide = true
            local equipmentTransactionUI = UIMgr:GetUI("EquipmentTransaction")
            if not equipmentTransactionUI then
                return
            end
            local index = equipmentTransactionUI:GetDefectIndex()
            local equipmentItem = equipmentTransactionUI._itemMaterial[index]
            self.guidePanel:SetTopAnim(false)
            self.guidePanel:SetGuideScale(0.6)
            equipmentItem:AddChild(self.guidePanel)
            self.guidePanel:SetTrans(-self.guidePanel.width / 2 + equipmentItem.width / 2, -self.guidePanel.height / 2 + equipmentItem.height / 2)
        end,
        [UIType.EquipmentMakeFreeItem] = function()
            --未解锁第二材料免费队列时指引
            self.isBeginGuide = true
            local equipmentMakeUI = UIMgr:GetUI("EquipmentMake")
            if not equipmentMakeUI then
                return
            end
            local equipmentItem = equipmentMakeUI._listMaking:GetChildAt(0)
            self.guidePanel:SetTopAnim(false)
            self.guidePanel:SetGuideScale(0.5)
            equipmentItem:AddChild(self.guidePanel)
            self.guidePanel:SetTrans(-self.guidePanel.width / 2 + equipmentItem.width / 2, -self.guidePanel.height / 2 + equipmentItem.height / 2 - 20)
        end,
        [UIType.EquipmentMakeMaterialBtn] = function()
            --材料界面材料栏
            self.isBeginGuide = true
            onClickCount = 0
            local equipmentMakeUI = UIMgr:GetUI("EquipmentMake")
            if not equipmentMakeUI then
                return
            end
            local equipmentItem = equipmentMakeUI.view:GetChild("_iconMaking")
            self.guidePanel:SetTopAnim(false)
            self.guidePanel:SetGuideScale(0.8)
            equipmentMakeUI.view:AddChild(self.guidePanel)
            self.guidePanel:SetTrans(-self.guidePanel.width / 2 + equipmentItem.width / 2 + equipmentItem.x, -self.guidePanel.height / 2 + equipmentItem.height / 2 + equipmentItem.y - 20)
            self.guidePanel:PlayDragAni()
        end,
        [UIType.WorldCityTownTip] = function()
            --外城指引回城浮标
            self.isBeginGuide = true
            self.isPointWorldCityTownTip = true
            local worldCityUI = UIMgr:GetUI("WorldCity")
            if not worldCityUI then
                return
            end
            local tipItem = worldCityUI._myTownTip
            self.guidePanel:SetTopAnim(false)
            self.guidePanel:SetGuideScale(0.5)
            tipItem:AddChild(self.guidePanel)
            self.guidePanel:SetTrans(-self.guidePanel.width / 2 + tipItem.width / 2 - 5, -self.guidePanel.height / 2 + tipItem.height / 2 - 3)
        end,
        [UIType.BuildObject] = function()
            --指向某个建筑，bid为该建筑的configId
            self.isBeginGuide = true
            self.cityCompleteNode = parentNode
            local buildingId = BuildModel.GetObjectByConfid(bId)
            local buildParent = BuildModel.GetObject(buildingId)
            CityMapModel.GetCityMap():AddChild(self.guidePanel)
            local posX = buildParent.x - (self.guidePanel.width / 2)
            local posY = buildParent.y - (self.guidePanel.height / 2)
            local isInnerCity = BuildModel.IsInnerOrBeast(bId)
            local disNum = isInnerCity and 100 or 50
            if bId == Global.BuildingCenter then
                posX = posX + 200
                posY = posY - 200
            end
            self.guidePanel:SetTrans(posX, posY - disNum)
        end,
        [UIType.OtherUI] = function()
        end
    }

    if tableFunc[type] then
        tableFunc[type]()
    end
    JumpModel:SetGuideStage(self.isBeginGuide)
end

--指引主界面Icon
function GuideControllerModel:SetMainIconGuide(strUIName)
    self.isBeginGuide = true
    local checkIsCity = function()
        if not GlobalVars.IsInCityTrigger or not GlobalVars.IsInCity then
            self:SetCloseGuide()
            return
        end
    end
    if self.uiType == UIType.UIMapTurnBtnUI then
        --如果有参数则代表在世界地图可以显示引导
        if not self.Info then
            checkIsCity()
        end
    else
        checkIsCity()
    end
    local mainUIPane = UIMgr:GetUI("MainUIPanel")
    self.mainIcon = mainUIPane[strUIName]
    if strUIName ~= "_groupTaskPlot" then
        mainUIPane._view:AddChild(self.guidePanel)
    end
    self.guidePanel:SetTopAnim(false)
    local switch = {
        ["_groupTaskPlot"] = function()
            self.guidePanel:SetGuideScale(0.6)
            self.guidePanel:SetPointerScale(0.8)
            local offsetY = 0
            if ABTest.Task_ABLogic() == 2002 then
                mainUIPane._taskGuideNode:AddChild(self.guidePanel)
                offsetY = -mainUIPane._taskGuideNode.height
            else
                if mainUIPane._groupTask.visible == true then
                    mainUIPane._taskGuideNode:AddChild(self.guidePanel)
                    offsetY = -mainUIPane._taskGuideNode.height - 30
                else
                    mainUIPane._taskplotBtnPos:AddChild(self.guidePanel)
                    offsetY = -mainUIPane._taskplotBtnPos.height - 30
                end
            end
            self.guidePanel:SetTrans(10, offsetY)
        end,
        ["down"] = function()
            self.btnWorld = nil
            local btnWorld = self.mainIcon:GetChild("_btnWorld")
            if self.uiType == UIType.UIMapTurnMonster or self.uiType == UIType.UIMapTurnBtnUI then
                self.btnWorld = btnWorld
            end
            self.guidePanel:SetTopAnim(true)
            self.guidePanel:SetGuideScale(0.8)
            local posx, posy = self.mainIcon.x + btnWorld.x + btnWorld.width / 2, self.mainIcon.y + btnWorld.y + btnWorld.height / 2
            self.guidePanel:SetTrans(posx - 100, posy - 110)
        end,
        ["_btnGodzilla"] = function()
            self.guidePanel:SetGuideScale(0.8)
            self.guidePanel:SetTrans(self.mainIcon.x - (self.mainIcon.width / 2) - 38, self.mainIcon.y - (self.mainIcon.height / 2) - 39)
        end,
        ["_btnWelfare"] = function()
            self.guidePanel:SetGuideScale(0.8)
            self.guidePanel:SetTrans(self.mainIcon.x - (self.mainIcon.width / 2) - 20, self.mainIcon.y - (self.mainIcon.height / 2) - 20)
        end,
        ["_mainHead"] = function()
            self.playDetailBtn = self.mainIcon:GetChild("_btnHead")
            self.guidePanel:SetGuideScale(0.8)
            self.guidePanel:SetTrans(-self.guidePanel.width / 2 + self.mainIcon.x + (self.mainIcon.width / 2), -self.guidePanel.height / 2 + self.mainIcon.y + (self.mainIcon.height / 2))
        end
    }

    if switch[strUIName] then
        switch[strUIName]()
    else
        self.guidePanel:SetGuideScale(0.8)
        self.guidePanel:SetTrans(self.mainIcon.x - (self.mainIcon.width / 2), self.mainIcon.y - (self.mainIcon.height / 2))
    end
end

--设置引导父级
function GuideControllerModel:SetParentUI(uiPanel, typeStr)
    self.parentPanels[typeStr] = uiPanel
end

function GuideControllerModel:GetPanelGuide(parentNode, params)
    local btn = nil
    if parentNode == nil then
        return
    end

    if params == nil then
        btn = parentNode:GuildShow()
    else
        btn = parentNode:GuildShow(params)
    end
    if not btn then
        return
    end
    btn:AddChild(self.guidePanel)
    local jumpId = JumpModel:GetJumpId()
    if jumpId == 810301 then
        self.guidePanel:SetTrans(-20, -30)
    else
        local btnPosX = btn.width / 2
        local btnPosY = btn.height / 2
        self.guidePanel:SetTrans(-self.guidePanel.width / 2 + btnPosX, -self.guidePanel.height / 2 + btnPosY)
    end
end

--当前功能列表按钮是否为指引
function GuideControllerModel:CheackCompleteBtn(t)
    if t ~= self.cutCompleteName and not isNewGuideStep then
        self:SetCloseGuide()
    end
end

function GuideControllerModel:SetCutJumBid(buildId)
    cutJumpBuildId = JumpModel:GetBuildId()
    if not cutJumpBuildId then
        return false
    end
    local jumpId = JumpModel:GetJumpId()
    local isNoBuildId = Tool.Equal(jumpId, 810202, 810203, 810204, 810205, 810301)
    if not BuildModel.GetConf(cutJumpBuildId) and isNoBuildId then
        local tempId = nil
        if BuildModel.GetConfIdByArmId(cutJumpBuildId) then
            tempId = BuildModel.GetConfIdByArmId(cutJumpBuildId)
        end
        if BuildModel.GetTechCenterId(cutJumpBuildId) then
            tempId = BuildModel.GetTechCenterId(cutJumpBuildId)
        end
        cutJumpBuildId = tempId
    end
    JumpModel:SetBuildId(cutJumpBuildId)
    return buildId == cutJumpBuildId and true or false
end

function GuideControllerModel:GetCityMapPieceNum()
    if self.piecePosNum ~= nil then
        return self.piecePosNum
    end
end

function GuideControllerModel:SetCloseGuide()
    if self.guidePanel == nil then
        return
    end
    self:InitGuieView()
    self.isBeginGuide = false
    self.cutSpeace = nil
    self.cityCompleteNode = nil
    self.uiType = nil
    self.unionItemName = nil
    self.cutCompleteName = ""
    self.jumpType = _G.GD.GameEnum.JumpType.Null
    self.Info = nil
    self.falconBtn = nil
    self.falConIndex = nil
    self.mainIcon = nil
    self.btnLookUp = nil
    self.itemDetail = nil
    self.playDetailBtn = nil
    self.isBtnFreeCompleteUI = false
    self.isPointWorldCityTownTip = false
    GlobalVars.IsJumpGuide = false
    cutJumpBuildId = 0
    JumpModel:SetJumpBidInit()
    JumpModel:SetJumpArmyId(0)
    JumpModel:SetGuideStage(nil)
    isNewGuideStep = false
    local bid = self:GetValParams("cityFunctionBId")
    bid = nil
end

--是否正在指向免费气泡
function GuideControllerModel:IsBtnFreeGuide()
    return self.isBtnFreeCompleteUI
end

--是否正在指向城外浮标
function GuideControllerModel:IsWorldCityTownTip()
    return self.isPointWorldCityTownTip
end

function GuideControllerModel:IsGuideState(params, cutJumpType)
    if not params and not cutJumpType then
        return self.isBeginGuide
    end
    local mJumptype = JumpModel:GetJumpType()
    if mJumptype == _G.GD.GameEnum.JumpType.Make then
        mJumptype = _G.GD.GameEnum.JumpType.Train
    end
    if (mJumptype and cutJumpType) and cutJumpType ~= mJumptype then
        return false
    end
    local isGuide = (self.isBeginGuide and self.Info == params) and true or false
    return isGuide
end

function GuideControllerModel.GetBuildDealyTime()
    return BuildDelayTime
end

--设置参数切是不会被释放UI或参数
function GuideControllerModel:SetValParams(type, valNode)
    self.ValParams[type] = valNode
end

function GuideControllerModel:GetValParams(type)
    if self.ValParams[type] then
        return self.ValParams[type]
    end
end

function GuideControllerModel:SetGuideAuto()
    if not cutJumpBuildId then
        return
    end
    local jumpId = JumpModel:GetJumpId()
    if Tool.Equal(jumpId, 810000, 810001, 810101) then --建筑引导
        local uiCreate = UIMgr:GetUI("BuildRelated/BuildCreate")
        if uiCreate and uiCreate.IsVisible then
            local uiUpgrade = UIMgr:GetUI("BuildRelated/BuildUpgrade")
            if uiUpgrade and uiUpgrade.IsVisible then
                if Model.Player.GuideVersion == 0 then
                    if cutJumpBuildId == 424000 then
                        uiUpgrade:ClickUpdate(true)
                    else
                        uiUpgrade:ClickUpdate(false)
                    end
                else
                    uiUpgrade:ClickUpdate(false)
                end
                return
            end
            uiCreate:OnBtnBuildClick()
            Scheduler.ScheduleOnceFast(
                function()
                    NoviceModel.SetCanSkipNovice(true)
                end,
                0.5
            )
            return
        end
        local pos = BuildModel.GetCreatPos(cutJumpBuildId)
        local piece = CityMapModel.GetMapPiece(pos)
        piece:OnBtnPieceClick()
        Scheduler.ScheduleOnceFast(
            function()
                NoviceModel.SetCanSkipNovice(true)
            end,
            0.5
        )
    elseif Tool.Equal(jumpId, 810100) then
        local uiUpgrade = UIMgr:GetUI("BuildRelated/BuildUpgrade")
        if uiUpgrade == nil then
            UIMgr:Open("BuildRelated/BuildUpgrade", BuildModel.GetCenter().Pos)
            CityMapModel.GetCityFunction():SetFuncVisible(false)
            Scheduler.ScheduleOnceFast(
                function()
                    NoviceModel.SetCanSkipNovice(true)
                end,
                0.5
            )
        else
            if uiUpgrade.IsVisible == false then
                UIMgr:Open("BuildRelated/BuildUpgrade", BuildModel.GetCenter().Pos)
                CityMapModel.GetCityFunction():SetFuncVisible(false)
                Scheduler.ScheduleOnceFast(
                    function()
                        NoviceModel.SetCanSkipNovice(true)
                    end,
                    0.5
                )
            else
                uiUpgrade:ClickUpdate(false)
                GuideControllerModel:SetCloseGuide()
            end
        end
    elseif jumpId == 810200 then --训练引导
        local uiTrain = UIMgr:GetUI("BuildRelated/BuildTrain")
        if uiTrain and uiTrain.IsVisible then
            CityMapModel.GetCityFunction():SetFuncVisible(false)
            uiTrain:OnBtnTimeTrainClick()
            GuideControllerModel:SetCloseGuide()
            return
        end
        if CityMapModel:GetComplete().visible then
            local building = BuildModel.FindByConfId(cutJumpBuildId)
            TurnModel.TrainArmy(building)
        end
        Scheduler.ScheduleOnceFast(
            function()
                NoviceModel.SetCanSkipNovice(true)
            end,
            0.5
        )
    end
end

function GuideControllerModel:InitAction()
    --修改点击事件
    Event.AddListener(
        EventDefines.EndTouchGuide,
        function(target)
            if not target then
                return
            end
            GlobalVars.IsClicking = true

            if self.isBeginGuide and not self:LimitInput(target.gOwner) and not isNewGuideStep then
                self:SetCloseGuide()
            end
        end
    )
    if self.clickTimer then
        Scheduler.UnSchedule(self.clickTimer)
    end
    self.clickTimer = function()
        if GlobalVars.IsClicking then
            GlobalVars.IsClicking = false
        end
    end
    --低于6级时开启按钮监听
    Scheduler.Schedule(self.clickTimer, 1)
end

--关闭计时器
function GuideControllerModel:CloseClickTimer()
    Scheduler.UnSchedule(self.clickTimer)
end

--设置弱引手指不消失，且屏幕可以操作
function GuideControllerModel:LimitInput(val)
    --如果是新手引导直接为真
    if isNewGuideStep then
        return isNewGuideStep
    end
    --如果内城地图在移动状态不能点击
    if not isEndMove then
        return true
    end

    local isLimit = false
    if self:CheackGuideNoStage(val) then
        isLimit = true
    end
    local uiTypeSwitch = {
        [UIType.CityMapUI] = function()
            if val and val == self.cutSpeace then
                isLimit = true
            end
        end,
        [UIType.LockUI] = function()
            if val and val == self.Info then
                isLimit = true
            end
        end,
        [UIType.UnionBtnUI] = function()
            if val and val.parent and val.parent == self.unionBtn then
                isLimit = true
            end
        end,
        [UIType.BuildCreateUI] = function()
            isLimit = true
        end,
        [UIType.BuildUpgradeUI] = function()
            isLimit = true
        end,
        [UIType.UnionUI] = function()
            isLimit = true
        end,
        [UIType.LaboratoryUI] = function()
            isLimit = true
        end,
        [UIType.LaboratorySkillUI] = function()
            isLimit = true
        end,
        [UIType.UIMapTurnMonster] = function()
            if GlobalVars.IsInCity and val and self.btnWorld and self:GetJumpId() == 813200 and val.parent == self.btnWorld then
                isLimit = false
                self.btnWorld = nil
                WorldMap.AddEventAfterMap(
                    function()
                        JumpModel.Map[810700](9400)
                    end
                )
            end
        end,
        [UIType.UIMapTurnBtnUI] = function()
            if GlobalVars.IsInCity and val and self.btnWorld then
                if val.parent == self.btnWorld or UIMgr:GetUIOpen("MainUICloud") then
                    isLimit = true
                else
                    isLimit = false
                end
            end
        end,
        [UIType.SearchIconUI] = function()
            if val and val.parent == self.btnLookUp then
                isLimit = true
            end
        end,
        [UIType.NewGuidePlayerTip] = function()
            isLimit = true
        end,
        [UIType.WorldMapPoint] = function()
            isLimit = true
        end,
        [UIType.WorldMapUI] = function()
            isLimit = true
        end,
        [UIType.ItemDetailUI] = function()
            if val and val.parent == self.itemDetail then
                isLimit = true
            end
        end,
        [UIType.PlayerDetailSkillUI] = function()
            if val and val.parent == self.playDetailBtn then
                isLimit = true
            end
        end,
        [UIType.BeautySystemMainUI] = function()
            if val and val ~= self.btnBeautyStart then
                isLimit = true
            end
        end,
        [UIType.BeautyDateUI] = function()
            if val and not (val == self.btnBeautyData or val.parent == self.btnBeautyData) then
                isLimit = true
            end
        end,
        [UIType.BeautyExit] = function()
            if val and not (val == self.btnBeautyReturn or val.parent == self.btnBeautyReturn) then
                isLimit = true
            end
        end,
        [UIType.BeautyClothUI] = function()
            if val and val ~= self.btnBeautyClothBtn then
                isLimit = true
            end
        end,
        [UIType.BtnFreeCompleteUI] = function()
            if (GlobalVars.IsNoviceGuideStatus == true and Tool.Equal(Model.Player.GuideVersion, 1, 2, 3) and Tool.Equal(Model.Player.GuideStep, 10044, 10037, 10036)) then
                isLimit = true
            end
        end,
        [UIType.FalconUI] = function()
            if val and val == self.falconBtn then
                JumpMap:JumpTo({jump = 810801, para = self.falConIndex})
            end
        end,
        [UIType.ExpeditionUI] = function()
            if val then
                isLimit = true
            end
        end,
        [UIType.EquipmentMakeMaterialBtn] = function()
            if val and onClickCount < 4 then
                isLimit = true
            end
            onClickCount = onClickCount + 1
        end
    }

    if uiTypeSwitch[self.uiType] then
        uiTypeSwitch[self.uiType]()
    end

    return isLimit
end

--不关闭引导的各种条件
function GuideControllerModel:CheackGuideNoStage(val)
    if val then
        local tipBar = self:GetValParams(UIType.TipBarUI)
        local tipBar2 = self:GetValParams(UIType.TipBarUI2)
        local btnQueue = self:GetValParams(UIType.btnQueueBuild)
        local btnQueueLock = self:GetValParams(UIType.btnQueueBuildLock)
        local isOtherGuide = self.uiType ~= UIType.BtnFreeCompleteUI and self.uiType ~= UIType.UIMainTaskIcon

        local cityFunctionBId = self:GetValParams("cityFunctionBId")
        local buildStr = "itemBuild"
        if cityFunctionBId then
            buildStr = buildStr .. cityFunctionBId
        end

        if val.name == buildStr and self.uiType ~= UIType.BtnFreeCompleteUI then
            return true
        end
        if val and (val.parent == btnQueue or val.parent == btnQueueLock) and not self.isBeginGuide then
            return true
        end
        --推荐任务处于不可点击状态
        local isTaskNoClick = Tool.Equal(val, tipBar2, tipBar) and self:GetValParams("TaskStage") == 0
        if isTaskNoClick and isOtherGuide then
            return true
        end
        if val.parent.parent == self.cityCompleteNode or val.parent == self.cityCompleteNode then
            return true
        end
        if self.uiType == UIType.BtnFreeCompleteUI and self.Info and self.Info == val.parent then
            return true
        end
    end
    return false
end

function GuideControllerModel.ClearAction()
    KSUtil.Click = nil
end

--设置GuideView
function GuideControllerModel:InitGuieView()
    --如果位置不相同或者引导状态中
    local posSame = self:CheckGuiderPos()
    if self.isBeginGuide == true or not posSame then
        if self.guidePanel then
            GRoot.inst:AddChild(self.guidePanel)
            self.guidePanel:SetTrans(-4000, -4000)
        end
    end
end

--检测手指是否在初始位置
function GuideControllerModel:CheckGuiderPos()
    if not self.guidePanel then
        return true
    end
    local posSame = self.guidePanel.x == -4000 and self.guidePanel.y == -4000
    return posSame
end

function GuideControllerModel:GetBid()
    if JumpModel:GetJumpBidId() then
        return JumpModel:GetJumpBidId()
    end
end

function GuideControllerModel:GetJumpId()
    return JumpModel:GetJumpId()
end
return GuideControllerModel
