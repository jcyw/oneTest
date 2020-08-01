--[[
    Author:maxiaolong
    Function:全体邮件
]]
local UnionAllInformation = UIMgr:NewUI("UnionAllInformation")
-- local itemUnionInformatin=import()
local UnionMemberModel = import("Model/Union/UnionMemberModel")
function UnionAllInformation:OnInit()
    local view = self.Controller.contentPane
    self._list = view:GetChild("liebiao")
    self._title = view:GetChild("titleName")
    self._title.text = "全体信件"

    self:AddListener(self._btnClose.onClick,
        function()
            self:OnClose()
        end
    )
    self:AddListener(self._btnUse.onClick,
        function()
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            self:OnClose()
        end
    )
    self._list.itemRenderer = function(index, item)
        item:SetData()
    end
end

function UnionAllInformation:OnOpen()
    self.postNum = UnionType.MEMBER_POST_COUNT
    self._list.numItems = self.postNum
    self.members = UnionMemberModel.GetMembers()
end

function UnionAllInformation:OnClose()
    UIMgr:Close("UnionAllInformation")
end

return UnionAllInformation
