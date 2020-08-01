-- 部队编辑界面
local TroopsDetailsFormation = UIMgr:NewUI("TroopsDetailsFormation")

import("UI/Common/ItemKeyboard")
local ArmiesModel = import("Model/ArmiesModel")
local VIPModel = import("Model/VIPModel")  
local MonsterModel = import("Model/MonsterModel")

function TroopsDetailsFormation:OnInit()
    self.mosterGroup = {}
    self.keyboard = UIMgr:CreatePopup("Common", "itemKeyboard")
    self._list.scrollItemToViewOnClick = false
    self.funListener = function()
        self._txtTroops.text = ArmiesModel.GetExpetionNum()
        self._txtallPower.text = ArmiesModel.GetTotalAttack()
        self._txtResource.text = ArmiesModel.GetLoadByExpedition(false)
    end

    self:InitFormationGroup()

    self:AddListener(self._btnCancel.onClick,function()
        UIMgr:Close("TroopsDetailsFormation")
    end)

    self:AddListener(self._btnSave.onClick,function()
        local armies = ArmiesModel.GetExpeditionArmies()
        local beasts = ArmiesModel.GetExpeditionBeast()
        local beastIds = {}
        for _,v in pairs(beasts) do
            table.insert(beastIds, v.Id)
        end
        local data = {
            FormId = self.curTeam,
            FormName = self._txtName.text,
            Armies = armies,
            Beasts = beastIds
        }
        Net.Armies.Formation({data}, function(rsp)
            if rsp.Fail then
                return
            end

            Model.Create(ModelType.Formations, data.FormId, data)
            TipUtil.TipById(50118)
        end)
    end)

    self:AddListener(self._btnHelp.onClick,function()
        local data = {
            title = StringUtil.GetI18n(I18nType.Commmon, 'Tips_TITLE'),
            info = StringUtil.GetI18n(I18nType.Commmon, 'UI_LOAD_TEXT')
        }
        UIMgr:Open("ConfirmPopupTextList", data)
      end)

    self:AddListener(self._btnEdit.onClick,function()
        local name = self.curFormation and self.curFormation.FormName or nil
        UIMgr:Open("FormationRename", name, self.curTeam, function(name)
            self._txtName.text = name
        end)
    end)

    self:AddListener(self._btnSelectType.onClick,function()
        self._group.visible = not self._group.visible
    end)

    self:AddListener(self._btnAdd.onClick,function()
        UIMgr:Open("ExpeditionUpperLimit")
    end)

    self:AddListener(self._btnReturn.onClick,function()
        UIMgr:Close("TroopsDetailsFormation")
    end)

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.WorldExpedition)
end

function TroopsDetailsFormation:OnOpen(index)
    self.curTeam = index and index or 1
    self.curShowType = ExpeditionItemType.number
    self.curFormation = Model.Formations and Model.Formations[self.curTeam] or nil
    self.curArmyItems = {}
    self._txtName.text = self.curFormation and self.curFormation.FormName or StringUtil.GetI18n(I18nType.Commmon, "FOMATION_DEFAULT_"..self.curTeam)
    self._txtallPower.text = 0
    self._txtResource.text = 0
    self._txtTroops.text = ArmiesModel.GetExpetionNum()
    self._btnNumFormation.selected = true
    self._btnSelectType.icon = self._btnNumFormation.icon
    self._group.visible = false
    
    self:AddEvent(EventDefines.UIOnExpetionNumChange, self.funListener)

    ArmiesModel.ClearArmies()
    ArmiesModel.Init()
    
    self:RefreshList()
    self:RefreshMosterList()
    self._btnTroops:Init(self.curTeam, false, function(index, formation, name)
        self.curTeam = index
        self.curFormation = formation
        self._txtName.text = name
        ArmiesModel.ClearArmies()
        self:RefreshList()
        self:RefreshMosterList()
    end)

    self._txtTroops.text = ArmiesModel.GetExpetionNum()
    self._txtallPower.text = ArmiesModel.GetTotalAttack()
    self._txtResource.text = ArmiesModel.GetLoadByExpedition(false)
end

function TroopsDetailsFormation:OnClose()
    Event.RemoveListener(EventDefines.UIOnExpetionNumChange, self.funListener)
end

function TroopsDetailsFormation:InitFormationGroup()
    self:AddListener(self._btnNumFormation.onClick,function()
        self._btnSelectType.icon = self._btnNumFormation.icon
        self._group.visible = false
        for _,v in pairs(self.curArmyItems) do
            self.curShowType = ExpeditionItemType.number
            v:RefreshType(self.curShowType)
        end
    end)

    self:AddListener(self._btnPercentFormation.onClick,function()
        self._btnSelectType.icon = self._btnPercentFormation.icon
        self._group.visible = false
        for _,v in pairs(self.curArmyItems) do
            self.curShowType = ExpeditionItemType.percent
            v:RefreshType(self.curShowType, ArmiesModel.GetMarchLimit())
        end
    end)
end

function TroopsDetailsFormation:RefreshList()
    self._list:RemoveChildrenToPool()
    self.curArmyItems = {}

    -- ArmiesModel.ClearArmies()
    -- local armies = ArmiesModel.Init()
    local armies = ArmiesModel.GetAllArmies()

    -- 原编队士兵总数
    local formationAmount = 0
        if self.curFormation then
        for _,v in pairs(self.curFormation.Armies) do
            formationAmount = formationAmount + v.Amount
        end
    end

    --当原编队士兵总数大于当前出征上限
    local rate = 1
    local limit = ArmiesModel.GetMarchLimit()
    if limit < formationAmount then
        rate = limit / formationAmount
    end

    for k,v in pairs(armies) do
        local curArmy = self:GetArmyFromCurFormationById(v.id)
        local panel = self._list:AddItemFromPool()
        local data = {
            info = v,
            initCount = curArmy and math.floor(curArmy.Amount * rate) or 0,
            maxCount = self.curShowType == ExpeditionItemType.number and v.Amount or ArmiesModel.GetMarchLimit(),
            type = self.curShowType,
            keyboard = self.keyboard,
            keyboardCb = function(txtInput)
                UIMgr:ShowPopup("Common", "itemKeyboard", txtInput)
            end
        }
        panel:Init(data)
        table.insert(self.curArmyItems, panel)
    end

    self._list.scrollPane:ScrollTop()
end

function TroopsDetailsFormation:RefreshMosterList()
    self.mosterGroup = {}
    local func_check = function(item)
        ArmiesModel.SetExpeditionBeast(item.model, not ArmiesModel.GetExpeditionBeastById(item.model.Id))

        for _,v in pairs(self.mosterGroup) do
            if v.config.id ~= item.config.id then
                v._checkBox.selected = false
                ArmiesModel.SetExpeditionBeast(v.model, false)
            end
        end
    end

    local beasts = {}
    for _,v in pairs(MonsterModel.GetBeastModels()) do
        table.insert(beasts, v)
    end
    table.sort(beasts, function(a, b)
        return a.Id < b.Id
    end)

    self._listMonster:RemoveChildrenToPool()
    for _,v in pairs(beasts) do
        local item = self._listMonster:AddItemFromPool()
        table.insert(self.mosterGroup, item)

        local isSelected = self:IsBeastInFormation(v.Id)
        item:Init(v, isSelected, true, func_check)
    end
end

function TroopsDetailsFormation:GetArmyFromCurFormationById(id)
    if not self.curFormation then
        return nil
    end

    for _,v in pairs(self.curFormation.Armies) do
        if v.ConfId == id then
            return v
        end
    end
end

function TroopsDetailsFormation:IsBeastInFormation(id)
    if not self.curFormation then
        return false
    end

    if not self.curFormation.Beasts then
        return false
    end

    for _,v in pairs(self.curFormation.Beasts) do
        if v == id then
            return true
        end
    end
end

return TroopsDetailsFormation