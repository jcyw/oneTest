local InvestActivityModel = {}

function InvestActivityModel:GetInvestList(params)
    self.inverstList = {}
    for i, v in pairs(params.Infos) do
        local item = ConfigMgr.GetItem("configInvestActivitys", v.Category)
        item.Status = v.Status
        table.insert(self.inverstList, item)
    end
    table.sort(
        self.inverstList,
        function(a, b)
            return a.id < b.id
        end
    )
    return self.inverstList
end

function InvestActivityModel:GetInvsetItem(id)
    local item = {}
    for i, v in pairs(self.inverstList) do
        if (v.id == id) then
            item = v
        end
    end
    return item
end
function InvestActivityModel:GetListData()
    return self.inverstList
end
function InvestActivityModel:IsInvesting()
    for i, v in pairs(self.inverstList) do
        if v.Status == 2 then
            return true
        end
    end
    return false
end
return InvestActivityModel
