--[[
    author:{zhanzhang}
    time:2019-11-18 17:51:01
    function:{监狱探索功能}
]]
local PrisonExploration = UIMgr:NewUI("PrisonExploration")

function PrisonExploration:OnInit()
    local view = self.Controller.contentPane
    self._btnReturn = view:GetChild("btnReturn")
    self._progressBar = view:GetChild("ProgressBar")
    self._content = view:GetChild("liebiao")
    self._btnRetreat = view:GetChild("btnRetreat")
    self._content = view:GetChild("liebiao")
    self._textProgress = view:GetChild("textProgress")
    self:OnRegister()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.PrisonExploration)
end

function PrisonExploration:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("PrisonExploration")
        end
    )
    self:AddListener(self._btnRetreat.onClick,
        function()
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "TIPS_EARLY_LEAVE"),
                sureCallback = function()
                    Net.Missions.Cancel(
                        self.mission.Uuid,
                        function(val)
                            UIMgr:Close("PrisonExploration")
                        end
                    )
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    )
    self.RefreshFunc = function()
        self:OnRefreshProgressBar()
    end
    self._content:SetVirtual()
    self._content.itemRenderer = function(index, item)
        local reward
        local isLast = self.total < (index + 1)
        if not isLast then
            reward = self.data.Rewards[index + 1]
        end

        item:Init(index + 1, reward, isLast, self.data.StartTime)
    end
end

function PrisonExploration:OnOpen(mission)
    -- UI_Exploring_Time
    self:UnSchedule(self.RefreshFunc)
    self.mission = mission
    Net.Siege.GetExploreInfo(
        function(rsp)
            self.data = rsp.ExploreInfo
            self._progressBar.max = self.data.EndTime - self.data.StartTime
            -- ExploreInfo:table: 0000000098186190
            -- Rewards:table: 0000000098186410
            -- StartTime:1574387931
            -- Times:160
            --             Reward:table: 0000000098185C10
            -- Type:0
            -- Amount:210
            -- Category:1
            -- ConfId:
            self.total = #self.data.Rewards
            self._content.numItems = #self.data.Rewards + 1
            self._content.scrollPane:ScrollBottom()
            self:Schedule(self.RefreshFunc, 1, true)
        end
    )
end
function PrisonExploration:OnRefreshProgressBar()
    local delay = (Tool.Time() - self.data.StartTime) % Global.SecretBaseRewardTime
    if delay == 1 then
        Net.Siege.ExploreReward(
            function(val)
                if val.FinishExplore then
                    self:UnSchedule(self.RefreshFunc)
                    UIMgr:Close("PrisonExploration")
                    return
                end
                self:ExploreRewardCallback(val)
            end
        )
        return
    end

    self._progressBar.value = Tool.Time() - self.data.StartTime
    self._textProgress.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Exploring_Time", {time = TimeUtil.SecondToDHMS(Tool.Time() - self.data.StartTime)})
end

function PrisonExploration:OnClose()
    self:UnSchedule(self.RefreshFunc)
    Event.Broadcast(EventDefines.UIOnClosePrison)
end
function PrisonExploration:ExploreRewardCallback(data)
    for i = 1, #data.Rewards do
        table.insert(self.data.Rewards, data.Rewards[i])
    end
    self.total = #self.data.Rewards
    self._content.numItems = self.total + 1
    self._content.scrollPane:ScrollBottom()
end
return PrisonExploration
