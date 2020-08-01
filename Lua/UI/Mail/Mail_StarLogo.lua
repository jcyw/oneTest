-- author:{Amu}
-- time:2019-06-11 16:01:46


local Mail_StarLogo = UIMgr:NewUI("Mail_StarLogo")

Mail_StarLogo.isClick = false
Mail_StarLogo.allSelect = false
Mail_StarLogo.initListClick = false

function Mail_StarLogo:OnInit()
    self._view = self.Controller.contentPane
    self._listView = self._view:GetChild("liebiao")
    
    -- self._group1 = self._view:GetChild("group1")
    self._group2 = self._view:GetChild("group2")

    self._checkBox = self._view:GetChild("checkBox")
    self._ctrView = self._view:GetController("c1")

    self.mailList = {}

    self:InitEvent()
end

function Mail_StarLogo:OnOpen(info, type, panel)
    -- self.mianInfo = MailModel:GetInfoByType(type)
    MailModel:ReadStarMails()
    self.type = type
    self._panel = panel
    if not self.initListClick then
        self:listViewAddClick()
    end 
    self:RefreshData()
    MAIL_SPANEL.Mail_StarLogo = self
    self._listView.scrollPane:ScrollTop()
end

function Mail_StarLogo:Close()
    UIMgr:Close("Mail_StarLogo")
end

function Mail_StarLogo:OnClose()
    MAIL_SPANEL.Mail_StarLogo = nil
end

function Mail_StarLogo:RefreshData()
    self.mianInfo = MailModel:GetInfoByType(self.type)
    self.isClick = false
    self.allSelect = false
    self._checkBox.asButton.selected = false
    self:InitListView()
    self._panel:RefreshData()
end


function Mail_StarLogo:InitListView()
    if self.mianInfo.info then
        self._listView.numItems  = #self.mianInfo.info
    else
        self._listView.numItems = 0
    end
end

function Mail_StarLogo:InitEvent( )
    self:AddListener(self._view:GetChild("btnReturn").onClick,function()
        self:Close()
    end)

    self:AddListener(self._view:GetChild("btnDel").onClick,function()
        Net.Mails.MarkFavorite(false, self.mailList,function()
            TipUtil.TipById(50084)
            local info = MailModel:updateIsFavoriteDatas(self.mailList, false)
            self:RefreshData(info)
            self._ctrView.selectedIndex = 0
        end)
    end)

    self:AddListener(self._view:GetChild("btnAdministration").onClick,function()
        self.isClick = true
        self._checkBox.asButton.selected = false
        self.allSelect = false
        self.mailList = {}
        self:listViewRemoveClick()
        self._listView:RefreshVirtualList()
        self._ctrView.selectedIndex = 1
    end)

    self:AddListener(self._view:GetChild("btnMainBlack").onClick,function()
        self.isClick = false
        self._checkBox.asButton.selected = false
        self.allSelect = false
        self.mailList = {}
        self:listViewAddClick()
        self._listView:RefreshVirtualList()
        self._ctrView.selectedIndex = 0
    end)

    -- self:AddListener(self._view,function()
    --     self.allSelect = self._checkBox.asButton.selected
    --     if self.allSelect then
    --         self.mailList = MailModel:GetAllFavoriteUIds()
    --     else
    --         self.mailList = {}
    --     end
    --     self._listView:RefreshVirtualList()
    -- end)

    self:AddListener(self._checkBox.onChanged,function()
        self.allSelect = self._checkBox.asButton.selected
        if self.allSelect then
            self.mailList = MailModel:GetAllFavoriteUIds()
        else
            self.mailList = {}
        end
        self._listView:RefreshVirtualList()
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        local _info = self.mianInfo.info[index+1]

        item:SetData(nil, index, _info, self.isClick, self.allSelect, self)
    end
    self._listView:SetVirtual()
    self:AddListener(self._listView.scrollPane.onPullUpRelease,function()
        MailModel:ReadStarMails()
    end)

    self:AddEvent(EventDefines.UIMailAddFavorite, function(rsp)
        table.insert(self.mailList, rsp)
    end)

    self:AddEvent(EventDefines.UIMailDelFavorite, function(rsp)
        for i,v in pairs(self.mailList) do
            if v == rsp then
                table.remove(self.mailList, i)
            end
        end
    end)

    self:AddEvent(MAILEVENTTYPE.MailStarReadEvent, function(msg)
        self.mianInfo = MailModel:GetInfoByType(self.type)
        self:InitListView()
    end)
end

function Mail_StarLogo:listViewRemoveClick( )
    self.initListClick = false
    self:ClearListener(self._listView.onClickItem)
end

function Mail_StarLogo:listViewAddClick()
    self.initListClick = true

    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        local data =  item:getData()
        local type = data.Category
        local subtype
        if type == MAIL_TYPE.Msg then
            subtype = math.floor(data.data[#data.data].SubCategory) 
        else
            subtype = math.floor(data.SubCategory)
        end
        item:SetRead()
        local index = self._listView:ChildIndexToItemIndex(self._listView:GetChildIndex(item))+1
        if type == MAIL_TYPE.PVPReport then
            if subtype == MAIL_SUBTYPE.subScoutFailReport then
                UIMgr:Open("MailUnion", self.type, index, data, self)
            elseif subtype == MAIL_SUBTYPE.subexploreReport then
                UIMgr:Open("MailSecretBase", self.type, index, data, self)
            elseif subtype == MAIL_SUBTYPE.subScoutReport or subtype == MAIL_SUBTYPE.subBeScoutReport then
                UIMgr:Open("MailScout", self.type, index, data, self)
            elseif subtype == MAIL_SUBTYPE.subTypeAttackFailure then
                UIMgr:Open("MailUnion", self.type, index, data, self)
            else
                UIMgr:Open("MailWarReport", self.type, index, data, self)
            end
        elseif type == MAIL_TYPE.Sports then       --竞技场邮件
            if MAIL_SUBTYPE.MailSubTypeSports then
                UIMgr:Open("MailWarReport", self.type, index, data, self)
            end
        elseif type == MAIL_TYPE.Alliance then
            if subtype == MAIL_SUBTYPE.subOrderReport       --联盟指令
                or subtype == MAIL_SUBTYPE.subAllianceBuildRecovery --联盟建筑回收
                or subtype == MAIL_SUBTYPE.subAllianceBuildPlace then   --联盟建筑放置通知
                UIMgr:Open("MailAllianceSystemInformation", self.type, index, data, self)
            elseif subtype == MAIL_SUBTYPE.subAllianceAssistRes then --援助资源
                UIMgr:Open("MailAllianceAssistance", self.type, index, data, self)
            elseif subtype == MAIL_SUBTYPE.subAllianceAssistArmies then  --self.type
                UIMgr:Open("MailAllianceTroopAssistance", type, index, data, self)
            elseif subtype == MAIL_SUBTYPE.subAllianceInvite then    --入盟邀请
                UIMgr:Open("MailAllianceInvitation", self.type, index, data, self)
            elseif subtype == MAIL_SUBTYPE.subAlliance              --联盟通知
                or subtype == MAIL_SUBTYPE.subAllianceBuildcomplete then    --联盟建筑完工
                UIMgr:Open("MailUnion", self.type, index, data, self)
            end
        elseif type == MAIL_TYPE.Activity then
            if subtype == MAIL_SUBTYPE.subTypeActiveCombat then      --活动集结怪邮件
                UIMgr:Open("Mail_FieldEnemyActivityAggregation", self.type, index, data, self)
            else
                UIMgr:Open("MailUnion", self.type, index, data, self)
            end
        elseif type == MAIL_TYPE.System or type == MAIL_TYPE.Studio then
            if subtype == MAIL_SUBTYPE.subMailSubTypeNewPlayer then    --新手邮件
                UIMgr:Open("MailUnion", self.type, index, data, self)
            elseif subtype == MAIL_SUBTYPE.subMailSubTypeForceUpgrade then  --强更提醒邮件
                UIMgr:Open("MailUnion", self.type, index, data, self)
            else
                UIMgr:Open("MailUnion", self.type, index, data, self)
            end
        end
    end)
end

return Mail_StarLogo