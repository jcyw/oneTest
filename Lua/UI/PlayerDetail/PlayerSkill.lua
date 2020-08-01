--[[
    author:Temmie
    time:2019-09-24 15:07:00
    function:指挥官技能
]]
local GD = _G.GD
local PlayerSkill = UIMgr:NewUI("PlayerSkill")

local SkillModel = import("Model/SkillModel")

PlayerSkill.MaxColume = 3 -- 总列数
-- PlayerSkill.Rowledge = 100 -- 行距
PlayerSkill.ItemHalfHight = 108
PlayerSkill.ItemHalfWidth = 88
PlayerSkill.ConlumeOffset = -235

function PlayerSkill:OnInit()
    local view = self.Controller.contentPane
    self.distence = 0
    self.columePosTable = {}
    self.itemPool = {}
    self.linePool = {}
    self._btnReset:GetChild("text").text = Tool.FormatNumberThousands(Global.PlayerSkillSwitch)
    self._activeControl = view:GetController("activeControl")

    self:InitConfig()
    self:Perprocessing()

    self:AddListener(self._btnBattle.onClick,
        function()
            self:BtnBattleClick()
        end
    )

    self:AddListener(self._btnProgress.onClick,
        function()
            self:BtnProgressClick()
            if self.triggerFunc then
                self.triggerFunc()
            end
        end
    )

    self:AddListener(self._btnAssist.onClick,
        function()
            self:BtnAssistClick()
        end
    )

    -- self:AddListener(self._btnActive.onClick,function()
    --     if Model.Player.Gem < Global.PlayerSkillSwitch then
    --         UITool.GoldLack()
    --     else
    --         Net.HeroSkills.SwitchSkillPage(self.curPage, function(rsp)
    --             if rsp.Fail then
    --                 return
    --             end

    --             SkillModel.UpdateCurPage(self.curPage)
    --             self._activeControl.selectedPage = "active"
    --         end)
    --     end
    -- end)

    self:AddListener(self._btnReset.onClick,
        function()
            local func = function()
                Net.HeroSkills.ResetAllSkills(
                    self.curPage,
                    function(rsp)
                        if rsp.Fail then
                            return
                        end

                        SkillModel.UpdateSkillPoints(rsp.Points, self.curPage)
                        SkillModel.ResetSkills(rsp.Skills, self.curPage)
                        self:RefreshList(true)
                        self:RefreshListBtnNum()
                        Event.Broadcast(EventDefines.RefreshSkillIconShow)
                        Event.Broadcast(EventDefines.UIPlayerInfoExchange)
                    end
                )
            end

            local item = GD.ItemAgent.GetItemModelById(GlobalItem.ItemResetSkill)
            if item and item.Amount > 0 then
                local config = ConfigMgr.GetItem("configItems", item.ConfId)
                local data = {
                    content = StringUtil.GetI18n(I18nType.Commmon, "Ui_ResetSkill_Tips"),
                    itemNum = 1,
                    sureBtnIcon = UITool.GetIcon(config.icon),
                    sureCallback = function()
                        func()
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
            else
                if Model.Player.Gem < Global.PlayerSkillReset then
                    UITool.GoldLack()
                else
                    local data = {
                        content = StringUtil.GetI18n(I18nType.Commmon, "Ui_ResetSkill_Tips"),
                        gold = Global.PlayerSkillSwitch,
                        sureCallback = function()
                            func()
                        end
                    }
                    UIMgr:Open("ConfirmPopupText", data)
                end
            end
        end
    )

    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("PlayerSkill")
        end
    )

    self:AddListener(self._list.scrollPane.onScroll, function()
        for _,v in pairs(self.effectItem) do
            local effect = v:GetEffect()
            if effect then
                effect.visible = CommonModel.CheckListItemEffectVisible(v, self._list)
            end
        end
    end)
end

-- function PlayerSkill:InitPageButton()
--     self.pageButtons = {
--         [1] = self._btnSkillSet1,
--         [2] = self._btnSkillSet2,
--         [3] = self._btnSkillSet3
--     }

--     for k,v in pairs(self.pageButtons) do
--         if SkillModel.GetPageActive(k) then
--             v:GetChild("iconLock").visible = false
--             local fun = function(page)
--                 if self.curPage == page then
--                     return
--                 end

--                 self.curPage = page
--                 if SkillModel.GetCurPage() == self.curPage then
--                     self._activeControl.selectedPage = "active"
--                 else
--                     self._activeControl.selectedPage = "unactive"
--                 end
--                 self:RefreshList(true)
--             end
--             self:AddListener(v.onClick,function()
--                 fun(k)
--             end)
--         else
--             v:GetChild("iconLock").visible = true
--             self:AddListener(v.onClick,function()
--                 self.pageButtons[self.curPage].selected = true
--             end)
--         end
--     end

--     self.pageButtons[self.curPage].selected = true
-- end

function PlayerSkill:OnOpen(confId)
    --引导
    if Model.Player.HeroLevel < 4 then
        Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.Level, 13200, 0)
    end
    self.skillItems = {}
    self.maxRow = 0
    self.enterSelectedId = confId
    self.enterSelected = nil
    self.curType = Global.PlayerSkillBattle
    self.curPage = SkillModel.GetCurPage()
    self._activeControl.selectedPage = "active"

    -- self:InitPageButton()

    local config = SkillModel.GetConfigById(self.enterSelectedId)
    if config then
        if config.skill_type2 == 1 then
            self._btnBattle.selected = true
            self:BtnBattleClick()
        elseif config.skill_type2 == 2 then
            self._btnProgress.selected = true
            self:BtnProgressClick()
        elseif config.skill_type2 == 3 then
            self._btnAssist.selected = true
            self:BtnAssistClick()
        end
    else
        self:BtnBattleClick()
    end

    if self.enterSelected then
        self._list.scrollPane:ScrollToView(self.enterSelected, true)
    end

    self:RefreshListBtnNum()
end

function PlayerSkill:BtnBattleClick()
    self._btnBattle.selected = true
    self._textDescribe.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Commander_SkillBattle_tips")
    self.curType = Global.PlayerSkillBattle
    self:RefreshList(true)
end

function PlayerSkill:BtnProgressClick()
    self._btnProgress.selected = true
    self._textDescribe.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Commander_SkillGrow_tips")

    self.curType = Global.PlayerSkillProgress
    self:RefreshList(true)
end

function PlayerSkill:BtnAssistClick()
    self._btnAssist.selected = true
    self._textDescribe.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Commander_Skillauxiliary_tips")
    self.curType = Global.PlayerSkillAssist

    self:RefreshList(true)
end

function PlayerSkill:RefreshListBtnNum()
    local battlePoint = SkillModel.GetPointAmountOfType(Global.PlayerSkillBattle, SkillModel.GetCurPage())
    self._btnBattle:GetChild("text").text = battlePoint

    local progressPoint = SkillModel.GetPointAmountOfType(Global.PlayerSkillProgress, SkillModel.GetCurPage())
    self._btnProgress:GetChild("text").text = progressPoint

    local assistPoint = SkillModel.GetPointAmountOfType(Global.PlayerSkillAssist, SkillModel.GetCurPage())
    self._btnAssist:GetChild("text").text = assistPoint

    if battlePoint > 0 or progressPoint > 0 or assistPoint > 0 then
        self._btnReset.enabled = true
    else
        self._btnReset.enabled = false
    end

    local item = GD.ItemAgent.GetItemModelById(GlobalItem.ItemResetSkill)
    if item and item.Amount > 0 then
        local config = ConfigMgr.GetItem("configItems", item.ConfId)
        if config then
            self._btnReset:GetChild("icon").url = UITool.GetIcon(config.icon)
            self._btnReset:GetChild("text").text = item.Amount
        end
    else
        self._btnReset:GetChild("icon").url = GD.ResAgent.GetIconUrl(Global.ResDiamond, false)
        self._btnReset:GetChild("text").text = Tool.FormatNumberThousands(Global.PlayerSkillSwitch)
    end
end

function PlayerSkill:RefreshList(isScrollTop)
    self._textSkillNumber.text = SkillModel.GetSkillPoints(self.curPage)

    local typeConfigs, maxRow = self:GetSkillConfigsByType(self.curType)
    self.maxRow = maxRow

    self._list:RemoveChildrenToPool()
    self.panel = self._list:AddItemFromPool()
    self._list.scrollItemToViewOnClick = false
    self:RecycleToPool()
    self.panel.width = self._list.width
    self.panel.height = (self.maxRow - 1) * (self.ItemHalfHight * 2) + self.ItemHalfHight * 2

    self:BuildSkillItem(typeConfigs)
    self:BuildSkillLine(typeConfigs)

    if isScrollTop then
        self._list.scrollPane:ScrollTop()
    end
end

-- 生成线
function PlayerSkill:BuildSkillLine(configs)
    for _, v in pairs(configs) do
        if v.config.relation then
            for _, v2 in pairs(v.config.relation) do
                local offset = v2.x - v.config.position.x
                if offset ~= 0 then
                    local line = self:GetLine()
                    self.panel:AddChild(line)
                    local x, y = self:TransitionXY(v.config.position.x, v.config.position.y)
                    -- local symbol = offset / math.abs(offset)
                    line:SetPosition(x + self.ItemHalfWidth * 0.5 - 5, y - self.ItemHalfHight + 4, 0)
                    line.rotation = 270 * (offset / math.abs(offset))
                    line.height = math.abs(offset) * self.distence + 3

                    local curModel = SkillModel.GetModelById(v.config.id, self.curPage)
                    if curModel then
                        line:SetLight(true)
                    else
                        line:SetLight(false)
                    end
                end
            end
        end
    end
end

-- 生成科技图标
function PlayerSkill:BuildSkillItem(configs)
    self.effectItem = {}
    for _, v in pairs(configs) do
        local selfModel = SkillModel.GetModelById(v.config.id, self.curPage)
        local item = self:GetItem()
        if self.enterSelectedId == v.config.id then
            self.enterSelected = item
        end
        self.panel:AddChildAt(item, 0)
        local x, y = self:TransitionXY(v.config.position.x, v.config.position.y)
        item:SetPosition(x - self.ItemHalfWidth * 0.5, y - self.ItemHalfHight, 0)
        self.callback = nil

        if #v.nexts > 0 then
            item:SetDownLineVisible(true)
        else
            item:SetDownLineVisible(false)
        end

        if selfModel then
            --技能已解锁
            self.callback = function(confId)
                UIMgr:Open(
                    "PlayerSkillPopup",
                    confId,
                    self.curPage,
                    function()
                        self._textSkillNumber.text = SkillModel.GetSkillPoints(self.curPage)
                        self:RefreshListBtnNum()
                    end,
                    function()
                        self:RefreshList(false)
                    end
                )
            end

            for _, v2 in pairs(v.nexts) do
                local nextModel = SkillModel.GetModelById(v2.id, self.curPage)
                if nextModel then
                    item:SetDownLineLight(true)
                    break
                else
                    item:SetDownLineLight(false)
                end
            end
        else
            --技能未解锁
            self.callback = function(confId)
                UIMgr:Open("PlayerSkillLock", confId)
            end

            item:SetDownLineLight(false)
        end

        if not v.config.relation then
            item:SetUpLineVisible(false)
        else
            item:SetUpLineVisible(true)

            if selfModel then
                item:SetUpLineLight(true)
            else
                item:SetUpLineLight(false)
            end
        end

        item:Init(v.config, self.curPage, self.callback)
        --item:SetTip("hide")
        table.insert(self.skillItems, item)

        local effect = item:GetEffect()
        if effect then
            table.insert(self.effectItem, item)
            if effect then
                effect.visible = CommonModel.CheckListItemEffectVisible(item, self._list)
            end
        end
    end
end

function PlayerSkill:Perprocessing()
    local uiWidth = self._list.width / PlayerSkill.MaxColume

    -- 计算列的位置
    for i = 1, PlayerSkill.MaxColume do
        table.insert(self.columePosTable, math.floor((uiWidth * (i - 1) + (uiWidth / 2) - self.ItemHalfWidth / 2)))
    end

    -- 计算两个图标间距离
    if #self.columePosTable > 1 then
        self.distence = self.columePosTable[2] - self.columePosTable[1]
    end
end

function PlayerSkill:InitConfig()
    self.skillConfig = {}
    local config = SkillModel.GetConfigs()
    for _, v in pairs(config) do
        local nexts = {}
        for _, v2 in pairs(config) do
            if v.skill_type2 == v2.skill_type2 and v2.relation then
                for _, v3 in pairs(v2.relation) do
                    if v.position.x == v3.x and v.position.y == v3.y then
                        table.insert(nexts, v2)
                        break
                    end
                end
            end
        end

        table.insert(self.skillConfig, {config = v, nexts = nexts})
    end
end

function PlayerSkill:GetItem()
    local item
    if #self.itemPool > 0 then
        item = table.remove(self.itemPool, 1)
        item.visible = true
    else
        item = UIMgr:CreateObject("PlayerDetail", "itemPlayerSkill")
        item.name = "Item"
    end
    return item
end

function PlayerSkill:GetLine()
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

function PlayerSkill:GetGrayLine()
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

-- 根据配置的行列算出具体坐标
function PlayerSkill:TransitionXY(x, y)
    return self.columePosTable[x], self.ItemHalfHight + (self.ItemHalfHight * 2) * (y - 1)
end

--根据confid获取item
function PlayerSkill:GetItemByConfid(confId)
    for _, v in pairs(self.skillItems) do
        if v.config.id == confId then
            return v
        end
    end
end

function PlayerSkill:RecycleToPool()
    local children = {}
    for i = 1, self.panel.numChildren do
        local object = self.panel:GetChildAt(i - 1)
        table.insert(children, object)
        if object.name == "Item" then
            object:StopEffect()
            table.insert(self.itemPool, object)
        elseif object.name == "Line" then
            table.insert(self.linePool, object)
        end
    end

    for _, v in pairs(children) do
        self._list.parent:AddChild(v)
        v.visible = false
    end

    self.panel:RemoveChildren()
end

-- 根据类别和位置获取技能配置
function PlayerSkill.GetConfigByPos(configs, x, y)
    for _, v in pairs(configs) do
        if v.config.position.x == x and v.config.position.y == y then
            return v
        end
    end
end

function PlayerSkill:GetSkillConfigsByType(type)
    local maxRow = 0
    local typeConfig = {}
    for _, v in pairs(self.skillConfig) do
        if v.config.skill_type2 == type then
            table.insert(typeConfig, v)
            if maxRow < v.config.position.y then
                maxRow = v.config.position.y
            end
        end
    end

    return typeConfig, maxRow
end

function PlayerSkill:TriggerOnclick(callback)
        self.triggerFunc = callback
end

return PlayerSkill
