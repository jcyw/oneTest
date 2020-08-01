--author: 	Amu
--time:		2019-09-09 19:16:15

local ChatModel = import("Model/ChatModel")

local ItemMailPersonalNewsChatBox = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailPersonalNewsChatBox", ItemMailPersonalNewsChatBox)

function ItemMailPersonalNewsChatBox:ctor()
    self._content = self:GetChild("titleName")
    self:InitEvent()
end

function ItemMailPersonalNewsChatBox:InitEvent()
end

function ItemMailPersonalNewsChatBox:SetData(index, info, type)
    -- self._content.text = info.Content
    ChatModel:SetMsgTemplateByType(self._content, type, info)
end

return ItemMailPersonalNewsChatBox