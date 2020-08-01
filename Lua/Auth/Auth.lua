if Auth then
    return Auth
end

Auth = {
    WorldData = {},
}

Auth.UpdateType = {
    UpdateTypeNoUpdate = 0,             --不更新
    UpdateTypeForceUpdate = 1,          --强制更新
    UpdateTypePreHotUpdate = 2,         --静默下载
    UpdateTypeHotUpdate = 3,            --正常热更
}

function Auth.LoginWorld(uid, timeStamp, sign, url, port, serverId, success, failed)
    local data = JSON.encode({
        uid = uid,
        timeStamp = timeStamp,
        sign = sign,
        device = Util.GetDevice(),
        device_os = Util.GetDeviceOS(),
        device_id = Util.GetDeviceId(),
        device_memory = Util.GetDeviceMemory(),
        server_id = serverId,
        version = GameVersion.GetLocalVersion().String,
        pkg_version = GameVersion.GetInAppVersion().String,
    })
    NetworkManager.Instance:PostJson(url .. "/auth/"..port, data, function(error, rsp)
        if (error ~= "" or rsp == "") and failed then
            Log.Error("LoginWorld failed: {0} -> {1}", error, rsp)
            failed(error)
            return
        end
        local serverInfo
        local updateType
        local decoded = pcall(function()
            serverInfo = JSON.decode(rsp)
            updateType = serverInfo.UpdateType
        end)
        if not decoded and failed then
            Log.Error("LoginWorld Invalid Rsp: {0}", rsp)
            failed("invalid rsp")
            return
        end
        if serverInfo.status == "failed" and failed then
            Log.Error("serverInfo.status failed: {0}", serverInfo)
            failed(serverInfo)
            return
        end
        
        -- 保存ABTest信息
        ABTest.SaveIds(serverInfo.abGroupIds)
        HotUpdate.SetUpdateType(updateType)
        local data = Auth.SaveServerData(serverInfo, url)
        success(data)
        end)
end

function Auth.SaveServerData(serverInfo, gate)
    local data = Auth.WorldData
    data.accountId = serverInfo.accountId
    data.connectHost = serverInfo.connectHost
    data.port = serverInfo.port
    data.token = serverInfo.sessionToken
    data.sceneId = serverInfo.sceneId
    data.gate = gate
    data.isWhiteDevice = serverInfo.isWhiteDevice
    data.isDown = serverInfo.isDown
    data.downTime = serverInfo.downTime
    return data
end

function Auth.IsWhiteDevice()
    return Auth.WorldData.isWhiteDevice
end

return Auth
