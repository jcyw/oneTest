--[[
    author:{zhanzhang}
    time:2019-11-29 21:30:11
    function:{联合军来袭（黑骑士）}
]]
local BlackKnight = UIMgr:NewUI("BlackKnight")

local TurnModel = import("Model/TurnModel")

function BlackKnight:OnInit()
    local view = self.Controller.contentPane

    self._controller = view:GetController("c1")
    self:OnRegister()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.BlackKnight)
    self._bgMid.icon = _G.UITool.GetIcon({"banner_activity","frame_black Knight_01"})
end

function BlackKnight:OnRegister()
    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"), info = StringUtil.GetI18n(I18nType.Commmon, "UI_UNION_ARMY_EXPLAIN")}
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("BlackKnight")
        end
    )
    self:AddListener(self._btnDetail.onClick,
        function()
            --玩家没有联盟跳转到加入联盟界面
            if Model.Player.AllianceId == "" then
                self:GoUnionView()
                return
            end
            --to do --打开联盟防御界面
            if self.activityInfo.InWar then
                UIMgr:Open("UnionWarfare", 2)
            else
                --会长和R4以上可以开启活动
                if Model.Player.AlliancePos < ALLIANCEPOS.R4 then
                    TipUtil.TipById(50001)
                else
                    Net.Siege.Participate(
                        Model.Player.AllianceId,
                        function(data)
                            Log.Info("成功开启活动")
                        end
                    )
                end
            end
        end
    )
    self:AddListener(self._btnView.onClick,
        function()
            Net.Siege.GetRank(
                1,
                function(data)
                    UIMgr:Open("BlackKnightReward", data, self.activityTime, self.activityInfo)
                end
            )

            --战争详情跳转到联盟防御页面
        end
    )
    --跳转到对应坐标
    self:AddListener(self._textCoordinate.onClick,
        function()
            TurnModel.WorldPos(MathUtil.GetCoordinate(self.activityInfo.SiegeFrom))
        end
    )
    self.RefreshFunc = function()
        self:RefreshInfo()
    end

    self:AddEvent(
        EventDefines.UIRefreshBlackKnight,
        function(data)
            self.activityInfo = data
            if data.InWar then
                --战斗开启
                self._controller.selectedIndex = 0
                self:RefreshDetail()
            elseif data.Round > 0 then
                --战斗结束
                self._controller.selectedIndex = 2
                self._textStart.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_OVER_DESC")
            else
                self._controller.selectedIndex = 1
                self._textStart.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_BEGIN_INFO")
                self._btnDetail.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_VIEW_STRATING_ATTACK")
            end
        end
    )
end

function BlackKnight:OnOpen(data)
    self.activityTime = data
    self.configInfo = ConfigMgr.GetItem("configActivitys", data.Id)

    self:Schedule(self.RefreshFunc, 1, true)
    --设置描述文档滑动
    local descBG = self.Controller.contentPane:GetChild("bgDec")
    ConfirmPopupTextUtil.SetUpContent(descBG.height - 70,self._label,StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_BACKGROUND"))
    self._label.y = descBG.y + 50
    --状态1 没有联盟
    if Model.Player.AllianceId == "" then
        --状态2 活动没有开启
        self:ChangeNoUnionState()
    end
    if not data.Open then
        self:ChangeNoActivity()
    else
        --状态3 活动已开启
        self:GetAttackInfo()
    end
end

--未加入联盟前往联盟页面
function BlackKnight:GoUnionView()
    TurnModel.UnionView()
    UIMgr:Close("BlackKnight")
end
--刷新文本信息
function BlackKnight:RefreshInfo()
    if self.activityInfo and self.activityInfo.InWar and self.activityInfo.EndTime > Tool.Time() then
        --联盟开启活动
        local delay = self.activityInfo.NextRoundStartAt - Tool.Time()
        if delay >= 0 then
            self._textAppear.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_ATTACK_TIMES", {time = UITool.GetTextColor(GlobalColor.Yellow, TimeUtil.SecondToDHMS(delay))})
        else
            -- self:UnSchedule(self.RefreshFunc)
            -- self._textAppear.text = ""
        end
        self._textTagTime.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_ATTACK_TIME", {time = TimeUtil.SecondToDHMS(self.activityInfo.EndTime - Tool.Time())})
    else
        --联盟未开启活动
        if self.activityTime.EndAt > Tool.Time() and self.activityTime.StartAt < Tool.Time() then
            --在活动开启期间
            self._textTagTime.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_OVER_TIME", {time = TimeUtil.SecondToDHMS(self.activityTime.EndAt - Tool.Time())})
        else
            self._textTagTime.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_BEGIN_TIME", {time = TimeUtil.SecondToDHMS(self.activityTime.StartAt - Tool.Time())})
        end
    end
end
--------------------------------------- 状态区分
--切换到无联盟状态
function BlackKnight:ChangeNoUnionState()
    self._controller.selectedIndex = 1
    local keyStr = ""
    if self.activityTime.Open then
        keyStr = "UNION_ARMY_BEGIN_INFO"
    elseif self.activityTime.StartAt > Tool.Time() then
        keyStr = "UNION_ARMY_BEGIN_DESC"
    else
        keyStr = "UNION_ARMY_OVER_DESC"
    end
    self._textStart.text = StringUtil.GetI18n(I18nType.Commmon, keyStr)
    self._btnDetail.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_JOIN_Alliance")
end
--活动暂未开放
function BlackKnight:ChangeNoActivity()
    self._controller.selectedIndex = 2
    self._textStart.text = StringUtil.GetI18n(I18nType.Commmon, (self.activityTime.StartAt > Tool.Time()) and "UNION_ARMY_BEGIN_DESC" or "UNION_ARMY_OVER_DESC")
    self._btnDetail.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_MTR_BattleDetails")
end
--联盟已经开启活动
function BlackKnight:RefreshDetail()
    self._btnDetail.title = StringUtil.GetI18n(I18nType.Commmon, "Ui_MTR_BattleDetails")
    self._textStart.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_BEGIN_INFO")
    self._textAppearNum.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_TIMES", {num = UITool.GetTextColor(GlobalColor.Yellow, self.activityInfo.Round)})
    self._textCoordinate.text = StringUtil.GetCoordinataWithLetter(MathUtil.GetCoordinate(self.activityInfo.SiegeFrom))
    self._textTroopsNum.text = self.activityInfo.FightingMembers
end

-------------------------------------------------------------------------------------------
--获取进攻信息
function BlackKnight:GetAttackInfo()
    Net.Siege.GetSiegeInfo(Model.Player.AllianceId)
end

function BlackKnight:OnClose()
    self:UnSchedule(self.RefreshFunc)
end
function BlackKnight:Dispose()
end

return BlackKnight
