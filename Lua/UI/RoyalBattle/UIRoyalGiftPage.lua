--[[
    author:{xiaosao}
    time:2020/6/9
    function:{王城战市长发放礼包主界面}
]]
local UIRoyalGiftPage = UIMgr:NewUI("UIRoyalGiftPage")
import("UI/RoyalBattle/Item/itemRoyalGiftExt")
import("UI/RoyalBattle/Item/ItemPlayerSelectExt")
function UIRoyalGiftPage:OnInit()
    self._view = self.Controller.contentPane
    self._controller = self._view:GetController("c1")
    self._controller.selectedIndex = 0
    --按钮事件
    self:AddListener(self._btnReturn.onClick,
        function()
            if self._controller.selectedIndex == 0 then
                UIMgr:Close("UIRoyalGiftPage")
            else
                self._controller.selectedIndex = 0
                self:RefreshShow()
            end
        end
    )
    --按钮事件
    self:AddListener(self._btnGiveOut.onClick,
        function()
            RoyalModel.ConfirmSendGift()
        end
    )
    self:AddListener(self._btnRecord.onClick,
        function()
            UIMgr:Open("UIRoyalGiftRecord")
        end
    )
    self:AddListener(self._btnInstruction.onClick,
        function()
            local data = {
                textTitle = StringUtil.GetI18n(I18nType.Commmon, "Throne_OfficialPost_KingReward_InfoButton"),
                textContent = StringUtil.GetI18n(I18nType.Commmon, "Throne_OfficialPost_KingReward_InfoText"),
                controlType = "none"
            }
            UIMgr:Open("ConfirmPopupDouble", data)
        end
    )
    --订阅事件
    self:AddEvent(
        EventDefines.SelectRoyalGiftToGive,
        function(giftId)
            RoyalModel.SetGivingOutGiftId(giftId)
            self._controller.selectedIndex = 1
            self:RefreshShow()
        end
    )

    --订阅事件
    self:AddEvent(
        EventDefines.RoyalGiftRefresh,
        function()
            self:RefreshShow()
        end
    )
    --设置列表渲染
    self._liebiaoGift.itemRenderer = function(index, gObject)
        local itemData = RoyalModel.GetGiftInfoById(ConfigMgr.GetList("configWarZoneGifts")[index + 1].id)
        gObject:SetData(itemData)
    end
    self._liebiaoPlayer.itemRenderer = function(index, gObject)
        local giftData = RoyalModel.GetSelectingGiftInfo()
        local playerData = RoyalModel.GetSelectingGiftReceiversInfo(index + 1)
        gObject:SetData(playerData,index < #giftData.info.Receivers)
    end
end

function UIRoyalGiftPage:OnOpen()
    --初始化礼包信息
    RoyalModel.GetAllGiftInfo()
    local info = _G.RoyalModel.GetKingWarInfo()
    -- local isKing = (info and not info.InWar and info.KingInfo and _G.Model.Account.accountId == info.KingInfo.PlayerId) or false
    -- local pageIndex = isKing and 0 or 2
    self._controller.selectedIndex = 0
end

function UIRoyalGiftPage:OnClose()
end

function UIRoyalGiftPage:RefreshShow()
    if self._controller.selectedIndex == 0 then
        self._titleNameText.text = StringUtil.GetI18n(I18nType.Commmon, "Throne_OfficialPost_Reward_LogTitle")
        self._liebiaoGift.numItems = #ConfigMgr.GetList("configWarZoneGifts")
    else
        self._titleNameText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_WarZone_Gift")
        self._btnGiveOut.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_WarZone_Gift_Distribute")
        local itemData = RoyalModel.GetSelectingGiftInfo()
        self._giftNameText.text = StringUtil.GetI18n(I18nType.Commmon, itemData.config.name)
        local number1text = (not RoyalModel.GetSelectingGiftInfo().players or #RoyalModel.GetSelectingGiftInfo().players == 0) 
            and #itemData.info.Receivers 
            or #itemData.info.Receivers + #RoyalModel.GetSelectingGiftInfo().players
        self._selectedNumText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Warzone_GiftPlayer",
            {number1 = number1text,number2 = itemData.config.gift_num})
        self._desc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Warzone_GiftTips",
            {item_name = StringUtil.GetI18n(I18nType.Commmon,itemData.config.name),number = itemData.config.gift_num})
        self._liebiaoPlayer.numItems = itemData.config.gift_num
        local maxCount = itemData.config.gift_num > 20 and 20 or itemData.config.gift_num
        self._liebiaoPlayer:ResizeToFit(maxCount)
    end
    self._btnRecord.title = StringUtil.GetI18n(I18nType.Commmon, "Throne_OfficialPost_KingReward_LogButton")
    self._btnInstruction.title = StringUtil.GetI18n(I18nType.Commmon, "Throne_OfficialPost_KingReward_InfoButton")
end

return UIRoyalGiftPage
