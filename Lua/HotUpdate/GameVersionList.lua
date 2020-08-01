local GameVersionList = {
    VersionContent = "",
    VersionList = nil,
    VersionListSize = 0,
    Transfered = 0,
    FileSize = nil,

    totalCount = 0,
    finishedCount = 0,

    totalCopyCount = 0,
    finishedCopyCount = 0,

    totalSize = 0,
    finishedSize = 0,

    localV = nil,
    remote = nil,
    needUpdateFiles = nil,
}

local Tools = import("HotUpdate/Tools/Tools")
--local LFS = require("lfs")

function GameVersionList.New(content)
    local ins = new(GameVersionList)
    ins.VersionContent = content
    local lines = StringUtil.Split(content, '\n')
    ins.VersionList = {}
    ins.FileSize = {}

    for _, line in ipairs(lines) do
        local chunks = StringUtil.Split(line, '=')
        local filename = chunks[1]
        if #chunks == 3 then
            GameVersionList.VersionListSize = GameVersionList.VersionListSize + 1
            ins.VersionList[filename] = chunks[2]
            local size = tonumber(chunks[3])
            ins.FileSize[filename] = size
        elseif filename ~= "" then
            Log.Info("Invalid file info: " .. filename)
        end
    end
    return ins
end

function GameVersionList.Parse(content)
    local list = {}
    local lines = StringUtil.Split(content, '\n')
    for _, line in ipairs(lines) do
        local chunks = StringUtil.Split(line, '=')
        local filename = chunks[1]
        if #chunks == 3 then
            list[filename] = {md5 = chunks[2], size = chunks[3]}
        end
    end
    return list
end

function GameVersionList.StartUpdate(localV, remote)
    GameVersionList.localV = localV
    GameVersionList.remote = remote
    GameVersionList.needUpdateFiles = {}
    local needUpdateCount = 0
    for remoteKey, remoteValue in pairs(remote.VersionList) do
        local relPath = remoteKey
        -- 版本记录一致
        local localMD5 = localV.VersionList[relPath]
        if localMD5 and localMD5 == remoteValue then
            goto next
        end
        -- 比对文件MD5
        local type, fullPath = KResourceModule.GetResourceFullPath(relPath, false, true)
        if type == KResourceModule.GetResourceFullPathType.InDocument then
            if Util.md5file(fullPath) == remoteValue then
                goto next
            end
        end
        -- 添加变动记录
        needUpdateCount  = needUpdateCount + 1
        table.insert(GameVersionList.needUpdateFiles, {k = remoteKey, v = remoteValue})
        GameVersionList.totalSize = GameVersionList.totalSize + remote.FileSize[remoteKey]

        ::next::
    end

    GameVersionList.totalCount = needUpdateCount
    GameVersionList.finishedCount = 0
    Sdk.TrackGameEvent("custom_loss", "generate_download_list", ""..needUpdateCount)
    coroutine.yield(GameVersionList.downloadFiles(GameVersionList.needUpdateFiles))
end

local MaxDownload = 5
function GameVersionList.downloadFiles(files)
    local failedFiles = {}
    local downloading = 0
    local hostUrl = GameVersion.VersionHostUrl()
    local fileSizes = GameVersionList.remote.FileSize
    while true do
        if #files == 0 and downloading == 0 then
            break
        end
        if #files > 0 and downloading < MaxDownload then
            downloading = downloading + 1
            Log.Info("Downloading count: {0}", downloading)
            CSCoroutine.Start(function()
                -- 信息准备
                local kv = table.remove(files)
                local relPath = kv.k
                local url = string.format("%s/%s", hostUrl, relPath)
                local lastDownloaded = 0
                local fileSize = fileSizes[relPath]
                -- 文件下载
                local data, err = Tools.download(url, function(progress)
                    local downloaded = fileSize * progress
                    local incr = downloaded - lastDownloaded
                    if incr > 0 then
                        GameVersionList.finishedSize = GameVersionList.finishedSize + incr
                        lastDownloaded = downloaded
                    end
                end)
                downloading = downloading - 1
                -- 错误检测
                if data == nil then
                    GameVersionList.finishedSize = GameVersionList.finishedSize - lastDownloaded
                    Log.Error("UpdateRes failed: " .. relPath .. " err: " .. err)
                    table.insert(failedFiles, kv)
                    return
                end
                -- MD5校对
                local fullPath = KResourceModule.DocumentPath .. relPath
                Util.WriteFile(fullPath, data)
                local type, fullPath = KResourceModule.GetResourceFullPath(relPath, false, true)
                -- 写入失败
                if type ~= KResourceModule.GetResourceFullPathType.InDocument then
                    Log.Error("Updates failed: {0}, not found in document", relPath)
                    table.insert(failedFiles, kv)
                    return
                end
                -- 写入不完整
                if Util.md5file(fullPath) ~= GameVersionList.remote.VersionList[relPath] then
                    Log.Error("Updates failed: {0}, md5 not match", relPath)
                    table.insert(failedFiles, kv)
                    return
                end
                -- 进度更新
                local incr = fileSize - lastDownloaded
                GameVersionList.finishedSize = GameVersionList.finishedSize + incr
                GameVersionList.finishedCount  = GameVersionList.finishedCount + 1
            end)
        end
        coroutine.yield()
    end

    if GameVersionList.finishedCount == GameVersionList.totalCount then
        Log.Info("UpdateRes finished")
        HULoading.SetLoadingTip("save_versionlist")
        GameVersionList.SetLocalVersionList(GameVersionList.remote.VersionContent)
        HULoading.SetLoadingTip("save_version")
        GameVersion.SetLocalVersion(GameVersion.remote)
    else
        Log.Error("UpdateRes not complete! retrying: {0}", GameVersionList.totalCount - GameVersionList.finishedCount)
        coroutine.yield(UnityEngine.WaitForSeconds(1))
        coroutine.yield(GameVersionList.downloadFiles(failedFiles))
    end
end

--------------------------静默更新下载逻辑
function GameVersionList.StartDownPreUpdate(localV, remote)
    GameVersionList.localV = localV
    GameVersionList.remote = remote
    GameVersionList.needUpdateFiles = {}
    local needUpdateCount = 0
    local filelist = {}
    for remoteKey, remoteValue in pairs(remote.VersionList) do
        local relPath = remoteKey
        -- 版本记录一致
        local localMD5 = localV.VersionList[relPath]
        if localMD5 and localMD5 == remoteValue then
            goto next
        end
        -- 比对文件MD5
        local type, fullPath = KResourceModule.GetResourceFullPath(relPath, false, true)
        if type == KResourceModule.GetResourceFullPathType.InDocument then
            if Util.md5file(fullPath) == remoteValue then
                goto next
            end
        end
        -- 添加变动记录
        needUpdateCount  = needUpdateCount + 1
        table.insert(GameVersionList.needUpdateFiles, {k = remoteKey, v = remoteValue})
        PreHotUpdateRes.list[remoteKey] = {md5=remoteValue, size=remote.FileSize[remoteKey], downloaded=false}
        local fileinfo = {
            md5 = remoteValue,
            size = remote.FileSize[remoteKey],
            name = remoteKey,
        }
        table.insert(filelist, fileinfo)
        GameVersionList.totalSize = GameVersionList.totalSize + remote.FileSize[remoteKey]

        ::next::
    end

    GameVersionList.totalCount = needUpdateCount
    PlayerDataModel.SetLocalData("PRE_UPDATE_COUNT", needUpdateCount)
    print("PRE_UPDATE_COUNT", needUpdateCount)
    GameVersionList.finishedCount = 0
    Util.WriteTextFile(KResourceModule.DocumentPath.."updatelist.txt", JSON.encode(filelist))
    Sdk.TrackGameEvent("custom_loss", "pre_generate_download_list", ""..needUpdateCount)
    if #GameVersionList.needUpdateFiles > 0 then
        GameVersionList.SyncPreHotupdateFiles(GameVersionList.needUpdateFiles)
    end
end

function GameVersionList.SyncPreHotupdateFiles(list)
    print("list-------------", table.inspect(list))
    for _, name in ipairs(list) do
        local downloading, fullPath = PreHotUpdateRes.checkDownloading(name)
        if not downloading then
            PreHotUpdateRes.downloadings[fullPath] = {
                updatedAt = os.time(),
            }
            PreHotUpdateRes.downloadPreHotUpdateFile(name, fullPath)
        end
    end
    CSCoroutine.Start(function()
        coroutine.yield(UnityEngine.WaitForSeconds(180))
        coroutine.yield(PreHotUpdateRes.CheckDownloadComplete(list))
    end)
end

-- 转移包内资源
function GameVersionList.TransferFiles()
    local batchLimit = 10
    local list = GameVersionList.GetInAppVersionList()
    for filename, md5 in pairs(list.VersionList) do
        ResMgr.CopyFile(filename)
        local type, fullPath = KResourceModule.GetResourceFullPath(filename, false, true)
        if type == KResourceModule.GetResourceFullPathType.InDocument then
            if Util.md5file(fullPath) == md5 then
                GameVersionList.Transfered = GameVersionList.Transfered + 1
            end
        end
        if GameVersionList.Transfered % batchLimit == 0 then
            coroutine.yield()
        end
    end
    if GameVersionList.Transfered ~= GameVersionList.VersionListSize then
        coroutine.yield(UnityEngine.WaitForSeconds(1))
        coroutine.yield(GameVersionList.TransferFiles())
    else
        GameVersionList.SetLocalVersionList(list.VersionContent)
        GameVersion.SetTransferVersion()
    end
end

--[[function GameVersionList.Attrdir(path)
    for file in LFS.dir(path) do
        if file ~= "." and file ~= ".." then  ----过滤linux目录下的"."和".."目录
        local f = path.. '/' ..file
            local attr = LFS.attributes (f)
            if attr.mode == "directory" then
                print(f .. "  -->  " .. attr.mode)
                attrdir(f)       --如果是目录，则进行递归调用
            else
                print(f .. "  -->  " .. attr.mode)
            end
        end
    end
end]]--

function GameVersionList.TransferPreHotUpdateFiles()
    --GameVersionList.Attrdir("KResourceModule.BundlesPathRelative")
    Log.Error("GameVersionList.TransferPreHotUpdateFiles")
    local batchLimit = 10
    ----local listByte = ResMgr.LoadFileBytes("updatelist.txt", true)
    --print("listByte------------", listByte)
    --local listString = GameVersion.Trim(listByte)
    local listString = ResMgr.LoadFileBytes("updatelist.txt", true) 
    print("listString----------", listString)
    local filelist = JSON.decode(listString)
    print("filelist----------", table.inspect(filelist))
    for _, value in pairs(filelist) do
        print("value-------------", value)
        if value ~= "" then
            --local lines = StringUtil.Split(value.name, '/')
            --print("lines------------", table.inspect(lines))
            local sourcePath = "PreHotUpdate/"..value.name
            print("sourcePath--------", sourcePath)
            local destPath = KResourceModule.DocumentPath..value.name
            print("destPath---------", destPath)
            local data = ResMgr.LoadFileBytes(sourcePath, true)
            Util.WriteFile(destPath, data)
            local type, fullPath = KResourceModule.GetResourceFullPath(value.name, false, true)
            print("type, fullPath", type, fullPath)
            if type == KResourceModule.GetResourceFullPathType.InDocument then
                if Util.md5file(fullPath) == value.md5 then
                    print("++++++++++++++++++++++++++", GameVersionList.Transfered)
                    GameVersionList.Transfered = GameVersionList.Transfered + 1
                end
            end
            if GameVersionList.Transfered % batchLimit == 0 then
                coroutine.yield()
            end
        end
    end
    
    if GameVersionList.Transfered ~= GameVersionList.VersionListSize then
        coroutine.yield(UnityEngine.WaitForSeconds(1))
        coroutine.yield(GameVersionList.TransferFiles())
    else
        --GameVersionList.SetLocalVersionList(GameVersionList.remote.VersionContent)
        Log.Error("Transfer finished~!!!!!!!!!!!!!!")
        Util.DeleteDir(KResourceModule.DocumentPath.."PreHotUpdate")
        PlayerDataModel.SetLocalData("PRE_UPDATE_FINISHED", "false")
        --GameVersion.SetTransferVersion()
    end
end

-- 获取安装包版本文件列表
function GameVersionList.GetInAppVersionList()
    local content = ResMgr.LoadAndUnzipInAppFile(GameVersionList.versionListPath())
    return GameVersionList.New(content)
end

function GameVersionList.GetLocalVersionList()
    local content = ResMgr.LoadAndUnzipFile(GameVersionList.versionListPath())
    return GameVersionList.New(content)
end

function GameVersionList.SetLocalVersionList(content)
    ResMgr.WriteDocFile(GameVersionList.versionListPath(), Util.Zip(content))
end

function GameVersionList.versionListPath()
    return KResourceModule.BundlesPathRelative..GameVersion.VersionListFileName
end

return GameVersionList