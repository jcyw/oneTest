--author: 	Amu
--time:		2019-06-28 16:29:41

local MailScoutBox = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/MailScoutBox", MailScoutBox)

function MailScoutBox:ctor()
    self._title = self:GetChild("title")
    self._num = self:GetChild("textTime")
    self._text = self:GetChild("textTitle")

    self:InitEvent()
end

function MailScoutBox:InitEvent(  )
end

function MailScoutBox:SetData(title, num, isAcc)
    self._title.text = title
    self._text.text = ""
    if num then
        if isAcc then
            self._num.text = num
        else
            self._num.text = "~"..num
        end
        self._num.visible = true
    else
        self._text.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_ResOwen_Report")
        self._num.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_ResUncollection_Report")
    end
end

return MailScoutBox