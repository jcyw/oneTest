--author: 	Amu
--time:		2019-09-09 15:26:42

local ItemMailPersonalNewsSelectObject = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailPersonalNewsSelectObject", ItemMailPersonalNewsSelectObject)

function ItemMailPersonalNewsSelectObject:ctor()
    self._btnHead = self:GetChild("btnHead")
    self._checkBox = self:GetChild("check_box")
    self._name =  self:GetChild("title")

    self:InitEvent()
end

function ItemMailPersonalNewsSelectObject:InitEvent()
    self:AddListener(self._checkBox.onChanged,function()
        local _selectd = self._checkBox.asButton.selected 
        self.info.selected = _selectd
        if _selectd then
            Event.Broadcast(CHAT_GROUP_EVNET.Add, self.playId)
        else
            Event.Broadcast(CHAT_GROUP_EVNET.Del, self.playId)
        end
    end)
end

function ItemMailPersonalNewsSelectObject:SetData(info)
    self.info = info
    self._checkBox.asButton.selected = self.info.selected and true or false
    self.playId = info.Id and info.Id or info.Uuid or info.UserId
    self._name.text = info.Name
    self._btnHead:SetData(info)
end

function ItemMailPersonalNewsSelectObject:GetIndex()
    return self.index
end

return ItemMailPersonalNewsSelectObject