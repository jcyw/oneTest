--[[
    author:{laofu}
    time:2020-06-10 19:29:51
    function:{新城竞赛排名页}
]]
local GD = _G.GD
local NewWarZoneRankPage = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/NewWarZoneRank", NewWarZoneRankPage)

function NewWarZoneRankPage:ctor()
    self._c1 = self:GetController("c1")

    self._btns = {}
    for i = 0, 2, 1 do
        local btn = self:GetChild("btn" .. i)
        self._btns[i] = btn
    end

    self._title = self:GetChild("title")
    self._timer = self:GetChild("time")

    self._list = self:GetChild("list")
    self._list:SetVirtual()

    self._btns[0].title = StringUtil.GetI18n(I18nType.Commmon, "UI_POWER_RANK_NEWA_WARZONE")
    self._btns[1].title = StringUtil.GetI18n(I18nType.Commmon, "UI_CENTRE_RANK_NEWA_WARZONE")
    self._btns[2].title = StringUtil.GetI18n(I18nType.Commmon, "UI_LEVEL_RANK_NEWA_WARZONE")

    self.TITLE = {
        [1] = StringUtil.GetI18n(I18nType.Commmon, "UI_FIRST_RANK_REWARD"),
        [2] = StringUtil.GetI18n(I18nType.Commmon, "UI_SECOND_RANK_REWARD")
    }

    self:InitEvent()
end

function NewWarZoneRankPage:InitEvent()
    for type, btn in pairs(self._btns) do
        self:AddListener(
            btn.onClick,
            function()
                self:SetList(type)
            end
        )
    end

    self._list.itemRenderer = function(index, item)
        local rankInfo = self.configRankInfos[index + 1]
        item:SetData(rankInfo)
    end

    self:AddEvent(
        EventDefines.CloseNewWarZoneRankPageTimer,
        function()
            self:UnSchedule(self.timer)
        end
    )
end

function NewWarZoneRankPage:SetList(type)
    self.configRankInfos = GD.NewWarZoneActivityAgent.GetPeakWayRankConifg(type)
    self._list.numItems = #self.configRankInfos
    self._list.scrollPane:ScrollTop()
end

function NewWarZoneRankPage:SetTimer(endAt)
    if self.timer then
        self:UnSchedule(self.timer)
    end

    local cutTime = function()
        return endAt - Tool.Time()
    end
    self.timer = function()
        self._timer.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RANK_REWARD_TIME", {time = Tool.FormatTime(cutTime())})
    end
    self:Schedule(self.timer, 1)
end

function NewWarZoneRankPage:ViewRank(rank)
    if rank > 500 then
        return "500+"
    else
        return _G.tostring(rank)
    end
end

function NewWarZoneRankPage:RefreshContent()
    self._title.text = self.TITLE[self.rankServerInfo.Period]

    for k, btn in pairs(self._btns) do
        local rankText = btn:GetChild("num")
        if k == 0 then
            rankText.text = self:ViewRank(self.rankServerInfo.PowerRank)
        elseif k == 1 then
            rankText.text = self:ViewRank(self.rankServerInfo.BaseRank)
        elseif k == 2 then
            rankText.text = self:ViewRank(self.rankServerInfo.PlayerLvRank)
        end
    end

    self:SetList(self._c1.selectedIndex)
    self:SetTimer(self.rankServerInfo.SettleAt)
end

function NewWarZoneRankPage:OpenPage(rankServerInfo)
    self.rankServerInfo = rankServerInfo
    self:RefreshContent()
end

return NewWarZoneRankPage
