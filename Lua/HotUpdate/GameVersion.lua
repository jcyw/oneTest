import("Utils/StringUtil")

local GameVersion = {
    String = "",
    StageFileName = "stage",
    VersionFileName = "version.txt",
    VersionListFileName = "version_list",
    TransferedVersionFileName = "transfered_version.txt",

    Main = 0,
    Sub = 0,
    Fix = 0,
    
    localV = nil,
    remote = nil,
}

local _platform = ""
local _isWindowsOrEditor
function GameVersion.IsWindows()
    if _isWindowsOrEditor then
        return _isWindowsOrEditor
    end
    if _platform == "" then
        _platform = KSUtil.GetPlayformStr()
    end
    if _platform == "WINDOWS" then
        _isWindowsOrEditor = true
    end
    return _isWindowsOrEditor
end

function GameVersion.VersionHost()
    if GameVersion.IsWindows() then
        return "http://172.16.31.126:8081/hotfix/"..string.lower(GateConfig.GetStage())
    else
        if GateConfig.GetStage() == "Production" and Auth.IsWhiteDevice() then
		    return "http://mrwjres-global.hwrescdn.com/hotfix/white_production"
        else
            return GateConfig.HotUpdateUrl()
        end
    end
end

function GameVersion.VersionFileUrl()
    return GameVersion.VersionHost() .. "/" .. GameVersion.VersionFileName
end

function GameVersion.VersionHostUrl()
    return GameVersion.VersionHost().."/"..GameVersion.remote
end

function GameVersion.VersionListUrl()
    return GameVersion.VersionHostUrl().."/"..KResourceModule.BundlesPathRelative..GameVersion.VersionListFileName
end

function GameVersion.New(version)
    version = GameVersion.Trim(version)
    local ins = new(GameVersion)
    ins.String = version
    version = string.gsub(version, "%.", ",")
    local chunks = StringUtil.Split(version, ',')
    ins.Main = math.floor(tonumber(chunks[1]))
    ins.Sub = math.floor(tonumber(chunks[2]))
    ins.Fix = math.floor(tonumber(chunks[3]))
    return ins
end

function GameVersion:Compare(otherVersion)
    if self:isUpdateApp(otherVersion) then
        return "UpdateApp"
    end
    if self:isUpdateRes(otherVersion) then
        return "UpdateRes"
    end
    return "Past"
end

-- 获取已更新版本
function GameVersion.GetLocalVersion()
    local version = ResMgr.LoadFileBytes(GameVersion.VersionFileName)
    return GameVersion.New(version)
end

function GameVersion.GetInAppVersion()
    local version = ResMgr.LoadInAppFileBytes(GameVersion.VersionFileName)
    return GameVersion.New(version)
end

function GameVersion.SetLocalVersion(content)
    local fullPath = KResourceModule.DocumentPath .. GameVersion.VersionFileName
    Util.WriteTextFile(fullPath, content)
end

function GameVersion.NeedTransfer()
    local path = GameVersion.TransferedVersionFileName
    local ok, fullPath = KResourceModule.TryGetDocumentResourceUrl(path, false)
    if not ok then
        return true
    end
    local version = ResMgr.LoadFileBytes(path, true)
    local inAppVersion = ResMgr.LoadInAppFileBytes(GameVersion.VersionFileName)
    Log.Info("NeedTransfer inAppVersion: {0}, transferedVersion: {1}", inAppVersion, version)
    return GameVersion.Trim(version) ~= GameVersion.Trim(inAppVersion)
end

function GameVersion.SetTransferVersion()
    local inAppVersion = ResMgr.LoadInAppFileBytes(GameVersion.VersionFileName)
    local fullPath = KResourceModule.DocumentPath .. GameVersion.TransferedVersionFileName
    Util.WriteTextFile(fullPath, GameVersion.Trim(inAppVersion))
    GameVersion.SetLocalVersion(inAppVersion)
end

--[[
    什么时候需要删老资源?
    首次安装: 无需转移（无transfered_version.txt）
    已经覆盖：无需转移（transfered_version.txt和inapp一致）
    覆盖安装：删除热更目录(transfered_version.txt和inapp的不一致)
]]
function GameVersion.CheckDelOldRes()
    local path = GameVersion.TransferedVersionFileName
    local ok, fullPath = KResourceModule.TryGetDocumentResourceUrl(path, false)
    -- 首次安装
    if not ok then
        return
    end
    -- 已经覆盖
    local version = ResMgr.LoadFileBytes(path, true)
    local inAppVersion = ResMgr.LoadInAppFileBytes(GameVersion.VersionFileName)
    Log.Info("CheckDelOldRes inAppVersion: {0}, installedVersion: {1}", inAppVersion, version)
    if GameVersion.Trim(version) == GameVersion.Trim(inAppVersion) then
        return
    end
    -- 覆盖安装
    Sdk.TrackGameEvent("custom_loss", "resource_decompression1_begin", "1")
    -- 删除version_list
    Util.DeleteFile(GameVersionList.versionListPath())
    -- 删除Bundles
    Util.DeleteDir(KResourceModule.DocumentPath.."Bundles")
    GameVersion.SetTransferVersion()
    Sdk.TrackGameEvent("custom_loss", "resource_decompression1_end", "1")
end

function GameVersion:isUpdateApp(otherVersion)
    return self.Main < otherVersion.Main
end

function GameVersion:isUpdateRes(otherVersion)
    if self.Main > otherVersion.Main then
        return false
    end
    if self.Sub < otherVersion.Sub then
        return true
    end
    if self.Sub > otherVersion.Sub then
        return false
    end
    return self.Fix < otherVersion.Fix
end

function GameVersion.Trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
 end

return GameVersion