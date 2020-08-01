--[[
    Author: songzeming
    Function: 玩家杀敌弹窗
]]
local PlayerKillBox = UIMgr:NewUI("PlayerKill/PlayerKillBox")

import("UI/PlayerDetail/PlayerKill/ItemPlayerKillBox")

function PlayerKillBox:OnInit()
    self:AddListener(self._mask.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
end

function PlayerKillBox:OnOpen()
    self._list:RemoveChildrenToPool()
    Net.UserInfo.GetUserDetailedBattleInfo(
        Model.Account.accountId,
        function(rsp)
            for _, v in pairs(CommonType.PLAYER_DETAIL_BATTLE) do
                local item = self._list:AddItemFromPool()
                local name = StringUtil.GetI18n(I18nType.Commmon, v.i18n)
                local value = rsp[v.netKey]
                if v.netKey == "Winrate" then
                    value = math.ceil(value * 100) .. "%"
                else
                    value = Tool.FormatNumberThousands(value)
                end
                item:Init(name, value)
            end
            self._list:EnsureBoundsCorrect()
            self._list.scrollPane.touchEffect = self._list.scrollPane.contentHeight > self._list.height
        end
    )
end

function PlayerKillBox:Close()
    UIMgr:Close("PlayerKill/PlayerKillBox")
end

return PlayerKillBox
