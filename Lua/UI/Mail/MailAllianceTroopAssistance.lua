-- author:{Amu}
-- time:2019-06-13 14:05:28


local MailAllianceTroopAssistance = UIMgr:NewUI("MailAllianceTroopAssistance")


function MailAllianceTroopAssistance:OnInit()
    self._view = self.Controller.contentPane

    self._name = self._view:GetChild("textSystemName")
    self._pos = self._view:GetChild("textCoordinate")

    self._listView = self._view:GetChild("liebiao")
    self.timeLab = self._view:GetChild("textTime")
    self.numlab = self._view:GetChild("textDefenseNum")

    self._tilteText = self._view:GetChild("textName")
    self._authorText = self._view:GetChild("textTagName")

    self._textContent = self._view:GetChild("textContent")

    self._bar = self._view:GetChild("itemDownBar")

    self.tempList = {}


    self:InitEvent()
end

function MailAllianceTroopAssistance:OnOpen(type, index, info, panel)
    self.type = type
    self.subType = info.SubCategory
    self._panel = panel
    self:_refreshData(info, index)
end

function MailAllianceTroopAssistance:_refreshData(info, index)
    self.index = index
    self._info = info
    self._tilteText.text = info.Subject 
    self._authorText.text = info.Subject
    self._textContent.text = info.Content
    
    self.report = JSON.decode(info.Report)
    self._bar:SetData(info, self)
    local num = 0
    self._Armies = {}
    for _,v in ipairs(self.report.Beasts)do
        table.insert(self._Armies, v)
    end
    for _,v in pairs(self.report.Armies)do
        num = num + v.Amount
        table.insert(self._Armies, v)
    end
    self.numlab.text = math.ceil(num)
    self.timeLab.text = TimeUtil:GetTimesAgo(info.CreatedAt)

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

function MailAllianceTroopAssistance:RefreshData(info)
    self._bar:SetData(info, self)
    self._panel:RefreshData()
end

function MailAllianceTroopAssistance:InitEvent(  )
    self:AddListener(self._view:GetChild("btnReturn").onClick,function()
        UIMgr:Close("MailAllianceTroopAssistance")
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
        item:SetData(index, self._Armies[index+1])
    end
end

function MailAllianceTroopAssistance:InitListView( )
    self._listView.numItems  = #self._Armies
end

function MailAllianceTroopAssistance:Close()
    UIMgr:Close("MailAllianceTroopAssistance")
end

return MailAllianceTroopAssistance