if LoadingTip then
    return LoadingTip
end

LoadingTip = {}

import("ConfigFiles/Language")
local _fallbackLocale = Language.Fallback()
local _currentLocale = Language.Current()

local conf = import("gen/excels/configI18nLoadingtips")
local index = {}
for i, v in ipairs(conf) do
    index[v.id] = v
end

function LoadingTip.Get(key)
    local item = index[key]
    if not item then
        return key
    end
    return item[_currentLocale] or item[_fallbackLocale]
end

return LoadingTip