--[[
    author:{触发式强引导}
    time:2020-02-17 16:12:49
]]
local GD = _G.GD
local TriggerGuideLogic = {}
---------------------------------------------------------模块导入----------------------------------------------
local BuildModel = import("Model/BuildModel")
local GuideModel = import("Model/GuideControllerModel")
local JumpMap = import("Model/JumpMap")
local JumpMapModel = import("Model/JumpMapModel")
local NoviceModel = import("Model/NoviceModel")
local WelfareModel = import("Model/WelfareModel")
local BuildNest = import("UI/MainCity/BuildRelated/BuildAnim/BuildNest")
local GD = _G.GD

---------------------------------------------------------设置常量---------------------------------------------
local UIMgr = _G.UIMgr
local GlobalVars = _G.GlobalVars
local Scheduler = _G.Scheduler

local UIType = _G.GD.GameEnum.UIType
local IsNoviceReadyCb = false
local cutNoviceId = 0 --新手引导Id
local delayTime = 3 --设置引导步骤延迟时间处理
local onceDealy = 0.4 --引导步骤回调方法延迟执行
local isHiddenClipMask = false --是否不显示黑色遮罩
local btnEntityFuncs = {}
local btnCallback = nil
local initGuidePos = -4000 --初始化指引图标位置

---------------------------------------------------------设置类型---------------------------------------------
local GuideCreatType = {
    Creat = 0,
    Upgrade = 1,
    UnLock = 2
}

-----------------------------------------------------引导过程中的相关设置----------------------------------------
--@desc: 新手引导阶段设置延迟点击，即玩家无法操作
function TriggerGuideLogic.DelayClick(time)
    local delayFunc = function()
        if NoviceModel.GetCanSkipNovice() == false then
            NoviceModel.SetCanSkipNovice(true)
        end
    end
    Scheduler.UnScheduleFast(delayFunc)
    Scheduler.ScheduleOnceFast(delayFunc, time)
end

--@desc:设置页面的点击回调事件
function TriggerGuideLogic:SetBtnClick(btnEntity)
    local callBack = function()
        if self.guideIsBegin and self.triggerGuideEnd then
            self:CloseTriggerGuide()
            self:SetTriggerNextStep()
            return
        elseif self.guideIsBegin and not self.triggerGuideEnd then
            local FuncGuide = function()
                --初始化位置
                self:InitGuiderPos()
                self:SetTriggerNextStep()
            end
            FuncGuide()
        elseif not self.guideIsBegin then
            return
        end
    end

    table.insert(btnEntityFuncs, btnEntity)
    btnEntity:TriggerOnclick(callBack)
end

--@desc:删除页面按钮的点击方法
function TriggerGuideLogic.RemoveTriggerFunc()
    if not next(btnEntityFuncs) then
        return
    end
    for _, v in pairs(btnEntityFuncs) do
        v:TriggerOnclick(nil)
    end
    btnEntityFuncs = {}
end

--@desc:设置UIMaskManager的提示框位置
function TriggerGuideLogic.SetTipPos(pos, isTop, des)
    local uiMask = UIMgr:GetUI("UIMaskManager")
    uiMask:SetTipPos(pos, isTop, des)
end

--@desc:设置触发引导遮罩显示
function TriggerGuideLogic.SetMaskClipShow()
    local maskUI = UIMgr:GetUI("UIMaskManager")
    maskUI:SetGuideMaskClipShow()
end

--@desc:是否打开Mask遮罩
function TriggerGuideLogic:SetOpenMask()
    local callback = function()
        self:CloseTriggerGuide()
    end
    UIMgr:Open("UIMaskManager", {initGuidePos, initGuidePos}, callback)
    self.guideIsBegin = true
end

--@desc:检测UI是否打开
function TriggerGuideLogic.CheackIsUIOpen(uiName)
    local uiOpen = UIMgr:GetUIOpen(uiName)
    if uiOpen and UIMgr:GetUI(uiName) then
        return true
    else
        return false
    end
end

--@desc:初始化引导遮罩位置
function TriggerGuideLogic:InitGuiderPos()
    local uiMask = UIMgr:GetUI("UIMaskManager")
    uiMask:GetCurrentMask().xy = Vector2(initGuidePos, initGuidePos)
    self:SetGuideScale({1, 1})
    uiMask:SetGuidePos({initGuidePos, initGuidePos})
    local pos = Vector2(initGuidePos, initGuidePos)
    local radius = Vector2(100, 100)
    uiMask:SetGuideClipInitPos(pos, radius)
end

--@desc:设置引导遮罩位置
function TriggerGuideLogic:SetGuidePos(pos, isBox)
    self.maskGuide = UIMgr:GetUI("UIMaskManager")
    self.maskGuide:SetPosParams(pos, isBox)
    if GlobalVars.IsNoviceGuideStatus then
        TriggerGuideLogic.DelayClick(0.5)
    end
    --遮罩显示
    if not isHiddenClipMask then
        self.maskGuide:SetGuideClipPara()
    end
end

--@desc:设置类似指引日常任务的那个范围框的大小位置
function TriggerGuideLogic:SetGuideBox(xy, wh)
    self.maskGuide = UIMgr:GetUI("UIMaskManager")
    self.maskGuide:SetGuideBox(xy, wh)
end

--@desc:设置当前UIMaskManager的遮罩大小
function TriggerGuideLogic:SetGuideMaskSize(sizeParams)
    self.maskGuide = UIMgr:GetUI("UIMaskManager")
    self.maskGuide:GetCurrentMask().size = sizeParams
end

--@desc:设置遮罩的点击事件
function TriggerGuideLogic:SetGuidBgTouch(callback)
    self.maskGuide = UIMgr:GetUI("UIMaskManager")
    self.maskGuide:SetGuideLayerTouch(callback)
end

--@desc:scale 表示挖洞的缩放大小，scale1 表示手指框缩放大小
function TriggerGuideLogic:SetGuideScale(scale, scale1)
    self.maskGuide = UIMgr:GetUI("UIMaskManager")
    if not scale1 then
        self.maskGuide:SetGuideLayerScale(scale)
    else
        self.maskGuide:SetGuideLayerScale(scale1)
    end
    self.maskGuide:SetScale(scale)
    TriggerGuideLogic.SetPointerScale(0.8)
end

--@desc:设置点击区域大小
function TriggerGuideLogic.SetPointerScale(offset)
    local maskManageUI = UIMgr:GetUI("UIMaskManager")
    maskManageUI:SetGuidePointerScale(offset)
end

--@desc:设置触发点击事件回调，主要用在猎鹰行动
function TriggerGuideLogic.SetNextCallBack(cb)
    btnCallback = cb
end

--@desc:点击建筑后打开的功能菜单
function TriggerGuideLogic:SetItemCityFunction(strName)
    Event.Broadcast(EventDefines.DelayMask, true)
    local CityMap = CityMapModel.GetCityMap()
    local cityComplete = GuideModel:GetPanelByType(UIType.CityCompleteUI)
    Scheduler.ScheduleOnceFast(
        function()
            local btn, btnName = cityComplete:GetFuncItem(strName)
            if not btn then
                Log.Error("点击建筑无功能菜单退出引导")
                self:ClearTriggerGuide()
                return
            end
            local layerGuide = UIMgr:GetUI("GuideLayer")
            local guider = layerGuide._guide
            local cutScale = guider.scale.y * 0.6 * CityMap.scale.x
            self:SetGuideScale({cutScale, cutScale})
            local pos = layerGuide._view:GlobalToLocal(btn:LocalToGlobal(Vector2.zero))
            local newPosX, newPosY = pos.x + btn.scale.x * btn.width / 2 * CityMap.scale.x + 3, pos.y + btn.scale.x * btn.height / 2 * CityMap.scale.x + 2
            TriggerGuideLogic:SetGuidePos({newPosX, newPosY})
            Event.Broadcast(EventDefines.DelayMask, false)
            self:SetBtnClick(btn)
        end,
        0.1
    )
end

--@desc:设置建筑建造页选择
function TriggerGuideLogic:SetBuildCreateUI(confId)
    local buildCreate = UIMgr:GetUI("BuildRelated/BuildCreate")
    buildCreate:SetRecommendPos(confId, true)
    local buildUI = buildCreate._btnBuild
    local posx, posy = buildUI.x + buildUI.width / 2, buildUI.y + buildUI.height / 2
    local guideLayer = UIMgr:GetUI("GuideLayer")
    guideLayer._guide:SetTopAnim(true)
    TriggerGuideLogic:SetGuideScale({0.8, 0.8})
    TriggerGuideLogic:SetGuidePos({posx, posy})
    Scheduler.ScheduleOnceFast(
        function()
            TriggerGuideLogic:SetBtnClick(buildCreate)
        end,
        0.2
    )
end

--@desc:指引到建筑位置的触发引导
function TriggerGuideLogic:SetMoveCallBack(buildConfId, dis, scaleOffset, moveType, tempCb)
    Event.Broadcast(EventDefines.DelayMask, true)
    local entity = nil
    local piece = nil
    local btnEntity = nil
    local lockEntity = nil
    local moveTypeSwitch = {
        [GuideCreatType.Creat] = function()
            local pos = BuildModel.GetCreatPos(buildConfId)
            entity = CityMapModel.GetMapPiece(pos)
            piece = entity
            btnEntity = entity
        end,
        [GuideCreatType.Upgrade] = function()
            --特殊处理医院
            local building = nil
            if Global.BuildingHospital == buildConfId then
                building = BuildModel:GetIdleHospital()
            else
                building = BuildModel.FindByConfId(buildConfId)
            end
            piece = CityMapModel.GetMapPiece(building.Pos)
            local buildId = BuildModel.GetObjectByConfid(buildConfId)
            entity = BuildModel.GetObject(buildId)
            btnEntity = entity
        end,
        [GuideCreatType.UnLock] = function()
            local buildId = BuildModel.GetObjectByConfid(buildConfId)
            if buildConfId == Global.BuildingBeastBase then
                --btnEntity = entity
                --local building = BuildModel.FindByConfId(buildConfId)
                entity = BuildModel.GetObject(buildId)
            else
                local pos = BuildModel.GetCreatPos(buildConfId)
                entity = CityMapModel.GetMapPiece(pos)
            end
            local buildNode = BuildModel.GetObject(buildId)
            if not buildNode._itemLock then
                Log.Error("{0}，建筑解锁获取不到解锁组件退出引导", buildConfId)
                self:ClearTriggerGuide()
                return
            end
            lockEntity = buildNode:GetLockCmpt()
            piece = entity
            btnEntity = buildNode
        end
    }

    if moveTypeSwitch[moveType] then
        moveTypeSwitch[moveType]()
    end
    local cb = function()
        Scheduler.ScheduleOnceFast(
            function()
                local CityMap = CityMapModel.GetCityMap()
                local scaleX = (lockEntity ~= nil) and lockEntity.scale.x or entity.scale.x
                local cutScale = scaleX * 1.0 * CityMap.scale.x
                local scale2 = (#scaleOffset == 2) and {cutScale * scaleOffset[2], cutScale * scaleOffset[2]} or nil
                self:SetGuideScale({cutScale * scaleOffset[1], cutScale * scaleOffset[1]}, scale2)
                local layerGuide = UIMgr:GetUI("GuideLayer")
                if buildConfId ~= Global.BuildingKingkong then
                    if lockEntity then
                        local pos = layerGuide._view:GlobalToLocal(lockEntity:LocalToGlobal(Vector2.zero))
                        local newPosX, newPosY = pos.x + scaleX * lockEntity.width / 2 * CityMap.scale.x, pos.y + scaleX * lockEntity.height / 2 * CityMap.scale.y
                        TriggerGuideLogic:SetGuidePos({newPosX, newPosY})
                    else
                        local pos = layerGuide._view:GlobalToLocal(entity:LocalToGlobal(Vector2.zero))
                        local newPosX, newPosY = pos.x, pos.y - (entity.scale.x * entity.height / 2 * CityMap.scale.y)
                        TriggerGuideLogic:SetGuidePos({newPosX + dis[1], newPosY + dis[2]})
                    end
                    Event.Broadcast(EventDefines.DelayMask, false)
                    TriggerGuideLogic:SetBtnClick(btnEntity)
                end
                --回调函数
                if tempCb then
                    tempCb()
                end
            end,
            0.2
        )
    end

    local isEqualPos = CityMapModel.CheckSpaceNodeIsMoved(piece.x, piece.y)
    if isEqualPos then
        cb()
        return
    else
        --延迟执行避免同事点击出错
        Scheduler.ScheduleOnceFast(
            function()
                ScrollModel.ForceStop()
                --带缩放移动
                ScrollModel.MoveScale(piece, buildConfId, nil, true)
                ScrollModel.SetCb(cb)
            end,
            0.3
        )
        return
    end
    --溢错处理
    Log.Error("溢错处理退出引导", buildConfId)
    TriggerGuideLogic:ClearTriggerGuide()
end

--@desc:镜头移动后回调
function TriggerGuideLogic.SetNoviceOnCall()
    IsNoviceReadyCb = true
end

--@desc:关闭所有窗口
function TriggerGuideLogic.IsNeedCloseWindow()
    local id = GlobalVars.NowTriggerId
    local triggerInfo = GD.TriggerGuideAgent.GetTriggerGuideByConfId(id)
    if triggerInfo and triggerInfo.isCloseWindow == 1 then
        UIMgr:ClosePopAndTopPanel()
        if UIMgr:GetUIOpen("TaskPlot") then
            UIMgr:Close("TaskPlot")
        end
        if CityType.BUILD_MOVE_TIP then
            Event.Broadcast(EventDefines.UICityBuildMove, BuildType.MOVE.Reset)
        end
    end
end

--@desc:关闭遮罩
function TriggerGuideLogic.CloseMaskUI()
    ScrollModel.SetWhetherMoveScale()
    UIMgr:Close("UIMaskManager")
end

---------------------------------------------------------引导步骤---------------------------------------------------
--desc:每个引导步骤的方法都按照步骤id写在这个列表当中
--注：新手引导|configNoviceGuide表格type字段类型为6，7，10，13的不需要写
TriggerGuideLogic.GuideTable = {
    --指引到任务按钮
    [1001] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                isHiddenClipMask = true
                local mainPanel = UIMgr:GetUI("MainUIPanel")
                local pos = {mainPanel._bgTipsBar.x + 120, mainPanel._bgTipsBar.y + 30}
                TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                TriggerGuideLogic:SetGuidePos(pos)
                TriggerGuideLogic.StepFunc = function()
                    --镜头移动结束后回调
                    TriggerGuideLogic.SetNoviceOnCall()
                    JumpMap:JumpTo(mainPanel.cutJump.jump, mainPanel.cutJump.finish)
                    Event.Broadcast(EventDefines.NextNoviceStep, 1001)
                end
            end
        )
    end,
    --主界面任务按钮
    [1002] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local mainPanel = UIMgr:GetUI("MainUIPanel")
                local taskBtnX = mainPanel.down.x + mainPanel._btnTask.x
                local taskBtnY = mainPanel.down.y + mainPanel._btnTask.y
                local pos = {taskBtnX + 10, taskBtnY}
                local guideLayer = UIMgr:GetUI("GuideLayer")
                guideLayer._guide:SetTopAnim(true)
                TriggerGuideLogic:SetGuidePos(pos)
                TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                TriggerGuideLogic.StepFunc = function()
                    --Log.Error("Strong Guide -----------------------1002")
                    TriggerGuideLogic.SetNoviceOnCall()
                    Event.Broadcast(EventDefines.UIOpenTaskPanel, false)
                end
            end
        )
    end,
    --任务界面领取按钮
    [1003] = function()
        local taskPanel = nil
        TriggerGuideLogic:SetScheduler(
            function()
                taskPanel = UIMgr:GetUI("TaskMain")
                local getRewardBtnX = taskPanel._btnRecGet.x + taskPanel._btnRecGet.width / 2
                local getRewardBtnY = taskPanel._btnRecGet.x + taskPanel._btnRecGet.height / 2 + 14
                local pos = {getRewardBtnX + 15, getRewardBtnY + 15}
                TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                TriggerGuideLogic:SetGuidePos(pos)
                TriggerGuideLogic.StepFunc = function()
                    --Log.Error("Strong Guide -----------------------1003")
                    taskPanel:GetRecTaskOnclick()
                    TriggerGuideLogic.SetNoviceOnCall()
                end
            end,
            "TaskMain"
        )
    end,
    --跳转到主城
    [1004] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                isHiddenClipMask = true
                local mainPanel = UIMgr:GetUI("MainUIPanel")
                local pos = {mainPanel._bgTipsBar.x + 150, mainPanel._bgTipsBar.y + 50}
                TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                TriggerGuideLogic:SetGuidePos(pos)
                TriggerGuideLogic.StepFunc = function()
                    --Log.Error("Strong Guide -----------------------1004")
                    TriggerGuideLogic.SetNoviceOnCall()
                    JumpMap:JumpTo(mainPanel.cutJump.jump, mainPanel.cutJump.finish)
                    Event.Broadcast(EventDefines.NextNoviceStep, 1004)
                end
            end
        )
    end,
    --升级按钮
    [1005] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic.StepFunc = function()
                    UIMgr:Open("BuildRelated/BuildUpgrade", BuildModel.GetCenter().Pos)
                    TriggerGuideLogic.SetNoviceOnCall()
                    CityMapModel.GetCityFunction():SetFuncVisible(false)
                end
            end
        )
    end,
    --升级
    [1006] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                -- local upgradePanel = UIMgr:GetUI("BuildRelated/BuildUpgrade")
                -- local upgradeBtnX = upgradePanel._btnR.x
                -- local upgradeBtnY = upgradePanel._btnR.y
                local buildUpgrade = UIMgr:GetUI("BuildRelated/BuildUpgrade")
                local buildUI = buildUpgrade._btnR
                local posx, posy = buildUpgrade._bgDown.x + buildUI.x + buildUI.width / 2, buildUpgrade._bgDown.y + buildUI.y + buildUI.height / 2
                local pos = {posx, posy}
                TriggerGuideLogic:SetGuideScale({0.42, 0.42})
                TriggerGuideLogic:SetGuidePos(pos)
                TriggerGuideLogic.StepFunc = function()
                    TriggerGuideLogic.SetNoviceOnCall()
                    upgradePanel:ClickUpdate(false)
                    UIMgr:Close("BuildRelated/BuildUpgrade")
                end
            end,
            "BuildRelated/BuildUpgrade"
        )
    end,
    --点击剧情任务
    [1007] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local mainPanel = UIMgr:GetUI("MainUIPanel")
                local taskBtnX = mainPanel._plotIcon.x
                local taskBtnY = mainPanel._plotIcon.y
                local pos = {taskBtnX + 180, taskBtnY + 50}
                TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                TriggerGuideLogic:SetGuidePos(pos)
                local guideLayer = UIMgr:GetUI("GuideLayer")
                guideLayer._guide:SetTopAnim(false)
                TriggerGuideLogic.StepFunc = function()
                    Net.Chapter.GetChapterInfo(
                        function(msg)
                            --Log.Error("Strong Guide -----------------------1007")
                            TriggerGuideLogic.SetNoviceOnCall()
                            UIMgr:Open("TaskPlot", msg)
                        end
                    )
                end
            end
        )
    end,
    --点击前往
    [1008] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local taskPanel = UIMgr:GetUI("TaskPlot")
                local taskItem = UIMgr:GetUI("TaskPlot").Controller.contentPane:GetChild("TaskPlotItem")
                local list = taskItem:GetChild("liebiaoPlot")
                local btnVector = list:GetChildAt(0):LocalToRoot(list:GetChildAt(0)._btnGo.xy)
                local offsetX = 50
                local offsetY = 40
                if MathUtil.HaveMatch() then
                    offsetX = offsetX * 0.75
                    offsetY = offsetY * 0.75
                end
                local pos = {btnVector.x + offsetX, btnVector.y + offsetY}
                TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                TriggerGuideLogic:SetGuidePos(pos)
                TriggerGuideLogic.StepFunc = function()
                    --Log.Error("Strong Guide -----------------------1008")
                    TriggerGuideLogic.SetNoviceOnCall()
                    taskPanel._list:GetChildAt(0):OnBtnClick(false)
                    Event.Broadcast(EventDefines.NextNoviceStep, 1008)
                end
            end,
            "TaskPlot"
        )
    end,
    --免费气泡引导
    [1009] = function()
        -- Event.Broadcast(EventDefines.Mask, true)
        Scheduler.ScheduleOnceFast(
            function()
                Event.Broadcast(EventDefines.CloseGuide)
                local centerBuild = BuildModel:GetCenter()
                Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BtnFreeCompleteUI, nil, centerBuild.Id)
                TriggerGuideLogic.DelayClick(0.5)
                TriggerGuideLogic.StepFunc = function()
                    Log.Error("Strong Guide -----------------------1009")
                    local node = BuildModel.GetObject(centerBuild.Id)
                    if Model.Player.Level ~= 2 then
                        node:BuildClick()
                    end
                    TriggerGuideLogic.SetNoviceOnCall()
                end
            end,
            0.2
        )
    end,
    --点击背包
    [1010] = function()
        -- Event.Broadcast(EventDefines.JumpTipEvent,nil,-1,UIType.PlayerDetailSkillUI,)
        -- Event.Broadcast(EventDefines.Mask, true)
        local mainPanel = UIMgr:GetUI("MainUIPanel")
        local backpackBtnX = mainPanel.down.x + mainPanel._btnBackpack.x
        local backpackBtnY = mainPanel.down.y + mainPanel._btnBackpack.y
        local pos = {backpackBtnX + 5, backpackBtnY + 5}
        local guideLayer = UIMgr:GetUI("GuideLayer")
        guideLayer._guide:SetTopAnim(true)
        TriggerGuideLogic:SetGuideScale({0.6, 0.6})
        TriggerGuideLogic:SetGuidePos(pos)
        TriggerGuideLogic.StepFunc = function()
            --Log.Error("Strong Guide -----------------------1010")
            --打开背包界面
            TriggerGuideLogic.SetNoviceOnCall()
            UIMgr:Open("Backpack")
        end
    end,
    --点击物品按钮
    [1011] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                --TODO暂时写死
                local giftId = 200512
                local backPack = UIMgr:GetUI("Backpack")
                backPack:ScrollToViewItem(giftId)
                local itemEntity = GD.ItemAgent.GetItemPane(giftId)
                local listItem = itemEntity.uiParent
                local listPosY = backPack:GetGuidePosByItem(listItem)
                backPack:SetScrollTouchEffect(false)
                local itemPosX = backPack._list.x + (itemEntity.width / 2 + itemEntity.x)
                local itemPosY = backPack._list.y + (itemEntity.height / 2 + listPosY)
                local guideLayer = UIMgr:GetUI("GuideLayer")
                guideLayer._guide:SetTopAnim(false)
                TriggerGuideLogic:SetGuideScale({0.7, 0.7})
                TriggerGuideLogic:SetGuidePos({itemPosX + 13, itemPosY + 6})
                TriggerGuideLogic.StepFunc = function()
                    --模拟点击
                    TriggerGuideLogic.SetNoviceOnCall()
                    itemEntity._btnClick.onClick:Call()
                end
            end,
            "Backpack"
        )
    end,
    --点击使用道具
    [1012] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                -- Scheduler.ScheduleOnceFast(function()end,)
                local usePanel = GD.ItemAgent.GetItemBoxPane()
                local backPack = UIMgr:GetUI("Backpack")
                local useBtn = usePanel._btnUse
                local posX = backPack._list.x + usePanel.x + (useBtn.x + useBtn.width / 2)
                local posY = backPack._list.y + usePanel.y + (useBtn.y + useBtn.height / 2)
                TriggerGuideLogic:SetGuideScale({0.65, 0.65})
                TriggerGuideLogic:SetGuidePos({posX + 5, posY - 2})
                TriggerGuideLogic.StepFunc = function()
                    --Log.Error("Strong Guide -----------------------1012")
                    TriggerGuideLogic.guideIsBegin = true
                    TriggerGuideLogic.SetNoviceOnCall()
                    useBtn.onClick:Call()
                    TriggerGuideLogic.guideIsBegin = false
                end
            end
        )
    end,
    --关闭道具使用弹窗
    [1013] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local backpackPopup = UIMgr:GetUI("BackpackPopup")
                local btnClose = backpackPopup._btnClose
                local posX, posY = btnClose.x, btnClose.y
                TriggerGuideLogic:SetGuideScale({0.65, 0.65})
                TriggerGuideLogic:SetGuidePos({posX + btnClose.width / 2, posY + btnClose.height / 2})
                TriggerGuideLogic.StepFunc = function()
                    --Log.Error("Strong Guide -----------------------1013")
                    TriggerGuideLogic.SetNoviceOnCall()
                    local backPack = UIMgr:GetUI("Backpack")
                    backPack:SetScrollTouchEffect(true)
                    UIMgr:Close("BackpackPopup")
                end
            end,
            "BackpackPopup"
        )
    end,
    --强引退出背包
    [1014] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                if UIMgr:GetUIOpen("BackpackPopup") then
                    UIMgr:Close("BackpackPopup")
                end
                local backPackUI = UIMgr:GetUI("Backpack")
                if not backPackUI then
                    --解决新手引导 进游戏走退出背包流程卡死问题
                    TurnModel.GoBackpackStore(false, 2)
                    backPackUI = UIMgr:GetUI("Backpack")
                end
                local returnBtn = backPackUI._btnReturn
                local posX = returnBtn.x + returnBtn.width / 2
                local posY = returnBtn.y + returnBtn.height / 2
                TriggerGuideLogic:SetGuideScale({0.7, 0.7})
                TriggerGuideLogic:SetGuidePos({posX - 10, posY})
                TriggerGuideLogic.StepFunc = function()
                    --Log.Error("Strong Guide -----------------------1014")
                    TriggerGuideLogic.SetNoviceOnCall()
                    UIMgr:Close("Backpack")
                end
            end
        )
    end,
    --点击剧情任务领取
    [1015] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local taskPanel = UIMgr:GetUI("TaskPlot")
                local taskItem = UIMgr:GetUI("TaskPlot").Controller.contentPane:GetChild("TaskPlotItem")
                local list = taskItem:GetChild("liebiaoPlot")
                local taskPlotItemBtn = list:GetChildAt(0)
                local btnVector = list:GetChildAt(0):LocalToRoot(list:GetChildAt(0)._btnGo.xy)
                local offsetX = 50
                local offsetY = 40
                if MathUtil.HaveMatch() then
                    offsetX = offsetX * 0.75
                    offsetY = offsetY * 0.75
                end
                local pos = {btnVector.x + offsetX, btnVector.y + offsetY}
                TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                TriggerGuideLogic:SetGuidePos(pos)
                TriggerGuideLogic.StepFunc = function()
                    --Log.Error("Strong Guide -----------------------1015")
                    TriggerGuideLogic.SetNoviceOnCall()
                    -- taskPlotItemBtn._btnReceive.onClick:Call()
                    taskPlotItemBtn:OnBtnClick(true)
                    Event.Broadcast(EventDefines.NextNoviceStep, 1015)
                    Event.Broadcast(EventDefines.TaskPlotGotoGuide, 5401002)
                end
            end,
            "TaskPlot"
        )
    end,
    [1016] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                isHiddenClipMask = true
                local mainPanel = UIMgr:GetUI("MainUIPanel")
                local pos = {mainPanel._bgTipsBar.x + 150, mainPanel._bgTipsBar.y + 50}
                local taskBtn = mainPanel._bgTipsBar
                TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                TriggerGuideLogic:SetGuidePos(pos)
                TriggerGuideLogic.StepFunc = function()
                    --Log.Error("Strong Guide -----------------------1004")
                    TriggerGuideLogic.SetNoviceOnCall()
                    taskBtn.onClick:Call()
                end
            end
        )
    end,
    --背包
    [11002] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.MainUITouchEvent, false, "_btnBackpack")
        local mainPanel = UIMgr:GetUI("MainUIPanel")
        local backpackBtnX = mainPanel.down.x + mainPanel._btnBackpack.x
        local backpackBtnY = mainPanel.down.y + mainPanel._btnBackpack.y
        local pos = {backpackBtnX + 5, backpackBtnY + 5}
        local guideLayer = UIMgr:GetUI("GuideLayer")
        guideLayer._guide:SetTopAnim(true)
        TriggerGuideLogic:SetGuideScale({0.6, 0.6})
        TriggerGuideLogic:SetGuidePos(pos)
        TriggerGuideLogic:SetBtnClick(mainPanel)
        local itemData = GD.ItemAgent.GetItemModelById(200512)
        if not itemData then
            Log.Error("11002引导，没有物品退出引导")
            TriggerGuideLogic:ClearTriggerGuide()
            return
        end
    end,
    --指引礼包物品
    [11003] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                --TODO暂时写死
                local giftId = 200512
                local backPack = UIMgr:GetUI("Backpack")
                backPack:ScrollToViewItem(giftId)
                local itemEntity = GD.ItemAgent.GetItemPane(giftId)
                if not itemEntity then
                    Log.Error("11003引导，没有下拉框退出引导")
                    TriggerGuideLogic:ClearTriggerGuide()
                end
                local listItem = itemEntity.uiParent
                local listPosY = backPack:GetGuidePosByItem(listItem)
                Scheduler.ScheduleOnceFast(
                    function()
                        backPack:SetScrollTouchEffect(false)
                        local itemPosX = backPack._list.x + (itemEntity.width / 2 + itemEntity.x)
                        local itemPosY = backPack._list.y + (itemEntity.height / 2 + listPosY)
                        local guideLayer = UIMgr:GetUI("GuideLayer")
                        guideLayer._guide:SetTopAnim(false)
                        TriggerGuideLogic:SetGuideScale({0.7, 0.7})
                        TriggerGuideLogic:SetGuidePos({itemPosX + 13, itemPosY + 6})
                        TriggerGuideLogic:SetBtnClick(itemEntity)
                    end,
                    0.5
                )
            end,
            "Backpack"
        )
    end,
    --指引礼包使用
    [11004] = function()
        Log.Warning("================11004礼包使用")
        local usePanel = GD.ItemAgent.GetItemBoxPane()
        local backPack = UIMgr:GetUI("Backpack")
        local useBtn = usePanel._btnUse
        local posX = backPack._list.x + usePanel.x + (useBtn.x + useBtn.width / 2)
        local posY = backPack._list.y + usePanel.y + (useBtn.y + useBtn.height / 2)
        TriggerGuideLogic:SetGuideScale({0.65, 0.65})
        TriggerGuideLogic:SetGuidePos({posX + 5, posY - 2})
        TriggerGuideLogic:SetBtnClick(usePanel)
    end,
    --隐藏引导页
    [11005] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                isHiddenClipMask = true
                Event.Broadcast(EventDefines.TriggerGuideShow, false)
                local backPackPopup = UIMgr:GetUI("BackpackPopup")
                TriggerGuideLogic:SetBtnClick(backPackPopup)
            end,
            "BackpackPopup"
        )
    end,
    --指引退出
    [11006] = function()
        Event.Broadcast(EventDefines.TriggerGuideShow, true)
        local backPackUI = UIMgr:GetUI("Backpack")
        backPackUI:SetScrollTouchEffect(true)
        local returnBtn = backPackUI._btnReturn
        local posX = returnBtn.x + returnBtn.width / 2
        local posY = returnBtn.y + returnBtn.height / 2
        TriggerGuideLogic:SetGuideScale({0.7, 0.7})
        TriggerGuideLogic:SetGuidePos({posX - 10, posY})
        TriggerGuideLogic.btnEntity = backPackUI
        TriggerGuideLogic.triggerGuideEnd = true
        backPackUI:SetScrollTouchEffect(true)
        TriggerGuideLogic:SetBtnClick(backPackUI)
    end,
    --研究科技指引建筑
    [11102] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        local dis = {0, -100}
        local scale = {1.3, 1}
        local cityFunction = CityMapModel.GetCityContext()._itemDetail
        local compVisible = cityFunction:GetFuncVisible()
        if compVisible then
            cityFunction:OffAnim(false)
        end
        TriggerGuideLogic:SetMoveCallBack(Global.BuildingScience, dis, scale, GuideCreatType.Upgrade)
    end,
    --指引投资菜单
    [11103] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.DelayMask, true)
        TriggerGuideLogic:SetScheduler(
            function()
                Event.Broadcast(EventDefines.DelayMask, false)
                TriggerGuideLogic:SetItemCityFunction("Research")
            end
        )
    end,
    --指引科技主界面选项
    [11104] = function(params)
        TriggerGuideLogic:SetScheduler(
            function()
                local techId = params
                local laboratory = UIMgr:GetUI("Laboratory")
                local btn = laboratory:TriggerGuideBtn(techId)
                local posx, posy = btn.x, btn.y + 85
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(btn)
            end,
            "Laboratory"
        )
    end,
    --指引科技图标
    [11105] = function(params)
        TriggerGuideLogic:SetScheduler(
            function()
                local techId = params
                local laboratorySkill = UIMgr:GetUI("LaboratorySkill")
                local item = laboratorySkill:GetSkillItemByConfid(techId)
                local posx, posy = laboratorySkill._list.x + item.x, laboratorySkill._list.y + (item.y - 25)
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(item)
            end,
            "LaboratorySkill"
        )
    end,
    --指引科技确定投资
    [11106] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local laboratorySkill = UIMgr:GetUI("LaboratorySkill")
                laboratorySkill._list.scrollPane.touchEffect = true
                local laboratoryPopup = UIMgr:GetUI("LaboratoryPopup")
                local posx, posy = laboratoryPopup._btnYellow.x + laboratoryPopup._btnYellow.width / 2, laboratoryPopup._btnYellow.y + laboratoryPopup._btnYellow.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(laboratoryPopup)
            end,
            "LaboratoryPopup"
        )
    end,
    --指引科技退出
    [11107] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic.triggerGuideEnd = true
                local laboratorySkill = UIMgr:GetUI("LaboratorySkill")
                local posx, posy = laboratorySkill._btnReturn.x + laboratorySkill._btnReturn.width / 2, laboratorySkill._btnReturn.y + laboratorySkill._btnReturn.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                UIMgr:Close("Laboratory")
                TriggerGuideLogic:SetBtnClick(laboratorySkill)
            end
        )
    end,
    --日常任务指引
    [12902] = function(params)
        local dailyTask = nil
        local dailyTop = nil
        local pos = nil
        local windowStr
        if UIMgr:GetUIOpen("TaskMain") then
            dailyTask = UIMgr:GetUI("TaskMain")
            dailyTop = dailyTask._dailyTask:GetChild("bannerDaily")
            pos = dailyTask.Controller.contentPane:GlobalToLocal(dailyTop:LocalToGlobal(Vector2.zero))
            windowStr = "TaskMain"
        elseif UIMgr:GetUIOpen("WelfareMain") then
            dailyTask = WelfareModel:GetWelfarePageTable(WelfareModel.WelfarePageType.DAILYTASK_ACTIVITY)
            dailyTop = dailyTask._dailyTasklogic:GetChild("bannerDaily")
            pos = dailyTask:GlobalToLocal(dailyTop:LocalToGlobal(Vector2.zero))
            windowStr = "WelfareMain"
        end
        TriggerGuideLogic:SetScheduler(
            function()
                if not pos then
                    TriggerGuideLogic:ClearTriggerGuide()
                    return
                end
                local posx = pos.x
                local posy = pos.y
                TriggerGuideLogic:SetGuideScale({3.5, 1.5}, {0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posx + dailyTop.width / 2, posy + dailyTop.height / 2}, true)
                TriggerGuideLogic:SetGuideMaskSize(Vector2(dailyTop.width, dailyTop.height))
                TriggerGuideLogic:SetGuideBox({posx, posy}, {dailyTop.width, dailyTop.height})
                TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
            end,
            windowStr
        )
    end,
    --日常任务单选指引
    [12903] = function()
        local dailyTask = nil
        local dailyList = nil
        local pos = nil
        local windowStr
        if UIMgr:GetUIOpen("TaskMain") then
            dailyTask = UIMgr:GetUI("TaskMain")
            dailyList = dailyTask._dailyTask:GetChild("liebiaoDaily")
            pos = dailyTask.Controller.contentPane:GlobalToLocal(dailyList:LocalToGlobal(Vector2.zero))
            windowStr = "TaskMain"
        elseif UIMgr:GetUIOpen("WelfareMain") then
            dailyTask = WelfareModel:GetWelfarePageTable(WelfareModel.WelfarePageType.DAILYTASK_ACTIVITY)
            dailyList = dailyTask._dailyTasklogic:GetChild("liebiaoDaily")
            pos = dailyTask:GlobalToLocal(dailyList:LocalToGlobal(Vector2.zero))
            windowStr = "WelfareMain"
        end
        TriggerGuideLogic:SetScheduler(
            function()
                local listItem = nil
                if dailyList.numChildren >= 6 then
                    listItem = dailyList:GetChildAt(4)
                else
                    listItem = dailyList:GetChildAt(0)
                end
                if not pos then
                    TriggerGuideLogic:ClearTriggerGuide()
                    return
                end
                local posx, posy = (pos.x + listItem.x + listItem.width / 2), (pos.y + listItem.y + listItem.height / 2)
                TriggerGuideLogic:SetGuideScale({3.3, 4}, {0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetGuideMaskSize(Vector2(dailyList.width, dailyList.height))
                TriggerGuideLogic:SetGuideBox({pos.x, pos.y}, {dailyList.width, dailyList.height})
                TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
            end,
            windowStr
        )
    end,
    --日常任务退出
    [12904] = function()
        local TaskMainWindow
        local windowStr
        if UIMgr:GetUIOpen("TaskMain") then
            TaskMainWindow = UIMgr:GetUI("TaskMain")
            windowStr = "TaskMain"
        elseif UIMgr:GetUIOpen("WelfareMain") then
            TaskMainWindow = UIMgr:GetUI("WelfareMain")
            windowStr = "WelfareMain"
        end
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic.triggerGuideEnd = true
                local posx, posy = TaskMainWindow._btnReturn.x + TaskMainWindow._btnReturn.width / 2, TaskMainWindow._btnReturn.y + TaskMainWindow._btnReturn.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(TaskMainWindow)
            end,
            windowStr
        )
    end,
    --vip
    [11202] = function()
        --默认使用vip道具
        Event.Broadcast(EventDefines.MainUITouchEvent, false, "_btnVip")
        local item = GD.ItemAgent.GetItemModelById(200120)
        if item then
            GD.ItemAgent.UseItem(200120)
        end
        Event.Broadcast(EventDefines.DelayMask, true)
        TriggerGuideLogic:SetScheduler(
            function()
                Event.Broadcast(EventDefines.DelayMask, false)
                isHiddenClipMask = true
                local buildCenter = BuildModel.GetCenter(Global.BuildingCenter)
                local itemBuild = BuildModel.GetObject(buildCenter.Id)
                if itemBuild._playFree then
                    local isOk = JumpMapModel:GuideStage() and JumpMapModel:GetJumpId() == 813300
                    if isOk then
                        return
                    else
                        local completeBtn = itemBuild:GetBtnComplete():GetCutBtn()
                        local building = BuildModel.GetCenter(Global.BuildingCenter)
                        JumpMapModel:SetBuildId(building)
                        JumpMap:JumpSimple(813300, building, nil, completeBtn)
                    end
                end
                --TODO暂时取消主城位置还原
                -- TurnModel.BuildCenter(true, true, cb)
                TriggerGuideLogic:ClearTriggerGuide()
            end
        )
    end,
    [11304] = function()
        isHiddenClipMask = true
        TriggerGuideLogic.triggerGuideEnd = true
        TriggerGuideLogic:CloseTriggerGuide()
        JumpMap:JumpSimple(812500)
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    --  建筑加速
    [11402] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        local itemData = GD.ItemAgent.GetItemModelById(202017)
        if not itemData then
            TriggerGuideLogic:CloseTriggerGuide()
        end
        local dis = {100, -270}
        local scale = {1.3, 1}
        local cityFunction = CityMapModel.GetCityContext()._itemDetail
        local compVisible = cityFunction:GetFuncVisible()
        if compVisible then
            cityFunction:OffAnim(false)
        end
        TriggerGuideLogic:SetMoveCallBack(Global.BuildingCenter, dis, scale, GuideCreatType.Upgrade)
    end,
    --加速菜单
    [11403] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic:SetItemCityFunction("Speed")
            end
        )
    end,
    --加速界面按钮
    [11404] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local accelerateUI = UIMgr:GetUI("BuildAcceleratePopup")
                local posX, posY = accelerateUI._btnUse.x + accelerateUI._btnUse.width / 2, accelerateUI._btnUse.y + accelerateUI._btnUse.height / 2
                TriggerGuideLogic:SetGuideScale({0.6, 0.6}, {0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posX + 18, posY + 7})
                TriggerGuideLogic:SetBtnClick(accelerateUI)
            end,
            "BuildAcceleratePopup"
        )
    end,
    --退出按钮
    [11405] = function()
        UIMgr:Close("ConfirmPopup")
        UIMgr:Close("BuildAcceleratePopup")
        TriggerGuideLogic:CloseTriggerGuide()
        TriggerGuideLogic:SetTriggerNextStep()
        -- local accelerateUI = UIMgr:GetUI("BuildAcceleratePopup")
        -- TriggerGuideLogic:SetBtnClick(accelerateUI)
    end,
    --新手改名
    [13102] = function()
        TriggerGuideLogic:CloseTriggerGuide()
        TurnModel.PlayerRename()
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    --建筑队列
    [11602] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        TriggerGuideLogic:SetScheduler(
            function()
                local sideBar = UIMgr:GetUI("SidebarRelated/Sidebar")
                local posX, posY = sideBar._btnArrow.x + sideBar._btnArrow.width / 2, sideBar._btnArrow.y + sideBar._btnArrow.height / 2
                local guideLayer = UIMgr:GetUI("GuideLayer")
                TriggerGuideLogic.triggerGuideEnd = true
                TriggerGuideLogic:SetGuideScale({0.45, 0.45})
                TriggerGuideLogic:SetGuidePos({posX - 10, posY})
                guideLayer:SetTip(true)
                TriggerGuideLogic:SetBtnClick(sideBar)
            end,
            "SidebarRelated/Sidebar"
        )
    end,
    --技能说明返回主界面
    [11702] = function()
        Event.Broadcast(EventDefines.DelayMask, true)
        TriggerGuideLogic:SetScheduler(
            function()
                Event.Broadcast(EventDefines.DelayMask, false)
                local PlayerDetailsWindow = UIMgr:GetUI("PlayerDetails")
                local posX, posY = PlayerDetailsWindow._btnReturn.x + PlayerDetailsWindow._btnReturn.width / 2, PlayerDetailsWindow._btnReturn.y + PlayerDetailsWindow._btnReturn.height / 2
                TriggerGuideLogic:SetGuideScale({0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posX, posY})
                TriggerGuideLogic:SetBtnClick(PlayerDetailsWindow)
            end,
            "PlayerDetails"
        )
    end,
    --指引主动技能按钮
    [11704] = function()
        TriggerGuideLogic.triggerGuideEnd = true
        Event.Broadcast(EventDefines.MainUITouchEvent, false, "btnSkill")
        local mainUI = UIMgr:GetUI("MainUIPanel")
        local posX, posY = mainUI._btnSkill.x + mainUI._btnSkill.width / 2, mainUI._btnSkill.y + mainUI._btnSkill.height / 2
        TriggerGuideLogic:SetGuideScale({0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posX, posY})
        TriggerGuideLogic:SetBtnClick(mainUI._btnSkill)
    end,
    --单个主动技能
    [11706] = function()
        UIMgr:GetUI("UIMaskManager"):SetClose(true)
        -- UIMgr:Close("UIMaskManager")
        TriggerGuideLogic.CloseMaskUI()
        Scheduler.ScheduleOnceFast(
            function()
                local mainActive = UIMgr:GetUI("MainActiveSkills")
                --获得主动技能Item通过激活状态
                local skillItem = mainActive:GetItemByIsActivity()
                if not skillItem then
                    return
                end
                --保证最层级上级
                UIMgr:Open("UIMaskManager")
                TriggerGuideLogic:SetGuideScale({0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({mainActive._list.x + skillItem.x + skillItem.width / 2, mainActive._list.y + skillItem.y + skillItem.height / 2})
                TriggerGuideLogic:SetBtnClick(skillItem)
            end,
            0.5
        )
    end,
    --主动技能使用
    [11708] = function()
        local mainActviteUI = UIMgr:GetUI("MainActiveSkills")
        mainActviteUI._list.scrollPane:ScrollLeft()
        local posX, posY = mainActviteUI._topbtnUse.x + mainActviteUI._topbtnUse.width / 2, mainActviteUI._topbtnUse.y + mainActviteUI._topbtnUse.height / 2
        TriggerGuideLogic:SetGuideScale({3.2, 2.5}, {0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posX, posY - 140})
        local bgImage = mainActviteUI._bgPopup
        TriggerGuideLogic:SetGuideBox({bgImage.x, bgImage.y - 25}, {bgImage.width, bgImage.height + 25})
        TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
    end,
    --主动技能使用退出
    [11709] = function()
        TriggerGuideLogic:ClearTriggerGuide()
        TriggerGuideLogic:SetTriggerNextStep()
        UIMgr:Close("MainActiveSkills")
    end,
    --哥斯拉在线
    [11803] = function()
        isHiddenClipMask = true
        TriggerGuideLogic.triggerGuideEnd = true
        TriggerGuideLogic:ClearTriggerGuide()
        JumpMap:JumpSimple(812700)
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    --特价商城
    [11902] = function()
        TriggerGuideLogic:SetMoveCallBack(Global.BuildingSpecialMall, {80, -90}, {0.7, 0.5}, GuideCreatType.Upgrade)
        TriggerGuideLogic.triggerGuideEnd = true
    end,
    --任务主界面入口图标
    [12002] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.MainUITouchEvent, false, "_btnTask")
        local mainPanel = UIMgr:GetUI("MainUIPanel")
        local posx = mainPanel.down.x + mainPanel._btnTask.x
        local posy = mainPanel.down.y + mainPanel._btnTask.y
        local pos = {posx, posy}
        TriggerGuideLogic:SetGuideScale({0.4, 0.4})
        TriggerGuideLogic:SetGuidePos(pos)
        TriggerGuideLogic:SetBtnClick(mainPanel)
    end,
    --任务指引框
    [12004] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local taskMain = UIMgr:GetUI("TaskMain")
                local taskMainList = taskMain._listOrd
                local taskMainTagBg = taskMain._view:GetChild("bgTagBox2")
                local width, height = taskMainTagBg.width, taskMainTagBg.height + taskMainList.height
                local posx, posy = taskMainTagBg.x, taskMainTagBg.y
                TriggerGuideLogic:SetGuideScale({3.4, 3.2}, {0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posx + taskMainList.width / 2, posy + taskMainList.height / 2}, true)
                TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
                TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
                TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
            end,
            "TaskMain"
        )
    end,
    --普通任务框
    [12006] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local TaskMain = UIMgr:GetUI("TaskMain")
                local taskMainTopBg = TaskMain._view:GetChild("_bannerMain")
                local posx, posy = taskMainTopBg.x, taskMainTopBg.y
                local width, height = taskMainTopBg.width, taskMainTopBg.height
                TriggerGuideLogic:SetGuideScale({3, 1.5}, {0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
                TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
                TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
                TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
            end
        )
    end,
    --任务退出
    [12007] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local TaskMainWindow = UIMgr:GetUI("TaskMain")
                local posx, posy = TaskMainWindow._btnReturn.x + TaskMainWindow._btnReturn.width / 2, TaskMainWindow._btnReturn.y + TaskMainWindow._btnReturn.height / 2
                TriggerGuideLogic.triggerGuideEnd = true
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(TaskMainWindow)
            end
        )
    end,
    --首次加入联盟
    [12103] = function(params)
        TriggerGuideLogic:SetScheduler(
            function()
                isHiddenClipMask = true
                local unionMain = UIMgr:GetUI("UnionMain/UnionMain")
                local posx, posy = unionMain._unionInfo.x, unionMain._unionInfo.y
                local width, height = unionMain._unionInfo.width, unionMain._unionInfo.height
                TriggerGuideLogic:SetGuideScale({1, 1}, {0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
                TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
                TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
                TriggerGuideLogic.SetTipPos({posx, posy + height}, false, params)
                --关闭遮罩
                TriggerGuideLogic.maskGuide:SetGuideMaskClose()
                TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
            end,
            "UnionMain/UnionMain"
        )
    end,
    --联盟列表内容
    [12104] = function(params)
        isHiddenClipMask = true
        local unionMain = UIMgr:GetUI("UnionMain/UnionMain")
        local posx, posy = unionMain._unionList.x, unionMain._unionList.y
        local width, height = unionMain._unionList.width, unionMain._unionList.height
        TriggerGuideLogic:SetGuideScale({1, 1}, {0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
        TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
        TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
        TriggerGuideLogic.SetTipPos({posx, posy}, true, params)
        TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
    end,
    --联盟成员
    [12105] = function(params)
        isHiddenClipMask = true
        local unionMain = UIMgr:GetUI("UnionMain/UnionMain")
        local posx, posy = unionMain._tagDown.x, unionMain._tagDown.y
        local width, height = unionMain._tagDown.width, unionMain._tagDown.height
        TriggerGuideLogic:SetGuideScale({1, 1}, {0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
        TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
        TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
        TriggerGuideLogic.SetTipPos({posx, posy}, true, params)
        TriggerGuideLogic.triggerGuideEnd = true
        TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
    end,
    [12106] = function()
        TriggerGuideLogic:CloseTriggerGuide()
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    [15303] = function(params)
        TriggerGuideLogic:SetScheduler(
            function()
                isHiddenClipMask = true
                local unionMain = UIMgr:GetUI("UnionMain/UnionMain")
                local posx, posy = unionMain._unionInfo.x, unionMain._unionInfo.y
                local width, height = unionMain._unionInfo.width, unionMain._unionInfo.height
                TriggerGuideLogic:SetGuideScale({1, 1}, {0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
                TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
                TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
                TriggerGuideLogic.SetTipPos({posx, posy + height}, false, params)
                --关闭遮罩
                TriggerGuideLogic.maskGuide:SetGuideMaskClose()
                TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
            end,
            "UnionMain/UnionMain"
        )
    end,
    --联盟列表内容
    [15304] = function(params)
        isHiddenClipMask = true
        local unionMain = UIMgr:GetUI("UnionMain/UnionMain")
        local posx, posy = unionMain._unionList.x, unionMain._unionList.y
        local width, height = unionMain._unionList.width, unionMain._unionList.height
        TriggerGuideLogic:SetGuideScale({1, 1}, {0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
        TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
        TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
        TriggerGuideLogic.SetTipPos({posx, posy}, true, params)
        TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
    end,
    --联盟成员
    [15305] = function(params)
        isHiddenClipMask = true
        local unionMain = UIMgr:GetUI("UnionMain/UnionMain")
        local posx, posy = unionMain._tagDown.x, unionMain._tagDown.y
        local width, height = unionMain._tagDown.width, unionMain._tagDown.height
        TriggerGuideLogic:SetGuideScale({1, 1}, {0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
        TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
        TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
        TriggerGuideLogic.SetTipPos({posx, posy}, true, params)
        TriggerGuideLogic.triggerGuideEnd = true
        TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
    end,
    [15306] = function()
        TriggerGuideLogic:CloseTriggerGuide()
        local step = TriggerGuideLogic.noviceID % 100
        Event.Broadcast(EventDefines.TriggerGuideNextStep, TriggerGuideLogic.noviceID - step, 9)
    end,
    [15403] = function(params)
        TriggerGuideLogic:SetScheduler(
            function()
                isHiddenClipMask = true
                local unionMain = UIMgr:GetUI("UnionMain/UnionMain")
                local posx, posy = unionMain._unionInfo.x, unionMain._unionInfo.y
                local width, height = unionMain._unionInfo.width, unionMain._unionInfo.height
                TriggerGuideLogic:SetGuideScale({1, 1}, {0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
                TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
                TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
                TriggerGuideLogic.SetTipPos({posx, posy + height}, false, params)
                --关闭遮罩
                TriggerGuideLogic.maskGuide:SetGuideMaskClose()
                TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
            end,
            "UnionMain/UnionMain"
        )
    end,
    --联盟列表内容
    [15404] = function(params)
        isHiddenClipMask = true
        local unionMain = UIMgr:GetUI("UnionMain/UnionMain")
        local posx, posy = unionMain._unionList.x, unionMain._unionList.y
        local width, height = unionMain._unionList.width, unionMain._unionList.height
        TriggerGuideLogic:SetGuideScale({1, 1}, {0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
        TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
        TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
        TriggerGuideLogic.SetTipPos({posx, posy}, true, params)
        TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
    end,
    --联盟成员
    [15405] = function(params)
        isHiddenClipMask = true
        local unionMain = UIMgr:GetUI("UnionMain/UnionMain")
        local posx, posy = unionMain._tagDown.x, unionMain._tagDown.y
        local width, height = unionMain._tagDown.width, unionMain._tagDown.height
        TriggerGuideLogic:SetGuideScale({1, 1}, {0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
        TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
        TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
        TriggerGuideLogic.SetTipPos({posx, posy}, true, params)
        TriggerGuideLogic.triggerGuideEnd = true
        TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
    end,
    [15406] = function()
        TriggerGuideLogic:CloseTriggerGuide()
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    -- 地图指引
    [12201] = function(params)
        UIMgr:Open("CollectionInstructions", nil, 1007)
        TriggerGuideLogic:CloseTriggerGuide()
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    [12301] = function(params)
        UIMgr:Open("CollectionInstructions", params)
        TriggerGuideLogic:CloseTriggerGuide()
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    [13301] = function(params)
        UIMgr:Open("CollectionInstructions", params)
        TriggerGuideLogic:CloseTriggerGuide()
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    [13401] = function(params)
        UIMgr:Open("CollectionInstructions", params)
        TriggerGuideLogic:CloseTriggerGuide()
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    [13501] = function(params)
        UIMgr:Open("CollectionInstructions", params)
        TriggerGuideLogic:CloseTriggerGuide()
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    [13601] = function(params)
        UIMgr:Open("CollectionInstructions", params)
        TriggerGuideLogic:CloseTriggerGuide()
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    [12401] = function(params)
        UIMgr:Open("CollectionInstructions", nil, 1008)
        TriggerGuideLogic:CloseTriggerGuide()
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    --防御武器建筑建造
    [12502] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        if BuildModel.CheckExist(Global.BuildingSecurityFactory) then
            TriggerGuideLogic:ClearTriggerGuide()
            return
        end
        local dis = {0, 0}
        local scale = {1.3, 1}
        TriggerGuideLogic:SetMoveCallBack(Global.BuildingSecurityFactory, dis, scale, GuideCreatType.Creat)
    end,
    --防御武器创建页面
    [12503] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic:SetBuildCreateUI(Global.BuildingSecurityFactory)
            end,
            "BuildRelated/BuildCreate"
        )
    end,
    --防御武器升级
    [12504] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local buildUpgrade = UIMgr:GetUI("BuildRelated/BuildUpgrade")
                local buildUI = buildUpgrade._btnR
                local posx, posy = buildUpgrade._bgDown.x + buildUI.x + buildUI.width / 2, buildUpgrade._bgDown.y + buildUI.y + buildUI.height / 2
                local guideLayer = UIMgr:GetUI("GuideLayer")
                guideLayer._guide:SetTopAnim(true)
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                local cityFunction = CityMapModel.GetCityContext()._itemDetail
                local compVisible = cityFunction:GetFuncVisible()
                if compVisible then
                    cityFunction:OffAnim(false)
                end
                TriggerGuideLogic:SetBtnClick(buildUpgrade)
            end,
            "BuildRelated/BuildUpgrade"
        )
    end,
    --防御武器制造菜单
    [12506] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.DelayMask, true)
        local bIdbId = BuildModel.GetObjectByConfid(Global.BuildingSecurityFactory)
        local buildNode = BuildModel.GetObject(bIdbId)
        if not buildNode then
            TriggerGuideLogic.triggerGuideEnd = true
            Log.Error("12506引导，没有防御武器工厂退出引导")
            TriggerGuideLogic:ClearTriggerGuide()
        else
            local function cb()
                TriggerGuideLogic.triggerGuideEnd = true
                TriggerGuideLogic:SetScheduler(
                    function()
                        Event.Broadcast(EventDefines.DelayMask, false)
                        TriggerGuideLogic:SetItemCityFunction("Produce")
                    end
                )
            end

            Scheduler.ScheduleOnceFast(
                function()
                    buildNode:BuildClick()
                    cb()
                end,
                0.5
            )
        end
    end,
    --武器制造
    [12507] = function()
        TriggerGuideLogic:ClearTriggerGuide()
        TriggerGuideLogic:SetScheduler(
            function()
                Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BuildTrainUI)
            end,
            "BuildRelated/BuildTrain"
        )
    end,
    --伤兵治疗
    [12602] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        local cityFunction = CityMapModel.GetCityContext()._itemDetail
        local compVisible = cityFunction:GetFuncVisible()
        if compVisible then
            cityFunction:OffAnim(false)
        end
        TriggerGuideLogic:SetMoveCallBack(Global.BuildingHospital, {0, -50}, {0.8, 0.8}, GuideCreatType.Upgrade)
    end,
    --治疗菜单
    [12603] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.DelayMask, true)
        TriggerGuideLogic:SetScheduler(
            function()
                Event.Broadcast(EventDefines.DelayMask, false)
                TriggerGuideLogic:SetItemCityFunction("Cure")
            end
        )
    end,
    --治疗按钮
    [12605] = function()
        isHiddenClipMask = true
        TriggerGuideLogic:CloseTriggerGuide()
        TriggerGuideLogic:SetScheduler(
            function()
                Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.CureArmyUI)
                TriggerGuideLogic:SetTriggerNextStep()
            end,
            "CureRelated/CureArmy"
        )
    end,
    --技能添加主界面入口
    [11502] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.MainUITouchEvent, false, "mainHead")
        local mainUI = UIMgr:GetUI("MainUIPanel")
        local posx, posy = mainUI._mainTop.x, mainUI._mainTop.y
        local mainUIHead = mainUI._mainTop:GetChild("mainHead")
        TriggerGuideLogic:SetGuideScale({0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posx + mainUIHead.width / 2, posy + mainUIHead.height / 2})
        TriggerGuideLogic:SetBtnClick(mainUIHead)
    end,
    --设置页技能图标
    [11503] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local playerDetailsUI = UIMgr:GetUI("PlayerDetails")
                local posx, posy = playerDetailsUI._btnSkill.x + playerDetailsUI._btnSkill.width / 2, playerDetailsUI._btnSkill.y + playerDetailsUI._btnSkill.height / 2
                TriggerGuideLogic:SetGuideScale({0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(playerDetailsUI)
            end,
            "PlayerDetails"
        )
    end,
    --技能页选项图标
    [11506] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local skillUI = UIMgr:GetUI("PlayerSkill")
                local posx, posy = skillUI._btnProgress.x + skillUI._btnProgress.width / 2, skillUI._btnProgress.y + skillUI._btnProgress.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(skillUI)
            end,
            "PlayerSkill"
        )
    end,
    --选中相对应的技能图标
    [11508] = function()
        local skillUI = UIMgr:GetUI("PlayerSkill")
        local listView = skillUI._list
        listView.scrollPane.touchEffect = false
        local item = skillUI:GetItemByConfid(623100)
        local posx, posy = listView.x + item.x + (item.width / 2), listView.y + item.y + item.height / 2
        TriggerGuideLogic:SetGuideScale({1, 1})
        TriggerGuideLogic:SetGuidePos({posx, posy})
        TriggerGuideLogic:SetBtnClick(item)
    end,
    --技能学习弱引导
    [11509] = function()
        local skillUI = UIMgr:GetUI("PlayerSkill")
        local listView = skillUI._list
        listView.scrollPane.touchEffect = true
        -- isHiddenClipMask = true
        TriggerGuideLogic:SetScheduler(
            function()
                local skillPopup = UIMgr:GetUI("PlayerSkillPopup")
                local posx, posy = skillPopup._btnAllLearning.x + skillPopup._btnAllLearning.width / 2, skillPopup._btnAllLearning.y + skillPopup._btnAllLearning.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(skillPopup)
            end,
            "PlayerSkillPopup"
        )
    end,
    [11510] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic.triggerGuideEnd = true
                local PlayerDetailsWindow = UIMgr:GetUI("PlayerDetails")
                local posx, posy = PlayerDetailsWindow._btnReturn.x + PlayerDetailsWindow._btnReturn.width / 2, PlayerDetailsWindow._btnReturn.y + PlayerDetailsWindow._btnReturn.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(PlayerDetailsWindow)
            end,
            "PlayerDetails"
        )
    end,
    --技能页选项图标
    [13203] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local skillUI = UIMgr:GetUI("PlayerSkill")
                local posx, posy = skillUI._btnProgress.x + skillUI._btnProgress.width / 2, skillUI._btnProgress.y + skillUI._btnProgress.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(skillUI)
            end,
            "PlayerSkill"
        )
    end,
    --选中相对应的技能图标
    [13205] = function()
        local skillUI = UIMgr:GetUI("PlayerSkill")
        local listView = skillUI._list
        -- listView.toun
        listView.scrollPane.touchEffect = false
        local item = skillUI:GetItemByConfid(623100)
        local posx, posy = listView.x + item.x + (item.width / 2), listView.y + item.y + item.height / 2
        TriggerGuideLogic:SetGuideScale({1, 1})
        TriggerGuideLogic:SetGuidePos({posx, posy})
        TriggerGuideLogic:SetBtnClick(item)
    end,
    --技能学习弱引导
    [13206] = function()
        local skillUI = UIMgr:GetUI("PlayerSkill")
        local listView = skillUI._list
        listView.scrollPane.touchEffect = true
        --isHiddenClipMask = true
        TriggerGuideLogic:SetScheduler(
            function()
                local skillPopup = UIMgr:GetUI("PlayerSkillPopup")
                local posx, posy = skillPopup._btnAllLearning.x + skillPopup._btnAllLearning.width / 2, skillPopup._btnAllLearning.y + skillPopup._btnAllLearning.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(skillPopup)
            end,
            "PlayerSkillPopup"
        )
    end,
    [13207] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic.triggerGuideEnd = true
                local PlayerDetailsWindow = UIMgr:GetUI("PlayerDetails")
                local posx, posy = PlayerDetailsWindow._btnReturn.x + PlayerDetailsWindow._btnReturn.width / 2, PlayerDetailsWindow._btnReturn.y + PlayerDetailsWindow._btnReturn.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(PlayerDetailsWindow)
            end,
            "PlayerDetails"
        )
    end,
    --账号绑定
    [12802] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.MainUITouchEvent, false, "mainHead")
        local mainUI = UIMgr:GetUI("MainUIPanel")
        local posx, posy = mainUI._mainTop.x, mainUI._mainTop.y
        local mainUIHead = mainUI._mainTop:GetChild("mainHead")
        TriggerGuideLogic:SetGuideScale({0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posx + mainUIHead.width / 2, posy + mainUIHead.height / 2})
        TriggerGuideLogic:SetBtnClick(mainUIHead)
    end,
    --指定设定按钮
    [12803] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local playerDetailsUI = UIMgr:GetUI("PlayerDetails")
                local posx, posy = playerDetailsUI._btnSet.x + playerDetailsUI._btnSet.width / 2, playerDetailsUI._btnSet.y + playerDetailsUI._btnSet.height / 2
                TriggerGuideLogic:SetGuideScale({0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(playerDetailsUI)
            end,
            "PlayerDetails"
        )
    end,
    --账号切换
    [12804] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local playerSetupUI = UIMgr:GetUI("PlayerSetup")
                local setUpItem = playerSetupUI.itemList[1]
                local posx, posy = playerSetupUI._list.x + setUpItem.width / 2, playerSetupUI._list.y + setUpItem.height / 2
                TriggerGuideLogic:SetGuideScale({0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(playerSetupUI)
            end,
            "PlayerSetup"
        )
    end,
    --绑定按钮
    [12806] = function()
        isHiddenClipMask = true
        TriggerGuideLogic:ClearTriggerGuide()
        TriggerGuideLogic:SetScheduler(
            function()
                JumpMap:JumpSimple(812800, nil, true)
            end,
            "SetupAccountNumber"
        )
    end,
    --解锁巨兽，指引到巨兽基地
    [13702] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        if BuildModel.CheckExist(Global.BuildingBeastBase) then
            TriggerGuideLogic:ClearTriggerGuide()
            return
        end
        local dis = {0, 0}
        local scale = {1.3, 1}
        TriggerGuideLogic:SetMoveCallBack(Global.BuildingBeastBase, dis, scale, GuideCreatType.Creat)
    end,
    --巨兽基地建造
    [13703] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic:SetBuildCreateUI(Global.BuildingBeastBase)
            end,
            "BuildRelated/BuildCreate"
        )
    end,
    --巨兽基地建造选择页
    [13704] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local buildUpgrade = UIMgr:GetUI("BuildRelated/BuildUpgrade")
                local buildUI = buildUpgrade._btnR
                local posx, posy = buildUpgrade._bgDown.x + buildUI.x + buildUI.width / 2, buildUpgrade._bgDown.y + buildUI.y + buildUI.height / 2
                local guideLayer = UIMgr:GetUI("GuideLayer")
                guideLayer._guide:SetTopAnim(true)
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(buildUpgrade)
            end,
            "BuildRelated/BuildUpgrade"
        )
    end,
    --巨兽巢穴解锁
    [13706] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        local pos = BuildModel.GetCreatPos(Global.BuildingGodzilla)
        local piece = CityMapModel.GetMapPiece(pos)
        local dis = {0, 0}
        local scale = {1.3, 1}
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic:SetMoveCallBack(Global.BuildingGodzilla, dis, scale, GuideCreatType.UnLock)
            end
        )
    end,
    --指引到地图图标
    [13708] = function()
        isHiddenClipMask = true
        TriggerGuideLogic:CloseTriggerGuide()
        JumpMap:JumpSimple(813000)
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    --地图打怪，指引世界地图按钮结束
    [13802] = function()
        JumpMap:JumpSimple(813200)
        TriggerGuideLogic:CloseTriggerGuide()
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    --背包按钮
    [13902] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.MainUITouchEvent, false, "_btnBackpack")
        local mainPanel = UIMgr:GetUI("MainUIPanel")
        local backpackBtnX = mainPanel.down.x + mainPanel._btnBackpack.x
        local backpackBtnY = mainPanel.down.y + mainPanel._btnBackpack.y
        local pos = {backpackBtnX + 5, backpackBtnY + 5}
        local guideLayer = UIMgr:GetUI("GuideLayer")
        guideLayer._guide:SetTopAnim(true)
        TriggerGuideLogic:SetGuideScale({0.6, 0.6})
        TriggerGuideLogic:SetGuidePos(pos)
        local itemData = GD.ItemAgent.GetItemModelById(204120)
        if not itemData then
            Log.Error("13902引导，没有物品退出引导")
            TriggerGuideLogic:ClearTriggerGuide()
            return
        end
        TriggerGuideLogic:SetBtnClick(mainPanel)
    end,
    --指引背包加速道具
    [13903] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                --TODO暂时写死
                Scheduler.ScheduleOnceFast(
                    function()
                        local giftId = 204120
                        local backPack = UIMgr:GetUI("Backpack")
                        backPack:ScrollToViewItem(giftId)
                        local itemEntity = GD.ItemAgent.GetItemPane(giftId)
                        if not itemEntity then
                            Log.Error("13903引导，没有下拉框退出引导")
                            TriggerGuideLogic:ClearTriggerGuide()
                            return
                        end
                        local listItem = itemEntity.uiParent
                        local listPosY = backPack:GetGuidePosByItem(listItem)
                        backPack:SetScrollTouchEffect(false)
                        local itemPosX = backPack._list.x + (itemEntity.width / 2 + itemEntity.x)
                        local itemPosY = backPack._list.y + (itemEntity.height / 2 + listPosY)
                        TriggerGuideLogic:SetGuideScale({0.7, 0.7})
                        TriggerGuideLogic:SetGuidePos({itemPosX + 15, itemPosY + 9})
                        TriggerGuideLogic:SetBtnClick(itemEntity)
                    end,
                    0.2
                )
            end,
            "Backpack"
        )
    end,
    --加速使用
    [13904] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local usePanel = GD.ItemAgent.GetItemBoxPane()
                local backPack = UIMgr:GetUI("Backpack")
                local useBtn = usePanel._btnUse
                local posX = backPack._list.x + usePanel.x + (useBtn.x + useBtn.width / 2)
                local posY = backPack._list.y + usePanel.y + (useBtn.y + useBtn.height / 2)
                TriggerGuideLogic:SetGuideScale({0.7, 0.7})
                TriggerGuideLogic:SetGuidePos({posX + 5, posY - 2})
                TriggerGuideLogic:SetBtnClick(usePanel)
            end
        )
    end,
    --退出指引
    [13905] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local backPackUI = UIMgr:GetUI("Backpack")
                backPackUI:SetScrollTouchEffect(true)
                local returnBtn = backPackUI._btnReturn
                local posX = returnBtn.x + returnBtn.width / 2
                local posY = returnBtn.y + returnBtn.height / 2
                TriggerGuideLogic:SetGuideScale({0.7, 0.7})
                TriggerGuideLogic:SetGuidePos({posX - 10, posY})
                TriggerGuideLogic.btnEntity = backPackUI
                TriggerGuideLogic.triggerGuideEnd = true
                backPackUI:SetScrollTouchEffect(true)
                TriggerGuideLogic:SetBtnClick(backPackUI)
            end,
            "Backpack"
        )
    end,
    --美女引导相关
    [14002] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        local uiMaskManager = UIMgr:GetUI("UIMaskManager")
        uiMaskManager:SetClose(true)
        local strName = StringUtil.GetI18n(I18nType.Commmon, "Beauty_guide_desc1")
        local strOld = StringUtil.GetI18n(I18nType.Commmon, "Beauty_guide_desc2")
        local strWork = StringUtil.GetI18n(I18nType.Commmon, "Beauty_guide_desc3")
        UIMgr:Open("BeautyIntroduce", strName, strOld, strWork)
        -- UIMgr:Close("UIMaskManager")
        TriggerGuideLogic.CloseMaskUI()
        local beautyUI = UIMgr:GetUI("BeautyIntroduce")
        local cityFunction = CityMapModel.GetCityContext()._itemDetail
        local compVisible = cityFunction:GetFuncVisible()
        if compVisible then
            cityFunction:OffAnim(false)
        end
        TriggerGuideLogic:SetBtnClick(beautyUI)
    end,
    --美女按钮指引
    [14003] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.DelayMask, true)
        UIMgr:Close("BeautyIntroduce")
        UIMgr:Open("UIMaskManager")
        local building = BuildModel.FindByConfId(Global.BuildingCasino)
        local piece = CityMapModel.GetMapPiece(building.Pos)
        local buildNode = BuildModel.GetObject(building.Id)
        local function func()
            buildNode:BuildClick()
            TriggerGuideLogic:SetScheduler(
                function()
                    Event.Broadcast(EventDefines.DelayMask, false)
                    TriggerGuideLogic.triggerGuideEnd = true
                    TriggerGuideLogic:SetItemCityFunction("BeautySystemMain")
                end
            )
        end
        local isEqualPos = CityMapModel.CheckSpaceNodeIsMoved(piece.x, piece.y)
        if isEqualPos then
            func()
            return
        else
            --带缩放移动
            ScrollModel.ForceStop()
            ScrollModel.MoveScale(piece, Global.BuildingCasino, nil, true)
            ScrollModel.SetCb(func)
            return
        end
        TriggerGuideLogic:ClearTriggerGuide()
    end,
    --美女开始按钮
    [14006] = function()
        TriggerGuideLogic:CloseTriggerGuide()
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BeautySystemMainUI)
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    [14102] = function()
        TriggerGuideLogic:CloseTriggerGuide()
        if UIMgr:GetUIOpen("BeautySystemMain") == true then
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BeautyDateUI)
        end
    end,
    [14103] = function()
        TriggerGuideLogic:CloseTriggerGuide()
        if UIMgr:GetUIOpen("BeautySystemMain") == true then
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BeautyExit)
        end
    end,
    [14204] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.MainUITouchEvent, false, "_btnWorld")
        local mainPanel = UIMgr:GetUI("MainUIPanel")
        local WorldMapBtnX = mainPanel.down.x + mainPanel._btnWorld.x
        local WorldMapBtnY = mainPanel.down.y + mainPanel._btnWorld.y
        local pos = {WorldMapBtnX + mainPanel._btnWorld.width / 2, WorldMapBtnY + mainPanel._btnWorld.height / 2}
        local guideLayer = UIMgr:GetUI("GuideLayer")
        guideLayer._guide:SetTopAnim(true)
        TriggerGuideLogic:SetGuideScale({0.6, 0.6})
        TriggerGuideLogic:SetGuidePos(pos)
        TriggerGuideLogic.triggerGuideEnd = true
        TriggerGuideLogic:SetBtnClick(mainPanel)
    end,
    [14207] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.MainUITouchEvent, false, "_btnWorld")
        local mainPanel = UIMgr:GetUI("MainUIPanel")
        local WorldMapBtnX = mainPanel.down.x + mainPanel._btnWorld.x
        local WorldMapBtnY = mainPanel.down.y + mainPanel._btnWorld.y
        local pos = {WorldMapBtnX + mainPanel._btnWorld.width / 2, WorldMapBtnY + mainPanel._btnWorld.height / 2}
        local guideLayer = UIMgr:GetUI("GuideLayer")
        guideLayer._guide:SetTopAnim(true)
        TriggerGuideLogic:SetGuideScale({0.6, 0.6})
        TriggerGuideLogic:SetGuidePos(pos)
        TriggerGuideLogic.triggerGuideEnd = true
        TriggerGuideLogic:SetBtnClick(mainPanel)
    end,
    [14402] = function()
        TriggerGuideLogic:CloseTriggerGuide()
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BeautyClothUI)
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    [14506] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.MainUITouchEvent, false, "btnRadar")
        local mainPanel = UIMgr:GetUI("MainUIPanel")
        local RadarBtnX = mainPanel._btnRadar.x
        local RadarBtnY = mainPanel._btnRadar.y
        local pos = {RadarBtnX + mainPanel._btnRadar.width / 2, RadarBtnY + mainPanel._btnWorld.height / 2}
        local guideLayer = UIMgr:GetUI("GuideLayer")
        guideLayer._guide:SetTopAnim(true)
        TriggerGuideLogic:SetGuideScale({0.6, 0.6})
        TriggerGuideLogic:SetGuidePos(pos)
        TriggerGuideLogic:SetBtnClick(mainPanel)
    end,
    --查看
    [14507] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local radarPanel = UIMgr:GetUI("Radar")
                local listItem = radarPanel._contentList:GetChildAt(0)
                local posx, posy = radarPanel._contentList.x + listItem.x + listItem.width / 2, radarPanel._contentList.y + listItem.y + listItem.height / 2
                local boxPosx, boxPosy = radarPanel._contentList.x + listItem.x, radarPanel._contentList.y + listItem.y
                TriggerGuideLogic:SetGuideScale({3.5, 1.5}, {0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posx, posy}, true)
                TriggerGuideLogic:SetGuideMaskSize(Vector2(listItem.width, listItem.height))
                TriggerGuideLogic:SetGuideBox({boxPosx, boxPosy}, {listItem.width, listItem.height})
                TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
            end,
            "Radar"
        )
    end,
    --点世界地图按钮
    [14508] = function()
        Event.Broadcast(EventDefines.OpenWorldMap)
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    [14509] = function()
        isHiddenClipMask = true
        TriggerGuideLogic:CloseTriggerGuide()
        JumpMap:JumpSimple(813000, true)
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    [14606] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.MainUITouchEvent, false, "btnRadar")
        local mainPanel = UIMgr:GetUI("MainUIPanel")
        local RadarBtnX = mainPanel._btnRadar.x
        local RadarBtnY = mainPanel._btnRadar.y
        local pos = {RadarBtnX + mainPanel._btnRadar.width / 2, RadarBtnY + mainPanel._btnWorld.height / 2}
        local guideLayer = UIMgr:GetUI("GuideLayer")
        guideLayer._guide:SetTopAnim(true)
        TriggerGuideLogic:SetGuideScale({0.6, 0.6})
        TriggerGuideLogic:SetGuidePos(pos)
        TriggerGuideLogic:SetBtnClick(mainPanel)
    end,
    --查看
    [14607] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local radarPanel = UIMgr:GetUI("Radar")
                local listItem = radarPanel._contentList:GetChildAt(0)
                local posx, posy = radarPanel._contentList.x + listItem.x + listItem.width / 2, radarPanel._contentList.y + listItem.y + listItem.height / 2
                local boxPosx, boxPosy = radarPanel._contentList.x + listItem.x, radarPanel._contentList.y + listItem.y
                TriggerGuideLogic:SetGuideScale({3.5, 1.5}, {0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posx, posy}, true)
                TriggerGuideLogic:SetGuideMaskSize(Vector2(listItem.width, listItem.height))
                TriggerGuideLogic:SetGuideBox({boxPosx, boxPosy}, {listItem.width, listItem.height})
                TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
            end,
            "Radar"
        )
    end,
    --点世界地图按钮
    [14608] = function()
        Event.Broadcast(EventDefines.OpenWorldMap)
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    [14609] = function()
        isHiddenClipMask = true
        TriggerGuideLogic:CloseTriggerGuide()
        --添加内外城处理
        JumpMap:JumpSimple(813000, true)
        TriggerGuideLogic:SetTriggerNextStep()
    end,
    [14704] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        local pos = BuildModel.GetCreatPos(Global.BuildingKingkong)
        local piece = CityMapModel.GetMapPiece(pos)
        local dis = {0, 0}
        local scale = {1.3, 1}
        TriggerGuideLogic:SetScheduler(
            function()
                isHiddenClipMask = true
                TriggerGuideLogic:CloseTriggerGuide()
                TriggerGuideLogic:SetMoveCallBack(
                    Global.BuildingKingkong,
                    dis,
                    scale,
                    GuideCreatType.UnLock,
                    function()
                        --local b1 = BuildModel.FindByConfId(Global.BuildingGodzilla)
                        --if b1.Level == 0 then
                        --    JumpMap:JumpSimple(813000)
                        --    TriggerGuideLogic:SetTriggerNextStep()
                        --else
                        Model.Player.isUnlockKingkong = true
                        BuildNest.NestUnlock(Global.BuildingKingkong)
                        Event.Broadcast(EventDefines.DelayMask, false)
                        TriggerGuideLogic:SetTriggerNextStep()
                        --end
                    end
                )
            end
        )
    end,
    --解锁巨兽，指引到巨兽基地
    [14802] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        if BuildModel.CheckExist(Global.BuildingBeastBase) then
            TriggerGuideLogic:ClearTriggerGuide()
            return
        end
        local dis = {0, 0}
        local scale = {1.3, 1}
        TriggerGuideLogic:SetMoveCallBack(Global.BuildingBeastBase, dis, scale, GuideCreatType.Creat)
    end,
    --巨兽基地建造
    [14803] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic:SetBuildCreateUI(Global.BuildingBeastBase)
            end,
            "BuildRelated/BuildCreate"
        )
    end,
    --巨兽基地建造选择页
    [14804] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                -- local buildUpgrade = UIMgr:GetUI("BuildRelated/BuildUpgrade")
                -- local buildUI = buildUpgrade._btnR
                -- local posx, posy = buildUI.x + buildUI.width / 2, buildUI.y + buildUI.height / 2
                local buildUpgrade = UIMgr:GetUI("BuildRelated/BuildUpgrade")
                local buildUI = buildUpgrade._btnR
                local posx, posy = buildUpgrade._bgDown.x + buildUI.x + buildUI.width / 2, buildUpgrade._bgDown.y + buildUI.y + buildUI.height / 2
                local guideLayer = UIMgr:GetUI("GuideLayer")
                guideLayer._guide:SetTopAnim(true)
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(buildUpgrade)
            end,
            "BuildRelated/BuildUpgrade"
        )
    end,
    --巨兽巢穴解锁
    [14806] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        local dis = {0, 0}
        local scale = {1.3, 1}
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic.triggerGuideEnd = true
                TriggerGuideLogic:SetMoveCallBack(Global.BuildingGodzilla, dis, scale, GuideCreatType.UnLock)
            end
        )
    end,
    --巨兽巢穴解锁
    [14902] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        local dis = {0, 0}
        local scale = {1.3, 1}
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic.triggerGuideEnd = true
                TriggerGuideLogic:SetMoveCallBack(Global.BuildingGodzilla, dis, scale, GuideCreatType.UnLock)
            end
        )
    end,
    --指引到直升机
    [15002] = function()
        local isExist = WelfareModel.CheckActiviyExist(WelfareModel.WelfarePageType.FALCON_ACTIVITY)
        if not isExist then
            TriggerGuideLogic:ClearTriggerGuide()
            UIMgr:Close("WelfareMain")
            return
        end
        TriggerGuideLogic.IsNeedCloseWindow()
        local building = BuildModel.FindByConfId(Global.BuildingAirPlane3)
        local dis = {0, -100}
        local scale = {1.3, 1}
        TriggerGuideLogic:SetMoveCallBack(Global.BuildingAirPlane3, dis, scale, GuideCreatType.Upgrade)
    end,
    [15003] = function()
        Event.Broadcast(EventDefines.DelayMask, true)
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic:SetTriggerNextStep()
            end,
            "WelfareMain"
        )
    end,
    --猎鹰行动开始扫描
    [15006] = function()
        local isExist = WelfareModel.CheckActiviyExist(WelfareModel.WelfarePageType.FALCON_ACTIVITY)
        if not isExist then
            TriggerGuideLogic:ClearTriggerGuide()
            UIMgr:Close("WelfareMain")
            return
        end
        TriggerGuideLogic:SetScheduler(
            function()
                local WelfareMain = UIMgr:GetUI("WelfareMain")
                local function falconFunc()
                    local falcon = WelfareMain.GetWelfareNode(WelfareModel.WelfarePageType.FALCON_ACTIVITY)
                    local btnSweep = falcon:GetChild("_btnStartSweep")
                    local posx, posy = btnSweep.x, btnSweep.y
                    TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                    TriggerGuideLogic:SetGuidePos({posx + btnSweep.width / 2, posy + btnSweep.height / 2})
                    isHiddenClipMask = true
                    TriggerGuideLogic:SetBtnClick(falcon)
                end
                Event.Broadcast(EventDefines.DelayMask, false)
                local isCheckOpenAct = WelfareMain.CheckPageIsOpen(WelfareModel.WelfarePageType.FALCON_ACTIVITY)
                if not isCheckOpenAct then
                    WelfareMain:JumpItem(WelfareModel.WelfarePageType.FALCON_ACTIVITY)
                    Scheduler.ScheduleOnceFast(
                        function()
                            falconFunc()
                        end,
                        0.3
                    )
                else
                    falconFunc()
                end
            end,
            "WelfareMain"
        )
    end,
    --指引的猎鹰行动
    [15007] = function()
        TriggerGuideLogic.SetNextCallBack(
            function()
                local WelfareMain = UIMgr:GetUI("WelfareMain")
                local falcon = WelfareMain.GetWelfareNode(WelfareModel.WelfarePageType.FALCON_ACTIVITY)
                local btnPoint1 = falcon:GetChild("_btnPoint1")
                local btnPoint6 = falcon:GetChild("_btnPoint6")
                local posx, posy = btnPoint1.x, btnPoint1.y
                local width = math.abs(btnPoint6.x - btnPoint1.x) + btnPoint6.width
                local height = math.abs(btnPoint6.y - btnPoint1.y) + btnPoint6.height
                TriggerGuideLogic:SetGuideScale({3.5, 1.5}, {0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
                TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
                TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
                TriggerGuideLogic.triggerGuideEnd = true
                TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
            end
        )
    end,
    --页面触发猎鹰行动扫描
    [15103] = function()
        local isExist = WelfareModel.CheckActiviyExist(WelfareModel.WelfarePageType.FALCON_ACTIVITY)
        if not isExist then
            TriggerGuideLogic:ClearTriggerGuide()
            UIMgr:Close("WelfareMain")
            return
        end
        TriggerGuideLogic:SetScheduler(
            function()
                local WelfareMain = UIMgr:GetUI("WelfareMain")
                local function falconFunc()
                    local falcon = WelfareMain.GetWelfareNode(WelfareModel.WelfarePageType.FALCON_ACTIVITY)
                    local btnSweep = falcon:GetChild("_btnStartSweep")
                    local posx, posy = btnSweep.x, btnSweep.y
                    TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                    TriggerGuideLogic:SetGuidePos({posx + btnSweep.width / 2, posy + btnSweep.height / 2})
                    isHiddenClipMask = true
                    TriggerGuideLogic:SetBtnClick(falcon)
                end
                local isCheckOpenAct = WelfareMain.CheckPageIsOpen(WelfareModel.WelfarePageType.FALCON_ACTIVITY)
                if not isCheckOpenAct then
                    WelfareMain:JumpItem(WelfareModel.WelfarePageType.FALCON_ACTIVITY)
                    Scheduler.ScheduleOnceFast(
                        function()
                            falconFunc()
                        end,
                        0.3
                    )
                else
                    falconFunc()
                end
            end,
            "WelfareMain"
        )
    end,
    --扫描结束后指引
    [15104] = function()
        TriggerGuideLogic.SetNextCallBack(
            function()
                local WelfareMain = UIMgr:GetUI("WelfareMain")
                local falcon = WelfareMain.GetWelfareNode(WelfareModel.WelfarePageType.FALCON_ACTIVITY)
                local btnPoint1 = falcon:GetChild("_btnPoint1")
                local btnPoint6 = falcon:GetChild("_btnPoint6")
                local posx, posy = btnPoint1.x, btnPoint1.y
                local width = math.abs(btnPoint6.x - btnPoint1.x) + btnPoint6.width
                local height = math.abs(btnPoint6.y - btnPoint1.y) + btnPoint6.height
                TriggerGuideLogic:SetGuideScale({3.5, 1.5}, {0.5, 0.5})
                TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
                TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
                TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
                TriggerGuideLogic.triggerGuideEnd = true
                TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
            end
        )
    end,
    --A方案点击条
    [15502] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.MainUITouchEvent, false, "bgTipsBar")
        local mainUI = UIMgr:GetUI("MainUIPanel")
        local posx, posy = mainUI._bgTipsBar.x + 120, mainUI._bgTipsBar.y + 30
        TriggerGuideLogic:SetGuideScale({0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posx, posy})
        TriggerGuideLogic:SetBtnClick(mainUI)
    end,
    [15503] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.MainUITouchEvent, false, "bgTipsBar")
        local mainUI = UIMgr:GetUI("MainUIPanel")
        local posx, posy = mainUI._bgTipsBar.x + 120, mainUI._bgTipsBar.y + 30
        TriggerGuideLogic:SetGuideScale({0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posx, posy})
        TriggerGuideLogic:SetBtnClick(mainUI)
        TriggerGuideLogic.triggerGuideEnd = true
    end,
    [15602] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        --local pos = BuildModel.FindByConfId(Global.BuildingBeastBase).Pos
        --local piece = CityMapModel.GetMapPiece(pos)
        local dis = {0, 0}
        local scale = {1.3, 1}
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic.triggerGuideEnd = true
                TriggerGuideLogic:SetMoveCallBack(Global.BuildingBeastBase, dis, scale, GuideCreatType.UnLock)
            end
        )
    end,
    [15604] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        local pos = BuildModel.GetCreatPos(Global.BuildingGodzilla)
        local piece = CityMapModel.GetMapPiece(pos)
        local dis = {0, 0}
        local scale = {1.3, 1}
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic.triggerGuideEnd = true
                TriggerGuideLogic:SetMoveCallBack(Global.BuildingGodzilla, dis, scale, GuideCreatType.UnLock)
            end
        )
    end,
    [15702] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        --local pos = BuildModel.FindByConfId(Global.BuildingBeastBase).Pos
        --local piece = CityMapModel.GetMapPiece(pos)
        local dis = {0, 0}
        local scale = {1.3, 1}
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic.triggerGuideEnd = true
                TriggerGuideLogic:SetMoveCallBack(Global.BuildingBeastBase, dis, scale, GuideCreatType.UnLock)
            end
        )
    end,
    [15902] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        local dis = {0, -100}
        local scale = {1.3, 1}
        local cityFunction = CityMapModel.GetCityContext()._itemDetail
        local compVisible = cityFunction:GetFuncVisible()
        if compVisible then
            cityFunction:OffAnim(false)
        end
        TriggerGuideLogic:SetMoveCallBack(Global.BuildingEquipFactory, dis, scale, GuideCreatType.Upgrade)
    end,
    [15903] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.DelayMask, true)
        TriggerGuideLogic:SetScheduler(
            function()
                Event.Broadcast(EventDefines.DelayMask, false)
                TriggerGuideLogic:SetItemCityFunction("Forge")
            end
        )
    end,
    [15904] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local equipmentSelect = UIMgr:GetUI("EquipmentSelect")
                local equipmentSelectView = equipmentSelect.Controller.contentPane
                local equipmentList = equipmentSelect._list
                local index = equipmentSelect:GetCanMakeIndex()
                local listItemNum = equipmentList:ItemIndexToChildIndex(index)
                local listItem = equipmentList:GetChildAt(listItemNum)
                local item = equipmentList:GetChildAt(listItemNum):GetChild("btnView1")
                local listItemPos = listItem:LocalToGlobal(Vector2.zero)
                local inPanelPos = equipmentSelectView:GlobalToLocal(listItemPos)
                local posx, posy = inPanelPos.x + item.x + item.width / 2, inPanelPos.y + item.y + item.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(listItem)
            end,
            "EquipmentSelect"
        )
    end,
    [15905] = function(params)
        isHiddenClipMask = true
        local equipmentUI = UIMgr:GetUI("EquipmentTransaction")
        local posx, posy = equipmentUI._bgTop.x - 5, equipmentUI._bgTop.y - 5
        local width, height = equipmentUI._bgTop.width + 10, equipmentUI._bgTop.height + 160
        TriggerGuideLogic:SetGuideScale({1, 1}, {0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
        TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
        TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
        TriggerGuideLogic.SetTipPos({0, posy}, true, params)
        --关闭遮罩
        TriggerGuideLogic.maskGuide:SetGuideMaskClose()
        TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
    end,
    [15906] = function(params)
        isHiddenClipMask = true
        local equipmentUI = UIMgr:GetUI("EquipmentTransaction")
        local posx, posy = equipmentUI._groupEquip.x - 5, equipmentUI._groupEquip.y - 5
        local width, height = equipmentUI._groupEquip.width + 10, equipmentUI._groupEquip.height + 90
        TriggerGuideLogic:SetGuideScale({1, 1}, {0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
        TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
        TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
        TriggerGuideLogic.SetTipPos({0, posy - 10}, true, params)
        TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
    end,
    [15907] = function(params)
        isHiddenClipMask = true
        local equipmentUI = UIMgr:GetUI("EquipmentTransaction")
        local posx, posy = equipmentUI._bgDown.x, equipmentUI._bgDown.y
        local width, height = equipmentUI._bgDown.width, equipmentUI._bgDown.height
        TriggerGuideLogic:SetGuideScale({1, 1}, {0.5, 0.5})
        TriggerGuideLogic:SetGuidePos({posx + width / 2, posy + height / 2}, true)
        TriggerGuideLogic:SetGuideMaskSize(Vector2(width, height))
        TriggerGuideLogic:SetGuideBox({posx, posy}, {width, height})
        TriggerGuideLogic.SetTipPos({0, posy}, true, params)
        TriggerGuideLogic.triggerGuideEnd = true
        TriggerGuideLogic:SetBtnClick(UIMgr:GetUI("UIMaskManager"):GetGuideLayer())
    end,
    [15909] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local equipmentUI = UIMgr:GetUI("EquipmentTransaction")
                local equipmentList = equipmentUI._itemMaterial
                local listItem = equipmentList[1]
                local posx, posy = listItem.x + listItem.width / 2, listItem.y + listItem.height / 2
                TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(listItem)
            end,
            "EquipmentTransaction"
        )
    end,
    [15910] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local equipmentUI = UIMgr:GetUI("EquipmentTransaction")
                local equipmentList = equipmentUI._listMaterial
                local listItem = equipmentList:GetChildAt(1)
                local posx, posy = equipmentList.x + listItem.width / 2 + listItem.width + 22, equipmentList.y + listItem.height / 2 - 15
                TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(listItem)
            end,
            "EquipmentTransaction"
        )
    end,
    [15912] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local equipmentUI = UIMgr:GetUI("EquipmentTransaction")
                local btnR = equipmentUI._btnR
                local posx, posy = btnR.x + btnR.width / 2, btnR.y + btnR.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(equipmentUI)
            end,
            "EquipmentTransaction"
        )
    end,
    [15913] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local popUI = UIMgr:GetUI("EquipTransactionQualityPopup")
                local btnSureSingle = popUI._btnSureSingle
                local posx, posy = btnSureSingle.x + btnSureSingle.width / 2, btnSureSingle.y + btnSureSingle.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(popUI)
            end,
            "EquipTransactionQualityPopup"
        )
    end,
    [15915] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local selectUI = UIMgr:GetUI("EquipmentSelect")
                local btnReturn = selectUI._btnReturn
                local posx, posy = btnReturn.x + btnReturn.width / 2, btnReturn.y + btnReturn.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(selectUI)
            end,
            "EquipmentSelect"
        )
    end,
    [15916] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        isHiddenClipMask = true
        local dis = {0, -100}
        local scale = {1.3, 1}
        TriggerGuideLogic:SetMoveCallBack(Global.BuildingEquipMaterialFactory, dis, scale, GuideCreatType.Upgrade)
    end,
    [15917] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                isHiddenClipMask = true
                TriggerGuideLogic:SetTriggerNextStep()
            end,
            "EquipmentMake"
        )
    end,
    [15918] = function()
        TriggerGuideLogic:ClearTriggerGuide()
        TriggerGuideLogic:SetScheduler(
            function()
                Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.EquipmentMakeMaterialBtn)
            end,
            "EquipmentMake"
        )
    end,
    [16001] = function()
        TriggerGuideLogic:ClearTriggerGuide()
        TriggerGuideLogic:SetScheduler(
            function()
                Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.WorldCityTownTip)
            end,
            "WorldCity"
        )
    end,
    [17002] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        local dis = {0, -100}
        local scale = {1.3, 1}
        local cityFunction = CityMapModel.GetCityContext()._itemDetail
        local compVisible = cityFunction:GetFuncVisible()
        if compVisible then
            cityFunction:OffAnim(false)
        end
        TriggerGuideLogic:SetMoveCallBack(Global.Buildingplane, dis, scale, GuideCreatType.Upgrade)
    end,
    [17003] = function()
        TriggerGuideLogic.IsNeedCloseWindow()
        Event.Broadcast(EventDefines.DelayMask, true)
        TriggerGuideLogic:SetScheduler(
            function()
                Event.Broadcast(EventDefines.DelayMask, false)
                TriggerGuideLogic:SetItemCityFunction("Plane")
            end
        )
    end,
    [17005] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local planeHangar = UIMgr:GetUI("AircraftHangar")
                local comboBox = planeHangar._aircraftList:GetChildAt(1)
                comboBox:SetController(1)
                local planeInfoItem = comboBox._list:GetChildAt(0)
                local comboBoxPos = comboBox:LocalToGlobal(Vector2.zero)
                local inPanelPos = planeHangar.Controller.contentPane:GlobalToLocal(comboBoxPos)
                local posx, posy = inPanelPos.x + planeInfoItem.x + planeInfoItem.width / 2 - 60, inPanelPos.y + planeInfoItem.y + planeInfoItem.height / 2 + 100
                TriggerGuideLogic:SetGuideScale({1, 1})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(planeInfoItem)
            end,
            "AircraftHangar"
        )
    end,
    [17006] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local planeDetails = UIMgr:GetUI("AircraftDetails")
                local partItem = planeDetails._partList:GetChildAt(0)
                local partItemPos = partItem:LocalToGlobal(Vector2.zero)
                local inPanelPos = planeDetails.Controller.contentPane:GlobalToLocal(partItemPos)
                local itemCell = partItem._item
                local posx, posy = inPanelPos.x + itemCell.width / 2 + 20, inPanelPos.y + itemCell.height / 2 + 15
                TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(partItem)
            end,
            "AircraftDetails"
        )
    end,
    [17007] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local popUI = UIMgr:GetUI("AircraftStorePopup")
                local btnSure = popUI._btnsure
                local posx, posy = btnSure.x + btnSure.width / 2, btnSure.y + btnSure.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(popUI)
            end,
            "AircraftStorePopup"
        )
    end,
    [17009] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local next_func = function()
                    local planeDetails = UIMgr:GetUI("AircraftDetails")
                    local partItem = planeDetails._partList:GetChildAt(1)
                    local partItemPos = partItem:LocalToGlobal(Vector2.zero)
                    local inPanelPos = planeDetails.Controller.contentPane:GlobalToLocal(partItemPos)
                    local itemCell = partItem._item
                    local posx, posy = inPanelPos.x + itemCell.width / 2 + 20, inPanelPos.y + itemCell.height / 2 + 15
                    TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                    TriggerGuideLogic:SetGuidePos({posx, posy})
                    TriggerGuideLogic:SetBtnClick(partItem)
                end

                --报错处理，当设备太卡的时候可能导致第一个零件购买不成功，会卡在弹窗那一步
                --if not PlaneModel.GetPartInfoByPartId(1001) then
                if TriggerGuideLogic.CheackIsUIOpen("AircraftStorePopup") then
                    UIMgr:Close(
                        "AircraftStorePopup",
                        function()
                            next_func()
                            Event.Broadcast(EventDefines.RefreshAirDetailsContent)
                        end
                    )
                else
                    next_func()
                end
            end,
            "AircraftDetails"
        )
    end,
    [17010] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local popUI = UIMgr:GetUI("AircraftStorePopup")
                local btnSure = popUI._btnsure
                local posx, posy = btnSure.x + btnSure.width / 2, btnSure.y + btnSure.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(popUI)
            end,
            "AircraftStorePopup"
        )
    end,
    [17012] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                local planeDetails = UIMgr:GetUI("AircraftDetails")
                local btnStart = planeDetails._btnStart
                local posx, posy = btnStart.x + btnStart.width / 2, btnStart.y + btnStart.height / 2
                TriggerGuideLogic:SetGuideScale({0.6, 0.6})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(planeDetails)
            end,
            "AircraftDetails"
        )
    end,
    [17014] = function()
        TriggerGuideLogic:SetScheduler(
            function()
                TriggerGuideLogic.triggerGuideEnd = true
                local planeUI = UIMgr:GetUI("AircraftHangar")
                local btnClose = planeUI._btnClose
                local posx, posy = btnClose.x + btnClose.width / 2, btnClose.y + btnClose.height / 2
                TriggerGuideLogic:SetGuideScale({0.8, 0.8})
                TriggerGuideLogic:SetGuidePos({posx, posy})
                TriggerGuideLogic:SetBtnClick(planeUI)
            end,
            "AircraftHangar"
        )
    end,
    --钻石月卡弹窗
    [17101] = function()
        for i = 1, #Model.DiamondFundInfo do
            if Model.DiamondFundInfo[i].ExpireAt > 0 then
                TriggerGuideLogic:ClearTriggerGuide()
                return
            end
        end
        UIMgr:Open("MonthlyCardPopup")
        TriggerGuideLogic:CloseTriggerGuide()
        TriggerGuideLogic:SetTriggerNextStep()
    end
}

---------------------------------------------------------其它方法---------------------------------------------------
function TriggerGuideLogic:Init()
    self.guideIsBegin = false --开始指引
    self.triggerGuideEnd = false --指引结束
    self.btnEntity = nil
    self:InitEvent()
    UIMgr:Open("GuideCanvas")
end

function TriggerGuideLogic:InitEvent()
    --设置触发引导UI
    Event.AddListener(
        EventDefines.TriggerGuideShow,
        function(isShow)
            if not self.guideIsBegin then
                return
            end
            if isShow then
                TriggerGuideLogic.SetMaskClipShow()
                UIMgr:Open("UIMaskManager")
            else
                local maskManager = UIMgr:GetUI("UIMaskManager")
                maskManager:SetGuideMaskClose()
                self.maskGuide:SetClose(true)
                TriggerGuideLogic.CloseMaskUI()
            end
        end
    )
    Event.AddListener(
        EventDefines.BuildItemStateChange,
        function(buildConfid)
            if Tool.Equal(buildConfid, Global.BuildingCenter) then
                --直接结束引导
                if GlobalVars.NowTriggerId == 11400 and GlobalVars.IsTriggerStatus then
                    if not GD.TriggerGuideAgent.CheackTriggerState(TriggerGuideLogic.noviceID) then --满足免费建造条件
                        self:ClearTriggerGuide()
                    end
                end
            end
        end
    )

    Event.AddListener(
        EventDefines.NextNoviceStep,
        function(cutId)
            if not GlobalVars.IsNoviceGuideStatus then
                return
            end
            if cutId ~= cutNoviceId then
                return
            end
            if IsNoviceReadyCb then
                IsNoviceReadyCb = false
                NoviceModel:NextStep()
                cutNoviceId = 0
            end
        end
    )
    Event.AddListener(
        EventDefines.FalconSearchEndCb,
        function()
            if btnCallback then
                btnCallback()
            end
        end
    )
    --关闭触发引导
    Event.AddListener(
        EventDefines.ClearTrigger,
        function()
            self:ClearTriggerGuide()
        end
    )
end

---------------------------------------------------------引导步骤的流程设置---------------------------------------------------

--@desc: Boot steps流程触发式引导
--类型是：新手引导|configNoviceGuide表的type字段
function TriggerGuideLogic:TriggerGuideStart(noviceID, ...)
    self.btnEntity = nil
    self.noviceID = noviceID
    if not self.GuideTable[noviceID] then
        Log.Warning("No find NoviceId")
    else
        if not self.guideIsBegin then
            --初始化关闭所有其他引导遮罩
            self:CloseTriggerGuide()
            self:SetOpenMask(self.guideIsBegin)
            self.triggerGuideEnd = false
        end
        if self.guideIsBegin then
            isHiddenClipMask = false
            --特殊处理关闭弱引导
            Event.Broadcast(EventDefines.CloseGuide)
            --新增特殊处理检测条件是否完成
            if not GD.TriggerGuideAgent.CheackTriggerState(noviceID) then
                Log.Error("{0}引导，不满足引导条件，退出引导", noviceID)
                self:ClearTriggerGuide()
                --退出触发引导
                return
            end
            local guideLayer = UIMgr:GetUI("GuideLayer")
            guideLayer._guide:SetTopAnim(false)
            Event.Broadcast(EventDefines.MainUITouchEvent, false)
            self.GuideTable[noviceID](...)
        end
    end
end

--@desc: 主要用于新手引导的任务跳转
function TriggerGuideLogic:StepTriggerGuide(triggerId, isClose, IsMask)
    self.StepFunc = nil
    if not self.guideIsBegin then
        self:SetOpenMask(self.guideIsBegin)
        isHiddenClipMask = false
        local guideLayer = UIMgr:GetUI("GuideLayer")
        guideLayer._guide:SetTopAnim(false)
        if IsMask then
            Event.Broadcast(EventDefines.Mask, true)
        end
        cutNoviceId = triggerId
        self.GuideTable[triggerId]()
        if isClose then
            self:SetGuidBgTouch(
                function()
                    if self.StepFunc then
                        self:CloseTriggerGuide()
                        Event.Broadcast(EventDefines.Mask, false)
                        self.StepFunc()
                    end
                end
            )
        end
    end
end

--@desc:设置引导步骤
function TriggerGuideLogic:SetScheduler(func, uiName)
    --延迟时间处理，与心跳时间相同
    local tempDelayTime = delayTime
    if uiName then
        self.fastFunc = function()
            tempDelayTime = tempDelayTime - 0.1
            if TriggerGuideLogic.CheackIsUIOpen(uiName) and tempDelayTime > 0 then
                Scheduler.UnScheduleFast(self.fastFunc)
                Scheduler.ScheduleOnceFast(
                    function()
                        func()
                    end,
                    0.2
                )
            elseif tempDelayTime <= 0 then
                Log.Error("设置引导步骤，获取UI不到UI页面，等待时间过长退出引导")
                Scheduler.UnScheduleFast(self.fastFunc)
                self:ClearTriggerGuide()
            end
        end
        --每间隔0.1秒检测ui状态
        if self.fastFunc then
            Scheduler.UnScheduleFast(self.fastFunc)
            Scheduler.ScheduleFast(self.fastFunc, 0.1)
        end
    else
        Scheduler.ScheduleOnceFast(
            function()
                func()
            end,
            onceDealy
        )
    end
end

--@desc:设置引导的下一步
function TriggerGuideLogic:SetTriggerNextStep()
    local step = TriggerGuideLogic.noviceID % 100
    Event.Broadcast(EventDefines.TriggerGuideNextStep, TriggerGuideLogic.noviceID - step, step)
end

--@desc:关闭所有引导并且算自动完成
function TriggerGuideLogic:ClearTriggerGuide()
    if GlobalVars.IsTriggerStatus then
        GD.TriggerGuideAgent.CompleteTrigger(
            GlobalVars.NowTriggerId,
            function()
                self:CloseTriggerGuide()
                self.noviceID = 0
            end
        )
    end
end

--@desc:关闭触发引导但不算触发引导完成
function TriggerGuideLogic:CloseTriggerGuide()
    if self.guideIsBegin then
        --仅在触发引导时候生效
        if not GlobalVars.IsNoviceGuideStatus then
            Event.Broadcast(EventDefines.MainUITouchEvent, true)
        end
        TriggerGuideLogic.RemoveTriggerFunc()
        self.guideIsBegin = false
        self.btnEntity = nil
        isHiddenClipMask = false
        TriggerGuideLogic.CloseMaskUI()
        Event.Broadcast(EventDefines.DelayMask, false)
        Event.Broadcast(EventDefines.GuideMask, false)
        if btnCallback then
            btnCallback = nil
        end
    end
end

--@desc:获得触发引导是否是开始的状态
function TriggerGuideLogic.IsGuideTriggering()
    return TriggerGuideLogic.guideIsBegin
end

return TriggerGuideLogic
