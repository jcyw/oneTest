--[[
    author:{zhanzhang}
    time:2019-06-14 16:20:18
    function:{出征上限提升}
]]
local GD = _G.GD
local ExpeditionUpperLimit = UIMgr:NewUI("ExpeditionUpperLimit")

function ExpeditionUpperLimit:OnInit()
    self:OnRegister()
end

function ExpeditionUpperLimit:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("ExpeditionUpperLimit")
        end
    )
end
function ExpeditionUpperLimit:OnOpen()
    local list = GD.ItemAgent.GetItemListByPage(Global.PageMarchLimit)
    self._contentList:RemoveChildrenToPool()
    for i = 1, #list do
        local item = self._contentList:AddItemFromPool()
        item:Init(list[i], ItemType.ExpeditionLimitProp)
    end
end

return ExpeditionUpperLimit
