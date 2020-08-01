--[[
    author:{laofu}
    time:2020-06-10 19:29:23
    function:{新城竞赛活动}
]]
local GD = _G.GD
local NewWarZoneActivity = UIMgr:NewUI("NewWarZoneActivity")

--页面枚举
local PAGE = {
    TASKPAGE = 0,
    RANKPAGE = 1
}

function NewWarZoneActivity:OnInit()
    local view = self.Controller.contentPane

    self._btnClose = view:GetChild("btnReturn")
    self._activityTitle = view:GetChild("textName")

    self._btnPage1 = view:GetChild("btnTask1")
    self._btnPage2 = view:GetChild("btnTask2")

    self._banner = view:GetChild("banner")
    self._btnHelp = view:GetChild("btnHelp")
    self._timerText = view:GetChild("textTime")

    self._tasksPage = view:GetChild("tasksPage")
    self._rankPage = view:GetChild("rankPage")

    self._c2 = view:GetController("c2")

    self._activityTitle.text = StringUtil.GetI18n(I18nType.Commmon, "ACITIVITY_NEW_WARZONE_NAME")
    self._banner.icon = UITool.GetIcon(GD.NewWarZoneActivityAgent.GetActivityBanner())
    self._btnPage1.title = StringUtil.GetI18n(I18nType.Commmon, "UI_RISE_WAY")
    self._btnPage2.title = StringUtil.GetI18n(I18nType.Commmon, "UI_PEAK_WAY")

    self:InitEvent()
end

--注册按键事件
function NewWarZoneActivity:InitEvent()
    self:AddListener(
        self._btnClose.onClick,
        function()
            UIMgr:Close("NewWarZoneActivity")
        end
    )
    self:AddListener(
        self._btnPage1.onClick,
        function()
            self:SetPage(PAGE.TASKPAGE)
        end
    )
    self:AddListener(
        self._btnPage2.onClick,
        function()
            self:SetPage(PAGE.RANKPAGE)
        end
    )
    self:AddListener(
        self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "ACITIVITY_NEW_WARZONE_DESC"),
                info = StringUtil.GetI18n(I18nType.Commmon, "ACITIVITY_NEW_WARZONE_STORY")
            }
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )
end

--请求服务器信息
function NewWarZoneActivity:GetServerInfo(cb)
    self.taskInfo = {}
    self.rankInfo = {}
    GD.NewWarZoneActivityAgent.GetRankInfo(
        function(msg)
            self.rankInfo = msg
        end
    )
    GD.NewWarZoneActivityAgent.GetTaskInfo(
        function(msg)
            self.taskInfo = msg
            if cb then
                cb()
            end
        end
    )
end

--设置计时器
function NewWarZoneActivity:SetTimer()
    if self.timer then
        self:UnSchedule(self.timer)
    end
    local at = self.taskInfo.EndAt
    local cutTime = function()
        return at - Tool.Time()
    end
    self.timer = function()
        self._timerText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_OVER_TIME", {time = Tool.FormatTime(cutTime())})
    end
    self:Schedule(self.timer, 1)
end

--设置页面
function NewWarZoneActivity:SetPage(pageIndex)
    self._c2.selectedIndex = pageIndex
    if pageIndex == PAGE.TASKPAGE then
        self._tasksPage:OpenPage()
    else
        self._rankPage:OpenPage(self.rankInfo)
    end
end

--刷新页面内容
function NewWarZoneActivity:RefreshContent()
    self:GetServerInfo(
        function()
            self:SetTimer()
            self:SetPage(self._c2.selectedIndex)
        end
    )
end

function NewWarZoneActivity:OnOpen()
    self:RefreshContent()
end

function NewWarZoneActivity:OnClose()
    self:UnSchedule(self.timer)
    --关闭rank页面计时器
    Event.Broadcast(EventDefines.CloseNewWarZoneRankPageTimer)
end

return NewWarZoneActivity
