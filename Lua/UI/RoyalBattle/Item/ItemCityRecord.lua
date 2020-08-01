--[[
    author:{tiantian}
    time:2020/6/10
    function:{王城城市大厅记录和名人堂item}
]]
local ItemCityRecord = fgui.extension_class(GComponent)
fgui.register_extension("ui://RoyalBattle/ItemCityRecord", ItemCityRecord)

function ItemCityRecord:ctor()
    self._controller1 = self:GetController("c1")
    self._controller2 = self:GetController("c2")
    self._now.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon,"Throne_Status_FormerKing_CurrentKingIcon")
    self:InitEvent()
end
function ItemCityRecord:InitEvent()
end
function ItemCityRecord:SetData(itemData, recordType,index,isEnd)
    self._controller1.selectedIndex = index%2==0 and 0 or 1
    local info = _G.RoyalModel.GetKingWarInfo()
    local status,_ = _G.RoyalModel.GetRoyalStatus()

    self._controller2.selectedIndex = 0
    if recordType == _G.RoyalModel.RecordType.king then
        local userId = itemData.UserId and StringUtil.Split(itemData.UserId, ".",true)[1]
        if isEnd then
            local lastTime = _G.RoyalModel.KingInfo.TransferDeadline - _G.Tool.Time()
            local waitStatus = not _G.RoyalModel.KingInfo or lastTime<=0
            local isking = status == RoyalModel.RoyalStatusType.Amani and userId == info.KingInfo.PlayerId
            isking = isking and waitStatus
            self._controller2.selectedIndex = isking and 1 or 0
        end
        -- CommonModel.SetUserAvatar(self._icon, itemData.UserAvatar, userId)
        self._icon:SetAvatar(itemData, nil, userId)
        self._info.text =
            _G.StringUtil.GetI18n(
            _G.I18nType.Commmon,
            "Throne_Status_FormerKing_KingLogText",
            {number = itemData.Rank, player_name = itemData.UserName}
        )
        self._time.text =
            _G.StringUtil.GetI18n(
            _G.I18nType.Commmon,
            "Throne_Status_FormerKing_Time",
            {time = _G.TimeUtil.StampTimeToYMD(itemData.Value)}
        )
    else
        local cfg = ConfigMgr.GetItem("configWarZoneRecords",itemData.Id)
        local data = #itemData.Params>=2 and {play_name=itemData.Params[1],play_name2=itemData.Params[2]}
        or {play_name=itemData.Params[1]}
        -- CommonModel.SetUserAvatar(self._icon, itemData.Avatar, userId)
        self._icon:SetAvatar(itemData, nil, itemData.UserId)
        self._info.text = "[color=#e55d41]"..
        _G.StringUtil.GetI18n(
        _G.I18nType.Commmon,
        cfg.content,
        data
        )
        self._time.text =
        _G.StringUtil.GetI18n(
        _G.I18nType.Commmon,
        "Throne_Status_Log_Time",
        {time = _G.TimeUtil.StampTimeToYMD(itemData.Time)}
    )
    end
end
