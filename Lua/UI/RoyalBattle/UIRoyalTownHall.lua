--[[
    Author: tiantian
    Function:王城市政厅
]]
local UIRoyalTownHall = _G.UIMgr:NewUI("UIRoyalTownHall")
import("UI/RoyalBattle/Item/ItemkingInfo")
import("UI/RoyalBattle/Item/ItemAppoint")

function UIRoyalTownHall:OnInit()
    self._view = self.Controller.contentPane
    self.controller = self._view:GetController("c1")
    self.controller.selectedIndex = 0
    self.officer1, self.officer2 = _G.RoyalModel.GetConfigWarZoneOfficer()
    self:OnInitEvent()
end
function UIRoyalTownHall:OnInitEvent()
    self:AddListener(
        self._btnClose.onClick,
        function()
            _G.UIMgr:Close("UIRoyalTownHall")
        end
    )
    self:AddListener(
        self._btnDetail.onClick,
        function()
            Sdk.AiHelpShowSingleFAQ(_G.ConfigMgr.GetItem("configWindowhelps", 2081).article_id)
        end
    )
    self:AddListener(
        self._btnResources.onClick,
        function()
            --城市资源
        end
    )
    self:AddListener(
        self._btnGift.onClick,
        function()
            UIMgr:Open("UIRoyalGiftPage")
        end
    )

    self:AddListener(
        self._btnTag1.onClick,
        function()
            self.controller.selectedIndex = 0
            self:RefreshListView()
        end
    )
    self:AddListener(
        self._btnTag2.onClick,
        function()
            self.controller.selectedIndex = 1
            self:RefreshListView()
        end
    )
    self._appointList.itemRenderer = function(index, item)
        if not index then
            return
        end
        local data = self.controller.selectedIndex==0 and self.officer1 or self.officer2
        item:SetData(data[index+1])
    end
    self:AddEvent(
        EventDefines.OfficialPositionRefresh,
        function()
            _G.RoyalModel.GetTitlesInfo(
                function()
                    self:RefreshListView()
                end
            )
        end
    )
end
function UIRoyalTownHall:OnOpen()
    _G.RoyalModel.SetKingWarInfo()
    _G.RoyalModel.GetTitlesInfo(
        function()
            self:RefreshListView()
        end
    )
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Button_Warzone_Management")
    self._btnTag1.text = StringUtil.GetI18n(I18nType.Commmon, "Throne_OfficialPost_Officertitle")
    self._btnTag2.text = StringUtil.GetI18n(I18nType.Commmon, "Throne_OfficialPost_Slavetitle")
    self._btnResources.text = StringUtil.GetI18n(I18nType.Commmon, "Throne_OfficialPost_Res_ConfirmTitle")
    self._btnGift.title = StringUtil.GetI18n(I18nType.Commmon, "Button_Warzone_GiftPackage")
    self._funcName.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CITYHALL")
end
function UIRoyalTownHall:RefreshListView()
    if self.controller.selectedIndex == 0 then
        self._appointList.numItems = #self.officer1
    end
    if self.controller.selectedIndex == 1 then
        self._appointList.numItems = #self.officer2
    end
end
function UIRoyalTownHall:OnClose()
end
return UIRoyalTownHall
