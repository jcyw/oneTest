--author: 	Amu
--time:		2020-02-26 12:01:17

local ItemPointGreen = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemPointGreen", ItemPointGreen)

ItemPointGreen.tempList = {}

function ItemPointGreen:ctor()
    self._textPoint = self:GetChild("textPoint")
    self._numText = self:GetChild("text")
    self:InitEvent()
end

function ItemPointGreen:InitEvent()

end

function ItemPointGreen:SetData(visible, num)
    self._textPoint.visible = visible
    self._numText.visible = visible
    if num then
        if type(num) == "number" and num > 99 then
            self._numText.text = "99+"
        else
            self._numText.text = num
        end
    end
end

return ItemPointGreen