-- author:{Amu}
-- time:2019-05-27 15:30:55


local Mail_CollectionReport = UIMgr:NewUI("Mail_CollectionReport")


function Mail_CollectionReport:OnInit()
    self._view = self.Controller.contentPane
    self._listView = self._view:GetChild("liebiaoBig")
    self._btnDel = self._view:GetChild("btnDel")
    self._textNo = self._view:GetChild("textNo")

    self:InitEvent()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.MailCollectionReport)
end

function Mail_CollectionReport:OnOpen(info, type)
    self.type = type
    self:RefreshData()
end

function Mail_CollectionReport:Close()
    UIMgr:Close("Mail_CollectionReport")
end

function Mail_CollectionReport:RefreshData( )
    self.mianInfo = MailModel:GetInfoByType(self.type)
    if #self.mianInfo <= 0 then
        MailModel:ReadTenDataByType(self.type)
    end
    self:InitListView()
    self:RefreshBtn()
end

function Mail_CollectionReport:RefreshBtn( )
    if #self.mianInfo.info <= 0 then
        self._btnDel.visible = false
    else
        self._btnDel.visible = true
    end
end

function Mail_CollectionReport:InitListView()
    if self.mianInfo.info then
        self._listView.numItems  = #self.mianInfo.info
        if #self.mianInfo.info > 0 then
            self._textNo.visible = false
        else
            self._textNo.visible = true
        end
    else
        self._listView.numItems = 0
        self._textNo.visible = true
    end
end

function Mail_CollectionReport:InitEvent( )
    self:AddListener(self._view:GetChild("btnReturn").onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnDel.onClick,function()
        Net.Mails.DeleteAll(self.type, function()
            MailModel:deleteAll(self.type)
            self:RefreshData()
            -- Event.Broadcast(EventDefines.UIMailsNumChange, {})
        end)
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        local _info = self.mianInfo.info[index+1]
        item:SetData(index, _info)
    end
    self._listView:SetVirtual()
    self:AddListener(self._listView.scrollPane.onPullUpRelease,function()
        self.mianInfo = MailModel:GetInfoByTypeOrRaise(self.type)
        if self._listView.numItems == #self.mianInfo.info then
            return
        end
        self._listView.numItems = #self.mianInfo.info
        if #self.mianInfo.info > 0 then
            self._textNo.visible = false
        else
            self._textNo.visible = true
        end
    end)

    self:AddEvent(MAILEVENTTYPE.MailsReadEvent, function(rsp)
        self.mianInfo = MailModel:GetInfoByType(self.type)
        self._listView.numItems = #self.mianInfo.info
        if #self.mianInfo.info > 0 then
            self._textNo.visible = false
        else
            self._textNo.visible = true
        end
        self:RefreshBtn()
    end)
end

return Mail_CollectionReport