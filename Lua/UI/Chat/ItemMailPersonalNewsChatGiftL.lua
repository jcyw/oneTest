--author: 	Amu
--time:		2019-08-05 20:07:59


local ChatModel = import("Model/ChatModel")

local ItemMailPersonalNewsChatGiftL = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemMailPersonalNewsChatGiftL", ItemMailPersonalNewsChatGiftL)

ItemMailPersonalNewsChatGiftL.tempList = {}

function ItemMailPersonalNewsChatGiftL:ctor()
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
    self._msg = self:GetChild("titleChat").asRichTextField
    self._msg_h = self:GetChild("titleChat").height
    self._msg_y = self:GetChild("titleChat").y
    self._head = self:GetChild("btnHead")
    self._changeBtn = self:GetChild("btnTranslate")

    self._ctrView = self:GetController("c1")

    self._msg.emojies = EmojiesMgr:GetEmojies()
    
    self:InitEvent()
end

function ItemMailPersonalNewsChatGiftL:InitEvent()
    self:AddListener(self._head.onClick,function()
        if self.callback then
            self.callback(self.info)
        end
    end)


    self:AddListener(self._touch.onClick,function()
        ChatModel:JumpToByMsgType(self.type, self.info, self._touch)
    end)
end

function ItemMailPersonalNewsChatGiftL:SetData(index, _info, type, cb)
    self.info = _info
    self.callback = cb
    self.type = type

    self:_refreshData(_info)
end

function ItemMailPersonalNewsChatGiftL:_refreshData(info)
    if self.info.MType == ALLIANCE_CHAT_TYEP.Voting then
        self._ctrView.selectedIndex = 1
    else
        self._ctrView.selectedIndex = 0
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
    ChatModel:SetMsgTemplateByType(self._msg, self.type, info)
    
    self._changeBtn.visible = false
end

return ItemMailPersonalNewsChatGiftL