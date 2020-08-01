--author: 	Amu
--time:		2019-07-11 16:50:54
local GD = _G.GD
local ItemUnionDonateRank = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionDonateRank", ItemUnionDonateRank)

local CommonModel = import("Model/CommonModel")

ItemUnionDonateRank.tempList = {}

function ItemUnionDonateRank:ctor()
    self._textRank = self:GetChild("textRank")
    self._iconHero = self:GetChild("iconHero")
    self._textPlayer = self:GetChild("textPlayer")
    self._textContributionNum = self:GetChild("textContributionNum")
    self._textHonorNum = self:GetChild("textHonorNum")
    self._ctrView = self:GetController("c1")

    self:InitEvent()
end

function ItemUnionDonateRank:InitEvent()
end

function ItemUnionDonateRank:SetData(info)
    local rank = info.RankPos+1
    self.info = info
    self._textRank.text = rank
    -- CommonModel.SetUserAvatar(self._iconHero, self.info.Info.Avatar)
    self._iconHero:SetAvatar(self.info)
    if rank == 1 then
        self._ctrView.selectedIndex = 0
    elseif rank == 2 then
        self._ctrView.selectedIndex = 1
    elseif rank == 3 then
        self._ctrView.selectedIndex = 2
    elseif rank > 3 then
        self._ctrView.selectedIndex = 3
    end
    self._textHonorNum.text = Tool.FormatNumberThousands(info.Honor)
    self._textPlayer.text = info.Name
    self._textContributionNum.text = Tool.FormatNumberThousands(info.Score)
end

function ItemUnionDonateRank:GetData()
    return self.info
end

return ItemUnionDonateRank