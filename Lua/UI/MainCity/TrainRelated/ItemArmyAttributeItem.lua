--[[
    Author: xiaoze
    Function: 训练进阶 兵种属性item
]]
local ItemArmyAttributeItem = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/ItemArmyAttributeItem", ItemArmyAttributeItem)

function ItemArmyAttributeItem:ctor()
    self._ctrType = self:GetController("type")
    self._ctrColor = self:GetController("color")

    self._textTitle = self._bar:GetChild("title")
    self._textContent = self._bar:GetChild("_text")
    self._textBar = self._bar:GetChild("_attack")
    self._textBarOver = self._textBar:GetChild("barOver")
end

function ItemArmyAttributeItem:SetAttribute(title, value, text)
    self._ctrType.selectedPage = "attribute"
    self._textTitle.text = title
    self._textBar.value = value
    self._textContent.text = text and text or ""
    self:SetAttributeOver(false)
end

function ItemArmyAttributeItem:SetAttributeOver(isOver, value, text)
    self._textBarOver.visible = isOver
    if not isOver then
        return
    end
    
    self._textBarOver.width = self._textBar.width * value
    self._textContent.text = text and text or ""
end

function ItemArmyAttributeItem:SetLevel(level)
    self._ctrType.selectedPage = "title"
    self._title.text = ConfigMgr.GetI18n(I18nType.Commmon, "UI_Details_Level")
    self._content.text = level
    self:SetHighColor(false)
end

function ItemArmyAttributeItem:SetHighColor(isHighColor)
    self._ctrColor.selectedPage = isHighColor and "next" or "current"
end

return ItemArmyAttributeItem