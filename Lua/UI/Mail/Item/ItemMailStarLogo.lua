-- author:{Amu}
-- time:2019-06-11 16:07:00

local ItemMailStarLogo = fgui.extension_class(GButton)
fgui.register_extension("ui://Mail/itemMailStarLogo", ItemMailStarLogo)


function ItemMailStarLogo:ctor()
    self._checkBox = self:GetChild("check_box")
    self._redPoint = self:GetChild("redPoint")
    self._icon = self:GetChild("icon")
    self._titleText = self:GetChild("title")
    self._subText = self:GetChild("text")
    self._timeText = self:GetChild("textTime")

    self._icon_x = self._icon.x

    self:InitEvent()
end

function ItemMailStarLogo:InitEvent(  )
    self:AddListener(self._checkBox.onChanged,function()
        local _selectd = self._checkBox.asButton.selected
        if _selectd then
            Event.Broadcast(EventDefines.UIMailAddFavorite, self.info.Uuid)
        else
            Event.Broadcast(EventDefines.UIMailDelFavorite, self.info.Uuid)
        end
    end)
end

function ItemMailStarLogo:SetData(index, _info, isClick, allSelect, panel)
    self.info = _info
    self._panel = panel
    self._redPoint.visible = not _info.IsRead
    self._titleText.text = _info.Subject.._info.Number
    self._subText.text = _info.Content
    self._timeText.text = TimeUtil:GetTimesAgo(_info.CreatedAt)
    self:SetText(_info)
    if isClick then
        self._icon.x = self._icon_x + 60
    else
        self._icon.x = self._icon_x
    end

    self._checkBox.visible = isClick
    self._checkBox.asButton.selected = allSelect
end

function ItemMailStarLogo:SetRead()
    if not self.info.IsRead then
        Net.Mails.MarkRead(self.info.Category, {self.info.Uuid},function(msg)
            self.info.IsRead = true
            MailModel:updateIsReadData(self.info.Category, self.info.Number, 1)
            self._panel:RefreshData()
            Event.Broadcast(EventDefines.UIMailsNumChange, {})
        end)
    end
end

function ItemMailStarLogo:getData(  )
    return self.info
end

function ItemMailStarLogo:SetText(_info)
    if _info.MailType then
        MailModel:SetMailIcon(self._icon, math.ceil(_info.MailType))
    end
    self._titleText.text = _info.Subject
    self._subText.text = _info.Preview
end

return ItemMailStarLogo