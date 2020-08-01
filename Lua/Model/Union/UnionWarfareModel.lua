--[[
    author:{zhanzhang}
    time:2019-07-11 17:10:29
    function:{联盟战争相关model}
]]
--------------------------------联盟战争信息----------------------------------------------------------------------
local UnionWarfareModel = {}
---------------联盟集结进攻
local attackBattleInfoList = {} --进攻战争列表
local attackMissionlist = {} --进攻行军列表

local defenceList = {}
local missionList = {}
--------------------初始化集结进攻信息------------------------------------------
function UnionWarfareModel.SetUnionWarfareInfo(rsp)
    ---------------------------------设置联盟进攻
    attackBattleInfoList = rsp.Battles
    defenceList = rsp.Defences
    missionList = rsp.Missions
end

---获取进攻战争列表-------------------------------
function UnionWarfareModel.GetUnionAttackList()
    return attackBattleInfoList
end

---获取进攻战争行军队列
function UnionWarfareModel.GetUnionAttackMissionList()
    return attackMissionlist
end

function UnionWarfareModel.GetDenfenceList()
    return defenceList
end

function UnionWarfareModel.GetBattleInfoById(id)
    for _,v in pairs(attackBattleInfoList) do
        if v.Uuid == id then
            return v
        end
    end
end

function UnionWarfareModel.GetMissionListByBattleId(Id)
    local list = {}
    for i = 1, #missionList do
        if missionList[i].AllianceBattleId == Id then
            table.insert(list, missionList[i])
        end
    end
    return list
end

--检测集结是否由我发起
function UnionWarfareModel.CheckWarIsMy(battleId)
    for i = 1, #attackBattleInfoList do
        if attackBattleInfoList[i].Uuid == battleId and attackBattleInfoList[i].UserId == Model.Account.accountId then
            return true
        end
    end
end

--检查我是否在集结里
function UnionWarfareModel.CheckInWar(battleId)
    for _,v in pairs(missionList) do
        if v.AllianceBattleId == battleId and v.UserId == Model.Account.accountId then
            return true
        end
    end
end

function UnionWarfareModel.AddMission(mission)
    table.insert(missionList, mission)
end

function UnionWarfareModel.RefreshMission(mission)
    for i = 1, #missionList do
        if missionList[i].Uuid == mission.Uuid then
            missionList[i] = mission
            return
        end
    end

    table.insert(missionList, mission)
end

function UnionWarfareModel.AddAttackBattle(battle)
    table.insert(attackBattleInfoList, battle)
end

function UnionWarfareModel.RemoveAttackBattle(uuid)
    for k,v in pairs(attackBattleInfoList) do
        if v.Uuid == uuid then
            table.remove(attackBattleInfoList, k)
            return
        end
    end
end

function UnionWarfareModel.AddDefendBattle(battle)
    table.insert(defenceList, battle)
end

function UnionWarfareModel.RemoveDefendBattle(uuid)
    for k,v in pairs(defenceList) do
        if v.Uuid == uuid then
            table.remove(defenceList, k)
            return
        end
    end
end

function UnionWarfareModel.RemoveMission(Uuid)
    if missionList then
        for k,v in pairs(missionList) do
            if v.Uuid == Uuid then
                table.remove(missionList, k)
            end
        end
    end
end

function UnionWarfareModel.RefreshBattleFinishAt(battleId, finishAt)
    for _,v in pairs(attackBattleInfoList) do
        if v.Uuid == battleId then
            v.FinishAt = finishAt
            return
        end
    end

    for _,v in pairs(defenceList) do
        if v.Uuid == battleId then
            v.FinishAt = finishAt
            return
        end
    end
end

return UnionWarfareModel
