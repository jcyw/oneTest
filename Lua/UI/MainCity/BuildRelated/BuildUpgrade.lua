--[[    Author: songzeming
    Function: 建筑升级
]]
local GD = _G.GD
local BuildUpgrade = UIMgr:NewUI("BuildRelated/BuildUpgrade")

local UpgradeModel = import("Model/UpgradeModel")
local BuildModel = import("Model/BuildModel")
local EventModel = import("Model/EventModel")
local CommonModel = import("Model/CommonModel")
local BuffModel = import("Model/BuffModel")
local GuidePanelModel = import("Model/GuideControllerModel")
local UnionModel = import("Model/UnionModel")
local UIType = _G.GD.GameEnum.UIType
import("UI/Common/ItemCondition")
import("UI/MainCity/BuildRelated/ItemDetailText")
import("UI/MainCity/BuildRelated/BuildCommon/ItemBuildPrompt")
import("UI/MainCity/BuildRelated/BuildCommon/ItemBuildInfo")
import("UI/Common/ItemPressPrompt")

local CTR = {
    Build = "Build", -- 建造
    Upgrade = "Upgrade" -- 升级
}

local _pressPrompt = nil
local pressPromptTrue = function()
    if _pressPrompt then
        _pressPrompt:SetVisible(true)
    end
end

local pressPromptFalse = function()
    if _pressPrompt then
        _pressPrompt:SetVisible(false)
    end
end
function BuildUpgrade:OnInit()
    self._list = self._bgDown:GetChild("list")
    self._btnL = self._bgDown:GetChild("btnL")
    self._btnR = self._bgDown:GetChild("btnR")
    self._ctr = self._bgDown:GetController("Ctr")
    self._upgradeTime = self._bgDown:GetChild("upgradeTime")
    self._touchMask = self._btnR:GetChild("_touchMask")

    _pressPrompt = self._pressPrompt

    GuidePanelModel:SetParentUI(self, UIType.BuildUpgradeUI)
    local CloseGuide = function()
        Event.Broadcast(EventDefines.CloseGuide)
    end

    self._goldText = self._btnL:GetChild("text")
    self:AddListener(
        self._btnL.onClick,
        function()
            self:CheckGoldUpgrade()
            CloseGuide()
            --AudioModel.StopSpeech()
        end
    )
    self:AddListener(
        self._btnR.onClick,
        function()
            self:ClickUpdate(self:GetABTest())
            CloseGuide()
            --AudioModel.StopSpeech()
            if self.triggerFunc then
                self.triggerFunc()
            end
        end
    )
    self:AddListener(
        self._btnReturn.onClick,
        function()
            self.isClickReturn = true
            UIMgr:Close("BuildRelated/BuildUpgrade")
            CloseGuide()
            --AudioModel.StopSpeech()
        end
    )

    self:AddEvent(
        EventDefines.UIResetBuilder,
        function()
            if self.Controller.parent then
                self:ResetData()
            end
        end
    )
    self:AddEvent(
        EventDefines.UIResourcesDisplayClose,
        function()
            self:ResetData()
        end
    )

    self.abTestB = ABTest.BuildingLevelUp_Logic() == 4002
end

function BuildUpgrade:OnOpen(pos, building, isBanScroll)
    Log.Info("是否为B方案 abTestB:{0}", self.abTestB)
    self.pos = pos
    self.IsVisible = true
    self.createBuilding = building
    self.isClickReturn = false
    self.isGuide = false
    self.isCreate = self.createBuilding and true or false

    if not self.isCreate and not isBanScroll then
        ScrollModel.Scale(pos, true)
    end

    self:UpdateData()

    local info = BuildModel.FindByPos(self.pos)
    if info then
        local config = ConfigMgr.GetItem("configBuildings", info.ConfId)
        local sound = config.building_click_line
        if sound then
            AudioModel.Play(sound)
        end
    end

    self:TouchDescShow()

    self._touchMask.visible = self:GetShowTouchMask()
end

function BuildUpgrade:GetShowTouchMask()
    return self.isGuide or GlobalVars.IsTriggerStatus
end

function BuildUpgrade:CloseCreate()
    if UIMgr:GetUIOpen("BuildRelated/BuildCreate") then
        UIMgr:Close("BuildRelated/BuildCreate")
    end
end

function BuildUpgrade:OnClose()
    self.IsVisible = false
    --Log.Error("----------------------------------")
    --AudioModel.StopSpeech()
    if self.createBuilding then
        if ScrollModel.GetScaling() then
            return
        end
        if self.isClickReturn then
            self.isClickReturn = false
            ScrollModel.LRMove(1, true)
        else
            if ScrollModel.GetWhetherMoveScale() then
                return
            else
                if self.isGuide then
                    ScrollModel.LRMove(1, true)
                else
                    ScrollModel.LRMove(1, false)
                end
            end
        end
    else
        self:CloseCreate()
    end
    self.isGuide = false

    self:RemoveListener(self._touchDescGesture.onBegin, pressPromptTrue)
    self:RemoveListener(self._touchDescGesture.onEnd, pressPromptFalse)
end

function BuildUpgrade:UpdateData()
    self.isCondition = false
    self._prompt:ResetImageList()
    self:ResetData()
end

-- 重置显示
function BuildUpgrade:ResetData()
    if self.createBuilding then
        --创建建筑
        self._ctr.selectedPage = CTR.Build
        self.building = self.createBuilding
        self.confId = self.building.id
        self.level = 0
    else
        --升级建筑
        self.building = BuildModel.FindByPos(self.pos)
        self._ctr.selectedPage = CTR.Upgrade
        self.confId = self.building.ConfId
        self.level = self.building.Level
    end

    if self.level >= BuildModel.GetConf(self.confId).max_level then
        -- 升级到最大等级 关闭界面
        UIMgr:Close("BuildRelated/BuildUpgrade")
        return
    end

    self:ShowText()
    self:ShowCondition()
    self:ShowGold()
    self._prompt:InitUpgrade(self.confId, self.level, self.pos)
    local type = GuidePanelModel.uiType
    local isGuideShow = false
    if type == UIType.BuildCreateUI then
        isGuideShow = GuidePanelModel:IsGuideState(self.pos, _G.GD.GameEnum.JumpType.Create)
    else
        isGuideShow = GuidePanelModel:IsGuideState(self.building, _G.GD.GameEnum.JumpType.Upgrade)
    end
    if isGuideShow == true then
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BuildUpgradeUI)
    end
end

-- 显示文本
function BuildUpgrade:ShowText()
    self.infoName = BuildModel.GetName(self.confId)
    local infoLevel = StringUtil.GetI18n(I18nType.Commmon, "Ui_Level", {number = self.level})
    self._info:Init(infoLevel, self.infoName)
    local nextLv = self.level + 1
    local nextConf = ConfigMgr.GetItem("configBuildingUpgrades", self.confId + nextLv)
    self.updateTime = math.ceil(nextConf.duartion / BuffModel.GetBuildSpeed())
    self._upgradeTime.text = Tool.FormatTime(self.updateTime)
    self._pressPrompt:SetArrowRight(BuildModel.GetInfo(self.confId))
end

-- 显示升级需要满足的条件
function BuildUpgrade:ShowCondition()
    self._list:RemoveChildrenToPool()
    local isCondition = true
    local count = 0
    local cond_func = function(data)
        local item = self._list:AddItemFromPool()
        count = count + 1
        data.index = count
        item:Init(data)
        if not data.IsSatisfy then
            isCondition = false
        end
    end
    --条件
    local confId = self.confId + self.level + 1
    local conf = ConfigMgr.GetItem("configBuildingUpgrades", confId)
    -- 队列中
    local builders = {}
    if not CommonModel.CheckFreeBuilder() then
        --没有免费队列显示队列中的建筑
        for k, v in pairs(Model.Builders) do
            if v.IsWorking then
                local building = Model.Find(ModelType.Buildings, v.EventId)
                builders[k] = building.ConfId
                local event = EventModel.GetUpgradeEvent(v.EventId)
                local type = "" -- 跳转、加速、免费、获取
                local t = event.FinishAt - Tool.Time()
                if t > CommonModel.FreeTime() then
                    type = BuildType.CONDITION.Accelerate
                else
                    type = BuildType.CONDITION.Free
                end
                local isInCondition = false
                local levelCondition = 0
                local maxBuilding = BuildModel.FindMaxLevel(building.ConfId)
                for _, vc in pairs(conf.condition) do
                    if vc.confId == maxBuilding.ConfId and maxBuilding.Level < vc.level then
                        isInCondition = true
                        levelCondition = vc.level
                        break
                    end
                end
                local data = {
                    Icon = UITool.GetIcon(BuildModel.GetBuildIconSmall(building.ConfId)),
                    Level = building.Level,
                    Title = BuildModel.GetName(building.ConfId),
                    IsSatisfy = false,
                    Type = type,
                    Event = event,
                    IsQueue = true,
                    LevelCondition = levelCondition,
                    IsInCondition = isInCondition,
                    Callback = function(cbType)
                        if cbType == BuildType.CONDITION.Accelerate then
                            -- 加速
                            local acc_func = function(flag)
                                if flag then
                                    self:ResetData()
                                end
                            end
                            UIMgr:Open("BuildAcceleratePopup", building, acc_func)
                        elseif cbType == BuildType.CONDITION.Free then
                            -- 免费
                            local node = BuildModel.GetObject(building.Id)
                            local reset_func = function()
                                self:ResetData()
                            end
                            node:ClickFree(event, reset_func)
                        end
                    end
                }
                cond_func(data)
            end
        end
    end
    -- 升级条件
    for _, v in pairs(conf.condition) do
        if builders[0] ~= v.confId and builders[1] ~= v.confId then
            local isCon = false -- 是否满足条件
            local type = "" -- 跳转、加速、免费、获取
            local event, icon
            local building = BuildModel.FindMaxLevel(v.confId)
            local abLevel = 0
            if ABTest.Task_ABLogic() == 2002 and ABTest.GodzilaGuideAB_Logic() == 6002 and self.confId == Global.BuildingBeastBase and v.confId == Global.BuildingCenter then
                --abLevel = 8
                abLevel = v.level
            else
                abLevel = v.level
            end
            if building then
                icon = UITool.GetIcon(BuildModel.GetBuildIconSmall(building.ConfId))
                isCon = building.Level >= abLevel

                event = EventModel.GetUpgradeEvent(building.Id)
                if event then
                    local t = event.FinishAt - Tool.Time()
                    if t > CommonModel.FreeTime() then
                        type = BuildType.CONDITION.Accelerate
                    else
                        type = BuildType.CONDITION.Free
                    end
                else
                    type = BuildType.CONDITION.Turn
                end
            else
                --建筑不存在 跳转修建建筑
                icon = UITool.GetIcon(BuildModel.GetBuildIconSmall(v.confId))
                isCon = false
                type = BuildType.CONDITION.Turn
            end
            local values = {
                building_name = BuildModel.GetName(v.confId),
                building_level = abLevel
            }
            local name = StringUtil.GetI18n(I18nType.Commmon, "Tech_Text4", values)
            local data = {
                Icon = icon,
                Title = name,
                IsSatisfy = isCon,
                NoUpgrade = not isCon,
                Type = type,
                Callback = function(cbType)
                    if cbType == BuildType.CONDITION.Turn then
                        -- 跳转
                        if ScrollModel.GetScaling() then
                            return
                        end
                        ScrollModel.Scale(nil, false)
                        ScrollModel.ForceStop()
                        local goldPos = building and building.Pos or BuildModel.GetCreatPos(v.confId)
                        local piece = CityMapModel.GetCityMap():GetMapPiece(goldPos)
                        if v.confId == _G.Global.BuildingCenter then
                            _G.ScrollModel.Move(piece.x + _G.BuildType.OFFSET_CENTER.x, piece.y + _G.BuildType.OFFSET_CENTER.y, false)
                        else
                            _G.ScrollModel.Move(piece.x, piece.y, false)
                        end
                        local function cb()
                            --[[
                                在跳转到前置升级任务时 此处self.createBuilding置空 
                                则此界面在关闭时就不会有地图移动动画 避免镜头偏移
                            ]]
                            self.createBuilding = nil
                            UIMgr:Close("BuildRelated/BuildUpgrade")
                            self:CloseCreate()
                            local e = EventModel.GetEvent(building)
                            if building and not e then
                                UIMgr:Open("BuildRelated/BuildUpgrade", building.Pos)
                            else
                                if piece:GetPieceActive() then
                                    TurnModel.BuildTurnCreatePos(v.confId)
                                else
                                    TurnModel.BuildFuncDetail(v.confId, nil, true)
                                end
                            end
                        end
                        ScrollModel.SetCb(cb)
                    elseif cbType == BuildType.CONDITION.Accelerate then
                        -- 加速
                        local acc_func = function(flag)
                            if flag then
                                self:ResetData()
                            end
                        end
                        UIMgr:Open("BuildAcceleratePopup", building, acc_func)
                    elseif cbType == BuildType.CONDITION.Free then
                        -- 免费
                        local node = BuildModel.GetObject(building.Id)
                        local reset_func = function()
                            self:ResetData()
                        end
                        node:ClickFree(event, reset_func)
                    end
                end
            }
            cond_func(data)
        end
    end
    --消耗道具 联合指挥部
    if self.confId == Global.BuildingJointCommand then
        local item = Model.Items[GlobalItem.ItemUpgradeJointCommand]
        local amount = 0
        if item then
            amount = item.Amount
        end
        local values = {
            own_num = amount,
            need_num = conf.item.amount
        }
        local name = StringUtil.GetI18n(I18nType.Commmon, "UI_GETMORE_ASSEMBLY", values)
        local icon = UITool.GetIcon(ConfigMgr.GetItem("configItems", GlobalItem.ItemUpgradeJointCommand).icon)
        local data = {
            Icon = icon,
            Title = name,
            IsSatisfy = amount >= conf.item.amount,
            Type = BuildType.CONDITION.ItemObtain,
            Callback = function()
                local mData = {
                    from = CommonType.LONG_ITEM_BOX_DISPLAY.JointCommandUpgrade,
                    cb = function()
                        self:ResetData()
                    end
                }
                UIMgr:Open("LongItemBox/LongItemDisplay", mData)
            end
        }
        cond_func(data)
    end
    -- 消耗条件
    for _, v in pairs(conf.res_req) do
        if v.amount > 0 then
            local data = {
                Icon = UITool.GetIcon(ConfigMgr.GetItem("configResourcess", v.category).img),
                Title = Tool.FormatNumberThousands(v.amount),
                IsSatisfy = Model.Resources[v.category].Amount >= v.amount,
                Type = BuildType.CONDITION.ResObtain,
                Category = v.category,
                IsRes = true,
                Amount = v.amount,
                Callback = function()
                    -- 获取资源
                    local reset_func = function()
                        self:ResetData()
                    end
                    UIMgr:Open("ResourceDisplay", v.category, v.category, v.amount - Model.Resources[v.category].Amount, reset_func)
                end
            }
            cond_func(data)
        end
    end
    self.isCondition = isCondition
    self._list:EnsureBoundsCorrect()
    self._list.scrollPane.touchEffect = self._list.scrollPane.contentHeight > self._list.height
end

-- 显示金币消耗
function BuildUpgrade:ShowGold()
    local freeTime = CommonModel.FreeTime()
    local timeGold = Tool.TimeTurnGold(self.updateTime, freeTime)
    local resGold = 0
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local cond = item:GetCondition()
        if not cond.IsSatisfy and cond.Type == BuildType.CONDITION.ResObtain then
            local category = item:GetCategory()
            local amount = item:GetAmount()
            local diffAmount = amount - Model.Resources[category].Amount
            resGold = resGold + Tool.ResTurnGold(cond.Category, diffAmount)
        end
    end
    self.resGold = resGold
    self.goldNumber = timeGold + resGold
    local r18n = self._ctr.selectedPage == CTR.Build and "BUTTON_BUILD" or "BUTTON_UPGRADE"
    if self.goldNumber > 0 then
        self._goldText.text = UITool.UBBTipGoldText(self.goldNumber)
        self._btnR.title = StringUtil.GetI18n(I18nType.Commmon, r18n)
    else
        self._goldText.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_Free")
        if self.abTestB then
            self._btnR.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_Free")
        else
            self._btnR.title = StringUtil.GetI18n(I18nType.Commmon, r18n)
        end
    end
end

-- 点击金币升级检测
function BuildUpgrade:CheckGoldUpgrade()
    if self.goldNumber <= Model.Player.Gem then
        self:ClickUpdate(true)
    else
        UITool.GoldLack()
    end
end
--资源不足提示
function BuildUpgrade:OnResPopup()
    --什么资源差多少
    local lackRes = {}
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local condition = item:GetCondition()
        if not condition.IsSatisfy and condition.IsRes then
            local category = item:GetCategory()
            local amount = item:GetAmount()
            local diffAmount = amount - Model.Resources[category].Amount
            if diffAmount > 0 then
                table.insert(lackRes, {Category = category, Amount = diffAmount})
            end
        end
    end

    local data = {
        textTip = StringUtil.GetI18n(I18nType.Commmon, self.isCreate and "Tech_Res_Text4" or "Tech_Res_Text3"),
        lackRes = lackRes,
        textBtnSure = StringUtil.GetI18n(I18nType.Commmon, self.isCreate and "BUTTON_BUILD" or "BUTTON_UPGRADE"),
        isBuild = self.isCreate,
        updateTime = self.updateTime,
        titleText = self.infoName,
        cbBtnSure = function()
            self:ResetData()
            local isNoUpgrade = false --是否不需要升级
            local isInCondition = false --是否需要其他条件（不能升级）
            for i = 1, self._list.numChildren do
                local child = self._list:GetChildAt(i - 1)
                local condition = child:GetCondition()
                if condition.IsInCondition then
                    isInCondition = true
                    break
                end
                if condition.NoUpgrade then
                    isNoUpgrade = true
                end
            end
            if isInCondition then
                TipUtil.TipById(50277)--此建筑物没有满足前置建筑需求
                return
            end
            if not isNoUpgrade then
                self:ToUpgrade(false)
            end
        end
    }
    UIMgr:Open("ConfirmPopupDissatisfaction", data)
end
-- 点击升级/立即升级
function BuildUpgrade:ClickUpdate(isNow)
    local tip_func = function()
        if not isNow or self.goldNumber == 0 then
            self:ToUpgrade(isNow)
            return
        end
        local values = {
            diamond_num = self.goldNumber
        }
        local textContent = StringUtil.GetI18n(I18nType.Commmon, "Ui_CompleteNow_Up", values)
        if self.level == 0 then
            textContent = StringUtil.GetI18n(I18nType.Commmon, "Ui_CompleteNow_Build", values)
        end
        local data = {
            content = textContent,
            tipType = TipType.TYPE.ConditionUpgrade,
            gold = self.goldNumber,
            sureCallback = function()
                self:ToUpgrade(isNow)
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end
    if not self.isCondition then
        local freeQueue = Model.Builders[BuildType.QUEUE.Free]
        local chargeQueue = Model.Builders[BuildType.QUEUE.Charge]
        local chargeQueueActiveTime = chargeQueue.ExpireAt - Tool.Time()
        local resNum = 0
        local queueNum = 0 --正在建筑的队列数
        local isNoUpgrade = false
        local isInCondition = false --是否需要其他条件（不能升级）
        local needResList = {}
        for i = 1, self._list.numChildren do --播放未满足的子项动画
            local child = self._list:GetChildAt(i - 1)
            local condition = child:GetCondition()
            if not condition.IsSatisfy then
                child:PlayAnim()
            end
        end
        for i = 1, self._list.numChildren do
            local child = self._list:GetChildAt(i - 1)
            local condition = child:GetCondition()
            if not condition.IsSatisfy then
                if condition.IsRes then
                    resNum = resNum + 1
                    needResList[resNum] = {resType = condition.Category,needCount = condition.Amount - GD.ResAgent.Amount(condition.Category)}
                end
            end
            if condition.IsInCondition then
                isInCondition = true
                break
            end
            if condition.IsQueue then
                queueNum = queueNum + 1
            end
            if condition.NoUpgrade then
                isNoUpgrade = true
            end
        end
        if isInCondition then
            TipUtil.TipById(50277)--此建筑物没有满足前置建筑需求
            JumpMap:JumpTo({jump = 819000})
            return
        end
        if (queueNum == 1 and freeQueue.IsWorking and chargeQueueActiveTime <= 0) --只有一个队列，第二队列未开放
            or queueNum == 2 then--两个队列都占满
            tip_func()
            return
        elseif not isNow and resNum > 0 and not isNoUpgrade then --资源不够
            local canUseItemToFill = true
            for k,v in pairs(needResList) do
                if not GD.ItemAgent.CanBackPackItemFillResNeed(v.resType,v.needCount) then
                    canUseItemToFill = false
                    break
                end
            end
            if not canUseItemToFill then
                self:OnResPopup()
            else
                UIMgr:Open("ComfirmPopupUseRes", needResList,function()
                        self:ToUpgrade(false)
                        self:ResetData()
                    end)
            end
            return
        end
    end
    if not self.isCondition then
        local isFirst = true
        local isBuildCond = true

        for i = 1, self._list.numChildren do
            local child = self._list:GetChildAt(i - 1)
            local condition = child:GetCondition()
            if not condition.IsSatisfy then
                if condition.NoUpgrade then
                    isBuildCond = false
                end
                if isFirst and condition.Type ~= BuildType.CONDITION.ResObtain then
                    isFirst = false
                    self._list.scrollPane:SetPercY(i / self._list.numChildren)
                end
            end
        end
        if not isNow then
            TipUtil.TipById(50105)--"没有满足条件的建筑！",
            JumpMap:JumpTo({jump = 819000})
            return
        end
        if isBuildCond then
            tip_func()
        else
            JumpMap:JumpTo({jump = 819000})
            TipUtil.TipById(50105)--"没有满足条件的建筑！",
        end
    else
        tip_func()
    end
end

function BuildUpgrade:GetABTest()
    return self.abTestB and self.goldNumber == 0 and not GlobalVars.IsNoviceGuideStatus and not self.isGuide and not GlobalVars.IsTriggerStatus
end

function BuildUpgrade:ToUpgrade(isNow)
    if not isNow then --and not BuildModel.CheckBuilder(self.isCreate and "Build" or "Upgrade", self.updateTime, self.infoName) then --列队满了
        local canbuild,buildQueueFull = BuildModel.CheckBuilder(self.isCreate and "Build" or "Upgrade", self.updateTime, self.infoName)
        if not canbuild then
            if buildQueueFull then
                JumpMap:JumpTo({jump = 819000})
                --BuildModel.CheckBuilder 会弹建筑队列已满的提示
            else
                -- JumpMap:JumpTo({jump = 819000})
                -- TipUtil.TipById(50277)--"此建筑物没有满足前置建筑需求",
            end
            return
        end
    end
    if self.isCreate then
        --建造
        local create_func = function(rsp)
            AudioModel.Play(40017)
            Model.Create(ModelType.Buildings, rsp.Building.Id, rsp.Building)
            if rsp.ResAmounts then
                Event.Broadcast(EventDefines.UIResourcesAmount, rsp.ResAmounts)
            end
            if rsp.Event then
                Model.Create(ModelType.UpgradeEvents, rsp.Event.Uuid, rsp.Event)
            end
            Event.Broadcast(EventDefines.UICityAddBuild, rsp.Building)
            --Boot steps建造后触发引导入口
            Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.EndLvUp, rsp.Building.ConfId, {rsp.Building.Level, 4})

            UIMgr:Close("BuildRelated/BuildUpgrade")
            self:CloseCreate()
            if isNow then
                --立即建造
                UnionModel.CheckJoinPush(rsp.Building.ConfId, rsp.Building.Level)
                local values = {
                    build_name = BuildModel.GetName(rsp.Building.ConfId),
                    build_level = rsp.Building.Level
                }
                TipUtil.TipById(50102, values)
                BuildModel.UpgradePrompt()
                Event.Broadcast(EventDefines.NoviceGuideBuildUpgrade, rsp.Building.ConfId)
                --播放特效
                local node = BuildModel.GetObject(rsp.Building.Id)
                node:PlayEffect()
            else
                Event.Broadcast(EventDefines.UIResetBuilder)
            end
            --保存建造记录
            PlayerDataModel:SetData(PlayerDataEnum.BUILD_CREATE, rsp.Building.ConfId)
        end
        Net.Buildings.Create(self.pos, self.confId, isNow, create_func)
    else
        --升级
        local upgrade_func = function(rsp)
            if rsp.Event then
                Model.Create(ModelType.UpgradeEvents, rsp.Event.Uuid, rsp.Event)
            end
            if rsp.Gem then
                Event.Broadcast(EventDefines.UIGemAmount, rsp.Gem)
            end
            local node = BuildModel.GetObject(self.building.Id)
            if not isNow then
                UIMgr:Close("BuildRelated/BuildUpgrade")
                -- if self.building.ConfId == Global.BuildingCenter then
                --     ScrollModel.CenterMoveScale()
                -- end
                --设置本地巨兽巢穴梯级提升弹窗标识
                if self.building.ConfId == Global.BuildingGodzilla then
                    BuildModel.SetGodzillaUpgradingMark(self.building.Level)
                elseif self.building.ConfId == Global.BuildingKingkong then
                    BuildModel.SetKingkongUpgradingMark(self.building.Level)
                end
                node:ResetCD()
                WeatherModel.CheckWeatherRain()
                Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.StartLvUp, self.building.ConfId, self.building.Level + 1)
            else
                node:UpgradeEnd(rsp.Building.Level)
                Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.EndLvUp, self.building.ConfId, {self.building.Level, 1})
                Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.NoTrigger, self.building.ConfId, self.building.Level)
            end
            if self.building.ConfId == Global.BuildingCenter then
                SdkModel.TrackBreakPoint(10055, self.building.Level) --打点
            end
            self:ResetData()
            if rsp.ResAmounts then
                Event.Broadcast(EventDefines.UIResourcesAmount, rsp.ResAmounts)
            end
        end
        local func = function()
            Net.Buildings.Upgrade(self.building.Id, isNow, upgrade_func)
        end

        if self.building.ConfId == Global.BuildingCenter and self.building.Level == 5 and BuffModel.CheckIsProtect() and Model.User.RookieShield then
            -- 当玩家将基地升级到6级且身上的新手保护罩仍然有效时
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "TIPS_NEWBIE_PROTECT"),
                buttonType = "double",
                sureCallback = func
            }
            UIMgr:Open("ConfirmPopupText", data)
        else
            func()
        end
    end
end
function BuildUpgrade:GetChild(str)
    return self.Controller.contentPane:GetChild(str)
end

--指引动画
function BuildUpgrade:GuildShow()
    self.isGuide = true
    self._touchMask.visible = self:GetShowTouchMask()
    local btn = nil
    if self._btnL then
        --新手引导特殊处理
        if GlobalVars.IsNoviceGuideStatus == true and Model.Player.GuideVersion == 0 and self.confId == 424000 then
            btn = self._btnL
        else
            btn = self._btnR
        end
    end
    return btn
end

--描述框触摸显示
function BuildUpgrade:TouchDescShow()
    self._touchDescGesture = UIMgr:GetLongPressGesture(self._touchDesc)
    self._touchDescGesture.trigger = 0
    self:AddListener(self._touchDescGesture.onBegin, pressPromptTrue)
    self:AddListener(self._touchDescGesture.onEnd, pressPromptFalse)
end

function BuildUpgrade:TriggerOnclick(callback)
    self.triggerFunc = callback
end

return BuildUpgrade
