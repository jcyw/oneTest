--author: 	Amu
--time:		2019-07-18 18:02:48

local ChatModel = import("Model/ChatModel")

local ChatTips = UIMgr:NewUI("ChatTips")

local speed = Global.BroadCastSpeed

function ChatTips:OnInit()
    local _view = self.Controller.contentPane
    self._view = _view
    self._btnClose = _view:GetChild("btnClose")
    self._bg = _view:GetChild("bg")
    self._cg = _view:GetChild("n1")
    self._title = self._cg:GetChild("title")

    self._ctrView = _view:GetController("c1")
    self._ctrView2 = _view:GetController("c2")

    self._bgY = self._bg.y

    -- _view.touchable = false
    -- self._btnClose.touchable = true

    self._title.emojies = EmojiesMgr:GetEmojies()

    self._textX = GRoot.inst.width
    self._bgW = self._cg.width

    self:InitEvent()
end

function ChatTips:InitEvent( )
    self:AddListener(self._btnClose.onClick,function()
        self:Close()
    end)

    self:AddListener(self._cg.onClick,function()
        ChatModel:JumpToByMsgType(MSG_TYPE.RMsg, self.msg, self._cg)
    end)

    self:AddEvent(EventDefines.ExitCasinoRadioChatEvent, function(msg)
        if self.type == RADIO_TYPE.CasinoRadio then        --赌场喇叭
            self:Close()
        else
            self:RefreshTip()
        end
    end)

    self:AddEvent(EventDefines.ExitTurnRadioChatEvent, function(msg)
        if self.type == RADIO_TYPE.TurnRadio then        --转盘喇叭
            self:Close()
        else
            self:RefreshTip()
        end
    end)

    self:AddEvent(EventDefines.OpenTurnRadioChatEvent, function(msg)
        self:RefreshTip()
    end)

    self:AddEvent(EventDefines.OpenCasinoRadioChatEvent, function(msg)
        self:RefreshTip()
    end)

    self:AddEvent(EventDefines.OpenRangeRewardRecord, function(msg)
        if ChatModel.casinoTipsIsShow then
            self._view.visible = false
        end
    end)

    self:AddEvent(EventDefines.ExitRangeRewardRecord, function(msg)
        if ChatModel.casinoTipsIsShow then
            self._view.visible = true
        end
    end)
end

function ChatTips:OnOpen(type, msg)
    -- self:ScheduleOnce(function() 
    --     self:Close() 
    -- end, 3)
    self.type = type
    self.msg = msg

    if self.msg.Style then
        --TODO
        --喇叭气泡
    end

    if self.msg.IsGM then
        self._ctrView.selectedIndex = 1
    else
        self._ctrView.selectedIndex = 0
    end

    if ChatModel.trurnTipsIsShow then
        self._ctrView2.selectedIndex = 1
    else
        self._ctrView2.selectedIndex = 0
    end


    self._title.text = TextUtil:ReplaceMoreBySpace(msg.Content, "\n", -1)

    local config = ConfigMgr.GetItem("configAnnouncements", msg.NotifyId)
    local _width = -self._title.displayObject.width

    if self.type == RADIO_TYPE.CasinoRadio then
        self._cg.touchable = true
    else
        self._cg.touchable = false
    end

    self:Roll(_width, config.rollTime)
    self:RefreshTip()
end

function ChatTips:Roll(_width, time)
    time = time - 1
    self._title.x = self._bgW
    self:GtweenOnComplete(self._title:TweenMoveX(_width, (math.abs(_width)+self._bgW)/speed):SetEase(EaseType.Linear),function()
        if time > 0 then
            self:Roll(_width, time)
        else
            self:Close()
        end
    end)
end

function ChatTips:RefreshTip()
    if ChatModel.casinoTipsIsShow then
        self._btnClose.visible = false
        self._bg.y = self._bgY + 50
    elseif ChatModel.trurnTipsIsShow then
        self._btnClose.visible = false
        self._bg.y = self._bgY + 115
    else
        self._btnClose.visible = true
        self._bg.y = self._bgY 
    end
end

function ChatTips:Close()
    GTween.Kill(self._title)
    UIMgr:Close("ChatTips")
    Event.Broadcast(EventDefines.RadioEndChatEvent)
end

-- function ChatTips:OnClose()
-- end

return ChatTips