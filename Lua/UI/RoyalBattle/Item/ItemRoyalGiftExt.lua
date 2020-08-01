--[[
    author:{xiaosao}
    time:2020/6/9
    function:{王城战市长发放礼包主界面item}
]]
local ItemRoyalGiftExt = fgui.extension_class(GComponent)
fgui.register_extension("ui://RoyalBattle/itemRoyalGiftExt", ItemRoyalGiftExt)
local WelfareModel = import("Model/WelfareModel")

function ItemRoyalGiftExt:ctor()
    self._controller = self:GetController("c1")
    self._controller.selectedIndex = 0
    self:InitEvent()
end

function ItemRoyalGiftExt:InitEvent()
    --按钮事件
    self:AddListener(self._btnGive.onClick,
        function()
            Event.Broadcast(EventDefines.SelectRoyalGiftToGive,self.itemData.config.id)
        end
    )
    --列表渲染
    self._liebiao.itemRenderer = function(index, item)
        local icon = self.items[index + 1].image
        local color = self.items[index + 1].color
        local amount = self.items[index + 1].amount
        local midStr = self.items[index + 1].midStr
        local title = self.items[index + 1].title
        local des = self.items[index + 1].desc
        item:SetAmount(icon, color, amount, nil, midStr)
        item:SetData({title, des})
    end
end

function ItemRoyalGiftExt:SetData(itemData)
    self.itemData = itemData
    self._btnGive.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_WarZone_Gift_Distribute")
    self._giftTitleText.text = StringUtil.GetI18n(I18nType.Commmon, itemData.config.name)
    self._giftNumText.text = StringUtil.GetI18n(I18nType.Commmon, "Throne_OfficialPost_KingReward_Sum", 
    {number = #itemData.info.Receivers,totalnumber = itemData.config.gift_num})
    self.items, self.itemNum = WelfareModel.GetResOrItemByGiftId(itemData.config.gift_id)
    self._liebiao.numItems = self.itemNum
    local info = _G.RoyalModel.GetKingWarInfo()
    self._controller.selectedIndex = (info and not info.InWar and RoyalModel.GetAccountTitlePower(2)) and 0 or 1
end
return ItemRstViewiftExt
