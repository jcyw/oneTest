--[[
    Author: songzeming
    Function: 联盟医院 点击治疗伤兵按钮
]]
local ItemUnionHospital = fgui.extension_class(GButton)
fgui.register_extension("ui://Union/itemUnionHospital", ItemUnionHospital)

function ItemUnionHospital:ctor()
    self:AddListener(self.onClick,function()
        self:OnBtnClick()
    end)
end

function ItemUnionHospital:Init(title, cb)
    self._title.text = title
    self.cb = cb
end

function ItemUnionHospital:OnBtnClick()
    self.cb()
end

return ItemUnionHospital