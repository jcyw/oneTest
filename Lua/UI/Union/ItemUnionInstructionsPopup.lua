--author: 	Amu
--time:		2019-11-01 15:14:29

local ItemUnionInstructionsPopup = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionInstructionsPopup", ItemUnionInstructionsPopup)

ItemUnionInstructionsPopup.iconItemList = {}

function ItemUnionInstructionsPopup:ctor()
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")

    self:InitEvent()
end

function ItemUnionInstructionsPopup:InitEvent(  )

end

function ItemUnionInstructionsPopup:SetData(info)
    self._id = info.mail_type
    self._title.text = StringUtil.GetI18n("configI18nCommons", info.name) 
    self._icon.icon = UITool.GetIcon(info.image)
end

function ItemUnionInstructionsPopup:GetType()
    return self._id
end

return ItemUnionInstructionsPopup