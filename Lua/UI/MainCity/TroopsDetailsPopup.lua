-- 士兵详情界面
local TroopsDetailsPopup = UIMgr:NewUI("TroopsDetailsPopup")

local ArmiesModel = import("Model/ArmiesModel")
local TrainModel = import("Model/TrainModel")

local DetailScrollBegin = false

function TroopsDetailsPopup:OnInit()
    local view = self.Controller.contentPane
    self._title = view:GetChild("titleName")
    self._detailList = view:GetChild("liebiao2")
    self._skillList = view:GetChild("liebiao")
    self._skillTitle = view:GetChild("textTalent")
    self._freeTitle = view:GetChild("textFree")
    self._bottomGroup = view:GetChild("bottomGroup")
    self._bgMask = view:GetChild("bgMask")
    self._btnClose = view:GetChild("btnClose")

    -- self._textNum = view:GetChild("textNum")
    -- self._groupSkTitle =_groupSkTitle view:GetChild("textSkillName")
    -- self._groupSkDesc = view:GetChild("textSkillDescribe")
    self._btnLast = view:GetChild("arrowL")
    self._btnNext = view:GetChild("arrowR")

    self:InitDismissGroup(view)

    -- self:AddListener(self._detailList.scrollPane.onScroll,
    --     function()
    --         if not DetailScrollBegin then
    --             self._dismissBtnOk.visible = false
    --             DetailScrollBegin = true
    --         end
    --     end
    -- )

    self:AddListener(self._detailList.scrollPane.onScrollEnd,
        function()
            DetailScrollBegin = false
            if not self._detailList.scrollPane.pageMode then
                return
            end
            self.curIndex = self._detailList.scrollPane.currentPageX + 1
            self:SetArmy()
            self:RefreshSkillList()
            self:RefreshArmyNum()
        end
    )

    self:AddListener(self._btnLast.onClick,function()
        self.curIndex = self.curIndex - 1
        if self.curIndex < 1 then
            self.curIndex = 1
            return
        end

        self._detailList.scrollPane:SetCurrentPageX(self.curIndex - 1)
        self:SetArmy()
        self:RefreshSkillList()
        self:RefreshArmyNum()
    end)

    self:AddListener(self._btnNext.onClick,function()
        self.curIndex = self.curIndex + 1
        if self.curIndex > #self.ids then
            self.curIndex = #self.ids
            return
        end

        self._detailList.scrollPane:SetCurrentPageX(self.curIndex - 1)
        self:SetArmy()
        self:RefreshSkillList()
        self:RefreshArmyNum()
    end)

    
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("TroopsDetailsPopup")
        end
    )

    self:AddListener(self._btnMask.onClick,
        function()
            UIMgr:Close("TroopsDetailsPopup")
        end
    )

    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("TroopsDetailsPopup")
        end
    )
    
    self:AddListener(self._btnAdvanced.onClick, function()
        UIMgr:Close("TroopsDetailsPopup")
        UIMgr:Open("TrainRelated/TrainAdvanced", self.armyId, self.advancedArmyId)
    end)

    -- self:AddEvent(
    --     EventDefines.UIArmiesRefresh,
    --     function()
    --         UIMgr:Close("TroopsDetailsPopup")
    --     end
    -- )
    print("==========================================",self._freeTitle.width,self._freeTitle.textWidth)
    self._bottomGroup.x = self._bottomGroup.x - (self._freeTitle.width - self._freeTitle.textWidth)*0.5
end

-- ids为士兵配置信息id列表
function TroopsDetailsPopup:OnOpen(ids, index, item, armyType, ignoreDismiss)
    self.amount = 0
    self.ids = ids
    self.configId = 0
    self.dismiss = 0
    self.item = item
    self.curIndex = index
    self.armyType = armyType --类型 伤兵用
    self.ignoreDismiss = ignoreDismiss

    self:InitDetailList()
    self:SetArmy()
    self:RefreshSkillList()
    self:RefreshArmyNum()

    self:PlayAnim()
    -- if self.ignoreDismiss or self.dismiss <= 0 then
    --     self._dismissBtnOk.enabled = false
    -- else
    --     self._dismissBtnOk.enabled = true
    -- end
end

-- 士兵详细数据面板
function TroopsDetailsPopup:InitDetailList()
    self._detailList:RemoveChildrenToPool()
    if #self.ids > 1 then
        self._detailList.touchable = true
        self._detailList.scrollPane.owner.data = self
        -- self._btnLast.visible = self.curIndex > 1 and true or false
        -- self._btnNext.visible = self.curIndex < #self.ids and true or false
    else
        self._detailList.touchable = false
        -- self._btnLast.visible = false
        -- self._btnNext.visible = false
    end
    self._listPoint.numItems = #self.ids
    for i = 1, self._listPoint.numChildren do
        self._listPoint:GetChildAt(i - 1).touchable = false
    end

    -- 初始化所有士兵数据面板
    for _, v in ipairs(self.ids) do
        local config = ConfigMgr.GetItem("configArmys", v)
        local panel = self._detailList:AddItemFromPool()
        panel:Init(config)
    end

    self._detailList:ScrollToView(self.curIndex - 1, false)
end

-- 刷新技能列表
function TroopsDetailsPopup:RefreshSkillList()
    self:SetPointsShow()
    local config = ConfigMgr.GetItem("configArmys", self.ids[self.curIndex])
    local typeConfig = ConfigMgr.GetItem("configArmyTypes", config.arm)
    local skills = typeConfig.skill_id
    self._skillList:RemoveChildrenToPool()

    if skills then
        for _,v in pairs(skills) do
            local skill = ConfigMgr.GetItem("configskills", v)
            local item = self._skillList:AddItemFromPool()
            item:Init(skill.icon, ConfigMgr.GetI18n("configI18nSkills", skill.i18n_name), ConfigMgr.GetI18n("configI18nSkills", skill.i18n_desc))
        end
    end
end

-- 刷新士兵数量
function TroopsDetailsPopup:RefreshArmyNum()
    local armyTotal = TrainModel.GetArmTotal(self.ids[self.curIndex])
    local armyNum = TrainModel.GetArmAmount(self.ids[self.curIndex])
    self._dismissText.text = armyNum
    self.amount = armyNum
    -- self._textNum.text = armyNum.."/"..armyTotal
end

-- 设置兵种数量
function TroopsDetailsPopup:SetArmy()
    local confId = self.ids[self.curIndex]
    local model
    if self.armyType == "InjuredArmy" then
        model = Model.InjuredArmies[confId]
    else
        model = ArmiesModel.FindByConfId(confId)
    end

    self.dismiss = 0
    -- self._dismissSlider.max = 0
    -- self._dismissSlider.value = 0
    self._dismissText.text = 0
    -- self._dismissBtnOk.visible = true
    -- self._btnLast.visible = self.curIndex > 1 and true or false
    -- self._btnNext.visible = self.curIndex < #self.ids and true or false

    --兵种进阶
    self.armyId = confId
    self._btnAdvanced.visible, self.advancedArmyId = TrainModel.CheckAdvanced(confId)

    if not model then
        self.amount = 0
        return
    end

    self.amount = model.Amount
    self.configId = model.ConfId
    -- self._dismissSlider.max = self.ignoreDismiss and 0 or self.amount
end

function TroopsDetailsPopup:InitDismissGroup(view)
    self.dismiss = 0
    -- self._dismissSlider = view:GetChild("slide")
    self._dismissText = view:GetChild("textInput")
    -- self._dismissBtnSub = view:GetChild("btnReduce")
    -- self._dismissBtnAdd = view:GetChild("btnAdd")
    self._dismissBtnOk = view:GetChild("btnDismiss")
    -- self._btnInput = view:GetChild("bgInputBox")

    self:AddListener(self._dismissBtnOk.onClick,function()
        if self.amount <= 0 then
            TipUtil.TipById(50114)
            return
        end

        UIMgr:Open("TroopsDetailsFirePopup", self.configId, self.amount, function()
            self:RefreshArmyNum()
        end)
    end)
end

function TroopsDetailsPopup:SetPointsShow()
    for i = 1, self._listPoint.numChildren do
        self._listPoint:GetChildAt(i - 1):GetController("button").selectedIndex = 0
    end
    local cpx = self._detailList.scrollPane.currentPageX
    self._listPoint:GetChildAt(cpx):GetController("button").selectedIndex = 1
    if not self.cpx or self.cpx == cpx then
        self.cpx = cpx
    else
        self:PlayAnim(self.cpx > cpx and 1 or -1)
        self.cpx = cpx
    end
end

function TroopsDetailsPopup:PlayAnim(dir)
    if not dir then
        for i = 1, self._skillList.numChildren do
            local item = self._skillList:GetChildAt(i - 1)
            item.x = 0
            GTween.Kill(item)
        end
    else
        for i = 1, self._skillList.numChildren do
            local item = self._skillList:GetChildAt(i - 1)
            GTween.Kill(item)
            item.x = -dir * item.width
            self:GtweenOnComplete(item:TweenMoveX(item.x, 0.1 * i),function()
                item:TweenMoveX(0, 0.2)
            end)
        end
    end
end

return TroopsDetailsPopup
