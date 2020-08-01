-- 联盟科技列表具体科技项
local ItemUnionScienceDonateClick = fgui.extension_class(GButton)
fgui.register_extension("ui://Union/itemUnionScienceDonateClick", ItemUnionScienceDonateClick)

local UnionModel = import("Model/UnionModel")

function ItemUnionScienceDonateClick:ctor()
    self._txtTitle = self:GetChild("textUnionSize")
    self._txtLv = self:GetChild("textLevelNum")
    self._txtNextLv = self:GetChild("textLevelNum2")
    self._recommendTip = self:GetChild("bgRecommend")
    self._textRecommend = self:GetChild("textRecommend")
    self._icon = self:GetChild("icon")
    self._txtResearchTime = self:GetChild("textResearchTimeNum")
    self._txtUpgradeProgress = self:GetChild("textProgressTime")
    self._barUpgradeProgress = self:GetChild("progressBar")
    self._btnResearch = self:GetChild("btnResearch")
    self._stateControl = self:GetController("stateControl")
    self.starIcons = { self:GetChild("iconStar1"), self:GetChild("iconStar2"), self:GetChild("iconStar3"), self:GetChild("iconStar4"), self:GetChild("iconStar5") }
    self.starBgs = { self:GetChild("bgStar1"), self:GetChild("bgStar2"), self:GetChild("bgStar3"), self:GetChild("bgStar4"), self:GetChild("bgStar5") }

    self:AddListener(self._btnResearch.onClick,function()
        if UnionModel.CheckUpgradeTech() then
            TipUtil.TipById(50285)
        else
            UnionModel.ResearchTech(self.model.UuId, function(rsp)
                self.callback()
            end)
        end
    end)

    self:AddListener(self:GetChild("bgButton").onClick,function()
        if not self.isLock then
            -- if self.model.Level == self.config.max_lv or self.model.IsUp or self.model.ContriProgress == self.model.ContriMax then
            --     return
            -- end

            -- 获取技能详细信息，结构为AllianceTech服务器协议
            UnionModel.GetTechDetail(self.model.UuId, function(rsp)
                if rsp.Fail then
                    return
                end

                UIMgr:Open("UnionDonate", self.config, rsp, self.callback)
            end)
        else
            TipUtil.TipById(50276)
        end
    end)
end

-- model 结构为AllianceTech服务器协议
function ItemUnionScienceDonateClick:Init(config, model, isLock, callback)
    NodePool.Init(NodePool.KeyType.StarShowEffect, "Effect", "EffectNode")
    NodePool.Init(NodePool.KeyType.StarSweepEffect, "Effect", "EffectNode")
    self.config = config
    self.model = model
    self.isLock = isLock
    self.callback = callback
    self._txtTitle.text = ConfigMgr.GetI18n("configI18nCommons", config.name_id)
    self._txtLv.text = model.Level
    self._icon.url = UITool.GetIcon(config.icon_id)
    
    self._recommendTip.visible = self.model.IsRecommended
    self._textRecommend.visible = self.model.IsRecommended

    -- 设置信息显示组
    if model.Level == config.max_lv then -- 最大等级
        self:SetLvMaxPanel()
    elseif model.IsUp then -- 正在升级
        self:SetUpgradingPanel()
    elseif model.ContriProgress == model.ContriMax then -- 可以升级
        self:SetWaitUpgradePanel()
    else
        self:SetDonatePanel()
    end

    if not self.isLock then
        self._icon.grayed = false
    else
        self._icon.grayed = true
    end
end

function ItemUnionScienceDonateClick:SetDonatePanel()
    self._stateControl.selectedPage = "star"

    -- 设置星星
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
    for i=1,self.model.Stage do
        if i > (self.oldStarNum or self.model.Stage) and (self.oldStarNum or self.model.Stage) < self.model.Stage then
            if not self["effect"..i] then
                self["effect"..i] = NodePool.Get(NodePool.KeyType.StarShowEffect)
                self:AddChild(self["effect"..i])
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
                        self:AddChild(self["effectStar"..i])
                        self["effectStar"..i].xy = Vector2(self.starIcons[i].x + self.starIcons[i].width / 2, self.starIcons[i].y + self.starIcons[i].height / 2)
                    end
                    self["effectStar"..i]:PlayDynamicEffectLoop("effect_collect","effect_star_sweep_prefab",Vector3(100, 100, 100),1)
                end, Vector3(100, 100, 1),nil,1)
        else
            self.starIcons[i].visible = true
            self.starIcons[i].fillAmount = 1
            if not self["effectStar"..i] then
                self["effectStar"..i] = NodePool.Get(NodePool.KeyType.StarSweepEffect)
                self:AddChild(self["effectStar"..i])
                self["effectStar"..i].xy = Vector2(self.starIcons[i].x + self.starIcons[i].width / 2, self.starIcons[i].y + self.starIcons[i].height / 2)
            end
            self["effectStar"..i]:PlayDynamicEffectLoop("effect_collect","effect_star_sweep_prefab",Vector3(100, 100, 100),1)
        end
    end
    if not self.isLock then
        if self.model.IsContriProgress == self.model.ContriMax then
            self.starIcons[self.model.Stage+1].visible = true
            self.starIcons[self.model.Stage+1].fillAmount = 1
        elseif self.model.ContriProgress > 0 then
            self.starIcons[self.model.Stage+1].visible = true
            self.starIcons[self.model.Stage+1].fillAmount = 0.5
        else
            self.starIcons[self.model.Stage+1].visible = true
            self.starIcons[self.model.Stage+1].fillAmount = 0
        end
    end
    self.oldStarNum = self.model.Stage
end

function ItemUnionScienceDonateClick:SetWaitUpgradePanel()
    self._stateControl.selectedPage = "research"

    local detailConfig = ConfigMgr.GetItem("configAllanceTechs", self.model.ConfId)
    self._txtResearchTime.text = Tool.FormatTimeOfSecond(detailConfig.time)

    if UnionModel.CheckPermission(GlobalAlliance.APUpgradeTech) then
        self._btnResearch.visible = true
    else
        self._btnResearch.visible = false
    end
end

function ItemUnionScienceDonateClick:SetUpgradingPanel()
    self._stateControl.selectedPage = "upgrade"

    self._txtNextLv.text = self.model.Level + 1
    local time = Tool.Time()
    local ct = self.model.ResearchEndAt - time
    if ct > 0 then
        local formatCT = Tool.FormatTime(ct)
        self.schedule_funtion = function()
            ct = ct - 1
            if ct > 0 then
                self._txtUpgradeProgress.text = Tool.FormatTime(ct)
                self._barUpgradeProgress.value = (Tool.Time() - self.model.ResearchStartAt) / (self.model.ResearchEndAt - self.model.ResearchStartAt) * 100
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
end

function ItemUnionScienceDonateClick:SetLvMaxPanel()
    self._stateControl.selectedPage = "max"
end

return ItemUnionScienceDonateClick