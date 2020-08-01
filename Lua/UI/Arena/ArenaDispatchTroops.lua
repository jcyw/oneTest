--author: 	Amu
--time:		2020-06-28 16:45:25

local ArmiesModel = import("Model/ArmiesModel")
local MapModel = import("Model/MapModel")
local MissionEventModel = import("Model/MissionEventModel")
local MonsterModel = import("Model/MonsterModel")
local JumpMapModel = import("Model/JumpMapModel")
local TaskModel = import("Model/TaskModel")
local UnionWarfareModel = import("Model/Union/UnionWarfareModel")
local ArenaModel = import("Model/ArenaModel")


local ArenaDispatchTroops = UIMgr:NewUI("ArenaDispatchTroops")

--出征士兵缓存数据
local armiesData
local isInit = false

function ArenaDispatchTroops:OnInit()
    local view = self.Controller.contentPane
    self._textFastSelection = self._btnFastSelection:GetChild("title") --快速选择文本
    self._textExpedition = self._btnExpedition:GetChild("title")
    self._textExpedition2 = self._btnExpedition2:GetChild("title")
    self._numExpedition2 = self._btnExpedition2:GetChild("text")
    self._btnExpedition.sortingOrder = 2
    self._textExpedition.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_TITLE1")
    self._textExpedition2.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_TITLE1")

    self._numExpedition2.text = Global.Arena_battle

    self._textTip.visible = false

    self._ctrView = view:GetController("c1")

    self.mosterGroup = {}
    self.isQuickSelect = true
    self.selectType = 0

    self.keyboard = UIMgr:CreatePopup("Common", "itemKeyboard")


    self.func_numChange = function()
        if isInit then
            self._textTroops.text = ArmiesModel.GetExpetionNum(self.armyLimit)
            self._textBattleNum.text = ArmiesModel.GetTotalAttack()
        end
    end

    self.func_limitChange = function()
        if self.data then
            local selfMarchLimit = ArmiesModel.GetMarchLimit()
            self.armyLimit = (self.data.amryLimit == nil or self.data.amryLimit < selfMarchLimit) and self.data.amryLimit or selfMarchLimit
            self._textTroops.text = ArmiesModel.GetExpetionNum(self.armyLimit)
            
            self:ChangeSelectType(self.curSelectType)
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

function ArenaDispatchTroops:OnRegister()
    self:AddListener(self._btnAdd.onClick,function()
        _G.UIMgr:Open("ExpeditionUpperLimit")
    end)

    self:AddListener(self._btnReturn.onClick,function()
        _G.UIMgr:Close("ArenaDispatchTroops")
    end)

    self:AddListener(self._btnFastSelection.onClick,function()
        self:QuickSelect()
    end)

    self:AddListener(self._btnExpedition.onClick,function()
        self:BtnExpeditionOnClick()
    end)

    self:AddListener(self._btnExpedition2.onClick,function()
        self:BtnExpeditionOnClick()
    end)

    self:AddListener(self._btnGain.onClick,function()
        UIMgr:Open("BaseGain", Global.PageMarchBuff)
    end)

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

function ArenaDispatchTroops:OnOpen(data)
    self.data = data
    self:AddEvent(EventDefines.UIOnExpetionNumChange, self.func_numChange)
    self:AddEvent(EventDefines.UIOnExpeditionLimitChange, self.func_limitChange)

    UnlockModel:UnlockCenter(UnlockModel.Center.Gain, self._btnGain)

    -- --检查出征上限，上限已满则返回提示
    -- if ArmiesModel.CheckMissionLimit() then
    --     UIMgr:Close("ArenaDispatchTroops")
    --     return
    -- end

    --根据免费挑战次数决定按钮状态
    if ArenaModel._DayBattleiFreeTimes > 0 then
        self._ctrView.selectedIndex = 0
    else
        self._ctrView.selectedIndex = 1
    end

    ArmiesModel.ClearArmies()
    ArmiesModel.Init()
    if ArmiesModel.GetAllCount() <= 0 then
        TipUtil.TipById(10003)
        UIMgr:Close("ArenaDispatchTroops")
    end

    isInit = false
    local selfMarchLimit = ArmiesModel.GetMarchLimit()
    -- self.data = data
    -- self.assistLimit = nil
    -- self.posNum = data.posNum
    self.armyLimit = (data.amryLimit == nil or data.amryLimit < selfMarchLimit) and data.amryLimit or selfMarchLimit
    -- self.messageType = data.openType
    self._textFastSelection.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CANCEL_SELECT")
    self.isQuickSelect = true
    self.resourceWeight = nil
    self.isJump = false

    self.curSelectType = 4

    isInit = true
    self.curTeam = 0
    self._textTroops.text = ArmiesModel.GetExpetionNum(self.armyLimit)


    self:RefreshMosterList()
    self:ChangeSelectType(self.curSelectType)
    self._textAim.text = StringUtil.GetI18n(I18nType.Commmon, "UI_TARGET_TEXT")..StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_ARENA_NAME")

end

function ArenaDispatchTroops:OnClose()
    self._listContent.numItems = 0
    Event.Broadcast(EventDefines.CloseGuide)
    Event.RemoveListener(EventDefines.UIOnExpetionNumChange, self.func_numChange)
    Event.RemoveListener(EventDefines.UIOnExpeditionLimitChange, self.func_limitChange)
end

function ArenaDispatchTroops:RefreshItems()
    self.listData = armiesData
    self._listContent.numItems = #armiesData

    self._textBattleNum.text = ArmiesModel.GetTotalAttack()
end

function ArenaDispatchTroops:RefreshMosterList()
    self.mosterGroup = {}
    
    local beasts = {}
    for _,v in pairs(MonsterModel.GetBeastModels()) do
        table.insert(beasts, v)
    end
    table.sort(beasts, function(a, b)
        return a.Id < b.Id
    end)
    local selected = nil

    for _,v in pairs(beasts) do
        if MonsterModel.IsUnlock(v.Id) and not ArmiesModel.IsBeastExpedition(v.Id) then
            local power = MonsterModel.GetMonsterRealPower(v.Id, v.Level)
            if selected == nil or power > selected.power then
                selected = v
                selected.power = power
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

function ArenaDispatchTroops:ExpeditionCallback(val)
    --刷新当前军队数量
    if (val.Armies) then
        -- Event.Broadcast(EventDefines.UIOnArmiesChange, val.Armies)
        ArmiesModel.RefreshArmies(val.Armies)
    end
    if (val.Event) then
        Event.Broadcast(EventDefines.UIOnMissionInfo, val.Event)
    end
    UIMgr:Close("ArenaDispatchTroops")
end

--选择排序规则
function ArenaDispatchTroops:ChangeSelectType(selectType)

    self.selectType = selectType
    armiesData = ArmiesModel.GetListByType(selectType, self.armyLimit, nil, self.isJump)
    self:RefreshItems()
    self.curTeam = 0
    -- self._btnTroops:SelectedBtn(self.curTeam)
end

--快速选择事件
function ArenaDispatchTroops:QuickSelect()
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

function ArenaDispatchTroops:BtnExpeditionOnClick()
    local expeditionCount = ArmiesModel.GetExpeditionCount()
    if expeditionCount<= 0 then
        TipUtil.TipById(50192)
        return
    end
    if expeditionCount*5/1000 > ArmiesModel:GetCureArmyLimit() then
        local data = {
            content = StringUtil.GetI18n("configI18nCommons", "UI_ARENA_BATTLE_TIPS31"),
            sureCallback = function()
                self:ArenaCheck()
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        self:ArenaCheck()
    end
end

function ArenaDispatchTroops:ArenaCheck()
    if ArenaModel._DayBattleiFreeTimes > 0 then
        self:ArenaChallenge(self.data.PlayerRankInfo.PlayerId)
    else
        local data = {
            content = StringUtil.GetI18n("configI18nCommons", "UI_ARENA_BATTLE_TIPS29", {num = Global.Arena_battle}),
            gold = tonumber(Global.Arena_battle),
            sureCallback = function()
                self:ArenaChallenge(self.data.PlayerRankInfo.PlayerId)
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end
end

function ArenaDispatchTroops:ArenaChallenge(PlayerId)
    UIMgr:Close("ArenaDispatchTroops")
    -- UIMgr:Open("ArenaBattle", self.data)
    ArenaModel.ArenaAttack(
        ArmiesModel.GetExpeditionArmies(), 
        ArmiesModel.GetExpeditionBeast()[1] == nil and 0 or ArmiesModel.GetExpeditionBeast()[1].Id,
        PlayerId,
        self.data.PlayerRankInfo.Rank, function(msg)
            if msg.RankIsChange then
                local data = {
                    content = StringUtil.GetI18n("configI18nCommons", "UI_ARENA_BATTLE_TIPS38"),
                    sureCallback = function()
                        self:ArenaChallenge("")
                    end,
                    cancelCallback = function()
                        Event.Broadcast(ARENA_CHALLENGE_EVNET.WinRefresh)
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
            else   
                UIMgr:Open("ArenaBattle", self.data)
                local panel = UIMgr:GetUI("ArenaBattle")
                if panel then
                    panel:Refresh(msg)
                end 
            end
    end)
end

return ArenaDispatchTroops
