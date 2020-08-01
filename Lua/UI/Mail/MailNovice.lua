--author: 	Amu
--time:		2020-02-11 17:16:24

local MailNovice = UIMgr:NewUI("MailNovice")


function MailNovice:OnInit()
    self._view = self.Controller.contentPane

    self._tilteText = self._view:GetChild("textName")
    self._authorText = self._view:GetChild("textTagName")
    self._timeText = self._view:GetChild("textTime")

    self._systemNameText = self._view:GetChild("textSystemName")
    self._describText = self._view:GetChild("textDescribe")

    self._bar = self._view:GetChild("itemDownBar")

    self._listView = self._view:GetChild("liebiao1")
    
    self._barH = self._bar.height
    self._textY = self._describText.y
    self._textH = self._describText.height

    self:InitEvent()
end

function MailNovice:InitEvent()
    self:AddListener(self._view:GetChild("btnReturn").onClick,function()
        UIMgr:Close("MailNovice")
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
        item:SetData(index, self._info, self, self.subType)
    end
end

function MailNovice:OnOpen(type, index, info, panel)
    self.type = type
    self._panel = panel
    self.subType = info.SubCategory
    self:_refreshData(info, index)
end

function MailNovice:_refreshData(info, index)
    self._info = info
    self.index = index
    self._tilteText.text = info.Subject 
    self._authorText.text = info.Subject
    self._systemNameText.text = info.Subject
    self._describText.text = info.Content

    self._timeText.text = TimeUtil:GetTimesAgo(info.CreatedAt)
    self._bar:SetData(info, self)
    if #info.Rewards <= 0 then
        self._listView.visible = false
    else
        self._listView.visible = true
    end

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

function MailNovice:RefreshData(info)
    self._bar:SetData(info, self)
    self._panel:RefreshData()
end

function MailNovice:InitListView( )
    self._listView.numItems  = 1
    self.item = self._listView:GetChildAt(0)
    self._listView.y = self._textY + self._describText.displayObject.height + 20
    self._listView:SetSize(self._listView.width, GRoot.inst.height - self._barH - self._listView.y)
end

function MailNovice:Close()
    UIMgr:Close("MailNovice")
end

return MailNovice