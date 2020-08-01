--author: 	Amu
--time:		2019-10-29 14:29:48

local BtnBind = fgui.extension_class(GButton)
fgui.register_extension("ui://Setup/btnBind", BtnBind)

function BtnBind:ctor()
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")

    self._name = self:GetChild("textGoogle")

    self:InitEvent()
end

function BtnBind:InitEvent()
end

function BtnBind:SetData(info, btnType)
    self.type = info.type and info.type or info
    self.isBind = info.isBind
    if self.type == SDK_BIND_TYPE.FACEBOOK_TYPE then
        self._icon.icon = UIPackage.GetItemURL("Common", "set_icon_facebook_03")
    elseif self.type == SDK_BIND_TYPE.GOOGLE_TYPE then
        self._icon.icon = UIPackage.GetItemURL("Common", "set_icon_google_01")
    end
    if btnType == 1 then  -- 绑定
        if self.isBind == "0" then
            if self.type == SDK_BIND_TYPE.FACEBOOK_TYPE then
                self._title.text = StringUtil.GetI18n(I18nType.Commmon, "System_Account_Bind_Button4")
            elseif self.type == SDK_BIND_TYPE.GOOGLE_TYPE then
                self._title.text = StringUtil.GetI18n(I18nType.Commmon, "System_Account_Bind_Button1")
            end
        else
            if self.type == SDK_BIND_TYPE.FACEBOOK_TYPE then
                self._title.text = StringUtil.GetI18n(I18nType.Commmon, "System_Account_Binded_Facebook")
            elseif self.type == SDK_BIND_TYPE.GOOGLE_TYPE then
                self._title.text = StringUtil.GetI18n(I18nType.Commmon, "System_Account_Binded_Google")
            end
        end
    elseif btnType == 2 then  -- 换号
        if self.type == SDK_BIND_TYPE.FACEBOOK_TYPE then
            self._title.text = StringUtil.GetI18n(I18nType.Commmon, "System_Account_Bind_Button6")
        elseif self.type == SDK_BIND_TYPE.GOOGLE_TYPE then
            self._title.text = StringUtil.GetI18n(I18nType.Commmon, "System_Account_Bind_Button3")
        end
    end
end

function BtnBind:GetType()
    return self.type
end

function BtnBind:GetBind()
    return self.isBind
end

return BtnBind