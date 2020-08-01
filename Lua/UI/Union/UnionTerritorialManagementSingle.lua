--[[
    author:Temmie
    time:2020-01-15 16:00:29
    function:联盟领地管理(只有联盟堡垒)
]]
local UnionTerritorialManagementSingle = UIMgr:NewUI("UnionTerritorialManagementSingle")

local UnionTrritoryModel = import("Model/Union/UnionTrritoryModel")

function UnionTerritorialManagementSingle:OnInit()
    self:AddListener(self._btnReturn.onClick,function()
        UIMgr:Close("UnionTerritorialManagementSingle")
    end)

    self:AddListener(self._btnHelp.onClick,function()
        Sdk.AiHelpShowSingleFAQ(ConfigMgr.GetItem("configWindowhelps", 1006).article_id)
    end)
end

function UnionTerritorialManagementSingle:OnOpen()
    Net.AllianceBuildings.BuildingsInfo(
        Model.Player.AllianceId,
        function(buildInfo)
            UnionTrritoryModel.Init(buildInfo)
            self:RefreshList()
        end
    )
end

function UnionTerritorialManagementSingle:RefreshList()
    self.configList = UnionTrritoryModel.GetTerritorTypeListByIndex(1)
    self._list:RemoveChildrenToPool()
    for i = 1, #self.configList do
        local item = self._list:AddItemFromPool()
        item:Init(self.configList[i])
    end
end

return UnionTerritorialManagementSingle