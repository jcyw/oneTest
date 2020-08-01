--[[
    Author: songzeming
    Function: 道具列表 长 通用
]]
local ItemAccProp = fgui.extension_class(GButton)
fgui.register_extension("ui://MainCity/itemBuildAccelerateTips", ItemAccProp)
import("UI/Common/ItemProp")

function ItemAccProp:ctor()
end

function ItemAccProp:Init(data)
    self._title.text = data.Title
    self._num.text = data.Amount
    self._item:SetAmount(nil, nil, data.Amount, data.Title)
end


return ItemAccProp

