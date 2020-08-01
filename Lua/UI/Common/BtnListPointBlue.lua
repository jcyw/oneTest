--author: 	Amu
--time:		2019-12-03 17:43:06

local BtnListPointBlue = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/btnListPointBlue", BtnListPointBlue)

function BtnListPointBlue:ctor()
    self._point = self:GetChild("point")
    self._ctrView = self:GetController("c1")

    self:InitEvent()
end

function BtnListPointBlue:InitEvent()
end

function BtnListPointBlue:SetData(page, index)
    self.index = index
    -- self._point.visible = not(index == page)
    if index == page then
        self._ctrView.selectedIndex = 1
    else
        self._ctrView.selectedIndex = 0
    end
end

function BtnListPointBlue:GetIndex()
    return self.index
end

return BtnListPointBlue