--[[
    author:{maxiaolong}
    time:2019-12-02 11:20:46
    function:{成长基金内容组件}
]]
local GD = _G.GD
local ItemGrowthFund = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemGrowthFund", ItemGrowthFund)
local WelfareModel = import("Model/WelfareModel")
local JumpMap = import("Model/JumpMap")
function ItemGrowthFund:ctor()
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
    self._btnGet = self:GetChild("btnGet")
    self._btnGet2 = self:GetChild("btnGet2")
    self._title = self:GetChild("title")
    self._listView = self:GetChild("liebiao")
    self._building = self:GetChild("Building")
    self._btnGetC1 = self:GetController("c1")
    self._btnGet3 = self:GetChild("btnGo")
    self._listView.itemRenderer = function(index, item)
        local id = WelfareModel.DicKeyByIndex(index + 1, self.items, true).id
        local amount = WelfareModel.DicKeyByIndex(index + 1, self.items, false)
        local data = {}
        data.Category = REWARD_TYPE.Item
        data.ConfId = id
        --item:SetData(data)
        --item:SetControl(1)
        --item:SetAmount(amount)
        --item:SetAmountMid(id)

        local mid = GD.ItemAgent.GetItemInnerContent(id)
        local icon,color = GD.ItemAgent.GetShowRewardInfo(data)
        item:SetShowData(icon,color,amount,nil,mid)

        self:ClearListener(item.onTouchBegin)
        self:ClearListener(item.onTouchEnd)
        self:ClearListener(item.onRollOut)
        self:AddListener(item.onTouchBegin,function()
            self.detailPop:OnShowUI(GD.ItemAgent.GetItemNameByConfId(id), GD.ItemAgent.GetItemDescByConfId(id), item, false)
        end)
        self:AddListener(item.onTouchEnd,function()
            self.detailPop:OnHidePopup()
        end)
        self:AddListener(item.onRollOut,function()
            self.detailPop:OnHidePopup()
        end)

        local reward = {
            Category = Global.RewardTypeItem,
            ConfId = id,
            Amount = amount
        }
        table.insert(self.rewards, reward)
    end
    self:AddListener(self._btnGet.onClick,
        function()
            if self.getBtnState == 0 then
                TipUtil.TipById(50046)
            elseif self.getBtnState == 1 then
                Event.Broadcast(EventDefines.GrowthGuideView)
            elseif self.getBtnState == 2 then
                Event.Broadcast(EventDefines.WelareCenterClose)
                JumpMap:JumpTo({jump = 810100, para = Global.BuildingCenter}, 0)
            elseif self.getBtnState == 4 then
                TipUtil.TipById(50044)
            end
        end
    )
    self:AddListener(self._btnGet2.onClick,
        function()
            if self.getBtnState == 1 then
                TipUtil.TipById(50046)
            elseif self.getBtnState == 3 then
                WelfareModel.GetNetRewardFundInfo(
                    self.info.id,
                    function()
                        Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.GrowthFund.Id, -1)
                        UITool.ShowReward(self.rewards)
                        self._btnGetC1.selectedIndex = 2
                        self.getBtnState = 4
                        self._btnGet3.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_39")
                    end
                )
            end
        end
    )
end

function ItemGrowthFund:SetData(info, isBuy)
    self.isBuy = isBuy
    self.info = info
    self.rewards = {}
    self.num, self.items = WelfareModel:GetGiftInfoById(info.giftId, 2)
    local buildingModel = split(info.building_model, ",")
    self._building.icon = UITool.GetIcon(buildingModel)
    self.finishLevel = info.level
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "GROWTH_FUND_CONDITION", {num = self.finishLevel})
    self._listView.numItems = self.num
    self.getBtnState = 0

    if info.isAwarded == true then
        self.getBtnState = 4
        self._btnGetC1.selectedIndex = 2
        self._btnGet3.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_39")
        return
    end
    --0未购买未达到等级，1--未购买到达等级，2购买没到达等级，3 购买到达等级,4已经领取了
    if self.finishLevel > Model.Player.Level then
        self._btnGet.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
        self._btnGetC1.selectedIndex = 0
        if not self.isBuy then
            self.getBtnState = 0
        else
            self.getBtnState = 2
        end
    else
        self._btnGet2.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
        if not self.isBuy then
            self.getBtnState = 1
            self._btnGetC1.selectedIndex = 0
        else
            self._btnGetC1.selectedIndex = 1
            self.getBtnState = 3
        end
    end
end

return ItemGrowthFund
