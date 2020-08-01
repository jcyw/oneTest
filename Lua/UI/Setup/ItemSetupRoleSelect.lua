--author: 	Amu
--time:		2019-11-18 19:19:10

local ItemSetupRoleSelect = fgui.extension_class(GButton)
fgui.register_extension("ui://Setup/itemSetupRoleSelect", ItemSetupRoleSelect)

function ItemSetupRoleSelect:ctor()
    self._icon = self:GetChild("icon")
    self._name = self:GetChild("textName")
    self._sever = self:GetChild("text1")
    self._level = self:GetChild("text2")

    self._newRole = self:GetChild("text3")

    self._tagIcon = self:GetChild("iconConfirm")

    self._newRole.text = StringUtil.GetI18n("configI18nCommons", "UidBind14")

    self._ctrView = self:GetController("c1")
end

function ItemSetupRoleSelect:SetData(info)
    self.info = info
    if not info then
        self._ctrView.selectedIndex = 1
    else
        self._ctrView.selectedIndex = 0
        self._name.text = StringUtil.GetI18n("configI18nCommons", "CHARACTER_NAME", {player_name = info.Name})
        self._sever.text = StringUtil.GetI18n("configI18nCommons", "CHARACTER_SEVER", {sever_id = info.ServerId})
        self._level.text = StringUtil.GetI18n("configI18nCommons", "CHARACTER_LEVEL", {num = info.CenterLevel})
        if info.RoleId == UserModel.data.accountId then
            self._tagIcon.visible = true
        else
            self._tagIcon.visible = false
        end
        CommonModel.SetUserAvatar(self._icon, info.Avatar, info.RoleId)
    end
end

function ItemSetupRoleSelect:GetData()
    return self.info
end

return ItemSetupRoleSelect