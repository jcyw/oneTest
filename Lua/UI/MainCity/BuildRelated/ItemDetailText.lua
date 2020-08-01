--[[
    Author: songzeming
    Function: 信息条 升级和详情
]]
local ItemDetailText = fgui.extension_class(GComponent)
fgui.register_extension('ui://MainCity/itemUgradeText', ItemDetailText)

function ItemDetailText:ctor()
end

function ItemDetailText:Init(title, base, add)
    self._title.text = title

    if Tool.Integer(base) then
        base = Tool.FormatNumberThousands(base)
    end
    self._base.text = base
    self._add.text = add
end

return ItemDetailText
