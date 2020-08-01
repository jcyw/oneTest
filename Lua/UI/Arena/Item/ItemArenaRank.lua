--author: 	Amu
--time:		2020-06-21 11:39:55

local ItemArenaRank = fgui.extension_class(GComponent)
fgui.register_extension("ui://Arena/itemArenaRank", ItemArenaRank)


function ItemArenaRank:ctor()

    self._iconRank = self:GetChild("iconRank")

    self._icon = self:GetChild("n34")

    self._name = self:GetChild("_name")
    self._union = self:GetChild("_union")

    self._iconGift = self:GetChild("iconGift")

    self._ctrView = self:GetController("rankControl")

    self:InitEvent()
end

function ItemArenaRank:InitEvent(  )
    self:AddListener(self._iconGift.onClick,function()
        local itemInfos = {
            {
                id = self._giftId,
                amount = 1
            }
        }
        UIMgr:Open("UnionTaskActiveRewardPopup", ITEM_TYPE.Gift, itemInfos, false)
    end)

    -- self:AddListener(self._btnChallenge.onClick,function()


    -- end)
end



function ItemArenaRank:SetData(info)
    self._name.text = info.PlayerName
    self._union.text = info.AllianceName
    local config = ConfigMgr.GetItem("configArenaRobots", info.Rank)
    if config then
        self._giftId = config.gift
    end
    -- CommonModel.SetUserAvatar(self._icon, info.Avatar)
    self._icon:SetAvatar(info)
    if info.Rank == 1 then
        self._ctrView.selectedIndex = 0
    elseif info.Rank == 2 then
        self._ctrView.selectedIndex = 1
    elseif info.Rank == 3 then
        self._ctrView.selectedIndex = 2
    else
        self._ctrView.selectedIndex = 3
        self._level.text = info.Rank
    end
end

return ItemArenaRank