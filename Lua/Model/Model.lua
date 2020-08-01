if Model then
    return Model
end

Model = {}

function Model.GetPlayer()
    return Model.Player
end

function Model.InitPlayer(user)
    Model.Player = user
end

function Model.Init(name, idName, datas)
    local gd = Model
    gd[name] = {}
    for _, v in ipairs(datas) do
        gd[name][v[idName]] = v
    end
end

function Model.UpdateList(name, idName, datas)
    local gd = Model
    gd[name] = gd[name] or {}
    for _, v in ipairs(datas) do
        gd[name][v[idName]] = v
    end
end

function Model.Find(name, id)
    local datas = Model[name]
    if datas then
        return datas[id]
    else
        return nil
    end
end

function Model.GetMap(name)
    return Model[name]
end

function Model.Update(name, id, kv)
    local data = Model.Find(name, id)
    if data then
        for k, v in pairs(kv) do
            if k ~= id then
                data[k] = v
            end
        end
    end
end

function Model.Delete(name, id)
    Model[name][id] = nil
end

function Model.Clear(name)
    Model[name] = {}
end

function Model.Create(name, id, data)
    if not Model[name] then
        Model[name] = {}
    end
    Model[name][id] = data
end

function Model.InitOtherInfo(name, data)
    Model[name] = data
end

function Model.GetInfo(name, id)
    local list = Model[name]
    if list[id] ~= nil then
        return list[id]
    end
    return nil
end

return Model
