--[[
    author:{zhanzhang}
    time:2019-07-29 15:07:31
    function:{防御塔功能}
]]
local UnionDefenseTowerFunction = UIMgr:NewUI("UnionDefenseTowerFunction")

function UnionDefenseTowerFunction:OnInit()
    -- body
    local view = self.Controller.contentPane
    self._btnReturn = view:GetChild("btnReturn")

    self:OnRegister()
end

function UnionDefenseTowerFunction:OnRegister()
    --前往获取资源
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("UnionDefenseTowerFunction")
        end
    )
end
function UnionDefenseTowerFunction:OnOpen()
end

return UnionDefenseTowerFunction
