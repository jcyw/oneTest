--[[
    Author: songzeming
    Function: 排行榜界面
]]


local RankList = UIMgr:NewUI("RankList")

local RANK_TYPE = {
    RankByAllianceKills = Global.RankByAllianceKills,
    RankByAlliancePower = Global.RankByAlliancePower,
    RankByPlayerKills = Global.RankByPlayerKills,
    RankByPlayerPower = Global.RankByPlayerPower,
    RankByPlayerBuildingCenter = Global.RankByPlayerBuildingCenter,
    RankByPlayerLevel = Global.RankByPlayerLevel
}

function RankList:OnInit()
    self._view = self.Controller.contentPane
    self._ctrView = self._view:GetController("typeControl")
    self.rankListsInfo = ConfigMgr.GetList("configRankLists")

    self.selectBtnList = {
        [RANK_TYPE.RankByAlliancePower] = self._btnUnionPower,
        [RANK_TYPE.RankByAllianceKills] = self._btnUnionKill,
        [RANK_TYPE.RankByPlayerPower] = self._btnPower,
        [RANK_TYPE.RankByPlayerKills] = self._btnKill,
        [RANK_TYPE.RankByPlayerBuildingCenter] = self._btnHouseLevel,
        [RANK_TYPE.RankByPlayerLevel] = self._btnLevel,
    }

    self.ctrMap = {
        [RANK_TYPE.RankByAlliancePower] = 0,
        [RANK_TYPE.RankByAllianceKills] = 0,
        [RANK_TYPE.RankByPlayerPower] = 1,
        [RANK_TYPE.RankByPlayerKills] = 1,
        [RANK_TYPE.RankByPlayerBuildingCenter] = 1,
        [RANK_TYPE.RankByPlayerLevel] = 1,
    }

    self.limit = 10
    self.selectBtn = nil

    self:InitEvent()
end

function RankList:InitEvent()
    self:AddListener(self._btnReturn.onClick,function() 
        self:Close()
    end)

    self:AddListener(self._btnHelp.onClick,function() 
        local data = {
            title = StringUtil.GetI18n(I18nType.Commmon, 'Tips_TITLE'),
            info = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Rank_UpDateTime')
        }
        UIMgr:Open("ConfirmPopupTextList", data)
    end)

    self:AddListener(self._btnUnionPower.onClick,function()
        self.subType = RANK_TYPE.RankByAlliancePower
        self:ChangeView(RANK_TYPE.RankByAlliancePower)
    end)

    self:AddListener(self._btnUnionKill.onClick,function()
        self.subType = RANK_TYPE.RankByAllianceKills
        self:ChangeView(RANK_TYPE.RankByAllianceKills)
    end)

    self:AddListener(self._btnPower.onClick,function() 
        self.subType = RANK_TYPE.RankByPlayerPower
        self:ChangeView(RANK_TYPE.RankByPlayerPower)
    end)

    self:AddListener(self._btnKill.onClick,function() 
        self.subType = RANK_TYPE.RankByPlayerKills
        self:ChangeView(RANK_TYPE.RankByPlayerKills)
    end)

    self:AddListener(self._btnHouseLevel.onClick,function() 
        self.subType = RANK_TYPE.RankByPlayerBuildingCenter
        self:ChangeView(RANK_TYPE.RankByPlayerBuildingCenter)
    end)

    self:AddListener(self._btnLevel.onClick,function() 
        self.subType = RANK_TYPE.RankByPlayerLevel
        self:ChangeView(RANK_TYPE.RankByPlayerLevel)
    end)

    self:AddListener(self._list.onClickItem,function(context)
        local item = context.data
        local data = item:GetData()
        data.Alliance = data.AllianceShortName
        data.Name = data.UserName
        if self.mianType == Global.RankOfAllianceType then
            UIMgr:Open("UnionViewData", data.AllianceId)
        else
            if data.UserId == Model.Account.accountId then
                UIMgr:Open("PlayerInfo/PlayerInfo")
            else
                UIMgr:Open("RankMessageShield", data)
            end
        end
    end)

    self._list.itemRenderer = function(index, item)
        if not index then 
            return
        end
        local info = self.rankingInfo[self.subType].RankInfo[index+1];
        info.Rank = index+1;--清除重复数据后使用服务器的排名会出现跳段 这里使用数据下标顺序作为排名
        item:SetData(self.mianType, info)

        -- 设置新的刷新指示item
        local amount = #self.rankingInfo[self.subType].RankInfo
        if index + 1 == amount - 5 then
            self.tagItem = item
        end
    end

    self:AddListener(self._list.scrollPane.onScroll, function()
        if not self.isEnd and not self.isRefreshing and self.tagItem and self._list.scrollPane:IsChildInView(self.tagItem) then
            self.tagItem = nil
            self.isRefreshing = true
            self:RefreshListItems()
        end
    end)
    -- self._list.scrollItemToViewOnClick = false
    self._list:SetVirtual()
end

function RankList:OnOpen(mainType, subType)
    self.rankingInfo = {}
    self.mianType = mainType
    self.subType = subType
    self.tagItem = nil -- 刷新指示item。当该列表item显示出来时，请求更多的信息
    self.isEnd = false -- 是否已经刷新倒低
    self.isRefreshing = false
    self._title.text = (mainType == Global.RankOfAllianceType) and StringUtil.GetI18n(I18nType.Commmon, "rank_Alliance") or StringUtil.GetI18n(I18nType.Commmon, "rank_Player")
    self:ChangeView(self.subType)
end

function RankList:SetSubTitle(type)
    if type == RANK_TYPE.RankByAlliancePower or type == RANK_TYPE.RankByPlayerPower then
        self._textSubTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Power")
    elseif type == RANK_TYPE.RankByAllianceKills or type == RANK_TYPE.RankByPlayerKills then
        self._textSubTitle.text = StringUtil.GetI18n(I18nType.Commmon, "rank_kill")
    elseif type == RANK_TYPE.RankByPlayerLevel then
        self._textSubTitle.text = StringUtil.GetI18n(I18nType.Commmon, "rank_level")
    elseif type == RANK_TYPE.RankByPlayerBuildingCenter then
        self._textSubTitle.text = StringUtil.GetI18n(I18nType.Commmon, "rank_hqlevel")
    end
end

function RankList:ChangeView(type)
    self:SetSubTitle(type)

    if self.selectBtn then
        self.selectBtn.asButton.selected = false
    end
    self.selectBtnList[type].asButton.selected = true
    self.selectBtn = self.selectBtnList[type]
    
    self._ctrView.selectedIndex = self.ctrMap[type]
    
    self.tagItem = nil
    self.isRefreshing = true
    self.isEnd = false
    self._list.numItems = 0
    if not self.rankingInfo[type] then
        self.rankingInfo[type] = {}
        self.rankingInfo[type].offset = 1
        self.rankingInfo[type].RankInfo = {}
        self.rankingInfo[type].RankDic = {}--用来记录排名信息在数据表中的位置
        Net.Rank.RankInfo(type, self.rankingInfo[type].offset, self.limit, function(msg)
            self.isRefreshing = false
            self.rankingInfo[type].Category = msg.Category
            self.rankingInfo[type].SelfRank = msg.SelfRank
            self.rankingInfo[type].RankInfo = msg.RankInfo
            self.rankingInfo[type].offset = msg.Offset

            self._textRank.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Rank_My_Position")..((msg.SelfRank and msg.SelfRank > 0) and msg.SelfRank or StringUtil.GetI18n(I18nType.Commmon, "Button_Commander_UnRank"))
            self:RefreshListView()
        end)
    else
        self.isRefreshing = false
        self._textRank.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Rank_My_Position")..((self.rankingInfo[type].SelfRank and self.rankingInfo[type].SelfRank > 0) and self.rankingInfo[type].SelfRank or StringUtil.GetI18n(I18nType.Commmon, "Button_Commander_UnRank"))
        self:RefreshListView()
    end
end

function RankList:RefreshListView( )
    self._list.numItems = #self.rankingInfo[self.subType].RankInfo
end

function RankList:RefreshListItems( )
    if not self.rankingInfo[self.subType] then
        self.rankingInfo[self.subType] = {}
        self.rankingInfo[self.subType].offset = 0
        self.rankingInfo[self.subType].RankInfo = {}
    end

    Net.Rank.RankInfo(self.subType, self.rankingInfo[self.subType].offset, self.limit, function(msg)
        self.isRefreshing = false
        self.rankingInfo[self.subType].Category = msg.Category
        self.rankingInfo[self.subType].SelfRank = msg.SelfRank
        self.rankingInfo[self.subType].offset = msg.Offset
        
        for _,v in ipairs(msg.RankInfo)do
            table.insert(self.rankingInfo[self.subType].RankInfo, v)
            
            if not self.rankingInfo[self.subType].RankDic[v.UserId] then
                self.rankingInfo[self.subType].RankDic[v.UserId] = #self.rankingInfo[self.subType].RankInfo;
            end
        end

        self:RefreshListView()

        local amount = #self.rankingInfo[self.subType].RankInfo
        local info = self.rankingInfo[self.subType].RankInfo[amount - 5]
        if self.tagItem and info and self.tagItem.info.UserId == info.UserId then
            self.isEnd = true
        end
    end)
end

function RankList:Close( )
    UIMgr:Close("RankList")
end

return RankList
