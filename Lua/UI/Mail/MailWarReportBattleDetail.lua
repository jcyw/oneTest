--author: 	Amu
--time:		2019-11-06 17:57:46



local MailWarReportBattleDetail = UIMgr:NewUI("MailWarReportBattleDetail")

function MailWarReportBattleDetail:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._btnReturn = self._view:GetChild("_btnClose")
    self._bgMask = self._view:GetChild("_mask")

    self._listView = self._view:GetChild("liebiao")

    self:InitEvent()
end

function MailWarReportBattleDetail:OnOpen(report)
    self.report = report
    self:RefreshListView()
end

function MailWarReportBattleDetail:InitEvent( )
    self:AddListener(self._btnReturn.onClick,function()--返回
        self:Close()
    end)

    self:AddListener(self._bgMask.onClick,function()
        self:Close()
    end)
    
    self._listView.scrollItemToViewOnClick = false
    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end

        item:SetData(self.report)
    end
end

function MailWarReportBattleDetail:RefreshListView( )
    self._listView.numItems = 1
end

function MailWarReportBattleDetail:Close( )
    UIMgr:Close("MailWarReportBattleDetail")
end

return MailWarReportBattleDetail