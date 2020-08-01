--[[
    author={zhanzhang}
    time=2020-03-17 21=06=32
    function={行军管理Model}
]]
local MarchManagerModel = {}
local MarchAnimModel = import("Model/MarchAnimModel")
local MarchLineModel = import("Model/MarchLineModel")
local RadarModel = import("Model/RadarModel")

--缓存
local showMarchCacheList = {}
local hideMarchList = {}
local otherAISiege = {}
local lookAtUuid

function MarchManagerModel.OnRefresh(list)
    --系统设置隐藏别的路线
    local isHideOther = SystemSetModel.GetSetting(30008)
    MarchManagerModel.RefreshOtherAISiege()
    if #list == 0 then
        return
    end

    local info
    for k, line in pairs(list) do
        if line.Category == Global.MissionAISiege and line.TargetAllianceId ~= Model.Player.AllianceId then
            otherAISiege[line.Uuid] = line
            if isHideOther then
                list[k] = nil
                hideMarchList[line.Uuid] = line
            end
        else
            -----攻击返程的行军先缓存，待攻击动画结束后在执行
            local isAttack = MarchAnimModel.IsAttacking(line)
            if isAttack then
                list[k] = nil
                hideMarchList[line.Uuid] = line
                MarchLineModel.CacheAttackLine(line)
            end
        end
        if line.Category == Global.MissionHunt and line.StopPointSize == -1 and line.OwnerId ~= Model.Account.accountId then
            list[k] = nil
        end
    end

    for _, v in pairs(list) do
        showMarchCacheList[v.Uuid] = v
    end

    MarchLineModel.OnRefresh(list)
    MarchAnimModel.OnRefresh(list)
end

function MarchManagerModel.ShowOtherAISiege()
    for k, v in pairs(otherAISiege) do
        MarchLineModel.CreateLine(v)
        MarchAnimModel.CreateRoute(v)
    end
end

function MarchManagerModel.HideOtherAISiege()
    for k, v in pairs(otherAISiege) do
        MarchLineModel.DelMarchLine(k)
        MarchAnimModel.DelMarchAnim(k)
    end
end

function MarchManagerModel.RefreshOtherAISiege()
    local isHideOther = SystemSetModel.GetSetting(30008)
    if isHideOther then
        MarchManagerModel.HideOtherAISiege()
    else
        MarchManagerModel.ShowOtherAISiege()
    end
end

function MarchManagerModel.DelMarchInfo(key, isMustDel)
    showMarchCacheList[key] = nil
    hideMarchList[key] = nil
    otherAISiege[key] = nil
    MarchAnimModel.DelMarchAnim(key, isMustDel)
    MarchLineModel.DelMarchLine(key)
end

function MarchManagerModel.GetMarchCategory(key)
    local data = showMarchCacheList[key]
    if not data then
        return Global.MissionAttack
    end

    return data.category
end

function MarchManagerModel.IsAISiegeOrNo(key)
    local data = showMarchCacheList[key]
    if not data then
        return true
    end
    return data.category == Global.MissionAISiege
end

--获取战斗坐标
function MarchManagerModel.GetBattlePoint(key)
    local data = showMarchCacheList[key]
    if not data.StartPointSize or not data.StopPointSize then
        Log.Error("出错了")
    end
    local startX, startY, stopX, stopY = MapModel.GetMarchPoint(data)
    return stopX, stopY, data.StopPointSize
end

--获取战斗巨兽信息
--0为无巨兽
--1为哥斯拉
--2为金刚
function MarchManagerModel.GetMarchMonster(rsp)
    if not showMarchCacheList[rsp.EventId] then
        return
    end
    for _, v in pairs(showMarchCacheList[rsp.EventId].ArmyTypes) do
        if v == 620 then
            return 1
        elseif v == 621 then
            return 2
        end
    end
    return 0
end

function MarchManagerModel.GetMarchLine(key)
    return showMarchCacheList[key]
end

return MarchManagerModel
