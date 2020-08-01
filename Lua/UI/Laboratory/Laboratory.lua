-- 科技研究主界面
local Laboratory = UIMgr:NewUI("Laboratory")

local TechModel = import("Model/TechModel")
local GuidePanel = import("Model/GuideControllerModel")
local UIType = _G.GD.GameEnum.UIType
local JumpModel = import("Model/JumpMapModel")
local GlobalVars = GlobalVars
Laboratory.radius = 270 -- 普通科技圆环半径
Laboratory.beastRadius = 320 -- 巨兽科技圆环半径
Laboratory.minNum = 6 -- 普通科技一个圆环最少不低于多少个项
Laboratory.beastMinNum = 4 -- 巨兽科技一个圆环最少不低于多少个项
Laboratory.offsetAngle = 270 -- 普通科技角度偏移
Laboratory.beastOffsetAngle = 225 -- 巨兽科技角度偏移
Laboratory.orignHeight = 1334

function Laboratory:OnInit()
    self.isFirstOpen = true
    local view = self.Controller.contentPane
    GuidePanel:SetParentUI(self, UIType.LaboratoryUI)
    self._contentPane = view
    self._textRecommendTitle = view:GetChild("textOnResearch")
    self._researchTxtTitle = view:GetChild("textTipsName")
    self._researchTxtDesc = view:GetChild("textDescribe")
    self._researchTxtTab = view:GetChild("textIconName")
    self._researchIcon = view:GetChild("icon")
    self._researchTxtCurLv = view:GetChild("textNumber")
    self._researchTxtCurTime = view:GetChild("textTime")
    self._researchTimeBar = view:GetChild("progressBar")
    self._researchbtnHelp = view:GetChild("btnHelp")
    self._btnGo = view:GetChild("btnGo")

    self._itemTxtTitle = view:GetChild("textNameLeft")
    -- self._itemTagBgLeft = view:GetChild("bgTag")
    -- self._itemTagBgRight = view:GetChild("bgTagBlue")

    self._recommendItem1 = view:GetChild("itemDown1")
    self._item1TxtTitle = self._recommendItem1:GetChild("textNameLeft")
    self._item1TxtName = self._recommendItem1:GetChild("textIconNameLeft")
    self._item1TxtDesc = self._recommendItem1:GetChild("textIconNumLeft")
    self._item1TxtTab = self._recommendItem1:GetChild("textIconName")
    self._item1Icon = self._recommendItem1:GetChild("iconLeft")
    self._item1CurLv = self._recommendItem1:GetChild("textNumberLeft")
    self._item1Control = self._recommendItem1:GetController("c1")

    self._recommendItem2 = view:GetChild("itemDown2")
    self._item2TxtTitle = self._recommendItem2:GetChild("textNameLeft")
    self._item2TxtName = self._recommendItem2:GetChild("textIconNameLeft")
    self._item2TxtDesc = self._recommendItem2:GetChild("textIconNumLeft")
    self._item2TxtTab = self._recommendItem2:GetChild("textIconName")
    self._item2Icon = self._recommendItem2:GetChild("iconLeft")
    self._item2CurLv = self._recommendItem2:GetChild("textNumberLeft")
    self._item2Control = self._recommendItem2:GetController("c1")

    self._textMaxTip1 = view:GetChild("textDescribe2")
    self._textMaxTip2 = view:GetChild("textDescribe3")
    self._txtTitle = view:GetChild("textName")
    self._list = view:GetChild("liebiao")
    self._bottomControl = view:GetController("bottomControl")
    self._bgControl = view:GetController("bgControl")
    self.itemPool = {}
    self.tabItem = {}
    self.btnTab = {}

    local uibg = self._bgImage:GetChild("_icon")
    UITool.GetIcon({"falcon", "science_bg_01"},uibg)
    self._bgBox = self._contentPane:GetChild("bgBox")

    self:AddListener(self._researchIcon.onClick,
        function()
            Event.Broadcast(EventDefines.CloseGuide)
            if self.upgrade then
                UIMgr:Open(
                    "LaboratoryDetailPopup",
                    self.upgrade.TargetId,
                    self.techType,
                    self.upgrade,
                    function()
                        self:OnOpen(self.building)
                    end
                )
            elseif self.oneTab then
                UIMgr:Open(
                    "LaboratorySkill",
                    self.oneTab,
                    self.techType,
                    self.oneConfigId,
                    true,
                    self.building,
                    function()
                        self:OnOpen(self.building)
                    end
                )
            end
        end
    )

    self:AddListener(self._researchbtnHelp.onClick,
        function()
            Event.Broadcast(EventDefines.CloseGuide)
            if self.upgrade then
                UIMgr:Open(
                    "LaboratoryDetailPopup",
                    self.upgrade.TargetId,
                    self.techType,
                    self.upgrade,
                    function()
                        self:OnOpen(self.building)
                    end
                )
            elseif self.oneTab then
                UIMgr:Open(
                    "LaboratorySkill",
                    self.oneTab,
                    self.techType,
                    self.oneConfigId,
                    true,
                    self.building,
                    function()
                        self:OnOpen(self.building)
                    end,
                    true
                )
            end
        end
    )

    self:AddListener(self._btnGo.onClick,
        function()
            Event.Broadcast(EventDefines.CloseGuide)
            UIMgr:ClosePopAndTopPanel()
            if self.techType == Global.BeastTech then
                Event.Broadcast(EventDefines.UICityBuildTurn, Global.BuildingBeastScience, nil, true)
            else
                Event.Broadcast(EventDefines.UICityBuildTurn, Global.BuildingScience, nil, true)
            end
        end
    )

    -- 点击底部推荐研究界面推荐1跳转对应研究详情界面
    self:AddListener(self._recommendItem1.onClick,
        function()
            Event.Broadcast(EventDefines.CloseGuide)
            if self.leftTab ~= nil then
                UIMgr:Open(
                    "LaboratorySkill",
                    self.leftTab,
                    self.techType,
                    self.leftConfigId,
                    true,
                    self.building,
                    function()
                        self:OnOpen(self.building)
                    end,
                    true
                )
            end
        end
    )

    -- 点击底部推荐研究界面推荐2跳转对应研究详情界面
    self:AddListener(self._recommendItem2.onClick,
        function()
            Event.Broadcast(EventDefines.CloseGuide)
            if self.rightTab ~= nil then
                UIMgr:Open(
                    "LaboratorySkill",
                    self.rightTab,
                    self.techType,
                    self.rightConfigId,
                    true,
                    self.building,
                    function()
                        self:OnOpen(self.building)
                    end,
                    true
                )
            end
        end
    )

    local btnReturn = view:GetChild("btnReturn")
    self:AddListener(btnReturn.onClick,
        function()
            Event.Broadcast(EventDefines.CloseGuide)
            UIMgr:Close("Laboratory")
        end
    )

    self:AddEvent(
        EventDefines.UIRefreshTechResearchFinish,
        function()
            self:OnOpen(self.building)
        end
    )
end

function Laboratory:OnOpen(building)
    if building.ConfId == Global.BuildingBeastScience then
        self.configTab = "configBeastTechTabs"
        self.techType = Global.BeastTech
        self._bgControl.selectedPage = "titan"
        UITool.GetIcon({"falcon", "science_bg_03"},self._bgBox)
    else
        self.configTab = "configTechTabs"
        self.techType = Global.NormalTech
        self._bgControl.selectedPage = "human"
        UITool.GetIcon({"falcon", "science_bg_02"},self._bgBox)
    end
    -- TechModel.Building = building
    self.building = building
    self._techTabs = ConfigMgr.GetList(self.configTab)
    self.oneTab = nil
    if self.schedule_funtion then
        self:UnSchedule(self.schedule_funtion)
    end

    self:BuildBottomGroup()
    if self.isFirstOpen then
        self:FixBGImage()
        self.isFirstOpen = false
    end
    self:BuildTechTab()
end

-- 初始化底部界面。有正在研究的显示正在研究项，没有则显示推荐研究
function Laboratory:BuildBottomGroup()
    local upgrade = TechModel.GetUpgradeTech(self.techType)
    if upgrade ~= nil then
        self.upgrade = upgrade
        self._bottomControl.selectedPage = "onResearch"
        self:InitResearchGroup(upgrade)
    else
        self.upgrade = nil
        self:InitRecommendGroup()
    end
end

-- 初始化底部正在研究界面
function Laboratory:InitResearchGroup(upgrade)
    local config = TechModel.GetDisplayConfigItem(self.techType, upgrade.TargetId)
    local model = TechModel.FindByConfId(config.id)
    local skillName = TechModel.GetTechName(config.id)
    self._textRecommendTitle.text = skillName
    self._researchTxtDesc.text = TechModel.GetTechDesc(config.id)
    self._researchTxtCurLv.text = model.Level .. "/" .. config.max_lv
    self._researchIcon.url = UITool.GetIcon(config.icon)
    self._researchbtnHelp.text = ConfigMgr.GetI18n(I18nType.Commmon, "TITLE_DETAILS")

    local function time_func()
        return upgrade.FinishAt - Tool.Time()
    end
    if time_func() > 0 then
        local formatCT = Tool.FormatTime(time_func())
        self.schedule_funtion = function()
            local t = time_func()
            if t >= 0 then
                self._researchTxtCurTime.text = Tool.FormatTime(t)
                self._researchTimeBar.value = (1 - t / upgrade.Duration) * 100
            else
                self:InitRecommendGroup()
                if self.schedule_funtion then
                    self:UnSchedule(self.schedule_funtion)
                end
            end
        end
        self.schedule_funtion()
        self:Schedule(self.schedule_funtion, 1)
    end
end

-- 初始化底部研究推荐界面
function Laboratory:InitRecommendGroup()
    -- 左边推荐1、2、6类型
    -- local left = {1, 2, 6}
    local leftTemp = self:GetRecommendGroup(false)
    --Laboratory.GetCanUpgradeTechConfigByTab(left)
    -- 右边推荐3、4、5类型
    -- local right = {3, 4, 5}
    local rightTemp = self:GetRecommendGroup(true)
    --Laboratory.GetCanUpgradeTechConfigByTab(right)

    self._textRecommendTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Tech_Title2")

    if leftTemp ~= nil and rightTemp ~= nil then
        self._bottomControl.selectedPage = "twoRecommend"

        -- self._recommendItem1.visible = true
        self.leftTab = leftTemp.curConfig.tab
        self.leftConfigId = leftTemp.curConfig.id
        self._item1TxtTitle.text = ConfigMgr.GetI18n("configI18nTechs", "priority_type_0")
        self._item1TxtName.text = TechModel.GetTechName(leftTemp.curConfig.id)
        self._item1TxtDesc.text = TechModel.GetTechDesc(leftTemp.curConfig.id)
        self._item1TxtTab.text = TechModel.GetTechTypeName(self.techType, leftTemp.curConfig.tab)
        self._item1Icon.url = UITool.GetIcon(leftTemp.curConfig.icon)
        self._item1CurLv.text = (leftTemp.nextLvConfig.lv - 1) .. "/" .. leftTemp.curConfig.max_lv
        self._item1Control.selectedIndex = 1

        -- self._recommendItem2.visible = true
        self.rightTab = rightTemp.curConfig.tab
        self.rightConfigId = rightTemp.curConfig.id
        self._item2TxtTitle.text = ConfigMgr.GetI18n("configI18nTechs", "priority_type_1")
        self._item2TxtName.text = TechModel.GetTechName(rightTemp.curConfig.id)
        self._item2TxtDesc.text = TechModel.GetTechDesc(rightTemp.curConfig.id)
        self._item2TxtTab.text = TechModel.GetTechTypeName(self.techType, rightTemp.curConfig.tab)
        self._item2Icon.url = UITool.GetIcon(rightTemp.curConfig.icon)
        self._item2CurLv.text = (rightTemp.nextLvConfig.lv - 1) .. "/" .. rightTemp.curConfig.max_lv
        self._item2Control.selectedIndex = 0
    elseif leftTemp ~= nil or rightTemp ~= nil then
        self._bottomControl.selectedPage = "oneRecommend"
        local temp = leftTemp and leftTemp or rightTemp
        local tabConfig = ConfigMgr.GetItem(self.configTab, temp.curConfig.tab)
        -- if tabConfig.recommend then
        --     self._itemTagBgLeft.visible = false
        --     self._itemTagBgRight.visible = true
        -- else
        --     self._itemTagBgLeft.visible = true
        --     self._itemTagBgRight.visible = false
        -- end

        self.oneTab = temp.curConfig.tab
        self.oneConfigId = temp.curConfig.id
        self._itemTxtTitle.text = ConfigMgr.GetI18n("configI18nTechs", "priority_type_" .. (tabConfig.recommend and 1 or 0))
        self._researchTxtTitle.text = TechModel.GetTechName(temp.curConfig.id)
        self._researchTxtDesc.text = TechModel.GetTechDesc(temp.curConfig.id)
        self._researchTxtTab.text = TechModel.GetTechTypeName(self.techType, temp.curConfig.tab)
        self._researchIcon.url = UITool.GetIcon(temp.curConfig.icon)
        self._researchTxtCurLv.text = (temp.nextLvConfig.lv - 1) .. "/" .. temp.curConfig.max_lv
        self._researchbtnHelp.text = ConfigMgr.GetI18n(I18nType.Commmon, "BUTTON_RESEARCH")
    else
        if self.building.Level < BuildModel.GetConf(Global.BuildingScience).max_level then
            self._bottomControl.selectedPage = "curMax"
            self._textMaxTip1.text = StringUtil.GetI18n(I18nType.Tech, "tech_build_limit_full")
            self._textMaxTip2.text = StringUtil.GetI18n(I18nType.Tech, "tech_build_limit")
            self._researchbtnHelp.text = ConfigMgr.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
        else
            self._bottomControl.selectedPage = "max"
            self._textMaxTip1.text = StringUtil.GetI18n(I18nType.Tech, "tech_full")
        end
    end
end

function Laboratory:FixBGImage()
    local bgImage = self._contentPane:GetChild("_bgImage")
    local bgBox = self._contentPane:GetChild("bgBox")
    bgImage.height = GlobalVars.ScreenStandard.height
    if GlobalVars.ScreenRatio.x > GlobalVars.ScreenRatio.y and math.floor(GlobalVars.ScreenRatio.x * 100) ~= math.floor(GlobalVars.ScreenRatio.y * 100) then
        bgImage.xy = Vector2(0,90)
        bgBox.width = bgBox.width * (bgBox.height / GlobalVars.ScreenStandard.height)
    elseif GlobalVars.ScreenRatio.x < GlobalVars.ScreenRatio.y and math.floor(GlobalVars.ScreenRatio.x * 100) ~= math.floor(GlobalVars.ScreenRatio.y * 100) then
        bgImage.xy = Vector2(0,-140)
        bgBox.height = bgBox.height / (bgBox.height / GlobalVars.ScreenStandard.height)
        bgBox.xy = Vector2(0,-140)
    end
end

function Laboratory:BuildTechTab()
    local tabs, tabAmount = self:GetPositionTypeAmount(self._techTabs)

    self._list.scrollPane.touchEffect = (#tabs > 1)
    self._list:RemoveChildrenToPool()
    self._panel = self._list:AddItemFromPool()
    self._panel.width = self._list.width
    self._panel.height = self._list.height * tabAmount
    self:RecycleToPool()
    local isGuideShow = GuidePanel:IsGuideState(self.building, _G.GD.GameEnum.JumpType.Tech)
    local techId = nil
    local tableIndex = nil
    if isGuideShow then
        techId = JumpModel:GetTech()
        if techId == Global.BuildingScience then
            tableIndex = -1
        else
            tableIndex = TechModel.GetTabByConfId(techId, self.techType)
        end
    end
    -- 计算科技分类图标位置，圆环排布，x轴向右为正，y轴向下为正，12点方向为起点，顺时针旋转
    local offsetAngle = Laboratory.offsetAngle
    local radius = Laboratory.radius
    if self.techType == Global.BeastTech then
        offsetAngle = Laboratory.beastOffsetAngle
        radius = Laboratory.beastRadius
    end
    local origin = {x = (self._contentPane.width / 2), y = (self.orignHeight / 3)+20}
    if GlobalVars.ScreenRatio.x > GlobalVars.ScreenRatio.y and math.floor(GlobalVars.ScreenRatio.x * 100) ~= math.floor(GlobalVars.ScreenRatio.y * 100) then
        origin = origin + Vector2(0,90)
    elseif GlobalVars.ScreenRatio.x < GlobalVars.ScreenRatio.y and math.floor(GlobalVars.ScreenRatio.x * 100) ~= math.floor(GlobalVars.ScreenRatio.y * 100) then
        origin = origin + Vector2(0,-150)
        radius = radius * 0.8
    end
    for k, v in pairs(tabs) do
        local curOrigin = {x = origin.x, y = (origin.y + self._contentPane.height * (k - 1))}
        local amount = #v
        local angle = 360 / amount
        for i = 1, amount do
            local rad = math.rad(angle * (i - 1) + offsetAngle)
            local offsetX = radius * math.cos(rad)
            local offsetY = radius * math.sin(rad)
            local item = self:GetItem()
            item:SetPosition(curOrigin.x + offsetX, curOrigin.y + offsetY, 0)
            if GlobalVars.ScreenRatio.x < GlobalVars.ScreenRatio.y then
                item.scale = Vector2(0.8,0.8)
            end
            item:Init(
                v[i],
                self.techType,
                function(tabId)
                    if tabId ~= tableIndex then
                        Event.Broadcast(EventDefines.CloseGuide)
                    end
                    UIMgr:Open(
                        "LaboratorySkill",
                        tabId,
                        self.techType,
                        nil,
                        true,
                        self.building,
                        function()
                            self:OnOpen(self.building)
                        end
                    )
                end
            )
            self._panel:AddChild(item)
            local temp = {id = v[i], value = item}
            table.insert(self.btnTab, temp)
            if v[i] and v[i] ~= "" then
                self.tabItem[v[i].id] = item
            end
        end
    end
    if isGuideShow then
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.LaboratoryUI)
    end
end

function Laboratory:GetItem()
    local item
    if #self.itemPool > 0 then
        item = table.remove(self.itemPool, 1)
    else
        item = UIMgr:CreateObject("Laboratory", "btnItemLaboratoryTab")
        item.name = "Item"
    end

    return item
end

function Laboratory:RecycleToPool()
    for i = 1, self._panel.numChildren do
        table.insert(self.itemPool, self._panel:GetChildAt(i - 1))
    end
    self._panel:RemoveChildren()
    self.tabItem = {}
end

-- 获取tab按钮
function Laboratory:GetTabItem(tabId)
    return self.tabItem[tabId]
end

function Laboratory:GetPositionTypeAmount(techTabs)
    local tabs = {}
    local positions = {}
    local tabAmount = 0
    for k, v in pairs(techTabs) do
        local needAdd = true
        for k1, v1 in pairs(tabs) do
            if v.position == k1 then
                needAdd = false
                if v.place <= #v1 then
                    v1[v.place] = v
                else
                    for i = (#v1 + 1), v.place - 1 do
                        table.insert(v1, "")
                    end
                    table.insert(v1, v)
                end
                break
            end
        end

        if needAdd then
            tabAmount = tabAmount + 1
            table.insert(positions, v.position)
            tabs[v.position] = {}
            for i = 1, v.place - 1 do
                table.insert(tabs[v.position], "")
            end
            table.insert(tabs[v.position], v)
        end
    end

    -- 将子项数不足的圆环补足
    local min = Laboratory.minNum
    if self.techType == Global.BeastTech then
        min = Laboratory.beastMinNum
    end
        
    for k, v in pairs(positions) do
        local amount = #tabs[v]
        if amount < min then
            local num = min - amount
            for i = 1, num do
                table.insert(tabs[v], "")
            end
        end
    end

    return tabs, tabAmount
end

-- 按分类组返回当前升级时间最短的可升级技能显示配置和下一技能等级配置
function Laboratory:GetCanUpgradeTechConfigByTab(tabs)
    local leftTemp = nil
    local configs = TechModel.GetDisplayConfigList(self.techType)
    for k, v in pairs(tabs) do
        for k1, v1 in pairs(configs) do
            if v1.tab == v then
                local can, configLv = TechModel.CheckTechCanUpgrade(v1, self.techType)
                if can and (leftTemp == nil or configLv.duration < leftTemp.nextLvConfig.duration) then
                    leftTemp = {}
                    leftTemp.curConfig = v1
                    leftTemp.nextLvConfig = configLv
                end
            end
        end
    end

    return leftTemp
end

-- 按配置获取推荐技能组，true为右边的技能推荐
function Laboratory:GetRecommendGroup(isRight)
    local result = nil
    local configs = TechModel.GetDisplayConfigList(self.techType)
    for _, v in pairs(configs) do
        local tabConfig = ConfigMgr.GetItem(self.configTab, v.tab)
        local enabled = TechModel.CheckTabEnabled(tabConfig.id, self.techType)
        if tabConfig.recommend == isRight and enabled then
            local can, configLv = TechModel.CheckTechCanUpgrade(v, self.techType, false, true)
            if can and (result == nil or configLv.priority < result.nextLvConfig.priority) then
                result = {}
                result.curConfig = v
                result.nextLvConfig = configLv
            end
        end
    end

    return result
end

function Laboratory:TriggerGuideBtn(studyId)
    local tableIndex = TechModel.GetTabByConfId(studyId, self.techType)
    return self:GetTabItem(tableIndex)
end
function Laboratory:GuildShow(studyId)
    local btn = nil
    if studyId == nil then
        btn = self._recommendItem1
    else
        if studyId == self.building.ConfId then
            btn = self._recommendItem1
        else
            local tableIndex = TechModel.GetTabByConfId(studyId, self.techType)
            btn = self:GetTabItem(tableIndex)
        end
    end
    return btn
end

return Laboratory
