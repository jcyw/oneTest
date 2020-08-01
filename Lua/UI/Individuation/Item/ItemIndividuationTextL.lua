--author: 	Amu
--time:		2020-07-14 11:47:06

local ItemIndividuationTextL = fgui.extension_class(GComponent)
fgui.register_extension("ui://Individuation/itemIndividuationTextL", ItemIndividuationTextL)

ItemIndividuationTextL.tempList = {}

function ItemIndividuationTextL:ctor()
    self._text = self:GetChild("titleChat").asRichTextField
    self._transText = self:GetChild("titleChatTranslate").asRichTextField
    self._line = self:GetChild("line")

    self._ctrView = self:GetController("c1")

    self._textWidth = self._text.width
    self._textHeight = self._text.height
    self._transTextWidth = self._transText.width
    self._transTextHeight = self._transText.height

    self._textY = self._text.y
    
    self._width = self.width
    self._height = self.height

    self._text.emojies = EmojiesMgr:GetEmojies()
    self._transText.emojies = EmojiesMgr:GetEmojies()
    self:InitEvent()
end

function ItemIndividuationTextL:InitEvent()

end

function ItemIndividuationTextL:SetData(text)

    self._text.text = text
    self:Refresh()
end

function ItemIndividuationTextL:Refresh()
    self._text.y = self._textY
    self.height = self._height + self._text.height - self._textHeight
    self.width = self._text.width - self._textWidth + self._width
end

return ItemIndividuationTextL