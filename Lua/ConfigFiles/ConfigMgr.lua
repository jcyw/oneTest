local ConfigMgr = {}

import("ConfigFiles/Language")

local loaded = {}
local indexes = {}
local _fallbackLocale = Language.Fallback()
local _currentLocale = Language.Current()

local function load(name)
    local conf = import("gen/excels/" .. name)
    loaded[name] = conf
    if name ~= "Global" then
        local index = {}
        for i, v in ipairs(conf) do
            index[v.id] = i
        end
        indexes[name] = index
    end
end

function ConfigMgr.Init()
    _fallbackLocale = Language.Fallback()
    _currentLocale = Language.Current()
end

-- 获取整个配置表并转换为dic
function ConfigMgr.GetDictionary(name)
    local conf = loaded[name]
    local dic = {}
    if not conf then
        load(name)
        conf = loaded[name]
    end
    for i, v in ipairs(conf) do
        dic[v.id] = v
    end
    return dic
end

-- 获取整个配置表
function ConfigMgr.GetList(name)
    local conf = loaded[name]
    if not conf then
        load(name)
        conf = loaded[name]
    end
    return conf
end

-- 获取配置表的一行
function ConfigMgr.GetItem(name, key)
    local conf = ConfigMgr.GetList(name)
    local idx = indexes[name][key]
    return conf[idx]
end

-- 按照给定的键值搜索表里符合的项
function ConfigMgr.GetListBySearchKeyValue(name, key, value)
    local list = {}
    local conf = ConfigMgr.GetList(name)
    for i, t in pairs(conf) do
        if t[key] == value then
            table.insert(list, t)
        end
    end
    return list
end

-- 获取全局变量
function ConfigMgr.GetVar(field)
    local conf = ConfigMgr.GetList("Global")
    return conf[field]
end

function ConfigMgr.SetI18nLocale(currentLocale)
    _currentLocale = currentLocale
end

function ConfigMgr:GetLocale()
    if _currentLocale then
        return _currentLocale
    else
        return _fallbackLocale
    end
end

local function I18nMissing(name, key)
    return name .. "_" .. key
end

-- 获取国际化描述
-- name 配置表名
-- key 条目ID
function ConfigMgr.GetI18n(name, key)
    local conf = ConfigMgr.GetList(name)
    if not conf then
        return I18nMissing(name, key)
    end

    local idx = indexes[name][key]
    if not idx then
        return I18nMissing(name, key)
    end

    local row = conf[idx]
    if not idx then
        return I18nMissing(name, key)
    end

    local text = row[_currentLocale] or row[_fallbackLocale]
    if text then
        return text
    else
        return I18nMissing(name, key)
    end
end
_G.ConfigMgr = ConfigMgr
return ConfigMgr
