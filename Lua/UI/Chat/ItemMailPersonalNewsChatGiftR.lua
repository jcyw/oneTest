--author: 	Amu
--time:		2019-08-05 20:08:07


local ChatModel = import("Model/ChatModel")

local ItemMailPersonalNewsChatGiftR = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemMailPersonalNewsChatGiftR", ItemMailPersonalNewsChatGiftR)

ItemMailPersonalNewsChatGiftR.tempList = {}

function ItemMailPersonalNewsChatGiftR:ctor()
    self._groupL = self:GetChild("groupL")
    self._groupR = self:GetChild("groupR")
    self._timeLab = self:GetChild("itemTime"):GetChild("textTime")

    self._iconGift = self:GetChild("iconGift")
    self._iconGift.visible = false
    
    self._viewH = self.height

    self._touch = self:GetChild("touch")

    self._time = self:GetChild("itemTime")
    self._playerInfo = self:GetChild("titleName")
    self._chatBox = self:GetChild("chatBgBox")
    self._chatBox_h = self:GetChild("chatBgBox").height
    self._msgG = self:GetChild("titleChatG").asRichTextField
    self._msgV = self:GetChild("titleChatV").asRichTextField
    self._msg_h = self:GetChild("titleChatG").height
    self._msg_y = self:GetChild("titleChatG").y
    self._head = self:GetChild("btnHead")
    self._changeBtn = self:GetChild("btnTranslate")

    self._ctrView = self:GetController("c1")

    self._msgG.emojies = EmojiesMgr:GetEmojies()
    -- self._msgV.emojies = EmojiesMgr:GetEmojies()
    
    self:InitEvent()
end

function ItemMailPersonalNewsChatGiftR:InitEvent()
    self:AddListener(self._head.onClick,function()
        if self.callback then
            self.callback(self.info)
        end
    end)


    self:AddListener(self._touch.onClick,function()
        ChatModel:JumpToByMsgType(self.type, self.info, self._touch)
    end)
end

function ItemMailPersonalNewsChatGiftR:SetData(index, _info, type, cb)
    self.info = _info
    self.callback = cb
    self.type = type

    self:_refreshData(_info)
end

function ItemMailPersonalNewsChatGiftR:_refreshData(info)
    if self.info.MType == ALLIANCE_CHAT_TYEP.Voting then
        self._ctrView.selectedIndex = 1
        ChatModel:SetMsgTemplateByType(self._msgV, self.type, info)
    else
        self._ctrView.selectedIndex = 0
        ChatModel:SetMsgTemplateByType(self._msgG, self.type, info)
    end

    local timeStr = TimeUtil:StampTimeToYMDHMS_OR_HMS(info.CreatedAt)
    if self.preMsg then
        if info.CreatedAt - self.preMsg.CreatedAt >= 300 then
            self._timeLab.text = timeStr
        else
            self._timeLab.text = ""
        end
    else
        self._timeLab.text = timeStr
    end

    self._playerInfo.text = TextUtil.FormatPlayName(info, self.type)
    self._changeBtn.visible = false
end

return ItemMailPersonalNewsChatGiftR