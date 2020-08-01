--[[
    author:{zhanzhang}
    time:2019-11-29 21:35:35
    function:{黑骑士积分榜}
]]
local BlackKnightGetGrade = UIMgr:NewUI("BlackKnightGetGrade")


function BlackKnightGetGrade:OnInit()
    local view = self.Controller.contentPane

    self:OnRegister()
end

function BlackKnightGetGrade:OnRegister()
    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("BlackKnightGetGrade")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("BlackKnightGetGrade")
        end
    )
    self.configList = ConfigMgr.GetList("configKnightBases")

    self._content:SetVirtual()
    self._content.itemRenderer = function(index, item)
        item:Init(index + 1, self.configList[index + 1])
    end
    self._content.numItems = #self.configList
end

function BlackKnightGetGrade:OnOpen()
    self._content.scrollPane:SetPosY(0)
end

return BlackKnightGetGrade
