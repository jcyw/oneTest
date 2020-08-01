--author: 	Amu
--time:		2019-07-08 14:59:16


local callback

local UnionDonateRank = UIMgr:NewUI("UnionDonateRank")

function UnionDonateRank:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._btnReturn = self._view:GetChild("btnReturn")

    self._btnDay = self._view:GetChild("btnDay")
    self._btnWeekly = self._view:GetChild("btnWeekly")
    self._btnHistory = self._view:GetChild("btnHistory")

    self._listView = self._view:GetChild("liebiao")

    self._textTime = self._view:GetChild("textTime")

    self._ctrView = self._view:GetController("c1")

    self.limit = 10
    self:InitEvent()
end

function UnionDonateRank:OnOpen()
    SdkModel.TrackBreakPoint(10074)      --打点
    self.info = {}
    self._scheduler = false
    self._ctrView.selectedIndex = 0
    self._listView.numItems = 0
    self.isRefreshing = false
    self:ChangeView(UNION_RANK_TYPE.UNIONRANKDAY)
end

function UnionDonateRank:InitEvent( )
    self:AddListener(self._btnReturn.onClick,function()--返回
        self:Close()
    end)

    self:AddListener(self._btnDay.onClick,function()--联盟捐献—日排行
        self:ChangeView(UNION_RANK_TYPE.UNIONRANKDAY)
    end)

    self:AddListener(self._btnWeekly.onClick,function()--联盟捐献—周排行
        self:ChangeView(UNION_RANK_TYPE.UNIONRANKWEEK)
    end)

    self:AddListener(self._btnHistory.onClick,function()--联盟捐献—历史排行
        self:ChangeView(UNION_RANK_TYPE.UNIONRANKHISTORY)
    end)

    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        local data = item:GetData()
        if data.UserId == UserModel.data.accountId then
            return
        end
        UIMgr:Open("UnionMessageShield", PLAYER_CONTACT_BOX_TYPE.RankBox, data)
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self.info[self.type].RankInfos[index+1])
    end
    self._listView:SetVirtual()

    self:AddListener(self._listView.scrollPane.onPullUpRelease,function()
        if not self.isRefreshing then
            self.isRefreshing = true
            self:RefreshListItems()
        end
    end)

    callback = function()
        if not self._endTime then
            return
        end
        local time = self._endTime - Tool.Time()
        if time <= 0 then
            self:UnSchedule(callback)
            self._scheduler = false
            return
        end
        self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, 'Onsale_Time_TItel', {time = TimeUtil.SecondToDHMS(time)})
    end
end

function UnionDonateRank:RefreahListView( )
    self._listView.numItems = #self.info[self.type].RankInfos
end

function UnionDonateRank:RefreshListItems( )
    Net.AllianceTech.ContriRank(Model.Player.AllianceId, self.type, self.info[self.type].Offset, self.limit, function(msg)
        self.isRefreshing = false
        self.info[self.type].Category = msg.Category
        self.info[self.type].Offset = msg.Offset
        self.info[self.type].RefreshTime = msg.RefreshTime
        for _,v in ipairs(msg.RankInfos)do
            table.insert(self.info[self.type].RankInfos, v)
        end
        if self._listView.numItems == #self.info[self.type].RankInfos then
            return
        end
        self:RefreahListView()
    end)
end

function UnionDonateRank:ChangeView(type)
    self.type = type
    self.isRefreshing = true
    if not self.info[type] or not self.info[type].RankInfos then
        self.info[type] = {}
        self.info[type].Offset = 0
        Net.AllianceTech.ContriRank(Model.Player.AllianceId, type, self.info[type].Offset, self.limit, function(msg)
            self.isRefreshing = false
            self.info[type].Category = msg.Category
            self.info[type].Offset = msg.Offset
            self.info[type].RefreshTime = msg.RefreshTime
            self.info[type].RankInfos = msg.RankInfos
            self._endTime = msg.RefreshTime
            if type == UNION_RANK_TYPE.UNIONRANKHISTORY then
                self:EndCountDown()
                self._textTime.visible = false
            else
                self:StartCountDown()
                self._textTime.visible = true
            end
            self:RefreahListView()
        end)
    else
        if type == UNION_RANK_TYPE.UNIONRANKHISTORY then
            self:EndCountDown()
            self._textTime.visible = false
        else
            self._endTime = self.info[type].RefreshTime
            self:StartCountDown()
            self._textTime.visible = true
        end
        self:RefreahListView()
    end
end

function UnionDonateRank:StartCountDown( )
    if not self._scheduler then
        callback()
        self:Schedule(callback, 1)
        self._scheduler = true
    end
end

function UnionDonateRank:EndCountDown( )
    self:UnSchedule(callback)
    self._scheduler = false
    self:RefreahListView()
end

function UnionDonateRank:Close( )
    UIMgr:Close("UnionDonateRank")
end

function UnionDonateRank:OnClose()
    self:UnSchedule(callback)
end

return UnionDonateRank