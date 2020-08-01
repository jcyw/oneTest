-- author:{Amu}
-- time:2019-06-04 10:37:02


local MailWarReport = UIMgr:NewUI("MailWarReport")

function MailWarReport:OnInit()
    self._view = self.Controller.contentPane

    self._tilteText = self._view:GetChild("textName")

    self._bar = self._view:GetChild("itemDownBar")

    self._listView = self._view:GetChild("liebiao")

    self._btnShare = self._view:GetChild("btnShare")

    self._ctrView = self._view:GetController("c1")
    self._ctrView2 = self._view:GetController("c2")

    self:InitEvent()
end

function MailWarReport:SetController(index)
    self._ctrView.selectedIndex = index
    --设置Banner
    if index == 0 then
        self._banner.icon = UITool.GetIcon(GlobalBanner.MailWarReport1)
    elseif index == 1 then
        self._banner.icon = UITool.GetIcon(GlobalBanner.MailWarReport2)
    end
end

function MailWarReport:OnOpen(type, index, info, panel, showType, player)
    self.type = type
    self._panel = panel
    self.player = player and player or UserModel.data.accountId
    self.showType = showType
    self:_refreshData(info, index, showType)
end

function MailWarReport:_refreshData(info, index, showType)
    self._info = info
    self.subType = math.floor(info.SubCategory)
    self.index = index
    self._bar:SetData(info, self)
    self.report = JSON.decode(info.Report)

    if self.subType == MAIL_SUBTYPE.subPVPReport then
        if self.report.Attacker.UserId == self.player or self:IsAttack()  then --我攻击别人
            if self.report.IsWin then --胜利
                self._tilteText.text = ConfigMgr.GetI18n("configI18nMailTypes", "Ui_MailTitle30001")
                self:SetController(0)
            else--失败
                self._tilteText.text = ConfigMgr.GetI18n("configI18nMailTypes", "Ui_MailTitle30002")
                self:SetController(1)
            end
        else--别人攻击我
            if not self.report.IsWin then --胜利
                self._tilteText.text = ConfigMgr.GetI18n("configI18nMailTypes", "Ui_MailTitle30009")
                self:SetController(0)
            else--失败
                self._tilteText.text = ConfigMgr.GetI18n("configI18nMailTypes", "Ui_MailTitle30010")
                self:SetController(1)
            end
        end
    elseif self.subType == MAIL_SUBTYPE.MailSubTypeSports then
        if self.report.Attacker.UserId == self.player or self:IsAttack()  then --我攻击别人
            if self.report.IsWin then --胜利
                -- self._tilteText.text = ConfigMgr.GetI18n("configI18nMailTypes", "Ui_MailTitle30001")
                self:SetController(0)
            else--失败
                -- self._tilteText.text = ConfigMgr.GetI18n("configI18nMailTypes", "Ui_MailTitle30002")
                self:SetController(1)
            end
        else--别人攻击我
            if not self.report.IsWin then --胜利
                -- self._tilteText.text = ConfigMgr.GetI18n("configI18nMailTypes", "Ui_MailTitle30009")
                self:SetController(0)
            else--失败
                -- self._tilteText.text = ConfigMgr.GetI18n("configI18nMailTypes", "Ui_MailTitle30010")
                self:SetController(1)
            end
        end
    end

    self._tilteText.text = self._info.Subject

    if showType == MAIL_SHOWTYPE.Shere then
        self._view:GetChild("arrowR").visible = false
        self._view:GetChild("arrowL").visible = false
        self._bar.visible = false
        self._btnShare.visible = false
        self._ctrView2.selectedIndex = 1
    else
        self._ctrView2.selectedIndex = 0
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

    self:InitListView()
end

function MailWarReport:RefreshData(info)
    self._bar:SetData(info, self)
    self._panel:RefreshData()
end

function MailWarReport:InitEvent(  )
    self:AddListener(self._view:GetChild("btnReturn").onClick,function() 
        UIMgr:Close("MailWarReport")
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
        if self.report.Attacker.UserId == self.player or self:IsAttack() then --我攻击别人
            params = {
                id = self._info.Uuid,
                name = self.report.Defender.Name
            }
            if self.report.IsWin then --胜利
                type = PUBLIC_CHAT_TYPE.ChatAttackSuccessShare
            else--失败
                type = PUBLIC_CHAT_TYPE.ChatAttackFailShare
            end
        else--别人攻击我
            params = {
                id = self._info.Uuid,
                name = self.report.Attacker.Name
            }
            if self.report.IsWin then --胜利
                type = PUBLIC_CHAT_TYPE.ChatDefenceFailShare
            else--失败
                type = PUBLIC_CHAT_TYPE.ChatDefenceSuccessShare
            end
        end
        UIMgr:Open("ConfirmPopupShade", type, JSON.encode(params))
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(index, self._info, self.player, self.showType)
    end

    self._listView:SetVirtual()
    self._listView.itemProvider = function(index)
        if not index then 
            return
        end

        if self.subType == MAIL_SUBTYPE.subPVPReport then
            return "ui://Mail/itemMailWarReport"
        elseif self.subType == MAIL_SUBTYPE.MailSubTypeSports then
            return "ui://Mail/itemMailArenaReport"
        end
    end

    self._listView.scrollItemToViewOnClick = false
end

function MailWarReport:InitListView( )
    self._listView.numItems  = 1
    self._listView.scrollPane:ScrollTop()
end

function MailWarReport:IsAttack()
    for _,v in ipairs(self.report.Members)do
        if v.Side == 0 then -- 攻击方
            if v.UserId == self.player then
                return true
            end
        elseif v.Side == 1 then -- 防守方
            if v.UserId == self.player then
                return false
            end
        end
    end
    return false
end

function MailWarReport:Close()
    UIMgr:Close("MailWarReport")
end

return MailWarReport