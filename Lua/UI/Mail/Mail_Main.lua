-- author:{Amu}
-- time:2019-05-27 11:51:34


local Mail_Main = UIMgr:NewUI("Mail_Main")

function Mail_Main:OnInit()
    self._view = self.Controller.contentPane

    self._listView = self._view:GetChild("liebiao")
    
    self.itemList = {}

    self:InitListView()
    -- self:InitData()

    self:InitEvent()
end

function Mail_Main:OnOpen()
    self.item:Refresh()
    self.item:RefreshData()
    MAIL_SPANEL.Mail_Main = self
end

function Mail_Main:DoOpenAnim(...)
    self:OnOpen(...)
    AnimationLayer.PanelAnim(AnimationType.PanelMoveUp, self)
end

function Mail_Main:InitListView()
    self._listView.itemRenderer = function(index, item)
        -- if not index then return end
    end
    self._listView.numItems  = 1
    self.item = self._listView:GetChildAt(0)
end

function Mail_Main:InitEvent( )
    self:AddListener(self._view:GetChild("btnReturn").onClick,function()
        UIMgr:Close("Mail_Main")
        MAIL_SPANEL.Mail_Main = nil
    end)
end

return Mail_Main