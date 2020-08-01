--author: 	Amu
--time:		2019-11-19 10:24:45

local ConfirmDoublePopup = UIMgr:NewUI("ConfirmDoublePopup")

function ConfirmDoublePopup:OnInit()
    self._view = self.Controller.contentPane
    self._content = self._view:GetChild("content")
    self._btnClose = self._view:GetChild("btnClose")
    self._btn1 = self._view:GetChild("btnCity")
    self._btn2 = self._view:GetChild("btnUnion")

    self._ctrView = self._view:GetController("c1")

    self._view.sortingOrder = 10  -- 断线重连弹窗层级最高
    
    self:InitEvent()
end

function ConfirmDoublePopup:InitEvent( )
    self:AddListener(self._btnClose.onClick,function()
        self:Close()
        if self.leftEvent then
            self.leftEvent()
        end
    end)

    self:AddListener(self._btn1.onClick,function()
        self:Close()
        if self.leftEvent then
            self.leftEvent()
        end
    end)

    self:AddListener(self._btn2.onClick,function()
        self:Close()
        if self.rightEvent then
            self.rightEvent()
        end
    end)
end

function ConfirmDoublePopup:OnOpen(index, info)
    self._ctrView.selectedIndex = index
    self.leftEvent = info.leftEvent
    self.rightEvent = info.rightEvent
    self.closeEvent = info.closeEvent
    if info.content then
        self._content.text = info.content
    end
    if info.leftBtn then
        self._btn1.text = info.leftBtn
    end
    if info.rightBtn then
        self._btn2.text = info.rightBtn
    end
end

function ConfirmDoublePopup:Close()
    UIMgr:Close("ConfirmDoublePopup")
end

function ConfirmDoublePopup:OnClose()
    if self.closeEvent then
        self.closeEvent()
    end
end

return ConfirmDoublePopup
