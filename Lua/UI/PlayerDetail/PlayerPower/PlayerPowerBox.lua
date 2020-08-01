--[[
    Author: songzeming
    Function: 玩家战力弹窗
]]
local PlayerPowerBox = UIMgr:NewUI("PlayerPower/PlayerPowerBox")

import("UI/PlayerDetail/PlayerPower/ItemPlayerPowerBox")
local POWER_TYPE = {
    "Ui_player_Forces", --指挥官战斗力
    "Ui_Army_Forces", --部队战斗力
    "Ui_Build_Forces", --建筑战斗力
    "Ui_PlayerAttribute1008", --装备战斗力
    "Ui_DefWeapon_Forces", --防御武器战斗力
    "Ui_AllianceTech_Forces", --联盟科技战斗力
    "Ui_Monster_Forces" --巨兽战斗力
}
local NET_POWER_TYPE = {
    "HeroPower",
    "ArmiesPower",
    "BuildingsPower",
    "EquipPower",
    "TrapsPower",
    "TechsPower",
    "BeastPower"
}

function PlayerPowerBox:OnInit()
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

    self._textPower.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Total_Forces")
end

function PlayerPowerBox:OnOpen()
    self._list.numItems = 0
    Net.UserInfo.GetUserDetailedPowerInfo(
        function(rsp)
            self._power.text = Tool.FormatNumberThousands(rsp.TotalPower)
            self._list.numItems = #POWER_TYPE
            for i = 1, self._list.numChildren do
                local title = StringUtil.GetI18n(I18nType.Commmon, POWER_TYPE[i])
                local power = Tool.FormatNumberThousands(rsp[NET_POWER_TYPE[i]])
                local cb_func = function()
                    local t = title .. ": " .. power
                    UIMgr:Open("PlayerPower/PlayerPowerTurnBox", i, t)
                end
                local item = self._list:GetChildAt(i - 1)
                item:Init(title, power, cb_func)
            end
            self._list:EnsureBoundsCorrect()
            self._list.scrollPane.touchEffect = self._list.scrollPane.contentHeight > self._list.height
        end
    )
end

function PlayerPowerBox:Close()
    UIMgr:Close("PlayerPower/PlayerPowerBox")
end

return PlayerPowerBox
