--author: 	Amu
--time:		2019-11-09 15:18:31

if AudioModel then
    return AudioModel
end

AudioModel = {}
AudioModel.MusicId = 0

function AudioModel.Play(soundId)
    local config = ConfigMgr.GetItem("sounds", tonumber(soundId))
    if not config then
        Log.Error("AudioModel.Play failed, sound not found: {0}", soundId)
        return
    end    
    if config.type == 0 then
        AudioModel.MusicId = soundId
        if config.name then
            AudioManager:PlayMusic(config.name)
        end
    elseif config.type == 1 then
        if config.order then
            if config.name then
                AudioManager:PlayClip(config.name, config.order, true)
            end
        else
            if config.name then
                AudioManager:PlayClip(config.name)
            end
        end
    elseif config.type == 2 then
        if config.order then
            if config.name then
                AudioManager:PlayClip(config.name, config.order, false)
            end
        else
            if config.name then
                AudioManager:PlayClip(config.name, 1, false)
            end
        end
    elseif config.type == 3 then
        AudioModel.PlaySpeech(config.name)
    end
end

function AudioModel.SetSoundName(btn, soundId)
    local config = ConfigMgr.GetItem("sounds", tonumber(soundId))
    btn.SoundName = config.name
end

function AudioModel.StopSpeech()
    if AudioManager.StopSpeech then
        AudioManager:StopSpeech()
    end 
end

function AudioModel.PlaySpeech(speechName)
    local bundleName = ResMgr.Instance:GetBundleName("music")
    local bundle = ResMgr.Instance:LoadBundleSync(bundleName)
    local clip = bundle:LoadAsset(speechName)
    if clip then
        if AudioManager.PlaySpeech then
            AudioManager:PlaySpeech(clip)
            return clip.length
        else
            return 3
        end
    else
        DynamicRes.GetAudioClip("audio", speechName, function(audioClip)
            if AudioManager.PlaySpeech then
                --Log.Error("audioClip.length------{0}", audioClip.length)
                AudioManager:PlaySpeech(audioClip)
                return audioClip.length
            else
                return 3
            end
        end)
        return 3
    end
end

return AudioModel