-- 科技正在升级/满级界面
local LaboratoryDetailPopup = UIMgr:NewUI("LaboratoryDetailPopup")

local EventModel = import("Model/EventModel")
local TechModel = import("Model/TechModel")
local BuildModel = import("Model/BuildModel")

function LaboratoryDetailPopup:OnInit()
    local view = self.Controller.contentPane
    self._txtTitle = view:GetChild("titleName")
    self._icon = view:GetChild("btnIcon"):GetChild("icon")
    self._txtIncrease = view:GetChild("textIncreaseNumber")
    self._txtDetail = view:GetChild("textIncreaseDetail")
    self._txtCurLv = view:GetChild("textCurrent")
    self._txtNextLv = view:GetChild("textNext")
    self._txtDuration = view:GetChild("textTimeText")
    self._btnYellow = view:GetChild("btnYellow")
    self._btnGold = view:GetChild("btnGold")
    self._txtGem = self._btnGold:GetChild("text")
    self._panelControl = view:GetController("panelControl")
    self._txtMax = view:GetChild("textHighest")
    self._timeBar = view:GetChild("progressBarTime")
    self._txtLv = view:GetChild("btnIcon"):GetChild("textNumber")
    
    -- 求援或使用加速道具
    self:AddListener(self._btnYellow.onClick,function()
        local building = TechModel.GetTechBuilding(self.techType)
        if building then
            UIMgr:Open("BuildAcceleratePopup", building, 
            function(flag)
                self:TimeRefresh()
            end,
            function()
                UIMgr:Close("LaboratoryDetailPopup")
            end)
        end
    end)

    -- 金币研究
    self:AddListener(self._btnGold.onClick,function()
        local event = EventModel.GetUpgradeEvent(self.config.id)
        local time = event.FinishAt - Tool.Time()
        local needGold = Tool.TimeTurnGold(time)

        if Model.Player.Gem < needGold then
            UITool.GoldLack()
            return
        end

        local values = {
            diamond_num = needGold
        }
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, 'Ui_CompleteNow_Tech', values),
            gold = needGold,
            tipType = TipType.TYPE.ConditionTech,
            sureCallback = function()
                Net.Events.Speedup(
                    event.Category,
                    event.Uuid,
                    function(rsp)
                        if rsp.Fail then
                            return
                        end

                        Model.Delete(ModelType.UpgradeEvents, rsp.EventId)
                        TechModel.UpdateTechModel({ConfId = rsp.ConfId, Level = rsp.TechLevel, Type = rsp.TechType})
                        
                        if rsp.TechType == Global.NormalTech then
                            Model.ResearchGift = true
                        else
                            Model.BeastResearchGift = true
                        end

                        local building = TechModel.GetTechBuilding(self.techType)
                        if building then
                            local buildObj = BuildModel.GetObject(building.Id)
                            buildObj:ResetCD()
                        end
                        
                        -- 显示科技完成奖励气泡
                        for _, v in pairs(Model.Buildings) do
                            if self.techType == Global.BeastTech and v.ConfId == Global.BuildingBeastScience then
                                BuildModel.GetObject(v.Id):ScienceAwardAnim(true)
                                break
                            elseif self.techType == Global.NormalTech and v.ConfId == Global.BuildingScience then
                                BuildModel.GetObject(v.Id):ScienceAwardAnim(true)
                                break
                            end
                        end

                        local config = TechModel.GetDisplayConfigItem(self.techType, rsp.ConfId)
                        TipUtil.TipById(30105, {tech_name =  TechModel.GetTechName(rsp.ConfId)}, config.icon)

                        Event.Broadcast(EventDefines.UIRefreshTechResearchFinish, rsp.ConfId)

                        if self.callBack ~= nil then
                            self.callBack()
                        end
                        UIMgr:Close("LaboratoryDetailPopup")
                    end
                )
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end)

    local btnDetail = view:GetChild("btnDetail")
    self:AddListener(btnDetail.onClick,function()
        UIMgr:Open("LaboratoryPopupPanel", self.config.id, self.techType)
    end)

    local btnClose = view:GetChild("_btnClose")
    self:AddListener(btnClose.onClick,function()
        UIMgr:Close("LaboratoryDetailPopup")
    end)

    local bgMask = view:GetChild("bgMask")
    self:AddListener(bgMask.onClick,function()
        UIMgr:Close("LaboratoryDetailPopup")
    end)

    self:AddEvent(EventDefines.UIAllianceHelpOnHelp, function(rsp)
        if rsp.Fail then
            return
        end

        self:TimeRefresh()
    end)
end

function LaboratoryDetailPopup:OnOpen(configId, techType, upgrade, callBack)
    self.techType = techType
    self.configId = configId
    self.upgrade = upgrade
    self.callBack = callBack   
    if upgrade ~= nil then
        -- 当前为正在升级界面
        self:InitUpgradeUI(configId, upgrade, callBack)
    else
        -- 当前为满级界面
        self:InitMaxLvUI(configId)
    end
end

function LaboratoryDetailPopup:InitUpgradeUI(configId, upgrade, callBack)
    self.config = TechModel.GetDisplayConfigItem(self.techType, configId)
    self._txtMax.visible = false
    self._panelControl.selectedPage = "reaserch"
    self._btnYellow.visible = true
    self._btnGold.visible = true
    self._txtNextLv.visible = true
    self._model = TechModel.FindByConfId(configId)
    self._curLvConfig = TechModel.GetTechConfigItem(self.techType, ((self._model == nil) and -1 or (self._model.ConfId + self._model.Level)))
    self._nextLvConfig = TechModel.GetTechConfigItem(self.techType, ((self._model == nil) and configId+1 or (self._model.ConfId + self._model.Level+1)))
    self._txtTitle.text = TechModel.GetTechName(self.config.id)
    self._txtDetail.text = TechModel.GetTechDesc(self.config.id)
    local curPower = self._curLvConfig and self._curLvConfig.power or 0
    self._txtIncrease.text = self._nextLvConfig == nil and StringUtil.Format(I18nType.Commmon, "Button_Number_Big") or (self._nextLvConfig.power - curPower)
    local event = EventModel.GetUpgradeEvent(self.config.id)
    local time = 0
    if event then
        time = event.FinishAt - Tool.Time()
    end
    self._txtGem.text = Tool.TimeTurnGold(time)
    self._icon.url = UITool.GetIcon(self.config.icon) 
    self._txtLv.text = self._model.Level.."/"..self.config.max_lv

    self._btnYellow.text = ConfigMgr.GetI18n(I18nType.Commmon, "BUTTON_MYITEM_SPEEDUP")
    
    local curValue = (self._curLvConfig == nil) and 0 or self._curLvConfig.para2[1]
    curValue = self.config.show == 2 and curValue or ((curValue/100).."%")
    self._txtCurLv.text = StringUtil.GetI18n(I18nType.Commmon, "Tech_Text2", {tech_effect = curValue})

    local nextValue = self._nextLvConfig.para2[1]
    nextValue = self.config.show == 2 and nextValue or ((nextValue/100).."%")
    self._txtNextLv.text = StringUtil.GetI18n(I18nType.Commmon, "Tech_Text3", {tech_effect = nextValue})

    if self.schedule_funtion then
        self:UnSchedule(self.schedule_funtion)
    end

    local function time_func()
        return upgrade.FinishAt - Tool.Time()
    end
    if time_func() > 0 then
        local formatCT = Tool.FormatTime(time_func())
        self.schedule_funtion = function()
            local t = time_func()
            if t >= 0 then
                self._txtDuration.text = Tool.FormatTime(t)
                self._timeBar.value = (1 - t / upgrade.Duration) * 100
            else
                if self.schedule_funtion then
                    self:UnSchedule(self.schedule_funtion)
                end
                UIMgr:Close("LaboratoryDetailPopup")
            end
        end
        self.schedule_funtion()
        self:Schedule(self.schedule_funtion, 1)
    end
end

function LaboratoryDetailPopup:InitMaxLvUI(configId)
    self._txtMax.visible = true
    self._panelControl.selectedPage = "lvMax"
    self._btnYellow.visible = false
    self._btnGold.visible = false
    self._txtNextLv.visible = false
    self.config = TechModel.GetDisplayConfigItem(self.techType, configId)
    self._model = TechModel.FindByConfId(configId)
    self._curLvConfig = TechModel.GetTechConfigItem(self.techType, ((self._model == nil) and -1 or (self._model.ConfId + self._model.Level)))
    self._txtTitle.text = TechModel.GetTechName(self.config.id)
    self._txtDetail.text = TechModel.GetTechDesc(self.config.id)
    self._txtIncrease.text = self._curLvConfig.power
    local curValue = self._curLvConfig.para2[1]
    curValue = self.config.show == 2 and curValue or ((curValue/100).."%")
    self._txtCurLv.text = StringUtil.GetI18n(I18nType.Commmon, "Tech_Text2", {tech_effect = curValue})
    self._icon.url = UITool.GetIcon(self.config.icon) 
    self._txtLv.text = self._model.Level.."/"..self.config.max_lv
end

function LaboratoryDetailPopup:TimeRefresh()
    local upgrade = TechModel.GetUpgradeTech(self.techType)
    if self.callBack ~= nil then
        self.callBack()
    end

    if upgrade ~= nil then
        self:OnOpen(self.configId, self.techType, upgrade, self.callBack)
    else
        UIMgr:Close("LaboratoryDetailPopup")
    end
end

return LaboratoryDetailPopup