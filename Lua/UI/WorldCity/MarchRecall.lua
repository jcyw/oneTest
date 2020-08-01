--[[
    author:{zhanzhang}
    time:2019-09-28 16:11:04
    function:{行军召回界面}
]]
local GD = _G.GD
local MarchRecall = UIMgr:NewUI("MarchRecall")
local MapModel = import("Model/MapModel")

function MarchRecall:OnInit()
    local view = self.Controller.contentPane
    self._btnReturn = view:GetChild("btnReturn")
    self._textAPNum = view:GetChild("textAPNum")
    self._contentList = view:GetChild("liebiao")

    self:OnRegister()
end

function MarchRecall:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("MarchRecall")
        end
    )
    self:AddEvent(
        EventDefines.UIDelMarchLine,
        function(rsp)
            if rsp.Uuid == self.data.Uuid then
                UIMgr:Close("MarchRecall")
            end
        end
    )
end

function MarchRecall:OnOpen(data)
    self.data = data
    local list = GD.ItemAgent.GetItemListByPage(data.IsRally and Global.PageRaidReturn or Global.PageMarchReturn)
    self._contentList:RemoveChildrenToPool()
    for i = 1, #list do
        local item = self._contentList:AddItemFromPool()
        item:Init(
            list[i],
            ItemType.MarchRecell,
            data.Uuid,
            function()
                UIMgr:Close("MarchRecall")
            end
        )
    end
end

function MarchRecall:OnClose()
end

return MarchRecall
