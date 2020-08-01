--[[
    Author: tiantian
    Function:王城状态
]]
local UIRoyalCityStatus = _G.UIMgr:NewUI("UIRoyalCityStatus")
import("UI/RoyalBattle/Item/ItemkingInfo")

function UIRoyalCityStatus:OnInit()
    self._statusRoyalIcon = self._statusInfo:GetChild("_royalIcon")
    self._statusPosition = self._statusInfo:GetChild("_position")
    self._statusAlliance = self._statusInfo:GetChild("_alliance")
    self._statusTime = self._statusInfo:GetChild("_statusTime")
    self._statusController = self._statusInfo:GetController("c1")
    self._funcName.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "UI_Warzone_State")
    self._title.text =  _G.RoyalModel.GetOfficialTitleStr(_G.RoyalModel.OfficialTitleType.Throne_OfficialPost_King)
    self._btnRecord.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Throne_Status_Button_FormerKing")
    self._btnMeritWall.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Throne_Status_Button_Log")
    self._kingInfo.touchable = false
    self:OnInitEvent()
end
function UIRoyalCityStatus:OnInitEvent()
    --注册监听事件
    self:AddListener(
        self._btnClose.onClick,
        function()
            _G.UIMgr:Close("UIRoyalCityStatus")
        end
    )
    self:AddListener(
        self._btnDetail.onClick,
        function()
            Sdk.AiHelpShowFAQSection("25941")
        end
    )
    self:AddListener(
        self._btnMeritWall.onClick,
        function()
            _G.UIMgr:Open("UIRoyalCityRecord", _G.RoyalModel.RecordType.War)
        end
    )
    self:AddListener(
        self._btnRecord.onClick,
        function()
            _G.UIMgr:Open("UIRoyalCityRecord", _G.RoyalModel.RecordType.king)
        end
    )
    self:AddEvent(
        EventDefines.KingInfoChange,
        function()
            self.warInfo = _G.RoyalModel.GetKingWarInfo()
            self:OnShowUI()
        end
    )
end
function UIRoyalCityStatus:OnOpen()
    _G.RoyalModel.SetKingWarInfo()
end
function UIRoyalCityStatus:OnShowUI()
    local info = self.warInfo.KingInfo
    local status, _ = _G.RoyalModel.GetRoyalStatus()
    -----------文本------------
    --战区司令
    local kingeStr = _G.RoyalModel.GetOfficialTitleStr(_G.RoyalModel.OfficialTitleType.Throne_OfficialPost_King)
    --官职:
    local officerStr = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "UI_Warzone_Officer")
    --虚位以待
    local freeStr = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_Free_Position")
    --尚未加入任何联盟！
    local noAllianceStr = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "NoAlliance_yet")
    --联盟:
    local allianceStr = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_Rank_AllianceName")

    local notuser =  status == _G.RoyalModel.RoyalStatusType.Ready or  status == _G.RoyalModel.RoyalStatusType.Vita
    self._statusController.selectedIndex = notuser and 1 or 0
    if status == _G.RoyalModel.RoyalStatusType.Ready then
        self._statusPosition.text = freeStr
        self._statusAlliance.text = ""
    end
    if status == _G.RoyalModel.RoyalStatusType.Vita then
        self._statusPosition.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "UI_Warzone_Competing")
        self._statusAlliance.text = ""
    end
    if status == _G.RoyalModel.RoyalStatusType.Ulichukua then
        self._statusPosition.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "UI_Warzone_CurrentOccupier", {player_name = info.Name})
        local allianceeText =
            string.len(info.AllianceId) > 0 and string.format("[%s]%s", info.AllianceShortName, self.warInfo.Alliance) or
            noAllianceStr
        self._statusAlliance.text = string.format("%s %s", allianceStr, allianceeText)
    end
    if status == _G.RoyalModel.RoyalStatusType.Amani then
        self._statusPosition.text = string.format("%s%s", officerStr, kingeStr)
        local allianceeText =
            string.len(info.AllianceId)>0 and string.format("[%s]%s", info.AllianceShortName, self.warInfo.Alliance) or
            noAllianceStr
        self._statusAlliance.text = string.format("%s %s", allianceStr, allianceeText)
    end

    local lasttime = self.warInfo.NextTime - _G.Tool.Time()
    if not self.ScheduleCall and lasttime>0 then
        self.ScheduleCall = function()
            self:SetStatusTime()
        end
        self:Schedule(self.ScheduleCall, 1)
    else
        self:SetTimeText(0)
    end
end
function UIRoyalCityStatus:SetStatusTime()
    local lasttime = self.warInfo.NextTime - _G.Tool.Time()
    self:SetTimeText(lasttime)
    if lasttime <= 0 then
        self:OnClose()
    end
end
function UIRoyalCityStatus:SetTimeText(lasttime)
    local _, i18nkey = _G.RoyalModel.GetRoyalStatus()
    self._statusTime.text =
    _G.StringUtil.GetI18n(_G.I18nType.Commmon, i18nkey, {time = "[color=#00cc00]".._G.TimeUtil.SecondToDHMS(lasttime).."[/color]"})
end
function UIRoyalCityStatus:OnClose()
    self:UnSchedule(self.ScheduleCall)
    self.ScheduleCall = nil
end
return UIRoyalCityStatus
