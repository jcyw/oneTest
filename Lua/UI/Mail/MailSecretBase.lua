--author: 	Amu
--time:		2019-11-28 10:01:30


local MailSecretBase = UIMgr:NewUI("MailSecretBase")

function MailSecretBase:OnInit()
    self._view = self.Controller.contentPane

    self.tempList = {}

    self._tilteText = self._view:GetChild("textName")
    self._authorText = self._view:GetChild("textTagName")
    self._timeText = self._view:GetChild("textTime")

    self.btnGet = self._view:GetChild("btnGreen")

    self._bar = self._view:GetChild("itemDownBar")

    self.groupState1 = self._view:GetChild("groupState1")

    self._listView = self._view:GetChild("liebiao")


    self:InitEvent()
end

function MailSecretBase:OnOpen(type, index, info, panel)
    self.type = type
    self._panel = panel
    self.subType = info.SubCategory
    self:_refreshData(info, index)
end

function MailSecretBase:_refreshData(info, index)
    self._info = info
    self.index = index
    self._tilteText.text = info.Subject 
    -- self._authorText.text = info.Subject
    -- self._timeText.text = TimeUtil:GetTimesAgo(info.CreatedAt)
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

function MailSecretBase:RefreshData(info)
    self._bar:SetData(info, self)
    self._panel:RefreshData()
end

function MailSecretBase:InitEvent(  )
    self:AddListener(self._view:GetChild("btnReturn").onClick,function()
        UIMgr:Close("MailSecretBase")
    end)

    self:AddListener(self._view:GetChild("arrowL").onClick,function()
        MailModel:ChangePanel(self, self.leftInfo, self.index-1)
    end)

    self:AddListener(self._view:GetChild("arrowR").onClick,function()
        MailModel:ChangePanel(self, self.rightInfo, self.index+1)
    end)
    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(index, self._info, self)
    end
end

function MailSecretBase:InitListView( )
    self._listView.numItems  = 1
    self.item = self._listView:GetChildAt(0)
end

function MailSecretBase:HideBtn(flag)
    self.btnGet.visible = flag
end

function MailSecretBase:Close()
    UIMgr:Close("MailSecretBase")
end

return MailSecretBase