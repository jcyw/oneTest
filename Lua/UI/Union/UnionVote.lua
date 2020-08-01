--author: 	Amu
--time:		2019-07-03 14:31:21

VOTEPANELTYPE = {}
VOTEPANELTYPE.Sponsor = 1 --发起投票
VOTEPANELTYPE.Record = 2 --投票纪录

local UnionModel = import("Model/UnionModel")

local UnionVote = UIMgr:NewUI("UnionVote")
UnionVote.selectItem = nil
UnionVote.initListClick = false
UnionVote.isClick = false

function UnionVote:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._textName = self._view:GetChild("textName")
    self._btnReturn = self._view:GetChild("btnReturn")
    self._btnHelp = self._view:GetChild("btnHelp")

    self._btnInventory = self._view:GetChild("btnInventory")
    self._btnStore = self._view:GetChild("btnStore")

    self._text = self._view:GetChild("text")

    self._group1 = self._view:GetChild("groupVote")
    self._group2 = self._view:GetChild("groupVoteRecordView")

    self._listView1 = self._view:GetChild("liebiaoVote")
    self._listView2 = self._view:GetChild("liebiaoRecordView")

    self._btnPublish = self._view:GetChild("btnPublish")

    self._btnManage = self._view:GetChild("btnManage")
    self._btnCancel = self._view:GetChild("btnCancel")
    self._btnDel = self._view:GetChild("btnDel")
    self._btnAll = self._view:GetChild("btnAll")

    self.voteList = {} --投票信息
    self.memberList = {} --投票成员信息
    self.voteRecordList = {} --选择的投票记录

    self:InitEvent()
end

function UnionVote:OnOpen()
    self:InitData()

    Net.Alliances.Members(
        Model.Player.AllianceId,
        function(rsp)
            self.members = UnionModel:FormatMember(rsp.Members)
            self:RefreahListView1()
            self.inputListView:RefreahMember(self.members)
            self.inputListView:InitPanel()
        end
    )
    self:ReqVoteList()
    if Model.Player.AlliancePos >= ALLIANCEPOS.R4 then
        self:ChangePage(VOTEPANELTYPE.Sponsor)
        self._btnInventory.selected = true
        self._btnManage.visible = true
    else
        self:ChangePage(VOTEPANELTYPE.Record)
        self._btnStore.selected = true
        self._btnManage.visible = false
    end
end

function UnionVote:InitData()
    self.isClick = false
    self.initListClick = false
    self.isSelectAll = false
    self._btnAll.text = StringUtil.GetI18n(I18nType.Commmon, "Button_Choose_All")
    self.voteList = {}
    self.voteRecordList = {}
end

function UnionVote:InitEvent()
    self:AddListener(self._btnReturn.onClick,
        function()
            --返回
            self:Close()
        end
    )

    self:AddListener(self._btnHelp.onClick,
        function()
            --帮助
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                info = StringUtil.GetI18n(I18nType.Commmon, "Ui_VoteTxt")
            }
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )

    self:AddListener(self._btnPublish.onClick,
        function()
            --发布
            local vote = self.inputListView:GetVote()
            if not vote then
                return
            end
            local member = self.inputListView:GetMembers()
            if not member then
                return
            end

            if #member == 1 then
                local data = {
                    content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Volt_tips_less"),
                    sureCallback = function()
                        Net.AllianceVote.InitiateVote(
                            vote,
                            member,
                            function()
                                TipUtil.TipById(50251)
                                self.inputListView:InitPanel()
                                self:ReqVoteList()
                            end
                        )
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
            elseif #member > 1 then
                Net.AllianceVote.InitiateVote(
                    vote,
                    member,
                    function()
                        TipUtil.TipById(50251)
                        self.inputListView:InitPanel()
                        self:ReqVoteList()
                    end
                )
            end
        end
    )

    self:AddListener(self._btnManage.onClick,
        function()
            --管理
            self.isClick = true
            if self.initListClick then
                self:ListViewRemoveClick()
            end
            self:RefreahListView2()
        end
    )

    self:AddListener(self._btnCancel.onClick,
        function()
            --取消
            self.isClick = false
            self.isSelectAll = false
            Event.Broadcast(UNIONVOTERECORDEVENT.DelAll)
            self._btnAll.text = StringUtil.GetI18n(I18nType.Commmon, "Button_Choose_All")
            if not self.initListClick then
                self:ListViewAddClick()
            end
            self:RefreahListView2()
        end
    )

    self:AddListener(self._btnDel.onClick,
        function()
            --删除
            if #self.voteRecordList == 0 then
                TipUtil.TipById(50261)
                return
            end
            Net.AllianceVote.DeleteVote(
                self.voteRecordList,
                function()
                    TipUtil.TipById(50222)
                    for i = #self.voteList, 1, -1 do
                        for k, v in pairs(UnionModel.notVoteList) do
                            if v == self.voteList[i].Uuid then
                                table.remove(UnionModel.notVoteList, k)
                                break
                            end
                        end
                        for _, v in pairs(self.voteRecordList) do
                            if self.voteList[i].Uuid == v then
                                table.remove(self.voteList, i)
                                break
                            end
                        end
                    end
                    Event.Broadcast(EventDefines.UIUnionManger)
                    self:RefreahListView2()
                end
            )
        end
    )

    self:AddListener(self._btnAll.onClick,
        function()
            --全选
            if not self.isSelectAll then
                Event.Broadcast(UNIONVOTERECORDEVENT.AddAll)
                self._btnAll.text = StringUtil.GetI18n(I18nType.Commmon, "Button_Choose_All_Cancel")
            else
                Event.Broadcast(UNIONVOTERECORDEVENT.DelAll)
                self._btnAll.text = StringUtil.GetI18n(I18nType.Commmon, "Button_Choose_All")
            end
        end
    )

    self:AddListener(self._btnInventory.onClick,
        function()
            if Model.Player.AlliancePos < ALLIANCEPOS.R4 then
                TipUtil.TipById(50241)
                self._btnStore.selected = true
                return
            end
            self:ChangePage(VOTEPANELTYPE.Sponsor)
        end
    )

    self:AddListener(self._btnStore.onClick,
        function()
            self:ChangePage(VOTEPANELTYPE.Record)
        end
    )

    self._listView1.itemRenderer = function(index, item)
        if not index then
            return
        end
        self.inputListView = item
        item:SetData(self, self.members)
    end
    self._listView1.scrollItemToViewOnClick = false
    self._listView1:SetVirtual()

    self._listView2.itemRenderer = function(index, item)
        if not index then
            return
        end
        -- if self.isClick then
        --     index = index
        -- else
        --     index = index+1
        -- end
        index = index + 1
        item:SetData(index, self.voteList[index], self.isClick, self.isSelectAll)
    end

    self._listView2.itemProvider = function(index)
        if not index then
            return
        end

        -- if self.isClick and index == 0 then
        --     return "ui://Union/itemUnionVoteRecordViewSelectAll"
        -- end
        return "ui://Union/itemUnionVoteRecordView"
    end

    self._listView2:SetVirtual()

    --关闭下拉框
    local flag = false
    self:AddListener(self._listView1.onTouchBegin,
        function(context)
            flag = true
        end
    )
    self:AddListener(self._listView1.onTouchMove,
        function()
            if flag then
                flag = false
                GRoot.inst:HidePopup()
            end
        end
    )

    self:AddEvent(
        UNIONVOTERECORDEVENT.AddAll,
        function()
            self.isSelectAll = true
            self.voteRecordList = {}
            for k, v in ipairs(self.voteList) do
                v._select = true
                table.insert(self.voteRecordList, v.Uuid)
            end
            self:RefreahListView2()
        end
    )

    self:AddEvent(
        UNIONVOTERECORDEVENT.DelAll,
        function()
            self.isSelectAll = false
            for k, v in ipairs(self.voteList) do
                v._select = false
            end
            self.voteRecordList = {}
            self:RefreahListView2()
        end
    )

    self:AddEvent(
        UNIONVOTERECORDEVENT.Add,
        function(uid, index)
            self.voteList[index]._select = true
            table.insert(self.voteRecordList, uid)
            self:RefreahListView2()
        end
    )

    self:AddEvent(
        UNIONVOTERECORDEVENT.Del,
        function(uid, index)
            self.voteList[index]._select = false
            for k, v in pairs(self.voteRecordList) do
                if v == uid then
                    table.remove(self.voteRecordList, k)
                    break
                end
            end
            self:RefreahListView2()
        end
    )

    self:AddEvent(
        UNIONVOTERECORDEVENT.Del,
        function(uid, index)
            self.voteList[index]._select = false
            for k, v in pairs(self.voteRecordList) do
                if v == uid then
                    table.remove(self.voteRecordList, k)
                    break
                end
            end
            self:RefreahListView2()
        end
    )

    self:AddEvent(
        UNIONVOTE.Ok,
        function()
            self:ReqVoteList()
        end
    )
end

function UnionVote:RefreahListView1()
    self._listView1.numItems = 1
end

function UnionVote:RefreahListView2()
    if self.isClick then
        -- self._listView2.numItems = #self.voteList+1
        self._listView2.numItems = #self.voteList
        self._btnManage.visible = false
        self._btnCancel.visible = true
        self._btnDel.visible = true
        self._btnAll.visible = true
    else
        self._listView2.numItems = #self.voteList
        -- self._btnManage.visible = true
        self._btnCancel.visible = false
        self._btnDel.visible = false
        self._btnAll.visible = false
        if Model.Player.AlliancePos >= ALLIANCEPOS.R4 then
            self._btnManage.visible = true
        else
            self._btnManage.visible = false
        end
    end
end

function UnionVote:ChangePage(type)
    self.showType = type
    if type == VOTEPANELTYPE.Sponsor then
        self._group1.visible = true
        self._group2.visible = false
        self._text.visible = false
        self._textName.text = self._btnInventory.text
        Event.Broadcast(UNIONVOTECOUNTDOWNEVNET.End)
    elseif type == VOTEPANELTYPE.Record then
        self._group1.visible = false
        self._group2.visible = true
        self._text.visible = false
        self._textName.text = self._btnStore.text
        if not self.initListClick then
            self:ListViewAddClick()
        end
        self.isClick = false
        Event.Broadcast(UNIONVOTECOUNTDOWNEVNET.Start)
    end
    if self.voteList and #self.voteList <= 0 and self.showType == VOTEPANELTYPE.Record then
        self._text.visible = true
    else
        self._text.visible = false
    end
end

function UnionVote:ListViewRemoveClick()
    self.initListClick = false
    self:ClearListener(self._listView2.onClickItem)
end

function UnionVote:ListViewAddClick()
    self.initListClick = true
    self:AddListener(self._listView2.onClickItem,
        function(context)
            local item = context.data
            local data = item:getData()
            UIMgr:Open("UnionVoteing", data)
        end
    )
end

function UnionVote:SetSelect(isSelect)
    for i, v in pairs(self.info) do
        v._select = isSelect
    end
end

function UnionVote:ReqVoteList()
    Net.AllianceVote.RequestVoteList(
        Model.Player.AllianceId,
        function(msg)
            self.voteList = msg.VoteList
            if self.voteList and #self.voteList <= 0 and self.showType == VOTEPANELTYPE.Record then
                self._text.visible = true
            else
                self._text.visible = false
            end
            table.sort(
                self.voteList,
                function(a, b)
                    return a.Start > b.Start
                end
            )
            self.memberList = msg.MemberList
            for k, v in ipairs(self.voteList) do
                for _, member in ipairs(self.memberList) do
                    if not v.members then
                        v.members = {}
                    end
                    if v.Uuid == member.Uuid then
                        table.insert(v.members, member)
                    end
                end
            end
            for i = #self.voteList, 1, -1 do
                local info = self.voteList[i]
                if info.Visible == 1 then
                    local members = self.voteList[i].members
                    table.remove(self.voteList, i)
                    for _, v in pairs(members) do
                        if UserModel.data.accountId == v.PlayerId then
                            table.insert(self.voteList, i, info)
                            break
                        end
                    end
                end
            end

            local members, _flag
            for _, v in pairs(self.voteList) do
                if (v.Start + v.Time) < Tool.Time() then
                    break
                end
                members = v.members
                for _, member in pairs(members) do
                    if UserModel.data.accountId == member.PlayerId and #member.Votes <= 0 then
                        _flag = false
                        for _, uid in pairs(UnionModel.notVoteList) do
                            if uid == v.Uuid then
                                _flag = true
                            end
                        end
                        if _flag then
                            break
                        end
                        table.insert(UnionModel.notVoteList, v.Uuid)
                        break
                    end
                end
            end
            Event.Broadcast(EventDefines.UIUnionManger)
            self:RefreahListView2()
        end
    )
end

function UnionVote:Close()
    UIMgr:Close("UnionVote")
end

function UnionVote:OnClose()
    Event.Broadcast(UNIONVOTECOUNTDOWNEVNET.End)
end

return UnionVote
