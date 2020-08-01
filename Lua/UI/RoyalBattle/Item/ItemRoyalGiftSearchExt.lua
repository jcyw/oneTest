--[[
    author:{xiaosao}
    time:2020/6/12
    function:{王城战市长发放礼包选择搜索玩家item}
]]
local ItemRoyalGiftSearchExt = fgui.extension_class(GComponent)
fgui.register_extension("ui://RoyalBattle/itemRoyalGiftSearchExt", ItemRoyalGiftSearchExt)

function ItemRoyalGiftSearchExt:ctor()
    self:AddEvent(
        EventDefines.SelectRoyalGiftPlayerToGive,
        function()
            self:RefreshShowContent()
        end
    )
    self:AddEvent(
        EventDefines.OfficialPositionRefresh2,
        function()
            self:RefreshShowContent()
        end
    )
    self:AddListener(self.onClick,
            function()
                if RoyalModel.SearchForGift() then
                    if self.tagCtr.selectedIndex == 2 then
                        TipUtil.TipById(50333)
                    else
                        RoyalModel.RoyalGiftSelectPlayer(self.playerData)
                    end
                elseif RoyalModel.SearchForOfficer() then
                    RoyalModel.SetOfficialPositionPlayer(self.playerData)
                elseif RoyalModel.SearchForKing() then
                    if self.tagCtr.selectedIndex == 2 then
                        TipUtil.TipById(50344)
                    else
                        RoyalModel.SetKingPositionPlayer(self.playerData)
                    end
                end
            end
        )
end

function ItemRoyalGiftSearchExt:SetData(playerData)
    self.playerData = playerData
    if not self.playerData.Uuid then
        self.playerData.Uuid = self.playerData.Id
    end
    if not self.playerData.Uuid then
        self.playerData.Uuid = self.playerData.UserId
    end
    self:RefreshShowContent(playerData)
end

function ItemRoyalGiftSearchExt:RefreshShowContent(playerData)
    if not playerData and not self.playerData then
        return
    end
    if not playerData then
        playerData = self.playerData
    end
    if not playerData.Uuid then
        playerData.Uuid = self.playerData.Id
    end
    self.tagCtr = self._tagMark:GetController("button")
    self._playerHeadIcon:SetAvatar(playerData)
    if RoyalModel.SearchForGift() then
        local selected = RoyalModel.GetPlayerRoyalGiftState(playerData.Uuid)
        -- CommonModel.SetUserAvatar(self._playerHeadIcon, playerData.Avatar)
        self._playerNameText.text = playerData.Name
        if selected == 1 then --已经发放
            self.tagCtr.selectedIndex = 2
        elseif selected == 2 then --已经选中
            self.tagCtr.selectedIndex = 1
        else
            self.tagCtr.selectedIndex = 0
        end
    elseif RoyalModel.SearchForOfficer() then
        -- CommonModel.SetUserAvatar(self._playerHeadIcon, playerData.Avatar)
        self._playerNameText.text = playerData.Name
        local selected = RoyalModel.GetOfficialPositionPlayerState(playerData.Uuid)
        self.tagCtr.selectedIndex = selected and 1 or 0
    elseif RoyalModel.SearchForKing() then
        -- CommonModel.SetUserAvatar(self._playerHeadIcon, playerData.Avatar)
        self._playerNameText.text = playerData.Name
        if not RoyalModel.IsKing(self.playerData.Uuid) then
            local selected = RoyalModel.GetKingPositionPlayerState(playerData.Uuid)
            self.tagCtr.selectedIndex = selected and 1 or 0
        else
            self.tagCtr.selectedIndex = 2
        end
    end
end

return ItemRoyalGiftSearchExt
