--[[
    author:{zhanzhang}
    time:2019-06-26 19:05:38
    function:{攻击预警Model}
]]
if RadarModel then
    return RadarModel
end
local RadarModel = {}
local Model = import("Model/Model")
local ModelType = import("Enum/ModelType")

function RadarModel.AddItem(data)
    local temp = Model.GetMap(ModelType.MarchWarnings)
    temp[data.Uuid] = data
    Event.Broadcast(EventDefines.UIOnRaderEvent)
end

function RadarModel.DeleteItem(uuid)
    local temp = Model.GetMap(ModelType.MarchWarnings)
    temp[uuid] = nil
    Event.Broadcast(EventDefines.UIOnRaderEvent)
end

function RadarModel.GetList()
    local temp = Model.GetMap(ModelType.MarchWarnings)
    local list = {}
    local time = Tool.Time()
    for key, val in pairs(temp) do
        if val.ArriveAt <= time then
            temp[key] = nil
        else --if (not val.Ignore) then
            table.insert(list, val)
        end
    end
    return list
end

function RadarModel.IgnoreAll()
    local list = Model.GetMap(ModelType.MarchWarnings)
    for _, val in pairs(list) do
        val.Ignore = true
    end
    Event.Broadcast(EventDefines.UIOnRaderEvent)
end

function RadarModel.IgnoreItem(key)
    local list = Model.GetMap(ModelType.MarchWarnings)
    if (list[key]) then
        list[key].Ignore = true
    end
    Event.Broadcast(EventDefines.UIOnRaderEvent)
end

--检测警报状态
function RadarModel.CheckWarning()
    local list = Model.GetMap(ModelType.MarchWarnings)
    -- local id = ConfigMgr.GetVar(MissionType.MissionAttack)
    --进攻状态且没有忽略才会开启警报状态
    for _, val in pairs(list) do
        if (val.Category == Global.MissionAttack or val.Category == Global.MissionSpy or val.Category == Global.MissionAISiege) and not val.Ignore then
            return true
        end
    end
    return false
end

--检测被援助状态
function RadarModel.CheckAssit()
    local list = Model.GetMap(ModelType.MarchWarnings)
    -- local id = ConfigMgr.GetVar(MissionType.MissionAssit)
    --进攻状态且没有忽略才会开启警报状态
    for _, val in pairs(list) do
        if (val.Category == Global.MissionAssit and not val.Ignore) then
            return true
        end
    end
    return false
end

--获取进攻部队数
function RadarModel.GetWarningNum()
    local result = 0
    local list = Model.GetMap(ModelType.MarchWarnings)
    for _, v in pairs(list) do
        if v.Category == Global.MissionAttack or v.Category == Global.MissionSpy or v.Category == Global.MissionAISiege then
            result = result + 1
        end
    end
    return result
end

--获取增益部队数
function RadarModel.GetAssitNum()
    local result = 0
    local list = Model.GetMap(ModelType.MarchWarnings)
    for _, v in pairs(list) do
        if v.Category == Global.MissionAssit then
            result = result + 1
        end
    end
    return result
end

--检测行军类型
function RadarModel.GetMissionType(category)
    return "未知"
end

return RadarModel
