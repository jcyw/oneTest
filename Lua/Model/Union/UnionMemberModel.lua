--[[
    Author: songzeming
    Function: 联盟成员缓存
]]
local UnionMemberModel = {}
local Members = {} --联盟成员
local Applys = {} --申请入盟成员 [仅R4以上职位可查看]
local ApllyOfficers = {} --申请联盟官员

--------------------------------------------------------- 联盟成员
--获取自己联盟成员列表 格式[k,v]
function UnionMemberModel.GetMembers()
    return Members
end

--设置自己成员列表 [仅初始化设置] 格式[k,v]
function UnionMemberModel.SetMembers(members)
    Members = {}
    for _, v in pairs(members) do
        Members[v.Id] = v
    end
end

--新增联盟成员/成员职位变化
function UnionMemberModel.AddMember(member)
    Members[member.Id] = member
end
--移除联盟成员
function UnionMemberModel.DelMember(id)
    if not Members[id] then
        return
    end
    Members[id] = nil
end
--退出联盟/解散联盟/被开除联盟
function UnionMemberModel.ClearMember()
    Model.Player.AllianceId = ''
    Model.Player.AllianceName = ''
    Model.Player.AlliancePos = 0
    Members = {}
end

--格式化成员列表
function UnionMemberModel.FormatMembers(members)
    if not members then
        members = Members
    end
    local t = {}
    t[0] = Applys
    for i = 1, 5 do
        t[i] = {}
    end
    for _, v in pairs(members) do
        table.insert(t[v.Position], v)
    end
    return t
end

--------------------------------------------------------- 申请入盟成员
--设置申请入盟成员成员 格式[k,v]
function UnionMemberModel.SetApplys(applys)
    Applys = {}
    for _, v in pairs(applys) do
        v.Id = v.UserId
        table.insert(Applys, v)
    end
end

--------------------------------------------------------- 申请联盟官员
--设置申请联盟官员 格式[k,v]
function UnionMemberModel.SetApplyOfficers(applys)
    ApllyOfficers = {}
    for _, v in pairs(applys) do
        ApllyOfficers[v.UserId] = v
    end
end

--获取所以申请联盟官员
function UnionMemberModel.GetApplyOfficers()
    return ApllyOfficers
end

--获取指定申请联盟官员
function UnionMemberModel.GetApplyOfficersByOfficer(officer)
    local officers = {}
    for _, v in pairs(ApllyOfficers) do
        if officer == v.Officer then
            officers[v.UserId] = v
        end
    end
    return officers
end

return UnionMemberModel
