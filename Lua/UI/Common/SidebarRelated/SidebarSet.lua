--[[
    Author: songzeming
    Function: 侧边栏设置界面
]]
local SidebarSet = UIMgr:NewUI("SidebarSet")

local BuildModel = import("Model/BuildModel")
import("UI/Common/SidebarRelated/ItemSidebarSet")

function SidebarSet:OnInit()
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("SidebarRelated/SidebarSet")
        end
    )
end

function SidebarSet:OnOpen()
    local conf = ConfigMgr.GetList("configSidebars")
    local centerLv = BuildModel.GetCenterLevel()
    local obj = {}
    for _, v in pairs(conf) do
        if v.remid == 1 and centerLv >= v.level then
            table.insert(obj, v)
        end
    end

    local localData = PlayerDataModel:GetData(PlayerDataEnum.QUEUEOVERVIEW)
    if not localData then
        localData = {}
    end
    self._list.numItems = #obj
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local title = obj[i].i18n
        if not localData[title] then
            localData[title] = TipType.QUEUEOVERVIEW.No
        end
        item:Init(
            title,
            localData[title],
            function(chooseIndex)
                if chooseIndex == localData[title] then
                    return
                end
                localData[title] = chooseIndex
                PlayerDataModel:SetData(PlayerDataEnum.QUEUEOVERVIEW, localData)
                Event.Broadcast(EventDefines.UISidebarPoint)
            end
        )
    end
end

return SidebarSet
