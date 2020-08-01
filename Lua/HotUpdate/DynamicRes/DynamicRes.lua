if DynamicRes then
    return DynamicRes
end

local Tools = import("HotUpdate/Tools/Tools")

DynamicRes = {
    -- 资源列表
    list = nil, -- item={md5="xx", size=xx, downloaded=true|false}
    -- 下载列表
    downloadings = {},
    -- 等待列表
    waitings = {},
}

local DynamicResDir = "dynamicres/"
local SyncFunction = function()
    DynamicRes.syncList()
end

function DynamicRes.Sync()
    if not KSUtil.IsEditor() then
        CSCoroutine.Start(SyncFunction)
    end
end

function DynamicRes.GetTexture2D(bundleName, resName, cb)
    local key = bundleName .. "/" .. resName
    DynamicRes.GetBundle(bundleName, function(ab)
        if not ab then
            -- Log.Info("dynamicres GetTexture2D nil: {0}", bundleName)
            return nil
        end
        local tex = ab:LoadAsset(resName)
        if tex then
            -- Log.Info("dynamicres GetTexture2D success: {0}->{1}", bundleName, resName)
            cb(tex)
        end
    end)
end

function DynamicRes.GetAudioClip(bundleName, resName, cb)
    DynamicRes.GetBundle(bundleName, function(ab)
        if not ab then
            return nil
        end
        local audioClip = ab:LoadAsset(resName)
        if audioClip then
            cb(audioClip)
        end
    end)
end

-- CustomGLoader回调
function DynamicRes.LuaGetTexture2D(url)
    local bundleName, resName = DynamicRes.urlToBundleAndResName(url)
    DynamicRes.GetTexture2D(bundleName, resName, function(tex)
        CustomGLoader.OnGetTexutre2D(url, tex)
    end)
end

-- 配置url -> bundleName,resName
function DynamicRes.urlToBundleAndResName(url)
    url = string.lower(url)
    local chunks = StringUtil.Split(url, ":")
    return chunks[1], chunks[2]
end

function DynamicRes.GetRealDicKeyName(name)
    if KSUtil.IsEditor() then
        return "HotUpdate/"..GameVersion.localV.."/"..KResourceModule.BundlesPathRelative.."dynamicres/"..name
    else
        local ok, fullPath = DynamicRes.nameToFullPath(name)
        return fullPath
    end
end

function DynamicRes.GetBundle(name, cb, progress)
    UIMgr.removeDelayDisposeBundle(name)
    if KSUtil.IsEditor() then        
        local path = "HotUpdate/"..GameVersion.localV.."/"..KResourceModule.BundlesPathRelative.."dynamicres/"..name
        cb(DynamicRes.loadBundle(path))
    else
        if not DynamicRes.list then
            table.insert(DynamicRes.waitings, {
                name = name,
                cb = cb,
                progress = progress,
            })
            return
        end
        if not DynamicRes.list[name] then
            Log.Error("bundle not in dynamicres: " .. name)
            return
        end
        local downloading, fullPath = DynamicRes.checkDownloading(name, cb, progress)
        if not downloading then
            local func = function()
                DynamicRes.downloadBundle(name, fullPath, cb, progress)
            end
            DynamicRes.downloadings[fullPath] = {
                cbs = {},
                progresses = {},
                updatedAt = os.time(),
                func = func,
            }
            CSCoroutine.Start(func)
        end
    end
end

function DynamicRes.GetPrefab(bundleName, resName, cb, progress)
    DynamicRes.GetBundle(bundleName, function(ab)
        if not ab then
            return nil
        end
        local tex = ab:LoadAsset(resName)
        cb(tex)
    end, progress)
end

--检测是否已经下载完毕
function DynamicRes.CheckDownloaded(name)
    if KSUtil.IsEditor() then
        return true
    end
    if not DynamicRes.list then
        return false
    end
    local ok, fullPath = DynamicRes.nameToFullPath(name)
    if ok and DynamicRes.list[name] and DynamicRes.list[name].downloaded then
        return true
    else
        return false
    end
end

function DynamicRes.sortDownloadList()
    -- 按照优先级排序
    table.sort(DynamicRes.downloadList, function(nameA, nameB)
        local conf1 = ConfigMgr.GetItem("configDynamics", nameA)
        local conf2 = ConfigMgr.GetItem("configDynamics", nameB)
        local priority1 = (conf1 and conf1.priority or 1000)
        local priority2 = (conf2 and conf2.priority or 1000)
        return priority1 < priority2
    end)
end

function DynamicRes.syncList()
    -- 下载资源列表
    local url = DynamicRes.listUrl()
    local data, err = Tools.download(url)
    if err then
        Log.Warning("DynamicRes download list failed: {0}", err)
        coroutine.yield(UnityEngine.WaitForSeconds(1))
        DynamicRes.syncList()
        return
    end
    -- 解析资源列表
    local content = Util.Unzip(data)
    local list = GameVersionList.Parse(content)
    -- 生成下载列表
    DynamicRes.downloadList = {}
    DynamicRes.list = {}
    for name, item in pairs(list) do
        DynamicRes.list[name] = item
        local md5 = DynamicRes.getMD5(name)
        if md5 == item.md5 then
            item.downloaded = true
        else
            item.downloaded = false
            local conf = ConfigMgr.GetItem("configDynamics", name)
            if not string.match(name, ".manifest") and conf and conf.default == 1 then
                table.insert(DynamicRes.downloadList, name)
            end
        end
    end
    DynamicRes.sortDownloadList()
    -- 下载等待中的资源
    for _, waiting in ipairs(DynamicRes.waitings) do
        DynamicRes.GetBundle(waiting.name, waiting.cb, waiting.progress)
    end
    -- 静默下载所有资源
    if #DynamicRes.downloadList > 0 then
        DynamicRes.syncRes(DynamicRes.downloadList)
    end
end

function DynamicRes.syncRes(list)
    for _, name in ipairs(list) do
        local downloading, fullPath = DynamicRes.checkDownloading(name)
        if not downloading then
            DynamicRes.downloadings[fullPath] = {
                cbs = {},
                progresses = {},
                updatedAt = os.time(),
            }
            DynamicRes.downloadBundle(name, fullPath)
        end
    end
end

local downloadExpire = 5
function DynamicRes.checkDownloading(name, cb, progress)
    local ok, fullPath = DynamicRes.nameToFullPath(name)
    -- 已下载
    if ok and DynamicRes.list[name] and DynamicRes.list[name].downloaded then
        local ab = DynamicRes.loadBundle(fullPath)
        if cb then
            -- Log.Info("dynamicres got: {0}", name)
            cb(ab)
        end
        return true, fullPath
    end

    -- 下载超时
    local task = DynamicRes.downloadings[fullPath]
    if task and task.updatedAt + downloadExpire <= os.time() then
        -- Log.Info("dynamicres download timeout: {0}", name)
        if task.func then
            CSCoroutine.Stop(task.func)
        end
        DynamicRes.downloadings[fullPath] = nil
        return false, fullPath
    end

    -- 下载中
    if task then
        if cb then
            -- Log.Info("dynamicres pending downloading: {0}", name)
            table.insert(task.cbs, cb)
        end
        if progress then
            table.insert(task.progresses, progress)
        end
        return true, fullPath
    end
    return false, fullPath
end

-- 私有方法
function DynamicRes.downloadBundle(name, fullPath, cb, progress)
    Log.Info("DynamicRes download: {0}", name)
    local task = DynamicRes.downloadings[fullPath]
    if cb then
        table.insert(task.cbs, cb)
    end
    if progress then
        table.insert(task.progresses, progress)
    end

    local url = DynamicRes.nameToUrl(name)

    -- 下载manifest
    local data, err = Tools.download(url..".manifest")
    if err then
        DynamicRes.downloadings[fullPath] = nil
        return
    end
    Util.WriteFile(fullPath..".manifest", data)
    -- 文件检测
    local manifest = name..".manifest"
    if DynamicRes.list[manifest].md5 ~= DynamicRes.getMD5(manifest) then
        Log.Error("md5 not match: {0}.manifest {1}->{2}", manifest, DynamicRes.list[manifest].md5, DynamicRes.getMD5(manifest))
        DynamicRes.downloadings[fullPath] = nil
        return
    end
    -- 下载bundle
    local data, err = Tools.download(url, function(percent)
        -- Log.Info("dynamic name: {0} -> {1}%", name, math.floor(percent * 100))
        for i, subProgress in ipairs(task.progresses) do
            if subProgress then
                subProgress(percent)
            end
        end
        local task = DynamicRes.downloadings[fullPath]
        if task then
            task.updatedAt = os.time()
        end
    end)
    if err then
        DynamicRes.downloadings[fullPath] = nil
        return
    end
    -- Log.Info("DynamicRes download success: {0}", name)
    Util.WriteFile(fullPath, data)
    -- 文件检测
    if DynamicRes.list[name].md5 ~= DynamicRes.getMD5(name) then
        Log.Error("md5 not match: {0} {1}->{2}", name, DynamicRes.list[name].md5, DynamicRes.getMD5(name))
        DynamicRes.downloadings[fullPath] = nil
        return
    end
    local task = DynamicRes.downloadings[fullPath]
    DynamicRes.downloadings[fullPath] = nil
    DynamicRes.list[name].downloaded = true
    if task and #task.cbs > 0 then
        local ab = DynamicRes.loadBundleWithData(fullPath, data)
        Log.Info("DynamicRes.loadBundleWithData fullPath: {0}", fullPath)
        for _, cb in ipairs(task.cbs) do
            -- Log.Info("dynamicres got: {0}", name)
            cb(ab)
        end
    end
end

function DynamicRes.loadBundle(fullPath)
    local ab = ResMgr.Instance:GetCacheBundle(fullPath)
    if ab then
        return ab
    end
    local bytes = KResourceModule.ReadAllBytes(fullPath)
    ab = AssetBundle.LoadFromMemory(Util.Strip(bytes))
    ResMgr.Instance:SetCacheBundles(fullPath, ab)
    return ResMgr.Instance:GetCacheBundle(fullPath)
end

function DynamicRes.loadBundleWithData(fullPath, data)
    local ab = ResMgr.Instance:GetCacheBundle(fullPath)
    if ab then
        return ab
    end
    ab = AssetBundle.LoadFromMemory(Util.Strip(data))
    ResMgr.Instance:SetCacheBundles(fullPath, ab)
    return ResMgr.Instance:GetCacheBundle(fullPath)
end

local _host = ""
function DynamicRes.host()
    if _host == "" then
        local version = GameVersion.remote
        _host = GameVersion.VersionHost().."/"..version
        _host = _host.."/"..KResourceModule.BundlesPathRelative.. "dynamicres"
    end
    return _host
end

function DynamicRes.listUrl()
    return DynamicRes.host().."/version_list"
end

function DynamicRes.nameToUrl(name)
    return DynamicRes.host().."/"..name
end

function DynamicRes.nameToFullPath(name)
    local path = KResourceModule.BundlesPathRelative .. "dynamicres/" .. name
    return KResourceModule.TryGetDocumentResourceUrl(path, false)
end

function DynamicRes.getMD5(name)
    local ok, fullPath = DynamicRes.nameToFullPath(name)
    if not ok then
        return ""
    end
    return Util.md5file(fullPath)
end

function DynamicRes.StopSync()
    Tools.StopWebRequest()
    CSCoroutine.Stop(SyncFunction)
end

return DynamicRes