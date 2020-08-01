--author: 	Amu
--time:		2019-09-06 19:35:54

local ItemSlidePointBlue = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/btnListPoint", ItemSlidePointBlue)

function ItemSlidePointBlue:ctor()
    self._ctrView = self:GetController("button")

    self:InitEvent()
end

function ItemSlidePointBlue:InitEvent()
end

function ItemSlidePointBlue:SetData(page, index)
    self.index = index
    if index == page then
        self._ctrView.selectedIndex = 1
    else
        self._ctrView.selectedIndex = 0
    end
end

function ItemSlidePointBlue:GetIndex()
    return self.index
end

return ItemSlidePointBlue