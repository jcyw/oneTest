--author: 	Amu
--time:		2019-08-12 20:27:13

if PlayerDataModel then
    return PlayerDataModel
end

PlayerDataModel = {}
function PlayerDataModel:Init(playId)
    local data = Util.GetPlayerData(playId)
    if string.len(data) == 0 then
        self.PlayData = {}
    else
        self.PlayData = JSON.decode(data)
    end
    self.PlayId = playId
end

function PlayerDataModel:SaveData()
    local data = JSON.encode(self.PlayData)
    Util.SetPlayerData(self.PlayId, data)
end

function PlayerDataModel:SetData(type, data)
    self.PlayData[type] = data
    self:SaveData()
end

function PlayerDataModel:GetData(type)
    if not self.PlayData then
        return
    end
    return self.PlayData[type] or nil
end

--设置不在提示数据 [今日登录不在提示]
function PlayerDataModel:SetDayNotTip(type)
    local info = self.PlayData[PlayerDataEnum.TIPDATA]
    if not info then
        info = {}
    end
    info["T"..type] = Tool.Time()
    self:SetData(PlayerDataEnum.TIPDATA, info)
end
--获取不在提示数据 [今日登录不在提示]
function PlayerDataModel:GetDayNotTip(type)
    local info = self.PlayData[PlayerDataEnum.TIPDATA]
    if not info then
        return --提示
    end
    local time = info["T"..type]
    if not time then
        return --提示
    end
    return TimeUtil.ToDay(time) --今日不再提示
end

function PlayerDataModel:ClearData()
    self.PlayData = {}
    Util.CleanPlayerData()
    self:Init(self.PlayId)
end

------------------ 与玩家Id无关
function PlayerDataModel.GetLocalData(key)
    return Util.GetPlayerData(key)
end
function PlayerDataModel.SetLocalData(key, value)
    Util.SetPlayerData(key, JSON.encode(value))
end

return PlayerDataModel