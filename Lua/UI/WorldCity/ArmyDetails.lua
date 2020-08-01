--[[
    author:{zhanzhang}
    time:2019-09-28 11:14:52
    function:{部队详情}
]]
local ArmyDetails = UIMgr:NewUI("ArmyDetails")

local MapModel = import("Model/MapModel")
local ArmiesModel = import("Model/ArmiesModel")

function ArmyDetails:OnInit()
    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("ArmyDetails")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("ArmyDetails")
        end
    )
    self._contentList:SetVirtual()

    self._contentList.itemRenderer = function(index, item)
        item:InitItemArmyInfo(self.armyList[index + 1])
    end
end

function ArmyDetails:OnOpen(armies)
    local list
    if armies.MissionTeams then
        list = armies.MissionTeams
    else
        list =  armies
    end

    self.armyList = list
    self._contentList.numItems = #self.armyList
end

function ArmyDetails:OnClose()
end

return ArmyDetails
