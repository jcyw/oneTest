--[[
    author:{zhanzhang}
    time:2020-01-14 17:44:08
    function:{function}
]]
if ClientRes then
    return ClientRes
end

ClientRes = {}
--通过ID获取路径
function ClientRes.GetResPathById(id)
    return string.lower(ConfigMgr.GetItem("configResourcePaths", id).resPath)
end
--获取一个功能模块包含的资源路径
function ClientRes.GetResListPathByType(modelIndex)
    local list = {}
    local config = ConfigMgr.GetList("configResourcePaths")
    for k, v in pairs(config) do
        if v.belong == modelIndex then
            table.insert(v)
        end
    end
    return list
end

return ClientRes
