--[[
    author:Temmie
    time:2020-07-01 11:20:55
    function:分两列的长按弹出tip
]]
local LongPressPopupLabelTwo = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://Common/LongPressPopupLabelTwo", LongPressPopupLabelTwo)

function LongPressPopupLabelTwo:ctor()

end

--[[
    data:
        contentL,
        contentR
]]
function LongPressPopupLabelTwo:InitLabel(title, datas)
    self._titleText.text = title
    self.datas = datas 

    self:RefreshList()
end

function LongPressPopupLabelTwo:RefreshList()
    self._list:RemoveChildrenToPool()
    for _,v in pairs(self.datas) do
        local item = self._list:AddItemFromPool()
        item:GetChild("_textL").text = v.contentL
        item:GetChild("_textR").text = v.contentR
    end
    self._list:ResizeToFit(#self.datas)
end

return LongPressPopupLabelTwo
