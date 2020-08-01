--author: 	Amu
--time:		2020-04-23 11:29:11

local BeautyReloadingArrow = fgui.extension_class(GComponent)
fgui.register_extension("ui://BeautySystem/BeautyReloadingArrow", BeautyReloadingArrow)

function BeautyReloadingArrow:ctor()
    self._touch = self:GetChild("touch")

    self._arrow = self:GetChild("arrow")
    self._hand = self:GetChild("hand")

    self._anim = self:GetTransition("Loop")

    self:InitEvent()
end

function BeautyReloadingArrow:InitEvent( )
    -- self:AddListener(self._touch.onClick,function()--返回
    --     -- self:Close()
    -- end)

    local _touchX = 0
    local _touchY = 0

    local _move = 0

    self:AddListener(self.onTouchBegin,function(context)
        _move = 0
        _touchX = context.inputEvent.x
        _touchY = context.inputEvent.y
    end)

    self:AddListener(self.onTouchEnd,function(context)
        _move = context.inputEvent.y - _touchY
        if math.abs(_move) > 100 and not self._show then
            self._show = true
            if self.flowerCb then
                self.flowerCb(self.unLockCostume)
            end
            self._anim:Stop()
            self._moveAnim:Play(function()
                if self.cb then
                    self.cb()
                end
            end)
        end
    end)
end

function BeautyReloadingArrow:Show(cb, flowerCb, moveAnim, unLockCostume)
    self._show = false
    self.unLockCostume = unLockCostume
    self._anim:Play(-1, 0, function()
    end)
    self.cb = cb
    self._moveAnim = moveAnim
    self.flowerCb = flowerCb
end


function BeautyReloadingArrow:Close( )
    UIMgr:Close("BeautyReloadingArrow")
end

return BeautyReloadingArrow