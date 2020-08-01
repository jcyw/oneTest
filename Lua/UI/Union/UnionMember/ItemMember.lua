--[[
    Author: songzeming
    Function: 联盟成员列表 成员Item
]]
local ItemMember = fgui.extension_class(GButton)
fgui.register_extension('ui://Union/itemUnionInvitationMember', ItemMember)

local CommonModel = import('Model/CommonModel')
local CONTROLLER = {
    Normal = 'Normal',
    MemberOnline = 'MemberOnline', --成员列表在线
    MemberOffline = 'MemberOffline', --成员列表离线
    MemberOnlineCenter = "MemberOnlineCenter", --成员列表在线左右居中
    MemberOfflineCenter = "MemberOfflineCenter", --成员列表离线左右居中
    Officer = 'Officer', --任命官员
    Setup = 'Setup', --联盟设置成员上线提醒
    Invitation = "Invitation"
}

function ItemMember:ctor()
    self._controller = self:GetController('Controller')
    self._flag = self:GetChild("n39")

    self:AddListener(self.onClick,
        function()
            if self._checkBox.visible then
                self:SetCheck(not self:GetCheck())
                self:OnCheckBox()
                return
            end
            if self.from == 'Member' then
                if self.clickCb() then
                    self.clickCb()
                end
                UIMgr:Open("UnionMember/UnionMemberDetail", self.member, self.isMine)
            end
        end
    )
    --盟主任命官员 点击任命
    self:AddListener(self._btnAppoint.onClick,
        function()
            if self.clickCb() then
                self.clickCb()
            end
        end
    )
end

function ItemMember:OnCheckBox()
    local isCheck = self:GetCheck()
    --成员列表
    if self.memberCb then
        self.memberCb(isCheck)
    end

    --投票
    if self.info then
        if isCheck then
            Event.Broadcast(UNIONVOTEMEMBEREVENT.Add, self.info.Id)
        else
            Event.Broadcast(UNIONVOTEMEMBEREVENT.Del, self.info.Id)
        end
    end
end

--投票相关
function ItemMember:SetData(info, type)
    self._controller.selectedPage = "vote"
    self.info = info
    self._name.text = info.Name
    self._iconFlag.icon = UIPackage.GetItemURL("Union", "icon_title_0" .. (info.Position or 0))
    self._force.text = ConfigMgr.GetI18n('configI18nCommons', 'Ui_Power') .. ':\n' .. Tool.FormatNumberThousands(info.Power)
    self._icon:SetAvatar(info)

    if type == UNION_VOTITEM_TYPE.SelectItem then
        self._checkBox.visible = true
        -- CommonModel.SetUserAvatar(self._icon, info.Avatar)
    elseif type == UNION_VOTITEM_TYPE.InfoItem then
        self._controller.selectedPage = CONTROLLER.Invitation
        self._textForce.text = ConfigMgr.GetI18n('configI18nCommons', 'Ui_Power')
        self._forceNum.text =  Tool.FormatNumberThousands(info.Power)
        self._flag.icon = UITool.GetIcon(ConfigMgr.GetItem("configFlags", info.Flag).icon)
        -- CommonModel.SetUserAvatar(self._icon, info.Avatar)
        self._checkBox.visible = false
        local config = ConfigMgr.GetItem('configLanguages', info.Language)
        if config then
            self._textLanguage.text = config.language
        end
    end
end
function ItemMember:GetData()
    return self.info
end

--成员列表相关
function ItemMember:Init(member, from, isMine, cb)
    self.member = member
    self.from = from
    self.isMine = isMine
    self.memberCb = cb

    -- CommonModel.SetUserAvatar(self._icon, member.Avatar, member.Id)
    self._icon:SetAvatar(member, nil, member.Id)
    self._name.text = member.Name
    local power = Tool.FormatNumberThousands(member.Power)
    self._force.text = string.format("%s: %s", StringUtil.GetI18n(I18nType.Commmon, 'Ui_Power'), power)
    self.visible = true
    if from == 'Officer' then
        --盟主任命官员
        self._checkBox.visible = false
        self._controller.selectedPage = CONTROLLER.Officer
    elseif from == 'Setup' then
        --联盟设置成员上线提醒
        self._checkBox.visible = true
        self._controller.selectedPage = CONTROLLER.Setup
        self:SetCheck(member.OnlineNotice)
    elseif from == 'Member' then
        --联盟成员列表
        self._checkBox.visible = false
        self._iconFlag.icon = UIPackage.GetItemURL("Union", "icon_title_0" .. member.Position)
        local isR45 = Model.Player.AlliancePos > 3
        local datas = {
            level = member.BaseLevel
        }
        local textCenter = StringUtil.GetI18n(I18nType.Commmon, "Alliance_BaseLevel", datas)
        if member.IsOnline then
            if isR45 then
                self._city.text = textCenter
                self._controller.selectedPage = CONTROLLER.MemberOnline
            else
                self._powerCenter.text = power
                self._controller.selectedPage = CONTROLLER.MemberOnlineCenter
            end
            self._time.text = self.isMine and StringUtil.GetI18n(I18nType.Commmon, 'Ui_Online') or ""
        else
            if isR45 then
                self._city.text = textCenter
                self._controller.selectedPage = CONTROLLER.MemberOffline
            else
                self._powerCenter.text = power
                self._controller.selectedPage = CONTROLLER.MemberOfflineCenter
            end
            self._time.text = self.isMine and FormatTimeAgo(member.ActiveAt) or ""
        end
    end
end
--点击回调
function ItemMember:ClickCb(cb)
    self.clickCb = cb
end
--设置单选框状态
function ItemMember:SetCheck(flag)
    self._checkBox.selected = flag
end
--是否选中单选框
function ItemMember:GetCheck()
    return self._checkBox.selected
end

function FormatTimeAgo(time)
    if not time then
        return ''
    end
    local t = Tool.Time() - time
    if t < 0 then
        return ''
    end
    if t < 60 then
        local values = {
            second = math.floor(t)
        }
        return StringUtil.GetI18n(I18nType.Commmon, 'Ui_SecondAgo', values)
    end
    if t < 3600 then
        local values = {
            minutes = math.floor(t / 60)
        }
        return StringUtil.GetI18n(I18nType.Commmon, 'Ui_MinutesAgo', values)
    end
    if t < 24 * 3600 then
        local values = {
            hour = math.floor(t / 3600)
        }
        return StringUtil.GetI18n(I18nType.Commmon, 'Ui_HourAgo', values)
    else
        local values = {
            day = math.floor(t / (24 * 3600))
        }
        return StringUtil.GetI18n(I18nType.Commmon, 'Ui_DayAgo', values)
    end
end

return ItemMember
