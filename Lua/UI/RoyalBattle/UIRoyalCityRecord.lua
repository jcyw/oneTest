--[[
    Author: tiantian
    Function:王城战记录
]]
local UIRoyalCityRecord = _G.UIMgr:NewUI("UIRoyalCityRecord")
import("UI/RoyalBattle/Item/ItemCityRecord")

function UIRoyalCityRecord:OnInit()
    self._view = self.Controller.contentPane
    self.controller = self._view:GetController("c1")
    self._titleName.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "UI_Warzone_State")
    self._btnTag1.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Throne_Status_Button_Log")
    self._btnTag2.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Throne_Status_Button_FormerKing")
    UITool.GetIcon({"falcon", "banner_wz02"},self._banner)
    self:OnInitEvent()
end
function UIRoyalCityRecord:OnInitEvent()
    self:AddListener(
        self._bgMask.onClick,
        function()
            _G.UIMgr:Close("UIRoyalCityRecord")
        end
    )
    self:AddListener(
        self._btnClose.onClick,
        function()
            _G.UIMgr:Close("UIRoyalCityRecord")
        end
    )
    self:AddListener(
        self._btnDetail.onClick,
        function()
            Sdk.AiHelpShowFAQSection("25941")
        end
    )
    self:AddListener(
        self._btnTag1.onClick,
        function()
            self.controller.selectedIndex = 0
            self.recordType = _G.RoyalModel.RecordType.War
            self:RefreshListView()
        end
    )
    self:AddListener(
        self._btnTag2.onClick,
        function()
            self.controller.selectedIndex = 1
            self.recordType = _G.RoyalModel.RecordType.king
            self:RefreshListView()
        end
    )
    self:AddEvent(
        EventDefines.KingInfoChange,
        function()
            self:AddScheduleCall()
        end
    )
    self._listView.itemRenderer = function(index, item)
        if not index then
            return
        end
        local pos = index + 1
        if self.recordType == _G.RoyalModel.RecordType.king then
            local data = self.kings[pos]
            local isEnd = data.Rank == self._listView.numItems
            item:SetData(data, self.recordType,index,isEnd)
        else
            item:SetData(self.logs[pos], self.recordType,index,false)
        end
    end
end
function UIRoyalCityRecord:OnOpen(recordType)
    self.recordType = recordType
    self.controller.selectedIndex = recordType
    _G.RoyalModel.GetKingInfo()
    _G.RoyalModel.GetHistoryKings(
        function()
            self.kings = _G.RoyalModel.RecordList[_G.RoyalModel.RecordType.king]
            table.sort(self.kings,function(a,b)
                return a.Rank>b.Rank
            end)
            if self.recordType == _G.RoyalModel.RecordType.king then
                self:RefreshListView()
            end
        end
    )
    _G.RoyalModel.GetWarLogs(
        function()
            self.logs = _G.RoyalModel.RecordList[_G.RoyalModel.RecordType.War]
            if self.recordType == _G.RoyalModel.RecordType.War then
                self:RefreshListView()
            end
        end
    )

    self:AddScheduleCall()
end
function UIRoyalCityRecord:RefreshListView()
    if self.controller.selectedIndex == 1 then
        self._listView.numItems = #self.kings
    end
    if self.controller.selectedIndex == 0 then
        self._listView.numItems = #self.logs
    end
end
function UIRoyalCityRecord:AddScheduleCall()
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
function UIRoyalCityRecord:SetStatusTime()
    local lasttime = self.warInfo.NextTime - _G.Tool.Time()
    self:SetTimeText(lasttime)
    if lasttime <= 0 then
        self:OnClose()
    end
end
function UIRoyalCityRecord:SetTimeText(lasttime)
    local _, i18nkey = _G.RoyalModel.GetRoyalStatus()
    self._statusTime.text =
        _G.StringUtil.GetI18n(_G.I18nType.Commmon, i18nkey, {time = _G.TimeUtil.SecondToDHMS(lasttime)})
end

function UIRoyalCityRecord:OnClose()
    self:UnSchedule(self.ScheduleCall)
    self.ScheduleCall = nil
end
return UIRoyalCityRecord
