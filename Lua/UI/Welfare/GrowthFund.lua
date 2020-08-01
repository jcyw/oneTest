--[[
    author:{maxiaolong}
    time:2019-12-02 11:12:41
    function:{成长基金主界面}
]]
local GrowthFund = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/GrowthFund", GrowthFund)
local WelfareModel = import("Model/WelfareModel")
local IsBuy = false

function GrowthFund:ctor()
    self._btnHelp = self:GetChild("btnHelp")
    self._btnBusniess = self:GetChild("btnOnly")
    self._listView = self:GetChild("liebiaoSingleReservoir")
    self._banner = self:GetChild("banner")
    self._banner.icon = UITool.GetIcon(GlobalBanner.WelfareGrowthFund)
    self._textintegral = self:GetChild("textIntegral")
    self._textSalvation = self:GetChild("textSalvation")
    self._textDescribe = self:GetChild("textDescribe")
    local intergralCtrl = self._textintegral:GetController("c1")
    intergralCtrl.selectedIndex = 1
    local integraltext = self._textintegral:GetChild("_textIntegral")
    integraltext.text = StringUtil.GetI18n(I18nType.Commmon, "UI_GET_REWARD")
    self._textSalvation.text = StringUtil.GetI18n(I18nType.Commmon, "UI_GROWTH_FUND_EXPLAIN")
    self._textDescribe.text = StringUtil.GetI18n(I18nType.Commmon, "GROWTH_FUND_REQUIRE")
    self._listView.itemRenderer = function(index, item)
        item:SetData(self.growItemDatas[index + 1], IsBuy)
    end

    EffectTool.AddBtnLightEffect(self._btnBusniess, {x = -2, y = -7}, {x = 0.49, y = 0.85, z = 0.9})

    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "TITTILE_GROWTH_FUND"),
                info = StringUtil.GetI18n(I18nType.Commmon, "GROWTH_FUND_EXPLAIN")
            }
            UIMgr:Open("ConfirmPopupTextCentered", data)
        end
    )

    self:AddListener(self._btnBusniess.onClick,
        function()
            self.buyGuild:SetShow(false)
            --接入购买充值接口
            if not _G.Model.GrowthFundBought then
                local configData = WelfareModel.ConfigFund()[1]
                SdkModel.Rcharge37(PurchaseType.ITEM_TYPE_APP, RCHARGE.Fund, configData.id, configData.giftId)
            end
        end
    )
    self:AddEvent(
        EventDefines.GrowthFundPayed,
        function()
            if self.visible then
                self._btnBusniess.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_ALREADY_BUY")
                --Model.GrowthFundBought = true
                self:RefreshShow()
            end
        end
    )
    self:AddEvent(
        EventDefines.RefreshGrowthFund,
        function()
            if self.visible then
                self:RefreshShow()
            end
        end
    )
    self:SetGuild()
end

--打开页面
function GrowthFund:OnOpen()
    IsBuy = _G.Model.GrowthFundBought
    self:SetShow(true)
    --成长基金查看
    Net.UserInfo.RecordLog(
        4102,
        "",
        function(rsp)
        end
    )
    -- self.growItemDatas = {}
    -- local growList = WelfareModel.GetGrowFundInfo()
    -- for i = 1, #growList do
    --     local growInfo = WelfareModel.GetGrowItemInfo(i)
    --     table.insert(self.growItemDatas, growInfo)
    -- end
    -- if IsBuy then
    --     self._btnBusniess.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_ALREADY_BUY")
    --     WelfareModel.GetNetFundInfo(
    --         function(params)
    --             -- print("----------------Params:",table.inspect(params.Infos))
    --             for i, v in pairs(params.Infos) do
    --                 if v.Status == 2 then
    --                     WelfareModel.SetGrowList(v.Category, self.growItemDatas)
    --                 end
    --             end
    --             self._listView.numItems = #self.growItemDatas
    --         end
    --     )
    -- else
    --     local configData = WelfareModel.ConfigFund()[1]
    --     local productPrice = ShopModel:GetCodeAndPriceByProductId(configData.giftId)
    --     self._btnBusniess.text = StringUtil.GetI18n(I18nType.Commmon, "PRICE_BUTTON", {price = productPrice})
    --     self._listView.numItems = #self.growItemDatas
    -- end
    self:RefreshShow()
    AnimationLayer.PlayListLeftToRightAnim(AnimationType.UILeftToRight,self._listView,0.2,self)
    self._listView.scrollPane:ScrollTop()
end
function GrowthFund:RefreshShow()
    IsBuy = _G.Model.GrowthFundBought
    self.growItemDatas = {}
    local growList = WelfareModel.GetGrowFundInfo()
    for i = 1, #growList do
        local growInfo = WelfareModel.GetGrowItemInfo(i)
        table.insert(self.growItemDatas, growInfo)
    end
    if IsBuy then
        self._btnBusniess.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_ALREADY_BUY")
        WelfareModel.GetNetFundInfo(
            function(params)
                -- print("----------------Params:",table.inspect(params.Infos))
                for i, v in pairs(params.Infos) do
                    if v.Status == 2 then
                        WelfareModel.SetGrowList(v.Category, self.growItemDatas)
                    end
                end
                self._listView.numItems = #self.growItemDatas
            end
        )
    else
        local configData = WelfareModel.ConfigFund()[1]
        local productPrice = ShopModel:GetCodeAndPriceByProductId(configData.giftId)
        self._btnBusniess.text = StringUtil.GetI18n(I18nType.Commmon, "PRICE_BUTTON", {price = productPrice})
        self._listView.numItems = #self.growItemDatas
    end
end

function GrowthFund:SetShow(isShow)
    self.visible = isShow
    if self.visible == false then
        self.buyGuild:SetShow(false)
    end
end

function GrowthFund:SetGuild()
    self.buyGuild = UIMgr:CreateObject("Common", "Guide")
    self._btnBusniess:AddChild(self.buyGuild)
    self.buyGuild:SetPivot(0.5, 0.5)
    self.buyGuild:SetGuideScale(0.8)
    self.buyGuild:SetXY(-self.buyGuild.width / 2 + self._btnBusniess.width / 2, -self.buyGuild.height / 2 + self._btnBusniess.height / 2)
    self.buyGuild:SetShow(false)
    self:AddEvent(
        EventDefines.GrowthGuideView,
        function()
            self.buyGuild:SetShow(true)
            self.buyGuild:PlayLoop()
        end
    )
end

return GrowthFund
