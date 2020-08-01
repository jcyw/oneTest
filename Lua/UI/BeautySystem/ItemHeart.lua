--author: 	Amu
--time:		2020-03-11 20:48:05

local ItemHeart = fgui.extension_class(GComponent)
fgui.register_extension("ui://BeautySystem/itemHeart", ItemHeart)

function ItemHeart:ctor()
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("textHeart1")

    self:InitEvent()
end

function ItemHeart:InitEvent()

end

function ItemHeart:SetData(num)
    self.num = num
    self._title.text = num
end

return ItemHeart