--author: 	Amu
--time:		2020-02-19 12:00:39

local ItemChatTranslateTextL = fgui.extension_class(GComponent)
fgui.register_extension("ui://Chat/itemChatTranslateTextL", ItemChatTranslateTextL)

ItemChatTranslateTextL.tempList = {}

function ItemChatTranslateTextL:ctor()
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

function ItemChatTranslateTextL:InitEvent()
    self._text.onClickLink:Add(function(context)
        local pos = split(context.data, ":")
        TurnModel.WorldPos(tonumber(pos[1]), tonumber(pos[2]))
        self:ScheduleOnce(function()
            UIMgr:HidePopup("Common", "itemChatBar")
        end, 0.15)
    end)
end

function ItemChatTranslateTextL:SetData(text, transText)
    if transText ~= nil then
        -- self._ctrView.selectedIndex = 1
        self._transText.text = TextUtil.FormatPosHref(transText)
    else
        -- self._ctrView.selectedIndex = 0
    end
    self._text.text = TextUtil.FormatPosHref(text)
    self:Refresh(transText)
end

function ItemChatTranslateTextL:Refresh(transText)
    -- if self._transText.text ~= nil or self._transText.text ~= "" then
    --     self.width = self._text.width
    -- else
    --     self.width = math.max(self._text.width, self._transText.width)
    -- end
    if transText ~= nil then
        self._transText.y = self._textY
        self._line.y = self._textY + self._transText.height + 7
        self._text.y =self._line.y  + 14
        self._line.visible = true
        self._transText.visible = true
        self.height = self._height + self._text.height - self._textHeight + self._transText.height + 22
        self.width = math.max(self._text.width - self._textWidth, self._transText.width - self._transTextWidth) + self._width
    else
        self._text.y = self._textY
        self._line.visible = false
        self._transText.visible = false
        self.height = self._height + self._text.height - self._textHeight
        self.width = self._text.width - self._textWidth + self._width
    end
end

return ItemChatTranslateTextL