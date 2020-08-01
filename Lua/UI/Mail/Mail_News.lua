-- author:{Amu}
-- time:2019-05-27 17:23:04

import("UI/Mail/MailUnion")
import("UI/Mail/MailAllianceInvitation")
import("UI/Mail/MailAllianceAssistance")
import("UI/Mail/MailAllianceSystemInformation")
import("UI/Mail/MailAllianceTroopAssistance")

local Mail_News = UIMgr:NewUI("Mail_News")

Mail_News.isClick = false
Mail_News.allSelect = false
Mail_News.initListClick = false

function Mail_News:OnInit()
    self._view = self.Controller.contentPane

    self._textName = self._view:GetChild("textName")

    self._listView = self._view:GetChild("liebiao")

    self._redPoint = self._view:GetChild("redPoint")
    -- self._redPointNum = self._view:GetChild("textRedPointNumber")
    
    self._group1 = self._view:GetChild("group1")
    self._group2 = self._view:GetChild("group2")
    self._btnShare = self._view:GetChild("btnYellow")

    self._checkBox = self._view:GetChild("checkBox")

    self._btnGet = self._view:GetChild("btnBlue")
    self._textNo = self._view:GetChild("textNo")

    self._ctrView = self._view:GetController("c1")

    self.selectList = {}

    self:InitEvent()
end

function Mail_News:OnOpen(info, type, panel)
    self.type = type
    self._panel = panel
    self._textName.text = ConfigMgr.GetI18n("configI18nCommons", "MAILTYPE_"..type)
    if not self.initListClick then
        self:listViewAddClick()
    end 
    self._ctrView.selectedIndex = 0
    self.mianInfo = MailModel:GetInfoByType(self.type)
    if self.type == MAIL_TYPE.Msg then
        MailModel:ClearMsgGroup()
        self:updateMsgdata(self.mianInfo)
        if #self.mianInfo.info <= 0 then
            MailModel:ReadTenMsgGroup()
        end
    else
        if #self.mianInfo.info <= 10 then
            MailModel:ReadTenDataByType(self.type)
        end
    end
    self:RefreshData()
    MAIL_SPANEL.Mail_News = self
    self._listView.scrollPane:ScrollTop()
end

function Mail_News:Close()
    UIMgr:Close("Mail_News")
end

function Mail_News:OnClose()
    if self.isClick then
        self.isClick = false
        self.selectList = {}
        self.allSelect = false
        self._checkBox.asButton.selected = false
        self:refreshList()
        self:listViewAddClick()
        self._listView:RefreshVirtualList()
        self._ctrView.selectedIndex = 0
        return
    end
    MAIL_SPANEL.Mail_News = nil
end

function Mail_News:RefreshData()
    self.isClick = false
    self.allSelect = false
    self:setSelect(false)
    self._checkBox.asButton.selected = false
    self:InitListView()
    self:refreshList()
    self:refreshNotRead()
    self._panel:RefreshData()
    self:RefreahBtn()
end

function Mail_News:RefreahBtn( )
    -- if self.type == MAIL_TYPE.Msg then
    --     if MailModel:GetNotReadAmountByType(MAIL_TYPE.Msg) > 0 then
    --         self._btnGet.visible = true
    --         self._btnGet.text = ConfigMgr.GetI18n("configI18nCommons", "Button_AllRead")
    --     else
    --         self._btnGet.visible = false
    --     end
    -- else
    --     if #self.mianInfo.info <= 0 then
    --         self._btnGet.visible = false
    --     else
    --         self._btnGet.visible = true
    --         -- self._btnGet.text = ConfigMgr.GetI18n("configI18nCommons", "Button_AllReceive")
    --         self._btnGet.text = ConfigMgr.GetI18n("configI18nCommons", "Button_AllRead")
    --     end
    -- end

    if MailModel:GetNotReadAmountByType(self.type) > 0 then
        self._btnGet.visible = true
        self._btnGet.text = ConfigMgr.GetI18n("configI18nCommons", "Button_AllRead")
    else
        self._btnGet.visible = false
    end
end

function Mail_News:updateMsgdata(infos)
    self.mianInfo = {}
    self.mianInfo.notReadAmount = infos.notReadAmount
    self.mianInfo.type = infos.type
    self.mianInfo.info = {}
    for _,v in pairs(infos.info) do
        table.insert(self.mianInfo.info, v)
    end
    table.sort(self.mianInfo.info, function(a, b)
        if MailModel:MsgGroupIsTop(a.Uuid) or MailModel:MsgGroupIsTop(b.Uuid) then
            if MailModel:MsgGroupIsTop(a.Uuid) then
                return true
            elseif MailModel:MsgGroupIsTop(b.Uuid) then
                return false
            end
        else
            return a.LastMsg.SentAt > b.LastMsg.SentAt
        end
    end)
end

function Mail_News:refreshList()
    if self.isClick then
        self._group1.visible = false
        self._group2.visible = true
    else
        self._group1.visible = true
        self._group2.visible = false
    end
end

function Mail_News:refreshNotRead()
    local info = MailModel:GetInfoByType(self.type)
    if info.notReadAmount > 0 then
        -- self._redPoint.visible = true
        -- self._redPointNum.visible = true
        -- self._redPointNum.text = math.floor(info.notReadAmount)
        self._redPoint:SetData(true, math.floor(info.notReadAmount))
    else
        -- self._redPoint.visible = false
        -- self._redPointNum.visible = false
        self._redPoint:SetData(false)
    end
end

function Mail_News:InitListView()
    if self.mianInfo.info then
        self._listView.numItems = #self.mianInfo.info
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

function Mail_News:InitEvent( )
    self:AddListener(self._view:GetChild("btnReturn").onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnGet.onClick,function()
        -- local ids, infos = MailModel:GetNotReadIdAndInfosByType(self.type)
        -- Net.Mails.MarkRead(ids,function(msg)
        --     MailModel:updateIsReadDatas(self.type, 1)
        --     self._panel:RefreshData()
        --     self:RefreshData()
        --     Event.Broadcast(EventDefines.UIMailsNumChange, {})
        -- end)
        if self.type == MAIL_TYPE.Msg then
            Net.Mails.MarkAllSessionsRead(function()
                MailModel:updateAllMsgIsRead()
                self._panel:RefreshData()
                self:RefreshData()
                Event.Broadcast(EventDefines.UIMailsNumChange, {})
            end)
        else
            Net.Mails.MarkReadAndClaim(self.type, function(rsp)
                if rsp.Rewards and next(rsp.Rewards) ~= nil then
                    UITool.ShowReward(rsp.Rewards)
                end
                MailModel:updateIsReadDatas(self.type, 1)
                self._panel:RefreshData()
                self:RefreshData()
                Event.Broadcast(EventDefines.UIMailsNumChange, {})
            end)
        end
    end)

    self:AddListener(self._view:GetChild("btnDel").onClick,function()
        if #self.selectList <= 0 then
            self.isClick = false
            self.selectList = {}
            self.allSelect = false
            self._checkBox.asButton.selected = false
            self:refreshList()
            self:listViewAddClick()
            self._listView:RefreshVirtualList()
            self._ctrView.selectedIndex = 0
            self:listViewAddClick()
            TipUtil.TipById(50087)
            return
        end
        local data
        if self.type == MAIL_TYPE.Msg then
            data = {
                content = ConfigMgr.GetI18n("configI18nCommons", "Ui_Mail_delete"),
                sureCallback = function()
                    self:DeleteSelectMsg()
                end
            }
        else
            local _content
            if #self.selectList >= #self.mianInfo.info then
                if self.mianInfo.notReceiveAmount and self.mianInfo.notReceiveAmount > 0 then
                    _content = ConfigMgr.GetI18n("configI18nCommons", "Ui_Mail_delete_attachment_batch")
                else
                    _content = ConfigMgr.GetI18n("configI18nCommons", "Ui_Mail_delete")
                end
            else
                _content = ConfigMgr.GetI18n("configI18nCommons", "Ui_Mail_delete")
                for _,v in pairs(self.mianInfo.info)do
                    if v.IsFavorite or not v.IsClaimed then
                        _content = ConfigMgr.GetI18n("configI18nCommons", "Ui_Mail_delete_attachment_batch")
                        break
                    end
                end
            end
            if #self.selectList >= #self.mianInfo.info then
                data = {
                    content = _content,
                    sureCallback = function()
                        Net.Mails.DeleteAll(self.type, function(msg)
                            MailModel:deleteAllNotReceive(self.type, msg.Unread)
                            self:RefreshData()
                            self:refreshListItems()
                            self._ctrView.selectedIndex = 0
                            self:listViewAddClick()
                            Event.Broadcast(EventDefines.UIMailsNumChange, {})
                        end)
                    end
                }
            else
                data = {
                    content = _content,
                    sureCallback = function()
                        Net.Mails.Delete(self.type, self.selectList,function(msg)
                            MailModel:deleteData(self.type, self.selectList, false)
                            self:RefreshData()
                            self:refreshListItems()
                            self._ctrView.selectedIndex = 0
                            self:listViewAddClick()
                            Event.Broadcast(EventDefines.UIMailsNumChange, {})
                        end)
                    end
                }
            end
        end
        UIMgr:Open("ConfirmPopupText", data)
    end)

    self:AddListener(self._view:GetChild("btnAdministration").onClick,function()
        self.isClick = true
        self.selectList = {}
        self.allSelect = false
        self._checkBox.asButton.selected = false
        self:refreshList()
        self:listViewRemoveClick()
        self._listView:RefreshVirtualList()
        self._ctrView.selectedIndex = 1
    end)

    self:AddListener(self._view:GetChild("btnMainBlack").onClick,function()
        self.isClick = false
        self.selectList = {}
        self.allSelect = false
        self._checkBox.asButton.selected = false
        self:refreshList()
        self:listViewAddClick()
        self._listView:RefreshVirtualList()
        self._ctrView.selectedIndex = 0
    end)

    self:AddListener(self._checkBox.onChanged,function()
        self.allSelect = self._checkBox.asButton.selected
        if self.allSelect then
            self.selectList = MailModel:GetUIdsByType(self.type)
            self:setSelect(true)
        else
            self.selectList = {}
            self:setSelect(false)
        end
        self._listView:RefreshVirtualList()
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        local _info = self.mianInfo.info[index+1]

        item:SetData(self.type, index, _info, self.isClick, self.allSelect, self)
    end
    self._listView:SetVirtual()
    
    self:AddListener(self._listView.scrollPane.onPullUpRelease,function()
        self:refreshListItems()
    end)

    self:AddEvent(EventDefines.UIDelMiil, function()
        self:RefreshData()
    end)

    self:AddEvent(EventDefines.UIMailAdd, function(uid, index)
        table.insert(self.selectList, uid)
    end)

    self:AddEvent(EventDefines.UIMailDel, function(uid, index)
        self.allSelect = false
        for i,v in pairs(self.selectList) do
            if v == uid then
                table.remove(self.selectList, i)
            end
        end
    end)

    self:AddEvent(EventDefines.UIReqMails,function(rsp)
        self:RefreshView()
        self:RefreahBtn()
        self:refreshNotRead()
        self._panel:RefreshData()
    end)

    self:AddEvent(MAILEVENTTYPE.MailsReadEvent, function(rsp)
        self.mianInfo = MailModel:GetInfoByType(self.type)
        self._listView.numItems = #self.mianInfo.info
        if #self.mianInfo.info > 0 then
            self._textNo.visible = false
        else
            self._textNo.visible = true
        end
        self:RefreahBtn()
        self:refreshNotRead()
        self._panel:RefreshData()
    end)

    self:AddEvent(MAILEVENTTYPE.MailRefresh, function()
        self:RefreshView()
        self:RefreahBtn()
        self:refreshNotRead()
        self._panel:RefreshData()
    end)

    self:AddEvent(MAILEVENTTYPE.MailNewMsg, function()
        self:RefreshView()
        self:RefreahBtn()
        self:refreshNotRead()
        self._panel:RefreshData()
    end)
end

function Mail_News:RefreshView( )
    self.mianInfo = MailModel:GetInfoByType(self.type)
    if self.type == MAIL_TYPE.Msg then
        self:updateMsgdata(self.mianInfo)
    end
    self._listView.numItems = #self.mianInfo.info
    if #self.mianInfo.info > 0 then
        self._textNo.visible = false
    else
        self._textNo.visible = true
    end
end

function Mail_News:refreshListItems( )
    self.mianInfo = MailModel:GetInfoByTypeOrRaise(self.type)
    if self.type == MAIL_TYPE.Msg then
        self:updateMsgdata(self.mianInfo)
    end
    if self._listView.numItems == #self.mianInfo.info then
        return
    end
    self._listView.numItems = #self.mianInfo.info
    if #self.mianInfo.info > 0 then
        self._textNo.visible = false
    else
        self._textNo.visible = true
    end
end

function Mail_News:listViewRemoveClick( )
    self.initListClick = false
    self:ClearListener(self._listView.onClickItem)
end

function Mail_News:DeleteSelectMsg( )
    if #self.selectList >= #self.mianInfo.info then
        Net.Mails.DeleteAllSessions(function(msg)
            MailModel:deleteMsgGroup(self.selectList)
            self:RefreshData()
            self:refreshListItems()
            self._ctrView.selectedIndex = 0
            Event.Broadcast(EventDefines.UIMailsNumChange, {})
        end)
    else
        Net.Mails.DeleteSession(self.selectList,function()
            MailModel:deleteMsgGroup(self.selectList)
            self:RefreshData()
            self:refreshListItems()
            self._ctrView.selectedIndex = 0
            Event.Broadcast(EventDefines.UIMailsNumChange, {})
        end)
    end
end

function Mail_News:DeleteSelectMails( )

end

function Mail_News:listViewAddClick()
    self.initListClick = true
    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        local data =  item:getData()
        local subtype
        if self.type == MAIL_TYPE.Msg then
            subtype = data.Category
        else
            subtype = math.floor(data.SubCategory)
        end
        item:SetRead()
        local index = self._listView:ChildIndexToItemIndex(self._listView:GetChildIndex(item))+1
        if self.type == MAIL_TYPE.PVPReport then
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
        elseif self.type == MAIL_TYPE.Sports then       --竞技场邮件
            if MAIL_SUBTYPE.MailSubTypeSports then
                UIMgr:Open("MailWarReport", self.type, index, data, self)
            end
        elseif self.type == MAIL_TYPE.Alliance then
            if subtype == MAIL_SUBTYPE.subOrderReport       --联盟指令
                or subtype == MAIL_SUBTYPE.subAllianceBuildRecovery --联盟建筑回收
                or subtype == MAIL_SUBTYPE.subAllianceBuildPlace then   --联盟建筑放置通知
                UIMgr:Open("MailAllianceSystemInformation", self.type, index, data, self)
            elseif subtype == MAIL_SUBTYPE.subAllianceAssistRes then --援助资源
                UIMgr:Open("MailAllianceAssistance", self.type, index, data, self)
            elseif subtype == MAIL_SUBTYPE.subAllianceAssistArmies then  --援助士兵
                UIMgr:Open("MailAllianceTroopAssistance", self.type, index, data, self)
            elseif subtype == MAIL_SUBTYPE.subAllianceInvite then    --入盟邀请
                UIMgr:Open("MailAllianceInvitation", self.type, index, data, self)
            elseif subtype == MAIL_SUBTYPE.subAlliance              --联盟通知
                or subtype == MAIL_SUBTYPE.subAllianceBuildcomplete then    --联盟建筑完工
                UIMgr:Open("MailUnion", self.type, index, data, self)
            end
        elseif self.type == MAIL_TYPE.Activity then
            if subtype == MAIL_SUBTYPE.subTypeActiveCombat then      --活动集结怪邮件
                UIMgr:Open("Mail_FieldEnemyActivityAggregation", self.type, index, data, self)
            else
                UIMgr:Open("MailUnion", self.type, index, data, self)
            end
        elseif self.type == MAIL_TYPE.System or self.type == MAIL_TYPE.Studio then
            if subtype == MAIL_SUBTYPE.subMailSubTypeNewPlayer then    --新手邮件
                UIMgr:Open("MailUnion", self.type, index, data, self)
            elseif subtype == MAIL_SUBTYPE.subMailSubTypeForceUpgrade then  --强更提醒邮件
                UIMgr:Open("MailUnion", self.type, index, data, self)
            else
                UIMgr:Open("MailUnion", self.type, index, data, self)
            end
        elseif self.type == MAIL_TYPE.Msg then
            MailModel:UpdateMsgSessionInfo(data.Uuid, function()
                UIMgr:Open("Mail_PersonalNews", self.type, index, data, self)
            end)
        end
    end)
end
function Mail_News:setSelect(isSelect)
    for i,v in pairs(self.mianInfo.info) do
        v._select = isSelect
    end
end

return Mail_News