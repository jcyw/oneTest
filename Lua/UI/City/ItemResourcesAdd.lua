--[[
    Author: songzeming
    Function: 资源数量显示和刷新Item 资源不足时可添加资源
]]
local ItemResourcesAdd = fgui.extension_class(GComponent)
fgui.register_extension('ui://Common/itemResourcesAdd', ItemResourcesAdd)

function ItemResourcesAdd:ctor()
    self:AddListener(self._btnAdd.onClick,function()
        self:OnBtnAddClick()
    end)
end

function ItemResourcesAdd:Init(category, amount)
    self.category = category
    self.amount = amount
    self._icon.icon = UITool.GetIcon(ConfigMgr.GetItem('configResourcess', category).img)
    local totalAmount = Model.Resources[category].Amount
    local isEnough = totalAmount - amount >= 0
    self._title.text = UITool.GetTextColor(isEnough and GlobalColor.White or GlobalColor.Red, Tool.FormatAmountUnit(amount))
    self._btnAdd.visible = not isEnough
end

function ItemResourcesAdd:InitCb(cb)
    self.cb = cb
end

function ItemResourcesAdd:SetBg(active)
    self._bg.visible = active
end

function ItemResourcesAdd:GetCategory()
    return self.category
end

function ItemResourcesAdd:GetAmount()
    return self.amount
end

function ItemResourcesAdd:OnBtnAddClick()
    UIMgr:Open("ResourceDisplay", self.category, self.category, self.amount - Model.Resources[self.category].Amount, function()
        if self.cb then
            self.cb()
        end
    end)
end

return ItemResourcesAdd
