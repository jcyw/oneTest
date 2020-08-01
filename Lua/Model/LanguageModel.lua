local LanguageModel = {}

function LanguageModel.GetConfig(id)
    return ConfigMgr.GetItem("configLanguages", id)
end

function LanguageModel.GetConfigByShortName(name)
    local configs = ConfigMgr.GetList("configLanguages")
    local enId = 1
    for _,v in ipairs(configs) do
        if v.language == "en" then
            enId = v
        end
        if v.language == name then
            return v
        end
    end
    return enId
end

function LanguageModel.SetLanguageCache(id)
    local config = LanguageModel.GetConfig(id)
    Util.SetPlayerData("Language", config.language)
    ConfigMgr.SetI18nLocale(config.language)
    ResMgr.Instance:SetLanguage(config.language)
end

return LanguageModel