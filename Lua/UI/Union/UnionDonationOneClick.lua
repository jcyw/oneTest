--[[
    author:Temmie
    time:2019-08-19 10:18:17
    function:联盟科技一键捐献
]]
local GD = _G.GD
local UnionDonationOneClick = UIMgr:NewUI("UnionDonationOneClick")

function UnionDonationOneClick:OnInit()
    self:AddListener(self._btnDonateL.onClick,function()
        if GD.ResAgent.Amount(self.resource.category, false) >= self.costNormalRes then
            self._btnDonateL.enabled = false
            Net.AllianceTech.MultiContribute(self.model.UuId, false, function(rsp)
                if rsp.Fail then
                    return
                end

                if self.cb then
                    self.cb(rsp.IsCooling, rsp.CoolTime, rsp.Tech)
                end

                TipUtil.TipById(50142, {honor_number = self.rewardL2, integral_number =self.rewardL1})
                Event.Broadcast(EventDefines.UIUnionDonateHonorRefresh, self.rewardL2)
                UIMgr:Close("UnionDonationOneClick")
            end)
        else
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Res_NoEnougha", {res_name = ConfigMgr.GetI18n(I18nType.Commmon, "RESOURE_TYPE_"..self.resource.category)}),
                sureBtnText = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_GetRes_Now"),
                sureCallback = function()
                    UIMgr:Open("ResourceDisplay", self.resource.category, self.resource.category, self.costNormalRes - GD.ResAgent.Amount(self.resource.category, false))
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    end)

    self:AddListener(self._btnDonateR.onClick,function()
        if GD.ResAgent.Amount(self.resource.category, false) >= self.costNormalRes and Model.Player.Gem >= self.costGem then
            self._btnDonateR.enabled = false
            Net.AllianceTech.MultiContribute(self.model.UuId, true, function(rsp)
                if rsp.Fail then
                    return
                end

                if self.cb then
                    self.cb(rsp.IsCooling, rsp.CoolTime, rsp.Tech)
                end

                TipUtil.TipById(50142, {honor_number = self.rewardR2, integral_number =self.rewardR1})
                Event.Broadcast(EventDefines.UIUnionDonateHonorRefresh, self.rewardR2)
                UIMgr:Close("UnionDonationOneClick")
            end)
        else
            if Model.Player.Gem < self.costGem then
                local data = {
                    content = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_Res_NoEnoughd"),
                    sureBtnText = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_GetDiamonds_Now"),
                    sureCallback = function()
                        -- 打开充值界面
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
            else
                local data = {
                    content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Res_NoEnougha", {res_name = ConfigMgr.GetI18n(I18nType.Commmon, "RESOURE_TYPE_"..self.resource.category)}),
                    sureBtnText = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_GetRes_Now"),
                    sureCallback = function()
                        UIMgr:Open("ResourceDisplay", self.resource.category, self.resource.category, self.costNormalRes - GD.ResAgent.Amount(self.resource.category, false))
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
            end
        end
    end)

    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("UnionDonationOneClick")
    end)
end

function UnionDonationOneClick:OnOpen(config, model, curValue, curTime, cb)
    self.model = model
    self.cb = cb
    self.detailConfig = ConfigMgr.GetItem("configAllanceTechs", config.id + model.Level)
    self._btnDonateL.enabled = true
    self._btnDonateR.enabled = true

    self.times = Global.ATMultiContriDefaultTimes
    curTime = curTime > 0 and curTime or 0
    local remainTime = math.ceil((Global.ATContributeCoolMax - curTime) / Global.ATContributeCoolTimeAdd)
    local remainValue = math.ceil((self.detailConfig.value[model.Stage+1] - curValue) / self.detailConfig.schedule)
    if remainTime > remainValue then
        if remainValue < self.times then
            self.times = remainValue
        end
    else
        if remainTime < self.times then
            self.times = remainTime
        end
    end
    
    self.resource = self.detailConfig.resource[model.Stage+1]
    self.costNormalRes = (self.times * self.resource.amount)
    self.costHighRes = math.floor((self.times * self.resource.amount * Global.ATMultiContriHighLevelResParam) / 100) * 100
    self.costGem = math.ceil(self.times * Global.ATMultiContriHighLevelGemParam)

    self.rewardL1 = self.times * self.detailConfig.schedule
    self._rewardL1:GetChild("icon").url = GD.ResAgent.GetIconUrl(Global.ResAlliancePoint)
    self._rewardL1:GetChild("title").text = "x"..self.rewardL1
    self.rewardL2 = self.times * self.detailConfig.contribution
    self._rewardL2:GetChild("icon").url = GD.ResAgent.GetIconUrl(Global.ResAllianceHonor)
    self._rewardL2:GetChild("title").text = "x"..self.rewardL2
    self._rewardL3:GetChild("icon").url = GD.ResAgent.GetIconUrl(self.resource.category)
    self._rewardL3:GetChild("title").text = "x"..self.costNormalRes

    self.rewardR1 = self.times * self.detailConfig.schedule * Global.ATMultiContriHighLevelTimes
    self._rewardR1:GetChild("icon").url = GD.ResAgent.GetIconUrl(Global.ResAlliancePoint)
    self._rewardR1:GetChild("title").text = "x"..self.rewardR1
    self.rewardR2 = self.times * self.detailConfig.contribution * Global.ATMultiContriHighLevelTimes
    self._rewardR2:GetChild("icon").url = GD.ResAgent.GetIconUrl(Global.ResAllianceHonor)
    self._rewardR2:GetChild("title").text = "x"..self.rewardR2
    self._rewardR3:GetChild("icon").url = GD.ResAgent.GetIconUrl(self.resource.category)
    self._rewardR3:GetChild("title").text = "x"..self.costHighRes
    self._rewardR4:GetChild("icon").url = GD.ResAgent.GetIconUrl(Global.ResDiamond)
    self._rewardR4:GetChild("title").text = "x"..self.costGem
    self._textCoin.text = self.costGem
end

return UnionDonationOneClick