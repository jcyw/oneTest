--[[
    author:{zhanzhang}
    time:2019-07-29 11:56:27
    function:{联盟防御炮台}
]]
local UnionDefenseTowerDetail = UIMgr:NewUI("UnionDefenseTowerDetail")

function UnionDefenseTowerDetail:OnInit()
    -- body
    local view = self.Controller.contentPane
    self._btnReturn = view:GetChild("btnReturn")
    self._textConstructionNum = view:GetChild("textConstructionNum")
    self._textDestroyNum = view:GetChild("textDestroyNum")
    self._contentList = view:GetChild("liebiao")

    self._btnDismantle = view:GetChild("btnDismantle")

    self:OnRegister()
end

function UnionDefenseTowerDetail:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("UnionDefenseTowerDetail")
        end
    )

    self:AddListener(self._btnDismantle.onClick,
        function()
            --拆除建筑
            Net.AllianceBuildings.Destroy(
                self.data.ConfId,
                function(val)
                end
            )
        end
    )
    self._contentList:SetVirtual()
    self._contentList.itemRenderer = function(index, item)
        item:Init(index, self.data[index])
    end
end
function UnionDefenseTowerDetail:OnOpen(chunkInfo)
    self.data = chunkInfo
    Net.AllianceBuildings.FortressInfo(chunkInfo.ConfId)
end

return UnionDefenseTowerDetail
