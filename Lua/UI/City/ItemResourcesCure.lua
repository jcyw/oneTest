--[[
    Author: songzeming
    Function: 资源数量显示和刷新Item 资源不足时可添加资源 带背景框(医院)
]]
local ItemResourcesCure = fgui.extension_class(GComponent)
fgui.register_extension('ui://Common/itemResourcesCure', ItemResourcesCure)

function ItemResourcesCure:ctor()
    self:AddListener(self._btnAdd.onClick,function()
        self:OnBtnAddClick()
    end)
end

function ItemResourcesCure:Init(category, amount)
    self.category = category
    self.amount = amount
    self._icon.icon = UITool.GetIcon(ConfigMgr.GetItem('configResourcess', category).img)
    local totalAmount = Model.Resources[category].Amount
    local isEnough = totalAmount - amount >= 0
    local formateAmount = UITool.GetTextColor(isEnough and GlobalColor.White or GlobalColor.Red, Tool.FormatAmountUnit(amount))
    self._title.text = formateAmount .. "/" .. Tool.FormatAmountUnit(totalAmount)
    self._btnAdd.visible = not isEnough
end

function ItemResourcesCure:InitCb(cb)
    self.cb = cb
end

function ItemResourcesCure:GetCategory()
    return self.category
end

function ItemResourcesCure:GetAmount()
    return self.amount
end

function ItemResourcesCure:OnBtnAddClick()
    UIMgr:Open("ResourceDisplay", self.category, self.category, self.amount - Model.Resources[self.category].Amount, function()
        if self.cb then
            self.cb()
        end
    end)
end

return ItemResourcesCure
