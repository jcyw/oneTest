--author: 	Amu
--time:		2020-04-13 19:46:25

local ItemArrowBtn = fgui.extension_class(GComponent)
fgui.register_extension("ui://BeautySystem/itemArrowBtn", ItemArrowBtn)

function ItemArrowBtn:ctor()
    self._btnSMS = self:GetChild("btnSMS")

    self:InitEvent()
end

function ItemArrowBtn:InitEvent()

    self:AddListener(self._btnArrowL.onClick,function()
        Event.Broadcast(BEAUTY_GIRL_EVENT.LeftArrow)
    end)

    self:AddListener(self._btnArrowR.onClick,function()
        Event.Broadcast(BEAUTY_GIRL_EVENT.RightArrow)
    end)

    self:AddListener(self.onClick,function()
        if self.cb then
            self.cb()
        end
    end)
end

function ItemArrowBtn:SetCallBack(cb)
    self.cb = cb
end

return ItemArrowBtn