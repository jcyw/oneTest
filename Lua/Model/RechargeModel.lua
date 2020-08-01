local RechargeModel = {}
local goldDatas = {}
function RechargeModel.GetRechargeDatas()
    local purchase = ConfigMgr.GetList("configDiamonds")
    if not purchase then
        return
    end
    table.sort(
        purchase,
        function(a, b)
            return a.id < b.id
        end
    )
    for _, v in ipairs(purchase) do
        goldDatas[v.id] = v
    end
    return purchase
end

--设置钻石充值数据
function RechargeModel.SetGoldData(configId, isRefresh)
    if goldDatas[configId] then
        goldDatas[configId].isPayed = isRefresh
    end
end


--设置钻石数据
function RechargeModel.SetGoldDataLogin(boughtGemIds)
    for _, v in ipairs(boughtGemIds) do
        if goldDatas[v] then
            RechargeModel.SetGoldData(v, true)
        end
    end
end

--得到充值数据
function RechargeModel.GetGoldData()
    return goldDatas
end

function RechargeModel.GetGoldDataById(Id)
    if goldDatas[Id] then
        return goldDatas[Id]
    end
end

return RechargeModel
