--[[
    author:{autor}
    time:2020-02-24 21:19:52
    function:{触发引导UI}
]]
local GlobalVars = GlobalVars
local UIMaskManager = UIMgr:NewUI("UIMaskManager")

function UIMaskManager:OnInit()
    self._view = self.Controller.contentPane
    self._c1 = self._view:GetController("c1")
    self._c1.selectedIndex = 1
    self._rectMask = self._rectCom:GetChild("mask")
    self._roundMask = self._roundCom:GetChild("mask")
    self._rectMask1 = self._rectCom1:GetChild("mask")
    self._roundMask1 = self._roundCom1:GetChild("mask")
    self._rectMask:SetPivot(0.5, 0.5)
    self._roundMask:SetPivot(0.5, 0.5)
    self._rectMask1:SetPivot(0.5, 0.5)
    self._roundMask1:SetPivot(0.5, 0.5)

    self._btnClose.visible = false
    self._maskW = self._rectMask.width
    self._maskH = self._rectMask.height
    self.guideCanvas = UIMgr:GetUI("GuideCanvas")

    self:AddListener(
        self._btnClose.onClick,
        function()
            self:OnClose()
        end
    )
end

function UIMaskManager:OnOpen(pos, callback)
    self.isTriggerView = nil
    if not pos then
        UIMgr:Open("GuideLayer")
        return
    end
    UIMgr:Open("GuideLayer", Vector2(pos[1], pos[2]))
    self:SetPosParams(pos)
    if callback then
        self.callback = callback
    end
end

function UIMaskManager:SetPosParams(pos, isRect)
    self:SetRectOrRound(isRect)
    local cutMask1, cutMask2 = self:GetCurrentMask()
    cutMask1:SetSize(self._maskW, self._maskH)
    cutMask2:SetSize(self._maskW, self._maskH)
    local cutBg = nil
    local cutBg1 = nil
    if self._c1.selectedIndex == 0 then
        cutBg = self._rectCom:GetChild("bg")
        cutBg1 = self._rectCom1:GetChild("bg")
    else
        cutBg = self._roundCom:GetChild("bg")
        cutBg1 = self._roundCom1:GetChild("bg")
    end
    if GlobalVars.IsNoviceGuideStatus then
        cutBg.visible = false
        cutBg1.visible = false
    else
        cutBg.visible = true
        cutBg1.visible = true
    end
    local x = pos[1]
    local y = pos[2]
    self.cutPosX = x
    self.cutPosY = y
    local width = self._cutMask.width
    local height = self._cutMask.height
    x = x - width / 2
    y = y - height / 2
    self._cutMask:SetXY(x, y)
    self._cutMask1:SetXY(x, y)
    self:SetGuidePos({x, y})
    local guideLayer = UIMgr:GetUI("GuideLayer")
    if guideLayer._box.visible then
        guideLayer._box.visible = false
    end
end

function UIMaskManager:SetRectOrRound(isRect)
    if isRect then
        self._c1.selectedIndex = 0
    else
        self._c1.selectedIndex = 1
    end
end

function UIMaskManager:SetGuideBox(xy, wh)
    local guideLayer = UIMgr:GetUI("GuideLayer")
    guideLayer._box.visible = true
    guideLayer._box:SetXY(xy[1], xy[2])
    guideLayer._box.width = wh[1]
    guideLayer._box.height = wh[2]
    return guideLayer._box
end

function UIMaskManager:SetGuidePos(pos)
    local guideLayer = UIMgr:GetUI("GuideLayer")
    guideLayer:SetPos(Vector2(pos[1], pos[2]))
end

--设置提示框位置
function UIMaskManager:SetTipPos(pos, isTop, des)
    local guideLayer = UIMgr:GetUI("GuideLayer")
    local tipText = guideLayer._tipText
    tipText.visible = true
    local offsetPosY = 0
    offsetPosY = tipText.height
    if isTop then
        offsetPosY = offsetPosY * -1
    else
        offsetPosY = offsetPosY / 2
    end
    tipText:GetChild("_contentText").text = des
    tipText.xy = Vector2(pos[1], pos[2] + offsetPosY)
end

function UIMaskManager:SetGuideLayerTouch(callback)
    local guideLayer = UIMgr:GetUI("GuideLayer")
    guideLayer:SetTochView(callback)
end

function UIMaskManager:GetCurrentMask()
    if self._c1.selectedIndex == 0 then
        self._cutMask = self._rectMask
        self._cutMask1 = self._rectMask1
    else
        self._cutMask = self._roundMask
        self._cutMask1 = self._roundMask1
    end
    return self._cutMask, self._cutMask1
end

--设置缩放设置遮罩属性
function UIMaskManager:SetScale(scale)
    self.cutClipScale = Vector2(scale[1], scale[2])
    local guideMask = self._cutMask
    guideMask:SetScale(scale[1], scale[2])
    self._cutMask1:SetScale(scale[1] * 0.6, scale[2] * 0.6)
    --设置遮罩属性
end

--设置shader遮罩属性
function UIMaskManager:SetGuideClipPara(parentNode)
    local ratio = Screen.width / 750
    local cutPosX, cutPosY = self.cutPosX * ratio, self.cutPosY * ratio
    self.guideCanvas:SetPosOrScale(Vector2(cutPosX, cutPosY), self.cutClipScale)
end

function UIMaskManager:SetGuideClipInitPos(pos, radius)
    --不显示黑色遮罩
    self.guideCanvas:SetProp(pos, radius)
end

function UIMaskManager:OnClose()
    UIMgr:Close("GuideLayer")
    self:SetGuideMaskClose()
    if self.isTriggerView then
        return
    end
    if self.callback then
        self.callback()
    end
end

--设置蒙版显示
function UIMaskManager:SetGuideMaskClipShow()
    self.guideCanvas:SetShow()
end

function UIMaskManager:SetGuideMaskClose()
    self.guideCanvas:SetClose()
end

function UIMaskManager:SetClose(isTriggering)
    self.isTriggerView = isTriggering
end

function UIMaskManager:GetGuideLayer()
    local guideLayer = UIMgr:GetUI("GuideLayer")
    return guideLayer
end

function UIMaskManager:SetGuideLayerScale(scale)
    local guideLayer = UIMgr:GetUI("GuideLayer")
    guideLayer:SetScale(scale)
    guideLayer._guide.x = guideLayer._guide.x - 25
    guideLayer._guide.y = guideLayer._guide.y - 25
end

function UIMaskManager:SetGuidePointerScale(offset)
    local pointer = UIMgr:GetUI("GuideLayer")
    pointer:SetPointerScale(offset)
end

return UIMaskManager
