if NetSaveModel then
    return NetSaveModel
end
local Model = _G.Model
local ModelType = _G.ModelType
local Net = _G.Net
local saveInfo = {}
NetSaveModel = {}
NetSaveModel.key = {
    EquipShow = 30009
}

function NetSaveModel.UpdataValue(infos)
    local tempData =  Model.GetMap(ModelType.NetSaveInfo)
    -- for k1,v1 in pairs(infos) do
    --     local need = true
    --     for k2,v2 in pairs(tempData) do
    --         if v2. Id == k1 then
    --             tempData[k2] = {Id = k1,Status = v1}
    --             need = false
    --         end
    --     end
    --     if need then
    --         table.insert(tempData,{Id = k1,Status = v1})
    --     end
    -- end
    for i = 1,#tempData do
        if tempData[i]. Id == infos.Id then
            tempData[i] = infos
        end
    end
    Model.InitOtherInfo(ModelType.NetSaveInfo, tempData)
    saveInfo = {}
end
function NetSaveModel.GetValue(key)
    if saveInfo[key] then
        return saveInfo[key]
    end
    local tempData =  Model.GetMap(ModelType.NetSaveInfo)
    for _,v in pairs(tempData) do
        if v.Id == key then
            saveInfo[key] = v.Status
            return saveInfo[key]
        end
    end
    return nil
end
function NetSaveModel.SetValue(k, v,callback)
    Net.UserInfo.SetSystemSettings(
        k,
        v,
        function (rsp)
            NetSaveModel.UpdataValue(rsp)
            if callback then
                callback(rsp)
            end
        end
    )
end

return NetSaveModel
