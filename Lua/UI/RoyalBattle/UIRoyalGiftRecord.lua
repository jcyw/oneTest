--[[
    Author: xiaosao
    Function:王城战礼包记录
]]
local UIRoyalGiftRecord = _G.UIMgr:NewUI("UIRoyalGiftRecord")

function UIRoyalGiftRecord:OnInit()
    self._titleName.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_WarZone_Gift")
    UITool.GetIcon({"falcon", "banner_wz02"},self._banner)
    self:OnInitEvent()
end
function UIRoyalGiftRecord:OnInitEvent()
    self:AddListener(
        self._bgMask.onClick,
        function()
            _G.UIMgr:Close("UIRoyalGiftRecord")
        end
    )
    self:AddListener(
        self._btnClose.onClick,
        function()
            _G.UIMgr:Close("UIRoyalGiftRecord")
        end
    )
end
function UIRoyalGiftRecord:OnOpen()
    local textStr = ""

    local giftRecordInfo
    RoyalModel.GetKingdomGiftRecords(
        function(msg)
            for k,v in pairs(msg.Records or {}) do
                local receiverName = v.ReceiverName
                if v.ReceiverAlliance and v.ReceiverAlliance ~= "" then
                    receiverName = "("..v.ReceiverAlliance..")"..receiverName
                end
                local senderName = v.KingName
                if v.KingAlliance and v.KingAlliance ~= "" then
                    senderName = "("..v.KingAlliance..")"..senderName
                end
                local officerName = StringUtil.GetI18n(I18nType.Commmon,ConfigMgr.GetItem("configWarZoneOfficers", v.SenderTitle).office_name)
                local giftName = ConfigMgr.GetItem("configWarZoneGifts", v.GiftId).name
                textStr = textStr .. StringUtil.GetI18n(I18nType.Commmon, "Throne_OfficialPost_KingReward_LogText",
                    {officer_name =officerName, player_name1 = senderName,player_name2 = receiverName,iteam = StringUtil.GetI18n(I18nType.Commmon, giftName)}).."\n"
            end
            ConfirmPopupTextUtil.SetUpContent(self._label.height,self._label,textStr)
        end
    )
end

return UIRoyalGiftRecord
