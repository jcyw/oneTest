Net.CrossServer = {}

-- 请求-请求服务器简略信息
function Net.CrossServer.GetServerSimpleInfo(...)
    Network.RequestDynamic("GetServerSimpleInfoParams", {}, ...)
end

-- 请求-请求服务器列表
function Net.CrossServer.GetServerList(...)
    Network.RequestDynamic("GetServerListParams", {}, ...)
end

return Net.CrossServer