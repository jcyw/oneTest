-- author:{Amu}
-- time:2019-06-15 10:23:16
local SHOW_TYPE = {
    SearchView = 0,
    UnionView = 1
}

local UnionModel = import("Model/UnionModel")


local MailPersonalNews_AddFriends_SelectObject = UIMgr:NewUI("MailPersonalNews_AddFriends_SelectObject")

function MailPersonalNews_AddFriends_SelectObject:OnInit()
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnReturn")

    self._btnSearchView = self._view:GetChild("btnTagSingle1")
    self._btnUnionView = self._view:GetChild("btnTagSingle2")
    self._btnSearch = self._view:GetChild("btnSearch")
    self._btnAdd = self._view:GetChild("btnBlue")
    
    self._itemJoin = self._view:GetChild("itemJoin")
    self._btnJoin = self._itemJoin:GetChild("btnJoin")


    self._inputText = self._view:GetChild("textSearch")
    self._notFoundTip = self._view:GetChild("groupNotFound")

    self._listViewSearch = self._view:GetChild("liebiaoSearch")
    self._listViewUnion = self._view:GetChild("liebiaoUnion")


    self._ctrView = self._view:GetController("c1")

    self:InitEvent()
end

function MailPersonalNews_AddFriends_SelectObject:InitEvent()
    self:AddListener(self._btnReturn.onClick,function() 
        self:Close()
    end)

    self:AddListener(self._btnSearchView.onClick,function()
        self:ChangeView(SHOW_TYPE.SearchView)
    end)

    self:AddListener(self._btnUnionView.onClick,function() 
        self:ChangeView(SHOW_TYPE.UnionView)
    end)

    self:AddListener(self._btnSearch.onClick,function()
        if self._inputText.text == "" then
            TipUtil.TipById(50220)
            return
        elseif string.len(self._inputText.text) < 2 then
            TipUtil.TipById(50221)
            return
        end
        Net.UserInfo.Search(self._inputText.text, 20, function(msg)
            if #msg.UserSearchInfos > 0 then
                self.PlayerInfos = msg.UserSearchInfos
                for i = #self.PlayerInfos, 1, -1 do
                    for k,v in ipairs(self.members)do
                        if self.PlayerInfos[i].Uuid == v.UserId then
                            table.remove(self.PlayerInfos, i)
                            break
                        end
                    end
                end
                self:RefreshListView()
            else
                TipUtil.TipById(50090)
            end
        end)
    end)

    self:AddListener(self._btnJoin.onClick,function()
        UIMgr:Open("UnionView/UnionView")
    end)

    self:AddListener(self._btnAdd.onClick,function() 
        if self.groupInfo.subCategory == MAIL_SUBTYPE.subPersonalMsg then
            local _m = {}
            for _,v in pairs(self.members)do
                table.insert(_m, v.UserId)
            end
            for _,v in pairs(self.selectList)do
                local flag = true
                for _,member in pairs(self.members)do
                    if v == member.UserId then
                        flag = false
                    end
                end
                if flag then
                    table.insert(_m, v)
                end
            end
            Net.Mails.AddToGroup("", _m, function(msg)
                TipUtil.TipById(50091)
                self.isCreat = true
                self.groupInfo.sessionId = msg.SessionId
                UIMgr:Close("MailPersonalNews_AddFriends")
                self:Close()
                UIMgr:Close("Mail_PersonalNews")
                self._panel:RefreshList()
            end)
        elseif self.groupInfo.subCategory == MAIL_SUBTYPE.subGroupMsg then
            if #self.selectList <= 0 then
                TipUtil.TipById(50092)
                return
            end
            Net.Mails.AddToGroup(self.groupInfo.sessionId, self.selectList, function(msg)
                TipUtil.TipById(50093)
                self:Close()
                self._panel:RefreshList()
            end)
        end
    end)

    self._listViewSearch.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self.PlayerInfos[index+1])
    end

    self._listViewSearch:SetVirtual()

    self._listViewUnion:SetVirtual()

    self._listViewUnion.itemProvider = function(index)
        if not index then 
            return
        end
        
        if index == 0
         or index == self._r5 + 1 
         or index == self._r5 + self._r4 + 2 
         or index == self._r5 + self._r4 + self._r3 + 3
         or index == self._r5 + self._r4 + self._r3 + self._r2 + 4 then
            return "ui://Mail/itemMailPersonalNewsSelectObject_tag"
        else
            return "ui://Mail/itemMailPersonalNewsSelectObject"
        end
    end

    self._listViewUnion.itemRenderer = function(index, item)
        if not index then 
            return
        end
        if index == 0 then
            item:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Class_R'..ALLIANCEPOS.R5)
        elseif index == self._r5 + 1 then
            item:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Class_R'..ALLIANCEPOS.R4)
        elseif index == self._r5 + self._r4 + 2 then
            item:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Class_R'..ALLIANCEPOS.R3)
        elseif index == self._r5 + self._r4 + self._r3 + 3 then
            item:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Class_R'..ALLIANCEPOS.R2)
        elseif index == self._r5 + self._r4 + self._r3 + self._r2 + 4 then
            item:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Class_R'..ALLIANCEPOS.R1)
        else
            if index < self._r5 + 1 then
                item:SetData(self.unionMembers[index])
            elseif index < self._r5 + self._r4 + 2 then
                item:SetData(self.unionMembers[index-1])
            elseif index < self._r5 + self._r4 + self._r3 + 3 then
                item:SetData(self.unionMembers[index-2])
            elseif index < self._r5 + self._r4 + self._r3 + self._r2 + 4 then
                item:SetData(self.unionMembers[index-3])
            elseif index > self._r5 + self._r4 + self._r3 + self._r2 + 4 then
                item:SetData(self.unionMembers[index-4])
            end
        end
    end


    self:AddEvent(CHAT_GROUP_EVNET.Add, function(playId)
        for _,v in ipairs(self.selectList)do
            if v == playId then
                return
            end
        end
        -- for _,v in ipairs(self.members)do
        --     if v.UserId == playId then
        --         return
        --     end
        -- end
        table.insert(self.selectList, playId)
    end)

    self:AddEvent(CHAT_GROUP_EVNET.Del, function(playId)
        for k,v in ipairs(self.selectList)do
            if v == playId then
                table.remove(self.selectList, k)
                break
            end
        end
    end)

    self:AddEvent(MAILEVENTTYPE.MailNewMsgGroup, function()
        if self.isCreat then
            UIMgr:Open("Mail_PersonalNews", MAIL_TYPE.Msg, 1, MailModel:GetMsgInfoByType(self.groupInfo.sessionId))
            self.isCreat = false
        end
    end)
end

function MailPersonalNews_AddFriends_SelectObject:OnOpen(members, groupInfo, panel)
    self.members = members
    self.groupInfo = groupInfo
    self._panel = panel

    self._ctrView.selectedIndex = 0
    self.showType = SHOW_TYPE.SearchView
    self.selectList = {}
    self.PlayerInfos = {}
    self.unionMembers = {}
    self._inputText.text = ""

    if Model.Player.AllianceId == "" then
        self:ChangeView(self.showType)
    else
        Net.Alliances.Members(Model.Player.AllianceId, function(msg)
            self.unionMembers = msg.Members
            for i = #self.unionMembers, 1, -1 do
                for k,v in ipairs(self.members)do
                    if self.unionMembers[i].Id == v.UserId then
                        table.remove(self.unionMembers, i)
                        break
                    end
                end
            end
            table.sort(self.unionMembers, function(a, b)
                return a.Position > b.Position
            end)
            self.formatMember = UnionModel:FormatMember(self.unionMembers)
            self._r5 = self.formatMember[ALLIANCEPOS.R5] and #self.formatMember[ALLIANCEPOS.R5] or 0
            self._r4 = self.formatMember[ALLIANCEPOS.R4] and #self.formatMember[ALLIANCEPOS.R4] or 0
            self._r3 = self.formatMember[ALLIANCEPOS.R3] and #self.formatMember[ALLIANCEPOS.R3] or 0
            self._r2 = self.formatMember[ALLIANCEPOS.R2] and #self.formatMember[ALLIANCEPOS.R2] or 0
            self:ChangeView(self.showType)
        end)
    end
    self:RefreshListView()
end

function MailPersonalNews_AddFriends_SelectObject:ChangeView(type)
    if self.showType == type then
        return
    end
    self.showType = type
    self._ctrView.selectedIndex = type
    self:RefreshListView()
end

function MailPersonalNews_AddFriends_SelectObject:RefreshListView()
    if self.showType == SHOW_TYPE.SearchView then
        self._listViewSearch.numItems  = #self.PlayerInfos
        if #self.PlayerInfos > 0 then
            self._notFoundTip.visible = false
        else
            self._notFoundTip.visible = true
        end
    elseif self.showType == SHOW_TYPE.UnionView then
        if Model.Player.AllianceId == "" then
            self._itemJoin.visible = true
            self._listViewUnion.numItems = 0
        else
            self._itemJoin.visible = false
            self._listViewUnion.numItems = #self.unionMembers + 5
        end
    end
end

function MailPersonalNews_AddFriends_SelectObject:Close()
    UIMgr:Close("MailPersonalNews_AddFriends_SelectObject")
end

return MailPersonalNews_AddFriends_SelectObject