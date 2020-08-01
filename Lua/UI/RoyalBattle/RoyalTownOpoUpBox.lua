--[[
    Author: xiaosao
    Function:王城战未开启点击弹窗
]]
local RoyalTownOpoUpBox = _G.UIMgr:NewUI("RoyalTownOpoUpBox")

function RoyalTownOpoUpBox:OnInit()
    self._title.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Throne_Status_Title")
    UITool.GetIcon({"falcon", "banner_wz02"},self._banner)
    self:OnInitEvent()
end
function RoyalTownOpoUpBox:OnInitEvent()
    self:AddListener(
        self._mask.onClick,
        function()
            _G.UIMgr:Close("RoyalTownOpoUpBox")
        end
    )
    self:AddListener(
        self._btnClose.onClick,
        function()
            _G.UIMgr:Close("RoyalTownOpoUpBox")
        end
    )
    self:AddEvent(
        EventDefines.KingInfoChange,
        function()
            self:AddScheduleCall()
        end
    )
    self:AddListener(
        self._btnDetail.onClick,
        function()
            Sdk.AiHelpShowFAQSection("25941")
        end
    )
end
function RoyalTownOpoUpBox:OnOpen()
    _G.RoyalModel.SetKingWarInfo()
    self._descText.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_WarZone_ReadyTxt")
end

function RoyalTownOpoUpBox:AddScheduleCall()
    self.warInfo = _G.RoyalModel.GetKingWarInfo()
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
function RoyalTownOpoUpBox:SetStatusTime()
    local lasttime = self.warInfo.NextTime - _G.Tool.Time()
    self:SetTimeText(lasttime)
    if lasttime <= 0 then
        self:OnClose()
    end
end
function RoyalTownOpoUpBox:SetTimeText(lasttime)
    --local _, i18nkey = _G.RoyalModel.GetRoyalStatus()
    self._openStateText.text =
        _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_WarZone_ReadyTime", {time = _G.TimeUtil.SecondToDHMS(lasttime)})
end

function RoyalTownOpoUpBox:OnClose()
    self:UnSchedule(self.ScheduleCall)
    self.ScheduleCall = nil
end

return RoyalTownOpoUpBox
