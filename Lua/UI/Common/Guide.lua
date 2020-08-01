--[[
    author:{maxiaolong}
    time:2019-11-19 21:12:51
    function:{引导图标}
]]
local Guide = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/Guide", Guide)

function Guide:ctor()
    self._aniGuide = self:GetTransition("EffGuide")
    self._aniDragGuide = self:GetTransition("DragAni")
    self._c2 = self:GetController("c2")
    self._arrowTop = self:GetChild("arrowTop")
    self._arrowDown = self:GetChild("arrowDown")
end

function Guide:Init(scale)
    self:SetScale(scale[1], scale[2])
    self._c2.selectedIndex = 0
end

function Guide:OnOpen()
    self:GuideAniPlay()
end

function Guide:GuideAniPlay()
    self._aniDragGuide:Stop()
    self._aniGuide:Play()
end

function Guide:PlayTime(times, delay, callback)
    self._aniGuide:Play(times, delay, callback)
end

function Guide:PlayLoop()
    self._aniGuide:Play(-1, 0, nil)
end

function Guide:GuideAniStop()
    self._aniGuide:Stop()
end

--播放手指拖动动画
function Guide:PlayDragAni()
    self._aniGuide:Stop()
    self._aniDragGuide:Play(-1, 0, nil)
end

function Guide:SetTopAnim(isTop)
    if isTop then
        self._c2.selectedIndex = 1
    else
        self._c2.selectedIndex = 0
    end
end

function Guide:SetShow(isShow)
    if self.visible ~= isShow then
        if self.visible == true then
            self._c2.selectedIndex = 0
            self:SetScale(1, 1)
        elseif self.visible == false then
            self:PlayLoop()
        end
    end
    self.visible = isShow
end

function Guide:SetInitSize()
    local h = self.height
    local w = self.width
end

--还原位置
function Guide:ResetTrans()
    self:SetScale(1, 1)
    self:SetXY(-4000, -4000)
    self.rotation = 0
end

function Guide:SetTrans(x, y, r)
    if not self.visible then
        self.visible = true
    end
    self:SetXY(x, y)
    if r == nil then
        r = 0
    end
    self.rotation = r
end

function Guide:SetPointerScale(offset)
    local scaleX = 1 / self.scale.x
    local scaleY = 1 / self.scale.y
    if not offset then
        self._arrowTop:SetScale(1, 1)
        self._arrowDown:SetScale(1, 1)
    else
        local scaleOffsetX = self._arrowTop.scale.x * scaleX * offset
        local scaleOffsetY = self._arrowTop.scale.y * scaleY * offset
        self._arrowTop:SetScale(scaleOffsetX, scaleOffsetY)
        self._arrowDown:SetScale(scaleOffsetX, scaleOffsetY)
    end
end

function Guide:SetArrowSize(offset)
    self._arrowTop:SetScale(1 * offset, 1 * offset)
    self._arrowDown:SetScale(1 * offset, 1 * offset)
end

function Guide:SetGuideScale(scale)
    self:SetScale(1 * scale, 1 * scale)
end

return Guide
