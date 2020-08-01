--author: 	Amu
--time:		2019-12-11 16:12:08


local MailScout = UIMgr:NewUI("MailScout")

function MailScout:OnInit()
    self._view = self.Controller.contentPane

    self._tilteText = self._view:GetChild("textName")

    self._bar = self._view:GetChild("itemDownBar")

    self._listView = self._view:GetChild("liebiao")

    self.listView2 = self._view:GetChild("liebiao")

    self._btnShare = self._view:GetChild("btnShare")

    self:InitEvent()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.MailScout)
end

function MailScout:OnOpen(type, index, info, panel, showType, player)
    self.type = type
    self._panel = panel
    self.player = player and player or UserModel.data.accountId
    self.showType = showType
    self:_refreshData(info, index, showType)
end

function MailScout:_refreshData(info, index, showType)
    self._info = info
    self.subType = math.floor(info.SubCategory)
    self.index = index
    self._bar:SetData(info, self)
    self.report = JSON.decode(info.Report)


    self._tilteText.text = self._info.Subject

    if showType == MAIL_SHOWTYPE.Shere then
        self._view:GetChild("arrowR").visible = false
        self._view:GetChild("arrowL").visible = false
        self._bar.visible = false
        self._btnShare.visible = false
    else
        self._bar.visible = true
        self._btnShare.visible = true
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
    end


    -- if self.subType == MAIL_SUBTYPE.subPVPReport then
    --     -- if self.report.IsWin
    --     self._btnShare.visible = false
    -- elseif self.subType == MAIL_SUBTYPE.subScoutReport then
    --     self._btnShare.visible = true
    -- end

    self:InitListView()
end

function MailScout:RefreshData(info)
    self._bar:SetData(info, self)
    self._panel:RefreshData()
end

function MailScout:InitEvent(  )
    self:AddListener(self._view:GetChild("btnReturn").onClick,function() 
        UIMgr:Close("MailScout")
    end)

    self:AddListener(self._view:GetChild("arrowL").onClick,function()
        MailModel:ChangePanel(self, self.leftInfo, self.index-1)
    end)

    self:AddListener(self._view:GetChild("arrowR").onClick,function()
        MailModel:ChangePanel(self, self.rightInfo, self.index+1)
    end)

    self:AddListener(self._btnShare.onClick,function()
        local type = 0
        local params = {}
        if self.subType == MAIL_SUBTYPE.subScoutReport then--侦察
            type = PUBLIC_CHAT_TYPE.ChatScoutShare
            params = {
                id = self._info.Uuid,
                name = self.report.Name
            }
        elseif self.subType == MAIL_SUBTYPE.subBeScoutReport then--被侦察
            type = PUBLIC_CHAT_TYPE.ChatBescoutShare
            params = {
                id = self._info.Uuid,
                name = self.report.SpyName
            }
        end
        UIMgr:Open("ConfirmPopupShade", type, JSON.encode(params))
    end)


    self.listView2.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(index, self._info, self.player)
    end
    self.listView2.scrollItemToViewOnClick = false
end

function MailScout:InitListView( )
    self.listView2.numItems  = 1
    self.listView2.scrollPane:ScrollTop()
end

function MailScout:Close()
    UIMgr:Close("MailScout")
end

return MailScout