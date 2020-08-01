-- author:{Amu}
-- time:2019-06-15 10:18:21

local ChatModel = import("Model/ChatModel")
local ChatBarModel = import("Model/ChatBarModel")

local ItemMailPersonalNewsChatL = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemMailPersonalNewsChatL", ItemMailPersonalNewsChatL)

function ItemMailPersonalNewsChatL:ctor()
    self._groupL = self:GetChild("groupL")
    self._groupR = self:GetChild("groupR")
    self._timeLab = self:GetChild("itemTime"):GetChild("textTime")

    self._iconGift = self:GetChild("iconGift")
    self._iconGift.visible = false
    
    self._viewH = self.height


    self._playerInfo = self:GetChild("titleName")
    self._chatBox = self:GetChild("chatBgBox")
    self._chatBox_h = self:GetChild("chatBgBox").height
    -- self._msg = self:GetChild("titleChat").asRichTextField
    -- self._msg_h = self:GetChild("titleChat").height
    -- self._msg_y = self:GetChild("titleChat").y
    self._msgBox = self:GetChild("title")
    self._msg = self:GetChild("title"):GetChild("titleChat").asRichTextField

    self._head = self:GetChild("btnHead")
    self._changeBtn = self:GetChild("btnTranslate")

    self._itemChatBar = self:GetChild("itemChatBar")

    self.BubbleIcon = {
        [DRESSUP_BUBBLE_TYPE.Arrow] = self:GetChild("chatBgArrow"),
        [DRESSUP_BUBBLE_TYPE.Box] = self:GetChild("chatBgBox"),
        [DRESSUP_BUBBLE_TYPE.LeftTop] = self:GetChild("righttop"),
        [DRESSUP_BUBBLE_TYPE.LeftBotton] = self:GetChild("rightbottom"),
    }

    -- self._ctrView = self:GetController("c1")

    self._itemChatBar.visible = false
    self._msg.emojies = EmojiesMgr:GetEmojies()
    self.isClick = false

    self:InitEvent()
end

function ItemMailPersonalNewsChatL:InitEvent()
    self:AddListener(self._head.onClick,function()
        if self.callback then
            self.callback(self.info)
        elseif self.info.SenderId then
            TurnModel.PlayerDetails(self.info.SenderId)
        elseif self.info.UserId and self.info.UserId ~= Model.Account.accountId then --私聊窗口
            TurnModel.PlayerDetails(self.info.UserId)
        end
    end)

    self:AddListener(self._changeBtn.onClick,function()
        if self.info.isTranslated then
            self.info.isTranslated = false
        else
            self.info.isTranslated = true
        end
        Event.Broadcast(CHAT_EVENT_TYPE.Refresh)
    end)

    self:AddListener(self._msgBox.onClick,function()
        if self.type == MSG_TYPE.Chat then
            if self.info.MType < 10 then
                -- Event.Broadcast(CHAT_EVENT_TYPE.CloseChatBar, self)
                if self.isClick then
                    self._itemChatBar.visible = false
                    self.isClick = false
                else
                    self._itemChatBar.visible = true
                    self.isClick = true
                end
            else
                ChatModel:JumpToByMsgType(self.type, self.info, self._chatBox)
            end
        else
            -- if self.isClick then
            --     self._itemChatBar.visible = false
            --     self.isClick = false
            -- else
            --     self._itemChatBar.visible = true
            --     self.isClick = true
            -- end
            local chatBar = ChatBarModel.GetChatBar()
            chatBar:Init(0)
            chatBar:SetBtnOne(StringUtil.GetI18n(I18nType.Commmon, "Chat_Copy"), function()
                GUIUtility.systemCopyBuffer = self.info.Content
                TipUtil.TipById(50126)
            end)
            UIMgr:ShowPopup("Common", "itemChatBar", self._chatBox, false)
        end
    end)
    self:AddEvent(CHAT_EVENT_TYPE.CloseChatBar, function()
        self._itemChatBar.visible = false
    end)
end

function ItemMailPersonalNewsChatL:SetData(index, _info, type, cb, preInfo)
    self._itemChatBar.visible = false
    self.index = index
    self.info = _info
    self.callback = cb
    self.type = type
    self.preMsg = preInfo

    self._msgId = ""
    if self.type == MSG_TYPE.Chat then
        self._msgId = self.info.MessageId
    elseif self.type == MSG_TYPE.LMsg then
        self._msgId = self.info.Uuid
    elseif self.type == MSG_TYPE.Mail then
        self._msgId = self.info.Uuid
    end

    print("==========  msgId  ====== " .. self._msgId)

    if self.info.isTranslated then
        self._changeBtn.selected = true
    else
        self._changeBtn.selected = false
    end

    self:_refreshData(_info)
end

function ItemMailPersonalNewsChatL:_refreshData(info)
    self.info = info

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

    if self.type == MSG_TYPE.Chat then
        if info.MType == PUBLIC_CHAT_TYPE.Normal then
            -- self._ctrView.selectedIndex = CHAT_BOX_TYPE.Normal
            if info.DressUpUsing then
                for _,v in pairs(info.DressUpUsing) do
                    if v.DressType == DRESSUP_TYPE.Bubble then
                        self:SetBubbleIcon(v.DressUpConId)
                    end
                end
            else
                self:SetBubbleIcon(80000001)
                print("====================没有装扮==============================")
            end
        elseif info.MType == PUBLIC_CHAT_TYPE.Radio then
            self:SetBubbleIcon(2)
        else
            self:SetBubbleIcon(1)
        end
    else
        if info.DressUpUsing then
            for _,v in pairs(info.DressUpUsing) do
                if v.DressType == DRESSUP_TYPE.Bubble then
                    self:SetBubbleIcon(v.DressUpConId)
                end
            end
        else
            self:SetBubbleIcon(80000001)
            print("====================没有装扮==============================")
        end
    end



    if info.IsGameManager then
        self:SetBubbleIcon(0)
    end

    self._head:SetAvatar(info, self.type)

    self._playerInfo.text = TextUtil.FormatPlayName(info, self.type)
    -- self._msg.text = ChatModel:GetMsgTemplateByType(self.type, info)
    if self.info.MType == PUBLIC_CHAT_TYPE.Normal 
        or self.info.MType == PUBLIC_CHAT_TYPE.Radio 
        or self.type ~= MSG_TYPE.Chat then
        -- ChatModel:SetMsgTemplateByType(self._msg, self.type, info)
        -- self._msgBox:SetData(info.Content)
        if self.info.isTranslated then
            if self.info.translatedText then
                if self.type == MSG_TYPE.Mail and self.info.Category == MAIL_CHAT_TYPE.MailMsgTypeAllianceNotify then
                    self._msgBox:SetData("("..ConfigMgr.GetI18n("configI18nCommons", "Ui_Union_Mail") ..")\n".. self.info.Content, 
                        "("..ConfigMgr.GetI18n("configI18nCommons", "Ui_Union_Mail") ..")\n".. self.info.translatedText[1])
                else
                    self._msgBox:SetData(self.info.Content, self.info.translatedText[1])
                end
            else
                Net.Chat.Translate(1, self._msgId, {self.info.Content}, function(msg)
                    if msg.Id == self._msgId then
                        self.info.translatedText = msg.Content
                        if self.type == MSG_TYPE.Mail and self.info.Category == MAIL_CHAT_TYPE.MailMsgTypeAllianceNotify then
                            self._msgBox:SetData("("..ConfigMgr.GetI18n("configI18nCommons", "Ui_Union_Mail") ..")\n".. self.info.Content, 
                                "("..ConfigMgr.GetI18n("configI18nCommons", "Ui_Union_Mail") ..")\n".. self.info.translatedText[1])
                        else
                            self._msgBox:SetData(self.info.Content, self.info.translatedText[1])
                        end
                        Event.Broadcast(CHAT_EVENT_TYPE.Refresh)
                    end
                end)
            end
        else
            if self.type == MSG_TYPE.Mail and self.info.Category == MAIL_CHAT_TYPE.MailMsgTypeAllianceNotify then
                self._msgBox:SetData("("..ConfigMgr.GetI18n("configI18nCommons", "Ui_Union_Mail") ..")\n".. self.info.Content)
            else
                self._msgBox:SetData(self.info.Content)
            end
            -- self._msgBox:SetData(self.info.Content)
        end
        self._changeBtn.visible = true
    else
        if self.info.MType == WORLD_CHAT_TYEP.Invite then
            if self.info.isTranslated then
                self._msg.text = self.info.translatedText[1]
                self._msgBox:Refresh()
            else
                ChatModel:SetMsgTemplateByType(self._msg, self.type, info)
                Net.Chat.Translate(1, self.info.MessageId, {self._msg.text}, function(msg)
                    if msg.Id == self._msgId then
                        self.info.translatedText = msg.Content
                        self.info.isTranslated = true
                        -- self._msgBox:SetData(self.info.Content, self.info.translatedText[1])
                        -- Event.Broadcast(CHAT_EVENT_TYPE.Refresh)
                        self._msg.text = self.info.translatedText[1]
                        self._msgBox:Refresh()
                    end
                end)
            end
        else
            ChatModel:SetMsgTemplateByType(self._msg, self.type, info)
            self._msgBox:Refresh()
            -- self._msgBox:SetData(tostring(self._msg.text))
        end
        self._changeBtn.visible = false
    end

    -- self._changeBtn.visible = false
end

function ItemMailPersonalNewsChatL:SetBubbleIcon(dressUpId)
    local config = ConfigMgr.GetItem("configDressups", dressUpId)
    if config.urls then
        for _,v in pairs(self.BubbleIcon)do
            v.visible = false
        end
        for _,v in pairs(config.urls)do
            if self.BubbleIcon[v.id] then
                self.BubbleIcon[v.id].visible = true
                self.BubbleIcon[v.id].icon = UITool.GetIcon({v.pkg, v.url})
            end
        end
    end
end

return ItemMailPersonalNewsChatL