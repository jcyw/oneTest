local GD = _G.GD
local LaboratoryPopup = UIMgr:NewUI("LaboratoryPopup")

import("UI/Common/ItemCondition")
local TechModel = import("Model/TechModel")
local BuildModel = import("Model/BuildModel")
local UpgradeModel = import("Model/UpgradeModel")
local JumpMap = import("Model/JumpMap")
local triggerGuide = import("Model/TriggerGuideLogic")
local GuideModel = import("Model/GuideControllerModel")
local GlobalVars = GlobalVars

function LaboratoryPopup:OnInit()
    local view = self.Controller.contentPane
    self._view = view
    self._txtTitle = view:GetChild("titleName")
    self._icon = view:GetChild("btnIcon"):GetChild("icon")
    self._txtIncrease = view:GetChild("textIncreaseNumber")
    self._txtDetail = view:GetChild("textIncreaseDetail")
    self._txtCurLv = view:GetChild("textCurrent")
    self._txtNextLv = view:GetChild("textNext")
    self._txtDuration = view:GetChild("textTime")
    self._list = view:GetChild("liebiao")
    self._btnYellow = view:GetChild("btnYellow")
    self._btnGold = view:GetChild("btnGold")
    self._txtGem = self._btnGold:GetChild("text")
    self._txtLv = view:GetChild("textAllNumberLeft")
    self._grayControl = view:GetController("grayControl")

    view:GetChild("btnYellow"):GetChild("title").text = ConfigMgr.GetI18n("configI18nCommons", "BUTTON_RESEARCH")
    view:GetChild("btnIcon"):GetChild("textNumber").visible = false

    self:AddListener(self._btnYellow.onClick,
        function()
            if self.triggerCallBack then
                self.triggerCallBack()
            end
            local pass, res = TechModel.CheckTechUpgradeRes(self.config, self.techType)
            local lackRes = {}
            local needResList = {}
            if not pass then
                local canUseItemToFill = true
                for _, v in pairs(res) do
                    if not GD.ItemAgent.CanBackPackItemFillResNeed(v.category,v.amount) then
                        canUseItemToFill = false
                    end
                    table.insert(lackRes, {Category = v.category, Amount = v.amount})
                    table.insert(needResList, {resType = v.category, needCount = v.amount})
                end
                if not canUseItemToFill then
                    local data = {
                        textTip = StringUtil.GetI18n(I18nType.Commmon, "Tech_Res_Text1"),
                        lackRes = lackRes,
                        textBtnSure = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_RESEARCH"),
                        cbBtnSure = function()
                            self:Research()
                        end
                    }
                    UIMgr:Open("ConfirmPopupDissatisfaction", data)
                else
                    UIMgr:Open("ComfirmPopupUseRes", needResList,function()
                            self:Research()
                        end)
                end
            else
                TechModel.TryGetScienceAward()
                self:Research()
            end
        end
    )

    self:AddListener(self._btnGold.onClick,
        function()
            if self.updateGem > Model.Player.Gem then
                UITool.GoldLack()
                return
            end

            local func_response = function(rsp)
                if rsp.Fail then
                    return
                end

                if rsp.ResAmounts then
                    Event.Broadcast(EventDefines.UIResourcesAmount, rsp.ResAmounts)
                end
                if rsp.Gem then
                    Event.Broadcast(EventDefines.UIGemAmount, rsp.Gem)
                end
                if rsp.Tech then
                    TechModel.UpdateTechModel(rsp.Tech)
                end

                if self.techType == Global.NormalTech then
                    Model.ResearchGift = true
                else
                    Model.BeastResearchGift = true
                end

                -- 显示科技完成奖励气泡
                for _, v in pairs(Model.Buildings) do
                    if self.techType == Global.BeastTech and v.ConfId == Global.BuildingBeastScience then
                        BuildModel.GetObject(v.Id):ScienceAwardAnim(true)
                    elseif self.techType == Global.NormalTech and v.ConfId == Global.BuildingScience then
                        BuildModel.GetObject(v.Id):ScienceAwardAnim(true)
                    end
                end

                local config = TechModel.GetDisplayConfigItem(self.TechType, self.config.id)
                TipUtil.TipById(30105, {tech_name = TechModel.GetTechName(self.config.id)}, self.config.icon)

                self.callBack(self.config.id)
                self:OnOpen(self.config.id, self.techType, self.callBack)
            end
            local values = {
                diamond_num = self.updateGem
            }
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Ui_CompleteNow_Tech", values),
                gold = self.updateGem,
                tipType = TipType.TYPE.ConditionTech,
                sureCallback = function()
                    self._btnGold.enabled = false
                    TechModel.TryGetScienceAward()
                    SdkModel.TrackBreakPoint(10056) --打点
                    Net.Techs.Upgrade(self.config.id, true, func_response)
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    )

    local btnDetail = view:GetChild("btnDetail")
    self:AddListener(btnDetail.onClick,
        function()
            UIMgr:Open("LaboratoryPopupPanel", self.config.id, self.techType)
        end
    )

    local btnClose = view:GetChild("btnClose")
    self:AddListener(btnClose.onClick,
        function()
            UIMgr:Close("LaboratoryPopup")
        end
    )

    local bgMask = view:GetChild("bgMask")
    self:AddListener(bgMask.onClick,
        function()
            UIMgr:Close("LaboratoryPopup")
        end
    )
end

function LaboratoryPopup:OnOpen(configId, techType, callBack)
    self.techType = techType
    self.callBack = callBack
    self.config = TechModel.GetDisplayConfigItem(self.techType, configId)
    self._btnGold.enabled = true
    self._icon.url = UITool.GetIcon(self.config.icon)
    self._model = TechModel.FindByConfId(configId)
    self._curLvConfig = TechModel.GetTechConfigItem(self.techType, ((self._model == nil) and -1 or (self._model.ConfId + self._model.Level)))
    self._nextLvConfig = TechModel.GetTechConfigItem(self.techType, ((self._model == nil) and configId + 1 or (self._model.ConfId + self._model.Level + 1)))
    self._txtLv.text = (self._model) and self._model.Level .. "/" .. self.config.max_lv or "0/" .. self.config.max_lv

    if self._nextLvConfig == nil then
        UIMgr:Open("LaboratoryDetailPopup", configId, self.techType)
        UIMgr:Close("LaboratoryPopup")
        return
    end

    self._txtTitle.text = TechModel.GetTechName(self.config.id)
    self._txtDetail.text = TechModel.GetTechDesc(self.config.id)
    self._txtIncrease.text = self._curLvConfig and self._nextLvConfig.power - self._curLvConfig.power or self._nextLvConfig.power
    self._txtDuration.text = Tool.FormatTime(math.ceil(TechModel.GetRealResearchTime(self._nextLvConfig)))--Tool.FormatTime(self._nextLvConfig.duration)
    self.updateGem = self:GetGem()
    --Tool.TimeTurnGold(self._nextLvConfig.duration)
    self._txtGem.text = self.updateGem

    local curValue = (self._curLvConfig == nil) and 0 or self._curLvConfig.para2[1]
    curValue = self.config.show == 2 and curValue or ((curValue / 100) .. "%")
    self._txtCurLv.text = StringUtil.GetI18n(I18nType.Commmon, "Tech_Text2", {tech_effect = curValue})

    local nextValue = self._nextLvConfig.para2[1]
    nextValue = self.config.show == 2 and nextValue or ((nextValue / 100) .. "%")
    self._txtNextLv.text = StringUtil.GetI18n(I18nType.Commmon, "Tech_Text3", {tech_effect = nextValue})

    if TechModel.CheckUnlock(self.config, techType) then
        self._grayControl.selectedPage = "normal"
    else
        self._grayControl.selectedPage = "twoGray"
    end

    self:InitList()
end

function LaboratoryPopup:InitList()
    self._list:RemoveChildrenToPool()

    -- 正在升级的科技
    local upgrade = TechModel.GetUpgradeTech(self.techType)
    if upgrade ~= nil then
        local item = self._list:AddItemFromPool()
        local techConfig = TechModel.GetDisplayConfigItem(self.techType, upgrade.TargetId)
        local techModel = TechModel.FindByConfId(upgrade.TargetId)
        local isOk = false
        local data = {
            Icon = UITool.GetIcon(techConfig.icon),
            Title = StringUtil.GetI18n(I18nType.Commmon, "Building_UPGRADE_Now", {building_name = TechModel.GetTechName(techConfig.id), rest_time = ""}),
            TitleColor = isOk and Color.white or Color(0.82, 0.45, 0.32),
            IsSatisfy = isOk,
            Type = BuildType.CONDITION.Accelerate,
            Callback = function()
                local building = TechModel.GetTechBuilding(self.techType)
                if building then
                    UIMgr:Open(
                        "BuildAcceleratePopup",
                        building,
                        function(flag)
                            if self.callBack then
                                self.callBack(upgrade.TargetId)
                            end

                            self:OnOpen(self.config.id, self.techType, self.callBack)
                        end
                    )
                end
            end
        }
        item:Init(data)
        item:SetUpgrateTime(upgrade)
    end

    -- 前置建筑
    if self._nextLvConfig.building_condition ~= nil then
        for k, v in pairs(self._nextLvConfig.building_condition) do
            local item = self._list:AddItemFromPool()
            local buildConfig = ConfigMgr.GetItem("configBuildings", v.confId)
            local buildModel = BuildModel.FindByConfId(v.confId)
            local isOk = (buildModel ~= nil and v.level <= buildModel.Level)
            local data = {
                Icon = UITool.GetIcon(UpgradeModel.GetIcon(v.confId, BuildModel.FindByConfId(v.confId).Level)),
                Title = BuildModel.GetName(buildConfig.id) .. " " .. ConfigMgr.GetI18n(I18nType.Commmon, "rank_level") .. v.level,
                TitleColor = isOk and Color.white or Color(0.82, 0.45, 0.32),
                IsSatisfy = isOk,
                Type = BuildType.CONDITION.Turn,
                Callback = function()
                    UIMgr:ClosePopAndTopPanel()
                    local data = {jump = 810100, para = self.techType == Global.BeastTech and Global.BuildingBeastScience or Global.BuildingScience}
                    if not GlobalVars.IsInCity then
                        Event.Broadcast(
                            EventDefines.UIEnterMyCity,
                            function()
                                JumpMap:JumpTo(data)
                            end
                        )
                    else
                        JumpMap:JumpTo(data)
                    end
                end
            }
            item:Init(data)
        end
    end

    -- 前置科技
    if self._nextLvConfig.tech_condition ~= nil then
        for k, v in pairs(self._nextLvConfig.tech_condition) do
            local item = self._list:AddItemFromPool()
            local techConfig = TechModel.GetDisplayConfigItem(self.techType, v.confId)
            local techModel = TechModel.FindByConfId(v.confId)
            local isOk = (techModel ~= nil and v.level <= techModel.Level)
            if isOk then
                local data = {
                    Icon = UITool.GetIcon(techConfig.icon),
                    Title = TechModel.GetTechName(techConfig.id) .. " " .. ConfigMgr.GetI18n(I18nType.Commmon, "rank_level") .. v.level,
                    TitleColor = isOk and Color.white or Color(0.82, 0.45, 0.32),
                    IsSatisfy = isOk
                }
                item:Init(data)
            else
                local data = {
                    Icon = UITool.GetIcon(techConfig.icon),
                    Title = TechModel.GetTechName(techConfig.id) .. " " .. ConfigMgr.GetI18n(I18nType.Commmon, "rank_level") .. v.level,
                    TitleColor = isOk and Color.white or Color(0.82, 0.45, 0.32),
                    IsSatisfy = isOk,
                    Type = BuildType.CONDITION.Turn,
                    Callback = function()
                        local upgrade = TechModel.GetUpgradeTech(self.techType)
                        if upgrade ~= nil and upgrade.TargetId == v.confId then
                            UIMgr:Open(
                                "LaboratoryDetailPopup",
                                upgrade.TargetId,
                                self.techType,
                                upgrade,
                                function()
                                    self.callBack(upgrade.TargetId)
                                end
                            )
                        else
                            UIMgr:Close(
                                "LaboratoryPopup",
                                function()
                                    UIMgr:Open("LaboratoryPopup", v.confId, self.techType, self.callBack)
                                end
                            )
                        end
                    end
                }
                item:Init(data)
            end
        end
    end

    -- 需要资源量
    if self._nextLvConfig.res_req ~= nil then
        for k, v in pairs(self._nextLvConfig.res_req) do
            if v.amount > 0 then
                local item = self._list:AddItemFromPool()
                local resConfig = ConfigMgr.GetItem("configResourcess", v.category)
                local isOk = (GD.ResAgent.Amount(v.category) >= v.amount)
                local resName = ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_" .. resConfig.id)
                local ownRes = Tool.FormatNumberThousands(GD.ResAgent.Amount(v.category, false))
                local needRes = Tool.FormatNumberThousands(v.amount)
                local data = {
                    Icon = GD.ResAgent.GetIconUrl(v.category),
                    --"ui://Common/"..resConfig.img,
                    Title = StringUtil.GetI18n(I18nType.Commmon, "Tech_Text6", {res_name = resName, res_amount = needRes, res_use = ownRes}),
                    TitleColor = isOk and Color.white or Color(0.82, 0.45, 0.32),
                    IsSatisfy = isOk,
                    Type = BuildType.CONDITION.ResObtain,
                    Callback = function()
                        -- UIMgr:ClosePopAndTopPanel()
                        UIMgr:Close("LaboratoryPopup")
                        UIMgr:Open("ResourceDisplay", v.category, v.category, (v.amount - GD.ResAgent.Amount(v.category)), function()
                            UIMgr:Open("LaboratoryPopup", self.config.id, self.techType, self.callBack)
                        end)
                    end
                }
                item:Init(data)
            end
        end
    end
end

function LaboratoryPopup:GetGem()
    local timeGem = Tool.TimeTurnGold(self._nextLvConfig.duration)
    local amountResGem = 0
    if self._nextLvConfig.res_req ~= nil then
        for k, v in pairs(self._nextLvConfig.res_req) do
            local own = GD.ResAgent.Amount(v.category)
            if v.amount > 0 and own < v.amount then
                amountResGem = amountResGem + Tool.ResTurnGold(v.category, v.amount - own)
            end
        end
    end

    return timeGem + amountResGem
end

function LaboratoryPopup:Research()
    local func_response = function(rsp)
        if rsp.Fail then
            return
        end

        if rsp.ResAmounts then
            Event.Broadcast(EventDefines.UIResourcesAmount, rsp.ResAmounts)
        end
        if rsp.Event then
            Model.Create("UpgradeEvents", rsp.Event.Uuid, rsp.Event)
            local model = TechModel.FindByConfId(rsp.Event.TargetId)
            if model == nil then
                TechModel.UpdateTechModel({ConfId = rsp.Event.TargetId, Level = 0, Type = self.techType})
            end
        end

        local building = TechModel.GetTechBuilding(self.techType)
        if building then
            local buildObj = BuildModel.GetObject(building.Id)
            buildObj:ResetCD()
        end

        self.callBack(self.config.id)

        local upgrade = TechModel.GetUpgradeTech(self.techType)
        if not triggerGuide.IsGuideTriggering() then
            UIMgr:Open(
                "LaboratoryDetailPopup",
                self.config.id,
                self.techType,
                upgrade,
                function()
                    self.callBack(self.config.id)
                end
            )
        end
        UIMgr:Close("LaboratoryPopup")
    end

    SdkModel.TrackBreakPoint(10056) --打点
    Net.Techs.Upgrade(self.config.id, false, func_response)
end

function LaboratoryPopup:TriggerOnclick(callback)
        self.triggerCallBack = callback
end

return LaboratoryPopup
