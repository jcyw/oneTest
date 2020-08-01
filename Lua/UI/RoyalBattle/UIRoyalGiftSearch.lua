--[[
    author:{xiaosao}
    time:2020/6/12
    function:{王城站市长礼包搜索玩家界面}
]]
local UIRoyalGiftSearch = UIMgr:NewUI("UIRoyalGiftSearch")
local UnionMemberModel = import('Model/Union/UnionMemberModel')
import("UI/RoyalBattle/Item/ItemRoyalGiftSearchExt")
import("UI/RoyalBattle/Item/ItemRoyalGiftUnionMemberTag")

local SearchType = {
    Gift = "Gift",
    Officer = "Officer",
    King = "King"
}

function UIRoyalGiftSearch:OnInit()
    self.canSearch = true
    self.players = {}
    self._textInput.text = ""
    self._view = self.Controller.contentPane
    self._controller = self._view:GetController("c1")
    self._normalBtnView = self._btnNormal:GetController("button")
    self._unionBtnView = self._btnUnion:GetController("button")
    self:InitEvent()
end

function UIRoyalGiftSearch:OnOpen(searchType)
    self._controller.selectedIndex = 0
    self._unionBtnView.selectedIndex = 0
    self._normalBtnView.selectedIndex = 1
    RoyalModel.SetSearchType(searchType)
    self._textInput.text = ""
    Net.Alliances.SearchPlayer(self._textInput.text, function(msg)
        self.players = msg.Players
        self:RefreahListView()
    end)
    self._btnNormal.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_SearchPlay")
    self._btnUnion.title = StringUtil.GetI18n(I18nType.Commmon, "Button_Alliacen_People")
    self._btnConfirm.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
    if Model.Player.AllianceId == "" then
        self._btnUnion.grayed = true
    else
        self._btnUnion.grayed = false
    end
    local I18nKey = searchType==SearchType.Gift and "Ui_WarZone_Gift_Distribute" or "Ui_Management_Add"
    local I18nKey = searchType==SearchType.King and "Ui_WarZone_Assignment" or I18nKey
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, I18nKey)
end

function UIRoyalGiftSearch:InitEvent( )
    self:AddListener(self._btnReturn.onClick,function()--返回
        RoyalModel.CleanSelectingPlayerList()
        UIMgr:Close("UIRoyalGiftSearch")
    end)
    self:AddListener(self._textInput.onChanged,function()
        if self._textInput.text == "" then
            Net.Alliances.SearchPlayer(self._textInput.text, function(msg)
                self.players = msg.Players
                self:RefreahListView()
            end)
        end
    end)

    self:AddListener(self._btnSearch.onClick,function()--搜索
        if not self.canSearch then
             TipUtil.TipById(50242)
            return
        end
        if string.len(self._textInput.text) < 3 then
            TipUtil.TipById(50201)
            return
        end
        self.players = {}
        Net.UserInfo.Search(self._textInput.text,10, function(msg)
            self.players = msg.UserSearchInfos
            if #self.players <= 0 then
                TipUtil.TipById(50090)
            end
            self:RefreahListView()
        end)
        self:ScheduleOnce(function() 
            self.canSearch = true
        end, 2)
        self.canSearch = false
    end)

    self._liebiaoSearch.itemRenderer = function(index, item)
        if not index then 
            return
        end
        -- 搜索出来的玩家设置显示
        item:SetData(self.players[index+1])
    end
    
    self:AddListener(self._btnConfirm.onClick,function()
        if RoyalModel.SearchForGift() then
            UIMgr:Close("UIRoyalGiftSearch")
            Event.Broadcast(EventDefines.RoyalGiftRefresh)
        elseif RoyalModel.SearchForOfficer() then
            RoyalModel.ConfirmSetOfficialPosition(function()
                UIMgr:Close("UIRoyalGiftSearch")
            end)
        elseif RoyalModel.SearchForKing() then
            RoyalModel.ConfirmChangeKing()
            UIMgr:Close("UIRoyalGiftSearch")
        end
    end)

    self:AddListener(self._btnNormal.onClick,function()
        self._unionBtnView.selectedIndex = 0
        self._normalBtnView.selectedIndex = 1
        self._controller.selectedIndex = 0
    end)

    self:AddListener(self._btnUnion.onClick,function()
        if self._btnUnion.grayed then
            self._unionBtnView.selectedIndex = 0
            TipUtil.TipById(50053)
        else
            self._unionBtnView.selectedIndex = 1
            self._normalBtnView.selectedIndex = 0
            self._controller.selectedIndex = 1
            Net.Alliances.Info(
                Model.Player.AllianceId,
                function(rsp)
                    UnionMemberModel.SetMembers(rsp.Members)
                    self.members = UnionMemberModel.FormatMembers()
                    self:RefreahListView()
                end
            )
        end
    end)

    self._liebiaoSearch:SetVirtual()
end

function UIRoyalGiftSearch:RefreahListView( )
    self._liebiaoSearch.numItems = #self.players
    self._liebiaoUnionMember.numItems = self.members and #self.members or 0
    for i = 1, self.members and #self.members or 0 do
        local item = self._liebiaoUnionMember:GetChildAt(i - 1)
        item:InitMember(self.members[#self.members + 1 - i],i)
    end
end

return UIRoyalGiftSearch
