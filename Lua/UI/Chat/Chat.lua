--author: 	Amu
--time:		2019-07-13 14:59:21

local Emojies = import("Utils/Emojies")
local ChatModel = import("Model/ChatModel")
local ChatBarModel = import("Model/ChatBarModel")
local BlockListModel = import("Model/BlockListModel")


local Chat = UIMgr:NewUI("Chat")

function Chat:OnInit()
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnReturn")
    self._btnTopBgBar = self._view:GetChild("btnTopBgBar")
    self._btnCity = self._view:GetChild("btnTagSingle1")
    self._btnUnion = self._view:GetChild("btnTagSingle2")
    self._btnEmojie = self._view:GetChild("iconExpression")
    self._btnSend = self._view:GetChild("btnBlue")
    self._btnHorn = self._view:GetChild("btnHorn")
    self._btnTask = self._view:GetChild("btnTask")
    self._btnArrow = self._view:GetChild("btnArrow")

    self._btnPull = self._view:GetChild("n84")

    self._textName = self._view:GetChild("textName")

    self._worldInputText = self._view:GetChild("worldtextInput").asTextInput
    self._worldTextChat = self._view:GetChild("worldtextChat").asTextInput

    self._unionInputText = self._view:GetChild("uniontextInput").asTextInput
    self._unionTextChat = self._view:GetChild("uniontextChat").asTextInput

    self._worldTextChat.visible = false
    self._unionTextChat.visible = false

    self._inputText = self._worldInputText
    self._textChat  = self._worldTextChat

    self._boxInput = self._view:GetChild("boxInput")

    self._listView = self._view:GetChild("liebiao")
    self._listViewTask = self._view:GetChild("liebiaoTask")

    self._box = self._view:GetChild("bgBox3")
    self._bgBox2 = self._view:GetChild("bgBox2")
    self._group = self._view:GetChild("groupTaskOpen")
    self._groupDown = self._view:GetChild("groupDown")
    self._itemChatBar = self._view:GetChild("itemChatBar")

    self._emojieBox = self._view:GetChild("itemExpressionSelect")

    self._ctrView = self._view:GetController("c1")
    self._horeCtrView = self._view:GetController("c2")

    self._itemJoin = self._view:GetChild("itemJoin")
    self._btnJoin = self._itemJoin:GetChild("btnJoin")

    self.taskerName = self._btnTask:GetChild("textCustomerServiceName")
    self.taskerNum = self._btnTask:GetChild("textCustomerServiceNum")
    self.taskerMsg = self._btnTask:GetChild("textCustomerService")
    self.taskerNum.visible =false

    -- self._listView.height = self._listView.height
    -- self._listViewTask.height = self._listViewTask.height + GRoot.inst.height-1334

    --因为listview 的后渲染导致层级问题   手动设置层级
    self._emojieBox.sortingOrder = 3
    self._btnTopBgBar.sortingOrder = 4
    self._btnReturn.sortingOrder = 4
    self._btnCity.sortingOrder = 4
    self._btnUnion.sortingOrder = 4
    self._textName.sortingOrder = 4

    -- self._boxInput.sortingOrder = 1

    -- self._worldTextChat.sortingOrder = 1
    -- self._worldInputText.sortingOrder = 1
    -- self._unionTextChat.sortingOrder = 1
    -- self._unionInputText.sortingOrder = 1
    
    self.inputY = self._box.y + GRoot.inst.height-1334
    self._boxH = self._box.height
    self._group.visible = false
    self._itemChatBar.visible = false

    self._btnTaskY = self._btnTask.y
    self._btnTaskH = self._btnTask.height

    self._emojieBoxH = self._emojieBox.height

    self.listViewY = self._listView.y
    self.listViewH = self._listView.height + GRoot.inst.height-1334

    self._inputText.emojies = EmojiesMgr:GetEmojies()
    self._textChat.emojies = EmojiesMgr:GetEmojies()
    self._unionInputText.emojies = EmojiesMgr:GetEmojies()
    self._unionTextChat.emojies = EmojiesMgr:GetEmojies()

    self._textChat.touchable = false
    -- self._inputText.y = self._inputText.y + 35 - self._inputText.height
    -- self._boxInput.y = self._boxInput.y + 84 - self._boxInput.height
    -- self._boxInput.height = 84
    -- self._inputText.height = 45
    self._inputH = self._inputText.height
    self._inputY = self._inputText.y
    self._boxInputH = self._boxInput.height
    self._boxInputY = self._boxInput.y

    self.isShowEmojie = false
    self._btnEmojie.asButton.selected = false
    self.showType = CHAT_TYPE.WorldChat
    -- ChatModel.chatType = CHAT_TYPE.WorldChat
    self._textName.text = ConfigMgr.GetI18n("configI18nCommons", "Chat_Server_Title")

    self._clickBtn = false

    self.limit = 20

    self.msgList = {}

    self:InitEvent()
    self:InitInputTextEvent(self._inputText)
    self:InitInputTextEvent(self._unionInputText)
end

function Chat:DoOpenAnim(...)
    self:OnOpen(...)
    AnimationLayer.PanelAnim(AnimationType.PanelMoveUp, self)
end

function Chat:OnOpen(type, index, infos, panel)
    self.msgType = PUBLIC_CHAT_TYPE.Normal
    self.showType = ChatModel.chatType
    self._ctrView.selectedIndex = ChatModel.chatType
    self._horeCtrView.selectedIndex = 1
    self.onPullUp = true
    self.isShow = true
    -- self._textName.text = ConfigMgr.GetI18n("configI18nCommons", "Chat_Server_Title")
    if(self._ctrView.selectedIndex == 0)then
        self._textName.text = ConfigMgr.GetI18n("configI18nCommons", "Chat_Server_Title")
        self._inputText = self._worldInputText
        self._textChat  = self._worldTextChat
    else
        self._textName.text = ConfigMgr.GetI18n("configI18nCommons", "Chat_Alliance_Title")
        self._inputText = self._unionInputText
        self._textChat  = self._unionTextChat
    end
    self._group.visible = false
    self._itemChatBar.visible = false
    -- self._inputText.text = ""
    -- self._textChat.text = ""

    self.isShowEmojie = false
    self._btnEmojie.asButton.selected = false
    self.inputClickNum = 0
    self:RefreshBanList()

    self:InitInputBox()
    self:RefreshView(self.showType)
    self:RefreshListViewH()
    SdkModel.TrackBreakPoint(10037)      --打点
end

function Chat:RefreshBanList()
    self._banList = BlockListModel.GetList()
    self._banMap = {}
    for _,v in ipairs(self._banList)do
        self._banMap[v.UserId] = v
    end
end

function Chat:InitInputTextEvent(inputText)

    self.__keyBoardH = 0

    local _inputCB
    local _enterCb
    local _keyboardHCB
    local _selectionStart = 0
    local _isFocusIn = false
    self._input = false

    _inputCB = function(msg)
        -- self._textChat.inputTextField.text = msg
        -- self._inputText.inputTextField.text = msg
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
        self:RefreshInputBox()
        Log.Info("======= _inputCB=============   " .. msg .. "  " .. _selectionStart .. "  " .. self._inputText.inputTextField.caretPosition)  
    end

    _enterCb = function()
        Log.Info("======= _enterCb=============   ")  
    end

    _keyboardHCB = function(_keyBoardH)
        local _keyBoardH = (Screen.height - _keyBoardH) * GRoot.inst.height / Screen.height
        Log.Info("======= _keyboardHCB=============   " .. _keyBoardH)
        if self.__keyBoardH == _keyBoardH then
            return
        end

        Log.Info("======= _keyboardHCB=============  keyBoardH  ".._keyBoardH
        .." inputY " .. self.inputY
        .." GRoot height " .. GRoot.inst.height)
        self.__keyBoardH = _keyBoardH
        if self.__keyBoardH == 0 then
            Stage.inst.focus = Stage.inst
        end
        -- self._box.y = self.inputY - _keyBoardH
        -- self._box.y = self.inputY - (Screen.height - _keyBoardH) * GRoot.inst.height / Screen.height
        -- self:BoxMoveTo(self.inputY - _keyBoardH)
        self:RefreshInputBox()
        Log.Info("======= _keyboardHCB=============  keyBoardH  ".._keyBoardH
        .." inputY " .. self.inputY
        .." GRoot height " .. GRoot.inst.height)
    end

    self:AddListener(inputText.onChanged,function()
        self._inputText.text = string.gsub(self._inputText.text, "[[%]]+", "")
        self._textChat.text = self._inputText.text
        self._inputText:InvalidateBatchingState(true)
        self._textChat:InvalidateBatchingState(true)
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
            Log.Info("======= onChanged=====GetSelection========   " ..self._inputText.inputTextField:GetSelection())
            CustomInput.Show(self._inputText.inputTextField:GetSelection(), true, _inputCB, _enterCb, _keyboardHCB)
        end
        -- UIMgr:HidePopup("Common", "itemChatBar")
        self:RefreshInputBox()
        if self._inputText.inputTextField.ClearSelection then
            self._inputText.inputTextField:ClearSelection()
        end
        Log.Info("======= onChanged=============   " ..self._inputText.text .. "  ".. self._inputText.inputTextField.caretPosition)  
    end)

    self:AddListener(inputText.inputTextField.onCatetChanged,function()
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
    
    inputText.keyboardInput = false

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
                self._inputText.inputTextField:SetSelection(_selectionStart, self._inputText.inputTextField.caretPosition - _selectionStart)
                local text = self._inputText.inputTextField:GetSelection()..GUIUtility.systemCopyBuffer
                CustomInput.Show(text, true, _inputCB, _enterCb, _keyboardHCB)
                self._inputText:InvalidateBatchingState(true)
                self._textChat:InvalidateBatchingState(true)
                self:UnSchedule(_focusOutCb)
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

    self:AddListener(inputText.onTouchBegin,function()
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
        Log.Info("======= onFocusIn=============  _selectionStart " .. _selectionStart.. " GetSelection " .. self._inputText.inputTextField:GetSelection())
    end)

    -- self:AddListener(inputText.onTouchEnd,function()
    --     _touchTime = 0
    -- end)

    --因为输入表情调用了SetSelection   灰设置焦点 导致分发了onFocusIn事件所以废弃
    self:AddListener(inputText.onFocusIn,function()
        -- -- CustomInput.Close()
        self.inputClickNum = 0

        -- Log.Info("======= onFocusIn=============  _selectionStart " .. _selectionStart.. " GetSelection " .. self._inputText.inputTextField:GetSelection())
    end)

    self:AddListener(inputText.onFocusOut,function()
        self:ScheduleOnce(_focusOutCb, 0.1)
        _touchTime = 0
    end)
end

function Chat:InitEvent(  )
    self:AddListener(self._btnReturn.onClick,function() 
        self:Close()
    end)

    self:AddListener(self._view.onTouchEnd,function(context)
        Event.Broadcast(CHAT_EVENT_TYPE.CloseChatBar, self)
    end)

    self:AddListener(self._btnCity.onClick,function()
        if self.showType ~= CHAT_TYPE.WorldChat then
            self._ctrView.selectedIndex = CHAT_TYPE.WorldChat
        end
        self._textName.text = ConfigMgr.GetI18n("configI18nCommons", "Chat_Server_Title")
        self._group.visible = false
    end)

    self:AddListener(self._btnUnion.onClick,function()
        if self.showType ~= CHAT_TYPE.UnionChat then
            self._ctrView.selectedIndex = CHAT_TYPE.WorldChat
        end
        self._textName.text = ConfigMgr.GetI18n("configI18nCommons", "Chat_Alliance_Title")
    end)

    self:AddListener(self._btnJoin.onClick,function()
        -- if self.showType ~= CHAT_TYPE.UnionChat then
        --     self._ctrView.selectedIndex = CHAT_TYPE.WorldChat
        -- end
        UIMgr:Open("UnionView/UnionView")
    end)

    self:AddListener(self._btnHorn.onClick,function()
        if self._horeCtrView.selectedIndex == 0 then
            self._horeCtrView.selectedIndex = 1
            self.msgType = PUBLIC_CHAT_TYPE.Normal
        else
            UIMgr:Open("ChatHornPopup")
        end
    end)

    self:AddListener(self._ctrView.onChanged,function()
        -- if Model.Player.AllianceId == "" then
        --     
        --     return
        -- end
        if self.showType == self._ctrView.selectedIndex then
            return
        end
        self._clickBtn = true
        self.showType = self._ctrView.selectedIndex
        if self.showType == CHAT_TYPE.UnionChat then
            self._inputText = self._unionInputText
            self._textChat  = self._unionTextChat
        elseif self.showType == CHAT_TYPE.WorldChat then
            self._inputText = self._worldInputText
            self._textChat  = self._worldTextChat
        end

        ChatModel.chatType = self.showType
        self.msgType = PUBLIC_CHAT_TYPE.Normal
        self._horeCtrView.selectedIndex = 1
        self:RefreshView(self.showType)
        if self.showType == CHAT_TYPE.UnionChat then
            self:RefreshView(CHAT_TYPE.UnionHelpChat)

            -- 处理因为输入超长表情 后切换状态后 inputtext 文本displayObject.height  高度异常
            local text = self._unionInputText.text
            self._unionInputText.text = ""
            self._unionTextChat.text = ""
            self._unionInputText.displayObject.height = self._inputH
            self._unionTextChat.displayObject.height = self._inputH
            print("==_unionInputText===displayObject===== " .. self._unionInputText.displayObject.height)
            self._unionInputText.text = text
            self._unionTextChat.text = text
            print("==_unionInputText===displayObject===== " .. self._unionInputText.displayObject.height)

            self._inputText = self._unionInputText
            self._textChat  = self._unionTextChat
        elseif self.showType == CHAT_TYPE.WorldChat then
            --self._horeCtrView.selectedIndex = 0

            -- 处理因为输入超长表情 后切换状态后 inputtext 文本displayObject.height  高度异常
            local text = self._worldInputText.text
            self._worldInputText.text = ""
            self._worldTextChat.text = ""
            self._worldInputText.displayObject.height = self._inputH
            self._worldTextChat.displayObject.height = self._inputH
            print("==_worldInputText===displayObject===== " .. self._worldInputText.displayObject.height)
            self._worldInputText.text = text
            self._worldTextChat.text = text
            print("==_worldInputText===displayObject===== " .. self._worldInputText.displayObject.height)

            self._inputText = self._worldInputText
            self._textChat  = self._worldTextChat
        end
        self:RefreshInputBox()
        self:RefreshListViewH()
    end)


    self:AddListener(self._btnTask.onClick,function()
        self._group.visible = true
    end)
    
    self:AddListener(self._btnArrow.onClick,function()
        if self._group.visible then
            self._group.visible = false
        else
            self._group.visible = true
            -- self:RefreshView(CHAT_TYPE.UnionHelpChat)
        end
    end)

    self:AddListener(self._btnEmojie.onClick,function()
        if self.isShowEmojie then
            self.isShowEmojie = false
            self._btnEmojie.asButton.selected = false
        else
            self.isShowEmojie = true
            self._btnEmojie.asButton.selected = true
        end
        self:RefreshInputBox()
        self._listView.scrollPane:ScrollBottom()
    end)

    self:AddListener(self._btnSend.onClick,function()
        local msg = self._textChat.text
        msg = TextUtil:ReplaceMoreBySpace(msg, "\n", 20)
        self:SendMsg(msg)
        self._emojieBox:Refresh()
    end)

    self:AddListener(self._view.onTouchEnd,function(context)
        local _touchY = context.inputEvent.y * GRoot.inst.height / Screen.height
        local changeH = self._textChat.displayObject.height - self._inputH
        if self._box.y < (self.inputY - changeH) and _touchY < (self._box.y) then
            self._listView.scrollPane:ScrollBottom()
            self._btnEmojie.asButton.selected = false
            self.isShowEmojie = false
            if self._clickBtn then
                self._clickBtn = false
                return
            end
            self:RefreshInputBox()
        end
    end)

    self._listView.itemProvider = function(index)
        if not index then 
            return
        end
        local msg = self.msgList[self.showType].msg
        if #msg <= 0 then  --因为在数据未初始化之前就控制器就自动刷新了listview  导致错误
            return
        end
        local info = msg[#msg - index]
        if info.MType == ALLIANCE_CHAT_TYEP.Voting then  --投票结果
            if info.SenderId == UserModel.data.accountId then
                return "ui://Common/itemMailPersonalNewsChatGiftR"
            else
                return "ui://Common/itemMailPersonalNewsChatGiftL"
            end
        end
        if info.SenderId == UserModel.data.accountId then
            return "ui://Common/itemMailPersonalNewsChatR"
        else
            return "ui://Common/itemMailPersonalNewsChatL"
        end
    end

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        local msg = self.msgList[self.showType].msg
        if #msg <= 0 then  --因为在数据未初始化之前就控制器就自动刷新了listview  导致错误
            return
        end
        item:SetData(index, msg[#msg - index], MSG_TYPE.Chat, nil, msg[#msg - index + 1])
    end

    self:AddListener(self._listView.scrollPane.onPullDownRelease,function()
        self:RefreshListItems()
    end)

    self:AddListener(self._listView.scrollPane.onPullUpRelease,function()
        self.onPullUp = true
    end)

    self:AddListener(self._listView.scrollPane.onScroll,function()
        -- print("===============" .. self._listView.scrollPane.posY + self._listView.scrollPane.viewHeight .. "   " .. self._listView.scrollPane.contentHeight)
        if (self._listView.scrollPane.posY + self._listView.scrollPane.viewHeight) >= self._listView.scrollPane.contentHeight then
            self.onPullUp = true
        else
            self.onPullUp = false
        end
    end)

    self._listView.scrollItemToViewOnClick = false
    self._listView:SetVirtual()

    self._listViewTask.itemProvider = function(index)
        if not index then 
            return
        end
        local msg = self.msgList[CHAT_TYPE.UnionHelpChat].msg
        if #msg <= 0 then  --因为在数据未初始化之前就控制器就自动刷新了listview  导致错误
            return
        end
        local info = msg[#msg - index]
        if info.SenderId == UserModel.data.accountId then
            return "ui://Common/itemMailPersonalNewsChatR"
        else
            return "ui://Common/itemMailPersonalNewsChatL"
        end
    end

    self._listViewTask.itemRenderer = function(index, item)
        if not index then 
            return
        end
        local msg = self.msgList[CHAT_TYPE.UnionHelpChat].msg
        if #msg <= 0 then  --因为在数据未初始化之前就控制器就自动刷新了listview  导致错误
            return
        end
        item:SetData(index, msg[#msg - index], MSG_TYPE.Chat, nil, msg[#msg - index + 1])
    end

    self:AddListener(self._listViewTask.scrollPane.onPullDownRelease,function()
        self:RefreshListHelpItems()
    end)
    self._listViewTask:SetVirtual()

    local callback = function(item, type)
        if type < 100 then -- 小表情
            self._input = true
            self._inputText.inputTextField:SetSelection(self._inputText.inputTextField.caretPosition, 0)
            EmojiesMgr:TextInputAddEmojie(self._inputText, UIPackage.GetItemByURL(item:GetChild("icon").icon).name)
        elseif type >= 100 then -- 大表情
            local msg = self._inputText.text
            self._inputText.text = ""
            EmojiesMgr:TextInputAddEmojie(self._inputText, UIPackage.GetItemByURL(item:GetChild("icon").icon).name)
            self.msgType = PUBLIC_CHAT_TYPE.Normal
            self:SendMsg(self._inputText.text)
            self._inputText.text = msg
            self._textChat.text = msg
        end
        self:RefreshInputBox()
    end

    self._emojieBox:SetData(callback)

    self:AddEvent(EventDefines.ChatEvent, function(msg)
        if msg.RoomId == "World" then--世界频道消息
            if not self.msgList[CHAT_TYPE.WorldChat] then
                self.msgList[CHAT_TYPE.WorldChat] = {}
                self.msgList[CHAT_TYPE.WorldChat].msg = {}
            end
            for _,banUser in ipairs(self._banList)do
                if banUser.UserId == msg.SenderId then
                    return
                end
            end
            table.insert(self.msgList[CHAT_TYPE.WorldChat].msg, 1, msg)
        else--联盟频道消息
            if msg.MType >= ALLIANCE_CHAT_TYEP.TaskHelp and msg.MType < PUBLIC_CHAT_TYPE.ChatAttackSuccessShare then--联盟通知
                if not self.msgList[CHAT_TYPE.UnionHelpChat] then
                    self.msgList[CHAT_TYPE.UnionHelpChat] = {}
                    self.msgList[CHAT_TYPE.UnionHelpChat].msg = {}
                end
                for _,banUser in ipairs(self._banList)do
                    if banUser.UserId == msg.SenderId then
                        return
                    end
                end
                table.insert(self.msgList[CHAT_TYPE.UnionHelpChat].msg, 1, msg)
            else
                if not self.msgList[CHAT_TYPE.UnionChat] then
                    self.msgList[CHAT_TYPE.UnionChat] = {}
                    self.msgList[CHAT_TYPE.UnionChat].msg = {}
                end
                for _,banUser in ipairs(self._banList)do
                    if banUser.UserId == msg.SenderId then
                        return
                    end
                end
                table.insert(self.msgList[CHAT_TYPE.UnionChat].msg, 1, msg)
            end
        end
        if msg.SenderId == UserModel.data.accountId then
            self:RefreshList(true)
        else
            self:RefreshList(self.onPullUp)
        end
        self:RefreshHelpList()
    end)

    self:AddEvent(WORLD_CHAT_EVENT.Radio, function(id)
        self._ctrView.selectedIndex = 0
        self.selectRadioId = id
        self.msgType = PUBLIC_CHAT_TYPE.Radio
        self._horeCtrView.selectedIndex = 0
    end)

    self:AddEvent(EventDefines.UIAllianceJoin, function()
        self:RefreshView(self.showType)
    end)

    self:AddEvent(CHAT_EVENT_TYPE.ShowChatBar, function(item)
    end)

    self:AddEvent(WORLD_CHAT_EVENT.BanRefresh, function ()
        self:RefreshBanList()
        if self.msgList[CHAT_TYPE.WorldChat] then
            for i=#self.msgList[CHAT_TYPE.WorldChat].msg, 1, -1 do
                if self._banMap[self.msgList[CHAT_TYPE.WorldChat].msg[i].SenderId] then
                    table.remove(self.msgList[CHAT_TYPE.WorldChat].msg, i)
                end
            end
        end
        if self.msgList[CHAT_TYPE.UnionChat] then
            for i=#self.msgList[CHAT_TYPE.UnionChat].msg, 1, -1 do
                if self._banMap[self.msgList[CHAT_TYPE.UnionChat].msg[i].SenderId] then
                    table.remove(self.msgList[CHAT_TYPE.UnionChat].msg, i)
                end
            end
        end
        if self.msgList[CHAT_TYPE.UnionHelpChat] then
            for i=#self.msgList[CHAT_TYPE.UnionHelpChat].msg, 1, -1 do
                if self._banMap[self.msgList[CHAT_TYPE.UnionHelpChat].msg[i].SenderId] then
                    table.remove(self.msgList[CHAT_TYPE.UnionHelpChat].msg, i)
                end
            end
        end
        self:RefreshList(self.onPullUp)
        self:RefreshHelpList()
    end)

    self:AddEvent(CHAT_EVENT_TYPE.Refresh, function()
        local msg = self.msgList[self.showType].msg
        self._listView.numItems = #msg
    end)

    self:AddEvent(EventDefines.GameOnFocus,function()
        if not self.isShow then
            return
        end
        self.__keyBoardH = 0
        self:InitInputBox()
    end)
end

function Chat:InitInputBox()
    if self._textChat.text == "" then
        self._textChat.displayObject.height = self._inputH
        self._inputText.displayObject.height = self._inputH
    end
    local changeH = self._textChat.displayObject.height - self._inputH
    self._textChat.height = self._textChat.displayObject.height
    self._inputText.height = self._inputText.displayObject.height
    self._boxInput.height = self._boxInputH + changeH
    self._box.height = self._boxH + changeH
    self:BoxMoveTo(self.inputY - changeH)
    self._btnEmojie.asButton.selected = false
end

function Chat:RefreshInputBox()
    local changeH = self._textChat.displayObject.height - self._inputH
    print("=====RefreshInputBox===== " .. self._textChat.displayObject.height)
    self._textChat.height = self._textChat.displayObject.height
    self._inputText.height = self._inputText.displayObject.height
    self._boxInput.height = self._boxInputH + changeH
    self._box.height = self._boxH + changeH

    self._textChat.y = self._boxInput.y + 15
    self._inputText.y = self._boxInput.y + 15
    
    if self.isShowEmojie and self.__keyBoardH <= 0 then
        self:BoxMoveTo(self.inputY - changeH - self._emojieBoxH)
    else
        self:BoxMoveTo(self.inputY - changeH - self.__keyBoardH)
    end
end

local _moveEnd = true
local _moveEndCb = function()
    _moveEnd = true
end

function Chat:BoxMoveTo(posY)
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
        local _listViewChange = 0
        if self.showType == CHAT_TYPE.WorldChat then
            _listViewChange = self.listViewY + posY -self.inputY 
        elseif self.showType == CHAT_TYPE.UnionChat then
            _listViewChange = self.listViewY + self._btnTaskH + posY -self.inputY 
        end
		self:GtweenOnUpdate(self._listView:TweenMoveY(_listViewChange, math.abs(_listViewChange)/1500),function()
            self._view:InvalidateBatchingState(true)
        end)
    end
end

function Chat:RefreshListViewH()
    if self.showType == CHAT_TYPE.WorldChat then
        self._listView.height = self.listViewH
        self._listView.y = self.listViewY
    elseif self.showType == CHAT_TYPE.UnionChat then
        self._listView.height = self.listViewH - self._btnTaskH
        self._listView.y = self.listViewY + self._btnTaskH
    end
end

function Chat:SendMsg(msg)
    local text = string.gsub(msg,"%s+","")
    if msg == "" or text == "" then
        TipUtil.TipById(50197)
        return
    end
    if self._isSend then
        TipUtil.TipById(50269)
        return
    end
    local _sendFun = function()
        local _fun = function()
            self._isSend = false
        end
        self:ScheduleOnce(_fun, Global.ChatSpeechInterval)
        self._isSend = true
    
        local roomId = ""
        if self.showType == CHAT_TYPE.WorldChat then
            roomId = "World"
            SdkModel.TrackBreakPoint(10038)      --打点
        elseif self.showType == CHAT_TYPE.UnionChat then
            roomId = Model.Player.AllianceId
            SdkModel.TrackBreakPoint(10039)      --打点
        end
        local pram = self.selectRadioId and ""..self.selectRadioId or ""
        Net.Chat.SendChat(roomId, Model.Account.accountId, msg, self.msgType, pram, function()
            self._inputText.text = ""
            self._textChat.text = ""
            self.inputClickNum = 0
            self.__keyBoardH = 0
            self.isShowEmojie = false
            self:InitInputBox()
            self:RefreshInputBox()
            self:RefreshListViewH()
            CustomInput.Close()
            Event.Broadcast(EventDefines.UIRefreshBackpack)
        end)
        self.msgType = PUBLIC_CHAT_TYPE.Normal
        self._horeCtrView.selectedIndex = 1 
    end
    if self.msgType == PUBLIC_CHAT_TYPE.Radio then
        local data = {
            content = StringUtil.GetI18n("configI18nCommons", "Ui_Chat_Notice_Tips"),
            sureCallback = function()
                _sendFun()
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        _sendFun()
    end
end

function Chat:RefreshView(type)
    self.onPullUp = true
    self:CheckIsJoin()
    if type == CHAT_TYPE.WorldChat then
        self._textName.text = ConfigMgr.GetI18n("configI18nCommons", "Chat_Server_Title")
    elseif type == CHAT_TYPE.UnionChat then
        self._textName.text = ConfigMgr.GetI18n("configI18nCommons", "Chat_Alliance_Title")
    end
    if not self.msgList[type] then
        self.msgList[type] = {}
        local roomId = ""
        if type == CHAT_TYPE.WorldChat then
            roomId = "World"
            self._textName.text = ConfigMgr.GetI18n("configI18nCommons", "Chat_Server_Title")
        elseif type == CHAT_TYPE.UnionChat then
            roomId = Model.Player.AllianceId
            self._textName.text = ConfigMgr.GetI18n("configI18nCommons", "Chat_Alliance_Title")
        end
        self.msgList[type].msg = {}

        if type == CHAT_TYPE.UnionHelpChat then
            Net.Chat.GetAllianceNoticeHistory(Model.Player.AllianceId, #self.msgList[CHAT_TYPE.UnionHelpChat].msg, self.offset ,function(msg)
                self.msgList[type].msg = {}
                if #self._banList <= 0 then
                    self.msgList[type].msg = msg.History
                else
                    for _,v in pairs(msg.History)do
                        if not self._banMap[v.SenderId] then
                            table.insert(self.msgList[type].msg, v)
                        end
                    end
                end
                self:RefreshHelpList()
            end)
        else
            Net.Chat.GetChatHistory(roomId, #self.msgList[type].msg, self.offset, function(msg)
                local a = Global.AllianceTaskHelp
                self.msgList[type].msg = {}
                if #self._banList <= 0 then
                    -- self.msgList[type].msg = msg.History
                    if roomId == "World" then
                        self.msgList[type].msg = msg.History
                    else
                        for _,v in pairs(msg.History)do
                            if v.MType < ALLIANCE_CHAT_TYEP.TaskHelp or v.MType >= PUBLIC_CHAT_TYPE.ChatAttackSuccessShare then
                                table.insert(self.msgList[type].msg, v)
                            end
                        end
                    end
                else
                    if roomId == "World" then
                        for _,v in pairs(msg.History)do
                            if not self._banMap[v.SenderId] then
                                table.insert(self.msgList[type].msg, v)
                            end
                        end
                    else
                        for _,v in pairs(msg.History)do
                            if not self._banMap[v.SenderId] and 
                            (v.MType < ALLIANCE_CHAT_TYEP.TaskHelp or v.MType >= PUBLIC_CHAT_TYPE.ChatAttackSuccessShare) then
                                table.insert(self.msgList[type].msg, v)
                            end
                        end
                    end
                end
                self:RefreshList(self.onPullUp)
            end)
        end
    else
        if type == CHAT_TYPE.UnionHelpChat then
            self:RefreshHelpList()
        else
            self:RefreshList(self.onPullUp)
        end
    end
end

function Chat:CheckIsJoin()
    if self.showType == CHAT_TYPE.UnionChat and Model.Player.AllianceId == "" then
        self._itemJoin.visible = true
        self._groupDown.visible = false
        self._btnTask.visible = false
        self._listView.visible = false
        return false
    else
        self._itemJoin.visible = false
        self._groupDown.visible = true
        self._btnTask.visible = true
        self._listView.visible = true
        return true
    end
end

function Chat:RefreshListItems( )
    local roomId = ""
    if self.showType == CHAT_TYPE.WorldChat then
        roomId = "World"
    elseif self.showType == CHAT_TYPE.UnionChat then
        roomId = Model.Player.AllianceId
    end
    local len = #self.msgList[self.showType] and #self.msgList[self.showType].msg or 0
    Net.Chat.GetChatHistory(roomId, len, self.offset ,function(msg)
        if not self.msgList[self.showType] then
            self.msgList[self.showType] = {}
            self.msgList[self.showType].offset = 0
            self.msgList[self.showType].msg = {}
        end
       
        for _,v in pairs(msg.History)do
            if #self._banList <= 0 then
                table.insert(self.msgList[self.showType].msg, v)
            else
                if not self._banMap[v.SenderId] then
                    table.insert(self.msgList[self.showType].msg, v)
                end
            end
        end
        if self._listView.numItems == #self.msgList[self.showType].msg then
            return
        end
        self:RefreshList()
    end)
end

function Chat:RefreshListHelpItems()
    Net.Chat.GetAllianceNoticeHistory(Model.Player.AllianceId, #self.msgList[CHAT_TYPE.UnionHelpChat].msg, self.offset ,function(msg)
        if not self.msgList[CHAT_TYPE.UnionHelpChat] then
            self.msgList[CHAT_TYPE.UnionHelpChat] = {}
            self.msgList[CHAT_TYPE.UnionHelpChat].msg = {}
        end
       
        for _,v in pairs(msg.History)do
            if #self._banList <= 0 then
                table.insert(self.msgList[CHAT_TYPE.UnionHelpChat].msg, v)
            else
                if not self._banMap[v.SenderId] then
                    table.insert(self.msgList[CHAT_TYPE.UnionHelpChat].msg, v)
                end
            end
        end
        if self._listView.numItems == #self.msgList[CHAT_TYPE.UnionHelpChat].msg then
            return
        end
        self:RefreshHelpList()
    end)
end

function Chat:RefreshList(isScrollBottom)
    local msg = self.msgList[self.showType].msg
    self._listView.numItems = #msg
    if isScrollBottom then
        self._listView.scrollPane:ScrollBottom()
    end

    if self.msgList[CHAT_TYPE.WorldChat] and #msg > 0 then
        if self._banMap[msg.SenderId] then
            return
        end
        ChatModel.newWorldMsgs = self.msgList[CHAT_TYPE.WorldChat].msg[1]
    end
    if self.msgList[CHAT_TYPE.UnionChat] and #msg > 0 then
        if self._banMap[msg.SenderId] then
            return
        end
        ChatModel.newUnionMsgs = self.msgList[CHAT_TYPE.UnionChat].msg[1]
    end
    Event.Broadcast(WORLD_CHAT_EVENT.Refresh)
end

function Chat:RefreshHelpList()
    if not self.msgList[CHAT_TYPE.UnionHelpChat] then
        return
    end
    local msg = self.msgList[CHAT_TYPE.UnionHelpChat].msg
    if #msg > 0 then
        self.taskerName.text = msg[1].Sender ..":"
        ChatModel:SetMsgTemplateByType(self.taskerMsg, CHAT_TYPE.UnionHelpChat, msg[1])
        self.taskerName.visible = true
        self.taskerMsg.visible = true
    else
        self.taskerName.visible = false
        self.taskerMsg.visible = false
    end
    self._listViewTask.numItems = #msg
    self._listViewTask.scrollPane:ScrollBottom()
end

function Chat:OnHide()
    CustomInput.Close()
end

function Chat:Close()
    UIMgr:Close("Chat")
end

function Chat:OnClose(  )
    self.isShow = false
end

return Chat