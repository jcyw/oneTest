--author: 	Amu
--time:		2020-06-08 14:28:52

local BtnGm = fgui.extension_class(GButton)
fgui.register_extension("ui://Loading/btnGm", BtnGm)

function BtnGm:ctor()
    self._redPoint = self:GetChild("redPoint")
    self._redPoint.visible = false
    self:InitEvent()
end

local newPointCB
local readCb
function BtnGm:InitEvent()
    Log.Info("BtnGm:InitEvent {0}", self)
    self:AddListener(self.onClick, function()
        Sdk.AiHelpShowConversation(Util.GetDeviceId(), "logining")
        SdkModel.GmNotRead = 0
        Event.Broadcast(GM_MSG_EVENT.MsgIsRead)
    end)

    newPointCB = function()
        self._redPoint.visible = true
    end

    readCb = function()
        self._redPoint.visible = false
    end

    self:AddEvent(GM_MSG_EVENT.NewMsgNotRead, newPointCB)
    self:AddEvent(GM_MSG_EVENT.MsgIsRead, readCb)
end

function BtnGm:Hide()
    self:RemoveFromParent()
    self:Dispose()
    SdkModel.GmNotRead = 0
end

return BtnGm