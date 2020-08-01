-- 科技研究科技树页面
local LaboratorySkill = UIMgr:NewUI("LaboratorySkill")

local TechModel = import("Model/TechModel")
local GuidePanel = import("Model/GuideControllerModel")
local JumpModel = import("Model/JumpMapModel")
LaboratorySkill.MaxColume = 7 -- 总列数
LaboratorySkill.Rowledge = 10 -- 行距
local UIType = _G.GD.GameEnum.UIType

function LaboratorySkill:OnInit()
    local view = self.Controller.contentPane
    self._view = view
    self._list = view:GetChild("liebiao")
    self._txtProgress = view:GetChild("textProgress")
    self._txtTitle = view:GetChild("textName")
    local uibg = self._uibg:GetChild("_icon")
    UITool.GetIcon({"falcon", "science_bg_02"},uibg)
    self._itemSize = nil
    self._panel = nil
    self.curItems = {}
    self.columePosTable = {}
    self.itemPool = {}
    self.linePool = {}
    self:AddListener(self._list.scrollPane.onScrollEnd,
        function()
            if self.moveEndFunc then
                self.moveEndFunc()
                self.moveEndFunc = nil
            end
        end
    )
    self:Preprocessing()

    self._btnReturn = view:GetChild("btnReturn")
    self:AddListener(self._btnReturn.onClick,
        function()
            if self.closecb then
                self.closecb()
            end
            if GuidePanel.isBeginGuide then
                Event.Broadcast(EventDefines.CloseGuide)
            end
            UIMgr:Close("LaboratorySkill")
            if self.triggerCallBack then
                self.triggerCallBack()
            end
        end
    )

    self:AddEvent(
        EventDefines.UIRefreshTechResearchFinish,
        function(confId)
            self.finishId = confId
            self:OnOpen(self._tab, self.techType)
        end
    )
end

function LaboratorySkill:OnOpen(tabId, techType, configId, isScrollTop, building, closecb, isEffect)
    self.techType = techType
    self.closecb = closecb and closecb or self.closecb
    self._tab = tabId
    self._txtTitle.text = TechModel.GetTechTypeName(techType, tabId)
    self._txtProgress.text = StringUtil.GetI18n(I18nType.Commmon, "Tech_Tips1")
    self._configs, self._maxRow = self:GetSkillConfigByTab(tabId)
    self.curUpgrade = nil

    self:BuildSkillItem(isScrollTop)
    local isGuideShow = GuidePanel:IsGuideState(building, _G.GD.GameEnum.JumpType.Tech)
    self.isGuideShow = isGuideShow
    self.moveEndFunc = nil
    if isGuideShow == true then
        self.moveEndFunc = function()
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.LaboratorySkillUI)
        end
        local techId = JumpModel:GetTech()
        if techId then
            configId = techId
        end
    end
    for _, v in pairs(self.curItems) do
        if configId ~= nil and v.config.id == configId then
            self._list.scrollPane:ScrollToView(v, true)
            if isEffect then
                v:PlayEffect()
            end
            break
        end

        if self.finishId and self.finishId == v.config.id and not self.curUpgrade then
            v:PlayResearchEndEffect(true)
        else
            v:PlayResearchEndEffect(false)
        end
    end
end

-- 创建科技树
function LaboratorySkill:BuildSkillItem(isScrollTop)
    self._list:RemoveChildrenToPool()
    self._panel = self._list:AddItemFromPool()
    self._list.scrollItemToViewOnClick = false
    self:RecycleToPool()
    self._panel.width = self._list.width
    self._panel.height = (self._maxRow - 1) * (self._itemSize.y + LaboratorySkill.Rowledge) + self._itemSize.y

    -- 生成连线
    for k, v in pairs(self._configs) do
        if v.relation ~= nil then
            for k1, v1 in pairs(v.relation) do
                local line

                -- 连线两端技能都升了一级以上时，连线点亮
                local model1 = TechModel.FindByConfId(v.id)
                local nextId = self:GetDisplayConfigByRelation(v.tab, v1.x, v1.y).id
                local nextUnlock = TechModel.CheckUnlock(TechModel.GetDisplayConfigItem(self.techType, nextId), self.techType)
                if model1 ~= nil and model1.Level > 0 and nextUnlock then
                    line = self:GetLine()
                else
                    line = self:GetGrayLine()
                end

                self._panel:AddChild(line)
                local fromX, fromY = self:TransitionXY(v.position.x, v.position.y)
                local toX, toY = self:TransitionXY(v1.x, v1.y - 0.45)
                local diffX = toX - fromX
                local diffY = toY - fromY
                local length = MathUtil.GetDistance(diffX, diffY)
                local angle = 360 - math.deg(math.atan(diffX / diffY))
                line:SetPosition(fromX, fromY, 0)
                line.height = length
                line.rotation = angle
            end
        end
    end

    -- 生成科技图标
    self.curItems = {}
    local upgrade = TechModel.GetUpgradeTech(self.techType)
    self.curUpgrade = upgrade
    for k, v in pairs(self._configs) do
        local model = TechModel.FindByConfId(v.id)
        local preModels, hasPreTech = TechModel.GetPreTechModel(self.techType, v.id)

        local item = self:GetItem()
        item.config = v

        table.insert(self.curItems, item)
        self._panel:AddChild(item)
        local x, y = self:TransitionXY(v.position.x, v.position.y)
        item:SetPosition(x, y, 0)
        local isUpgrade = (upgrade ~= nil and upgrade.TargetId == v.id)
        item:Init(
            v,
            self.techType,
            (upgrade ~= nil and upgrade.TargetId == v.id) and upgrade or nil,
            function(configId)
                if self.isGuideShow then
                    if configId ~= JumpModel:GetTech() then
                        Event.Broadcast(EventDefines.CloseGuide)
                    end
                end
                local config = TechModel.GetDisplayConfigItem(self.techType, configId)
                if not isUpgrade then
                    if model == nil or model.Level < config.max_lv then
                        -- 没有在研究则跳转研究界面
                        UIMgr:Open(
                            "LaboratoryPopup",
                            configId,
                            self.techType,
                            function(id)
                                self.finishId = id
                                for _, v in pairs(self.curItems) do
                                    v:ClearEffect()
                                end
                                self:OnOpen(self._tab, self.techType)
                            end
                        )
                    else
                        -- 研究满级则跳转研究满级界面
                        UIMgr:Open("LaboratoryDetailPopup", configId, self.techType)
                    end
                else
                    -- 正在研究则跳转正在研究界面
                    UIMgr:Open(
                        "LaboratoryDetailPopup",
                        configId,
                        self.techType,
                        upgrade,
                        function()
                            for _, v in pairs(self.curItems) do
                                v:ClearEffect()
                            end
                            self:OnOpen(self._tab, self.techType)
                        end
                    )
                end
            end
        )

        if not hasPreTech then
            item:SetPoint("hide")
        end
    end

    if isScrollTop then
        self._list.scrollPane:ScrollTop()
    end
end

function LaboratorySkill:Preprocessing()
    if self._itemSize ~= nil then
        return
    end

    local item
    if #self.itemPool > 0 then
        item = self.itemPool[1]
    else
        item = UIMgr:CreateObject("Laboratory", "btnItemLaboratoryDetail")
        item.name = "Item"
        table.insert(self.itemPool, item)
    end

    self._itemSize = {x = item.width, y = item.height}

    -- 计算列的位置
    local colSize = (self._list.width - self._itemSize.x) / (LaboratorySkill.MaxColume - 1)
    self.columePosTable = {self._itemSize.x / 2}
    for i = 1, LaboratorySkill.MaxColume - 1 do
        table.insert(self.columePosTable, (self._itemSize.x / 2) + (colSize * i))
    end
end

function LaboratorySkill:GetLine()
    local line
    if #self.linePool > 0 then
        line = table.remove(self.linePool, 1)
        line.visible = true
        line:GetController("colorControl").selectedPage = "blue"
    else
        line = UIMgr:CreateObject("Common", "line")
        line:GetController("colorControl").selectedPage = "blue"
        line.name = "Line"
    end

    return line
end

function LaboratorySkill:GetGrayLine()
    local line
    if #self.linePool > 0 then
        line = table.remove(self.linePool, 1)
        line.visible = true
        line:GetController("colorControl").selectedPage = "gray"
    else
        line = UIMgr:CreateObject("Common", "line")
        line:GetController("colorControl").selectedPage = "gray"
        line.name = "Line"
    end

    return line
end

function LaboratorySkill:GetItem()
    local item
    if #self.itemPool > 0 then
        item = table.remove(self.itemPool, 1)
        item.visible = true
    else
        item = UIMgr:CreateObject("Laboratory", "btnItemLaboratoryDetail")
        item.name = "Item"
    end

    return item
end

-- 根据配置行列获取技能显示配置
function LaboratorySkill:GetDisplayConfigByRelation(tab, x, y)
    local configs = TechModel.GetDisplayConfigList(self.techType)
    for k, v in pairs(configs) do
        if v.tab == tab and v.position.x == x and v.position.y == y then
            return v
        end
    end
end

function LaboratorySkill:RecycleToPool()
    local children = {}
    for i = 1, self._panel.numChildren do
        local object = self._panel:GetChildAt(i - 1)
        table.insert(children, object)
        if object.name == "Item" then
            table.insert(self.itemPool, object)
        elseif object.name == "Line" then
            table.insert(self.linePool, object)
        end
    end

    for _, v in pairs(children) do
        self._list.parent:AddChild(v)
        v.visible = false
    end

    self._panel:RemoveChildren()
end

-- 根据配置的行列算出具体坐标
function LaboratorySkill:TransitionXY(x, y)
    return self.columePosTable[x], self._itemSize.y / 2 + (self._itemSize.y + LaboratorySkill.Rowledge) * (y - 1)
end

function LaboratorySkill:GetSkillConfigByTab(tab)
    local maxRow = 0
    local datas = {}
    local configs = TechModel.GetDisplayConfigList(self.techType)
    for k, v in pairs(configs) do
        if v.tab == tab then
            if v.position.y > maxRow then
                maxRow = v.position.y
            end
            table.insert(datas, v)
        end
    end

    return datas, maxRow
end

function LaboratorySkill:GetSkillItemByConfid(techId)
    for k, v in pairs(self.curItems) do
        if v.config.id == techId then
            return v
        end
    end
end

function LaboratorySkill:TriggerOnclick(callback)
        self.triggerCallBack = callback
end

function LaboratorySkill:OnClose()
    for _, v in pairs(self.curItems) do
        v:ClearEffect()
    end
    self.finishId = nil
end

return LaboratorySkill
