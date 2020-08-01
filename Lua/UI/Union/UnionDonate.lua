-- 联盟科技捐献界面
local GD = _G.GD
local UnionDonate = UIMgr:NewUI("UnionDonate")

local UnionModel = import("Model/UnionModel")
local BuildModel = import("Model/BuildModel")
local UnionInfoModel = import("Model/Union/UnionInfoModel")

function UnionDonate:OnInit()
    NodePool.Init(NodePool.KeyType.StarShowEffect, "Effect", "EffectNode")
    NodePool.Init(NodePool.KeyType.StarSweepEffect, "Effect", "EffectNode")
    local view = self.Controller.contentPane
    self._txtTitle = view:GetChild("titleName")
    self._txtDetail = view:GetChild("textSpeed")
    -- self._txtLv = view:GetChild("textLevelNum")
    self._icon = view:GetChild("btnIcon"):GetChild("icon")
    self._iconNum = view:GetChild("btnIcon"):GetChild("textNumber")
    self.iconRecommend = view:GetChild("btnIcon"):GetChild("group")
    self._btnRecommend = view:GetChild("btnRecommend")
    -- self._txtRecommend = view:GetChild("textRecommend")
    self._txtProgress = view:GetChild("textNum")
    self._txtProgressDonate = view:GetChild("textDonateNum")
    -- self._txtTimeProgress = view:GetChild("textProgressBar")
    self._barProgress = view:GetChild("progressBar")
    self._barProgressDonate = view:GetChild("progressBarDonate")
    self._txtCurEffect = view:GetChild("textLevelEffectNum")
    self._txtNextEffect = view:GetChild("textNextNum")
    self._nextEffectTitle = view:GetChild("textNext")
    self._txtTechValue = view:GetChild("textHonorNum")
    self._txtUnionCoinValue = view:GetChild("textCreditNum")

    self._btnDonateTop = view:GetChild("btnDonateT")
    self._iconTop = self._btnDonateTop:GetChild("icon")
    self._txtNumTop = self._btnDonateTop:GetChild("title")
    self._txtHonorTop = view:GetChild("textHonorNumLT")
    self._txtCreditTop = view:GetChild("textCreditNumLT")

    self._btnDonateLeft = view:GetChild("btnDonateL")
    self._iconLeft = self._btnDonateLeft:GetChild("icon")
    self._txtNumLeft = self._btnDonateLeft:GetChild("title")
    self._txtHonorLeft = view:GetChild("textHonorNum")
    self._txtCreditLeft = view:GetChild("textCreditNum")
    self._leftBtnController = view:GetController("leftBtnController")

    self._btnDonateRight = view:GetChild("btnDonateR")
    self._iconRight = self._btnDonateRight:GetChild("icon")
    self._txtNumRight = self._btnDonateRight:GetChild("title")
    self._txtHonorRight = view:GetChild("textHonorNumRT")
    self._txtCreditRight = view:GetChild("textCreditNumRT")
    self._rightBtnController = view:GetController("rightBtnController")

    self._btnDonateVip = view:GetChild("btnDonateAll")
    self._txtTime = view:GetChild("textTime")
    -- self._btnControl = view:GetController("btnControl")
    self._typeControl = view:GetController("typeControl")
    self._rmdController = view:GetController("rmdController")
    self.starIcons = { view:GetChild("iconStar1"), view:GetChild("iconStar2"), view:GetChild("iconStar3"), view:GetChild("iconStar4"), view:GetChild("iconStar5") }
    self.starBgs = { view:GetChild("bgStar1"), view:GetChild("bgStar2"), view:GetChild("bgStar3"), view:GetChild("bgStar4"), view:GetChild("bgStar5") }
    self.detailModel = nil -- 服务器返回的技能详细信息，对应AllianceTech服务器协议
    self.costs = {nil, nil, nil} -- 服务器返回的捐献所需资源信息，对应AllianceTechContriCost服务器协议
    self.bonusTimes = Global.ACCostBonusTimes

    self.iconRecommend.visible = false

    self:AddListener(self._btnRecommend.onClick,function()
        if self.detailModel.IsRecommended then
            -- self._btnRecommend.visible = true
            UnionModel.SetTechUnrecommend(self.detailModel.UuId, function(rsp)
                if rsp.Fail then
                    return
                end
                
                if self.callback then
                    self.callback()
                end
                -- self._btnRecommend.visible = false
                self._rmdController.selectedPage = "Unrecommend"
                self.detailModel.IsRecommended = false
            end)
        else
            if UnionModel.CheckRecommondMax() then
                TipUtil.TipById(50289)
                return
            end
            -- self._btnRecommend.visible = false
            UnionModel.SetTechRecommend(self.detailModel.UuId, function(rsp)
                if rsp.Fail then
                    return
                end
                
                if self.callback then
                    self.callback()
                end
                self._rmdController.selectedPage = "Recommend"
                self._btnRecommend.visible = true
                self.detailModel.IsRecommended = true
            end)
        end
    end)

    -- 普通捐献
    self:AddListener(self._btnDonateTop.onClick,function()
        if self.costs[1] ~= nil then
            if not self.CanPurchaseCool then
                TipUtil.TipById(50027)
            elseif self.isCool then
                self:OpenTipWindow()
            elseif CommonModel.IsResByCategory(self.costs[1].Cost.ConfId) and self.costs[1].Cost.Amount > GD.ResAgent.Amount(self.costs[1].Cost.ConfId) then
                --资源不足弹窗
                self:ResInsufficientPopup(self.costs[1].Cost.ConfId)
                --TipUtil.TipById(50286, {res_name = GD.ResAgent.GetName(self.costs[1].Cost.ConfId)})
            elseif not CommonModel.IsResByCategory(self.costs[1].Cost.ConfId) and Model.Player.Gem < self.costs[1].Cost.Amount then
                UITool.GoldLack()
            else
                self._btnDonateTop.touchable = false
                UnionModel.TechNormalDonate(self.detailModel.UuId, self.costs[1].Id, function(rsp)
                    self._btnDonateTop.touchable = true
                    self.isCool = rsp.IsCooling
                    self:RefreshTime(rsp.CoolTime)
                    self:SetCosts(rsp.NextCosts)
                    self:RefreshUI(rsp.Info)

                    local info = UnionInfoModel.GetInfo()
                    if not next(info) then 
                        UnionModel.RequestUnionInfo(function()
                            info = UnionInfoModel.GetInfo()
                            info.Honor = info.Honor + self.honor1
                            Event.Broadcast(EventDefines.UIUnionDonateHonorRefresh, self.honor1)
                        end)
                    else
                        info.Honor = info.Honor + self.honor1
                        Event.Broadcast(EventDefines.UIUnionDonateHonorRefresh, self.honor1)
                    end

                    TipUtil.TipById(50012, {number1 = self.honor1, number2 = self.tech1})
                end)
            end
        end
        -- Net.GM.AllianceTechContriMax(self.detailModel.UuId, function(rsp)
        --     self.callback()
        -- end)
    end)

    -- 5倍捐献
    self:AddListener(self._btnDonateLeft.onClick,function()
        if self.costs[2] ~= nil then
            if not self.CanPurchaseCool then
                TipUtil.TipById(50027)
            elseif self.isCool then
                self:OpenTipWindow()
            elseif CommonModel.IsResByCategory(self.costs[2].Cost.ConfId) and self.costs[2].Cost.Amount > GD.ResAgent.Amount(self.costs[2].Cost.ConfId) then
                --资源不足弹窗
                self:ResInsufficientPopup(self.costs[2].Cost.ConfId)
                --TipUtil.TipById(50286, {res_name = GD.ResAgent.GetName(self.costs[2].Cost.ConfId)})
            elseif not CommonModel.IsResByCategory(self.costs[2].Cost.ConfId) and Model.Player.Gem < self.costs[2].Cost.Amount then
                UITool.GoldLack()
            else
                self._btnDonateLeft.touchable = false
                UnionModel.TechNormalDonate(self.detailModel.UuId, self.costs[2].Id, function(rsp)
                    self._btnDonateLeft.touchable = true
                    self.isCool = rsp.IsCooling
                    self:RefreshTime(rsp.CoolTime)
                    self:SetCosts(rsp.NextCosts)
                    self:RefreshUI(rsp.Info)

                    local info = UnionInfoModel.GetInfo()
                    info.Honor = info.Honor + self.honor5

                    TipUtil.TipById(50012, {number1 = self.honor5, number2 = self.tech5})

                    Event.Broadcast(EventDefines.UIUnionDonateHonorRefresh, self.honor5)
                end)
            end
        end
    end)

    -- 25倍捐献
    self:AddListener(self._btnDonateRight.onClick,function()
        if self.costs[3] ~= nil then
            if not self.CanPurchaseCool then
                TipUtil.TipById(50027)
            elseif self.isCool then
                self:OpenTipWindow()
            elseif CommonModel.IsResByCategory(self.costs[3].Cost.ConfId) and self.costs[3].Cost.Amount > GD.ResAgent.Amount(self.costs[3].Cost.ConfId) then
                --资源不足弹窗
                self:ResInsufficientPopup(self.costs[3].Cost.ConfId)
                --TipUtil.TipById(50286, {res_name = GD.ResAgent.GetName(self.costs[3].Cost.ConfId)})
            elseif not CommonModel.IsResByCategory(self.costs[3].Cost.ConfId) and Model.Player.Gem < self.costs[3].Cost.Amount then
                UITool.GoldLack()
            else
                self._btnDonateRight.touchable = false
                UnionModel.TechNormalDonate(self.detailModel.UuId, self.costs[3].Id, function(rsp)
                    self._btnDonateRight.touchable = true
                    self.isCool = rsp.IsCooling
                    self:RefreshTime(rsp.CoolTime)
                    self:SetCosts(rsp.NextCosts)
                    self:RefreshUI(rsp.Info)

                    local info = UnionInfoModel.GetInfo()
                    --判空处理
                    local honor = info.Honor or 0
                    info.Honor = honor + self.honor25

                    TipUtil.TipById(50012, {number1 = self.honor25, number2 = self.tech25})

                    Event.Broadcast(EventDefines.UIUnionDonateHonorRefresh, self.honor25)
                end)
            end
        end
    end)

    -- 一键捐献
    self:AddListener(self._btnDonateVip.onClick,function()
        if not self.CanPurchaseCool then
            TipUtil.TipById(50027)
        elseif self.isCool then
            self:OpenTipWindow()
        else
            UIMgr:Open("UnionDonationOneClick", self.config, self.detailModel, self:GetCurContriProgress(), self.coolTime - Tool.Time(), function(isCooling, time, info)
                self.isCool = isCooling
                self:RefreshTime(time)
                self:RefreshUI(info)
            end)
        end
    end)

    local btnResearch = view:GetChild("_btnUse")
    self:AddListener(btnResearch.onClick,function()
        UnionModel.ResearchTech(self.detailModel.UuId, function(rsp)
            if self.callback then
                self.callback()
            end
            
            UIMgr:Close("UnionDonate")
        end)
    end)

    -- local btnDetail = view:GetChild("btnDetail")
    -- self:AddListener(btnDetail.onClick,function()
    --     
    -- end)

    local bgMask = view:GetChild("bgMask")
    self:AddListener(bgMask.onClick,function()
        -- if (self.detailModel.Level ~= self.config.max_lv) and (not self.detailModel.IsUp) and (self.detailModel.ContriProgress ~= self.detailModel.ContriMax) then
        --     return
        -- end
            
        if self.callback then
            self.callback()
        end
        
        UIMgr:Close("UnionDonate")
    end)

    local btnClose = view:GetChild("btnClose")
    self:AddListener(btnClose.onClick,function()
        if self.callback then
            self.callback()
        end
        
        UIMgr:Close("UnionDonate")
    end)
end

function UnionDonate:OnOpen(config, rsp, callback)
    self.config = config
    self.callback = callback
    self.detailModel = rsp.Info
    self.isCool = rsp.IsCooling
    self.CanPurchaseCool = rsp.CanPurchaseCool
    self.coolTime = rsp.CoolTime
    self._txtCurEffect.text = ""
    self._txtNextEffect.text = ""
    self._btnDonateTop.enabled = false
    self._btnDonateVip.enabled = false
    self._leftBtnController.selectedPage = "gray"
    self._rightBtnController.selectedPage = "gray"
    self._btnDonateTop.touchable = true
    self._btnDonateLeft.touchable = true
    self._btnDonateRight.touchable = true
    self.oldStarNum = self.detailModel.Stage

    self:RefreshTime(rsp.CoolTime)
    self:SetCosts(rsp.Costs)
    self:RefreshUI(self.detailModel)
end

function UnionDonate:RefreshUI(detailModel)
    self.detailModel = detailModel
    self.configAllanceTech = ConfigMgr.GetItem("configAllanceTechs", detailModel.ConfId)

    self._txtTitle.text = ConfigMgr.GetI18n("configI18nCommons", self.config.name_id)
    self._icon.url = UITool.GetIcon(self.config.icon_id)
    self._iconNum.text = detailModel.Level.."/"..self.config.max_lv
    self._txtDetail.text = ConfigMgr.GetI18n("configI18nCommons", self.config.description_id)
    -- self._btnRecommend.visible = self.detailModel.IsRecommended
    self._rmdController.selectedPage = self.detailModel.IsRecommended and "Recommend" or "Unrecommend"
    -- self._txtLv.text = self.detailModel.Level
    self._txtCurEffect.text = self.config.show == 1 and self.detailModel.CurrentBuffEffect or (self.detailModel.CurrentBuffEffect / 100).."%"
    self._txtNextEffect.text = self.config.show == 1 and self.detailModel.NextBuffEffect or (self.detailModel.NextBuffEffect / 100).."%"
    self._nextEffectTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceTech_NextEffect")

    if self.detailModel.Level == self.config.max_lv then -- 最大等级
        self:SetLvMaxPanel()
    elseif self.detailModel.IsUp then -- 正在升级
        self:SetUpgradingPanel()
    elseif self.detailModel.ContriProgress == self.detailModel.ContriMax then -- 可以升级
        self:SetWaitUpgradePanel()
    else
        self:SetDonatePanel()
    end

    if UnionModel.CheckPermission(GlobalAlliance.APUpgradeTech) then
        self._btnRecommend.visible = true
        -- self._txtRecommend.visible = true
        -- self.iconRecommend.visible = false
    else
        self._btnRecommend.visible = false
        -- self._txtRecommend.visible = false
        -- self.iconRecommend.visible = false
    end
end

-- 捐献界面
function UnionDonate:SetDonatePanel()
    self._typeControl.selectedPage = "donate"
    
    local barText = self:GetCurContriProgress().."/"..self:GetCurContriMax()
    local barValue = self:GetCurContriProgress() / self:GetCurContriMax() * 100
    self._txtProgress.text = barText
    self._barProgress.value = barValue
    self._txtProgressDonate.text = barText
    self._barProgressDonate.value = barValue

    self.honor1 = self.configAllanceTech.contribution
    self.tech1 = self.configAllanceTech.schedule
    self._txtHonorTop.text = self.tech1
    self._txtCreditTop.text = self.honor1

    self.honor5 = self.configAllanceTech.contribution * 5
    self.tech5 = self.configAllanceTech.schedule * 5
    self._txtHonorLeft.text = self.tech5
    self._txtCreditLeft.text = self.honor5

    self.honor25 = self.configAllanceTech.contribution * 25
    self.tech25 = self.configAllanceTech.schedule * 25
    self._txtHonorRight.text = self.tech25
    self._txtCreditRight.text = self.honor25

    if self.isCool then
        self._txtTime.color = Color.red
    else
        self._txtTime.color = Color.green
    end

    self:RefreshStarIcon()
    self:RefreshDonateButton()
end

-- 等待升级界面
function UnionDonate:SetWaitUpgradePanel()
    self._typeControl.selectedPage = "wait"

    self._barProgress.value = 100
    self._barProgressDonate.value = 100
    self._txtProgress.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceTech_ResearchTime")..Tool.FormatTimeOfSecond(self.configAllanceTech.time)
    -- self._txtTimeProgress.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceTech_ResearchTime")..Tool.FormatTimeOfSecond(self.configAllanceTech.time)
    
    self:RefreshStarIcon()
    self:RefreshDonateButton()
end

-- 正在升级界面
function UnionDonate:SetUpgradingPanel()
    self._typeControl.selectedPage = "researching"

    if self.schedule_funtion ~= nil then
        self:UnSchedule(self.schedule_funtion)
    end

    local time = Tool.Time()
    local ct = self.detailModel.ResearchEndAt - time
    if ct > 0 then
        local formatCT = Tool.FormatTime(ct)
        self.schedule_funtion = function()
            ct = ct - 1
            if ct > 0 then
                local barValue = (Tool.Time() - self.detailModel.ResearchStartAt) / (self.detailModel.ResearchEndAt - self.detailModel.ResearchStartAt) * 100
                -- self._txtTimeProgress.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceTech_ResearchTime")..Tool.FormatTime(ct)
                self._txtProgress.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceTech_ResearchTime")..Tool.FormatTime(ct)
                self._barProgress.value = barValue
                self._barProgressDonate.value = barValue
            else
                if self.schedule_funtion then
                    self:UnSchedule(self.schedule_funtion)
                end
                self.callback()
            end
        end
        self.schedule_funtion()
        self:Schedule(self.schedule_funtion, 1)
    end
    
    self:RefreshStarIcon()
    self:RefreshDonateButton()
end

-- 满级界面
function UnionDonate:SetLvMaxPanel()
    self._typeControl.selectedPage = "max"
    self._txtNextEffect.text = ""
    self._nextEffectTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceTech_LvMax")

    self:RefreshDonateButton()
end

function UnionDonate:RefreshDonateButton()
    
    if self.costs[1] ~= nill then
        self._btnDonateTop.enabled = true
    else
        self._btnDonateTop.enabled = false
    end

    if self.costs[2] ~= nill then
        self._leftBtnController.selectedPage = "normal"
    else
        self._leftBtnController.selectedPage = "gray"
    end

    if self.costs[3] ~= nill then
        self._rightBtnController.selectedPage = "normal"
    else
        self._rightBtnController.selectedPage = "gray"
    end

    if BuildModel.GetCenterLevel() >= Global.ATMultiContriUnlockLv then
        -- self._btnControl.selectedPage = "show"
        self._btnDonateVip.enabled = true
    else
        -- self._btnControl.selectedPage = "hide"
        self._btnDonateVip.enabled = false
    end
end

function UnionDonate:RefreshStarIcon()
    -- for _,v in pairs(self.starIcons) do
    --     v.visible = false
    -- end
    for i = 1,#self.starIcons do
        self.starIcons[i].visible = false
        if self["effect"..i] then
            self["effect"..i]:StopEffect()
            NodePool.Set(NodePool.KeyType.StarShowEffect, self["effect"..i])
            self["effect"..i] = nil
        end
        if self["effectStar"..i] then
            self["effectStar"..i]:StopEffect()
            NodePool.Set(NodePool.KeyType.StarSweepEffect, self["effectStar"..i])
            self["effectStar"..i] = nil
        end
    end
    for _,v in pairs(self.starBgs) do
        v.visible = false
    end
    for i=1,self.config.donate do
        self.starBgs[i].visible = true
    end
    for i=1,self.detailModel.Stage do
        self.starIcons[i].visible = true
        self.starIcons[i].fillAmount = 1
    end
    for i=1,self.detailModel.Stage do
        if i > (self.oldStarNum or self.detailModel.Stage) and (self.oldStarNum or self.detailModel.Stage) < self.detailModel.Stage then
            if not self["effect"..i] then
                self["effect"..i] = NodePool.Get(NodePool.KeyType.StarShowEffect)
                self.Controller.contentPane:AddChild(self["effect"..i])
                self["effect"..i].xy = Vector2(self.starIcons[i].x + self.starIcons[i].width / 2, self.starIcons[i].y + self.starIcons[i].height / 2 + 1)
            end
            self["effect"..i]:PlayDynamicEffectSingle("effect_collect","effect_star_dot",
                function()
                    if self["effect"..i] then
                        NodePool.Set(NodePool.KeyType.StarShowEffect, self["effect"..i])
                    end
                    self.starIcons[i].visible = true
                    self.starIcons[i].fillAmount = 1
                    self["effect"..i] = nil
                    if not self["effectStar"..i] then
                        self["effectStar"..i] = NodePool.Get(NodePool.KeyType.StarSweepEffect)
                        self.Controller.contentPane:AddChild(self["effectStar"..i])
                        self["effectStar"..i].xy = Vector2(self.starIcons[i].x + self.starIcons[i].width / 2, self.starIcons[i].y + self.starIcons[i].height / 2)
                    end
                    self["effectStar"..i]:PlayDynamicEffectLoop("effect_collect","effect_star_sweep_prefab",Vector3(100, 100, 100),1)
                end, Vector3(100, 100, 1),nil,1)
        else
            self.starIcons[i].visible = true
            self.starIcons[i].fillAmount = 1
            if not self["effectStar"..i] then
                self["effectStar"..i] = NodePool.Get(NodePool.KeyType.StarSweepEffect)
                self.Controller.contentPane:AddChild(self["effectStar"..i])
                self["effectStar"..i].xy = Vector2(self.starIcons[i].x + self.starIcons[i].width / 2, self.starIcons[i].y + self.starIcons[i].height / 2)
            end
            self["effectStar"..i]:PlayDynamicEffectLoop("effect_collect","effect_star_sweep_prefab",Vector3(100, 100, 100),1)
        end
    end
    if self.detailModel.ContriProgress == self.detailModel.ContriMax then
        self.starIcons[self.detailModel.Stage+1].visible = true
        self.starIcons[self.detailModel.Stage+1].fillAmount = 1
    elseif self.detailModel.ContriProgress > 0 then
        self.starIcons[self.detailModel.Stage+1].visible = true
        self.starIcons[self.detailModel.Stage+1].fillAmount = 0.5
    else
        self.starIcons[self.detailModel.Stage+1].visible = true
        self.starIcons[self.detailModel.Stage+1].fillAmount = 0
    end
    self.oldStarNum = self.detailModel.Stage
end

function UnionDonate:GetCurContriProgress()
    local finishValue = 0
    for i=1,self.detailModel.Stage do
        finishValue = finishValue + self.configAllanceTech.value[i]
    end

    return self.detailModel.ContriProgress - finishValue
end

function UnionDonate:GetCurContriMax()
    return self.configAllanceTech.value[self.detailModel.Stage+1]
end

function UnionDonate:SetCosts(costs)
    self.costs = {nil, nil, nil}
    
    for _,v in pairs(costs) do
        if v.Times ~= self.bonusTimes[1] and v.Times ~= self.bonusTimes[2] then
            self.costs[1] = v
            self._iconTop.url = GD.ResAgent.GetIconUrl(Model.Resources[v.Cost.ConfId].Category)
            self._txtNumTop.text = v.Cost.Amount
            if GD.ResAgent.Amount(v.Cost.ConfId, false) < v.Cost.Amount then
                self._txtNumTop.color = Color(0.98, 0.36, 0.25)
            else
                self._txtNumTop.color = Color(0.47, 0.85, 1)
            end
        elseif v.Times == self.bonusTimes[1] then
            self.costs[2] = v
            self._iconLeft.url = GD.ResAgent.GetIconUrl(Model.Resources[v.Cost.ConfId].Category)
            self._txtNumLeft.text = v.Cost.Amount
            if GD.ResAgent.Amount(v.Cost.ConfId, false) < v.Cost.Amount then
                self._txtNumLeft.color = Color(0.98, 0.36, 0.25)
            else
                self._txtNumLeft.color = Color(0.47, 0.85, 1)
            end
        else
            self.costs[3] = v
            self._iconRight.url = GD.ResAgent.GetIconUrl(Model.Resources[v.Cost.ConfId].Category)
            self._txtNumRight.text = v.Cost.Amount
            if GD.ResAgent.Amount(v.Cost.ConfId, false) < v.Cost.Amount then
                self._txtNumRight.color = Color(0.98, 0.36, 0.25)
            else
                self._txtNumRight.color = Color(0.47, 0.85, 1)
            end
        end
    end
end

function UnionDonate:RefreshTime(time)
    self.coolTime = time
    
    if self.schedule_funtion ~= nil then
        self:UnSchedule(self.schedule_funtion)
    end

    self._txtTime.text = "00:00:00"
    local ct = time - Tool.Time()
    if ct > 0 then
        local formatCT = Tool.FormatTime(ct)
        self.schedule_funtion = function()
            ct = ct - 1
            if ct >= 0 then
                self._txtTime.text = Tool.FormatTime(ct)
                self.coolTime = self.coolTime - 1
            else
                self._txtTime.text = "00:00:00"
                self.coolTime = 0
                if self.schedule_funtion then
                    self:UnSchedule(self.schedule_funtion)
                end
            end
        end
        self.schedule_funtion()
        self:Schedule(self.schedule_funtion, 1)
    end
end

function UnionDonate:OpenTipWindow()
    local cost = math.floor((self.coolTime - Tool.Time()) / 120)
    cost = cost < 1 and 1 or cost
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceTech_CleanCd", {diamond_num = cost}),
        gold = cost,
        sureBtnText = ConfigMgr.GetI18n(I18nType.Commmon, "System_Option_Button3"),
        sureCallback = function()
            Net.AllianceTech.PurchaseContriCooldown(function(rsp)
                if rsp.Fail then
                    return
                end

                self._txtTime.text = "00:00:00"
                self._txtTime.color = Color.green
                self.coolTime = 0
                self.isCool = false

                Model.Player.AllianceTechCanContri = true
                Event.Broadcast(EventDefines.UIUnionScience)
                self:UnSchedule(self.schedule_funtion)
            end)
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end


--资源不足时弹窗
function UnionDonate:ResInsufficientPopup(resType)
    local data = {
        content = ConfigMgr.GetI18n("configI18nCommons", "Ui_Res_NoEnough"),
        sureBtnText = ConfigMgr.GetI18n("configI18nCommons", "Ui_GetRes_Now"),
        sureCallback = function()
            UIMgr:Open("ResourceDisplay", resType)
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
    UIMgr:Close("UnionDonate")
end

return UnionDonate