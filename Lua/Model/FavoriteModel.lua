--[[
    author:{zhanzhang}
    time:2019-06-03 19:56:48
    function:{收藏夹model}
]]
--军队Model
local FavoriteModel = {}
local Model = import("Model/Model")
local handleList = {}
--
function FavoriteModel.GetItemByType(showType)
    local list = Model.GetMap(ModelType.Bookmarks)
    --全部

    --朋友
    local selectList = {}
    if showType == Global.CoordinateShareAllianceMark then
        local list = Model.GetMap(ModelType.AllianceBookmarks)
        for _, v in pairs(list) do
            table.insert(selectList, v)
        end
    else
        --标记
        for k, v in pairs(list) do
            v.isSelect = (handleList[k])
            if (showType == FavoriteType.All or v.Category == showType) then
                table.insert(selectList, v)
            end
        end
    end
    table.sort(
        selectList,
        function(a, b)
            return a.CreatedAt > b.CreatedAt
        end
    )

    return selectList
end

function FavoriteModel:GetAllCount()
    local list = Model.GetMap(ModelType.Bookmarks)
    local count = 0
    for k, v in pairs(list) do
        count = count + 1
    end
    return count .. "/" .. Global.MapMarkLimit
end

--刷新收藏
function FavoriteModel.RefreshItem(info)
    local list = Model.GetMap(ModelType.Bookmarks)
    list[info.Id] = info
end
--点击全选
function FavoriteModel.SetItem(isSelect, mType)
    local list = Model.GetMap(ModelType.Bookmarks)
    for k, v in pairs(list) do
        if (mType == FavoriteType.All or v.Category == mType) then
            handleList[k] = isSelect
        end
    end
end

function FavoriteModel.ChangeSelect(id, isSelet)
    if not handleList then
        handleList = {}
    end

    handleList[id] = isSelet
end

function FavoriteModel.ClearSelect()
    handleList = {}
end

--获取删除列表
function FavoriteModel.GetDelList(mType)
    local list = Model.GetMap(ModelType.Bookmarks)
    local delList = {}
    for k, v in pairs(list) do
        if ((mType == FavoriteType.All or v.Category == mType) and handleList[k]) then
            table.insert(delList, v.Id)
        end
    end
    return delList
end

--删除单个收藏
function FavoriteModel.DelItem(id)
    local list = Model.GetMap(ModelType.Bookmarks)
    --标记
    for k, v in pairs(list) do
        if (v.Id == id) then
            list[k] = nil
        end
    end
end

function FavoriteModel.DelList(delList)
    for i = 1, #delList do
        FavoriteModel.DelItem(delList[i])
    end
end

function FavoriteModel.IsFavorite(posNum)
    local list = Model.GetMap(ModelType.Bookmarks)
    if (list[posNum]) then
        return true
    else
        return false
    end
end
--获取当前地块联盟标记
function FavoriteModel.GetUnionSign(posNum)
    local list = Model.GetMap(ModelType.AllianceBookmarks)
    local posX, posY = MathUtil.GetCoordinate(posNum)
    for _, v in pairs(list) do
        if v.X == posX and v.Y == posY then
            return v
        end
    end

    return nil
end

function FavoriteModel.GetUnionSignByType(index)
    local list = Model.GetMap(ModelType.AllianceBookmarks)
    -- for i = 1, #list do
    --     if list[i].Category == index then
    --         return list[i]
    --     end
    -- end
    -- return nil
    return list[index]
end

--当前页面是否全选
function FavoriteModel.IsAllSelect(showType)
    local list = FavoriteModel.GetItemByType(showType)
    for i = 1, #list do
        if not list[i].isSelect then
            return false
        end
    end
    return true
end

return FavoriteModel
