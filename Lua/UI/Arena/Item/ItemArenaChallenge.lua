--author: 	Amu
--time:		2020-06-21 11:36:51

local CommonModel = import("Model/CommonModel")
local ArenaModel = import("Model/ArenaModel")

local ItemArenaChallenge = fgui.extension_class(GComponent)
fgui.register_extension("ui://Arena/itemArenaChallenge", ItemArenaChallenge)


function ItemArenaChallenge:ctor()

    self._textRank = self:GetChild("textRank")
    self._textExpedition = self:GetChild("textExpedition")

    self._iconHero = self:GetChild("n33")

    self._textName = self:GetChild("textPlayerGameName")
    self._textUnion = self:GetChild("textUnion")

    self:InitEvent()
end

function ItemArenaChallenge:InitEvent(  )
    self:AddListener(self._btnView.onClick,function()
        if ArenaModel._PriedRanks[self._info.PlayerRankInfo.Rank] then
            ArenaModel.ArenaPryTroopInfo(self._info.PlayerRankInfo.Rank, function(info)
                UIMgr:Open("ArenaViewPlayerGame", info)
            end)
        else
            if ArenaModel._WeekPriedFreeTimes > 0 then
                local data = {
                    content = StringUtil.GetI18n("configI18nCommons", "UI_ARENA_BATTLE_TIPS9", {num = ArenaModel._WeekPriedFreeTimes}),
                    sureCallback = function()
                        ArenaModel.ArenaPryTroopInfo(self._info.PlayerRankInfo.Rank, function(info)
                            UIMgr:Open("ArenaViewPlayerGame", info)
                        end)
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
            else
                local data = {
                    content = StringUtil.GetI18n("configI18nCommons", "Supply_Diamond_2"),
                    gold = tonumber(Global.Arena_spy),
                    sureCallback = function()
                        ArenaModel.ArenaPryTroopInfo(self._info.PlayerRankInfo.Rank, function(info)
                            UIMgr:Open("ArenaViewPlayerGame", info)
                        end)
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
            end
        end 
    end)

    self:AddListener(self._btnChallenge.onClick,function()
        UIMgr:Open("ArenaDispatchTroops", self._info)
    end)
end



function ItemArenaChallenge:SetData(info)
    if ArenaModel._rankNum >= 0 and info.PlayerRankInfo.Rank >= ArenaModel._rankNum then
        self._btnChallenge.enabled = false
    else
        self._btnChallenge.enabled = true
    end
    self._info = info
    self._textRank.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS5", {num = info.PlayerRankInfo.Rank})
    self._textExpedition.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS6", {num = info.PlayerPower})
    self._textName.text = info.PlayerRankInfo.PlayerName
    self._textUnion.text = info.PlayerRankInfo.AllianceName

    -- CommonModel.SetUserAvatar(self._iconHero,info.PlayerRankInfo.Avatar)
    self._iconHero:SetAvatar(info.PlayerRankInfo)
end

return ItemArenaChallenge