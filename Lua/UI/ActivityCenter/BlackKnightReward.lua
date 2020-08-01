--[[
    author:{zhanzhang}
    time:2019-11-29 21:35:27
    function:{黑骑士奖励}
]]
local BlackKnightReward = UIMgr:NewUI("BlackKnightReward")

function BlackKnightReward:OnInit()
    local view = self.Controller.contentPane
    self._rankController = view:GetController("c1")

    self:OnRegister()
end

function BlackKnightReward:OnRegister()
    self.refreshFunc = function()
        self:OnRefreshTime()
    end
    --配置初始化
    self.configReward = ConfigMgr.GetList("configKnightRewards")
    self.rewardList = {}
    for i = 1, 3 do
        self.rewardList[i] = {}
    end
    for i = 1, #self.configReward do
        local itemConfig = self.configReward[i]
        table.insert(self.rewardList[itemConfig.type], itemConfig)
    end

    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("BlackKnightReward")
        end
    )
    self:AddListener(self._btnHelp.onClick,
        function()
            UIMgr:Open("BlackKnightGetGrade")
        end
    )
    --积分配置显示
    self._gradeContent:SetVirtual()
    self._gradeContent.itemRenderer = function(index, item)
        item:Init(index + 1, self.rewardList[1][index + 1], self.data)
    end

    -- self._rankContent:SetVirtual()
    -- self._rankContent.itemRenderer = function(index, item)
    --     item:Init(index + 1, self.rewardList[self.InfoIndex][index + 1])
    -- end

    self:AddListener(self._btnPoints.onClick,
        function()
            self:RankReward()
        end
    )
    self:AddListener(self._btnUnion.onClick,
        function()
            self:UnionRank()
        end
    )
    self:AddListener(self._btnPersonal.onClick,
        function()
            self:PersonRank()
        end
    )
end

function BlackKnightReward:OnOpen(data, activityTime, activityInfo)
    -- AlliancePos:0
    -- AllianceScore:0
    -- PlayerPos:1
    -- PlayerScore:0
    self.data = data
    self.activityInfo = activityInfo
    self.activityTime = activityTime
    self:RankReward()
    self:Schedule(self.refreshFunc, 1, true)
end
--积分奖励
function BlackKnightReward:RankReward()
    self.InfoIndex = 1
    self._rankController.selectedIndex = 0
    self._textMy.text = StringUtil.GetI18n(I18nType.Commmon, "UI_PERSONAL_POINTS", {num = self.data.PlayerScore})
    self._textUnion.text = StringUtil.GetI18n(I18nType.Commmon, "UI_UNION_POINTS", {num = self.data.AllianceScore})

    self._gradeContent.numItems = #self.rewardList[1]
end

--帮会积分榜
function BlackKnightReward:UnionRank()
    self.InfoIndex = 2
    self._rankController.selectedIndex = 1
    self._textMy.text = StringUtil.GetI18n(I18nType.Commmon, "UI_UNION_POINTS", {num = self.data.AllianceScore})
    if self.data.AlliancePos > 0 then
        self._textUnion.text = StringUtil.GetI18n(I18nType.Commmon, "UI_MY_UNION_RANK", {num = self.data.AlliancePos})
    else
        self._textUnion.text = StringUtil.GetI18n(I18nType.Commmon, "UI_MY_UNION_RANK", {num = StringUtil.GetI18n(I18nType.Commmon, "UI_RANK_NONE")})
    end

    self._rankContent:RemoveChildrenToPool()
    local item = self._rankContent:AddItemFromPool()
    item:Init(1, self.rewardList[3][1], 2, false)
end
--个人积分
function BlackKnightReward:PersonRank()
    self.InfoIndex = 3
    self._rankController.selectedIndex = 2
    self._textMy.text = StringUtil.GetI18n(I18nType.Commmon, "UI_PERSONAL_POINTS", {num = self.data.PlayerScore})
    if self.data.PlayerPos > 0 then
        self._textUnion.text = StringUtil.GetI18n(I18nType.Commmon, "UI_MY_PERSONAL_RANK", {num = self.data.PlayerPos})
    else
        self._textUnion.text = StringUtil.GetI18n(I18nType.Commmon, "UI_MY_PERSONAL_RANK", {num = StringUtil.GetI18n(I18nType.Commmon, "UI_RANK_NONE")})
    end

    self._rankContent:RemoveChildrenToPool()
    local item = self._rankContent:AddItemFromPool()
    item:Init(1, self.rewardList[2][1], 1, false)
end

function BlackKnightReward:OnRefreshTime()
    -- if self.InfoIndex == 1 then
    --     return
    -- end
    if self.activityInfo and self.activityInfo.EndTime > Tool.Time() then
        self._textTagTime.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_ATTACK_TIME", {time = TimeUtil.SecondToDHMS(self.activityInfo.EndTime - Tool.Time())})
    else
        local delay = self.activityTime.EndAt - Tool.Time()
        --联盟未开启活动
        if delay >= 0 and self.activityTime.StartAt < Tool.Time() then
            --在活动开启期间

            self._textTagTime.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_OVER_TIME", {time = TimeUtil.SecondToDHMS(delay)})
        else
            self._textTagTime.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_BEGIN_TIME", {time = TimeUtil.SecondToDHMS(self.activityTime.StartAt - Tool.Time())})
        end
    end
end

function BlackKnightReward:OnClose()
    self:UnSchedule(self.refreshFunc)
end
return BlackKnightReward
