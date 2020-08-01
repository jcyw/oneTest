--author: 	Amu
--time:		2019-07-03 14:31:30
local UnionModel = import("Model/UnionModel")

local UnionVoteing = UIMgr:NewUI("UnionVoteing")
UnionVoteing.selectList = {}

local GlobalVars = GlobalVars
local callback

function UnionVoteing:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._btnReturn = self._view:GetChild("btnReturn")

    self._textName = self._view:GetChild("textName")

    self._btnHelp = self._view:GetChild("btnHelp")
    self._btnview = self._view:GetChild("btnview")
    self._btnPublish = self._view:GetChild("btnPublish")

    self._textChooseOne = self._view:GetChild("textChooseOne")

    self._textTitle = self._view:GetChild("textTitle")
    self._textInputContent = self._view:GetChild("textInputContent")
    self._textTime = self._view:GetChild("textTime")

    self._listView = self._view:GetChild("liebiao")

    self:InitEvent()
end

function UnionVoteing:OnOpen(info)
    self.info = info

    self._endTime = info.Start + info.Time
    self._schedule = false
    self._textTitle.text = info.Title
    self._textInputContent.text = info.Content

    self.isVote = false
    self.isVoteMem = false
    self.votes = {}
    for _, v in pairs(info.members) do
        if v.PlayerId == Model.Account.accountId then
            self.isVoteMem = true
            if #v.Votes > 0 then
                self.isVote = true
                self.votes = v.Votes
            end
        end
    end

    self.textList = {info.Content, info.Title}
    for _, v in ipairs(info.Options) do
        table.insert(self.textList, v)
    end

    self:StartCountDown()
    callback()

    self.selectList = {}
    self._btnHelp.selected = GlobalVars.UnionVoteingIsTranslated
    if GlobalVars.UnionVoteingIsTranslated then
        self:Translated()
    else
        self:RefreahListView()
    end
end

function UnionVoteing:InitEvent()
    self:AddListener(self._btnReturn.onClick,
        function()
            --返回
            self:Close()
        end
    )

    self:AddListener(self._btnview.onClick,
        function()
            UIMgr:Open("UnionVoteParticipants", self.info.members)
        end
    )

    self:AddListener(self._btnHelp.onClick,
        function()
            if GlobalVars.UnionVoteingIsTranslated then
                GlobalVars.UnionVoteingIsTranslated = false
                self:Refresh()
            else
                GlobalVars.UnionVoteingIsTranslated = true
                self:Translated()
            end
        end
    )

    self:AddListener(self._btnPublish.onClick,
        function()
            if (self._endTime - Tool.Time()) <= 0 then
                --在聊天种展示结果
                local msg = {
                    id = self.info.Uuid,
                    title = self.info.Title
                }
                Net.Chat.SendChat(
                    Model.Player.AllianceId,
                    Model.Account.accountId,
                    "",
                    ALLIANCE_CHAT_TYEP.Voting,
                    JSON.encode(msg),
                    function()
                        TipUtil.TipById(50252)
                    end
                )
            else
                if not self.isVoteMem then
                    TipUtil.TipById(50253)
                    return
                end
                if self.isVote then
                    TipUtil.TipById(50254)
                    return
                end
                local vote = {}
                vote.Uuid = self.info.Uuid
                vote.PlayerId = UserModel.data.accountId
                vote.Votes = self.selectList
                if #vote.Votes == 0 then
                    TipUtil.TipById(50262)
                    return
                elseif #vote.Votes > self.info.VoteNum then
                    TipUtil.TipById(50255, {number = self.info.VoteNum})
                    return
                end
                Net.AllianceVote.Vote(
                    vote,
                    function()
                        TipUtil.TipById(50263)
                        self.isVote = true
                        Event.Broadcast(UNIONVOTE.Ok)
                        self.votes = self.selectList
                        self:RefreahListView()
                        for k, v in pairs(UnionModel.notVoteList) do
                            if v == vote.Uuid then
                                table.remove(UnionModel.notVoteList, k)
                                self:Close()
                                return
                            end
                        end
                    end
                )
            end
        end
    )

    self._listView.itemRenderer = function(index, item)
        if not index then
            return
        end

        if (self._endTime - Tool.Time()) <= 0 then
            item:SetData(self.info, index, GlobalVars.UnionVoteingIsTranslated)
        else
            if GlobalVars.UnionVoteingIsTranslated then
                item:SetData(self.info.TOptions[index + 1], self.isVote, self.votes)
            else
                item:SetData(self.info.Options[index + 1], self.isVote, self.votes)
            end
        end
    end
    self._listView:SetVirtual()

    self._listView.itemProvider = function(index)
        if not index then
            return
        end
        if (self._endTime - Tool.Time()) <= 0 then
            return "ui://Union/itemUnionVoteResult"
        else
            return "ui://Union/itemUnionVoteing"
        end
    end

    self:AddEvent(
        UNIONVOTE.Add,
        function(info)
            table.insert(self.selectList, info)
        end
    )

    self:AddEvent(
        UNIONVOTE.Del,
        function(info)
            for k, v in pairs(self.selectList) do
                if v == info then
                    table.remove(self.selectList, k)
                    break
                end
            end
        end
    )

    callback = function()
        if not self._endTime then
            return
        end
        local time = self._endTime - Tool.Time()
        if time <= 0 then
            self:UnSchedule(callback)
            self._scheduler = false
            self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Cutoff")
            self._btnPublish.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Result")
            self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Cutoff")
            self._textChooseOne.visible = false
            return
        end
        self._textTime.text =
            StringUtil.GetI18n(
            I18nType.Commmon,
            "Ui_Vote_Deadline",
            {
                time = TimeUtil.SecondToHMS(time)
            }
        )
    end
end

function UnionVoteing:Translated()
    Net.Chat.Translate(
        4,
        self.info.Uuid,
        self.textList,
        function(msg)
            self.info.TOptions = {}
            for k, v in ipairs(msg.Content) do
                if k == 1 then
                    self.info.TContent = v
                elseif k == 2 then
                    self.info.TTitle = v
                else
                    table.insert(self.info.TOptions, v)
                end
            end
            self:Refresh()
        end
    )
end

function UnionVoteing:Refresh()
    if GlobalVars.UnionVoteingIsTranslated then
        self._textTitle.text = self.info.TTitle
        self._textInputContent.text = self.info.TContent
        self:RefreahListView()
    else
        self._textTitle.text = self.info.Title
        self._textInputContent.text = self.info.Content
        self:RefreahListView()
    end
end

function UnionVoteing:RefreahListView()
    self._listView.numItems = #self.info.Options
end

function UnionVoteing:StartCountDown()
    if not self._scheduler then
        self:Schedule(callback, 1)
        self._scheduler = true
        if self.isVote then
            self._btnPublish.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Have_voted")
        else
            self._btnPublish.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
        end
        self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Voteing")
        self._textChooseOne.visible = true
    end
end

function UnionVoteing:EndCountDown()
    self:UnSchedule(callback)
    self._scheduler = false
    self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Cutoff")
    self._btnPublish.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Result")
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Cutoff")
    self._textChooseOne.visible = false
    self:RefreahListView()
end

function UnionVoteing:Close()
    UIMgr:Close("UnionVoteing")
end

function UnionVoteing:OnClose()
    self:EndCountDown()
end

return UnionVoteing
