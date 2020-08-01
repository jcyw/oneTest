-- author:{Amu}
-- time:2019-06-14 17:19:35
local ChatBarModel = import("Model/ChatBarModel")
local Emojies = import("Utils/Emojies")
local BlockListModel = import("Model/BlockListModel")
local DressUpModel = import("Model/DressUpModel")


local Mail_PersonalNews = UIMgr:NewUI("Mail_PersonalNews")


function Mail_PersonalNews:OnInit()
    self._view = self.Controller.contentPane

    self._textName = self._view:GetChild("textName")
    self._btnTopBgBar = self._view:GetChild("btnTopBgBar")
    self._btnReturn = self._view:GetChild("btnReturn")

    self._btnChatGroup = self._view:GetChild("btnAddFriends")
    self._btnEmojie = self._view:GetChild("iconExpression")

    self._inputText = self._view:GetChild("textInput").asTextInput
    self._textChat = self._view:GetChild("textChat").asTextInput

    self._listView = self._view:GetChild("liebiao")

    self._emojieBox = self._view:GetChild("itemExpressionSelect")

    self._box = self._view:GetChild("bgBox3")
    self._group = self._view:GetChild("group")
    self._boxInput = self._view:GetChild("boxInput")
    self.inputY = self._box.y + GRoot.inst.height-1334
    self._boxH = self._box.height

    self._listView.height = self._listView.height + GRoot.inst.height-1334

    --因为listview 的后渲染导致层级问题   手动设置层级
    self._emojieBox.sortingOrder = 3
    self._btnTopBgBar.sortingOrder = 4
    self._btnReturn.sortingOrder = 4
    self._textName.sortingOrder = 4

    self._view:GetChild("itemChatBar").visible = false

    self._inputText.emojies = EmojiesMgr:GetEmojies()
    self._textChat.emojies = EmojiesMgr:GetEmojies()
    self._textChat.touchable = false
    self.listViewY = self._listView.y
    self.listViewH = self._listView.height
    self._inputH = self._inputText.height
    self._inputY = self._inputText.y
    self._boxInputH = self._boxInput.height
    self._boxInputY = self._boxInput.y

    self._emojieBoxH = self._emojieBox.height

    self.isShowEmojie = false
    self._btnEmojie.asButton.selected = false

    self:InitEvent()
end

--临时会话传openType  和  receiverInfo
function Mail_PersonalNews:OnOpen(type, index, infos, panel, openType, receiverInfo)
    self.isOpen = true
    self.isChange = false
    self.Infos = nil
    self.isFirst = true
    -- self.inputCache = ""
    -- self._inputText.text = ""
    -- self._textChat.text = ""
    if openType == MAIL_CHATHOME_TYPE.TempChat then  --临时会话
        self.openType = openType
        self.type = MAIL_TYPE.Msg
        self.subCategory = receiverInfo.subCategory
        self.Receiver = receiverInfo.Receiver
        self._receive = self.Receiver
        self._textName.text = receiverInfo.Receiver
        self._titleText = ""

        -- self._btnChatGroup.visible = false
        self.targetId = receiverInfo.subject
        local sessionIds = {receiverInfo.subject, UserModel.data.accountId}
        table.sort(sessionIds)
        self.sessionId = sessionIds[1]..":"..sessionIds[2]
        self.members = MailModel:GetMsgMembers(self.sessionId)

        self.Infos = MailModel:GetMsgInfoMsgfByType(self.sessionId)
        if #self.Infos <= 0 then
            Net.Mails.GetSession(self.sessionId, function(msg)
                self.members = msg.Members
                if msg.MsgNumber and #msg.Members > 0 then
                    MailModel:InsterMsgGroup(self.sessionId, msg)
                    MailModel:ReadTenMsg(self.sessionId, index)
                else
                    self.members = {
                        {
                            Alliance = Model.Player.AllianceName,
                            Avatar = Model.Player.Avatar,
                            DressUpUsing = DressUpModel.usingDressUp,
                            Name = Model.Player.Name,
                            UserId = UserModel.data.accountId,
                            VipActive = Model.Player.VipActivated,
                            VipLevel = Model.Player.VipLevel,
                        }
                    }
                    self:InitListView()
                end
            end)
            self:InitListView()
        else
            self:InitListView()
        end
        if GuidedModel._changeNameFlag and GuidedModel._changeNameStep == 2 then
            self.inputCache = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceTask_Name")
            self._inputText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceTask_Name")
            self._textChat.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceTask_Name")
            GuidedModel._changeNameStep = 3
        end
    elseif openType == MAIL_CHATHOME_TYPE.UnionChat then  --联盟全体邮件
        self.openType = openType
        self.type = MAIL_TYPE.Msg
        self.subCategory = MAIL_SUBTYPE.subMailSubTypeAllianceNotify
        self.Receiver = UserModel.data.accountId
        self.sessionId = UserModel.data.accountId..":"..UserModel.data.accountId
        self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Union_Mail")
        self.members = MailModel:GetMsgMembers(self.sessionId)

        self._emojieBox:ShieldBigEmojie(true)

        self.Infos = MailModel:GetMsgInfoMsgfByType(self.sessionId)
        if #self.Infos <= 0 then
            Net.Mails.GetSession(self.sessionId, function(msg)
                self.members = msg.Members
                if msg.MsgNumber and #msg.Members > 0 then
                    MailModel:InsterMsgGroup(self.sessionId, msg)
                    MailModel:ReadTenMsg(self.sessionId, index)
                else
                    self.members = {
                        {
                            Alliance = Model.Player.AllianceName,
                            Avatar = Model.Player.Avatar,
                            DressUpUsing = DressUpModel.usingDressUp,
                            Name = Model.Player.Name,
                            UserId = UserModel.data.accountId,
                            VipActive = Model.Player.VipActivated,
                            VipLevel = Model.Player.VipLevel,
                        }
                    }
                    self:InitListView()
                end
            end)
            self:InitListView()
        else
            self:InitListView()
        end
    else
        self.Infos = infos.msgs
        self.index = index
        self.type = type
        self.sessionId = infos.Uuid
        self.members = infos.Members
        self.subCategory = infos.Category
        self.messageUserId = infos.UserId
        MailModel:ReadTenMsg(infos.Uuid, index)
        if infos.Category == MAIL_SUBTYPE.subPersonalMsg then
            for _,v in pairs(infos.Members)do
                if v.UserId ~= UserModel.data.accountId then
                    self.Receiver = v.Name
                    self._textName.text = v.Name
                    self.targetId = v.UserId
                end
            end
            self._titleText = ""
        elseif infos.Category == MAIL_SUBTYPE.subGroupMsg then
            self:SetMsgGroupTitle(infos.Title, #infos.Members)
            self._textName.text = infos.Title
        elseif infos.Category == MAIL_SUBTYPE.subMailSubTypeAllianceNotify then
            self._emojieBox:ShieldBigEmojie(true)
            self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Union_Mail")
        end
        if self.subCategory == MAIL_SUBTYPE.subGroupMsg then
            self._receive = self.sessionId
        elseif self.subCategory == MAIL_SUBTYPE.subPersonalMsg then
            self._receive = self.Receiver
        end
        -- self:ReadMsg(infos.LastMsg.Number)
        self:InitListView()
    end
    self:InitInputBox()
    self:RefreshBanList()
end

function Mail_PersonalNews:RefreshBanList()
    self._banList = BlockListModel.GetList()
    self._banMap = {}
    for _,v in ipairs(self._banList)do
        self._banMap[v.UserId] = v
    end
end

function Mail_PersonalNews:RefreshData(info)
    self._bar:SetData(info, self)
    self._panel:RefreshData()
end

function Mail_PersonalNews:InitEvent(  )
    self:AddListener(self._view:GetChild("btnReturn").onClick,function() 
        self:Close()
    end)

    self:AddListener(self._btnChatGroup.onClick,function() 
        local data = {
            subCategory = self.subCategory,
            receiver = self._titleText,
            sessionId = self.sessionId,
            messageUserId = self.messageUserId
        }
        UIMgr:Open("MailPersonalNews_AddFriends", data, self.members)
    end)

    self:AddListener(self._view:GetChild("btnBlue").onClick,function()
        if self._banMap[self.targetId] then
            TipUtil.TipById(50267)
            return
        end
        local msg = self._inputText.text
        local text = string.gsub(msg,"%s+","")
        if msg == "" or text == "" then
            TipUtil.TipById(50220)
            return
        end
        local _cb = function(AlliancePos)
            SdkModel.TrackBreakPoint(10040)      --打点
            Net.Mails.Send(self.subCategory, self._receive, msg, AlliancePos, function(rsp)
                if GuidedModel._changeNameFlag and GuidedModel._changeNameStep == 3 then
                    Net.AllianceDaily.AlliancePresientTaskMarkRename()
                end
                self.isChange = true
                self._inputText.text = ""
                self._textChat.text = ""
                self.inputCache = ""
                self:RefreshInputBox()
            end)
            self._emojieBox:Refresh()
        end
        if self.subCategory == MAIL_SUBTYPE.subMailSubTypeAllianceNotify then
            UIMgr:Open("MailAllInformation", _cb)
        else
            _cb(nil)
        end
    end)

    self:AddListener(self._view.onTouchEnd,function(context)
        Event.Broadcast(CHAT_EVENT_TYPE.CloseChatBar, self)
    end)

    self:AddListener(self._btnEmojie.onClick,function()
        if self.isShowEmojie then
            self.isShowEmojie = false
            self._btnEmojie.asButton.selected = false
        else
            self.isShowEmojie = true
            self._btnEmojie.asButton.selected = true

            -- self.inputClickNum = 0
            -- self.__keyBoardH = 0
            -- CustomInput.Close()
            -- print("====onClick=====")
        end
        self:RefreshInputBox()
        self._listView.scrollPane:ScrollBottom()
    end)

    self:AddListener(self._inputText.onChanged,function()
        if utf8.len(self._inputText.text) >= 1000 then
            TipUtil.TipById(50088)
            self._inputText.text = self.inputCache
            return
        end
        self.inputCache = self._inputText.text
        self:RefreshInputBox()
    end)

    self:AddListener(self._view.onTouchBegin,function(context)
        local _touchY = context.inputEvent.y * GRoot.inst.height / Screen.height
        self._touchY = _touchY
        local changeH = self._inputText.displayObject.height - self._inputH
        if self._box.y < (self.inputY - changeH) and _touchY < self._box.y then
            self._listView.scrollPane:ScrollBottom()
            self._listView.height = self.listViewH
            self._btnEmojie.asButton.selected = false
            self.isShowEmojie = false
            self:RefreshInputBox()
        end
    end)

    self.__keyBoardH = 0
    local _inputCB
    local _enterCb
    local _keyboardHCB
    local _selectionStart = 0
    local _isFocusIn = false
    self._input = false

    _inputCB = function(msg)
        self._input = true
        if self._inputText.inputTextField.selectionStart then
            self._inputText.inputTextField.selectionStart = _selectionStart
        else
            self._inputText.inputTextField:SetSelection(_selectionStart, 
                    self._inputText.inputTextField.caretPosition - _selectionStart)
        end
        self._inputText.inputTextField:ReplaceSelection(msg)
        self._inputText:InvalidateBatchingState(true)
        self._textChat:InvalidateBatchingState(true)

        -- self._inputText.inputTextField:SetSelection(self._inputText.inputTextField.caretPosition, 0)
        -- if msg ~= "" then
        --     CustomInput.Show("", true, _inputCB, _enterCb, _keyboardHCB)
        --     self._inputText.inputTextField:ReplaceSelection(msg)
        -- end
        self:RefreshInputBox()
        Log.Info("======= _inputCB=============   " .. msg .. "  " .. _selectionStart .. "  " .. self._inputText.inputTextField.caretPosition)  
    end

    _enterCb = function()
        Log.Info("======= _enterCb=============   ")  
    end

    _keyboardHCB = function(_keyBoardH)
        local _keyBoardH = (Screen.height - _keyBoardH) * GRoot.inst.height / Screen.height
        if self.__keyBoardH == _keyBoardH then
            return
        end

        self.__keyBoardH = _keyBoardH
        if self.__keyBoardH == 0 then
            Stage.inst.focus = Stage.inst
        end
        self:RefreshInputBox()
        Log.Info("======= _keyboardHCB=============  keyBoardH  ".._keyBoardH
        .." inputY " .. self.inputY
        .." GRoot height " .. GRoot.inst.height)
    end

    self:AddListener(self._inputText.onChanged,function()
        self._inputText.text = string.gsub(self._inputText.text, "[[%]]+", "")
        self._textChat.text = self._inputText.text
        if self._input then
            self._input = false
        else
            if not KSUtil.IsEditor() then
                if self._inputText.inputTextField.selectionStart then
                    self._inputText.inputTextField.selectionStart = _selectionStart
                else
                    self._inputText.inputTextField:SetSelection(_selectionStart, 
                            self._inputText.inputTextField.caretPosition - _selectionStart)
                end 
            end
            CustomInput.Show(self._inputText.inputTextField:GetSelection(), true, _inputCB, _enterCb, _keyboardHCB)
        end
        Log.Info("======= onChanged=============   " .. self._inputText.inputTextField.caretPosition)  
        self:RefreshInputBox()
    end)

    self:AddListener(self._inputText.inputTextField.onCatetChanged,function()
        if self._inputText.inputTextField.selectionStart then
            self._inputText.inputTextField.selectionStart = _selectionStart
        else
            self._inputText.inputTextField:SetSelection(_selectionStart, 
                    self._inputText.inputTextField.caretPosition - _selectionStart)
        end
        CustomInput.Show(self._inputText.inputTextField:GetSelection(), true, _inputCB, _enterCb, _keyboardHCB)
        Log.Info("======= onCatetChanged=============   " .. self._inputText.inputTextField.caretPosition)  
        self:RefreshInputBox()
    end)
    
    self._inputText.keyboardInput = false

    local _touchTime = 0
    local touchTime
    local chatbarIsShow = false

    local _focusOutCb = function()
        if chatbarIsShow then
            UIMgr:HidePopup("Common", "itemChatBar")
            self._inputText:RequestFocus()
            chatbarIsShow = false
        else
            self.inputClickNum = 0
            self.__keyBoardH = 0
            self:RefreshInputBox()
            CustomInput.Close()
        end
    end

    touchTime = function()
        if _touchTime >= 1 then
            local chatBar = ChatBarModel.GetChatBar()
            chatBar:SetBtnOne(StringUtil.GetI18n(I18nType.Commmon, "UI_TEXT_PASTE"), function()
                -- self._inputText.text = self._inputText.text..GUIUtility.systemCopyBuffer
                -- self._inputText.inputTextField:SetSelection(self._inputText.inputTextField.caretPosition,  0)
                if self._inputText.inputTextField.selectionStart then
                    self._inputText.inputTextField.selectionStart = _selectionStart
                else
                    self._inputText.inputTextField:SetSelection(_selectionStart, 
                            self._inputText.inputTextField.caretPosition - _selectionStart)
                end
                local text = self._inputText.inputTextField:GetSelection()..GUIUtility.systemCopyBuffer
                CustomInput.Show(text, true, _inputCB, _enterCb, _keyboardHCB)
                -- self._inputText.inputTextField:ReplaceSelection(text)
                -- self._inputText.text = self._inputText.text
                -- self._textChat.text = self._inputText.text
                self._inputText:InvalidateBatchingState(true)
                self._textChat:InvalidateBatchingState(true)
                self:UnSchedule(_focusOutCb)
                -- self._inputText.inputTextField:SetSelection(0, -1)
                -- self._inputText.inputTextField:SetSelection(_selectionStart, self._inputText.inputTextField.caretPosition - _selectionStart)
                self._inputText:RequestFocus()
                self:RefreshInputBox()
                UIMgr:HidePopup("Common", "itemChatBar")
                _touchTime = 0
                chatbarIsShow = false
            end)
            if self._inputText.text == "" then
                chatBar:Init(0)
            else
                chatBar:Init(1)
                chatBar:SetBtnTwo(StringUtil.GetI18n(I18nType.Commmon, "Ui_Choose_All"), function()
                    self:UnSchedule(_focusOutCb)
                    self._inputText.inputTextField:SetSelection(0, -1)
                    self._inputText:RequestFocus()
                    self:RefreshInputBox()
                    UIMgr:HidePopup("Common", "itemChatBar")
                    _touchTime = 0
                    chatbarIsShow = false
                end)
            end
            UIMgr:ShowPopup("Common", "itemChatBar", self._inputText, false)
            local caretPos = InputTextField.Caret:LocalToGlobal(Vector2.zero)
            chatBar.x = chatBar.x + InputTextField.Caret.x
            chatBar.y = chatBar.y + InputTextField.Caret.y
            chatbarIsShow = true
        else
            _touchTime = _touchTime + 1
        end
    end

    self:AddListener(self._inputText.onTouchBegin,function()
        self.inputClickNum = 0
        if self._inputText.inputTextField.selectionStart then
            self._inputText.inputTextField.selectionStart = _selectionStart
        else
            self._inputText.inputTextField:SetSelection(_selectionStart, 
                    self._inputText.inputTextField.caretPosition - _selectionStart)
        end
        -- self._inputText.inputTextField:SetSelection(0, -1)
        -- _selectionStart = self._inputText.inputTextField.caretPosition
        -- CustomInput.Show(self._inputText.inputTextField:GetSelection(), true, _inputCB, _enterCb, _keyboardHCB)
        -- self._inputText.inputTextField:SetSelection(self._inputText.inputTextField.caretPosition, 0)
        CustomInput.Show(self._inputText.inputTextField:GetSelection(), true, _inputCB, _enterCb, _keyboardHCB)

        if chatbarIsShow then
            UIMgr:HidePopup("Common", "itemChatBar")
            chatbarIsShow = false
        else
            touchTime()
        end

        Log.Info("======= onFocusIn=============  _selectionStart " .. _selectionStart.. " GetSelection " .. self._inputText.inputTextField:GetSelection())
    end)

    -- self:AddListener(self._inputText.onTouchEnd,function()
    --     self:UnSchedule(touchTime)
    --     _touchTime = 0
    -- end)

    self:AddListener(self._inputText.onFocusOut,function()
        self:ScheduleOnce(_focusOutCb, 0.1)
        _touchTime = 0
    end)

    local callback = function(item, type)
        if type < 100 then -- 小表情
            self._input = true
            self._inputText.inputTextField:SetSelection(self._inputText.inputTextField.caretPosition, 0)
            EmojiesMgr:TextInputAddEmojie(self._inputText, UIPackage.GetItemByURL(item:GetChild("icon").icon).name)
        elseif type >= 100 then -- 大表情
            if self._banMap[self.targetId] then
                TipUtil.TipById(50267)
                return
            end
            local msg = self._inputText.text
            self._inputText.text = ""
            EmojiesMgr:TextInputAddEmojie(self._inputText, UIPackage.GetItemByURL(item:GetChild("icon").icon).name)
            SdkModel.TrackBreakPoint(10040)      --打点
            Net.Mails.Send(self.subCategory, self._receive, self._inputText.text, function(rsp)
                self:RefreshInputBox()
                self.isChange = true
            end)
            self._inputText.text = msg
            self._textChat.text = msg
        end
        self:RefreshInputBox()
    end

    self._emojieBox:SetData(callback)
    self._listView.itemProvider = function(index)
        if not index then 
            return
        end
        local info = self.Infos[#self.Infos - index]
        if info.msgType == MAIL_MSG_TYPE.System then
            return "ui://Mail/itemMailPersonalNewsChatBox"
        elseif info.UserId == UserModel.data.accountId then
            return "ui://Common/itemMailPersonalNewsChatR"
        else
            return "ui://Common/itemMailPersonalNewsChatL"
        end
    end

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        local _msg = self.Infos[#self.Infos - index]
        if not _msg then
            return
        end
        for _,v in pairs(self.members)do
            if v.UserId == _msg.UserId then
                _msg.VipActive = v.VipActive
                _msg.VipLevel = v.VipLevel
                _msg.Alliance = v.Alliance
                _msg.Sender = v.Name
                _msg.Avatar = v.Avatar
                _msg.DressUpUsing = v.DressUpUsing
                break
            end
        end
        item:SetData(index, self.Infos[#self.Infos - index], MSG_TYPE.Mail, nil, self.Infos[#self.Infos - index + 1])
    end
    self:AddListener(self._listView.scrollPane.onPullDownRelease,function()
        self:refreshListItems()
    end)
    self._listView.scrollItemToViewOnClick = false
    self._listView:SetVirtual()

    self:AddEvent(MAILEVENTTYPE.MailNewMsg,function(rsp)
        if self.isOpen and self.sessionId == rsp.SessionId then
            self.Infos = MailModel:GetMsgInfoMsgfByType(self.sessionId)
            self._listView.numItems  = #self.Infos
            self._listView.scrollPane:ScrollBottom()
            self:ReadMsg(rsp.MailMessage.Number)
        end
    end)

    self:AddEvent(MAILEVENTTYPE.MailMsgReadEvent, function()
        if not self.isOpen then
            return 
        end
        self.Infos = MailModel:GetMsgInfoMsgfByType(self.sessionId)
        self._listView.numItems = #self.Infos
        if self.isFirst then
            self._listView.scrollPane:ScrollBottom()
            self.isFirst = false
        end
    end)

    self:AddEvent(MAILEVENTTYPE.MailGroupChange, function(info)
        if self.isOpen and info.Category == MAIL_SUBTYPE.subGroupMsg and self.sessionId == info.Uuid then
            self:SetMsgGroupTitle(info.Title, #info.Members)
        end
    end)
    self:AddEvent(CHAT_EVENT_TYPE.Refresh, function()
        if not self.isOpen then
            return 
        end
        self._listView.numItems = #self.Infos
    end)

    self:AddEvent(EventDefines.GameOnFocus,function()
        if not self.isOpen then
            return 
        end
        self.__keyBoardH = 0
        self:RefreshInputBox()
    end)
end

function Mail_PersonalNews:SetMsgGroupTitle(title, num)
    if title == "" then
        self._textName.text = string.format( "群聊(%d)", num)
    else
        self._textName.text = title
    end
end

function Mail_PersonalNews:InitListView( )
    self._listView.numItems = #self.Infos
    self._listView.scrollPane:ScrollBottom()
end

function Mail_PersonalNews:refreshListItems()
    self.Infos = MailModel:GetMsgInfoByTypeOrRaise(self.sessionId, #self.Infos)
    if self._listView.numItems == #self.Infos then
        return
    end
    self._listView.numItems = #self.Infos
end

function Mail_PersonalNews:InitInputBox()
    -- self._inputText.displayObject.height = self._inputH
    local changeH = self._inputText.displayObject.height - self._inputH
    self._inputText.height = self._inputText.displayObject.height
    self._textChat.height = self._textChat.displayObject.height
    self._boxInput.height = self._boxInputH + changeH
    self._box.height = self._boxH + changeH
    
    -- self._box.y = self.inputY - changeH
    self:BoxMoveTo(self.inputY - changeH)

    self._listView.height = self.listViewH
    self._btnEmojie.asButton.selected = false
end

function Mail_PersonalNews:RefreshInputBox()
    local changeH = self._inputText.displayObject.height - self._inputH
    self._inputText.height = self._inputText.displayObject.height
    self._textChat.height = self._textChat.displayObject.height
    self._boxInput.height = self._boxInputH + changeH
    self._box.height = self._boxH + changeH
    if self.isShowEmojie and self.__keyBoardH <= 0  then
        self:BoxMoveTo(self.inputY - changeH - self._emojieBoxH)
    else
        self:BoxMoveTo(self.inputY - changeH - self.__keyBoardH)
    end
end

local _moveEnd = true
local _moveEndCb = function()
    _moveEnd = true
end

function Mail_PersonalNews:BoxMoveTo(posY)
    if self._box.y == posY then
        if not _moveEnd then
            GTween.Kill(self._box)
            GTween.Kill(self._listView)
            _moveEnd = false
        end
    else
        GTween.Kill(self._box)
        GTween.Kill(self._listView)
        _moveEnd = false
        local _change = self._box.y - posY
		self:GtweenOnUpdate(self:GtweenOnComplete(self._box:TweenMoveY(posY , math.abs(_change)/1500),_moveEndCb),function()
            self._view:InvalidateBatchingState(true)
        end)
        self:GtweenOnUpdate(self._listView:TweenMoveY(self._listView.y - _change, math.abs(_change)/1500),function()
            self._view:InvalidateBatchingState(true)
        end)
    end
end

function Mail_PersonalNews:ReadMsg(number)
    Net.Mails.MarkSessionReaded(self.sessionId, number, function()
        MailModel:updateMsgIsReadDatas(self.sessionId, number)
        Event.Broadcast(EventDefines.UIMailsNumChange, {})
    end)
end

function Mail_PersonalNews:OnHide()
    CustomInput.Close()
end

function Mail_PersonalNews:Close()
    UIMgr:Close("Mail_PersonalNews")
end

function Mail_PersonalNews:OnClose()
    self.isOpen = false
    if self.isChange then
        Event.Broadcast(MAILEVENTTYPE.MailRefresh)
    end
end

return Mail_PersonalNews