--author: 	Amu
--time:		2019-10-29 14:20:39

local BtnUnbind = fgui.extension_class(GButton)
fgui.register_extension("ui://Setup/btnUnbind", BtnUnbind)

function BtnUnbind:ctor()
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")

    self._name = self:GetChild("textGoogle")
end

function BtnUnbind:InitEvent()
end

function BtnUnbind:SetData(info)
    self.type = info.type
    self.isBind = info.isBind

    self._name.text = info.name

    if self.type == SDK_BIND_TYPE.FACEBOOK_TYPE then
        self._icon.icon = UIPackage.GetItemURL("Common", "set_icon_facebook_03")
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "System_Account_Bind_Button5")
    elseif self.type == SDK_BIND_TYPE.GOOGLE_TYPE then
        self._icon.icon = UIPackage.GetItemURL("Common", "set_icon_google_01")
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "System_Account_Bind_Button2")
    end
end

function BtnUnbind:GetType()
    return self.type
end

function BtnUnbind:GetBind()
    return self.isBind
end

return BtnUnbind