--[[
    author:Temmie
    time:2019-12-24 11:12:43
    function:每日礼包领取弹窗
]]
local GD = _G.GD
local RechargeGiftPackagePopupGift = UIMgr:NewUI("RechargeGiftPackagePopupGift")

function RechargeGiftPackagePopupGift:OnInit()
    self:AddListener(self._btnBuy.onClick,function()
        if self.giftId then
            Net.ChargeActivity.DailyBonus(function(rsp)
                if rsp.Fail then
                    return
                end
                if self.cb then
                    self.cb(self.rewards)
                end
    
                UIMgr:Close("RechargeGiftPackagePopupGift")
            end)
        else
            Net.Purchase.GetEveryDayGift(function(rsp)
                if rsp.Fail then
                    return
                end
                if self.cb then
                    self.cb(self.rewards)
                end
    
                UIMgr:Close("RechargeGiftPackagePopupGift")
            end)
        end
    end)

    self:AddListener(self._mask.onClick,function()
        UIMgr:Close("RechargeGiftPackagePopupGift")
    end)

    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("RechargeGiftPackagePopupGift")
    end)
end

function RechargeGiftPackagePopupGift:OnOpen(callback, giftId)
    self.giftId = giftId
    local giftConfig
    if giftId then
        giftConfig = ConfigMgr.GetItem("configGifts", giftId)
    else
        giftConfig = ConfigMgr.GetItem("configGifts", Global.GiftEveryDay)
    end
    self.cb = callback
    self.rewards = {}
    self._list:RemoveChildrenToPool()
    for _,v in pairs(giftConfig.items) do
        local itemConfig = ConfigMgr.GetItem("configItems", v.confId)
        local item = self._list:AddItemFromPool()
        local icon = item:GetChild("reward")

        --icon:GetChild("_icon").url = UITool.GetIcon(itemConfig.icon)
        --icon:GetChild("_bg").url = GD.ItemAgent.GetItmeQualityByColor(itemConfig.color)
        --icon:GetChild("_groupMid").visible = false;
        item:GetChild("title").text = GD.ItemAgent.GetItemNameByConfId(itemConfig.id)
        item:GetChild("textNum").text = "x"..v.amount
        local mid = GD.ItemAgent.GetItemInnerContent(v.confId)
        icon:SetShowData(itemConfig.icon,itemConfig.color,nil,nil,mid)


        local reward = {
            Category = Global.RewardTypeItem,
            ConfId = v.confId,
            Amount = v.amount
        }
        table.insert(self.rewards, reward)
    end
end

return RechargeGiftPackagePopupGift