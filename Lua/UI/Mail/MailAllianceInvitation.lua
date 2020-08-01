-- author:{Amu}
-- time:2019-06-13 11:51:48


local MailAllianceInvitation = UIMgr:NewUI("MailAllianceInvitation")

function MailAllianceInvitation:OnInit()
    self._view = self.Controller.contentPane

    self._bar = self._view:GetChild("itemDownBar")

    self._listView = self._view:GetChild("listview")
    
    self:InitEvent()
end

function MailAllianceInvitation:OnOpen(type, index, info, panel)
    self.type = type
    self.subType = info.SubCategory
    self._panel = panel
    self:_refreshData(info, index)
end

function MailAllianceInvitation:_refreshData(info, index)
    self.index = index
    self._info = info
    self._bar:SetData(info, self)

    self.leftInfo = MailModel:getInfoByTypeAndIdex(self.type, self.index - 1)
    self.rightInfo = MailModel:getInfoByTypeAndIdex(self.type, self.index + 1)

    if self.leftInfo then
        self._view:GetChild("arrowL").visible = true
    else
        self._view:GetChild("arrowL").visible = false
    end

    if self.rightInfo then
        self._view:GetChild("arrowR").visible = true
    else
        self._view:GetChild("arrowR").visible = false
    end
    
    self:InitListView()
end

function MailAllianceInvitation:RefreshData(info)
    self._bar:SetData(info, self)
    self._panel:RefreshData()
end

function MailAllianceInvitation:InitEvent(  )
    self:AddListener(self._view:GetChild("btnReturn").onClick,function()
        UIMgr:Close("MailAllianceInvitation")
    end)


    self:AddListener(self._view:GetChild("arrowL").onClick,function()
        MailModel:ChangePanel(self, self.leftInfo, self.index-1)
    end)

    self:AddListener(self._view:GetChild("arrowR").onClick,function()
        MailModel:ChangePanel(self, self.rightInfo, self.index+1)
    end)

    self._listView.scrollItemToViewOnClick = false
    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self._info, self._panel)
    end
end

function MailAllianceInvitation:InitListView( )
    self._listView.numItems  = 1
end

function MailAllianceInvitation:Close()
    UIMgr:Close("MailAllianceInvitation")
end

return MailAllianceInvitation