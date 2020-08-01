--[[
    author:{maxiaolong }
    time:2019-09-29 13:47:04
    function:{月卡列表元素单元}
]]
local GD = _G.GD
local itemSuperCheapCard = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemSuperCheapCard", itemSuperCheapCard)

local WelfareModel = import("Model/WelfareModel")
local rewardNum = 0
function itemSuperCheapCard:ctor()
    --StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FALCON")
    self.staus = 0;
    self._textMaximum.text = StringUtil.GetI18n(I18nType.Commmon, "NewDiamondsFund_Desc1")
    self._textRenew.text = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_5")
    self._textIntegral.text = StringUtil.GetI18n(I18nType.Commmon, "NewDiamondsFund_Desc2")
    
    --self._DiamondBuyBtn = self:GetChild("textRenew")
    self._DiamondBuyBtnNum = self._DiamondBuyBtn:GetChild("title")
    self._DiamondBuyBtnDec = self._DiamondBuyBtn:GetChild("dec")
    self._DiamondBuyBtnDec.text = StringUtil.GetI18n(I18nType.Commmon, "NewDiamondsFund_BuyDesc")
    

    self._DiamondGetBtnText = self._DiamondGetBtn:GetChild("title")
    self._DiamondGetBtnTimeBg = self._DiamondGetBtn:GetChild("_timeBg")
    self._DiamondGetBtnTextTime = self._DiamondGetBtn:GetChild("_textTime")
    self._DiamondGetBtnIconTime = self._DiamondGetBtn:GetChild("_iconTime")
    
    self._DiamondGetBtnText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
    
    self.title = ""
    self.info = ""
    
    self.showTips = function()
        local data = {
            title = self.title,
            info = self.info
        }
        UIMgr:Open("ConfirmPopupTextList", data)
    end
    
    self:AddListener(self._btnHelp.onClick,
            function()
                self.showTips()
            end
    )

    self:AddListener(self._DiamondBuyBtn.onClick,
        function()
            if UITool.CheckGem(self.needDiamond) then
                local data = {
                    content = StringUtil.GetI18n(I18nType.Commmon, "Onsale_Tips2"),
                    sureCallback = function()
                        --print("self._DiamondBuyBtn.onClick == ".. Model.DiamondFundInfo[self.pos].Tier)
                        Net.DiamondFund.Buy(
                                Model.DiamondFundInfo[self.pos].Tier,
                                function(rsp)
                                    --print("Net.DiamondFund.Buy rsp ======================" .. table.inspect(rsp))
                                    Model.DiamondFundInfo[self.pos] = rsp.DiamondFund
                                    self.SecondRefresh()
                                    _G.Event.Broadcast(_G.EventDefines.RefreshSuperCheapRedData)
                                    --print("Model.DiamondFundInfo ======================" .. table.inspect(Model.DiamondFundInfo))
                                    TipUtil.TipByContent(nil, StringUtil.GetI18n(I18nType.Commmon, "Ui_Buy_Success"))
                                end
                        )
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
            end
        end
    )

    self:AddListener(self._DiamondGetBtn.onClick,
        function()
            --print("self._DiamondGetBtn.onClick == ".. Model.DiamondFundInfo[self.pos].Tier)
            Net.DiamondFund.Claim(
                    Model.DiamondFundInfo[self.pos].Tier,
                function(rsp)
                    --print("Net.DiamondFund.Claim rsp ======================" .. table.inspect(rsp))
                    Model.DiamondFundInfo[self.pos] = rsp.DiamondFund
                    self.Rewards = rsp.Rewards
                    self.SecondRefresh()
                    _G.Event.Broadcast(_G.EventDefines.RefreshSuperCheapRedData)
                    --print("Model.DiamondFundInfo222222 ======================" .. table.inspect(Model.DiamondFundInfo))
                    UITool.ShowReward(self.Rewards)
                end
            )
        end
    )
    
    self.SecondRefresh = function()
        if(self.pos) then
            if Model.DiamondFundInfo[self.pos].ExpireAt > 0 and Model.DiamondFundInfo[self.pos].ClaimedTimes < 30 then
                self._remianBg.visible =true
                self._textRemainDay.visible =true
                self._DiamondBuyBtn.visible =false
                self._DiamondGetBtn.visible =true
                self._remianBg.visible  = true
                self._textRemainDay.visible  = true
                local restDay = math.max(0,math.floor((Model.DiamondFundInfo[self.pos].ExpireAt - Tool.Time()) / 86400))
                self._textRemainDay.text = StringUtil.GetI18n(I18nType.Commmon, "UI_MONTHLY_CARD_REST_TIME", {num = restDay})
                --local days  =  TimeUtil.StampTimeToYMD(Tool.Time())
                --print("Model.DiamondFundInfo[self.pos].ClaimedDate== ".. Model.DiamondFundInfo[self.pos].ClaimedDate)
                --days = string.gsub(days,"-","",2);
                --print("daysdaysdaysdaysdaysdays== ".. days)
                --Model.DiamondFundInfo[self.pos].ShowTimes = 0
                --Model.DiamondFundInfo[self.pos].ClaimedDate = days
                self.remainSecond = TimeUtil.ToDayRemianSecond()
                --print("self.remainSecondself.remainSecondself.remainSecondself.remainSecond = ".. self.remainSecond)
                if(self.remainSecond == 0 or self.remainSecond == 1) then
                    Model.DiamondFundInfo[self.pos].ShowTimes = Model.DiamondFundInfo[self.pos].ShowTimes + 1
                    --print("Model.DiamondFundInfo[self.pos].ShowTimes = ".. Model.DiamondFundInfo[self.pos].ShowTimes)
                end
                --if(Model.DiamondFundInfo[self.pos].ShowTimes <= 0 and tonumber(days) == tonumber(Model.DiamondFundInfo[self.pos].ClaimedDate))then
                if(Model.DiamondFundInfo[self.pos].ShowTimes <= 0)then
                    self._DiamondGetBtnText.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_39")
                    self._DiamondGetBtnTimeBg.visible = true
                    self._DiamondGetBtnTextTime.visible = true
                    self._DiamondGetBtnIconTime.visible = true
                    self._DiamondGetBtnTextTime.text = Tool.FormatTime(self.remainSecond)
                    self._DiamondGetBtn.enabled = false
                    if(self.staus ~= 1) then
                        self.staus = 1
                        _G.Event.Broadcast(_G.EventDefines.RefreshSuperCheapRedData)
                    end
                else
                    if(self.staus ~= 2) then
                        self.staus = 2
                        _G.Event.Broadcast(_G.EventDefines.RefreshSuperCheapRedData)
                    end
                    self._DiamondGetBtn.enabled = true
                    if(Model.DiamondFundInfo[self.pos].ShowTimes > 1)then
                        self._DiamondGetBtnText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get").."x".. Model.DiamondFundInfo[self.pos].ShowTimes
                    else
                        self._DiamondGetBtnText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
                    end
                    self._DiamondGetBtnTimeBg.visible = false
                    self._DiamondGetBtnTextTime.visible = false
                    self._DiamondGetBtnIconTime.visible = false
                end
            else
                if(self.staus ~= 3) then
                    self.staus = 3
                    _G.Event.Broadcast(_G.EventDefines.RefreshSuperCheapRedData)
                end
                self._remianBg.visible =false
                self._textRemainDay.visible =false
                self._DiamondBuyBtn.visible =true
                self._DiamondGetBtn.visible =false
                if Model.Player.Gem > self.needDiamond then
                    self._DiamondBuyBtn:GetController("isRed").selectedIndex = 1
                else
                    self._DiamondBuyBtn:GetController("isRed").selectedIndex = 0
                end
            end

            --print("Model.DiamondFundInfo[self.pos].ExpireAt == ".. Model.DiamondFundInfo[self.pos].ExpireAt)
            --print("Tool.Time() == ".. Tool.Time())
            --if Model.DiamondFundInfo[self.pos].ExpireAt and Model.DiamondFundInfo[self.pos].ExpireAt >= Tool.Time() then
            --    self._remianBg.visible =true
            --    self._textRemainDay.visible =true
            --    self._DiamondBuyBtn.visible =false
            --    self._DiamondGetBtn.visible =true
            --    self._remianBg.visible  = true
            --    self._textRemainDay.visible  = true
            --    local restDay = math.floor((Model.DiamondFundInfo[self.pos].ExpireAt - Tool.Time()) / 86400)
            --    self._textRemainDay.text = StringUtil.GetI18n(I18nType.Commmon, "UI_MONTHLY_CARD_REST_TIME", {num = restDay})
            --    --local days  =  TimeUtil.StampTimeToYMD(Tool.Time())
            --    --print("Model.DiamondFundInfo[self.pos].ClaimedDate== ".. Model.DiamondFundInfo[self.pos].ClaimedDate)
            --    --days = string.gsub(days,"-","",2);
            --    --print("daysdaysdaysdaysdaysdays== ".. days)
            --    --Model.DiamondFundInfo[self.pos].ShowTimes = 0
            --    --Model.DiamondFundInfo[self.pos].ClaimedDate = days
            --    self.remainSecond = TimeUtil.ToDayRemianSecond()
            --    if(self.remainSecond == 0) then
            --        Model.DiamondFundInfo[self.pos].ShowTimes = Model.DiamondFundInfo[self.pos].ShowTimes + 1
            --    end
            --    --if(Model.DiamondFundInfo[self.pos].ShowTimes <= 0 and tonumber(days) == tonumber(Model.DiamondFundInfo[self.pos].ClaimedDate))then
            --    if(Model.DiamondFundInfo[self.pos].ShowTimes <= 0)then
            --        self._DiamondGetBtnText.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_39")
            --        self._DiamondGetBtnTimeBg.visible = true
            --        self._DiamondGetBtnTextTime.visible = true
            --        self._DiamondGetBtnIconTime.visible = true
            --        self._DiamondGetBtnTextTime.text = Tool.FormatTime(self.remainSecond)
            --        self._DiamondGetBtn.enabled = false
            --        if(self.staus ~= 1) then
            --            self.staus = 1
            --            _G.Event.Broadcast(_G.EventDefines.RefreshSuperCheapRedData)
            --        end
            --    else
            --        if(self.staus ~= 2) then
            --            self.staus = 2
            --            _G.Event.Broadcast(_G.EventDefines.RefreshSuperCheapRedData)
            --        end
            --        self._DiamondGetBtn.enabled = true
            --        if(Model.DiamondFundInfo[self.pos].ShowTimes > 1)then
            --            self._DiamondGetBtnText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get").."x".. Model.DiamondFundInfo[self.pos].ShowTimes
            --        else
            --            self._DiamondGetBtnText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
            --        end
            --        self._DiamondGetBtnTimeBg.visible = false
            --        self._DiamondGetBtnTextTime.visible = false
            --        self._DiamondGetBtnIconTime.visible = false
            --    end
            --else
            --    if(self.staus ~= 3) then
            --        self.staus = 3
            --        _G.Event.Broadcast(_G.EventDefines.RefreshSuperCheapRedData)
            --    end
            --    self._remianBg.visible =false
            --    self._textRemainDay.visible =false
            --    self._DiamondBuyBtn.visible =true
            --    self._DiamondGetBtn.visible =false
            --    if Model.Player.Gem > self.needDiamond then
            --        self._DiamondBuyBtn:GetController("isRed").selectedIndex = 1
            --    else
            --        self._DiamondBuyBtn:GetController("isRed").selectedIndex = 0
            --    end
            --end
        end
    end
    
    self:Schedule(self.SecondRefresh, 1, true)
end

function itemSuperCheapCard:DynamicLoad(url, resName, cb, progressCb)
    local _cb = function(ab)
        if not ab then
            return nil
        end
        local prefab = ab:LoadAsset(resName)
        cb(prefab)
    end

    DynamicRes.GetBundle(url, _cb, progressCb)
end

function itemSuperCheapCard:SetData(pos)
    self.pos = pos
    if(Model.DiamondFundInfo[self.pos].Tier == 0)then
        self._yellowBg.visible = false
        --self._quality4Bg.visible = false
        self._grayBg.visible = true
        --self._quality3Bg.visible = true
        self._orangeBg.visible = false
        
        self._textCardName.text = StringUtil.GetI18n(I18nType.Commmon, "DiamondsFund title2")
        --self._amountDiamond.text = Global.NewDiamondsFundGifts[1]
        self._textRenewNum.text = Global.NewDiamondsFundGifts[1]*30
        self._DiamondBuyBtnNum.text = Global.NewDiamondsFundPrices[1]
        self.needDiamond = Global.NewDiamondsFundPrices[1]
        self.title = StringUtil.GetI18n(I18nType.Commmon, "DiamondsFund title2")
        self.info = StringUtil.GetI18n(I18nType.Commmon, "NewDiamondsFund_Desc3")
        self._item:SetShowData({"Common","icon_diamond_01"},3,Global.NewDiamondsFundGifts[1])

        local cb = function(prefab)
            self.temptexture = prefab
            self._image.texture = NTexture(self.temptexture)
        end

        local progressCb = function(proNum)

        end

        if self.temptexture then
            self._image.texture = NTexture(self.temptexture)
        else
            self:DynamicLoad("falcon", "supercheapbg1", cb, progressCb)
        end
    elseif(Model.DiamondFundInfo[self.pos].Tier == 1)then
        self._yellowBg.visible = false
        --self._quality4Bg.visible = true
        self._grayBg.visible = false
        --self._quality3Bg.visible = false
        self._orangeBg.visible = true

        self._textCardName.text = StringUtil.GetI18n(I18nType.Commmon, "DiamondsFund title3")
        --self._amountDiamond.text = Global.NewDiamondsFundGifts[2]
        self._textRenewNum.text = Global.NewDiamondsFundGifts[2]*30
        self._DiamondBuyBtnNum.text = Global.NewDiamondsFundPrices[2]
        self.needDiamond = Global.NewDiamondsFundPrices[2]
        self.title = StringUtil.GetI18n(I18nType.Commmon, "DiamondsFund title3")
        self.info = StringUtil.GetI18n(I18nType.Commmon, "NewDiamondsFund_Desc3")
        self._item:SetShowData({"Common","icon_diamond_01"},4,Global.NewDiamondsFundGifts[2])

        local cb = function(prefab)
            self.temptexture = prefab
            self._image.texture = NTexture(self.temptexture)
        end

        local progressCb = function(proNum)

        end

        if self.temptexture then
            self._image.texture = NTexture(self.temptexture)
        else
            self:DynamicLoad("falcon", "supercheapbg2", cb, progressCb)
        end
    elseif(Model.DiamondFundInfo[self.pos].Tier == 2)then
        self._yellowBg.visible = true
        --self._quality4Bg.visible = true
        self._grayBg.visible = false
        --self._quality3Bg.visible = false
        self._orangeBg.visible = false

        self._textCardName.text = StringUtil.GetI18n(I18nType.Commmon, "DiamondsFund title4")
        --self._amountDiamond.text = Global.NewDiamondsFundGifts[3]
        self._textRenewNum.text = Global.NewDiamondsFundGifts[3]*30
        self._DiamondBuyBtnNum.text = Global.NewDiamondsFundPrices[3]
        self.needDiamond = Global.NewDiamondsFundPrices[3]
        self.title = StringUtil.GetI18n(I18nType.Commmon, "DiamondsFund title4")
        self.info = StringUtil.GetI18n(I18nType.Commmon, "NewDiamondsFund_Desc3")
        self._item:SetShowData({"Common","icon_diamond_01"},4,Global.NewDiamondsFundGifts[3])

        local cb = function(prefab)
            self.temptexture = prefab
            self._image.texture = NTexture(self.temptexture)
        end

        local progressCb = function(proNum)

        end

        if self.temptexture then
            self._image.texture = NTexture(self.temptexture)
        else
            self:DynamicLoad("falcon", "supercheapbg3", cb, progressCb)
        end
    end

    self.SecondRefresh()
end



return itemSuperCheapCard
