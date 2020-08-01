--[[
    Author: songzeming
    Function: 联盟设置 修改联盟交流语言列表Item
]]
local ItemUnionSetupLanguageBox = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemItemUnionReviseLanguageItem", ItemUnionSetupLanguageBox)

function ItemUnionSetupLanguageBox:ctor()
    self._title = self:GetChild("textLanguage")
    self._checkBox = self:GetChild("checkBox")
    self:AddListener(self._checkBox.onChanged,function()
        if self:GetCheck() then
            self.cb()
        end
    end)
end

function ItemUnionSetupLanguageBox:Init(title, flag, cb)
    self.cb = cb
    self._title.text = title
    self:SetCheck(flag)
end

function ItemUnionSetupLanguageBox:SetCheck(flag)
    self._checkBox.selected = flag
    self._checkBox.touchable = not flag
end

function ItemUnionSetupLanguageBox:GetCheck()
    return self._checkBox.selected
end

return ItemUnionSetupLanguageBox