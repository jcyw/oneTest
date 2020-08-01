--[[
    author:{xiaosao}
    time:2020/6/20
    function:{王城战官职弹窗界面}
]]
local OfficerPopUpBox = UIMgr:NewUI("OfficerPopUpBox")
function OfficerPopUpBox:OnInit()
    self._view = self.Controller.contentPane
    self._controller = self._view:GetController("c1")
    --按钮事件
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("OfficerPopUpBox")
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            UIMgr:Close("OfficerPopUpBox")
        end
    )
    --按钮事件
    self:AddListener(self._btnSet.onClick,
        function()
            UIMgr:Open("UIRoyalGiftSearch","Officer")
            UIMgr:Close("OfficerPopUpBox")
        end
    )
    self:AddListener(self._btnReset.onClick,
        function()
            RoyalModel.SetOfficialPositionPlayer(self.info)
            RoyalModel.ConfirmResetOfficialPosition()
            UIMgr:Close("OfficerPopUpBox")
        end
    )
    self:AddListener(self._btnChangeKing.onClick,
        function()
            UIMgr:Open("UIRoyalGiftSearch","King")
            UIMgr:Close("OfficerPopUpBox")
        end
    )
    --设置列表渲染
    self._list.itemRenderer = function(index, gObject)
        local text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, self.data.buff_txt[index + 1])
        local buffText = gObject:GetChild("text")
        buffText.text = text
    end
end

function OfficerPopUpBox:SetChangeKingTime()
    self._timeText.text = _G.TimeUtil.SecondToDHMS(RoyalModel.KingInfo.TransferDeadline - _G.Tool.Time())
    --_G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_WarZone_ReadyTime", {time = _G.TimeUtil.SecondToDHMS(lasttime)})
end

function OfficerPopUpBox:OnOpen(data,isKing)
    self.data = data
    self.info = _G.RoyalModel.GetTitleInfoByTitleId(data.id)
    local officer = _G.RoyalModel.GetAccountTitlePower(2)
    if isKing then
        self._controller.selectedIndex = 3
        if RoyalModel.CanChangeKing(self.info.PlayerId) then
            self._btnChangeKing.visible = true
            self._timeText.visible = true
            if not self.ScheduleCall then
                self.ScheduleCall= function()
                    self:SetChangeKingTime()
                end
                self:Schedule(self.ScheduleCall, 1)
            end
        else
            self._btnChangeKing.visible = false
            self._timeText.visible = false
            if self.ScheduleCall then
                self:UnSchedule(self.ScheduleCall)
                self.ScheduleCall = nil
            end
        end
    else
        self._controller.selectedIndex = officer and (self.info and 0 or 1) or 2
    end
    if self.info then
        CommonModel.SetUserAvatar(self._icon, self.info.Avatar, self.info.PlayerId)
        if self.info.AllianceShortName and self.info.AllianceShortName ~= "" then
            self._playerName.text = "("..self.info.AllianceShortName..")"..self.info.Name
        else
            self._playerName.text = self.info.Name
        end
    else
        local isOfficer = self.data.officer_event == 1
        self._icon.icon = (isOfficer and UIPackage.GetItemURL("RoyalBattle", "case_wz_gy") or UIPackage.GetItemURL("RoyalBattle", "case_wz_zf"))
        self._playerName.text = ""
    end
    self._title.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, data.office_name)
    self._btnSet.title = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_Appoint")
    self._btnReset.title = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_WarZone_Dismissal")
    self._btnChangeKing.title = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_WarZone_Assignment")
    self._list.numItems = #data.buff_txt
end

function OfficerPopUpBox:OnClose()
    if self.ScheduleCall then
        self:UnSchedule(self.ScheduleCall)
        self.ScheduleCall = nil
    end
end

return OfficerPopUpBox
