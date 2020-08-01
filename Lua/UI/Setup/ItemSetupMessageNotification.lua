--author: 	Amu
--time:		2020-02-05 16:08:35

local ItemSetupMessageNotification = fgui.extension_class(GComponent)
fgui.register_extension("ui://Setup/itemSetupMessageNotification", ItemSetupMessageNotification)

function ItemSetupMessageNotification:ctor()
    self._title = self:GetChild("title")
    self._textDescribe = self:GetChild("textDescribe")
    self._btnOpen = self:GetChild("btnOpen")

    self:InitEvent()
end

function ItemSetupMessageNotification:InitEvent()
    self:AddListener(self._btnOpen.onClick,function()
        if self._btnOpen.selected then

        else
            
        end
    
        self._notifySet.Open = not self._btnOpen.selected
        Net.UserInfo.SetNotifyBlock(self._info.id, self._notifySet.Open)
        SystemSetModel.RefreshNotifySetting(self._info.id)
    end)
end

function ItemSetupMessageNotification:SetData(info)
    self._info = info
    self._title.text = StringUtil.GetI18n("configI18nCommons", info.title)
    self._textDescribe.text = StringUtil.GetI18n("configI18nCommons", info.desc)

    self._notifySet = Model.Find(ModelType.NotifySettings, self._info.id)
    self._btnOpen.selected =not self._notifySet.Open
end

function ItemSetupMessageNotification:GetData()
    return self.info
end

return ItemSetupMessageNotification