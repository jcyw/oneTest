--[[    author:{maxiaolong}
    time:2019-10-31 11:26:40
    function:{主动技能面板}
]]
local MainActiveSkills = UIMgr:NewUI("MainActiveSkills")
local SkillModel = import("Model/SkillModel")
local TurnModel = import("Model/TurnModel")
local itemMainActive = import("UI/MainCity/ItemMainActiveSkills")
local MissionEventModel = import("Model/MissionEventModel")
local BuildModel = import("Model/BuildModel")
local GiftModel = import("Model/GiftModel")
local GlobalVars = GlobalVars
MainActiveSkills.cutClickId = 0

function MainActiveSkills:OnInit()
    self.view = self.Controller.contentPane
    self._btnSkill1 = self.view:GetChild("btnSkillSet1")
    self._btnSkill2 = self.view:GetChild("btnSkillSet2")
    self._btnSkill3 = self.view:GetChild("btnSkillSet3")
    self._list = self.view:GetChild("liebiao")
    self._closeBtn = self.view:GetChild("_btnClose")
    self._controller = self.view:GetController("c1")
    self._controller.selectedIndex = 0
    self._titleName = self.view:GetChild("textNameDaily")
    self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVE_SKILL")
    self._bgPopup = self.view:GetChild("bgPopup")
    self._topTilte = self.view:GetChild("_title")
    self._topDes = self.view:GetChild("_textGold")
    self._topIcon = self.view:GetChild("icon")
    self._topBtnUseNo = self.view:GetChild("_btnUseNo")
    self._topbtnUse = self.view:GetChild("_btnUse")
    self._topTextTime = self.view:GetChild("textTime")
    self.skillCDStr = StringUtil.GetI18n(I18nType.Commmon, "UI_SKILL_CD")
    self.goToStr = StringUtil.GetI18n(I18nType.Commmon, "UI_GO_TO_SEE")
    self.activeSkillStr = StringUtil.GetI18n(I18nType.Commmon, "UI_SKILL_ACTION_TIME")
    self.NoSkill = StringUtil.GetI18n(I18nType.Commmon, "TIPS_NO_LEARN_SKILL")
    self.TimerType = {
        NullTimer = 0,
        CDTimer = 1,
        ExpireTimer = 2
    }
    self.cutTimer = self.TimerType.NullTimer
    self:AddListener(self._mask.onClick,
        function()
            self:ClosePanel()
        end
    )
    self:AddListener(self._closeBtn.onClick,
        function()
            self:ClosePanel()
        end
    )
    self:AddListener(self._btnCloseBox.onClick,
        function()
            self:ClosePanel()
        end
    )
    self._list.itemRenderer = function(index, item)
        if self.skillParams == nil then
            return
        end
        local data = self.skillParams[index + 1]
        item:SetData(data, self, index + 1)
    end
    self:AddListener(self._topbtnUse.onClick,
        function()
            if self._controller.selectedIndex == 2 then
                if self.cutClickId ~= nil then
                    UIMgr:Open("PlayerSkill", self.cutClickId)
                    self:ClosePanel()
                end
            elseif self._controller.selectedIndex == 3 then
                if self.triggerFunc then
                    self.triggerFunc()
                    self.triggerFunc = nil
                end
                if self.cutClickId == 611600 then --立即返回
                    if MissionEventModel.GetMissionAmount() == 0 then
                        local data = {
                            content = StringUtil.GetI18n(I18nType.Commmon, "PlayerSkill_Tips")
                        }
                        self:ClosePanel()
                        UIMgr:Open("ConfirmPopupText", data)
                        return
                    end
                end
                Net.HeroSkills.UseActiveSkill(
                    self.cutClickId,
                    function(params)
                        if params.OK == true then
                            self:ActiveTurnById(self.cutClickId)
                            local skillId = tonumber(self.cutClickId)
                            SkillModel.RemoveRedPointData(skillId)
                            Event.Broadcast(EventDefines.UIRefreshSkillRed)
                            self:OnSkillUseEffect()
                        else
                            return
                        end
                    end
                )
                self:ClosePanel()
            else
                return
            end
        end
    )
    --主动技能收取资源时候通知
    self:AddEvent(
        EventDefines.SkillGetResInfo,
        function(rsp)
            for _, v in pairs(rsp.Res) do
                local buildObj = BuildModel.GetObject(v.BuildId)
                buildObj:HarestEndAnim(v.Amount)
            end
        end
    )
end

function MainActiveSkills:OnOpen()
    if GlobalVars.IsTriggerStatus then
        self._list.scrollPane.touchEffect = false
        self._list.scrollItemToViewOnClick = false
    else
        self._list.scrollPane.touchEffect = true
        self._list.scrollItemToViewOnClick = true
    end
    self._controller.selectedIndex = 0
    self._list.scrollPane.posX = 0
    Net.HeroSkills.GetActiveSkillsInfo(
        function(params)
            self.skillParams = {}
            local activityInfo = SkillModel:GetActiveSkillConfig(params.Skills)
            self.skillParams = activityInfo
            local num = #activityInfo
            self._list.numItems = num
            if num > 0 then
                for i = 1, num do
                    self._list:GetChildAt(i - 1):SetSelectedShow()
                end
            --self._list:GetChildAt(0):SetSelectedShow(true)
            end
        end
    )
end

function MainActiveSkills:DoOpenAnim(...)
    self:OnOpen(...)
    --设置层级
    self.Controller.contentPane.sortingOrder = self.Controller.contentPane.sortingOrder + 1
    self.Controller.sortingOrder = self.Controller.sortingOrder + 1

    AnimationLayer.PanelAnim(AnimationType.ActiveSkills, self)
end

function MainActiveSkills:OnPenStateSet(name, icon, des, skillId, cutState, cdTime, expireTime, cdSumTime)
    if cutState == ActivitySkillType.lOCK then
        self:SelectdeView(2)
    elseif cutState == ActivitySkillType.UNCD then
        self:SelectdeView(3)
    elseif cutState == ActivitySkillType.CD or cutState == ActivitySkillType.EXPIRE then
        self:SelectdeView(1)
    else
        self:SelectdeView(0)
    end
    self._topTilte.text = name
    self._topIcon.icon = UITool.GetIcon(icon)
    self._topDes.text = des
    self.cutClickId = skillId
    local str = ""
    if cutState == 0 then
        self._topTextTime.text = self.NoSkill
    elseif cutState == 1 then --冷却中
        if cdTime > 0 then
            self.cutTimer = self.TimerType.CDTimer
        end
    elseif cutState == 2 then --使用
        local itemCofing = SkillModel.GetConfigById(self.cutClickId)
        if itemCofing.skill_cd == nil then
            return
        end
        self.cdTimeStr = Tool.FormatTimeOfSecond(cdSumTime)
        self._topTextTime.text = self.skillCDStr .. self.cdTimeStr
    elseif cutState == 3 then --作用中
        if expireTime ~= nil and expireTime > 0 then
            self.cutTimer = self.TimerType.ExpireTimer
        end
    end
end

function MainActiveSkills:ActiveTurnById(id)
    if id == 622000 then --资源丰收
        local mapMoveFunc = function()
            local piece = CityMapModel.GetMapPiece(207)
            ScrollModel.Move(piece.x, piece.y, true)
        end
        if not GlobalVars.IsInCity then
            GiftModel.IgnoreGiftPush = true
            Event.Broadcast(EventDefines.UIEnterMyCity)
            self:ScheduleOnceFast(
                function()
                    GiftModel.IgnoreGiftPush = false
                    mapMoveFunc()
                end,
                0.7
            )
            return
        end
        mapMoveFunc()
    elseif id == 622200 then --资源保护
        TipUtil.TipById(30108)
    elseif id == 611600 then --立即返回
        TurnModel.WorldMap()
    else
        TipUtil.TipById(30108)
    end
end

function MainActiveSkills:RefreshMainActive(timeText)
    if self._controller.selectedIndex ~= 1 then
        return
    end
    if self.cutTimer == self.TimerType.CDTimer then
        self._topTextTime.text = self.skillCDStr .. timeText
    elseif self.cutTimer == self.TimerType.ExpireTimer then
        self._topTextTime.text = self.activeSkillStr .. timeText
    end
end

function MainActiveSkills:SelectdeView(index)
    self._controller.selectedIndex = index
    local title = self._topbtnUse:GetChild("title")
    if index == 0 then
        return
    elseif index == 1 then
        self._topBtnUseNo:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_USE_ITEM")
    elseif index == 2 then
        title.text = self.goToStr
    elseif index == 3 then
        title.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_USE_ITEM")
    end
end
--刷新页面数据
function MainActiveSkills:RefreshView(cdTime)
    local timeStr = cdTime - Tool.Time()
    local timestr1 = Tool.FormatTimeOfSecond(timeStr)
    self._topTextTime.text = self.skillCDStr .. timestr1
end

function MainActiveSkills:GetSkillId()
    if self.cutClickId then
        return self.cutClickId
    end
end

function MainActiveSkills:ClosePanel()
    if GlobalVars.IsTriggerStatus and GlobalVars.NowTriggerId == 11700 then
        return
    end
    UIMgr:Close("MainActiveSkills")
end

function MainActiveSkills:OnClose()
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        item:Closeschedule()
    end
end

--播放使用主动技能特效
function MainActiveSkills:OnSkillUseEffect()
    if self.cutClickId == 622000 then
        --资源丰收
        --AnimationModel.ResHarvest()
        AnimationModel.ResHarvestEffect()
    end
end

--通过id获得技能点位置
function MainActiveSkills:GetItemByIsActivity()
    local tempItem = nil
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        if item._controller.selectedIndex == 2 then
            return item
        end
    end
end

function MainActiveSkills:TriggerOnclick(callback)
        self.triggerFunc = callback
end

return MainActiveSkills
