Net.MiniMap = {}

-- 请求-请求缩略图信息
function Net.MiniMap.GetMiniMapInfo(...)
    Network.RequestDynamic("GetMiniMapInfoParams", {}, ...)
end

return Net.MiniMap