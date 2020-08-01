--author: 	Amu
--time:		2019-07-16 09:55:21

local BuildModel = import("Model/BuildModel")
local ChatBarModel = import("Model/ChatBarModel")

import("UI/Mail/Item/ItemMailPersonalNewsChatL")
import("UI/Mail/Item/ItemMailPersonalNewsChatR")
import("UI/Chat/ItemChatExpressionSelect")
import("UI/Common/ItemChatBar")

local ShieldType = {}
ShieldType.Player = 0
ShieldType.Union = 1

local UnionMessage = UIMgr:NewUI("UnionMessage")
local newMessageId = 0
local isOpen = false

function UnionMessage:OnInit()
    self._view = self.Controller.contentPane

    self._inputText = self._view:GetChild("textInput").asTextInput
    self._textChat = self._view:GetChild("textChat").asTextInput

    self._btnTopBgBar = self._view:GetChild("btnTopBgBar")
    self._btnReturn = self._view:GetChild("btnReturn")
    self._textName = self._view:GetChild("textName")
    self._textInformation = self._view:GetChild("textInformation")
    self._bgTag = self._view:GetChild("bgTag")

    self._listView = self._view:GetChild("liebiao")

    self._emojieBox = self._view:GetChild("itemExpressionSelect")
    self._btnEmojie = self._view:GetChild("iconExpression")

    self._box = self._view:GetChild("bgBox3")
    self._group = self._view:GetChild("groupTaskOpen")
    self._boxInput = self._view:GetChild("boxInput")
    self.inputY = self._box.y + GRoot.inst.height - 1334
    self._boxH = self._box.height

    self._listView.height = self._listView.height + GRoot.inst.height - 1334

    -- self._group.visible = false

    --因为listview 的后渲染导致层级问题   手动设置层级
    self._emojieBox.sortingOrder = 3

    self._btnTopBgBar.sortingOrder = 4
    self._btnReturn.sortingOrder = 4
    self._textName.sortingOrder = 4
    self._textInformation.sortingOrder = 4
    self._bgTag.sortingOrder = 4

    self._view:GetChild("itemChatBar").visible = false

    self._inputText.emojies = EmojiesMgr:GetEmojies()
    self._textChat.emojies = EmojiesMgr:GetEmojies()
    self._textChat.touchable = false

    -- self._inputText.y = self._inputText.y + 35 - self._inputText.height
    -- self._boxInput.y = self._boxInput.y + 50 - self._boxInput.height
    -- self._boxInput.height = 55
    -- self._inputText.height = 45

    -- self._inputText.y = self._inputText.y + 35 - self._inputText.height
    -- -- self._boxInput.y = self._boxInput.y + 84 - self._boxInput.height
    -- self._boxInput.height = 84
    -- self._inputText.height = 45

    self.listViewY = self._listView.y
    self.listViewH = self._listView.height
    self._inputH = self._inputText.height
    self._inputY = self._inputText.y
    self._boxInputH = self._boxInput.height
    self._boxInputY = self._boxInput.y

    self._emojieBoxH = self._emojieBox.height

    self.isShowEmojie = false
    self._btnEmojie.asButton.selected = false

    self.msgList = {}
    self.banList = {}
    self.banList[ShieldType.Player] = {}
    self.banList[ShieldType.Union] = {}

    self:InitEvent()
end

function UnionMessage:OnOpen(unionId)
    isOpen = true
    self.inputClickNum = 0
    self.banList = {}
    self.banList[ShieldType.Player] = {}
    self.banList[ShieldType.Union] = {}
    self.msgList = {}
    self.unionId = unionId and unionId or Model.Player.AllianceId
    -- self._inputText.text = ""
    -- self._textChat.text = ""
    self:RefreshView()
    self:InitInputBox()
    Net.AllianceMessage.RequestMessageList(self.unionId, #self.msgList, function(msg)
        for _, v in pairs(msg.MessageList) do
            v.DressUpUsing = v.DressUpUsingList
            table.insert(self.msgList, v)
        end
        -- table.sort(self.msgList, function(a, b)
        --     return a.MessageId<b.MessageId
        -- end)
        if self.unionId == Model.Player.AllianceId then
            local MessageId = 0
            if #self.msgList > 0 then
                MessageId = self.msgList[1].MessageId
            end
            PlayerDataModel:SetData(PlayerDataEnum.UnionMsgId, MessageId)
            newMessageId = MessageId
        end
        Net.AllianceMessage.RequestBanList(
            self.unionId,
            function(msg)
                self.banList[ShieldType.Player] = msg.BanList
                self.banList[ShieldType.Union] = msg.AllianceBanList
                self:DelHaveBanPlay()
                self:RefreshView()
            end
        )

        if self.unionId == Model.Player.AllianceId then
            Net.AllianceMessage.MarkRead(
                newMessageId,
                function()
                end
            )
            Model.UnreadAllianceMessages = 0
        end
    end)
end

function UnionMessage:InitEvent()
    self:AddListener(self._view:GetChild("btnReturn").onClick,
        function()
            self:Close()
        end
    )

    self:AddListener(self._view:GetChild("btnBlue").onClick,
        function()
            if BuildModel.GetCenterLevel() < 11 then
                TipUtil.TipById(50160)
                return
            end
            local msg = {}
            msg.AllianceId = self.unionId
            msg.Content = self._inputText.text
            if msg.Content == "" then
                TipUtil.TipById(50197)
                return
            end
            for _, v in ipairs(self.banList[ShieldType.Player]) do
                if v.PlayerId == UserModel.data.accountId then
                    TipUtil.TipById(50162)
                    return
                end
            end

            for _, allianceId in ipairs(self.banList[ShieldType.Union]) do
                if Model.Player.AllianceId == allianceId then
                    TipUtil.TipById(50163)
                    return
                end
            end
            SdkModel.TrackBreakPoint(10043) --打点
            Net.AllianceMessage.RequestSendMessage(
                msg,
                function()
                    self._inputText.text = ""
                    self._textChat.text = ""
                    self:RefreshInputBox()
                end
            )
            self._emojieBox:Refresh()
        end
    )

    self:AddListener(self._view.onTouchEnd,
        function(context)
            Event.Broadcast(CHAT_EVENT_TYPE.CloseChatBar, self)
        end
    )

    self:AddListener(self._btnEmojie.onClick,
        function()
            if self.isShowEmojie then
                self.isShowEmojie = false
                self._btnEmojie.asButton.selected = false
            else
                self.isShowEmojie = true
                self._btnEmojie.asButton.selected = true
                -- self.inputClickNum = 0
                -- self.__keyBoardH = 0
                -- CustomInput.Close()
            end
            self:RefreshInputBox()
            self._listView.scrollPane:ScrollBottom()
        end
    )

    self:AddListener(self._inputText.onChanged,
        function()
            self:RefreshInputBox()
        end
    )

    self:AddListener(self._inputText.onClick,
        function()
            if self.inputClickNum >= 1 then
                local chatBar = ChatBarModel.GetChatBar()
                chatBar:Init(0)
                chatBar:SetBtnOne(
                    StringUtil.GetI18n(I18nType.Commmon, "UI_TEXT_PASTE"),
                    function()
                        self._inputText.text = self._inputText.text .. GUIUtility.systemCopyBuffer
                        self:RefreshInputBox()
                    end
                )
                UIMgr:ShowPopup("Common", "itemChatBar", self._inputText, false)
            else
                self.inputClickNum = self.inputClickNum + 1
            end
        end
    )

    self:AddListener(self._view.onTouchBegin,
        function(context)
            local _touchY = context.inputEvent.y * GRoot.inst.height / Screen.height
            self._touchY = _touchY
            local changeH = self._inputText.displayObject.height - self._inputH
            if self._box.y < (self.inputY - changeH) and _touchY < self._box.y then
                -- self._box.y = self.inputY - changeH
                self._listView.scrollPane:ScrollBottom()
                self._listView.height = self.listViewH
                self._btnEmojie.asButton.selected = false
                self.isShowEmojie = false
                self:RefreshInputBox()
            end
        end
    )

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
        Log.Info("======= _keyboardHCB=============  keyBoardH  " .. _keyBoardH .. " inputY " .. self.inputY .. " GRoot height " .. GRoot.inst.height)
    end

    self:AddListener(self._inputText.onChanged,
        function()
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
        end
    )

    self:AddListener(self._inputText.inputTextField.onCatetChanged,
        function()
            if self._inputText.inputTextField.selectionStart then
                self._inputText.inputTextField.selectionStart = _selectionStart
            else
                self._inputText.inputTextField:SetSelection(_selectionStart, 
                        self._inputText.inputTextField.caretPosition - _selectionStart)
            end
            CustomInput.Show(self._inputText.inputTextField:GetSelection(), true, _inputCB, _enterCb, _keyboardHCB)
            Log.Info("======= onCatetChanged=============   " .. self._inputText.inputTextField.caretPosition)
            self:RefreshInputBox()
        end
    )

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
        CustomInput.Show(self._inputText.inputTextField:GetSelection(), true, _inputCB, _enterCb, _keyboardHCB)

        if chatbarIsShow then
            UIMgr:HidePopup("Common", "itemChatBar")
            chatbarIsShow = false
        else
            touchTime()
        end

        Log.Info("======= onFocusIn=============  _selectionStart " .. _selectionStart .. " GetSelection " .. self._inputText.inputTextField:GetSelection())
    end)

    -- self:AddListener(self._inputText.onTouchEnd,function()
    --     self:UnSchedule(touchTime)
    --     _touchTime = 0
    -- end)

    self:AddListener(self._inputText.onFocusOut,function()
        self:ScheduleOnce(_focusOutCb, 0.1)
        _touchTime = 0
    end)

    self._listView.itemProvider = function(index)
        if not index then
            return
        end
        local info = self.msgList[#self.msgList - index]
        if info.SelfAllianceId == Model.Player.AllianceId then
            return "ui://Common/itemMailPersonalNewsChatR"
        else
            return "ui://Common/itemMailPersonalNewsChatL"
        end
    end

    local callback = function(info)
        if info.SenderId == UserModel.data.accountId then
            return
        end
        UIMgr:Open("UnionMessageShield", PLAYER_CONTACT_BOX_TYPE.ChatBox, info)
    end

    self._listView.itemRenderer = function(index, item)
        if not index then
            return
        end
        item:SetData(index, self.msgList[#self.msgList - index], MSG_TYPE.LMsg, callback, self.msgList[#self.msgList - index + 1])
    end
    self:AddListener(self._listView.scrollPane.onPullDownRelease,function()
        self:RefreshListItems()
    end)

    self._listView.scrollItemToViewOnClick = false
    self._listView:SetVirtual()

    local callback = function(item, type)
        if type < 100 then -- 小表情
            self._input = true
            self._inputText.inputTextField:SetSelection(self._inputText.inputTextField.caretPosition, 0)
            EmojiesMgr:TextInputAddEmojie(self._inputText, UIPackage.GetItemByURL(item:GetChild("icon").icon).name)
        elseif type >= 100 then -- 大表情
            if BuildModel.GetCenterLevel() < 11 then
                TipUtil.TipById(50160)
                return
            end
            local msg = self._inputText.text
            self._inputText.text = ""
            EmojiesMgr:TextInputAddEmojie(self._inputText, UIPackage.GetItemByURL(item:GetChild("icon").icon).name)
            local _msg = {}
            _msg.AllianceId = self.unionId
            _msg.Content = self._inputText.text
            SdkModel.TrackBreakPoint(10043) --打点
            Net.AllianceMessage.RequestSendMessage(
                _msg,
                function()
                    self:RefreshInputBox()
                end
            )
            self._inputText.text = msg
            self._textChat.text = msg
        end
        self:RefreshInputBox()
        self:RefreshListItems()
    end

    self._emojieBox:SetData(callback)

    self:AddEvent(EventDefines.AllianceMessage, function(msg)
        if self.unionId ~= msg.AllianceId then
            return
        end
        if isOpen then
            PlayerDataModel:SetData(PlayerDataEnum.UnionMsgId, msg.MessageId)
            newMessageId = msg.MessageId

            if self.unionId == Model.Player.AllianceId then
                Net.AllianceMessage.MarkRead(
                    newMessageId,
                    function()
                    end
                )
                Model.UnreadAllianceMessages = 0
            end
        end
        self:AddNewMsg(msg)
        self:RefreshView()
    end)

    self:AddEvent(UNION_MSG_EVENT.Del, function(uuid)
        for k, v in ipairs(self.msgList) do
            if v.Uuid == uuid then
                table.remove(self.msgList, k)
                self:RefreshView()
                return
            end
        end
    end)

    self:AddEvent(UNION_MSG_BAN.BanPlayer,function(SenderId)
        table.insert(self.banList[ShieldType.Player], {PlayerId = SenderId})
        for i = #self.msgList, 1, -1 do
            local info = self.msgList[i]
            if info.SenderId == SenderId then
                table.remove(self.msgList, i)
            end
        end
        self:RefreshView()
    end)

    self:AddEvent(UNION_MSG_BAN.BanAlliance, function(info)
        table.insert(self.banList[ShieldType.Union], info)
        for i = #self.msgList, 1, -1 do
            local info = self.msgList[i]
            if info.SelfAllianceId == info.AllianceId then
                table.remove(self.msgList, i)
                break
            end
        end
        self:RefreshView()
    end)

    self:AddEvent(CHAT_EVENT_TYPE.Refresh, function()
        self._listView.numItems = #self.msgList
    end)

    self:AddEvent(EventDefines.GameOnFocus,function()
        if not isOpen then
            return
        end
        self.__keyBoardH = 0
        self:RefreshInputBox()
    end)
end

function UnionMessage:DelHaveBanPlay()
    for i = #self.msgList, 1, -1 do
        local info = self.msgList[i]
        for _, banInfo in ipairs(self.banList[ShieldType.Union]) do
            if info.SelfAllianceId == banInfo.AllianceId then
                table.remove(self.msgList, i)
                break
            end
        end

        for _, Player in ipairs(self.banList[ShieldType.Player]) do
            if info.SenderId == Player.PlayerId then
                table.remove(self.msgList, i)
                break
            end
        end
    end
end

function UnionMessage:AddNewMsg(msg)
    for _, banInfo in ipairs(self.banList[ShieldType.Union]) do
        if msg.SelfAllianceId == banInfo.AllianceId then
            return
        end
    end

    for _, Player in ipairs(self.banList[ShieldType.Player]) do
        if msg.SenderId == Player.PlayerId then
            return
        end
    end
    table.insert(self.msgList, 1, msg)
end

function UnionMessage:RefreshView()
    self._listView.numItems = #self.msgList
    self._listView.scrollPane:ScrollBottom()
end

function UnionMessage:RefreshListItems()
    Net.AllianceMessage.RequestMessageList(self.unionId, #self.msgList, function(msg)
        for _, v in pairs(msg.MessageList) do
            table.insert(self.msgList, v)
        end
        -- table.sort(self.msgList, function(a, b)
        --     return a.MessageId<b.MessageId
        -- end)
        self:DelHaveBanPlay()
        self:RefreshView()
    end)
end

function UnionMessage:InitInputBox()
    -- self._inputText.displayObject.height = self._inputH
    local changeH = self._inputText.displayObject.height - self._inputH
    self._inputText.height = self._inputText.displayObject.height
    self._textChat.height = self._textChat.displayObject.height
    self._boxInput.height = self._boxInputH + changeH
    self._box.height = self._boxH + changeH
    self._listView.y = self.listViewY

    -- self._box.y = self.inputY - changeH
    self:BoxMoveTo(self.inputY - changeH)

    self._listView.height = self.listViewH
    self._btnEmojie.asButton.selected = false
end

function UnionMessage:RefreshInputBox()
    local changeH = self._inputText.displayObject.height - self._inputH
    self._textChat.height = self._textChat.displayObject.height
    self._inputText.height = self._inputText.displayObject.height
    self._boxInput.height = self._boxInputH + changeH
    self._box.height = self._boxH + changeH

    -- self._inputText.y = self._inputY - changeH
    if self.isShowEmojie and self.__keyBoardH <= 0 then
        -- self._box.y = self.inputY - changeH - 468
        self:BoxMoveTo(self.inputY - changeH - self._emojieBoxH)
    else
        -- self._box.y = self.inputY - changeH
        self:BoxMoveTo(self.inputY - changeH - self.__keyBoardH)
    end
end

local _moveEnd = true
local _moveEndCb = function()
    _moveEnd = true
end

function UnionMessage:BoxMoveTo(posY)
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
		self:GtweenOnComplete(self:GtweenOnComplete(self._box:TweenMoveY(posY, math.abs(_change) / 1500),_moveEndCb),function()
            self._view:InvalidateBatchingState(true)
        end)
		self:GtweenOnUpdate(self._listView:TweenMoveY(self._listView.y - _change, math.abs(_change) / 1500),function()
            self._view:InvalidateBatchingState(true)
        end)
    end
end

function UnionMessage:OnHide()
    CustomInput.Close()
end

function UnionMessage:Close()
    UIMgr:Close("UnionMessage")
end

function UnionMessage:OnClose()
    Event.Broadcast(EventDefines.UIUnionManger)
    isOpen = false
end

---全体邮件功能

return UnionMessage
