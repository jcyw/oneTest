--author: 	Amu
--time:		2020-02-26 12:01:41

local ItemPointRed = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemPointRed", ItemPointRed)

ItemPointRed.tempList = {}

function ItemPointRed:ctor()
    -- self._numText = self:GetChild("text")
    self:InitEvent()
end

function ItemPointRed:InitEvent()

end

function ItemPointRed:SetData(visible, num)
    self.visible = visible
    -- if num then
    --     self._numText.text = num
    -- end
end

return ItemPointRed