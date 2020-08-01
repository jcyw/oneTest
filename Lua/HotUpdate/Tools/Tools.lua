local Tools = {
    downloadings = {} -- 任务列表
}

-- 在协程里使用
function Tools.download(url, progress)
    -- 下载资源
    local reqConnect = UnityWebRequest.Get(url)
    Tools.downloadings[url] = reqConnect
    reqConnect:SendWebRequest()
    while not reqConnect.isDone do
        -- 下载进度0.0-1.0
        if progress and reqConnect.downloadProgress then
            progress(reqConnect.downloadProgress)
        end
        coroutine.yield()
    end
    -- 错误检测
    Tools.downloadings[url] = nil
    if reqConnect.isHttpError or reqConnect.isNetworkError then
        Log.Error("download failed: " .. url .. " err: " .. reqConnect.error)
        return nil, reqConnect.error
    end
    -- 成功回调
    return reqConnect.downloadHandler.data, nil
end

function Tools.StopWebRequest()
    for key, reqConnect in pairs(Tools.downloadings) do
        reqConnect:Abort()
    end
end

return Tools