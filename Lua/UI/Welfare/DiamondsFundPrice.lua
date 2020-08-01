--[[
    author:{laofu}
    time:2020-05-25 11:12:02
    function:{钻石月卡}
]]
local GD = _G.GD
local DiamondsFundPrice = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/DiamondsFundPrice", DiamondsFundPrice)

function DiamondsFundPrice:ctor()
    self._text = self:GetChild("title")
    self._rulesText = self:GetChild("rulesTitle")

    self._btnToggle1 = self:GetChild("tag1")
    self._btnToggle2 = self:GetChild("tag2")
    self._tips = self:GetChild("btnHelp")
    self._btnGet = self:GetChild("btnGet")
    self._btnBuy = self:GetChild("btnBuy")
    self._rewardList = self:GetChild("giftList")

    self._c1 = self:GetController("c1")
    self._c2 = self:GetController("c2")
    self._c1.selectedIndex = 0

    --文本多语言赋值
    self._btnToggle1.title = StringUtil.GetI18n(I18nType.Commmon, "DiamondsFund title2")
    self._btnToggle2.title = StringUtil.GetI18n(I18nType.Commmon, "DiamondsFund title3")
    self._text.text = StringUtil.GetI18n(I18nType.Commmon, "DiamondsFund ruletitle")
    self._rulesText.text = StringUtil.GetI18n(I18nType.Commmon, "DiamondsFund ruledesc")
    --注册事件
    self:InitEvent()
    --获得一个礼包表
    self.configGift = ConfigMgr.GetList("configGifts")
    --提示说明
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
end

function DiamondsFundPrice:InitEvent()
    self:AddListener(self._tips.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                info = StringUtil.GetI18n(I18nType.Commmon, "DiamondsFund tips")
            }
            UIMgr:Open("ConfirmPopupTextCentered", data)
        end
    )
    self:AddListener(self._btnToggle1.onClick,
        function()
            self:RefreshWindow(1, 0)
        end
    )
    self:AddListener(self._btnToggle2.onClick,
        function()
            self:RefreshWindow(2, 1)
        end
    )
    self:AddListener(self._btnBuy.onClick,
        function()
            --购买月卡
            --self:MonthlyPurchase()
            TipUtil.TipById(50335)
        end
    )
    self:AddListener(self._btnGet.onClick,
        function()
            --获得奖励
            self:GetReward(self.canGetInfo)
        end
    )
    self._rewardList.itemRenderer = function(index, item)
        local info = self.everydayInfos[index + 1]
        --道具显示
        local itemProbig = item:GetChild("item")
        local itemData = GD.ItemAgent.GetItemModelByConfId(info.itemId)
        local mid = GD.ItemAgent.GetItemInnerContent(info.itemId)
        itemProbig:SetAmount(itemData.icon, itemData.color, info.amount, nil, mid)
        --道具标题
        local itemTitle = item:GetChild("title")
        itemTitle.text = StringUtil.GetI18n(I18nType.Commmon, "ROAD_GROWTH_DAYS", {num = info.day})
        --道具事件
        local itemTouch = item:GetChild("touch")
        --local itemC1 = item:GetController("c1")
        itemProbig:SetPickTypeMidde(false)
        --移除之前的所有事件
        itemTouch:RemoveEventListeners()
        if info.status == 1 then
            self:AddListener(itemTouch.onClick,
                function()
                    self:GetReward(info)
                end
            )
            itemProbig:SetPickTypeMidde(false)
            self.canGetInfo = info
            --特效播放
            local node = itemProbig:GetEffect()
            self:ItemEffect(node)
        elseif info.status == 0 then
            --领取过的状态
            itemProbig:SetPickTypeMidde(true)
            self:Label(info.itemId, itemTouch)
        elseif info.status == 2 then
            --未领取的状态
            self:Label(info.itemId, itemTouch)
        end
    end

    self:AddEvent(
        EventDefines.DiamondsFundPriceRefresh,
        function()
            if self.visible then
                self.serverInfos = nil
                self:RefreshWindow(1, 0)
            end
        end
    )

    self:AddEvent(
        EventDefines.GemFundUIRefresh,
        function()
            if self.visible then
                self:RefreshWindow(self._c1.selectedIndex + 1, self._c1.selectedIndex)
            end
        end
    )
end

--道具提示
function DiamondsFundPrice:Label(id, item)
    local title = GD.ItemAgent.GetItemNameByConfId(id)
    local decs = GD.ItemAgent.GetItemDescByConfId(id)
    self:AddListener(item.onTouchBegin,
        function()
            if (self.detailPop and self.detailPop.OnShowUI) then
                self.detailPop:OnShowUI(title, decs, item, false)
            end
        end
    )

    self:AddListener(item.onTouchEnd,
        function()
            self.detailPop:OnHidePopup()
        end
    )

    self:AddListener(item.onRollOut,
        function()
            self.detailPop:OnHidePopup()
        end
    )
end

function DiamondsFundPrice:OnOpen()
    self:RefreshWindow(self._c1.selectedIndex + 1, self._c1.selectedIndex)
end

function DiamondsFundPrice:SetShow(isShow)
    self.visible = isShow
end

--[[
    @desc:整个页面显示刷新
]]
function DiamondsFundPrice:RefreshWindow(grade, page)
    self:SetShow(true)

    self.refreshFunc = function(grade, page)
        self:CheckRedPoint()
        --当前页面是哪个档位
        local gradeInfo = grade == 1 and self.serverInfos[1] or self.serverInfos[2]
        self:ListRefresh(grade, page, gradeInfo)
        --如果是已购买按钮标题显示签到，如果是未购买则显示钻石价格
        if gradeInfo.Bought then
            self._c2.selectedIndex = 0
            self._btnGet.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Sign_In")
            --按钮可操作状态设置
            self._btnGet.enabled = not gradeInfo.Taken
        else
            self._c2.selectedIndex = 1
            self._btnBuy.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Buy")
            local gemText = self._btnBuy:GetChild("text")
            local gem = Global.DiamondsFundPrice[gradeInfo.Category]
            gemText.text = Tool.FormatNumberThousands(gem)
            if gem > Model.Player.Gem then
                gemText.color = Color(0.98, 0.36, 0.25)
            else
                gemText.color = Color.white
            end
            self._btnBuy.grayed = true
        end
    end

    if not self.serverInfos then
        Net.GemFund.GetInfo(
            function(rsp)
                self.serverInfos = rsp.Infos
                self.refreshFunc(grade, page)
            end
        )
    else
        self.refreshFunc(grade, page)
    end
end

--[[
    @desc:toggle切换列表刷新
]]
function DiamondsFundPrice:ListRefresh(grade, page, gradeInfo)
    self._c1.selectedIndex = page
    local gifts = grade == 1 and Global.DiamondsFundGift1 or Global.DiamondsFundGift2
    self.everydayInfos = {}
    for index, giftID in pairs(gifts) do
        local gift =
            table.find(
            self.configGift,
            function(data)
                return data.id == giftID
            end
        )
        --领取状态，0是已领取，1是可领取，2是还无法领取
        local status = 0
        if index < gradeInfo.Day then
            status = 0
        elseif index > gradeInfo.Day then
            status = 2
        elseif index == gradeInfo.Day and not gradeInfo.Taken then
            status = 1
        end
        local info = {
            giftID = giftID,
            itemId = gift.items[1].confId,
            amount = gift.items[1].amount,
            status = status,
            day = index
        }
        table.insert(self.everydayInfos, info)
    end
    NodePool.Set(NodePool.KeyType.GemFundEffect, self.effect)
    self._rewardList.numItems = #self.everydayInfos
end

--[[
    @desc:获得奖励
]]
function DiamondsFundPrice:GetReward(info)
    --奖励动画参数
    local reward = {
        [1] = {
            Category = Global.RewardTypeItem,
            ConfId = info.itemId,
            Amount = info.amount
        }
    }
    --请求服务器获得奖励
    Net.GemFund.GetGemFundAward(
        self._c1.selectedIndex + 1,
        function()
            UITool.ShowReward(reward)
            --关闭红点
            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.GemFundActivity.Id, -1)
            --按钮设置不可操作
            self._btnGet.enabled = false
            --刷新页面数据
            self.serverInfos[self._c1.selectedIndex + 1].Taken = true
            self:RefreshWindow(self._c1.selectedIndex + 1, self._c1.selectedIndex)
        end
    )
end

--[[
    @desc:购买月卡
]]
function DiamondsFundPrice:MonthlyPurchase()
    --检测钻石是否充足
    if not UITool.CheckGem(Global.DiamondsFundPrice[self._c1.selectedIndex + 1]) then
        return
    end
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceShop_Supplement"),
        sureCallback = function()
            Net.GemFund.BuyGemFund(
                self._c1.selectedIndex + 1,
                function()
                    --购买完后刷新一下页面
                    self.serverInfos = nil
                    self:RefreshWindow(self._c1.selectedIndex + 1, self._c1.selectedIndex)
                    Event.Broadcast(EventDefines.UIWelfareGemFund)
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

--[[
    @desc:红点检测
]]
function DiamondsFundPrice:CheckRedPoint()
    CuePointModel:SetSingle(CuePointModel.Type.Red, 0, self._btnToggle1)
    CuePointModel:SetSingle(CuePointModel.Type.Red, 0, self._btnToggle2)
    -- --红点
    -- for _, v in pairs(serverInfos) do
    --     if not v.Bought and v.Category == 1 then
    --         CuePointModel:SetSingle(CuePointModel.Type.Red, 1, self._btnToggle1)
    --     elseif not v.Bought and v.Category == 2 then
    --         CuePointModel:SetSingle(CuePointModel.Type.Red, 1, self._btnToggle2)
    --     end
    -- end
    -- 奖励领取红点
    for _, v in pairs(self.serverInfos) do
        if v.Bought and v.Category == 1 and not v.Taken then
            CuePointModel:SetSingle(CuePointModel.Type.Red, 1, self._btnToggle1)
        elseif v.Bought and v.Category == 2 and not v.Taken then
            CuePointModel:SetSingle(CuePointModel.Type.Red, 1, self._btnToggle2)
        end
    end
end

--[[
    @desc:可领取时候的一个特效状态
]]
function DiamondsFundPrice:ItemEffect(node)
    -- NodePool.Init(NodePool.KeyType.GemFundEffect, "Effect", "EffectNode")
    -- self.effect = NodePool.Get(NodePool.KeyType.GemFundEffect)
    -- node:AddChild(self.effect)
    -- self.effect.xy = Vector2(0, 0)
    -- self.effect:PlayDynamicEffectLoop("effects/gemfundeffect/prefab/Effect_Welfare_frame_prefab", Vector3(1, 1, 1),1)

    NodePool.Init(NodePool.KeyType.GemFundEffect, "Effect", "EffectNode")
    self.effect = NodePool.Get(NodePool.KeyType.GemFundEffect)
    node:AddChild(self.effect)
    self.effect.xy = Vector2(0, 0)
    self.effect:PlayDynamicEffectLoop("effect_ab/gemfundeffect","effect_welfare_frame_prefab", Vector3(1, 1, 1),1)

end

return DiamondsFundPrice
