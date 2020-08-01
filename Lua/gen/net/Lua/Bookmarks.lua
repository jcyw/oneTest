Net.Bookmarks = {}

-- 请求-添加书签
function Net.Bookmarks.Add(...)
    local fields = {
        "Category", -- int32
        "Name", -- string
        "X", -- int32
        "Y", -- int32
    }
    Network.RequestDynamic("BookmarkAddParams", fields, ...)
end

-- 请求-编辑书签
function Net.Bookmarks.Edit(...)
    local fields = {
        "BookmarkId", -- int32
        "Category", -- int32
        "Name", -- string
    }
    Network.RequestDynamic("BookmarkEditParams", fields, ...)
end

-- 请求-删除书签
function Net.Bookmarks.Del(...)
    local fields = {
        "BookmarkIds", -- array-int32
    }
    Network.RequestDynamic("BookmarkDelParams", fields, ...)
end

-- 请求-分享坐标
function Net.Bookmarks.Share(...)
    local fields = {
        "Channel", -- int32
        "Category", -- int32
        "ConfId", -- int32
        "X", -- int32
        "Y", -- int32
    }
    Network.RequestDynamic("BookmarkShareParams", fields, ...)
end

-- 请求-添加联盟标记
function Net.Bookmarks.AddAlliance(...)
    local fields = {
        "Category", -- int32
        "Name", -- string
        "X", -- int32
        "Y", -- int32
    }
    Network.RequestDynamic("BookmarkAddAllianceParams", fields, ...)
end

-- 请求-删除联盟标记
function Net.Bookmarks.DelAlliance(...)
    local fields = {
        "Category", -- int32
    }
    Network.RequestDynamic("BookmarkDelAllianceParams", fields, ...)
end

return Net.Bookmarks