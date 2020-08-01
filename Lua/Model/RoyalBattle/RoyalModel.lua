--[[
    Author: tiantian
    Function: 王城信息缓存
]]
if _G.RoyalModel then
    return _G.RoyalModel
end
local RoyalModel = {}
local officerConfigInfo = ConfigMgr.GetDictionary("configWarZoneOfficers")
--官职类型
RoyalModel.OfficialTitleType = {
    --[[战区司令]] Throne_OfficialPost_King = 1,
    --[[后勤部长]] Throne_OfficialPost_Secretary = 2,
    --[[总工程师]] Throne_OfficialPost_ChiefExecutive = 3,
    --[[行政部长]] Throne_OfficialPost_JusticeSecretary = 4,
    --[[财务部长]] Throne_OfficialPost_Premier = 5,
    --[[陆军部部长]] Throne_OfficialPost_Inspector = 6,
    --[[陆军参谋长]] Throne_OfficialPost_Commander = 7,
    --[[科研部长]] Throne_OfficialPost_Investment = 8,
    --[[建设局长]] Throne_OfficialPost_Engineer = 9
}
--官职名称缓存列表
RoyalModel.OfficialTitleText = {}
--记录类型 1 历史司令 2 争夺记录
RoyalModel.RecordType = {king = 1, War = 0}
RoyalModel.RecordList = {{}, {}}

--请求-王位战信息
function RoyalModel.SetKingWarInfo()
    Net.King.WarInfo(
        function(msg)
            RoyalModel.GetKingWarInfoRsp(msg)
        end
    )
end
--通知-王位战活动信息
function RoyalModel.GetKingWarInfoRsp(msg)
    RoyalModel.warInfo = msg
    Event.Broadcast(EventDefines.KingInfoChange)
end
 --获取王位战信息
function RoyalModel.GetKingWarInfo()
    return RoyalModel.warInfo
end

--请求 获取王位（位置）信息
function RoyalModel.GetKingInfo(cb)
    Net.King.GetKingInfo(
        function(msg)
            RoyalModel.UpdataKingInfo(msg.Info)
            if cb then
                cb()
            end
        end
    )
end
--通知-王位战活动信息(暂时无用 没有通知)
function RoyalModel.UpdataKingInfo(msg)
    RoyalModel.KingInfo = msg
end

--请求-获取历史国王信息
function RoyalModel.GetHistoryKings(cb)
    Net.King.HistoryKings(
        function(msg)
            RoyalModel.RecordList[RoyalModel.RecordType.king] = msg.Kings
            if cb then
                cb()
            end
        end
    )
end
--请求-获取争夺记录信息
function RoyalModel.GetWarLogs(cb)
    Net.King.WarLogs(
        function(msg)
            RoyalModel.RecordList[RoyalModel.RecordType.War] = msg.Logs
            if cb then
                cb()
            end
        end
    )
end

--请求-获取头衔信息
function RoyalModel.GetTitlesInfo(cb)
    Net.King.TitlesInfo(
        function(msg)
            RoyalModel.titlesInfo = {}
            for _, value in ipairs(msg.Titles) do
                RoyalModel.titlesInfo[value.TitleId] = value.Info
            end
            if cb then
                cb()
            end
        end
    )
end

--请求-王战礼包分配记录
function RoyalModel.GetKingdomGiftRecords(cb)
    Net.King.KingdomGiftRecords(function(msg)
        if cb then
            cb(msg)
        end
    end)
end

--官员和奴隶分类 不含司令101
function RoyalModel.GetConfigWarZoneOfficer()
    local Officer1 = {}
    local Officer2 = {}
    local cfg = _G.ConfigMgr.GetList("configWarZoneOfficers")
    for _, value in ipairs(cfg) do
        if value.officer_event ==1 and value.id~=101 then
            table.insert(Officer1,value)
        end
        if value.officer_event ==2 then
            table.insert(Officer2,value)
        end
    end
    return Officer1,Officer2
end

--通过玩家ID获取头衔信息
function RoyalModel.GetTitleInfoByUserId(UserId)
    for key, value in pairs(RoyalModel.titlesInfo or {}) do
        if UserId == value.PlayerId then
            return key,value
        end
    end
    return nil,nil
end

--获取官职任职信息
function RoyalModel.GetTitleInfoByTitleId(Id)
    return RoyalModel.titlesInfo and RoyalModel.titlesInfo[Id]
end

function RoyalModel.GetAccountTitlePower(powerId)
    local titleId = RoyalModel.GetTitleInfoByUserId(Model.Account.accountId)
    if titleId then
        local power = _G.ConfigMgr.GetItem("configWarZoneOfficers",titleId).power
        return table.contains(power, powerId)
    end
    return false
end

--获取官职文本
function RoyalModel.GetOfficialTitleStr(mtype)
    --没有缓存的时候 需要先初始化
    if not next(RoyalModel.OfficialTitleText) then
        for key, pos in pairs(RoyalModel.OfficialTitleType) do
            local str = _G.StringUtil.GetI18n(_G.I18nType.Commmon, key)
            RoyalModel.OfficialTitleText[pos] = str
        end
    end
    return RoyalModel.OfficialTitleText[mtype]
end
--王城状态
RoyalModel.RoyalStatusType = {Ready = 1, Vita = 2, Ulichukua = 3, Amani = 4}
--获取当前王城状态
function RoyalModel.GetRoyalStatus()
    local status = RoyalModel.RoyalStatusType.Ready
    local i18nkey = ""
    if not RoyalModel.warInfo then
        return status, i18nkey
    end
    --是否有占领者
    local hasUser = RoyalModel.warInfo and RoyalModel.warInfo.KingInfo
    hasUser = hasUser and string.len(RoyalModel.warInfo.KingInfo.PlayerId)>0
    if not RoyalModel.warInfo.InWar and not hasUser then
        --准备状态 不在战争状态且没有占领者
        status = RoyalModel.RoyalStatusType.Ready
        i18nkey = "Throne_Status_ProtectionTime"
    end
    if not RoyalModel.warInfo.InWar and hasUser then
        --和平状态 不在战争状态且有占领者
        status = RoyalModel.RoyalStatusType.Amani
        i18nkey = "Throne_Status_ProtectionTime"
    end
    if RoyalModel.warInfo.InWar and not hasUser then
        --争夺状态 在战争状态且没有占领者
        status = RoyalModel.RoyalStatusType.Vita
        i18nkey = "UI_Warzone_CompetingTime"
    end
    if RoyalModel.warInfo.InWar and hasUser then
        --占领状态 在战争状态且有占领者
        status = RoyalModel.RoyalStatusType.Ulichukua
        i18nkey = "UI_Warzone_OccupierTime"
    end
    return status, i18nkey
end

--所有礼包信息（服务器获取）
local _allGiftsInfo  --key = 礼包ID  value = {info（服务器记录消息，含Id和已发人员Receivers），config(配置表内容，名字，奖励道具等)}
local _givingOutGiftId

function RoyalModel.GetAllGiftData()
    return _allGiftsInfo
end

function RoyalModel.GetGiftInfoById(giftId)
    return _allGiftsInfo[giftId]
end

local SearchType = {
    Gift = 1,
    Officer = 2,
    King = 3
}

local _officialPositionId
local _curPfficialPositionPlayerData
local _curSearchType

function RoyalModel.SetSearchType(searchType)
    _curSearchType = SearchType[searchType]
end
--设定选择要发放的礼包
function RoyalModel.SetGivingOutGiftId(giftId)
    _givingOutGiftId = giftId
end

--确定发礼包
function RoyalModel.ConfirmSendGift()
    if not _allGiftsInfo[_givingOutGiftId].players or #_allGiftsInfo[_givingOutGiftId].players == 0 then
        return
    end
    local playerArr = {}
    for k,v in pairs (_allGiftsInfo[_givingOutGiftId].players) do
        playerArr[#playerArr + 1] = v.Uuid
    end
    if #playerArr == 0 then
        return
    end
    Net.King.SendGift(playerArr,_givingOutGiftId,
        function()
            RoyalModel.GetAllGiftInfo()
            TipUtil.TipById(50337)
        end)
end

--判定选中被搜索人员的礼包发放状态
function RoyalModel.GetPlayerRoyalGiftState(playerId)
    for k,v in pairs (_allGiftsInfo[_givingOutGiftId].info.Receivers) do
        if v.PlayerId == playerId then
            return 1
        end
    end
    for k,v in pairs (_allGiftsInfo[_givingOutGiftId].players or {}) do
        if v.Uuid == playerId then
            return 2
        end
    end
    return 0
end

function RoyalModel.RoyalGiftSelectPlayer(playerData)
    if #_allGiftsInfo[_givingOutGiftId].players + #_allGiftsInfo[_givingOutGiftId].info.Receivers < _allGiftsInfo[_givingOutGiftId].config.gift_num then
        local has = false
        local index
        for k,v in pairs(_allGiftsInfo[_givingOutGiftId].players) do
            if v.Uuid == playerData.Uuid then
                has = true
                index = k
                break
            end
        end
        if not has then
            table.insert(_allGiftsInfo[_givingOutGiftId].players,playerData)
        else
            table.remove( _allGiftsInfo[_givingOutGiftId].players,index )
        end
    else
        -- sly 提示人满
    end
    Event.Broadcast(EventDefines.SelectRoyalGiftPlayerToGive)
end

function RoyalModel.RoyalGiftUnSelectPlayer(playerData)
    local removeIndex
    for i = 1 , #_allGiftsInfo[_givingOutGiftId].players do
        if _allGiftsInfo[_givingOutGiftId].players[i].Uuid == playerData.Uuid then
            removeIndex = i
            break
        end
    end
    table.remove( _allGiftsInfo[_givingOutGiftId].players, removeIndex )
    Event.Broadcast(EventDefines.RoyalGiftRefresh)
end
local _curChangeKingPlayerData
function RoyalModel.CleanSelectingPlayerList()
    for k,v in pairs(_allGiftsInfo or {}) do
        v.players = {}
    end
    _curChangeKingPlayerData= nil
end

function RoyalModel.GetSelectingGiftInfo()
    return _allGiftsInfo[_givingOutGiftId]
end

function RoyalModel.GetSelectingGiftReceiversInfo(index)
    if index <= #_allGiftsInfo[_givingOutGiftId].info.Receivers then
        return _allGiftsInfo[_givingOutGiftId].info.Receivers[index]
    else
        if not _allGiftsInfo[_givingOutGiftId].players then
            _allGiftsInfo[_givingOutGiftId].players = {}
        end
        return _allGiftsInfo[_givingOutGiftId].players[index - #_allGiftsInfo[_givingOutGiftId].info.Receivers]
    end
end

function RoyalModel.GetGivingOutGiftId()
    return _givingOutGiftId
end

function RoyalModel.GetAllGiftInfo()
    local allGiftsConfig = ConfigMgr.GetDictionary("configWarZoneGifts")
    _allGiftsInfo = {}
    Net.King.GetGiftInfos(
        function(rsp)
            for _, info in pairs(rsp.Infos) do
                _allGiftsInfo[info.Id] = {}
                _allGiftsInfo[info.Id].info = info
                _allGiftsInfo[info.Id].config = allGiftsConfig[info.Id]
            end
            Event.Broadcast(EventDefines.RoyalGiftRefresh)
        end
    )
end

--设定选择要发放的官职
function RoyalModel.SetOfficialPositionId(officialPositionId)
    _curPfficialPositionPlayerData = nil
    _officialPositionId = officialPositionId
end

function RoyalModel.SearchForGift()
    return _curSearchType == SearchType.Gift
end

function RoyalModel.SearchForOfficer()
    return _curSearchType == SearchType.Officer
end

function RoyalModel.SearchForKing()
    return _curSearchType == SearchType.King

end

function RoyalModel.SetOfficialPositionPlayer(playerData)
    if _curPfficialPositionPlayerData and _curPfficialPositionPlayerData.Uuid == playerData.Uuid then
        _curPfficialPositionPlayerData = nil
    else
        _curPfficialPositionPlayerData = playerData
    end
    Event.Broadcast(EventDefines.OfficialPositionRefresh2)
end

--判定当前官职的角色选中状态
function RoyalModel.GetOfficialPositionPlayerState(playerId)
    return playerId == (_curPfficialPositionPlayerData and _curPfficialPositionPlayerData.Uuid or "")
end

function RoyalModel.ConfirmSetOfficialPosition(cb)
    if not _officialPositionId or not _curPfficialPositionPlayerData then
        return 
    end
    local netking = function()
        Net.King.GiveTitle(_curPfficialPositionPlayerData.Uuid,_officialPositionId,
        function()
            Event.Broadcast(EventDefines.OfficialPositionRefresh)
        end)
        if cb then
            cb()
        end
    end
    if RoyalModel.warInfo.KingInfo and _curPfficialPositionPlayerData.Uuid == RoyalModel.warInfo.KingInfo.PlayerId then
        TipUtil.TipById(50336)
    else
        local key,_ = RoyalModel.GetTitleInfoByUserId(_curPfficialPositionPlayerData.Uuid)
        if key then
            local off1 = StringUtil.GetI18n(I18nType.Commmon,_G.ConfigMgr.GetItem("configWarZoneOfficers",key).office_name)
            local off2 = StringUtil.GetI18n(I18nType.Commmon,_G.ConfigMgr.GetItem("configWarZoneOfficers",_officialPositionId).office_name)
            local data =
            {
                content = StringUtil.GetI18n(I18nType.Commmon, "Ui_WarZone_AppointConfirm", {office1 = off1,office2 = off2}),
                sureCallback = netking
            }
            UIMgr:Open("ConfirmPopupText", data)
        else
            netking()
        end
    end
end

function RoyalModel.ConfirmResetOfficialPosition()
    if not _officialPositionId then
        return 
    end
    Net.King.RemoveTitle(_curPfficialPositionPlayerData.PlayerId,_officialPositionId,
        function()
            Event.Broadcast(EventDefines.OfficialPositionRefresh)
        end
    )
end


function RoyalModel.GetKingPositionPlayerState(playerId)
    return playerId == (_curChangeKingPlayerData and _curChangeKingPlayerData.Uuid or "")
end

function RoyalModel.SetKingPositionPlayer(playerData)
    if _curChangeKingPlayerData and _curChangeKingPlayerData.Uuid == playerData.Uuid then
        _curChangeKingPlayerData = nil
    else
        _curChangeKingPlayerData = playerData
    end
    Event.Broadcast(EventDefines.OfficialPositionRefresh2)
end

function RoyalModel.ConfirmChangeKing()
    if not _curChangeKingPlayerData then
        return 
    end
    Net.King.TransferCrown(_curChangeKingPlayerData.Uuid,
    function()
        RoyalModel.SetKingWarInfo()
        Event.Broadcast(EventDefines.OfficialPositionRefresh)
    end
)
end

function RoyalModel.CanChangeKing(kingUuid)
    local isKing = kingUuid == Model.Account.accountId
    local inTime = RoyalModel.KingInfo.TransferDeadline > _G.Tool.Time()
    return isKing and inTime
end

function RoyalModel.IsKing(playerUuid)
    return playerUuid == RoyalModel.KingInfo.UserId
end

_G.RoyalModel = RoyalModel
return RoyalModel
