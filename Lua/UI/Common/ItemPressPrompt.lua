--[[
    Author: songzeming
    Function: 按下弹窗
]]
local ItemPressPrompt = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/ItemPressPrompt", ItemPressPrompt)

local CTR = {
    Hide = 0,
    Right = 1,
    Left = 2
}

function ItemPressPrompt:ctor()
    self._ctr = self:GetController("Ctr")
    self.defaultHeight = self._desc.height
end

function ItemPressPrompt:SetArrowHide(text, time)
    self:ShowText(CTR.Hide, text, time)
end

function ItemPressPrompt:SetArrowLeft(text, time)
    self:ShowText(CTR.Left, text, time)
end

function ItemPressPrompt:SetArrowRight(text, time)
    self:ShowText(CTR.Right, text, time)
end

function ItemPressPrompt:SetVisible(flag)
    GTween.Kill(self)
    self.visible = flag
end

function ItemPressPrompt:ShowText(ctr, text, time)
    self._ctr.selectedIndex = ctr
    self._desc.text = text

    --设置对齐方式 *1.2是防止默认高度比实际高度大几像素
    if self._desc.height > self.defaultHeight * 1.2 then
        self._desc.align = AlignType.Left
    else
        self._desc.align = AlignType.Center
    end

    self:SetVisible(true)
    GTween.Kill(self)
    if not time then
        time = 3
    end
    self:GtweenOnComplete(self:TweenFade(1, time),function()
        self:SetVisible(false)
    end)
end

return ItemPressPrompt
