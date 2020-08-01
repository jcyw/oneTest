--[[
    Author: songzeming
    Function: 图片公用组件
]]
local ItemImage = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/itemImage", ItemImage)

function ItemImage:ctor()
    self._icon = self:GetChild("icon")
    self:DefaultTypeset()
end

function ItemImage:SetImage(image)
    self._icon.icon = image
end

--默认排版
function ItemImage:DefaultTypeset()
    self.visible = true
    self.touchable = false
    self.alpha = 1
    self._icon.pivot = Vector2(0.5, 1)
    self._icon.pivotAsAnchor = true
    self._icon.xy = Vector2(0, 0)
    self._icon.align = AlignType.Center
    self._icon.verticalAlign = VertAlignType.Bottom
    self.scale = Vector2(1, 1)
end

function ItemImage:GetContext()
    return self
end

return ItemImage
