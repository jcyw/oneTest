if Language then
    return Language
end

Language = {
  Afrikaans = "af",
  Arabic = "ar",
  Basque = "eu",
  Belarusian = "be",
  Bulgarian = "bg",
  Catalan = "ca",
  Chinese = "cn", --6,
  Czech = "cs",
  Danish = "da",
  Dutch = "nl",
  English = "en", -- 10
  Estonian = "et",
  Faroese = "fo",
  Finnish = "fi",
  French = "fr", -- 14
  German = "gr", -- 15
  Greek = "el",
  Hebrew = "he",
  Hungarian = "hu",
  Icelandic = "is",
  Indonesian = "id",
  Italian = "it",
  Japanese = "jp", -- 22
  Korean = "kr", -- 23
  Latvian = "lv",
  Lithuanian = "lt",
  Norwegian = "nb",
  Polish = "pl",
  Portuguese = "pt",
  Romanian = "ro",
  Russian = "ru",
  SerboCroatian = "hbs",
  Slovak = "sk",
  Slovenian = "sl",
  Spanish = "es",
  Swedish = "sv",
  Thai = "th",
  Turkish = "tr",
  Ukrainian = "uk",
  Vietnamese = "vi",
  ChineseSimplified = "cn", -- 40
  ChineseTraditional = "tw", -- 41
  Unknown = "en",
}

local _fallbackLocale = "en"

-- 机器语言
function Language.Device()
    local language = Util.GetLocalLanguage()
    local code = Language[language]
    Log.Info("Device Language: {0}", code)
    return code
end

-- 默认语言
function Language.Fallback()
    return _fallbackLocale
end

-- 保存语言
function Language.Saved()
    local saveLanguage = Util.GetPlayerData("Language")
    Log.Info("Saved Language: {0}", saveLanguage)
    return saveLanguage
end

-- 游戏语言
local languageConfs = import("gen/excels/configLanguages")
function Language.Current()
    local lan = Language.Saved()
    if lan == "" then
        lan = Language.Device()
    end
    for _,v in ipairs(languageConfs) do
        if v.language == lan then
            return lan
        end
    end
    return "en"
end

return Language