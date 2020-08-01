--author: 	Amu
--time:		2019-07-03 14:31:44

import("UI/Union/ItemUnionVoteParticipantw")

local UnionVoteParticipants = UIMgr:NewUI("UnionVoteParticipants")

function UnionVoteParticipants:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._btnClose = self._view:GetChild("btnClose")
    self._bgMask = self._view:GetChild("bgMask")

    self._listView = self._view:GetChild("liebiao")


    self:InitEvent()
end

function UnionVoteParticipants:OnOpen(info)
    self.info = info
    self:RefreahListView()
end

function UnionVoteParticipants:InitEvent( )
    self:AddListener(self._btnClose.onClick,function()--返回
        self:Close()
    end)

    self:AddListener(self._bgMask.onClick,function()--返回
        self:Close()
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self.info[index+1], UNION_VOTITEM_TYPE.InfoItem)
    end
    self._listView:SetVirtual()
end

function UnionVoteParticipants:RefreahListView( )
    self._listView.numItems = #self.info
end

function UnionVoteParticipants:Close( )
    UIMgr:Close("UnionVoteParticipants")
end

return UnionVoteParticipants