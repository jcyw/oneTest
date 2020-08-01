--author: 	Amu
--time:		2020-01-03 20:09:26
if SystemSetModel then
    return SystemSetModel
end

SystemSetModel = {}

--初始化游戏声音设置
function SystemSetModel.InitAudioVolume()
    local data = PlayerDataModel:GetData("SyetemSet" .. 10001)
    if not data then
        data = {
            soundVolume = 100,
            musicVolume = 100,
            soundSelected = false,
            musicSelected = false
        }
    end
    AudioManager.MusicMute = data.musicSelected
    AudioManager.ClipMute = data.soundSelected
    AudioManager.MusicVolume = data.musicVolume/100
    AudioManager.SoundVolume = data.soundVolume/100
    Util.SetPlayerData("LoginAudioRecord", JSON.encode(data))
end

--登录界面专用，声音设置为上个登录账号的声音设置
function SystemSetModel.InitLoginAudioVolume()
    local data = Util.GetPlayerData("LoginAudioRecord")
    if string.len(data) ~= 0 then
        data = JSON.decode(data)
    else
        data = nil
    end
    if not data then
        data = {
            soundVolume = 100,
            musicVolume = 100,
            soundSelected = false,
            musicSelected = false
        }
    end
    AudioManager.MusicMute = data.musicSelected
    AudioManager.ClipMute = data.soundSelected
    AudioManager.MusicVolume = data.musicVolume/100
    AudioManager.SoundVolume = data.soundVolume/100
end

function SystemSetModel.InitSystemSetting()
    SystemSetModel.RefreshSystemSetting(30001)
    SystemSetModel.RefreshSystemSetting(30004)
    SystemSetModel.RefreshSystemSetting(30008)
end

function SystemSetModel.RefreshSystemSetting(id)
    local data = PlayerDataModel:GetData("SyetemSet" .. id)
    if not data then
        local config = ConfigMgr.GetItem("configSystemSettings", id)
        data = {btnSelected = (config.reset > 0 and {false} or {true})[1],}
    end
    if id == 30001 then --  任务提示设置,这里暂时不能设置，走程序控制
        --Event.Broadcast(SYSTEM_SETTING_EVENT.HideTaskLable, not data.btnSelected)
    elseif id == 30002 then --  VIP展示设置
        Net.UserInfo.ModifyHideVipInfo(data.btnSelected)
    elseif id == 30003 then --  选中优先级设置
    elseif id == 30004 then --  日常奖励提醒
        Event.Broadcast(SYSTEM_SETTING_EVENT.HideDayGiftTip, not data.btnSelected)
    elseif id == 30008 then --  黑骑士行军路线
        Event.Broadcast(SYSTEM_SETTING_EVENT.HideOtherAISiege, data.btnSelected)
    end
end

function SystemSetModel.Clear(id)
    if id == 40001 then -- 清空缓存
        PlayerDataModel:ClearData()
        MailModel:DeleteDBTable()
        MailModel:Init()
        SystemSetModel.InitAudioVolume()
        SystemSetModel.InitSystemSetting()
        TipUtil.TipById(50279)
    end
end

function SystemSetModel.GoTo(id)
    if id == 20001 then -- 更新检测
        -- Sdk.OpenAppStore()
        Sdk.OpenBrowser("https://play.google.com/store/apps/details?id=com.global.neocrisis2")
        Net.UserInfo.EvaluateGame() -- 前往商店后通知服务器
    end
end

function SystemSetModel.RefreshNotifySetting(id)
end

function SystemSetModel.GetSetting(id)
    local data = PlayerDataModel:GetData("SyetemSet" .. id)
    if not data then
        data = {
            btnSelected = true
        }
    end
    return data.btnSelected
end

return SystemSetModel
