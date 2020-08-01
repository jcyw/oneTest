--[[
    Author: songzeming
    Function: 联盟信息缓存
]]
local UnionInfoModel = {}
local Info = {} --联盟信息
local Permissions = {} --联盟权限

--------------------------------------------------------- 联盟信息
--获取自己联盟信息
function UnionInfoModel.GetInfo()
    return Info
end

--设置自己联盟信息
function UnionInfoModel.SetInfo(info)
    Info = info
    --加入或者创建联盟 天选之人失效
    Model.Player.IsGodLike = false
    --是否已经加入(创建)过联盟
    Model.Player.FirstJoinUnion = false
end

--清空联盟信息
function UnionInfoModel.ClearInfo()
    Info = {}
end
--------------------------------------------------------- 联盟权限
--获取联盟权限
function UnionInfoModel.GetPermissions()
    return Permissions
end

--设置联盟权限
function UnionInfoModel.SetPermissions(p)
    Permissions = p
end

--清空联盟权限
function UnionInfoModel.ClearPermissions()
    Permissions = {}
end

--是否被限制联盟权限
function UnionInfoModel.CheckPermissions(id, position)
    for _, v in pairs(Permissions) do
        if v.Permission == id and v.Position == position then
            return true
        end
    end
    return false
end

return UnionInfoModel
