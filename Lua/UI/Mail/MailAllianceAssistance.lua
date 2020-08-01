-- author:{Amu}
-- time:2019-06-13 11:51:39


local MailAllianceAssistance = UIMgr:NewUI("MailAllianceAssistance")

function MailAllianceAssistance:OnInit()
    self._view = self.Controller.contentPane

    self._tilteText = self._view:GetChild("textName")

    self._itemTag = self._view:GetChild("itemTag")

    self._listView = self._view:GetChild("liebiao")

    self._bar = self._view:GetChild("itemDownBar")

    self.tempList = {}

    self:InitEvent()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.MailCollectionReport)
end

function MailAllianceAssistance:OnOpen(type, index, info, panel)
    self.type = type
    self.subType = info.SubCategory
    self._panel = panel
    self._info = info

    self:_refreshData(info, index)
end

function MailAllianceAssistance:_refreshData(info, index)
    self.report = JSON.decode(info.Report)
    self._bar:SetData(info, self)
    self._tilteText.text = info.Subject 

    self.resList = {}

    for _,v in ipairs(self.report.Res)do
        if v.Amount and v.Amount > 0 then
            table.insert(self.resList, v)
        end
    end

    self._itemTag:SetData(info, self.report)
    self.index = index
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

function MailAllianceAssistance:RefreshData(info)
    self._bar:SetData(info, self)
    self._panel:RefreshData()
end

function MailAllianceAssistance:InitEvent(  )
    self:AddListener(self._view:GetChild("btnReturn").onClick,function()
        UIMgr:Close("MailAllianceAssistance")
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
        item:SetData(index, self._info, self.resList[index+1])
    end
end

function MailAllianceAssistance:InitListView( )
    self._listView.numItems = #self.resList
    self.item = self._listView:GetChildAt(0)
    self._listView.height = self.item.height*#self.resList
end

function MailAllianceAssistance:Close()
    UIMgr:Close("MailAllianceAssistance")
end

return MailAllianceAssistance