--[[
    author:Temmie
    time:2019-09-27 15:42:31
    function:指挥官技能升级、满级弹窗界面
]]
local PlayerSkillPopup = UIMgr:NewUI("PlayerSkillPopup")

local SkillModel = import("Model/SkillModel")

function PlayerSkillPopup:OnInit()
    local view = self.Controller.contentPane
    self._view = view
    self._typeControl = view:GetController("typeControl")

    self:AddListener(self._btnLearning.onClick,
        function()
            self._btnLearning.enabled = false
            Net.HeroSkills.LearnHeroSkill(
                self.curPage,
                self.config.id,
                1,
                function(rsp)
                    self._btnLearning.enabled = true

                    if rsp.Fail then
                        return
                    end

                    SkillModel.UpdateSkillPoints(rsp.SkillPoints, self.curPage)

                    for _, v in pairs(rsp.ChangedSkills) do
                        SkillModel.UpdateSkillModel(v, self.curPage)
                    end
                    if self.learncb then
                        self.learncb()
                    end
                    Event.Broadcast(EventDefines.RefreshSkillIconShow)
                    if self.config.skill_type == 2 then
                        SkillModel.SetASRedPointData(
                            self.config.id,
                            function()
                                Event.Broadcast(EventDefines.UIRefreshSkillRed)
                            end
                        )
                        Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.ActiveSkill)
                    end
                    Event.Broadcast(EventDefines.UIPlayerInfoExchange)

                    local model = SkillModel.GetModelById(self.config.id, self.curPage)
                    if model.Level < self.config.max_lv then
                        self:OnOpen(self.config.id, self.curPage, self.learncb, self.closecb)
                    else
                        if self.closecb then
                            self.closecb()
                        end
                        UIMgr:Close("PlayerSkillPopup")                        
                    end
                end
            )
        end
    )

    self:AddListener(self._btnAllLearning.onClick,
        function()
            self._btnAllLearning.enabled = false
            Net.HeroSkills.LearnHeroSkill(
                self.curPage,
                self.config.id,
                2,
                function(rsp)
                    self._btnAllLearning.enabled = true

                    if rsp.Fail then
                        return
                    end                    

                    SkillModel.UpdateSkillPoints(rsp.SkillPoints, self.curPage)
                    for _, v in pairs(rsp.ChangedSkills) do
                        SkillModel.UpdateSkillModel(v, self.curPage)
                    end
                    if self.learncb then
                        self.learncb()
                    end
                    Event.Broadcast(EventDefines.RefreshSkillIconShow)
                    if self.config.skill_type == 2 then
                        SkillModel.SetASRedPointData(
                            self.config.id,
                            function()
                                Event.Broadcast(EventDefines.UIRefreshSkillRed)
                            end
                        )
                        Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.ActiveSkill)
                    end
                    Event.Broadcast(EventDefines.UIPlayerInfoExchange)

                    local model = SkillModel.GetModelById(self.config.id, self.curPage)
                    if model.Level < self.config.max_lv then
                        self:OnOpen(self.config.id, self.curPage, self.learncb, self.closecb)
                    else
                        if self.closecb then
                            self.closecb()
                        end
                        UIMgr:Close("PlayerSkillPopup")                        
                    end
                    -- self:OnOpen(self.config.id, self.curPage, self.learncb, self.closecb)
                    if self.triggerCallBack then
                        UIMgr:Close("PlayerSkillPopup")
                        self.triggerCallBack()
                    end
                end
            )
        end
    )

    self:AddListener(self._btnClose.onClick,
        function()
            if self.closecb then
                self.closecb()
            end

            UIMgr:Close("PlayerSkillPopup")
        end
    )

    self:AddListener(self._btnMask.onClick,
        function()
            if self.closecb then
                self.closecb()
            end

            UIMgr:Close("PlayerSkillPopup")
        end
    )
end

function PlayerSkillPopup:OnOpen(confId, page, learnCB, closeCB)
    self.config = SkillModel.GetConfigById(confId)
    self.learncb = learnCB
    self.closecb = closeCB
    self.curPage = page
    self.model = SkillModel.GetModelById(confId, self.curPage)
    self._titleName.text = StringUtil.GetI18n(I18nType.Tech, self.config.id .. "_NAME")
    self._textCurrentName.text = StringUtil.GetI18n(I18nType.Tech, self.config.id .. "_DESC")
    -- self._textNextName.text = StringUtil.GetI18n(I18nType.Tech, self.config.id.."_DESC")
    self._textSingleDesc.text = StringUtil.GetI18n(I18nType.Tech, self.config.id .. "_DESC")
    self._btnLearning.enabled = (SkillModel.GetSkillPoints(self.curPage) > 0)
    self._btnAllLearning.enabled = (SkillModel.GetSkillPoints(self.curPage) > 0)

    self._iconItem:GetChild("_icon").url = UITool.GetIcon(self.config.icon)
    self._iconItem:GetChild("_textLv").visible = false
    self._iconItem:GetChild("levelBg").visible = false
    self._iconItem:GetChild("_textTip").visible = false
    self._iconItem:GetChild("numberBg").visible = false

    local buffConfig
    if self.config.buff_id then
        buffConfig = ConfigMgr.GetItem("configAttributes", self.config.buff_id[1])
    end
    if self.model.Level < self.config.max_lv then
        self._textLevel.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Level") .. self.model.Level
        self._textLevelNext.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Level") .. (self.model.Level + 1)
        if self.config.skill_type == 1 then
            self._typeControl.selectedPage = "upgrade"

            local nextValue = self.config.skill_number[1] + self.config.skill_add[1] * self.model.Level
            local curValue
            if self.model.Level > 0 then
                curValue = self.config.skill_number[1] + self.config.skill_add[1] * (self.model.Level - 1)
            else
                curValue = 0
            end

            local curText = curValue
            local nextText = nextValue
            if buffConfig and buffConfig.value_type == 2 then
                curText = (curValue / 100) .. "%"
                nextText = (nextValue / 100) .. "%"
            end

            -- self._textCurrentNum.text = curText
            -- self._textNextNum.text = nextText
            self._textProgressBar.text = curText .. "+" .. nextText
            local max = (self.config.skill_number[1] + self.config.skill_add[1] * (self.config.max_lv - 1))
            self._progressBar.value = curValue / max * 100
            self._progressBar2.value = (curValue + self.config.skill_add[1]) / max * 100
        else
            self._typeControl.selectedPage = "singleUpgrade"
        end
    else
        self._textLevelNext.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Level") .. self.model.Level
        if self.config.skill_type == 1 then
            self._typeControl.selectedPage = "max"
            self._textMax.text = "Lv.max"

            local curValue
            if self.model.Level > 0 then
                curValue = self.config.skill_number[1] + self.config.skill_add[1] * (self.model.Level - 1)
            else
                curValue = 0
            end
            if buffConfig and buffConfig.value_type == 2 then
                curValue = (curValue / 100) .. "%"
            end

            -- self._textCurrentNum.text = curValue
            self._textProgressBar.text = curValue
            self._progressBar.value = 100
            self._progressBar2.value = 100
        else
            self._typeControl.selectedPage = "singleMax"
            self._textMax.text = "Lv.max"
        end
    end
end

function PlayerSkillPopup:TriggerOnclick(callback)
    self.triggerCallBack = callback
end

return PlayerSkillPopup
