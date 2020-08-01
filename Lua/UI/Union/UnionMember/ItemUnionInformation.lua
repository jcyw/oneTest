--[[
    Author: songzeming
    Function: 联盟成员列表 职位排序Item
]]
local ItemUnionInformation = fgui.extension_class(GButton)
fgui.register_extension("ui://Union/itemUnionAllInformation", ItemUnionInformation)
function ItemUnionInformation:ctor()
end

--设置参数
function ItemUnionInformation:SetData()
    self._title.text = ""
    self._name.text = ""
    self._member.text = ""
end

return ItemUnionInformation
