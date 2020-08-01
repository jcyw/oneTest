--[[
    author:{zhanzhang}
    time:2019-06-29 09:48:26
    function:{战争记录}
]]
local ItemUnionBattleRecords = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionBattleRecords", ItemUnionBattleRecords)

function ItemUnionBattleRecords:ctor()
    self._controller = self:GetController("c1")
end

function ItemUnionBattleRecords:Init(index, data)
    -- Attacker:"Guest17"
    -- AttackerAlliance:"1m3"
    -- Category:0
    -- CreatedAt:1573005346
    -- Defender:"Guest18"
    -- DefenderAlliance:""
    -- IsWin:true
    -- PlunderRes 0是没有，其他按照资源表配置

    self._textAttackName.text = GameUtil.ShowPlayerName(data.Attacker, data.AttackerAlliance)
    self._textDenfenceName.text = GameUtil.ShowPlayerName(data.Defender, data.DefenderAlliance)

    local isVicInFirst = data.IsWin == (data.AttackerAlliance == Model.Player.AllianceName)
    if data.AttackerAlliance == Model.Player.AllianceName then
        self._controller.selectedIndex = 0
    else
        self._controller.selectedIndex = 2
    end

    self._textAttackStatus.text = StringUtil.GetI18n(I18nType.Commmon, isVicInFirst and "Ui_Victory" or "Ui_Defeat")
    self._textDefenceStatus.text = StringUtil.GetI18n(I18nType.Commmon, isVicInFirst and "Ui_Defeat" or "Ui_Victory")
    self._textAttackStatus.color = isVicInFirst and UITool.Green or UITool.Red

    self._textDefenceStatus.color = isVicInFirst and UITool.Red or UITool.Green

    self._textTimeNum.text = TimeUtil:GetTimesAgo(data.CreatedAt)
    if data.PlunderRes > 0 then
        local config = ConfigMgr.GetItem("configResourcess", data.PlunderRes)
        self._iconRes.icon = UITool.GetIcon(config.icon)
        self._controller.selectedIndex = 1
    end
end

return ItemUnionBattleRecords
