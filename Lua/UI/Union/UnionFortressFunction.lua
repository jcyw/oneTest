--[[
    author:{zhanzhang}
    time:2019-10-28 15:21:33
    function:{联盟功能查看}
]]
local UnionFortressFunction = UIMgr:NewUI("UnionFortressFunction")

function UnionFortressFunction:OnInit()
    self:OnRegister()
end

function UnionFortressFunction:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("UnionFortressFunction")
        end
    )
    self:AddListener(self._btnHelp.onClick,
        function()
            Sdk.AiHelpShowFAQSection("29887")
        end
    )
end

function UnionFortressFunction:OnOpen()
    self._contentList:RemoveChildrenToPool()
    local list = ConfigMgr.GetList("configTerritoryBuffs")
    for i = 1, #list do
        local item = self._contentList:AddItemFromPool()
        item:Init(list[i])
    end
end

return UnionFortressFunction
