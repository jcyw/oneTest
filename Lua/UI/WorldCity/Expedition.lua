import("UI/Common/ItemKeyboard")
local ArmiesModel = import("Model/ArmiesModel")
local MapModel = import("Model/MapModel")
local MissionEventModel = import("Model/MissionEventModel")
local Expedition = UIMgr:NewUI("Expedition")
local MonsterModel = import("Model/MonsterModel")
local JumpMapModel = import("Model/JumpMapModel")
local TaskModel = import("Model/TaskModel")
local UnionWarfareModel = import("Model/Union/UnionWarfareModel")
local GlobalVars = GlobalVars
local MarchAnimModel = import("Model/MarchAnimModel")

--出征士兵缓存数据
local armiesData
local isInit = false
local textKey = ""

local messageTypeMap = {
    [ExpeditionType.AttackPlayer] = function(self)
        --进攻玩家
        return Global.MissionAttack
    end,
    [ExpeditionType.Mining] = function(self)
        if not self.data.mineAttach then
            --进行采矿
            return Global.MissionMining
        end
    end,
    [ExpeditionType.Pve] = function(self)
        --进攻野怪
        return Global.MissionPVE
    end,
    [ExpeditionType.UnionAttack] = function(self)
        --发起集结进攻
        local area = MapModel.GetArea(self.posNum)
        if area and area.Category == Global.MapTypeTown then
            return Global.MissionAttack
        end
    end,
    [ExpeditionType.JoinUnionAttack] = function(self)
        --加入集结战争
        return Global.MissionRally
    end,
    [ExpeditionType.JoinUnionDefense] = function(self)
        -- 援助士兵
        return Global.MissionAssit
    end
}

function Expedition:OnInit()
    local view = self.Controller.contentPane
    self._textFastSelection = self._btnFastSelection:GetChild("title") --快速选择文本
    self._textExpedition = self._btnExpedition:GetChild("title")
    self._expeditionTime.sortingOrder = 1
    self._btnExpedition.sortingOrder = 2

    self._btnSortList = {}
    self.mosterGroup = {}
    self.isQuickSelect = true
    self.selectType = 0

    self.keyboard = UIMgr:CreatePopup("Common", "itemKeyboard")

    for i = 1, 4 do
        self._btnSortList[i] = view:GetChild("btn" .. i)
    end
    --
    --[[状态控制器
    0 进攻空地
    1 进攻野怪
    2 进攻玩家或者资源
    ]] self._statusController = view:GetController("c3")

    self.func_numChange = function()
        if isInit then
            self._textTroops.text = ArmiesModel.GetExpetionNum(self.armyLimit)
            self._textBattleNum.text = ArmiesModel.GetTotalAttack()
            self:updateTextResource()
            self:RefreshTime()
            self:SetPveTip()
        end
    end

    self.func_limitChange = function()
        if self.data then
            local selfMarchLimit = ArmiesModel.GetMarchLimit()
            self.armyLimit = (self.data.amryLimit == nil or self.data.amryLimit < selfMarchLimit) and self.data.amryLimit or selfMarchLimit
            self._textTroops.text = ArmiesModel.GetExpetionNum(self.armyLimit)
            
            self:ChangeSelectType(self.curSelectType)
            self:updateTextResource()
            self:RefreshMosterList()
        end
    end

    self.func_monster = function(item)
        ArmiesModel.SetExpeditionBeast(item.model, not ArmiesModel.GetExpeditionBeastById(item.model.Id))

        for _,v in pairs(self.mosterGroup) do
            if v.config.id ~= item.config.id then
                v._checkBox.selected = false
                ArmiesModel.SetExpeditionBeast(v.model, false)
            end
        end
    end

    self:OnRegister()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.WorldExpedition)
end

function Expedition:OnRegister()
    self._group.visible = false
    self:AddListener(self._btnAdd.onClick,
        function()
            -- body
            _G.UIMgr:Open("ExpeditionUpperLimit")
        end
    )
    self:AddListener(self._btnAddSp.onClick,
        function()
            --UIMgr:Open("MarchAP")
            _G.UIMgr:Open("PlayerItem/PlayerItem", "Hp")

        end
    )
    self:AddListener(self._btnSelectType.onClick,
        function()
            self._group.visible = not self._group.visible
        end
    )
    self:AddListener(self._btnReturn.onClick,
        function()
            _G.UIMgr:Close("Expedition")
        end
    )
    for i = 1, 4 do
        self:AddListener(self._btnSortList[i].onClick,
            function()
                if not self.isQuickSelect then
                    self._textFastSelection.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CANCEL_SELECT")
                    self.isQuickSelect = true
                end
                self._btnSelectType.icon = self._btnSortList[i]:GetChild("icon").icon
                self.curSelectType = i
                self:ChangeSelectType(i)
            end
        )
    end
    self:AddListener(self._btnFastSelection.onClick,
        function()
            self:QuickSelect()
        end
    )

    self:AddListener(self._btnExpedition.onClick,
        function()
            self:BtnExpeditionOnClick()
        end
    )
    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                info = StringUtil.GetI18n(I18nType.Commmon, "UI_LOAD_TEXT")
            }
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )
    self:AddListener(self._btnGain.onClick,
        function()
            UIMgr:Open("BaseGain", Global.PageMarchBuff)
        end
    )

    self._listContent:SetVirtual()
    self._listContent.scrollItemToViewOnClick = false

    self._listContent.itemRenderer = function(index, item)
        local itemInfo = self.listData[index + 1]
        local data = {}
        data.info = ArmiesModel.GetExpeditionArmy(itemInfo.id)
        data.initCount = data.info.NowCount
        data.maxCount = data.info.Amount
        data.type = ExpeditionItemType.number
        data.keyboard = self.keyboard
        data.keyboardCb = function(txtInput)
            UIMgr:ShowPopup("Common", "itemKeyboard", txtInput)
        end

        item:Init(data)
    end
end

--[[data:
    openType -- 界面类型 ExpeditionType
    posNum -- 出征位置
    amryLimit -- 士兵援助对象部队容量
    battleId -- 集结id
    monsterId -- 怪物id
    assistId -- 援助玩家id
]]
function Expedition:OnOpen(data, isGuide)
    self:AddEvent(EventDefines.UIOnExpetionNumChange, self.func_numChange)
    self:AddEvent(EventDefines.UIOnExpeditionLimitChange, self.func_limitChange)

    UnlockModel:UnlockCenter(UnlockModel.Center.Gain, self._btnGain)

    --检查出征上限，上限已满则返回提示
    if ArmiesModel.CheckMissionLimit() then
        UIMgr:Close("Expedition")
        return
    end

    ArmiesModel.ClearArmies()
    ArmiesModel.Init()
    if ArmiesModel.GetAllCount() <= 0 then
        TipUtil.TipById(10003)
        UIMgr:Close("Expedition")
    end

    isInit = false
    local selfMarchLimit = ArmiesModel.GetMarchLimit()
    self.data = data
    self.assistLimit = nil
    self.posNum = data.posNum
    self.armyLimit = (data.amryLimit == nil or data.amryLimit < selfMarchLimit) and data.amryLimit or selfMarchLimit
    self.messageType = data.openType
    self._group.visible = false
    self._textFastSelection.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CANCEL_SELECT")
    self.isQuickSelect = true
    self.resourceWeight = nil
    self.isJump = false

    -- 矿点出征默认选择负重优先，其余选择搭配优先
    if self.messageType == ExpeditionType.Mining and not data.mineAttach then
        self._btnSortList[2].selected = true
        self._btnSelectType.icon = self._btnSortList[2]:GetChild("icon").icon
        self.curSelectType = 2
    else
        self._btnSortList[4].selected = true
        self._btnSelectType.icon = self._btnSortList[4]:GetChild("icon").icon
        self.curSelectType = 4
    end

    isInit = true
    self.curTeam = 0
    self._textTroops.text = ArmiesModel.GetExpetionNum(self.armyLimit)

    if self.messageType == ExpeditionType.AttackPlayer or self.messageType == ExpeditionType.Mining or 
    ((self.messageType == ExpeditionType.UnionAttack or self.messageType == ExpeditionType.JoinUnionAttack) and not self.data.monsterId) then
        --进攻类型、获取资源 显示总负重
        self._statusController.selectedIndex = 2
        local isJump = JumpMapModel:GuideStage()
        if isJump then
            -- 采矿引导
            local jumpId = JumpMapModel:GetJumpId()
            local finish = JumpMapModel:GetFinishiParams()
            self.assistLimit = finish.para2
            self.isJump = true
        else
            self:CalExpeditionLoadRes()
        end
    elseif self.messageType == ExpeditionType.Pve or 
    ((self.messageType == ExpeditionType.UnionAttack or self.messageType == ExpeditionType.JoinUnionAttack) and self.data.monsterId) then
        --进攻野怪 显示体力
        self._statusController.selectedIndex = 1
        -- local info = MapModel.GetArea(self.posNum)
        -- if not info then
        --     return
        -- end
        local config = ConfigMgr.GetItem("configMonsters", self.data.monsterId)
        self._textResource.text = config.usePower
    else
        --空地或者其他都不显示
        self._statusController.selectedIndex = 0
    end

    self:RefreshMosterList()
    self:ChangeSelectType(self.curSelectType)
    self:updateTextResource()
    self:SetAimTip()

    self._btnTroops:Init(
        nil,
        true,
        function(index, formation, name)
            if not formation then
                self._btnTroops:SelectedBtn(self.curTeam)
                data.content = StringUtil.GetI18n(I18nType.Commmon, "FOMATION_UNFOMRED_TIPS")
                data.sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
                data.sureCallback = function()
                    UIMgr:Open("TroopsDetailsFormation", index)
                end
                UIMgr:Open("ConfirmPopupText", data)
                return
            end

            self.curTeam = index

            -- 原编队士兵总数
            local formationAmount = 0
            for _,v in pairs(formation.Armies) do
                formationAmount = formationAmount + v.Amount
            end

            -- 获取编队兵种配置数量
            armiesData = {}
            ArmiesModel.ClearArmies()
            local temp = {}
            local armies = GameUtil.Clone(ArmiesModel.Init())
            for _, v in pairs(formation.Armies) do
                for _, v1 in pairs(armies) do
                    if v1.id == v.ConfId then
                        v1.NowCount = v.Amount <= v1.Amount and v.Amount or v1.Amount
                        -- ArmiesModel.SetExpeditionArmies(v1.id, v1.NowCount, v1.Amount)
                        temp[v1.id] = v1
                        table.insert(armiesData, v1)
                        break
                    end
                end
            end

            -- 将编队里的兵种数量设置到出征数据中去
            local rate = 1
            if self.armyLimit < formationAmount then
                --当原编队士兵总数大于当前出征上限
                rate = self.armyLimit / formationAmount
            end
            for _,v in pairs(armiesData) do
                v.NowCount = math.floor(v.NowCount * rate)
                ArmiesModel.SetExpeditionArmies(v.id, v.NowCount, v.Amount)
            end

            -- 将未在编队里的兵种选择数量设为0
            for _, v in pairs(armies) do
                if not temp[v.id] then
                    v.NowCount = 0
                    ArmiesModel.SetExpeditionArmies(v.id, v.NowCount, v.Amount)
                    table.insert(armiesData, v)
                end
            end

            self:RefreshItems()

            for _,v in pairs(self.mosterGroup) do
                v:SetSelected(false)
                for _,v1 in pairs(formation.Beasts) do
                    if v.model.Id == v1 then
                        v:SetSelected(true)
                        break;
                    end
                end
            end

            self._textTroops.text = ArmiesModel.GetExpetionNum(self.armyLimit)
            if not self.isQuickSelect then
                self._textFastSelection.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CANCEL_SELECT")
                self.isQuickSelect = true
            end
        end
    )
    if isGuide then
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1,_G.GD.GameEnum.UIType.ExpeditionUI)
    end
end

function Expedition:OnClose()
    self._listContent.numItems = 0
    Event.Broadcast(EventDefines.CloseGuide)
    Event.RemoveListener(EventDefines.UIOnExpetionNumChange, self.func_numChange)
    Event.RemoveListener(EventDefines.UIOnExpeditionLimitChange, self.func_limitChange)
end

function Expedition:RefreshItems()
    self.listData = armiesData
    self._listContent.numItems = #armiesData

    self:RefreshTime()
    self._textBattleNum.text = ArmiesModel.GetTotalAttack()

    self:SetPveTip()
end

function Expedition:RefreshMosterList()
    self.mosterGroup = {}
    
    local beasts = {}
    for _,v in pairs(MonsterModel.GetBeastModels()) do
        table.insert(beasts, v)
    end
    table.sort(beasts, function(a, b)
        return a.Id < b.Id
    end)
    local selected = nil
    -- 采矿引导不默认选择巨兽
    if not (self.curSelectType == 2 and self.isJump) then
        for _,v in pairs(beasts) do
            if MonsterModel.IsUnlock(v.Id) and not ArmiesModel.IsBeastExpedition(v.Id) then
                local power = MonsterModel.GetMonsterRealPower(v.Id, v.Level)
                if selected == nil or power > selected.power then
                    selected = v
                    selected.power = power
                end
            end
        end
    end
    self._listMonster:RemoveChildrenToPool()
    for _,v in pairs(beasts) do
        local item = self._listMonster:AddItemFromPool()
        local isSelected = (selected and (v.Id == selected.Id) and true or false)
        table.insert(self.mosterGroup, item)
        item:Init(v, isSelected, false, self.func_monster)
    end
end

function Expedition:ExpeditionCallback(val)
    --刷新当前军队数量
    if (val.Armies) then
        -- Event.Broadcast(EventDefines.UIOnArmiesChange, val.Armies)
        ArmiesModel.RefreshArmies(val.Armies)
    end
    if (val.Event) then
        Event.Broadcast(EventDefines.UIOnMissionInfo, val.Event)
    end
    -- MarchAnimModel.SetLookAt(val.Event.Uuid)
    UIMgr:Close("Expedition")
end

--选择排序规则
function Expedition:ChangeSelectType(selectType)
    self._group.visible = false
    if (selectType == 1) then
        textKey = "BUTTON_LEVEL_FIRST"
    elseif (selectType == 2) then
        textKey = "BUTTON_LOAD_FIRST"
    elseif (selectType == 3) then
        textKey = "BUTTON_SPEED_FIRST"
    elseif (selectType == 4) then
        textKey = "BUTTON_MATCH_FIRST"
    end
    self.selectType = selectType
    local aslimit = (not self.data.mineAttach) and self.assistLimit or nil
    armiesData = ArmiesModel.GetListByType(selectType, self.armyLimit, aslimit, self.isJump)
    local test = {}
    for _,v in pairs(armiesData) do
        if v.NowCount > 0 then
            test[v.id] = v
        end
    end
    self:RefreshItems()
    self.curTeam = 0
    self._btnTroops:SelectedBtn(self.curTeam)
end

--快速选择事件
function Expedition:QuickSelect()
    if (not self.isQuickSelect) then
        self._textFastSelection.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CANCEL_SELECT")
        if self.messageType == ExpeditionType.Mining then
            self:ChangeSelectType(self.curSelectType)
        else
            self:ChangeSelectType(self.curSelectType)
        end
    else
        self._textFastSelection.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_QUICK_SELECT")
        self:ChangeSelectType(0)
    end
    self.isQuickSelect = not self.isQuickSelect
end

--刷新出征时间
function Expedition:RefreshTime()
    --转换为有buff配置的出征类型
    local type = 0
    local func = messageTypeMap[self.messageType]
    if func then
        type = func(self) or type
    end

    local speed = ArmiesModel:GetSpeedByExpedition(type)
    local startp = Vector2(Model.Player.X, Model.Player.Y)
    local endp = Vector2(math.floor(self.posNum / 10000), math.floor(self.posNum % 10000))
    self.expeditionTime = MapModel.GetMarchTime(startp, endp, speed)
    self._expeditionTime.text = TimeUtil.SecondToHMS(self.expeditionTime)    
end

------------------------------------------------《《进攻类型》》----------------------------------------------------------------
--集结进攻
function Expedition:AllianceAttack(durationType, posX, posY)
    local list = ArmiesModel.GetExpeditionArmies()
    local durationType = durationType
    SdkModel.TrackBreakPoint(10046)      --打点
    Net.AllianceBattle.Create(
        Global.ABCategoryAttack,
        durationType,
        posX,
        posY,
        list,
        ArmiesModel.GetExpeditionBeast()[1] == nil and 0 or ArmiesModel.GetExpeditionBeast()[1].Id,
        function(val)
            UIMgr:Close("Expedition")
        end
    )
end

-- 士兵援助
function Expedition:AllianceBattleAssist(posX, posY)
    Net.AllianceBattle.Assist(
        posX,
        posY,
        "",
        ArmiesModel.GetExpeditionArmies(),
        ArmiesModel.GetExpeditionBeast()[1] == nil and 0 or ArmiesModel.GetExpeditionBeast()[1].Id,
        self.data.assistId,
        function(rsp)
            if rsp.Fail then
                return
            end

            self:ExpeditionCallback(rsp)
        end
    )
end

function Expedition:AllianceDefense()
end

function Expedition:BtnExpeditionOnClick()
    if ArmiesModel.GetExpeditionCount() <= 0 then
        TipUtil.TipById(50192)
        return
    end

    local posX, posY = MathUtil.GetCoordinate(self.posNum)
    if self.messageType == ExpeditionType.AttackPlayer then
        --进攻玩家
        SdkModel.TrackBreakPoint(10059)      --打点
        Net.Missions.Attack(
            posX,
            posY,
            self.heroId,
            ArmiesModel.GetExpeditionArmies(),
            ArmiesModel.GetExpeditionBeast()[1] == nil and 0 or ArmiesModel.GetExpeditionBeast()[1].Id,
            function(val)
                self:ExpeditionCallback(val)
            end
        )
    elseif self.messageType == ExpeditionType.Mining then
        if not self.data.mineAttach then
            --进行采矿
            SdkModel.TrackBreakPoint(10062)      --打点
            Net.Missions.Mining(
                posX,
                posY,
                self.heroId,
                ArmiesModel.GetExpeditionArmies(),
                ArmiesModel.GetExpeditionBeast()[1] == nil and 0 or ArmiesModel.GetExpeditionBeast()[1].Id,
                function(val)
                    self:ExpeditionCallback(val)
                end
            )
        else
            --攻击敌人矿点
            SdkModel.TrackBreakPoint(10063)      --打点
            Net.Missions.Attack(
                posX,
                posY,
                self.heroId,
                ArmiesModel.GetExpeditionArmies(),
                ArmiesModel.GetExpeditionBeast()[1] == nil and 0 or ArmiesModel.GetExpeditionBeast()[1].Id,
                function(val)
                    self:ExpeditionCallback(val)
                end
            )
        end
    elseif self.messageType == ExpeditionType.Pve then
        --进攻野怪
        SdkModel.TrackBreakPoint(10064)      --打点
        Net.Missions.Pve(
            posX,
            posY,
            self.heroId,
            ArmiesModel.GetExpeditionArmies(),
            ArmiesModel.GetExpeditionBeast()[1] == nil and 0 or ArmiesModel.GetExpeditionBeast()[1].Id,
            function(val)
                self:ExpeditionCallback(val)
            end
        )
    elseif self.messageType == ExpeditionType.UnionAttack then
        local build = BuildModel.FindByConfId(Global.BuildingJointCommand)
        if not build or build.Level <= 0 then
            TipUtil.TipById(50291)
        else
            self:AllianceAttack(self.data.aggregation, posX, posY)
        end
    elseif self.messageType == ExpeditionType.JoinUnionAttack then
        --加入集结战争
        SdkModel.TrackBreakPoint(10045)      --打点

        local func = function()
            Net.AllianceBattle.Join(
                self.heroId,
                ArmiesModel.GetExpeditionArmies(),
                self.data.battleId,
                ArmiesModel.GetExpeditionBeast()[1] == nil and 0 or ArmiesModel.GetExpeditionBeast()[1].Id,
                function(rsp)
                    if rsp.Fail then
                        return
                    end
    
                    self:ExpeditionCallback(rsp)
                end
            )

            UIMgr:ClosePopAndTopPanel()
            if GlobalVars.IsInCity then
                Event.Broadcast(EventDefines.OpenWorldMap)
            end
        end

        local battleInfo = UnionWarfareModel.GetBattleInfoById(self.data.battleId)
        if battleInfo and (battleInfo.FinishAt - Tool.Time()) < self.expeditionTime then
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Alliance_War_2"),
                buttonType = "double",
                sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "Alliance_War_GoOn"),
                cancelBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_NO"),
                sureCallback = func
            }
            UIMgr:Open("ConfirmPopupText", data)
        else
            func()
        end
    elseif self.messageType == ExpeditionType.JoinUnionDefense then
        -- 援助士兵
        SdkModel.TrackBreakPoint(10061)      --打点
        self:AllianceBattleAssist(posX, posY)

        UIMgr:ClosePopAndTopPanel()
        if GlobalVars.IsInCity then
            Event.Broadcast(EventDefines.OpenWorldMap)
        end
    elseif self.messageType == ExpeditionType.UnionBuildingStation then
        -- 联盟建筑驻军
        self:AllianceBattleAssist(posX, posY)

        UIMgr:ClosePopAndTopPanel()
        if GlobalVars.IsInCity then
            Event.Broadcast(EventDefines.OpenWorldMap)
        end
    elseif self.messageType == ExpeditionType.None then
        -- 扎营
        SdkModel.TrackBreakPoint(10060)      --打点
        Net.Missions.March(
            posX,
            posY,
            Global.MissionCamp,
            nil,
            ArmiesModel.GetExpeditionArmies(),
            nil,
            ArmiesModel.GetExpeditionBeast()[1] == nil and 0 or ArmiesModel.GetExpeditionBeast()[1].Id,
            function(rsp)
                if rsp.Fail then
                    return
                end

                self:ExpeditionCallback(rsp)
            end
        )
    elseif self.messageType == ExpeditionType.UnionBuildingBuild then
        -- 联盟建筑修建
        self:AllianceBattleAssist(posX, posY)
    elseif self.messageType == ExpeditionType.SearchPrison then
        Net.Missions.March(
            posX,
            posY,
            Global.MissionExplore,
            nil,
            ArmiesModel.GetExpeditionArmies(),
            self.data.searchType .. "",
            ArmiesModel.GetExpeditionBeast()[1] == nil and 0 or ArmiesModel.GetExpeditionBeast()[1].Id,
            function(rsp)
                if rsp.Fail then
                    return
                end

                self:ExpeditionCallback(rsp)
            end
        )
    else
        Log.Warning("没有进攻类型")
    end
end

--计算出征挖掘资源
function Expedition:CalExpeditionLoadRes()
    local mapInfo = MapModel.GetArea(self.posNum)
    if not mapInfo then
        return
    end

    local mineInfo = ConfigMgr.GetItem("configMines", mapInfo.ConfId)
    if mineInfo then
        local resourceInfo = ConfigMgr.GetItem("configResourcess", mineInfo.category)
        self._iconResource.icon = UITool.GetIcon(resourceInfo.img)
        self.resourceWeight = resourceInfo.ratio
        self.assistLimit = mapInfo.Value * self.resourceWeight
    else
        self._statusController.selectedIndex = 3
    end
end

function Expedition:updateTextResource()
    if self._statusController.selectedIndex ~= 2 and self._statusController.selectedIndex ~= 3 then
        return
    end

    if not self.resourceWeight then
        -- self._iconResource.icon = UITool.GetIcon(Global.MarchLoadIcon)
        self._textResource.text = ArmiesModel.GetLoadByExpedition(true)
    else
        self._textResource.text = math.floor(ArmiesModel.GetLoadByExpedition(false) / self.resourceWeight)
    end
end

function Expedition:SetAimTip()
    local mapInfo = MapModel.GetArea(self.posNum)
    if self.messageType == ExpeditionType.AttackPlayer or (self.messageType == ExpeditionType.UnionAttack and not self.data.monsterId) then
        if mapInfo.Category == Global.MapTypeAllianceDomain then
            -- 进攻联盟堡垒
            self._textAim.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TARGET_TEXT")..StringUtil.GetI18n(I18nType.Commmon, "MARCH_TARGET_STRONGHOLD_ENEMY")
        else
            -- 进攻玩家
            self._textAim.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TARGET_TEXT")..StringUtil.GetI18n(I18nType.Commmon, "MARCH_TARGET_HQ")
        end
    elseif self.messageType == ExpeditionType.Mining then
        -- 采矿
        self._textAim.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TARGET_TEXT")..StringUtil.GetI18n(I18nType.Commmon, "MARCH_TARGET_RES")
    elseif self.messageType == ExpeditionType.Pve or (self.messageType == ExpeditionType.UnionAttack and self.data.monsterId) then
        -- 进攻野怪
        self._textAim.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TARGET_TEXT")..StringUtil.GetI18n(I18nType.Commmon, "MARCH_TARGET_MONSTER")   
    elseif self.messageType == ExpeditionType.JoinUnionDefense or self.messageType == ExpeditionType.JoinUnionAttack then
        -- 援助士兵、加入集结战争
        self._textAim.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TARGET_TEXT")..StringUtil.GetI18n(I18nType.Commmon, "MARCH_TARGET_ASSIST")
    elseif self.messageType == ExpeditionType.UnionBuildingStation or self.messageType == ExpeditionType.UnionBuildingBuild then
        -- 联盟建筑驻军、联盟建筑修建
        self._textAim.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TARGET_TEXT")..StringUtil.GetI18n(I18nType.Commmon, "MARCH_TARGET_STRONGHOLD_FRIEND")
    elseif self.messageType == ExpeditionType.None then
        -- 扎营
        self._textAim.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TARGET_TEXT")..StringUtil.GetI18n(I18nType.Commmon, "MARCH_TARGET_TILE")
    elseif self.messageType == ExpeditionType.SearchPrison then
        -- 搜索秘密基地
        self._textAim.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TARGET_TEXT")..StringUtil.GetI18n(I18nType.Commmon, "MARCH_TARGET_SECRET")
    end
end

function Expedition:SetPveTip()
    if self.data.monsterId and #Global.MarchPowerCompare == 4 then
        self._textTip.visible = true

        local power = ArmiesModel.GetTotalAttack()
        local config = ConfigMgr.GetItem("configMonsters", self.data.monsterId)
        if not config or not config.rec_force then
            self._textTip.visible = false
            return
        end

        local rate = power / config.rec_force * 10000
        if rate <= Global.MarchPowerCompare[1] then
            self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "UI_POWER_COMPARE_TEXT_1")
        elseif rate <= Global.MarchPowerCompare[2] then
            self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "UI_POWER_COMPARE_TEXT_2")
        elseif rate <= Global.MarchPowerCompare[3] then
            self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "UI_POWER_COMPARE_TEXT_3")
        elseif rate <= Global.MarchPowerCompare[4] then
            self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "UI_POWER_COMPARE_TEXT_4")
        else
            self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "UI_POWER_COMPARE_TEXT_5")
        end
    else
        self._textTip.visible = false
    end
end

return Expedition
