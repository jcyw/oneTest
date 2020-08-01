--[[
    author:{xiaosao}
    time:2020/6/16
    function:{王城站预告活动中心界面}
]]
local RoyalBattleActivity = UIMgr:NewUI("RoyalBattleActivity")

function RoyalBattleActivity:OnInit()
    local view = self.Controller.contentPane
    self:OnRegister()

    self._banner.icon = UITool.GetIcon(GlobalBanner.RoyalBattleActivity)
end

function RoyalBattleActivity:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("RoyalBattleActivity")
        end
    )
    self:AddListener(self._btnReward.onClick,
        function()
            UIMgr:Open("UIRoyalTownHall")
        end
    )
    self:AddListener(self._btnRule.onClick,
        function()
            UIMgr:Open("RoyalBattleActivityDesc", 1001)
        end
    )
    self.RefreshFunc = function()
        self:RefreshInfo()
    end
end

function RoyalBattleActivity:OnOpen(data)
    self.activityInfo = data
    _G.RoyalModel.SetKingWarInfo()
    self:Schedule(self.RefreshFunc, 1, true)
    --设置描述文档滑动
    local descBG = self.Controller.contentPane:GetChild("bgDec")
    ConfirmPopupTextUtil.SetUpContent(descBG.height - 69,self._label,StringUtil.GetI18n(I18nType.Commmon, "Ui_WarZone_Notice_BackGround"))
    self._label.y = descBG.y + 58
    self._textSiLingState.text =  StringUtil.GetI18n(I18nType.Commmon, "Throne_Status_KingName",{player_name = "[color=#04ba62]"..StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_Free_Position").."[/color]"})
    self._textTitleSmall.text = StringUtil.GetI18n(I18nType.Commmon, "Throne_Status_Title")
    self._textTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_WarZone_Notice_Name")
    self._descTitle.text = StringUtil.GetI18n(I18nType.Commmon, "TITTLE_ACTIVITY_BACKGROUND")
    self._btnReward.title = StringUtil.GetI18n(I18nType.Commmon, "Throne_OfficialPost_Officertitle")
    self._btnRule.title = StringUtil.GetI18n(I18nType.Commmon, "DiamondsFund ruletitle")
end

--刷新文本信息
function RoyalBattleActivity:RefreshInfo()
    local info = _G.RoyalModel.GetKingWarInfo()
    if not info then
        self._protectText.text = StringUtil.GetI18n(I18nType.Commmon, "Throne_Status_ProtectionTime", {time = TimeUtil.SecondToDHMS(0)})
        return
    end
    local delay = info.NextTime - Tool.Time()
    if delay >= 0 then
        self._protectText.text = StringUtil.GetI18n(I18nType.Commmon, "Throne_Status_ProtectionTime", {time = TimeUtil.SecondToDHMS(delay)})
    else
        UIMgr:Close("RoyalBattleActivity")
    end
end

function RoyalBattleActivity:OnClose()
    self:UnSchedule(self.RefreshFunc)
end

return RoyalBattleActivity
