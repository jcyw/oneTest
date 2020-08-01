-- author:{Amu}
-- time:2019-05-29 10:48:53


local MailUnion = UIMgr:NewUI("MailUnion")

function MailUnion:OnInit()
    self._view = self.Controller.contentPane

    self._tilteText = self._view:GetChild("textName")
    -- self._authorText = self._view:GetChild("textTagName")
    self._timeText = self._view:GetChild("textTime")

    -- self._systemNameText = self._view:GetChild("textSystemName")
    -- self._describText = self._view:GetChild("textDescribe")

    self._bar = self._view:GetChild("itemDownBar")

    self._listView = self._view:GetChild("n80")
    -- self._listView = self._view:GetChild("liebiao1")

    self._barH = self._bar.height
    -- self._textY = self._describText.y
    -- self._textH = self._describText.height

    self:InitEvent()
end

function MailUnion:OnOpen(type, index, info, panel,showType)
    self.type = type
    self._panel = panel
    self:_refreshData(info, index,showType)
end

function MailUnion:_refreshData(info, index,showType)
    self._info = info
    self.index = index
    self._tilteText.text = info.Subject
    self.subType = info.SubCategory
    -- self._authorText.text = info.Subject
    -- self._systemNameText.text = info.Subject
    -- self._describText.text = info.Content

    -- self._timeText.text = TimeUtil:GetTimesAgo(info.CreatedAt)
    self._bar:SetData(info, self)
    -- if #info.Rewards <= 0 then
    --     self._listView.visible = false
    -- else
    --     self._listView.visible = true
    -- end
    -- if info.IsClaimed then
    --     -- self.btnGet.enabled = false
    --     self._ctrView.selectedIndex = 0
    --     -- self.btnGet.text = StringUtil.GetI18n(I18nType.Commmon,"ShootingReward_39")
    -- else
    --     -- self.btnGet.enabled = true
    --     self._ctrView.selectedIndex = 1
    --     -- self.btnGet.text = "领取"
    -- end
    if showType == MAIL_SHOWTYPE.Shere then
        self._bar.visible = false
    else
        self._bar.visible = true
    end

    self.leftInfo = MailModel:getInfoByTypeAndIdex(self.type, self.index - 1)
    self.rightInfo = MailModel:getInfoByTypeAndIdex(self.type, self.index + 1)

    if self.leftInfo and not (showType == MAIL_SHOWTYPE.Shere) then
        self._view:GetChild("arrowL").visible = true
    else
        self._view:GetChild("arrowL").visible = false
    end

    if self.rightInfo and not (showType == MAIL_SHOWTYPE.Shere) then
        self._view:GetChild("arrowR").visible = true
    else
        self._view:GetChild("arrowR").visible = false
    end

    self:InitListView()
end

function MailUnion:RefreshData(info)
    self._bar:SetData(info, self)
    self._panel:RefreshData()
end

function MailUnion:InitEvent(  )
    self:AddListener(self._view:GetChild("btnReturn").onClick,function()
        UIMgr:Close("MailUnion")
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
        item:SetData(index, self._info, self, self.subType)
    end
end

function MailUnion:InitListView( )
    self._listView.numItems  = 1
    -- self.item = self._listView:GetChildAt(0)
    -- self._listView.y = self._textY + self._describText.displayObject.height + 20
    -- self._listView:SetSize(self._listView.width, GRoot.inst.height - self._barH - self._listView.y)
end

function MailUnion:HideBtn(flag)
    -- self.btnGet.visible = flag
    -- self.btnHaveGet.visible = flag
end

function MailUnion:Close()
    UIMgr:Close("MailUnion")
end

function MailUnion:OnClose(  )
    Event.Broadcast(MAIL_PANEL_STATE_EVENT.MailUnionClose)
end

return MailUnion